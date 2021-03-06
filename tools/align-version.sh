#!/bin/bash
#------------------------------------------------------------------------
# updates all package.json files to the version defined in lerna.json
# this is called when building inside our ci/cd system
#------------------------------------------------------------------------
set -euo pipefail
scriptdir=$(cd $(dirname $0) && pwd)

# go to repo root
cd ${scriptdir}/..

suffix="${1:-}"
if [ -n "${suffix}" ]; then
  echo "suffix is no longer supported"
  exit 1
fi

version=$(node -p "require('./tools/get-version')")
files="./package.json $(npx lerna ls -p -a | xargs -n1 -I@ echo @/package.json)"
${scriptdir}/align-version.js ${version}${suffix} ${files}

# validation
marker=$(node -p "require('./tools/get-version-marker').replace(/\./g, '\\\.')")

# Get a list of all package.json files. None of them shouldn contain 0.0.0 anymore.
# Exclude a couple of specific ones that we don't care about.
package_jsons=$(find . -name package.json | grep -v node_modules)

if grep -l "[^0-9]${marker}" $package_jsons; then
  echo "ERROR: unexpected version marker ${marker} in a package.json file"
  exit 1
fi
