FROM ghcr.io/xenontheinertg/docky:latest
ENV DEBIAN_FRONTEND noninteractive
COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
