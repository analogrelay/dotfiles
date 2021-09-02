# For testing the dotfiles setup process
FROM debian

ENV DEBIAN_FRONTEND=noninteractive
ENV CONTAINER=1

# Install expected prereqs, and ansible since it takes a while and we'd rather cache it.
RUN apt-get update && apt-get -qy install sudo ansible

# Create a test user that can sudo without a password
RUN useradd -ms /bin/bash -G sudo testuser

RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Switch to the test user
USER testuser

# Copy in the dotfiles
COPY . /dotfiles

# Run the setup script
RUN /dotfiles/script/setup