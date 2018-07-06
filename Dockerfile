FROM ruby:2.5.1


# see update.sh for why all "apt-get install"s have to stay as one long line
RUN apt-get update && apt-get install -y nodejs --no-install-recommends && rm -rf /var/lib/apt/lists/*

# see http://guides.rubyonrails.org/command_line.html#rails-dbconsole
RUN apt-get update && apt-get install -y sqlite3 --no-install-recommends && rm -rf /var/lib/apt/lists/*

# throw errors if Gemfile has been modified since Gemfile.lock
RUN bundle config --global frozen 1

WORKDIR /usr/src/app

COPY Gemfile Gemfile.lock ./
RUN bundle install --deployment

COPY . .

RUN bundle exec rake assets:clobber assets:precompile
ENV RAILS_ENV production
ENV RAILS_LOG_TO_STDOUT true
CMD ["bundle", "exec", "rails", "s", "-p", "3000", "-b", "0.0.0.0"]
