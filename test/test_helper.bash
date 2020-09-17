#!/bin/bash

function kubeval() {
  command kubeval --additional-schema-locations file://. "$@"
}

# shellcheck disable=SC2034 disable=SC2154
readonly FIXTURES="${BATS_TEST_DIRNAME}/$(basename "${BATS_TEST_FILENAME}" .bats)"
