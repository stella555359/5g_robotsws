import io
import os
import re
import tarfile
import zipfile
from datetime import datetime
from typing import List, Tuple, Optional, Dict, Any

import sos_validation_config as cfg


def _now_stamp() -> str:
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def _default_report_path(tar_path: str) -> str:
    base_dir = os.path.dirname(os.path.abspath(tar_path))
    base_name = os.path.splitext(os.path.basename(tar_path))[0]
    return os.path.join(base_dir, f"{base_name}_validation_report.txt")


def validate_sos_report(
    tar_path: str,
    report_path: Optional[str] = None,
) -> Tuple[bool, List[str], str]:

    errors: List[str] = []
    report_items: List[Dict[str, Any]] = []

    archive_abs = os.path.abspath(tar_path)
    report_path = report_path or _default_report_path(tar_path)

    try:
        tf = tarfile.open(tar_path, mode="r:gz")
    except (tarfile.ReadError, FileNotFoundError) as e:
        _write_report(
            report_path,
            archive_abs,
            [
                {
                    "check": "OPEN_TAR",
                    "expected": archive_abs,
                    "status": "ERROR",
                    "note": f"Cannot open tar: {e}",
                }
            ],
        )
        return False, [f"Cannot open tar: {e}"], report_path

    def norm(name: str) -> str:
        name = name.replace("\\", "/")
        while name.startswith("./"):
            name = name[2:]
        return name

    members_map = {norm(m.name): m for m in tf.getmembers()}

    def base_alternatives(path: str) -> List[str]:
        if not getattr(cfg, "ACCEPT_BOTH_BASES", False):
            return [path]
        bases = list(getattr(cfg, "BASE_DIRS", ("UEAPP1", "UEAPP")))
        for b in bases:
            prefix = f"{b}/"
            if path.startswith(prefix):
                tail = path[len(prefix):]
                return [f"{alt}/{tail}" for alt in bases]
        return [path]

    def find_member_any(paths: List[str]):
        for p in paths:
            m = members_map.get(p)
            if m:
                return m, p
        if not cfg.ALLOW_PREFIX_MATCH:
            return None, None
        for full_name, mem in members_map.items():
            for p in paths:
                if full_name.endswith(p):
                    return mem, full_name
        return None, None

    def get_regular_any(paths: List[str]):
        mem, actual = find_member_any(paths)
        if mem and mem.isfile():
            return mem, actual
        return None, None

    def _detect_present_base(mmap) -> Optional[str]:
        bases = list(getattr(cfg, "BASE_DIRS", ("UEAPP1", "UEAPP")))
        for b in bases:
            prefix = f"{b}/"
            if any(name.startswith(prefix) for name in mmap.keys()):
                return b
        return None

    def _ueapp_listing(mmap, max_depth: int = 4) -> List[str]:
        base = _detect_present_base(mmap)
        if not base:
            return ["# UEAPP directory listing: UEAPP1/ or UEAPP/ base found in archive"]

        prefix = f"{base}/"
        entries = []

        for name, mem in mmap.items():
            if not name.startswith(prefix):
                continue
            rel = name[len(prefix):]
            if not rel:
                continue
            parts = [p for p in rel.split("/") if p]
            depth = len(parts)
            if depth == 0 or depth > max_depth:
                continue

            if mem.isdir():
                entries.append((name, True, 0))
            elif mem.isfile():
                entries.append((name, False, getattr(mem, "size", 0)))

        if not entries:
            return [f"# UEAPP directory listing (up to depth {max_depth} from base '{base}'): no entries"]

        entries.sort(key=lambda x: x[0])

        lines = [f"# UEAPP directory listing (up to depth {max_depth} from base '{base}')"]
        for full_name, is_dir, size in entries:
            if is_dir:
                lines.append(f"./{full_name}: (dir)")
            else:
                lines.append(f"./{full_name}: {size} bytes")
        return lines

    snapshot_alts = base_alternatives(cfg.ZIP_SNAPSHOT_PATH)
    m_snapshot, actual_snapshot_name = get_regular_any(snapshot_alts)
    if not m_snapshot:
        errors.append(f"Missing required file: one-of({', '.join(snapshot_alts)})")
        report_items.append({
            "check": "ZIP_SNAPSHOT",
            "expected": f"one-of({', '.join(snapshot_alts)})",
            "status": "MISSING",
            "note": "Required zip not found",
        })
    else:
        try:
            fp = tf.extractfile(m_snapshot)
            if fp is None:
                errors.append(f"Cannot read {actual_snapshot_name} from tar.")
                report_items.append({
                    "check": "ZIP_SNAPSHOT",
                    "expected": f"one-of({', '.join(snapshot_alts)})",
                    "actual": actual_snapshot_name,
                    "status": "ERROR",
                    "note": "extractfile() returned None",
                })
            else:
                data = fp.read()
                with zipfile.ZipFile(io.BytesIO(data)) as zf:
                    file_entries = [zi for zi in zf.infolist() if not zi.filename.endswith("/")]
                    if len(file_entries) == 0:
                        errors.append(f"{actual_snapshot_name} contains zero files.")
                        report_items.append({
                            "check": "ZIP_SNAPSHOT",
                            "expected": f"one-of({', '.join(snapshot_alts)})",
                            "actual": actual_snapshot_name,
                            "status": "INVALID",
                            "size_bytes": m_snapshot.size,
                            "note": "Zip valid but contains zero files",
                        })
                    else:
                        report_items.append({
                            "check": "ZIP_SNAPSHOT",
                            "expected": f"one-of({', '.join(snapshot_alts)})",
                            "actual": actual_snapshot_name,
                            "status": "FOUND",
                            "size_bytes": m_snapshot.size,
                            "note": f"{len(file_entries)} file(s) inside zip",
                        })
        except zipfile.BadZipFile:
            errors.append(f"{actual_snapshot_name} is not a valid zip file (corrupt).")
            report_items.append({
                "check": "ZIP_SNAPSHOT",
                "expected": f"one-of({', '.join(snapshot_alts)})",
                "actual": actual_snapshot_name,
                "status": "INVALID",
                "size_bytes": m_snapshot.size if m_snapshot else None,
                "note": "BadZipFile: zip is corrupt",
            })

    for canonical in cfg.REQUIRED_CONF_FILES:
        alts = base_alternatives(canonical)
        mem, actual_name = get_regular_any(alts)
        if not mem:
            errors.append(f"Missing required file: one-of({', '.join(alts)})")
            report_items.append({
                "check": "CONF_FILE",
                "expected": f"one-of({', '.join(alts)})",
                "status": "MISSING",
                "note": "Required conf file not found",
            })
        else:
            report_items.append({
                "check": "CONF_FILE",
                "expected": f"one-of({', '.join(alts)})",
                "actual": actual_name,
                "status": "FOUND",
                "size_bytes": mem.size,
            })

    if cfg.TARGETBD_REGEX.startswith('^UEAPP1/'):
        targetbd_rx = re.compile(cfg.TARGETBD_REGEX.replace(r'^UEAPP1/', r'^(UEAPP1|UEAPP)/'))
    else:
        targetbd_rx = re.compile(r'^(UEAPP1|UEAPP)/conf/TargetBD_5G_AP_[0-9]+_[0-9]+_[0-9]+\.xml$')

    targetbd_found = None
    for name, mem in members_map.items():
        if not mem.isfile():
            continue
        if targetbd_rx.match(name):
            targetbd_found = name
            break
        if cfg.ALLOW_PREFIX_MATCH:
            parts = name.split("/")
            for base in getattr(cfg, "BASE_DIRS", ("UEAPP1", "UEAPP")):
                if base in parts:
                    idx = parts.index(base)
                    suffix = "/".join(parts[idx:])
                    if targetbd_rx.match(suffix):
                        targetbd_found = name
                        break
            if targetbd_found:
                break

    if not targetbd_found:
        exp_disp = "regex(^(UEAPP1|UEAPP)/conf/TargetBD_5G_AP_[0-9]+_[0-9]+_[0-9]+\\.xml$)"
        report_items.append({
            "check": "TARGETBD",
            "expected": exp_disp,
            "status": "MISSING",
            "note": "No member matched TargetBD regex under UEAPP1 or UEAPP",
        })
        errors.append(f"Missing required TargetBD file matching {exp_disp}")
    else:
        mem = members_map[targetbd_found]
        report_items.append({
            "check": "TARGETBD",
            "expected": "regex(^(UEAPP1|UEAPP)/conf/TargetBD_5G_AP_[0-9]+_[0-9]+_[0-9]+\\.xml$)",
            "actual": targetbd_found,
            "status": "FOUND",
            "size_bytes": mem.size,
        })

    for canonical in cfg.REQUIRED_NONEMPTY_FILES:
        alts = base_alternatives(canonical)
        mem, actual_name = get_regular_any(alts)
        if not mem:
            errors.append(f"Missing required file: one-of({', '.join(alts)})")
            report_items.append({
                "check": "NONEMPTY_FILE",
                "expected": f"one-of({', '.join(alts)})",
                "status": "MISSING",
                "note": "Required non-empty file not found",
            })
        else:
            if mem.size <= 0:
                errors.append(f"{actual_name} is empty (0 bytes).")
                report_items.append({
                    "check": "NONEMPTY_FILE",
                    "expected": f"one-of({', '.join(alts)})",
                    "actual": actual_name,
                    "status": "EMPTY",
                    "size_bytes": mem.size,
                })
            else:
                report_items.append({
                    "check": "NONEMPTY_FILE",
                    "expected": f"one-of({', '.join(alts)})",
                    "actual": actual_name,
                    "status": "FOUND",
                    "size_bytes": mem.size,
                })

    listing_lines = _ueapp_listing(members_map, max_depth=4)

    tf.close()

    ok = len(errors) == 0
    _write_report(report_path, archive_abs, report_items, extra_tail=listing_lines)
    return ok, errors, report_path


def _write_report(
    report_path: str,
    archive_abs: str,
    items: List[Dict[str, Any]],
    extra_tail: Optional[List[str]] = None
) -> None:
    """
    Write a plain text report of validation results.
    """
    lines: List[str] = []
    lines.append("# SosReport Validation Report")
    lines.append(f"# Archive: {archive_abs}")
    lines.append(f"# Generated: {_now_stamp()}")
    lines.append("")

    def to_virtual_abs(member_name: Optional[str]) -> Optional[str]:
        if not member_name:
            return None
        return f"{archive_abs}:{'/' if not member_name.startswith('/') else ''}{member_name}"

    for item in items:
        check = item.get("check", "UNKNOWN")
        status = item.get("status", "UNKNOWN")
        expected = item.get("expected")
        actual = item.get("actual")
        size = item.get("size_bytes")
        note = item.get("note")

        expected_disp = expected
        virtual_actual = to_virtual_abs(actual)

        lines.append(f"[{status}] {check}")
        if expected_disp:
            lines.append(f"  expected: {expected_disp}")
        if virtual_actual:
            lines.append(f"  actual:   {virtual_actual}")
        if size is not None:
            lines.append(f"  size:     {size} bytes")
        if note:
            lines.append(f"  note:     {note}")
        lines.append("")

    # Append UEAPP listing at the end
    if extra_tail:
        lines.extend(extra_tail)

    os.makedirs(os.path.dirname(os.path.abspath(report_path)), exist_ok=True)
    with open(report_path, "w", encoding="utf-8") as f:
        f.write("\n".join(lines))


if __name__ == "__main__":
    import sys
    tar_in = sys.argv[1]
    out = sys.argv[2] if len(sys.argv) > 2 else None
    ok, errs, rpt = validate_sos_report(tar_in, report_path=out)
    if ok:
        print(f"Validation PASSED. Report: {rpt}")
        sys.exit(0)
    else:
        print(f"Validation FAILED. Report: {rpt}")
        for e in errs:
            print(" -", e)
        sys.exit(1)
