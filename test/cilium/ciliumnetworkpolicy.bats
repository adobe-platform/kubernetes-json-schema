#!/usr/bin/env bats

load ../test_helper

@test "valid CiliumNetworkPolicy" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid CiliumNetworkPolicy (test)" ]]
}

@test "invalid CiliumNetworkPolicy" {
  run kubeval "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid CiliumNetworkPolicy (test) - spec.endpointSelector.matchLabels: Invalid type. Expected: object, given: null" ]]
}

@test "invalid CiliumNetworkPolicy in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid CiliumNetworkPolicy (test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
