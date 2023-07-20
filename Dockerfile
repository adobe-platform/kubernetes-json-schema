FROM debian:buster-slim

RUN apt-get update && apt-get install -y curl moreutils jq && \
  curl -L https://github.com/mikefarah/yq/releases/download/v4.9.6/yq_linux_amd64 -o /usr/local/bin/yq && \
  chmod +x /usr/local/bin/yq

WORKDIR /working

CMD [ "./build.sh" ]
