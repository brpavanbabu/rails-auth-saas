# RailsAuthSaaS

> **Production-ready Rails authentication template** with compliance modules for healthcare, fintech, and education.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Rails Version](https://img.shields.io/badge/Rails-8.1%2B-red.svg)](https://rubyonrails.org/)
[![Ruby Version](https://img.shields.io/badge/Ruby-3.3%2B-red.svg)](https://www.ruby-lang.org/)

**Skip 2-4 weeks of authentication development.** Drop-in Rails template with OAuth, 2FA, SAML, multi-tenancy, and compliance modules for HIPAA, Fintech, and EdTech.

---

## 🎯 Who This is For

### ✅ Perfect for:
- Healthcare SaaS builders (telehealth, patient portals, EHR systems)
- Fintech developers (payment platforms, banking apps, crypto)
- EdTech platforms (LMS integrations with Canvas, Moodle, Blackboard)
- B2B SaaS products (team collaboration, project management)
- Enterprise apps (SSO, multi-tenancy, audit logs)

### ❌ Not for:
- Simple blogs or personal projects (use Devise—it's free)
- Apps that don't need compliance features
- Non-Rails frameworks

---

## 🚀 What's Included

### Core Authentication
- ✅ Email/Password (bcrypt hashing)
- ✅ Remember Me (secure tokens)
- ✅ Password reset flows
- ✅ Magic links (passwordless)
- ✅ Rate limiting
- ✅ Session management

### Advanced Features
- ✅ **Two-Factor Authentication (2FA/MFA)**: TOTP with QR codes, backup codes
- ✅ **OAuth 2.0**: Google, GitHub (Microsoft ready)
- ✅ **Enterprise SSO**: SAML 2.0 (Okta, Azure AD, OneLogin)
- ✅ **Multi-Tenancy**: Account-based isolation, roles, team management

### Compliance Modules (Technical Infrastructure)

#### 🏥 HIPAA Module
- Audit logs (every user action)
- PHI access tracking
- Session timeout enforcement
- Suspicious activity detection
- **Use case**: Telehealth, patient portals, health tech SaaS

#### 💰 Fintech Module  
- Transaction logs (immutable)
- Security event monitoring
- Access control logs
- Basic fraud detection patterns
- **Use case**: Payment processors, banking apps, investment platforms

#### 🎓 EdTech LTI 1.3 Module
- Canvas/Moodle/Blackboard integration
- OIDC login flow
- Grade passback (AGS)
- Deep linking support
- **Use case**: Online courses, educational SaaS, learning analytics

⚠️ **Important**: Compliance modules provide technical infrastructure only. They do NOT guarantee regulatory compliance. Consult qualified legal and compliance professionals.

### Professional UI
- Modern CSS design system (200+ lines)
- Responsive layout (mobile-friendly)
- Styled forms, buttons, cards
- Professional navigation bar
- OAuth button styling

---

## ⚡ Quick Start

```bash
# Clone and install
git clone https://github.com/yourusername/rails-auth-saas.git
cd rails-auth-saas
bundle install

# Setup database
rails db:create db:migrate

# Generate encryption keys
rails db:encryption:init
# Copy output to .env file

# Start server
rails server
```

Visit `http://localhost:3000` - fully functional authentication system running.

**See [DEPLOYMENT.md](DEPLOYMENT.md)** for production deployment (Railway, Render, Docker).

---

## 📋 What You Need to Add

This template provides **authentication infrastructure**. You still build your core product:

- Your business logic (what your app actually does)
- Subscription billing (if SaaS)
- Admin dashboard (if needed)
- Landing page (marketing site)
- Your domain-specific features

**Think of this as**: A solid foundation so you can focus on building your unique product instead of reinventing authentication.

---

## 📦 What's Included

### Core Authentication
- User registration with email verification
- Secure login/logout with `has_secure_password`
- Remember Me functionality
- Rate limiting (prevent brute force attacks)
- Password reset flows
- Magic links (passwordless authentication)

### Advanced Security
- **Two-Factor Authentication (2FA/MFA)**
  - TOTP (Time-based One-Time Passwords)
  - Backup codes
  - QR code generation
- **OAuth 2.0 Integration**
  - Google OAuth
  - GitHub OAuth
  - Microsoft OAuth (coming soon)
  - Account linking/unlinking
- **Enterprise SSO (SAML 2.0)**
  - Multi-provider support
  - Automatic metadata generation
  - Admin configuration UI

### Multi-Tenancy
- Account-based data isolation
- Role-based access control (RBAC)
- Team/organization management
- Perfect for B2B SaaS

### Compliance Modules

⚠️ **DISCLAIMER**: These modules provide technical infrastructure only. They do NOT guarantee compliance with HIPAA, PCI DSS, SOC2, or any other regulations. You MUST consult qualified legal and compliance professionals.

#### 🏥 HIPAA Compliance Module
Technical features for healthcare applications (audit logging, session management):
- Comprehensive audit logging
- PHI access tracking
- Session timeout enforcement
- Password complexity helpers
- Suspicious activity detection

**Use case:** Healthcare apps that need audit trail infrastructure as a starting point.

**NOT included:** Legal compliance certification, BAA signing, security audits, breach notification procedures.

#### 💰 Fintech Compliance Module
Technical features for financial applications (transaction logging, monitoring):
- Immutable transaction logging
- Security event monitoring
- Access control logs
- Basic fraud detection patterns

**Use case:** Financial apps that need logging infrastructure as a starting point.

**NOT included:** PCI DSS certification, SOC2 reports, actual fraud detection, regulatory filing.

#### 🎓 EdTech LTI 1.3 Module
LMS integration for educational applications:
- Canvas/Moodle/Blackboard integration
- OIDC login flow
- Deep linking support
- Grade passback (basic implementation)
- Launch validation

**Use case:** Educational apps integrating with Learning Management Systems.

**NOT included:** FERPA legal compliance, production-grade grade sync, LMS vendor support.

---

## ⚡ Quick Start (5 Minutes)

### Prerequisites
```bash
ruby -v   # 3.2.0 or higher
rails -v  # 8.0.0 or higher
```

### Installation

```bash
# Clone the repository
git clone https://github.com/brpavanbabu/rails-auth-saas.git
cd rails-auth-saas

# Install dependencies
bundle install

# Generate new Rails credentials (IMPORTANT - master.key not included for security)
EDITOR="code --wait" rails credentials:edit
# Or use nano: EDITOR=nano rails credentials:edit

# Setup database
rails db:create db:migrate

# Start server
rails server
```

Visit `http://localhost:3000` - you'll see the login page with professional styling.

**To integrate into your existing Rails app:**
1. Copy the relevant controllers, models, and views to your app
2. Run the migrations from `db/migrate/`
3. Add required gems to your `Gemfile`
4. Configure OAuth/SAML providers as needed

### 🎉 Done!

Visit `http://localhost:3000` and you'll have:
- `/signup` - User registration with styled forms
- `/login` - User login with OAuth buttons
- `/dashboard` - Protected user dashboard
- `/auth/google_oauth2` - Google OAuth (after configuring client ID/secret)
- `/auth/github` - GitHub OAuth (after configuring client ID/secret)
- `/two_factor/setup` - 2FA setup with QR code

**Note:** OAuth providers require configuration (see Configuration section below).

---

## 🔧 Configuration

### 1. Environment Variables

Create a `.env` file in the root directory:

```bash
# Required for Active Record Encryption
ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY=generate_with_rails_secret
ACTIVE_RECORD_ENCRYPTION_DETERMINISTIC_KEY=generate_with_rails_secret  
ACTIVE_RECORD_ENCRYPTION_KEY_DERIVATION_SALT=generate_with_rails_secret

# Email
MAILER_FROM=noreply@yourdomain.com
SMTP_ADDRESS=smtp.sendgrid.net
SMTP_USERNAME=apikey
SMTP_PASSWORD=your_sendgrid_api_key

# OAuth (optional - leave blank to disable)
GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_secret
GITHUB_CLIENT_ID=your_github_client_id
GITHUB_CLIENT_SECRET=your_github_secret
```

**Generate encryption keys:**
```bash
rails db:encryption:init
# Copy the output to your .env file
```

### 2. OAuth Providers (Optional)

OAuth is already configured in `config/initializers/omniauth.rb`. Just set the environment variables above.

**Get OAuth credentials:**
- **Google**: [Google Cloud Console](https://console.cloud.google.com/apis/credentials)
- **GitHub**: [GitHub OAuth Apps](https://github.com/settings/developers)

### 3. Email Configuration

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
```

### 3. Email Configuration

Email configuration is already set in `config/environments/production.rb`. Just set the SMTP environment variables shown in step 1.

**Recommended Email Services:**
- SendGrid (free tier: 100 emails/day)
- Mailgun (free tier: 5K emails/month)
- AWS SES (very cheap)

### 4. Enable Compliance Modules

#### HIPAA Compliance
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include HipaaCompliance
  
  # Automatically logs all actions and enforces session timeout
end
```

#### Fintech Compliance
```ruby
class ApplicationController < ActionController::Base
  include FintechCompliance
  
  # Automatically logs transactions and security events
end
```

---

## 📚 Documentation

### User Model

The `User` model includes all authentication methods:

```ruby
# Create user
user = User.create!(
  email: 'user@example.com',
  password: 'SecurePass123!',
  password_confirmation: 'SecurePass123!'
)

# Enable 2FA
user.enable_two_factor!
# => Returns { secret: "...", backup_codes: [...], provisioning_uri: "..." }

# Verify OTP
user.verify_otp('123456')
# => true/false

# OAuth account linking
OauthAccount.create!(
  user: user,
  provider: 'google',
  uid: 'google_user_id',
  email: 'user@gmail.com'
)

# Multi-tenancy
account = Account.create!(name: 'Acme Corp')
account.memberships.create!(user: user, role: 'owner')
```

### Controllers

```ruby
# Require authentication
class DashboardController < ApplicationController
  before_action :authenticate_user!
  
  def index
    @user = current_user
    @account = current_account
  end
end

# Require 2FA
class AdminController < ApplicationController
  before_action :require_two_factor!
end

# Tenant-scoped queries
class ProjectsController < ApplicationController
  def index
    @projects = current_account.projects
  end
end
```

### Routes

All routes are automatically configured:

```ruby
# Authentication
GET  /signup              # Registration form
POST /signup              # Create account
GET  /login               # Login form
POST /login               # Authenticate
DELETE /logout            # Sign out

# OAuth
GET  /auth/:provider      # Initiate OAuth
GET  /auth/:provider/callback  # OAuth callback

# Two-Factor
GET  /two_factor/setup    # Setup 2FA
POST /two_factor/enable   # Enable 2FA
POST /two_factor/verify   # Verify OTP
DELETE /two_factor        # Disable 2FA

# Enterprise SSO
GET  /auth/saml/login     # SAML login
POST /auth/saml/callback  # SAML callback
GET  /auth/saml/metadata  # SP metadata

# LTI 1.3 (EdTech)
GET  /lti/login           # LTI login
POST /lti/launch          # LTI launch
GET  /lti/jwks            # Public keys
```

---

## 🧪 Testing

Tests are included but coverage is not comprehensive:

```bash
# Run all tests
rails test

# Run specific test suites
rails test test/models/user_test.rb
rails test test/controllers/sessions_controller_test.rb
```

**Note:** This is a starter project. You should add comprehensive tests for your specific use case.

---

## 🔒 Security

### Built-in Security Features
- ✅ Password hashing with bcrypt
- ✅ CSRF protection
- ✅ SQL injection prevention (via Rails)
- ✅ XSS protection (via Rails)
- ✅ Rate limiting (basic implementation)
- ✅ Session timeout
- ✅ 2FA with TOTP
- ✅ OAuth state parameter validation
- ✅ SAML signature verification

### Security Warnings
⚠️ **Before deploying to production:**
- Conduct a professional security audit
- Enable HTTPS/TLS everywhere
- Configure secure session cookies
- Set up monitoring and alerting
- Implement proper rate limiting (consider Rack::Attack)
- Review all dependencies for vulnerabilities
- Configure proper CORS policies

**This code has NOT been professionally audited.** Use at your own risk.

---

## 🤝 Contributing

This is a community project. Contributions welcome via pull requests.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## 📝 License

MIT License - Free to use, modify, and distribute in unlimited projects.

See [LICENSE.md](LICENSE.md) for full details and important disclaimers.

---

## 📞 Resources

- **Full Feature List**: [WHAT-YOU-GET.md](WHAT-YOU-GET.md)
- **Deployment Guide**: [DEPLOYMENT.md](DEPLOYMENT.md)
- **GitHub**: [github.com/brpavanbabu/rails-auth-saas](https://github.com/brpavanbabu/rails-auth-saas)
- **Issues**: [Report bugs](https://github.com/brpavanbabu/rails-auth-saas/issues)

---

**Save 2-4 weeks of authentication development. Focus on building your unique product.**
