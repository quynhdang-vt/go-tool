FROM alpine:3.7 as builder

ARG ARG_GITHUB_ACCESS_TOKEN

ADD . /go/src/github.com/quynhdang-vt/go-tool
WORKDIR /go/src/github.com/quynhdang-vt/go-tool

RUN apk update && \
    apk add -U build-base go git curl libstdc++ && \
    git config --global url."https://${ARG_GITHUB_ACCESS_TOKEN}:x-oauth-basic@github.com/".insteadOf "https://github.com/" && \
                go env && go list all | grep cover
RUN GOPATH=/go make -f Makefile.inContainer deps
RUN GOPATH=/go make -f Makefile.inContainer docker

FROM alpine:3.7
RUN mkdir -p /app/events && apk update && apk add -U curl jq && apk add ca-certificates && rm -rf /var/cache/apk/*
COPY --from=builder /go/src/github.com/quynhdang-vt/go-tool/go-tool /app


WORKDIR /app
ENTRYPOINT ["/app/go-tool"]
