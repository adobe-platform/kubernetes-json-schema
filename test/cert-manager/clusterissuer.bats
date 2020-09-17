#!/usr/bin/env bats

readonly FIXTURES="${BATS_TEST_DIRNAME}/clusterissuer"

@test "valid ClusterIssuer" {
  run kubeval --additional-schema-locations file://. "${FIXTURES}/valid.yaml"
  [[ $status -eq 0 ]]
  [[ $output = "PASS - ${FIXTURES}/valid.yaml contains a valid ClusterIssuer (test)" ]]
}

@test "invalid ClusterIssuer" {
  run kubeval --additional-schema-locations file://. "${FIXTURES}/invalid.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/invalid.yaml contains an invalid ClusterIssuer (test) - server: server is required" ]]
}

@test "invalid ClusterIssuer in strict mode" {
  run kubeval --additional-schema-locations file://. --strict "${FIXTURES}/strict.yaml"
  [[ $status -eq 1 ]]
  [[ $output = "WARN - ${FIXTURES}/strict.yaml contains an invalid ClusterIssuer (test) - invalid-key: Additional property invalid-key is not allowed" ]]
}
