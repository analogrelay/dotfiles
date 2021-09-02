# For testing the dotfiles setup process
FROM debian:stretch

ENV DEBIAN_FRONTEND=noninteractive

# Install expected prereqs
RUN apt-get update && apt-get -qy install sudo

# Create a test user that can sudo without a password
RUN useradd -ms /bin/bash -G sudo testuser

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the test user
USER testuser

# Copy in the dotfiles
COPY . /dotfiles

# Run the setup script
RUN /dotfiles/script/setup