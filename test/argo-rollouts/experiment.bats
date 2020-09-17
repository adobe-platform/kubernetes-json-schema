#!/usr/bin/env bats

load ../test_helper

@test "valid Experiment" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid Experiment (test.test)" ]]
}

@test "invalid Experiment" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid Experiment (test.test) - name: name is required" ]]
}

@test "invalid Experiment in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid Experiment (test.test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
