## Description

Spec-atelier is the plattform to develop your arquictertural docs for construction projects. Its backend is an API-mode, JSON-only Rails app;
its frontend is a React app built and powered by Node.

## Install

Version Requirements:

- **Ruby 2.6.5**
- **Node 12.14.x** [(LTS)](https://github.com/nodejs/Release#release-schedule1)
- **PostgreSQL 9.4** (via Homebrew: `postgresql@9.4`)

Assumptions:

- [rbenv] for Ruby version management
- [nvm] for Node version management
- [Homebrew] for other macOS packages

### Installation

Follow these instructions for your platform:
```bash
mkdir spec-atelier && cd spec-atelier
mkdir back && cd back
git clone git@github.com:Sophia-Sergio/spec-atelier.git .
bundle install
cd .. && mkdir front
cd front
git clone git@github.com:Proskynete/specatelier-frontend.git .

```

### Create and populate databases

Once you have completed the installation instructions above, follow these steps to create and
populate your database.

```bash
cd back
rails db:create db:migrate
rails db:seed
bundle exec rake db:load_excel:tables
```

### Start server for back and front

```bash
foreman start -f Procfile.dev
```

### Testing locally:

```bash
# Back-end Rails tests
$ bundle exec rspec   # add "--format documentation" for verbose reporting
                      # of successful tests
```
