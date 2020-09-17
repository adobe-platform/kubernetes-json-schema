#!/usr/bin/env bats

readonly FIXTURES="${BATS_TEST_DIRNAME}/helmrelease"

@test "valid HelmRelease" {
  run kubeval --additional-schema-locations file://. "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid HelmRelease (test.test)" ]]
}

@test "invalid HelmRelease" {
  run kubeval --additional-schema-locations file://. "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid HelmRelease (test.test) - chart: chart is required" ]]
}

@test "invalid HelmRelease in strict mode" {
  run kubeval --additional-schema-locations file://. --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid HelmRelease (test.test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
