#!/bin/bash
declare output status
# shellcheck disable=SC2034,SC2154
output="$(functionThatOutputSomething "${arg1}")"
status=$?
echo "${status}"
