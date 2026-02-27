class AnalysesController < ApplicationController
  before_action :authenticate_user!
  before_action :check_analysis_limit, only: [:create]

  def index
    @analyses = current_user.analyses.order(created_at: :desc)
  end

  def new
    @analysis = Analysis.new
  end

  def create
    channel_id = extract_channel_id(params[:analysis][:channel_url])
    
    if channel_id.nil?
      flash[:error] = "Invalid YouTube channel URL. Please check and try again."
      redirect_to new_analysis_path and return
    end

    @analysis = current_user.analyses.create!(
      channel_id: channel_id,
      channel_url: params[:analysis][:channel_url],
      status: :pending
    )

    ChannelAnalysisJob.perform_later(@analysis.id)
    
    redirect_to analysis_path(@analysis), notice: "Analysis started! This will take 5-10 minutes."
  end

  def show
    @analysis = current_user.analyses.find(params[:id])
    
    if @analysis.completed?
      @reports = @analysis.reports.order(:report_type)
      @quick_wins = @analysis.quick_wins
      @content_calendar = @analysis.content_calendar
    end
  end

  def destroy
    @analysis = current_user.analyses.find(params[:id])
    @analysis.destroy
    redirect_to analyses_path, notice: "Analysis deleted."
  end

  private

  def extract_channel_id(url)
    return nil if url.blank?
    
    # Match patterns:
    # https://www.youtube.com/channel/UCtCstrcdhS5LkYw7g2n2a7w
    # https://www.youtube.com/@ChannelHandle
    # https://youtube.com/c/ChannelName
    
    if url.match(/youtube\.com\/channel\/([A-Za-z0-9_-]+)/)
      $1
    elsif url.match(/youtube\.com\/@([A-Za-z0-9_-]+)/)
      # For @handles, we'd need to resolve to channel ID
      # For now, store the handle and resolve in the job
      "@#{$1}"
    elsif url.match(/youtube\.com\/c\/([A-Za-z0-9_-]+)/)
      "c/#{$1}"
    elsif url.match(/^UC[A-Za-z0-9_-]{22}$/)
      # Direct channel ID
      url
    else
      nil
    end
  end

  def check_analysis_limit
    return if current_user.pro_tier? || current_user.agency_tier?
    
    analyses_this_month = current_user.analyses
      .where('created_at >= ?', Time.current.beginning_of_month)
      .count
    
    if analyses_this_month >= 1
      flash[:error] = "Free tier allows 1 analysis per month. Upgrade to Pro for unlimited analyses!"
      redirect_to pricing_path
    end
  end
end
