# PIN (PlayInNear) - Location-Based Sports Discovery Platform

PIN is a location-based sports discovery platform that helps users find and create nearby sports tournaments.

## Features

- Discover sports tournaments (Cricket, Volleyball, Football, Badminton, etc.)
- Filter by sport, location, and date
- Tournament themes with prizes, rules, and contact information
- Admin panel for tournament management
- Responsive design for mobile and desktop

## Tech Stack

- Ruby 3.3.0
- Rails 7.2.0
- PostgreSQL 16
- Redis 7
- ActiveAdmin
- Docker & Railway

## Local Development

### Prerequisites

- Docker and Docker Compose

### Quick Start

```bash
# 2. Install dependencies
bundle install

# 3. Start services
docker-compose up -d

# 4. Setup database
docker-compose exec web rails db:create db:migrate db:seed

# Access application
# Web: http://localhost:3000
# Admin: http://localhost:3000/admin (admin@playinnear.com / admin123456)
```

### Common Commands

```bash
# View logs
docker-compose logs -f

# Rails console
docker-compose exec web rails console

# Run migrations
docker-compose exec web rails db:migrate

# Stop services
docker-compose down
```

## License

Proprietary and confidential.
