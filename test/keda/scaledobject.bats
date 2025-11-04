#!/usr/bin/env bats

load ../test_helper

@test "valid ScaledObject" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid ScaledObject (test)" ]]
}

@test "invalid ScaledObject" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid ScaledObject (test) - scaleTargetRef: scaleTargetRef is required" ]]
}

@test "invalid ScaledObject in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid ScaledObject (test) - unknownProperty: Additional property unknownProperty is not allowed" ]]
}

