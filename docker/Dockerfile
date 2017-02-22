FROM gcr.io/stacksmith-images/minideb-buildpack:jessie-r10

MAINTAINER Angel <angel@laux.com>

# Install packages
RUN echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list && apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates-java/jessie-backports openjdk-8-jdk-headless openjdk-8-jdk ruby build-essential unzip wget vim

# Download started packages
RUN cd ~ && wget https://halite.io/downloads/starterpackages/Halite-Java-Starter-Package.zip && \
    wget https://halite.io/downloads/starterpackages/Halite-Ruby-Starter-Package.zip && \
    unzip Halite-Java-Starter-Package.zip && unzip Halite-Ruby-Starter-Package.zip && \
    rm *.zip

# Install halite
RUN cd ~ && sh -c "$(curl -fsSL https://raw.githubusercontent.com/HaliteChallenge/Halite/master/environment/install.sh)"

# Clean
RUN apt-get remove --pure build-essential && apt-get clean && \
    rm -rf /var/lib/apt /var/cache/apt/archives/*

# Add the entrypoint
COPY entrypoint.sh /

# Arena
WORKDIR /arena

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/bin/bash"]
