#!/usr/bin/env bats

load ../test_helper

@test "valid HelmRelease" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid HelmRelease (test.test)" ]]
}

@test "invalid HelmRelease" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid HelmRelease (test.test) - chart: chart is required" ]]
}

@test "invalid HelmRelease in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid HelmRelease (test.test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
