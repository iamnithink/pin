# Production Dockerfile
# Used for Railway deployment
FROM ruby:3.3.0

# Install dependencies
RUN apt-get update -qq && \
    apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler -v 2.5.0

# Copy Gemfile and install ONLY production gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copy application code
COPY . .

# Precompile assets for production
RUN RAILS_ENV=production SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# Expose port (Railway sets PORT env var)
EXPOSE 3000

# Start server (Railway sets PORT env var)
CMD ["sh", "-c", "bundle exec rails server -b 0.0.0.0 -p ${PORT:-3000}"]
