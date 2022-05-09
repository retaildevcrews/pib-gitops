# this image is built and updated weekly
# https://github.com/cse-labs/codespaces-images

FROM ghcr.io/cse-labs/dind:latest

# some images require specific values
ARG USERNAME=vscode

# log docker build start
RUN echo "$(date +'%Y-%m-%d %H:%M:%S')    docker build start" >> "/home/${USERNAME}/status"

# change ownership
RUN chown -R ${USERNAME}:${USERNAME} "/home/${USERNAME}"

# log completion - make sure this is last
RUN echo "$(date +'%Y-%m-%d %H:%M:%S')    docker build complete" >> "/home/${USERNAME}/status"
