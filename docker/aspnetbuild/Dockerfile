FROM microsoft/dotnet:2.0.0-runtime-deps

RUN apt-get update && \
    apt-get -qy install \
    unzip \
    jq \
    gnupg \
    curl && \
    rm -Rf /var/apt/lists/*

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash - && \
    apt-get -qy install nodejs && \
    rm -Rf /var/apt/lists/*