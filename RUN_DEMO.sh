#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "${BASH_SOURCE[0]}")"

PATH="$PWD/.venv-monolith/bin:$PWD/.tools:$PATH" \
  PYTHON_BIN_PATH="$PWD/.venv-monolith/bin/python" \
  PYTHON_LIB_PATH="$PWD/.venv-monolith/lib/python3.8/site-packages" \
  "$PWD/.tools/bazel-3.1.0" \
    --output_user_root="$PWD/.bazel-cache" \
    run --output_filter=IGNORE_LOGS \
    --copt=-Wno-error --host_copt=-Wno-error \
    --cxxopt=-include --cxxopt=cstdint \
    --host_cxxopt=-include --host_cxxopt=cstdint \
    //monolith/native_training:demo -- --num_ps=0
