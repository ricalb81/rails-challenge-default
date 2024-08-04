FROM ruby:3.0.6

# Add Debian security repository
RUN echo "deb http://security.debian.org/debian-security bullseye-security main contrib non-free" > /etc/apt/sources.list

# Add Debian stretch repository
RUN echo "deb http://archive.debian.org/debian/ stretch main" > /etc/apt/sources.list \
    && echo "Acquire::Check-Valid-Until false;" > /etc/apt/apt.conf.d/99no-check-valid-until

# Install dependencies

RUN apt-get update -qq
RUN apt-get install -y build-essential libpq-dev nodejs
RUN apt-get clean all
RUN rm -rf /var/lib/apt/lists/*


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV RAILS_LOG_TO_STDOUT=true

RUN mkdir /app

# Copy these over first so that we can rely on Docker to intelligently run or not run bundle install based
# on whether these files have changed or not.
COPY Gemfile Gemfile.lock /app/
WORKDIR /app
RUN bundle install

# Copy over the rest of the app's files
COPY . /app

CMD ["bundle", "exec", "rails", "s", "-p", "3005", "-b", "0.0.0.0"]
