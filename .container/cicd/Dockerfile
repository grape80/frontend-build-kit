FROM golang:1.20.3-bullseye

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

RUN go install github.com/grape80/gotmpl2html/cmd/gotmpl2html@latest
RUN cd $GOPATH/bin && curl -fsSL https://esbuild.github.io/dl/latest | sh
RUN go install github.com/tdewolff/minify/v2/cmd/minify@latest
RUN curl -fsSL https://github.com/sass/dart-sass/releases/download/1.63.6/dart-sass-1.63.6-linux-$(go env GOHOSTARCH).tar.gz | tar zxvf - -C /opt
ENV PATH $PATH:/opt/dart-sass

WORKDIR /workspace

RUN useradd -u 1001 -m nonroot && chown nonroot:nonroot -R /workspace
# WA: https://github.com/actions/runner/issues/2411

USER nonroot
