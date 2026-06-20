#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$PROJECT_DIR/.dart_tool/ios_preview"
DEVICE_UDID="${IOS_SIMULATOR_UDID:-}"
PORT="${IOS_PREVIEW_PORT:-3100}"
RUN_FLUTTER=1

usage() {
  cat <<'EOF'
Usage: tools/qa/ios_preview.sh [options]

Deploy the Flutter app to an iOS 26 Simulator and expose a browser preview
through serve-sim, matching the Build iOS Apps simulator-browser workflow.

Options:
  --device <udid>        Use a specific Simulator UDID.
  --port <port>          serve-sim port. Defaults to 3100.
  --no-flutter-run       Skip flutter run and only start the simulator preview.
  -h, --help             Show this help.

Environment:
  DEVELOPER_DIR          Defaults to /Applications/Xcode-beta.app/Contents/Developer when present.
  IOS_SIMULATOR_UDID     Same as --device.
  IOS_PREVIEW_PORT       Same as --port.
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --device)
      DEVICE_UDID="${2:-}"
      shift 2
      ;;
    --port)
      PORT="${2:-}"
      shift 2
      ;;
    --no-flutter-run)
      RUN_FLUTTER=0
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 64
      ;;
  esac
done

if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode-beta.app/Contents/Developer ]]; then
  export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
fi

if ! command -v xcrun >/dev/null 2>&1; then
  echo "xcrun is required. Install Xcode or set DEVELOPER_DIR." >&2
  exit 69
fi

if ! command -v flutter >/dev/null 2>&1; then
  echo "flutter is required on PATH." >&2
  exit 69
fi

if [[ -z "$DEVICE_UDID" ]]; then
  DEVICE_UDID="$(
    /usr/bin/python3 - <<'PY'
import json
import subprocess

raw = subprocess.check_output(
    ["xcrun", "simctl", "list", "-j", "devices", "available"],
    text=True,
)
devices_by_runtime = json.loads(raw)["devices"]
candidates = []
for runtime, devices in devices_by_runtime.items():
    if "iOS-26" not in runtime:
        continue
    for device in devices:
        name = device.get("name", "")
        if not name.startswith("iPhone"):
            continue
        candidates.append(device)

booted = [d for d in candidates if d.get("state") == "Booted"]
preferred = booted or candidates
for device in preferred:
    if device.get("name") == "iPhone 17 Pro":
        print(device["udid"])
        raise SystemExit
if preferred:
    print(preferred[0]["udid"])
PY
  )"
fi

if [[ -z "$DEVICE_UDID" ]]; then
  echo "No available iOS 26 iPhone Simulator found." >&2
  exit 69
fi

mkdir -p "$LOG_DIR"

echo "Using Simulator: $DEVICE_UDID"
echo "Using DEVELOPER_DIR: ${DEVELOPER_DIR:-$(xcode-select -p)}"

xcrun simctl boot "$DEVICE_UDID" >/dev/null 2>&1 || true
xcrun simctl bootstatus "$DEVICE_UDID" -b

cleanup_serve_sim() {
  npx --yes serve-sim@latest --kill "$DEVICE_UDID" >/dev/null 2>&1 || true
  pkill -f "serve-sim.*$DEVICE_UDID" >/dev/null 2>&1 || true
}

FLUTTER_PID=""
cleanup() {
  cleanup_serve_sim
  if [[ -n "$FLUTTER_PID" ]] && kill -0 "$FLUTTER_PID" >/dev/null 2>&1; then
    kill "$FLUTTER_PID" >/dev/null 2>&1 || true
    wait "$FLUTTER_PID" >/dev/null 2>&1 || true
  fi
}
trap cleanup EXIT INT TERM HUP

cd "$PROJECT_DIR"

if [[ "$RUN_FLUTTER" -eq 1 ]]; then
  echo "Starting flutter run..."
  flutter run -d "$DEVICE_UDID" --debug >"$LOG_DIR/flutter-run.log" 2>&1 &
  FLUTTER_PID="$!"

  FLUTTER_READY=0
  for _ in $(seq 1 180); do
    if ! kill -0 "$FLUTTER_PID" >/dev/null 2>&1; then
      echo "flutter run exited early. See $LOG_DIR/flutter-run.log" >&2
      tail -n 80 "$LOG_DIR/flutter-run.log" >&2 || true
      exit 1
    fi
    if grep -Eq "Flutter run key commands|An Observatory debugger|The Flutter DevTools debugger" "$LOG_DIR/flutter-run.log"; then
      FLUTTER_READY=1
      break
    fi
    sleep 1
  done

  if [[ "$FLUTTER_READY" -ne 1 ]]; then
    echo "Timed out waiting for flutter run. See $LOG_DIR/flutter-run.log" >&2
    tail -n 80 "$LOG_DIR/flutter-run.log" >&2 || true
    exit 1
  fi
fi

cleanup_serve_sim
echo "Starting serve-sim preview on http://localhost:$PORT"
echo "Press Ctrl-C to stop preview and clean up this simulator mirror."
npx --yes serve-sim@latest "$DEVICE_UDID" --port "$PORT"
