from __future__ import annotations
import re
import shutil
from pathlib import Path
import argparse


def is_within(child: Path, parent: Path) -> bool:
    try:
        child.resolve().relative_to(parent.resolve())
        return True
    except Exception:
        return False


def posix_relpath(from_path: Path, to_path: Path) -> str:
    return Path(shutil.os.path.relpath(to_path, start=from_path)).as_posix()


def find_segment_after(path: Path, segment: str) -> Path | None:
    parts = [p for p in path.resolve().parts]
    try:
        idx = [s.lower() for s in parts].index(segment.lower())
    except ValueError:
        return None
    return Path(*parts[idx + 1:]) if idx + 1 < len(parts) else Path()


def rewrite_resource_line(
        line: str,
        src_file: Path,
        src_root: Path,
        dst_file: Path,
        dst_root: Path,
        blr_resources_root: Path,
) -> str:
    m = re.match(r"^(\s*(?:[Rr]esource|[Ll]ibrary))(\s+)(\S+|\x22.*?\x22)(.*)$", line)
    if not m:
        return line

    lead_keyword, spacing, path_token, trailing = m.groups()
    raw_path = path_token.strip()

    quoted = False
    if (raw_path.startswith('"') and raw_path.endswith('"')) or (
            raw_path.startswith("'") and raw_path.endswith("'")
    ):
        quoted = True
        quote_char = raw_path[0]
        raw_path = raw_path[1:-1]
    else:
        quote_char = '"'

    if '${' in raw_path or '%{' in raw_path:
        return line

    if ('/' not in raw_path and '\\' not in raw_path and not raw_path.lower().endswith(('.robot', '.py'))):
        return line

    if raw_path.startswith('resources/') and not raw_path.startswith(('../resources/', '../../resources/')):
        return line
    try:
        resolved = (src_file.parent / Path(raw_path)).resolve()
    except Exception:
        return line

    new_target: Path | None = None
    if is_within(resolved, src_root):
        after_5get = find_segment_after(resolved, '5GET_BLR')

        if after_5get is not None:
            after_parts = [p for p in after_5get.parts]
            lower_parts = [p.lower() for p in after_parts]
            if 'resources' in lower_parts:
                res_idx = lower_parts.index('resources')
                tail_after_resources = Path(*after_parts[res_idx + 1:])

                before_resources = Path(*after_parts[:res_idx])
                dest_candidate = (dst_root / before_resources / 'resources' / tail_after_resources)

                if dest_candidate.exists():
                    new_target = dest_candidate
                else:
                    if len(before_resources.parts) > 0:
                        return line
                    else:
                        new_target = blr_resources_root / tail_after_resources
            else:
                return line
        else:
            return line
    elif is_within(resolved, blr_resources_root):
        tail_after_resources = find_segment_after(resolved, 'resources')
        if tail_after_resources is not None:
            new_target = blr_resources_root / tail_after_resources
        else:
            new_target = resolved
    else:
        return line
    if new_target is None:
        return line
    new_rel = posix_relpath(dst_file.parent, new_target)
    new_path_token = f'{quote_char}{new_rel}{quote_char}' if quoted else new_rel
    return f"{lead_keyword}{spacing}{new_path_token}{trailing}"


def process_robot_file(
        src_file: Path, dst_file: Path, src_root: Path, dst_root: Path, blr_resources_root: Path
) -> None:
    dst_file.parent.mkdir(parents=True, exist_ok=True)

    text = src_file.read_text(encoding='utf-8', errors='ignore')
    new_lines = []
    for line in text.splitlines(keepends=False):
        if re.match(r"^\s*(?:[Rr]esource|[Ll]ibrary)\s+", line):
            new_line = rewrite_resource_line(
                line=line,
                src_file=src_file,
                src_root=src_root,
                dst_file=dst_file,
                dst_root=dst_root,
                blr_resources_root=blr_resources_root,
            )
            new_lines.append(new_line)
        else:
            new_lines.append(line)

    dst_file.write_text("\n".join(new_lines) + ("\n" if text.endswith("\n") else ""), encoding='utf-8')


def copy_folder_recursively(src_folder: Path, dst_folder: Path, src_root: Path, dst_root: Path,
                            blr_resources_root: Path) -> None:
    """Copy entire folder structure and process all robot files."""
    dst_folder.mkdir(parents=True, exist_ok=True)

    for item in src_folder.iterdir():
        if item.is_file():
            dst_file = dst_folder / item.name
            if dst_file.exists():
                continue
            if item.suffix.lower() == '.robot' or item.suffix.lower() == '.resource':
                process_robot_file(item, dst_file, src_root, dst_root, blr_resources_root)
            else:
                shutil.copy2(item, dst_file)
        elif item.is_dir():
            sub_dst = dst_folder / item.name
            copy_folder_recursively(item, sub_dst, src_root, dst_root, blr_resources_root)


def main() -> None:
    parser = argparse.ArgumentParser(
        description='Copy .robot file(s) or entire folder(s) and rewrite Resource imports.')
    parser.add_argument('destination_folder', help='Destination folder (e.g., corresponding suite under T09)')
    parser.add_argument('source_paths', nargs='+', help='One or more source .robot files or folders under 5GET_BLR')
    args = parser.parse_args()

    dst_dir = Path(args.destination_folder).resolve()
    source_paths = [Path(p).resolve() for p in args.source_paths]
    missing = [str(p) for p in source_paths if not p.exists()]
    if missing:
        raise SystemExit(f"Source path(s) not found: {', '.join(missing)}")
    dst_dir.mkdir(parents=True, exist_ok=True)
    dst_root = next((p for p in dst_dir.parents if p.name.lower() == 't09'), None)
    if dst_root is None:
        dst_root = dst_dir
    try:
        project_root = Path(__file__).resolve().parents[3]
    except Exception:
        project_root = Path.cwd()
    blr_resources_root = project_root / 'Bangalore' / 'resources'
    if not blr_resources_root.exists():
        raise SystemExit(f"Bangalore resources not found: {blr_resources_root}")

    for src_path in source_paths:
        src_root = next((p for p in src_path.parents if p.name.lower() == '5get_blr'), None)
        if src_root is None and src_path.parents:
            src_root = src_path.parents[0]

        if src_path.is_file():
            if src_path.suffix.lower() != '.robot':
                raise SystemExit(f"Source file is not a .robot file: {src_path}")
            dst_file = (dst_dir / src_path.name).resolve()
            if dst_file.exists():
                continue
            process_robot_file(src_path, dst_file, src_root, dst_root, blr_resources_root)
        elif src_path.is_dir():
            if dst_dir.name.lower() == 't09':
                dst_subfolder = dst_dir / src_path.name
                copy_folder_recursively(src_path, dst_subfolder, src_root, dst_root, blr_resources_root)
            else:
                copy_folder_recursively(src_path, dst_dir, src_root, dst_root, blr_resources_root)
        else:
            raise SystemExit(f"Source path is neither a file nor directory: {src_path}")


if __name__ == '__main__':
    main()
