#!/usr/bin/env bash
set -euo pipefail

# Run this from a freshly downloaded monolith repo, or run it directly with:
#   bash FRESH_CLONE_SETUP_AND_RUN.sh
cd "$(dirname "${BASH_SOURCE[0]}")"

mkdir -p .tools .pip-cache .conda-pkgs .downloads

if ! command -v conda >/dev/null 2>&1; then
  echo "conda is required for this setup because the project needs Python 3.8." >&2
  exit 1
fi

if [ ! -x "$PWD/.venv-monolith/bin/python" ]; then
  XDG_CACHE_HOME="$PWD/.cache" \
  CONDA_PKGS_DIRS="$PWD/.conda-pkgs" \
  conda --no-plugins create --solver=classic -y \
    -p "$PWD/.venv-monolith" \
    python=3.8
fi

PIP_CACHE_DIR="$PWD/.pip-cache" \
"$PWD/.venv-monolith/bin/python" -m pip install \
  -U pip numpy==1.19.4 wheel packaging requests opt_einsum keras_preprocessing \
  --no-deps

PIP_CACHE_DIR="$PWD/.pip-cache" \
"$PWD/.venv-monolith/bin/python" -m pip install \
  --no-deps tensorflow-estimator==2.4.0

if [ ! -x "$PWD/.tools/bazel-3.1.0" ]; then
  if command -v curl >/dev/null 2>&1; then
    curl -fL \
      -o "$PWD/.tools/bazel-3.1.0" \
      https://github.com/bazelbuild/bazel/releases/download/3.1.0/bazel-3.1.0-linux-x86_64
  elif command -v wget >/dev/null 2>&1; then
    wget -O "$PWD/.tools/bazel-3.1.0" \
      https://github.com/bazelbuild/bazel/releases/download/3.1.0/bazel-3.1.0-linux-x86_64
  else
    echo "curl or wget is required to download Bazel 3.1.0." >&2
    exit 1
  fi
  chmod +x "$PWD/.tools/bazel-3.1.0"
fi

cat > third_party/rules_python_pkginfo.patch <<'PATCH'
diff --git a/python/pip_install/repositories.bzl b/python/pip_install/repositories.bzl
index 7f51ef2..c0443d2 100644
--- a/python/pip_install/repositories.bzl
+++ b/python/pip_install/repositories.bzl
@@ -12,8 +12,8 @@ _RULE_DEPS = [
     ),
     (
         "pypi__pkginfo",
-        "https://files.pythonhosted.org/packages/e6/d5/451b913307b478c49eb29084916639dc53a88489b993530fed0a66bab8b9/pkginfo-1.5.0.1-py2.py3-none-any.whl",
-        "a6d9e40ca61ad3ebd0b72fbadd4fba16e4c0e4df0428c041e01e06eb6ee71f32",
+        "https://files.pythonhosted.org/packages/fa/3d/f4f2ba829efb54b6cd2d91349c7463316a9cc55a43fc980447416c88540f/pkginfo-1.12.1.2-py3-none-any.whl",
+        "c783ac885519cab2c34927ccfa6bf64b5a704d7c69afaea583dd9b7afe969343",
     ),
     (
         "pypi__setuptools",
PATCH

cat > third_party/kafka_ssl_set1_host.patch <<'PATCH'
diff --git a/src/rdkafka_ssl.c b/src/rdkafka_ssl.c
index 1d5b330..a86fb41 100644
--- a/src/rdkafka_ssl.c
+++ b/src/rdkafka_ssl.c
@@ -39,6 +39,10 @@
 
 #include <openssl/x509.h>
 
+#if OPENSSL_VERSION_NUMBER >= 0x10100000
+int SSL_set1_host(SSL *s, const char *hostname);
+#endif
+
 #if !_WIN32
 #include <sys/types.h>
 #include <sys/stat.h>
PATCH

cat > third_party/pybind11_cstdint.patch <<'PATCH'
diff --git a/include/pybind11/attr.h b/include/pybind11/attr.h
index 9b73812..4a00d19 100644
--- a/include/pybind11/attr.h
+++ b/include/pybind11/attr.h
@@ -9,6 +9,8 @@
 
 #pragma once
 
+#include <cstdint>
+
 #include "cast.h"
 
 NAMESPACE_BEGIN(PYBIND11_NAMESPACE)
PATCH

cat > third_party/aws_cstdint.patch <<'PATCH'
diff --git a/aws-cpp-sdk-core/include/aws/core/utils/crypto/Cipher.h b/aws-cpp-sdk-core/include/aws/core/utils/crypto/Cipher.h
index 57927c2..0d76d1a 100644
--- a/aws-cpp-sdk-core/include/aws/core/utils/crypto/Cipher.h
+++ b/aws-cpp-sdk-core/include/aws/core/utils/crypto/Cipher.h
@@ -15,6 +15,8 @@
 
 #pragma once
 
+#include <cstdint>
+
 #include <aws/core/Core_EXPORTS.h>
 #include <aws/core/utils/Array.h>
 #include <aws/core/utils/memory/stl/AWSStreamFwd.h>
PATCH

cat > third_party/boringssl_no_werror.patch <<'PATCH'
diff --git a/BUILD b/BUILD
index b50ad02..0aac3df 100644
--- a/BUILD
+++ b/BUILD
@@ -61,7 +61,6 @@ posix_copts = [
 
     # This list of warnings should match those in the top-level CMakeLists.txt.
     "-Wall",
-    "-Werror",
     "-Wformat=2",
     "-Wsign-compare",
     "-Wmissing-field-initializers",
PATCH

cat > third_party/flatbuffers_no_absl_string_view.patch <<'PATCH'
diff --git a/include/flatbuffers/base.h b/include/flatbuffers/base.h
index b4935e0..0e8a610 100644
--- a/include/flatbuffers/base.h
+++ b/include/flatbuffers/base.h
@@ -212,8 +212,8 @@
         typedef std::experimental::string_view string_view;
       }
       #define FLATBUFFERS_HAS_STRING_VIEW 1
-    // Check for absl::string_view
-    #elif __has_include("absl/strings/string_view.h")
+    // Check for absl::string_view only when explicitly enabled.
+    #elif defined(FLATBUFFERS_USE_ABSL_STRING_VIEW) && __has_include("absl/strings/string_view.h")
       #include "absl/strings/string_view.h"
       namespace flatbuffers {
         typedef absl::string_view string_view;
@@ -226,24 +226,12 @@
 #ifndef FLATBUFFERS_HAS_NEW_STRTOD
-  // Modern (C++11) strtod and strtof functions are available for use.
-  // 1) nan/inf strings as argument of strtod;
-  // 2) hex-float  as argument of  strtod/strtof.
-  #if (defined(_MSC_VER) && _MSC_VER >= 1900) || \
-      (defined(__GNUC__) && (__GNUC__ * 100 + __GNUC_MINOR__ >= 409)) || \
-      (defined(__clang__))
-    #define FLATBUFFERS_HAS_NEW_STRTOD 1
-  #endif
+  #define FLATBUFFERS_HAS_NEW_STRTOD 1
 #endif // !FLATBUFFERS_HAS_NEW_STRTOD
 
 #ifndef FLATBUFFERS_LOCALE_INDEPENDENT
   // Enable locale independent functions {strtof_l, strtod_l,strtoll_l, strtoull_l}.
   // They are part of the POSIX-2008 but not part of the C/C++ standard.
   // GCC/Clang have definition (_XOPEN_SOURCE>=700) if POSIX-2008.
-  #if ((defined(_MSC_VER) && _MSC_VER >= 1800)            || \
-       (defined(_XOPEN_SOURCE) && (_XOPEN_SOURCE>=700)))
-    #define FLATBUFFERS_LOCALE_INDEPENDENT 1
-  #else
-    #define FLATBUFFERS_LOCALE_INDEPENDENT 0
-  #endif
+  #define FLATBUFFERS_LOCALE_INDEPENDENT 0
 #endif  // !FLATBUFFERS_LOCALE_INDEPENDENT
 
 // Suppress Undefined Behavior Sanitizer (recoverable only). Usage:
PATCH

cat > third_party/ruy_limits.patch <<'PATCH'
diff --git a/ruy/block_map.cc b/ruy/block_map.cc
index 22b1d91..a4e2a17 100644
--- a/ruy/block_map.cc
+++ b/ruy/block_map.cc
@@ -17,6 +17,7 @@ limitations under the License.
 
 #include <algorithm>
 #include <cstdint>
+#include <limits>
 
 #ifdef RUY_MAKEBLOCKMAP_DEBUG
 #include <cstdio>
PATCH

"$PWD/.venv-monolith/bin/python" <<'PY'
from pathlib import Path


def replace_once(path, old, new, already=None):
    p = Path(path)
    s = p.read_text()
    if already and already in s:
        return
    if new in s:
        return
    if old not in s:
        raise SystemExit(f"Expected text not found in {path}")
    p.write_text(s.replace(old, new, 1))


replace_once(
    "WORKSPACE",
    '''http_archive(
    name = "rules_python",
    sha256 = "b6d46438523a3ec0f3cead544190ee13223a52f6a6765a29eae7b7cc24cc83a0",''',
    '''http_archive(
    name = "rules_python",
    patch_args = ["-p1"],
    patches = ["//third_party:rules_python_pkginfo.patch"],
    sha256 = "b6d46438523a3ec0f3cead544190ee13223a52f6a6765a29eae7b7cc24cc83a0",''',
    already='patches = ["//third_party:rules_python_pkginfo.patch"]',
)

replace_once(
    "WORKSPACE",
    '''http_archive(
    name = "kafka",
    build_file = "//third_party:kafka.BUILD",
    patch_cmds = [''',
    '''http_archive(
    name = "kafka",
    build_file = "//third_party:kafka.BUILD",
    patch_args = ["-p1"],
    patch_cmds = [''',
    already='patch_args = ["-p1"]\n    patch_cmds = [',
)

replace_once(
    "WORKSPACE",
    '''    ],
    sha256 = "f7fee59fdbf1286ec23ef0b35b2dfb41031c8727c90ced6435b8cf576f23a656",''',
    '''    ],
    patches = ["//third_party:kafka_ssl_set1_host.patch"],
    sha256 = "f7fee59fdbf1286ec23ef0b35b2dfb41031c8727c90ced6435b8cf576f23a656",''',
    already='patches = ["//third_party:kafka_ssl_set1_host.patch"]',
)

tf_patch = Path("third_party/org_tensorflow/tf.patch")
s = tf_patch.read_text()
if "absl/synchronization/internal/graphcycles.cc" not in s:
    s = s.replace("@@ -308,3 +308,23 @@", "@@ -308,3 +308,47 @@", 1)
    s = s.replace(
        '''+     for cpu in cpu_configs:
+         native.config_setting(
diff --git a/third_party/snappy.BUILD b/third_party/snappy.BUILD''',
        '''+     for cpu in cpu_configs:
+         native.config_setting(
+diff --git a/absl/synchronization/internal/graphcycles.cc b/absl/synchronization/internal/graphcycles.cc
+index 9b9903d..ebd66a2 100644
+--- a/absl/synchronization/internal/graphcycles.cc
++++ b/absl/synchronization/internal/graphcycles.cc
+@@ -35,6 +35,7 @@
+ 
+ #include <algorithm>
+ #include <array>
++#include <limits>
+ #include "absl/base/internal/hide_ptr.h"
+ #include "absl/base/internal/raw_logging.h"
+ #include "absl/base/internal/spinlock.h"
+diff --git a/absl/strings/internal/str_format/extension.h b/absl/strings/internal/str_format/extension.h
+index 16dfa47..0f854ef 100644
+--- a/absl/strings/internal/str_format/extension.h
++++ b/absl/strings/internal/str_format/extension.h
+@@ -19,6 +19,7 @@
+ #include <limits.h>
+ 
+ #include <cstddef>
++#include <cstdint>
+ #include <cstring>
+ #include <ostream>
+ 
diff --git a/third_party/snappy.BUILD b/third_party/snappy.BUILD''',
        1,
    )

if "pybind11_cstdint.patch" not in s:
    s += '''
diff --git a/tensorflow/workspace.bzl b/tensorflow/workspace.bzl
index 267f94c916d..0f4a50f9af3 100644
--- a/tensorflow/workspace.bzl
+++ b/tensorflow/workspace.bzl
@@ -1140,5 +1140,6 @@ def tf_repositories(path_prefix = "", tf_repo_name = ""):
         sha256 = "1eed57bc6863190e35637290f97a20c81cfe4d9090ac0a24f3bbf08f265eb71d",
         strip_prefix = "pybind11-2.4.3",
         build_file = clean_dep("//third_party:pybind11.BUILD"),
+        patch_file = "@//third_party:pybind11_cstdint.patch",
         system_build_file = clean_dep("//third_party/systemlibs:pybind11.BUILD"),
     )

diff --git a/third_party/aws/workspace.bzl b/third_party/aws/workspace.bzl
index dca36c87e6f..ef26563fc2b 100644
--- a/third_party/aws/workspace.bzl
+++ b/third_party/aws/workspace.bzl
@@ -15,6 +15,7 @@ def repo():
         sha256 = "758174f9788fed6cc1e266bcecb20bf738bd5ef1c3d646131c9ed15c2d6c5720",
         strip_prefix = "aws-sdk-cpp-1.7.336",
         build_file = "//third_party/aws:BUILD.bazel",
+        patch_file = "@//third_party:aws_cstdint.patch",
     )
 
     third_party_http_archive(
 
diff --git a/tensorflow/workspace.bzl b/tensorflow/workspace.bzl
index 267f94c916d..20c07a93e89 100644
--- a/tensorflow/workspace.bzl
+++ b/tensorflow/workspace.bzl
@@ -738,6 +738,7 @@ def tf_repositories(path_prefix = "", tf_repo_name = ""):
         name = "boringssl",
         sha256 = "a9c3b03657d507975a32732f04563132b4553c20747cec6dc04de475c8bdf29f",
         strip_prefix = "boringssl-80ca9f9f6ece29ab132cce4cf807a9465a18cfac",
+        patch_file = "@//third_party:boringssl_no_werror.patch",
         system_build_file = clean_dep("//third_party/systemlibs:boringssl.BUILD"),
         urls = [
             "https://storage.googleapis.com/mirror.tensorflow.org/github.com/google/boringssl/archive/80ca9f9f6ece29ab132cce4cf807a9465a18cfac.tar.gz",

diff --git a/third_party/flatbuffers/workspace.bzl b/third_party/flatbuffers/workspace.bzl
index bd3670ca446..1f1391c5c9f 100644
--- a/third_party/flatbuffers/workspace.bzl
+++ b/third_party/flatbuffers/workspace.bzl
@@ -12,6 +12,7 @@ def repo():
             "https://github.com/google/flatbuffers/archive/v1.12.0.tar.gz",
         ],
         build_file = "//third_party/flatbuffers:BUILD.bazel",
+        patch_file = "@//third_party:flatbuffers_no_absl_string_view.patch",
         system_build_file = "//third_party/flatbuffers:BUILD.system",
         delete = ["build_defs.bzl"],
         link_files = {

diff --git a/third_party/ruy/workspace.bzl b/third_party/ruy/workspace.bzl
index c0a2c0c89bb..d469c467cb7 100644
--- a/third_party/ruy/workspace.bzl
+++ b/third_party/ruy/workspace.bzl
@@ -12,4 +12,5 @@ def repo():
             "https://github.com/google/ruy/archive/5bb02fbf90824c2eb6cd7418f766c593106a332b.zip",
         ],
         build_file = "//third_party/ruy:BUILD",
+        patch_file = "@//third_party:ruy_limits.patch",
     )
'''
tf_patch.write_text(s)

net_utils = Path("monolith/native_training/runtime/ops/net_utils.cc")
s = net_utils.read_text()
if "#include <string>" not in s:
    s = s.replace("#include <map>\n", "#include <map>\n#include <string>\n", 1)
    net_utils.write_text(s)

snappy = Path("monolith/native_training/data/training_instance/cc/snappy_inputbuffer.cc")
s = snappy.read_text()
if '#include "glog/logging.h"' in s:
    s = s.replace('#include <sys/time.h>\n#include "glog/logging.h"\n\n#include "monolith/native_training/data/training_instance/cc/snappy_inputbuffer.h"\n',
                  '#include <sys/time.h>\n\n#include "monolith/native_training/data/training_instance/cc/snappy_inputbuffer.h"\n', 1)
if '#include "tensorflow/core/platform/errors.h"' not in s:
    s = s.replace('#include "monolith/native_training/data/training_instance/cc/snappy_inputbuffer.h"\n',
                  '#include "monolith/native_training/data/training_instance/cc/snappy_inputbuffer.h"\n\n#include "tensorflow/core/platform/errors.h"\n#include "tensorflow/core/platform/logging.h"\n', 1)
if 'LOG_IF(ERROR, !ReadFromFile().ok()) << "Failed to read ahead from HDFS."; ' in s:
    raise SystemExit("Unexpected snappy LOG_IF spacing")
if 'LOG_IF(ERROR, !ReadFromFile().ok()) << "Failed to read ahead from HDFS.";' in s:
    s = s.replace(
        '  LOG_IF(ERROR, !ReadFromFile().ok()) << "Failed to read ahead from HDFS.";',
        '  Status read_status = ReadFromFile();\n  if (!read_status.ok()) {\n    LOG(ERROR) << "Failed to read ahead from HDFS: " << read_status;\n  }',
        1,
    )
snappy.write_text(s)

gitignore = Path(".gitignore")
s = gitignore.read_text()
for entry in [
    "/.bazel-cache/",
    "/.conda-pkgs/",
    "/.downloads/",
    "/.pip-cache/",
    "/.tools/",
    "/.venv-monolith/",
]:
    if entry not in s:
        s += entry + "\n"
gitignore.write_text(s)
PY

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
