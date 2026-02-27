# Deployment Guide

This guide shows you how to deploy RailsAuthSaaS to production in under 10 minutes.

---

## 🚀 Quick Deploy Options

### Option 1: Railway (Easiest, $5/month)

**Setup time:** 5 minutes

1. **Install Railway CLI:**
```bash
npm i -g @railway/cli
# or download from https://railway.app/cli
```

2. **Login and deploy:**
```bash
railway login
railway init
railway up
```

3. **Set environment variables in Railway dashboard:**
```bash
RAILS_MASTER_KEY=your_master_key_here
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_client_secret
```

4. **Add PostgreSQL:**
```bash
railway add --database postgresql
```

Railway automatically detects Rails apps and runs migrations.

**Done!** Your app is live at `https://your-app.railway.app`

---

### Option 2: Render (Free tier available)

**Setup time:** 10 minutes

1. **Create `render.yaml` in your project root:**
```yaml
services:
  - type: web
    name: rails-auth-saas
    env: ruby
    buildCommand: bundle install; bundle exec rake assets:precompile; bundle exec rake db:migrate
    startCommand: bundle exec puma -C config/puma.rb
    envVars:
      - key: RAILS_MASTER_KEY
        sync: false
      - key: DATABASE_URL
        fromDatabase:
          name: rails-auth-db
          property: connectionString

databases:
  - name: rails-auth-db
    databaseName: railsauthsaas
    user: railsauthsaas
```

2. **Push to GitHub and connect Render:**
   - Go to https://dashboard.render.com
   - Click "New +" → "Blueprint"
   - Connect your GitHub repo
   - Render will deploy automatically

3. **Set environment variables in Render dashboard**

**Done!** Your app is live at `https://your-app.onrender.com`

---

### Option 3: Docker + Any Host (Most Flexible)

**Setup time:** 15 minutes

1. **Create `Dockerfile`:**
```dockerfile
FROM ruby:3.3.10-slim

RUN apt-get update -qq && apt-get install -y \
  build-essential \
  libpq-dev \
  nodejs \
  npm \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Gemfile* ./
RUN bundle install

COPY . .

RUN bundle exec rake assets:precompile

EXPOSE 3000

CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
```

2. **Create `docker-compose.yml`:**
```yaml
version: '3.8'

services:
  db:
    image: postgres:16
    environment:
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  web:
    build: .
    command: bash -c "bundle exec rake db:create db:migrate && bundle exec puma -C config/puma.rb"
    volumes:
      - .:/app
    ports:
      - "3000:3000"
    depends_on:
      - db
    environment:
      DATABASE_URL: postgres://postgres:password@db:5432/rails_auth_production
      RAILS_MASTER_KEY: ${RAILS_MASTER_KEY}

volumes:
  postgres_data:
```

3. **Deploy to any Docker host:**
```bash
docker-compose up -d
```

Deploy to: **DigitalOcean ($4/month)**, **Fly.io**, **AWS ECS**, **Heroku**, etc.

---

## 🔐 Security Checklist Before Production

- [ ] Set `RAILS_ENV=production`
- [ ] Use PostgreSQL (not SQLite)
- [ ] Set strong `RAILS_MASTER_KEY`
- [ ] Enable SSL/HTTPS (required for OAuth and cookies)
- [ ] Set `config.force_ssl = true` in production.rb
- [ ] Configure proper SMTP settings for emails
- [ ] Set up error monitoring (Sentry, Rollbar, Honeybadger)
- [ ] Configure backups
- [ ] Review `config/credentials.yml.enc`

---

## 📧 Email Configuration

For production emails (password resets, magic links, 2FA), configure SMTP:

```ruby
# config/environments/production.rb
config.action_mailer.delivery_method = :smtp
config.action_mailer.smtp_settings = {
  address: ENV['SMTP_ADDRESS'],
  port: 587,
  user_name: ENV['SMTP_USERNAME'],
  password: ENV['SMTP_PASSWORD'],
  authentication: 'plain',
  enable_starttls_auto: true
}
config.action_mailer.default_url_options = { 
  host: 'your-domain.com',
  protocol: 'https'
}
```

**Recommended services:**
- **SendGrid** (100 emails/day free)
- **Mailgun** (5K emails/month free)  
- **AWS SES** (very cheap, $0.10 per 1K emails)

---

## 🗄️ Database Migration from SQLite to PostgreSQL

If you need to switch from SQLite (development) to PostgreSQL (production):

1. **Update `Gemfile`:**
```ruby
# Replace
gem "sqlite3"
# With
gem "pg"
```

2. **Update `config/database.yml`:**
```yaml
production:
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  database: <%= ENV['DATABASE_URL'] %>
```

3. **Run migrations:**
```bash
RAILS_ENV=production rails db:create db:migrate
```

---

## 🔧 Environment Variables Reference

Required for production:

```bash
# Rails
RAILS_MASTER_KEY=your_64_char_hex_string
RAILS_ENV=production
DATABASE_URL=postgresql://user:pass@host:5432/dbname

# Email
MAILER_FROM=noreply@yourdomain.com
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key

# OAuth (optional)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_secret

# Active Record Encryption (generate with: rails db:encryption:init)
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=your_key
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=your_key
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=your_salt
```

---

## 🎯 Post-Deployment Testing

After deploying, test these critical flows:

1. ✅ Signup: Create new account
2. ✅ Login: Sign in with email/password
3. ✅ Password Reset: Request password reset email
4. ✅ 2FA Setup: Enable two-factor authentication
5. ✅ OAuth: Login with Google/GitHub (if configured)
6. ✅ Dashboard: Access protected pages
7. ✅ Logout: Sign out and verify session cleared

---

## 🆘 Common Issues

### "No route matches"
- Run `rails routes` to see all available routes
- Check `config/routes.rb` is loaded correctly

### "PG::ConnectionBad"
- Verify `DATABASE_URL` is set correctly
- Check database host is accessible

### "OAuth redirect_uri mismatch"
- Update OAuth app settings with your production domain
- Google: `https://yourdomain.com/auth/google_oauth2/callback`
- GitHub: `https://yourdomain.com/auth/github/callback`

### "ActiveRecord::Encryption" errors
- Ensure all three encryption keys are set in environment variables
- Run `rails db:encryption:init` to generate new keys

---

## 📊 Monitoring

Recommended tools:
- **Uptime**: UptimeRobot (free)
- **Errors**: Sentry (free tier)
- **Performance**: Scout APM, New Relic, or Skylight
- **Logs**: Railway/Render built-in, or Papertrail

---

## 🔄 Continuous Deployment

**Railway/Render:** Auto-deploys on every git push to main branch

**Custom CD with GitHub Actions:**
```yaml
# .github/workflows/deploy.yml
name: Deploy
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Deploy to Railway
        run: |
          npm i -g @railway/cli
          railway up
        env:
          RAILWAY_TOKEN: ${{ secrets.RAILWAY_TOKEN }}
```

---

## 💾 Backups

**Automated backups:**
- Railway: Built-in daily backups
- Render: Built-in backups on paid plans
- Manual: Use `pg_dump` with cron job

```bash
# Backup script
pg_dump $DATABASE_URL > backup-$(date +%Y%m%d).sql
```

---

**Need help?** Check the main [README.md](README.md) for additional configuration details.
