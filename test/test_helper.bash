#!/bin/bash

function kubeval() {
  command kubeval --additional-schema-locations file://. "$@"
}

readonly FIXTURES="${BATS_TEST_DIRNAME}/$(basename "${BATS_TEST_FILENAME}" .bats)"
