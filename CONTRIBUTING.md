# Contributing to RailsAuthSaaS

First off, thank you for considering contributing to RailsAuthSaaS! 🎉

## Code of Conduct

Be respectful, inclusive, and professional. We're all here to build great software.

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check existing issues. When you create a bug report, include:

- **Clear title and description**
- **Steps to reproduce**
- **Expected vs actual behavior**
- **Rails/Ruby version**
- **Code samples** (if applicable)

### Suggesting Features

Feature suggestions are welcome! Please:

- **Check if it already exists** in issues/discussions
- **Explain the use case** (why is this needed?)
- **Describe the solution** (how should it work?)
- **Consider alternatives** (what other approaches exist?)

### Pull Requests

1. **Fork the repo** and create your branch from `main`
2. **Add tests** for any new code
3. **Ensure tests pass** (`rails test`)
4. **Follow Ruby style guide** (RuboCop)
5. **Update documentation** (README, docs/)
6. **Write clear commit messages**

#### Example PR Process

```bash
# Fork and clone
git clone https://github.com/YOUR-USERNAME/rails-auth-saas.git
cd rails-auth-saas

# Create branch
git checkout -b feature/my-awesome-feature

# Make changes, add tests
# ...

# Run tests
rails test

# Commit with clear message
git commit -m "Add awesome feature for X"

# Push and create PR
git push origin feature/my-awesome-feature
```

### Code Style

We follow standard Ruby/Rails conventions:

```ruby
# Good
def authenticate_user
  return unless session[:user_id]
  @current_user ||= User.find_by(id: session[:user_id])
end

# Bad
def authenticate_user
  if session[:user_id]
    @current_user ||= User.find_by(id: session[:user_id])
  end
end
```

### Testing

All new features must include tests:

```ruby
# test/models/user_test.rb
test "should enable two factor authentication" do
  user = users(:one)
  result = user.enable_two_factor!
  
  assert user.otp_required_for_login?
  assert_not_nil result[:secret]
  assert_equal 10, result[:backup_codes].length
end
```

### Documentation

Update docs when adding features:

- **README.md** - Main features, quick start
- **docs/** - Detailed guides
- **Code comments** - For complex logic only

## Development Setup

```bash
# Clone repo
git clone https://github.com/yourusername/rails-auth-saas.git
cd rails-auth-saas

# Install dependencies
bundle install

# Setup database
rails db:setup

# Run tests
rails test

# Start server
rails server
```

## Project Structure

```
rails-auth-saas/
├── app/
│   ├── controllers/     # Authentication controllers
│   ├── models/          # User, OAuth, SAML models
│   ├── views/           # Login, signup forms
│   └── jobs/            # Background jobs
├── db/migrate/          # Database migrations
├── docs/                # Documentation
├── test/                # Test suite
└── README.md
```

## Questions?

- Open a [Discussion](https://github.com/yourusername/rails-auth-saas/discussions)
- Email: hello@railsauthsaas.com
- Twitter: [@railsauthsaas](https://twitter.com/railsauthsaas)

---

**Thank you for contributing!** 🚀
