#!/bin/bash

set -u

if [ -z "${GITHUB_TOKEN}" ]
then
    echo "The GITHUB_TOKEN environment variable is not defined."
    exit 1
fi

GIT=$(whereis git)

BRANCH="${1}"
MESSAGE="${2}"
DRAFT="${3}"
PRE="${4}"

NEXT_RELEASE=$(date '+%Y.%V')

LAST_HASH=$(${GIT} rev-list --tags --max-count=1)

LAST_RELEASE=$(${GIT} describe --tags ${LAST_HASH})
echo "Last release : ${LAST_RELEASE}"

if [ ${LAST_RELEASE:0:7} == ${NEXT_RELEASE} ]; then
    NEXT_RELEASE=${LAST_RELEASE:0:7}.$((${LAST_RELEASE:8} + 1))
    echo "Minor release"
fi

if [ "$MESSAGE" == "0" ]; then
	MESSAGE="release: version ${NEXT_RELEASE}"
fi


echo "Next release : ${NEXT_RELEASE}"

API_JSON=$(printf '{"tag_name": "v%s","target_commitish": "%s","name": "v%s","body": "%s","draft": %s,"prerelease": %s}' "$NEXT_RELEASE" "$BRANCH" "$NEXT_RELEASE" "$MESSAGE" "$DRAFT" "$PRE" )
API_RESPONSE_STATUS=$(curl --data "$API_JSON" -s -i https://api.github.com/repos/${GITHUB_REPOSITORY}/releases?access_token=${GITHUB_TOKEN})
echo "$API_RESPONSE_STATUS"

echo ::set-output name=tag::${NEXT_RELEASE}
