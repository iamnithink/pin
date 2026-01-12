#!/bin/bash
set -e

# Install missing gems if Gemfile was changed
bundle check || bundle install

# Remove a potentially pre-existing server.pid for Rails
rm -f tmp/pids/server.pid

# Execute the main container command
exec "$@"
