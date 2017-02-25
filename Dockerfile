FROM gcr.io/stacksmith-images/minideb-buildpack:jessie-r10

MAINTAINER Angel <angel@laux.com>

# Install keys
RUN curl https://www.dotdeb.org/dotdeb.gpg | sudo apt-key add - && \
    echo 'deb http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list && \
    echo 'deb-src http://packages.dotdeb.org jessie all' >> /etc/apt/sources.list && \
    echo "deb http://http.debian.net/debian jessie-backports main" >> /etc/apt/sources.list

# Install packages
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates-java/jessie-backports \
    openjdk-8-jdk-headless openjdk-8-jdk ruby build-essential unzip wget vim php7.0

# Install Node
RUN curl -sL https://deb.nodesource.com/setup_6.x | sudo -E bash - && apt-get install -y nodejs

# Download started packages
RUN cd ~ && wget https://halite.io/downloads/starterpackages/Halite-Java-Starter-Package.zip && \
    wget https://halite.io/downloads/starterpackages/Halite-PHP-Starter-Package.zip && \
    wget https://halite.io/downloads/starterpackages/Halite-Ruby-Starter-Package.zip && \
    wget https://halite.io/downloads/starterpackages/Halite-JavaScript-Starter-Package.zip && \
    unzip Halite-Java-Starter-Package.zip && unzip Halite-Ruby-Starter-Package.zip && \
    unzip Halite-PHP-Starter-Package.zip && unzip Halite-JavaScript-Starter-Package.zip && \
    rm *.zip

# Install halite
RUN cd ~ && sh -c "$(curl -fsSL https://raw.githubusercontent.com/HaliteChallenge/Halite/master/environment/install.sh)"

# Clean
RUN apt-get remove --purge -y build-essential && apt-get -y autoremove && apt-get clean && \
    rm -rf /var/lib/apt /var/cache/apt/archives/*

# Main script depedencies
RUN gem install tty-prompt tty-command terminal-table chunky_png

# Add the entrypoint
COPY docker/entrypoint.sh /

# Add the main script
COPY main.rb /

# Arena
WORKDIR /arena

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]

CMD ["/main.rb"]
