# Run
FROM node:alpine3.10 as run

RUN apk add --no-cache curl git jq

RUN npm install -g conventional-changelog-cli

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
