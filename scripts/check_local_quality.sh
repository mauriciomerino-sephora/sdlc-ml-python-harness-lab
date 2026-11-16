#!/bin/sh
# Git hooks export repository/index overrides. Tests create their own repositories,
# so keep those overrides out of the gate's children while preserving other settings.
set -eu
git_local_variables=$(git rev-parse --local-env-vars)
for git_local_variable in $git_local_variables; do
    unset "$git_local_variable"
done
exec make ci
