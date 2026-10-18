#!/usr/bin/env bash
# Gate coverage baris minimum (default 80%) dari laporan lcov.
#
# Pakai:
#   flutter test --coverage
#   bash tool/check_coverage.sh                    # ambang 80%
#   COVERAGE_MIN=85 bash tool/check_coverage.sh    # ambang kustom
#   bash tool/check_coverage.sh path/ke/lcov.info  # berkas lain
#
# Keluar dengan kode 1 bila di bawah ambang (dipakai sebagai gate CI).
set -euo pipefail

LCOV="${1:-coverage/lcov.info}"
THRESHOLD="${COVERAGE_MIN:-80}"

if [ ! -f "$LCOV" ]; then
  echo "check_coverage: berkas '$LCOV' tidak ditemukan. Jalankan 'flutter test --coverage' dulu." >&2
  exit 1
fi

if ! command -v lcov >/dev/null 2>&1; then
  echo "check_coverage: 'lcov' tidak terpasang (brew install lcov / apt-get install lcov)." >&2
  exit 1
fi

lcov --summary "$LCOV"
PCT="$(lcov --summary "$LCOV" 2>&1 | awk '/lines/ { gsub(/%/,""); print $2 }')"
echo "Line coverage: ${PCT}% (ambang ${THRESHOLD}%)"

awk -v p="$PCT" -v t="$THRESHOLD" 'BEGIN {
  if (p+0 < t+0) {
    printf "GAGAL: coverage %s%% < %s%%\n", p, t
    exit 1
  }
  printf "LULUS: coverage %s%% >= %s%%\n", p, t
}'