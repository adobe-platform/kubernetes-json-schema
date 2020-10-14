#!/usr/bin/env bats

load ../test_helper

@test "valid ServiceMonitor" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid ServiceMonitor (test)" ]]
}

@test "invalid ServiceMonitor" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid ServiceMonitor (test) - selector: selector is required" ]]
}

@test "invalid ServiceMonitor in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid ServiceMonitor (test) - matchLabels: Additional property matchLabels is not allowed" ]]
}
