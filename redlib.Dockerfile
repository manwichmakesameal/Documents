FROM alpine:3.19 AS builder

ARG TARGET

RUN apk upgrade --no-cache && \
    apk add --no-cache git cargo rust

WORKDIR /build

RUN git clone https://github.com/redlib-org/redlib.git && \
    cd redlib && \
    cargo build --release

FROM alpine:3.19

RUN apk upgrade --no-cache && \
    apk add --no-cache bash libgcc libstdc++

COPY --from=builder /build/redlib/target/release/redlib /usr/local/bin/redlib

RUN adduser --home /nonexistent --no-create-home --disabled-password redlib
USER redlib

# Tell Docker to expose port 8080
EXPOSE 8080

# Run a healthcheck every minute to make sure redlib is functional
HEALTHCHECK --interval=1m --timeout=3s CMD wget --spider --q http://localhost:8080/settings || exit 1

CMD ["redlib"]