FROM alpine:latest
LABEL maintainer="Vianney Bouchaud <vianney@bouchaud.org>"

RUN apk add --no-cache bash coreutils grep

WORKDIR /opt/

COPY ./build /usr/bin
RUN chmod +x /usr/bin/build

ENTRYPOINT ["build"]
