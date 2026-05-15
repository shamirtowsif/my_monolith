# Monolith Local Demo

Trains and exports a TensorFlow-based recommendation model using sparse feature embeddings.

## Run The Demo

First try the prepared local run script:

```bash
bash RUN_DEMO.sh
```

This uses the existing local Python environment, Bazel binary, and Bazel cache in this folder.

## If That Does Not Work

Start from a clean copy of the original project:

```bash
git clone https://github.com/bytedance/monolith.git
cd monolith
```

Then run the fresh setup script:

```bash
bash FRESH_CLONE_SETUP_AND_RUN.sh
```

That script creates the local Python 3.8 environment, downloads Bazel 3.1.0, applies the needed compatibility fixes, installs runtime dependencies, builds the project, and runs the demo.

After the fresh setup succeeds once, future runs can use:

```bash
bash RUN_DEMO.sh
```
