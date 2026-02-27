class ChannelAnalysisJob < ApplicationJob
  queue_as :default

  def perform(analysis_id)
    @analysis = Analysis.find(analysis_id)
    
    begin
      @analysis.update!(status: :running, started_at: Time.current)
      
      # Spawn 6 FREE Codex research agents
      spawn_research_agents
      
      # Mark as completed
      @analysis.update!(
        status: :completed,
        completed_at: Time.current,
        cost: 0.00 # FREE agents!
      )
      
      # Send completion email
      AnalysisMailer.completed(@analysis).deliver_later
      
      # Broadcast to WebSocket (if user is watching live)
      ActionCable.server.broadcast(
        "analysis_#{@analysis.id}",
        { status: 'completed', redirect_url: Rails.application.routes.url_helpers.analysis_path(@analysis) }
      )
      
    rescue StandardError => e
      @analysis.update!(
        status: :failed,
        error_message: e.message
      )
      
      AnalysisMailer.failed(@analysis).deliver_later
      raise e
    end
  end

  private

  def spawn_research_agents
    # Create report directory
    timestamp = Time.current.strftime("%Y%m%d-%H%M%S")
    report_dir = Rails.root.join("reports", "channel-analysis", timestamp)
    FileUtils.mkdir_p(report_dir)
    
    @analysis.update!(report_directory: report_dir.to_s)
    
    # Spawn 6 agents using PowerShell script
    # In production, this would call an API or use a task queue
    cmd = [
      "powershell.exe",
      "-File",
      Rails.root.join("scripts", "analyze-channel.ps1").to_s,
      "-ChannelId", @analysis.channel_id,
      "-ChannelName", "\"#{@analysis.channel_name || 'Target Channel'}\"",
      "-Niche", "\"#{@analysis.niche || 'General'}\""
    ].join(" ")
    
    system(cmd)
    
    # Wait a bit for agents to start
    sleep 2
    
    # Store agent statuses
    create_agent_records
    
    # Poll for completion (in production, use callbacks or webhooks)
    wait_for_agents_completion
  end

  def create_agent_records
    agent_types = [
      { name: "Channel Performance", type: "channel_performance", description: "Analyzing recent video performance" },
      { name: "Competitor Analysis", type: "competitor_analysis", description: "Researching top competitors" },
      { name: "Audience Research", type: "audience_research", description: "Understanding your audience" },
      { name: "Trend Analysis", type: "trend_analysis", description: "Identifying trending topics" },
      { name: "SEO & Algorithm", type: "seo_algorithm", description: "Optimizing for YouTube search" },
      { name: "Content Strategy", type: "content_strategy", description: "Creating 30-day plan" }
    ]
    
    agent_types.each do |agent_data|
      @analysis.agent_statuses.create!(
        name: agent_data[:name],
        agent_type: agent_data[:type],
        description: agent_data[:description],
        status: :running
      )
    end
  end

  def wait_for_agents_completion
    # Check for report files every 30 seconds (max 15 minutes)
    30.times do
      report_files = Dir.glob(File.join(@analysis.report_directory, "*.md"))
      
      # Update agent statuses based on file existence
      @analysis.agent_statuses.each do |agent_status|
        report_file = File.join(@analysis.report_directory, "#{agent_status.agent_type.gsub('_', '-')}.md")
        
        if File.exist?(report_file)
          agent_status.update!(status: :completed, completed_at: Time.current)
          
          # Import report content
          content = File.read(report_file)
          @analysis.reports.find_or_create_by!(report_type: agent_status.agent_type) do |report|
            report.content = content
            report.agent_id = agent_status.id
          end
          
          # Broadcast progress
          ActionCable.server.broadcast(
            "analysis_#{@analysis.id}",
            { 
              agent: agent_status.agent_type, 
              status: 'completed',
              progress: calculate_progress
            }
          )
        end
      end
      
      # Check if all agents completed
      if @analysis.agent_statuses.where(status: :completed).count == 6
        extract_quick_wins_and_calendar
        return
      end
      
      sleep 30
    end
    
    # Timeout after 15 minutes
    raise "Analysis timeout: Some agents did not complete in time"
  end

  def extract_quick_wins_and_calendar
    # Parse the content strategy report to extract structured data
    strategy_report = @analysis.reports.find_by(report_type: 'content_strategy')
    return unless strategy_report
    
    content = strategy_report.content
    
    # Extract quick wins (simple regex parsing)
    quick_wins_section = content[/## Quick Wins.*?(?=##|\z)/m]
    @analysis.update!(quick_wins: quick_wins_section) if quick_wins_section
    
    # Extract 30-day calendar
    calendar_section = content[/## 30-Day Content Calendar.*?(?=##|\z)/m]
    @analysis.update!(content_calendar: calendar_section) if calendar_section
  end

  def calculate_progress
    completed = @analysis.agent_statuses.where(status: :completed).count
    total = @analysis.agent_statuses.count
    (completed.to_f / total * 100).round
  end
end
