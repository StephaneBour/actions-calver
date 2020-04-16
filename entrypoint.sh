#!/bin/sh -l

set -u

cd /github/workspace || exit 1

# Env and options
if [ -z "${GITHUB_TOKEN}" ]
then
    echo "The GITHUB_TOKEN environment variable is not defined."
    exit 1
fi

BRANCH="${1}"
NAME="${2}"
MESSAGE="${3}"
DRAFT="${4}"
PRE="${5}"
CREATE_RELEASE="${6}"
DATE_FORMAT="${7}"

# Fetch git tags
git fetch --depth=1 origin +refs/tags/*:refs/tags/*

NEXT_RELEASE=$(date "+${DATE_FORMAT}")

LAST_HASH=$(git rev-list --tags --max-count=1)
echo "Last hash : ${LAST_HASH}"

LAST_RELEASE=$(git describe --tags "${LAST_HASH}")
echo "Last release : ${LAST_RELEASE}"
MAJOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk -v l=${#NEXT_RELEASE} '{ string=substr($0, 1, l); print string; }' )
echo "Last major release : ${MAJOR_LAST_RELEASE}"

if [ "${MAJOR_LAST_RELEASE}" = "${NEXT_RELEASE}" ]; then
    MINOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk -v l=`expr ${#NEXT_RELEASE} + 2` '{ string=substr($0, l); print string; }' )
    NEXT_RELEASE=${MAJOR_LAST_RELEASE}.$((${MINOR_LAST_RELEASE} + 1))
    echo "Minor release"
fi

if [ "${NAME}" = "0" ]; then
	NAME="release: version ${NEXT_RELEASE}"
fi

if [ "${MESSAGE}" = "0" ]; then
  MESSAGE=$(conventional-changelog)
fi

echo "Next release : ${NEXT_RELEASE}"

echo "${MESSAGE}"

echo "Create release : ${CREATE_RELEASE}"

if [ "${CREATE_RELEASE}" = "true" ] || [ "${CREATE_RELEASE}" = true ]; then
  JSON_STRING=$( jq -n \
                    --arg tn "$NEXT_RELEASE" \
                    --arg tc "$BRANCH" \
                    --arg n "$NEXT_RELEASE" \
                    --arg b "$MESSAGE" \
                    --argjson d "$DRAFT" \
                    --argjson p "$PRE" \
                    '{tag_name: $tn, target_commitish: $tc, name: $n, body: $b, draft: $d, prerelease: $p}' )
  echo ${JSON_STRING}
  OUTPUT=$(curl -s --data "${JSON_STRING}" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases?access_token=${GITHUB_TOKEN}")
  echo ${OUTPUT} | jq
fi;

echo ::set-output name=release::"${NEXT_RELEASE}"
