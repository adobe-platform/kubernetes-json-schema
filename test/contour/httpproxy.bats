#!/usr/bin/env bats

load ../test_helper

# Bats and test_helper.bash provide these variables.
# shellcheck disable=SC2154

@test "valid HTTPProxy with CORS" {
  run kubeval "${FIXTURES}/valid.yaml"
  [[ ${status} -eq 0 ]]
  [[ ${output} = "PASS - ${FIXTURES}/valid.yaml contains a valid HTTPProxy (test)" ]]
}

@test "valid HTTPProxy with CORS in strict mode" {
  run kubeval --strict "${FIXTURES}/valid.yaml"
  [[ ${status} -eq 0 ]]
  [[ ${output} = "PASS - ${FIXTURES}/valid.yaml contains a valid HTTPProxy (test)" ]]
}

@test "valid HTTPProxy without CORS in strict mode" {
  run kubeval --strict "${FIXTURES}/without-cors.yaml"
  [[ ${status} -eq 0 ]]
  [[ ${output} = "PASS - ${FIXTURES}/without-cors.yaml contains a valid HTTPProxy (test)" ]]
}

@test "invalid HTTPProxy CORS field types" {
  for mode in standard strict; do
    options=()
    if [[ ${mode} = strict ]]; then
      options=(--strict)
    fi
    run kubeval "${options[@]}" "${FIXTURES}/invalid.yaml"
    [[ ${status} -eq 1 ]]
    for field in allowCredentials allowHeaders allowMethods allowOrigin exposeHeaders maxAge; do
      [[ ${output} = *"spec.virtualhost.corsPolicy.${field}: Invalid type."* ]]
    done
  done
}

@test "invalid HTTPProxy CORS array items" {
  for mode in standard strict; do
    options=()
    if [[ ${mode} = strict ]]; then
      options=(--strict)
    fi
    run kubeval "${options[@]}" "${FIXTURES}/invalid-items.yaml"
    [[ ${status} -eq 1 ]]
    for field in allowHeaders allowMethods allowOrigin exposeHeaders; do
      [[ ${output} = *"spec.virtualhost.corsPolicy.${field}.0: Invalid type."* ]]
    done
  done
}

@test "invalid HTTPProxy CORS header tokens" {
  for mode in standard strict; do
    options=()
    if [[ ${mode} = strict ]]; then
      options=(--strict)
    fi
    run kubeval "${options[@]}" "${FIXTURES}/invalid-tokens.yaml"
    [[ ${status} -eq 1 ]]
    for field in allowHeaders allowMethods exposeHeaders; do
      [[ ${output} = *"spec.virtualhost.corsPolicy.${field}.0: Does not match pattern"* ]]
    done
  done
}

@test "invalid HTTPProxy CORS missing required fields" {
  for mode in standard strict; do
    options=()
    if [[ ${mode} = strict ]]; then
      options=(--strict)
    fi
    run kubeval "${options[@]}" "${FIXTURES}/missing-required.yaml"
    [[ ${status} -eq 1 ]]
    [[ ${output} = *"allowMethods is required"* ]]
    [[ ${output} = *"allowOrigin is required"* ]]
  done
}

@test "invalid HTTPProxy CORS property in strict mode" {
  run kubeval --strict "${FIXTURES}/strict.yaml"
  [[ ${status} -eq 1 ]]
  [[ ${output} = *"Additional property unknownCorsProperty is not allowed"* ]]
}

@test "invalid HTTPProxy virtualhost property in strict mode" {
  run kubeval --strict "${FIXTURES}/strict-virtualhost.yaml"
  [[ ${status} -eq 1 ]]
  [[ ${output} = *"Additional property unknownVirtualHostProperty is not allowed"* ]]
}
