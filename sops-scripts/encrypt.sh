#!/bin/bash

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd "${scriptDir}/.." || exit 1

export SOPS_AGE_RECIPIENTS=$(<$(pwd)/sops-scripts/public-age-keys.txt)
exec 3<<< "$(cat $1)"
sops --encrypt --input-type yaml --output-type yaml --age ${SOPS_AGE_RECIPIENTS} --encrypted-regex "^(user|password)$" /dev/fd/3

