FROM ruby:2.5.0
RUN curl -o- -L https://yarnpkg.com/install.sh | bash
RUN apt-get update -qq && apt-get install -y nodejs postgresql-client curl bash yarn
RUN mkdir /myapp
WORKDIR /myapp
COPY Gemfile* /myapp
RUN bundle install
COPY package.json yarn.lock /myapp
RUN yarn install --check-files
COPY . /myapp

# Add a script to be executed every time the container starts.
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
