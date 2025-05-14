#!/usr/bin/env bats

load ../test_helper

@test "valid AnalysisTemplate" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]] || {
    echo "Output: $output"
    exit 1
  }
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid AnalysisTemplate (test.test)" ]] || {
    echo "Output: $output"
    exit 1
  }
}

@test "invalid AnalysisTemplate" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]] || {
    echo "Output: $output"
    exit 1
  }
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid AnalysisTemplate (test.test) - provider: provider is required" ]] || {
    echo "Output: $output"
    exit 1
  }
}

@test "invalid AnalysisTemplate in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]] || {
    echo "Output: $output"
    exit 1
  }
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid AnalysisTemplate (test.test) - invalid-key: Additional property invalid-key is not allowed" ]] || {
    echo "Output: $output"
    exit 1
  }
}
