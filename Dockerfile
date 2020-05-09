# Pre setup stuff
FROM ruby:2.5.8 as builder

# Add Yarn to the repository
RUN curl https://deb.nodesource.com/setup_12.x | bash \
    && curl https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install system dependencies & clean them up
RUN apt-get update -qq && apt-get install -y \
  postgresql-client build-essential yarn nodejs \
  && rm -rf /var/lib/apt/lists/*


# This is where we build the rails app
FROM builder as rails-app

# This is to fix an issue on Linux with permissions issues
ARG USER_ID=1000
ARG GROUP_ID=1000

# Create a non-root user
RUN groupadd --gid $GROUP_ID user
RUN useradd --no-log-init --uid $USER_ID --gid $GROUP_ID user --create-home

# Remove existing running server
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh

RUN mkdir /myapp
WORKDIR /myapp

# Install rails related dependencies
COPY Gemfile* /myapp/
RUN bundle install
COPY package.json /myapp/
COPY yarn.lock /myapp/
RUN yarn install --check-files

# Copy over all files
COPY . .

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

# Allow access to port 3000
EXPOSE 3000

RUN mkdir /myapp/tmp
RUN chown --changes --silent --no-dereference --recursive \
    --from=0:0 ${USER_ID}:${GROUP_ID} /myapp

# Define the user running the container
USER user

# Start the main process.
CMD ["rails", "server", "-b", "0.0.0.0"]
