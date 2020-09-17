#!/usr/bin/env bats

load ../test_helper

@test "valid Rollout" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid Rollout (test.test)" ]]
}

@test "invalid Rollout" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid Rollout (test.test) - selector: selector is required" ]]
}

@test "invalid Rollout in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid Rollout (test.test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
