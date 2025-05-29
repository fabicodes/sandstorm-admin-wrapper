FROM ruby:3-slim-bookworm AS sandstorm-wrapper


RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    wget \
    make \
    gcc \
    g++ \
    libssl-dev \
    pkg-config \
    lib32gcc-s1 \
    ruby-dev && \
    rm -rf /var/lib/apt/lists/*

# Configure locales
RUN apt-get update && \
    apt-get install -y --no-install-recommends locales && \
    rm -rf /var/lib/apt/lists/* && \
    echo "LC_ALL=en_US.UTF-8" >> /etc/environment && \
    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
    echo "LANG=en_US.UTF-8" > /etc/default/locale && \
    locale-gen en_US.UTF-8

ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

ENV BUNDLE_PATH /home/sandstorm/admin-interface/vendor/bundle
ENV GEM_HOME $BUNDLE_PATH
ENV BUNDLE_APP_CONFIG /home/sandstorm/admin-interface/.bundle
ENV PATH $GEM_HOME/bin:$PATH

RUN useradd -ms /bin/bash sandstorm

WORKDIR /home/sandstorm

COPY --chown=sandstorm:sandstorm . .

RUN wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz

RUN mkdir -p steamcmd/installation && \
    mv steamcmd_linux.tar.gz steamcmd/installation/

RUN cd steamcmd/installation && \
    tar -xvf steamcmd_linux.tar.gz && \
    rm steamcmd_linux.tar.gz

RUN cp config/config.toml.docker config/config.toml
RUN gem install bundler --conservative
WORKDIR /home/sandstorm/admin-interface

RUN bundle install --jobs=$(nproc)

WORKDIR /home/sandstorm
RUN chown -R sandstorm:sandstorm /home/sandstorm
USER sandstorm
CMD ["/home/sandstorm/docker_start.sh"]

# Expose necessary ports (adjust if your application uses different ports)
# Example: EXPOSE 3000
# EXPOSE 27015/udp
# EXPOSE 27016/udp
