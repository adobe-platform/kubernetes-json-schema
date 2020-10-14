#!/usr/bin/env bats

load ../test_helper

@test "valid IngressRoute" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid IngressRoute (test)" ]]
}

@test "invalid IngressRoute" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid IngressRoute (test) - name: name is required" ]]
}

@test "invalid IngressRoute in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid IngressRoute (test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
