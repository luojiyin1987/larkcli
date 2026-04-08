#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Source helpers without running the backup entrypoint.
source "$SCRIPT_DIR/lark-backup.sh"

assert_eq() {
  local expected="$1"
  local actual="$2"
  local message="$3"

  if [[ "$expected" != "$actual" ]]; then
    echo "assertion failed: $message" >&2
    echo "expected: $expected" >&2
    echo "actual:   $actual" >&2
    exit 1
  fi
}

assert_eq "2" "$(index_width 0)" "empty collections keep two-digit compatibility"
assert_eq "2" "$(index_width 9)" "single-digit totals still render two digits"
assert_eq "2" "$(index_width 99)" "double-digit totals stay two digits"
assert_eq "3" "$(index_width 100)" "three-digit totals widen to three digits"
assert_eq "4" "$(index_width 1000)" "four-digit totals widen to four digits"

assert_eq "01" "$(format_index 1 9)" "single-digit totals stay zero-padded"
assert_eq "99" "$(format_index 99 99)" "two-digit totals do not over-pad"
assert_eq "001" "$(format_index 1 100)" "three-digit totals pad to width three"
assert_eq "020" "$(format_index 20 100)" "intermediate indices share the same width"
assert_eq "100" "$(format_index 100 100)" "last index keeps natural width"
assert_eq "0007" "$(format_index 7 1000)" "four-digit totals pad to width four"

known_rows_json="$(mktemp)"
TMP_FILES+=("$known_rows_json")
cat >"$known_rows_json" <<'EOF'
{"data":{"records":{"rows":[["Alice"],["Bob"]]}}}
EOF
assert_eq $'2\tfalse\t0' "$(record_list_page_info "$known_rows_json")" "legacy nested record-list shape is supported"

known_flat_json="$(mktemp)"
TMP_FILES+=("$known_flat_json")
cat >"$known_flat_json" <<'EOF'
{"data":{"data":[["Alice"],["Bob"],["Carol"]]}}
EOF
assert_eq $'3\tfalse\t0' "$(record_list_page_info "$known_flat_json")" "flat record-list shape is supported"

unknown_shape_json="$(mktemp)"
TMP_FILES+=("$unknown_shape_json")
cat >"$unknown_shape_json" <<'EOF'
{"data":{"items":[{"name":"unexpected"}]}}
EOF
if ( record_list_page_info "$unknown_shape_json" >/dev/null 2>&1 ); then
  echo "assertion failed: unknown record-list shape must fail fast" >&2
  exit 1
fi

table_list_json="$(mktemp)"
TMP_FILES+=("$table_list_json")
cat >"$table_list_json" <<'EOF'
{"data":{"items":[{"table_id":"tbl_1"},{"table_id":"tbl_2"}],"has_more":true,"total":12}}
EOF
assert_eq $'2\ttrue\t12' "$(table_list_page_info "$table_list_json")" "table-list pagination metadata is parsed in one pass"

echo "lark-backup smoke test OK"
