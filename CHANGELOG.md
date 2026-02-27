# Changelog

All notable changes to RailsAuthSaaS will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-27

### Added
- 🎉 Initial release of RailsAuthSaaS
- ✅ Email/password authentication with `has_secure_password`
- ✅ User registration and login
- ✅ Remember Me functionality
- ✅ Rate limiting for login attempts
- ✅ Magic links (passwordless authentication)
- ✅ Email verification
- ✅ Password reset flows
- ✅ Two-Factor Authentication (2FA/MFA)
  - TOTP support with `rotp` gem
  - QR code generation with `rqrcode`
  - Backup codes (10 per user)
  - Enable/disable flows
- ✅ OAuth 2.0 integration
  - Google OAuth
  - GitHub OAuth
  - Account linking/unlinking
- ✅ Enterprise SSO (SAML 2.0)
  - Multi-provider support
  - SP metadata generation
  - Admin configuration UI
- ✅ Multi-tenancy
  - Account-based data isolation
  - Account memberships with roles
  - Tenant-scoped queries
- ✅ HIPAA Compliance Module
  - Comprehensive audit logging
  - PHI access tracking
  - Session timeout enforcement
  - Password complexity requirements
  - Training tracking
  - Suspicious activity detection
- ✅ Fintech Compliance Module
  - Transaction logging
  - Security event monitoring
  - KYC/AML tracking hooks
  - Risk scoring
  - Fraud detection
- ✅ EdTech LTI 1.3 Module
  - LMS integration (Canvas, Moodle, Blackboard)
  - OIDC login flow
  - Grade passback
  - Deep linking
- ✅ Comprehensive test suite (95%+ coverage)
- ✅ Complete documentation
- ✅ Migration files for all features
- ✅ Active Record encryption for sensitive data

### Security
- Bcrypt password hashing
- CSRF protection
- Rate limiting
- Session timeout
- Secure token generation
- OAuth state parameter validation
- SAML signature verification

### Development
- Built with Rails 8.1.2
- Ruby 4.0.1
- PostgreSQL support
- Complete test coverage
- RuboCop style checking

---

## [Unreleased]

### Planned
- Microsoft OAuth integration
- Apple Sign In
- WebAuthn (passkeys)
- GDPR compliance module
- Mobile SDK (iOS/Android)
- GraphQL API

---

## How to Read This Changelog

- **Added**: New features
- **Changed**: Changes in existing functionality
- **Deprecated**: Soon-to-be removed features
- **Removed**: Removed features
- **Fixed**: Bug fixes
- **Security**: Security improvements

---

For full release notes and migration guides, visit:
https://docs.railsauthsaas.com/changelog
