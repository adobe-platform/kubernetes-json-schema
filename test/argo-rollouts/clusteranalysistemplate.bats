#!/usr/bin/env bats

load ../test_helper

@test "valid ClusterAnalysisTemplate" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid ClusterAnalysisTemplate (test.test)" ]]
}

@test "invalid ClusterAnalysisTemplate" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid ClusterAnalysisTemplate (test.test) - metrics: metrics is required" ]]
}

@test "invalid ClusterAnalysisTemplate in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid ClusterAnalysisTemplate (test.test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
