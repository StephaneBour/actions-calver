#!/bin/sh -l

set -u

cd "${GITHUB_WORKSPACE}" || exit 1

# Env and options
if [ -z "${GITHUB_TOKEN}" ]; then
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
VERSION_REGEXP="${8}"

# Security
git config --global --add safe.directory "${GITHUB_WORKSPACE}"

# Fetch git tags
git fetch --depth=1 origin +refs/tags/*:refs/tags/*

NEXT_RELEASE=$(date "+${DATE_FORMAT}")

# ColemanB - Script looks for tags meeting requirements
# and then looks up hash.
LAST_RELEASE=$(git tag --sort=v:refname | grep -E "${VERSION_REGEXP}" | tail -n 1)
echo "Last release : ${LAST_RELEASE}"

LAST_HASH="$(git show-ref -s "${LAST_RELEASE}")"
echo "Last hash : ${LAST_HASH}"
# ColemanB - End changes.

MAJOR_LAST_RELEASE=$(echo "${LAST_RELEASE}" | awk -v l=${#NEXT_RELEASE} '{ string=substr($0, 1, l); print string; }')
echo "Last major release : ${MAJOR_LAST_RELEASE}"

if [ "${MAJOR_LAST_RELEASE}" = "${NEXT_RELEASE}" ]; then
  MINOR_LAST_RELEASE="$(echo "${LAST_RELEASE}" | awk -v l=$((${#NEXT_RELEASE} + 2)) '{ string=substr($0, l); print string; }')"
  NEXT_RELEASE=${MAJOR_LAST_RELEASE}.$((MINOR_LAST_RELEASE + 1))
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
  JSON_STRING=$(jq -n \
    --arg tn "$NEXT_RELEASE" \
    --arg tc "$BRANCH" \
    --arg n "$NEXT_RELEASE" \
    --arg b "$MESSAGE" \
    --argjson d "$DRAFT" \
    --argjson p "$PRE" \
    '{tag_name: $tn, target_commitish: $tc, name: $n, body: $b, draft: $d, prerelease: $p}')
  echo "${JSON_STRING}"
  OUTPUT=$(curl -s --data "${JSON_STRING}" -H "Authorization: token ${GITHUB_TOKEN}" "https://api.github.com/repos/${GITHUB_REPOSITORY}/releases")
  echo "${OUTPUT}" | jq
fi

echo "release=${NEXT_RELEASE}" >>$GITHUB_OUTPUT
