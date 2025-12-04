# syntax=docker/dockerfile:1


## These params are important. The IDs must match the host IDs to avoid permission issues.
## They can be overridden at build time using --build-arg.
## This is needed to run the container in rootless mode with a user matching the host user.
ARG GROUP_ID=1000
ARG GROUP=rails
ARG RAILS_ENV=development
ARG USER_ID=1000
ARG USER=rails

# Build the image step by step to optimize build time and cache usage.
# This part buils the base image with all *system* dependencies.
FROM ruby:3.4 AS ballast-lane-system
ARG RAILS_ENV
ENV RAILS_ENV=$RAILS_ENV
WORKDIR /tmp
COPY scripts/system.zsh .
RUN apt-get update && apt-get install --no-install-recommends --auto-remove -y coreutils zsh
RUN zsh -cel ./system.zsh

# Build the required Ruby and NodeJS dependencies.
FROM ballast-lane-system AS ballast-lane-node
WORKDIR /tmp
COPY scripts/node.zsh .
RUN zsh -cel ./node.zsh

FROM ballast-lane-node AS ballast-lane-ruby
WORKDIR /tmp
COPY scripts/ruby.zsh .
RUN zsh -cel ./ruby.zsh

# Build the new rootless user (with core configuration and dependencies)
FROM ballast-lane-ruby AS ballast-lane-user
ARG GROUP
ARG GROUP_ID
ARG USER
ARG USER_ID
ENV GROUP=$GROUP
ENV USER=$USER
WORKDIR /tmp
ADD https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh ./ohmyzsh.sh
COPY scripts/prepare-user.zsh .
RUN zsh -cel ./prepare-user.zsh

# Install gems and node modules
FROM ballast-lane-user AS ballast-lane-dependencies
RUN mkdir -p /project && chown -R $USER:$GROUP /project
USER $USER:$GROUP
WORKDIR /project
COPY --chown=$USER:$GROUP scripts/entrypoint.rb scripts/setup-project.zsh scripts/
COPY --chown=$USER:$GROUP Gemfile* package.json pnpm-lock.yaml ./
RUN zsh -cel scripts/setup-project.zsh
USER root:root
WORKDIR /tmp
COPY scripts/system-cleanup.zsh .
RUN zsh -cel ./system-cleanup.zsh

FROM ballast-lane-dependencies AS ballast-lane-project
USER $USER:$GROUP
WORKDIR /project
COPY --chown=$USER:$GROUP .git .git
RUN git reset --hard

FROM ballast-lane-project AS ballast-lane
USER $USER:$GROUP
WORKDIR /project
ENTRYPOINT ["scripts/entrypoint.rb"]
