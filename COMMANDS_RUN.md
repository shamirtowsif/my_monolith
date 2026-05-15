# Commands Run

This file lists the shell commands run during the project setup, build, and demo execution work. Polling an already-running command session and `apply_patch` file edits are not shell commands and are not listed here.

## Environment Setup

```bash
XDG_CACHE_HOME=/home/odbhutsc/Documents/monolith/.cache CONDA_PKGS_DIRS=/home/odbhutsc/Documents/monolith/.conda-pkgs conda --no-plugins create --solver=classic -y -p /home/odbhutsc/Documents/monolith/.venv-monolith python=3.8
```

```bash
PIP_CACHE_DIR=/home/odbhutsc/Documents/monolith/.pip-cache /home/odbhutsc/Documents/monolith/.venv-monolith/bin/python -m pip install -U pip numpy==1.19.4 wheel packaging requests opt_einsum keras_preprocessing --no-deps
```

```bash
PIP_CACHE_DIR=/home/odbhutsc/Documents/monolith/.pip-cache /home/odbhutsc/Documents/monolith/.venv-monolith/bin/python -m pip install --no-deps tensorflow-estimator==2.4.0
```

## Bazel Demo Runs

```bash
PATH=/home/odbhutsc/Documents/monolith/.venv-monolith/bin:/home/odbhutsc/Documents/monolith/.tools:$PATH PYTHON_BIN_PATH=/home/odbhutsc/Documents/monolith/.venv-monolith/bin/python PYTHON_LIB_PATH=/home/odbhutsc/Documents/monolith/.venv-monolith/lib/python3.8/site-packages /home/odbhutsc/Documents/monolith/.tools/bazel-3.1.0 --output_user_root=/home/odbhutsc/Documents/monolith/.bazel-cache run --output_filter=IGNORE_LOGS --copt=-Wno-error --host_copt=-Wno-error --cxxopt=-include --cxxopt=cstdint --host_cxxopt=-include --host_cxxopt=cstdint //monolith/native_training:demo -- --num_ps=0
```

The Bazel command above was run repeatedly while resolving build/runtime failures. The final run built successfully and completed the demo with exit code 0.

## Build Investigation Commands

```bash
rg -n "absl|string_view|FLATBUFFERS.*STRING" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/base.h
```

```bash
sed -n '180,250p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/base.h
```

```bash
rg -n "flatbuffers" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/tensorflow/workspace.bzl /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party -g '*.bzl' -g '*.BUILD' -g 'BUILD'
```

```bash
git status --short
```

```bash
sed -n '1,70p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party/flatbuffers/workspace.bzl
```

```bash
rg -n "pybind11_cstdint|aws_cstdint|boringssl_no_werror|flatbuffers|patch_file|patches" third_party/org_tensorflow/tf.patch
```

```bash
sed -n '1,70p' /home/odbhutsc/Documents/monolith/third_party/org_tensorflow/tf.patch
```

```bash
sed -n '1120,1185p' /home/odbhutsc/Documents/monolith/third_party/org_tensorflow/tf.patch
```

```bash
sed -n '520,610p' third_party/org_tensorflow/tf.patch
```

```bash
wc -l third_party/org_tensorflow/tf.patch
```

```bash
sed -n '1,80p' third_party/pybind11_cstdint.patch
```

```bash
sed -n '1,80p' third_party/boringssl_no_werror.patch
```

```bash
rg -n "FLATBUFFERS_HAS_STRING_VIEW|string_view" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/src
```

```bash
sed -n '1,80p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/src/idl_gen_text.cpp
```

```bash
sed -n '1,65p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/string.h
```

```bash
rg -n "ruy" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/tensorflow/workspace.bzl /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party -g '*.bzl' -g '*.BUILD' -g 'BUILD'
```

```bash
sed -n '1,45p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy/ruy/block_map.cc
```

```bash
rg -n "numeric_limits" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy
```

```bash
rg -n "cxxopt|copt|build" .bazelrc tools . -g '.bazelrc' -g '*.bazelrc'
```

```bash
sed -n '1,80p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party/ruy/workspace.bzl
```

```bash
sed -n '1,70p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy/ruy/cpuinfo.cc
```

```bash
sed -n '1,65p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy/ruy/apply_multiplier.cc
```

```bash
sed -n '1,55p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy/ruy/validate.h
```

```bash
sed -n '1,70p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy/ruy/mul_params.h
```

```bash
sed -n '1,55p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/ruy/ruy/pack_common.h
```

```bash
nl -ba third_party/org_tensorflow/tf.patch | sed -n '585,630p'
```

```bash
tail -60 third_party/org_tensorflow/tf.patch
```

```bash
sed -n '1,25p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party/ruy/workspace.bzl
```

```bash
rg -n "ClassicLocale|instance_|class ClassicLocale" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers
```

```bash
sed -n '1,130p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/BUILD.bazel
```

```bash
sed -n '1,130p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party/flatbuffers/BUILD.bazel
```

```bash
sed -n '1,130p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/src/BUILD
```

```bash
sed -n '130,260p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/src/BUILD
```

```bash
rg -n "src:flatc|flatc_library|src/BUILD|srcs = \\[" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/third_party/flatbuffers -g '*'
```

```bash
sed -n '180,235p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/src/util.cpp
```

```bash
sed -n '185,235p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/util.h
```

```bash
sed -n '130,180p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/base.h
```

```bash
rg --files /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/execroot/__main__/bazel-out/host/bin/external/flatbuffers | rg 'util\\.o$|idl_gen_text\\.o$'
```

```bash
rg -n "FLATBUFFERS_LOCALE_INDEPENDENT" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers
```

```bash
nm -C /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/execroot/__main__/bazel-out/host/bin/external/flatbuffers/src/_objs/flatc/util.o | rg "ClassicLocale|FLATBUFFERS_VERSION"
```

```bash
nm -C /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/execroot/__main__/bazel-out/host/bin/external/flatbuffers/src/_objs/flatbuffers/util.o | rg "ClassicLocale|FLATBUFFERS_VERSION"
```

```bash
nm -C /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/execroot/__main__/bazel-out/host/bin/external/flatbuffers/src/_objs/flatc/idl_gen_text.o | rg "ClassicLocale"
```

```bash
sed -n '1,60p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/util.h
```

```bash
sed -n '210,255p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/base.h
```

```bash
sed -n '1,90p' third_party/flatbuffers_no_absl_string_view.patch
```

```bash
nl -ba /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/flatbuffers/include/flatbuffers/base.h | sed -n '205,255p'
```

```bash
rg --files /home/odbhutsc/Documents/monolith/.bazel-cache | rg 'flatbuffers.*1\\.12|62f2223f|v1\\.12'
```

```bash
file /home/odbhutsc/Documents/monolith/.bazel-cache/cache/repos/v1/content_addressable/sha256/62f2223fb9181d1d6338451375628975775f7522185266cd5296571ac152bc45/file
```

```bash
tar -tzf /home/odbhutsc/Documents/monolith/.bazel-cache/cache/repos/v1/content_addressable/sha256/62f2223fb9181d1d6338451375628975775f7522185266cd5296571ac152bc45/file | rg 'include/flatbuffers/base.h$'
```

```bash
tar -xOzf /home/odbhutsc/Documents/monolith/.bazel-cache/cache/repos/v1/content_addressable/sha256/62f2223fb9181d1d6338451375628975775f7522185266cd5296571ac152bc45/file flatbuffers-1.12.0/include/flatbuffers/base.h | nl -ba | sed -n '205,255p'
```

```bash
mkdir -p /tmp/monolith-flatbuffers-patch-test
```

```bash
mkdir -p /tmp/monolith-flatbuffers-patch-test2
```

```bash
tar -xzf /home/odbhutsc/Documents/monolith/.bazel-cache/cache/repos/v1/content_addressable/sha256/62f2223fb9181d1d6338451375628975775f7522185266cd5296571ac152bc45/file -C /tmp/monolith-flatbuffers-patch-test flatbuffers-1.12.0/include/flatbuffers/base.h
```

```bash
patch --dry-run -p1 -d /tmp/monolith-flatbuffers-patch-test/flatbuffers-1.12.0 -i /home/odbhutsc/Documents/monolith/third_party/flatbuffers_no_absl_string_view.patch
```

```bash
nl -ba third_party/flatbuffers_no_absl_string_view.patch | sed -n '1,80p'
```

## Local Source Investigation Commands

```bash
sed -n '1,90p' monolith/native_training/data/training_instance/cc/snappy_inputbuffer.cc
```

```bash
sed -n '1,120p' monolith/native_training/data/training_instance/cc/snappy_inputbuffer.h
```

```bash
sed -n '50,95p' monolith/native_training/data/training_instance/BUILD
```

```bash
rg -n "LOG_IF\\(|#include <glog|glog/logging|tensorflow/core/platform/logging|snappy_inputbuffer" monolith/native_training/data/training_instance monolith -g '*.cc' -g '*.h'
```

```bash
sed -n '24,60p' monolith/native_training/data/training_instance/cc/zstd_inputbuffer.cc
```

```bash
rg -n "errors::|strings::StrCat|LOG|CHECK|Status\\(|DataLoss|OutOfRange|ResourceExhausted|Internal|Unavailable" monolith/native_training/data/training_instance/cc/snappy_inputbuffer.cc
```

```bash
sed -n '90,240p' monolith/native_training/data/training_instance/cc/snappy_inputbuffer.cc
```

```bash
sed -n '240,290p' monolith/native_training/data/training_instance/cc/snappy_inputbuffer.cc
```

## TensorFlow Estimator Runtime Investigation Commands

```bash
rg -n "tensorflow_estimator|tensorflow-estimator|tensorflow==|tf.version|TF_VERSION|tensorflow_estimator" . monolith third_party -g '*.txt' -g '*.py' -g '*.bzl' -g 'requirements*' -g 'WORKSPACE'
```

```bash
rg -n "582c8d236cb079023657287c318ff26adb239002|org_tensorflow|tensorflow/archive" WORKSPACE third_party -g '*'
```

```bash
/home/odbhutsc/Documents/monolith/.venv-monolith/bin/python -m pip show tensorflow-estimator tensorflow_estimator tensorboard
```

```bash
sed -n '1,120p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/tensorflow/core/public/version.h
```

```bash
rg -n "_VERSION|VERSION" /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/tensorflow/tools/pip_package/setup.py /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/tensorflow -g 'setup.py' -g 'version.py'
```

```bash
sed -n '1,120p' /home/odbhutsc/Documents/monolith/.bazel-cache/b162b18fb33aaa04c38d09dac48a1051/external/org_tensorflow/tensorflow/tools/pip_package/setup.py
```

## Gitignore / Workspace State Commands

```bash
git status --short
```

```bash
ls -a | rg '^\\.gitignore$'
```

```bash
sed -n '1,160p' .gitignore
```
