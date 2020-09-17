#!/usr/bin/env bats

load ../test_helper

@test "valid ClusterIssuer" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid ClusterIssuer (test)" ]]
}

@test "invalid ClusterIssuer" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid ClusterIssuer (test) - server: server is required" ]]
}

@test "invalid ClusterIssuer in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid ClusterIssuer (test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
