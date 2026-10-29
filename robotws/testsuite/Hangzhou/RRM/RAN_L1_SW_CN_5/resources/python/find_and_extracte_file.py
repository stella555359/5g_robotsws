import os
import re
import zipfile
import tarfile
import tempfile
import lzma
import gzip
import shutil
from datetime import datetime, timedelta


def is_compressed_file(file_name):
    return file_name.endswith(
        ('.zip', '.tar', '.gz', '.tgz', '.txz', '.xz', '.tar.gz')
    )


def is_valid_archive_file(file_path):
    """Validate archive by signature/reader support, not only by extension."""
    lower = file_path.lower()
    try:
        if lower.endswith('.zip'):
            return zipfile.is_zipfile(file_path)
        if lower.endswith('.tar') or lower.endswith('.tgz') or lower.endswith('.txz') or lower.endswith('.tar.gz'):
            return tarfile.is_tarfile(file_path)
        if lower.endswith('.xz'):
            with open(file_path, 'rb') as f:
                return f.read(6) == b'\xfd7zXZ\x00'
        if lower.endswith('.gz') and not lower.endswith('.tar.gz'):
            with open(file_path, 'rb') as f:
                return f.read(2) == b'\x1f\x8b'
    except OSError:
        return False
    return False


def should_recurse_archive(file_name, abs_path):
    return is_compressed_file(file_name) and is_valid_archive_file(abs_path)


def is_in_any_parent(parent_stack, target_parent_zips):
    if not target_parent_zips:
        return True
    return any(
        any(parent_zip in parent for parent in parent_stack)
        for parent_zip in target_parent_zips
    )


def search_and_extract_files_from_archive(
    archive_path,
    target_patterns,
    output_dir,
    target_parent_zips=None,
    parent_stack=None,
    result=None,
    virtual_path=""
):
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    patterns_list = (
        target_patterns if isinstance(target_patterns, list)
        else [target_patterns]
    )
    if result is None:
        result = {pattern: {} for pattern in patterns_list}
    if parent_stack is None:
        parent_stack = []

    def match_and_extract(file_name, abs_path):
        for pattern in patterns_list:
            if re.search(pattern, file_name):
                dest_path = os.path.join(output_dir, file_name)
                shutil.copy2(abs_path, dest_path)
                file_size_bytes = os.path.getsize(abs_path)
                file_size_kb = round(file_size_bytes / 1024, 2)
                result[pattern][file_name] = {
                    "size": file_size_kb,
                    "output_path": os.path.abspath(dest_path),
                    "original_path": os.path.join(virtual_path, file_name)
                }

    if os.path.isdir(archive_path):
        for root, dirs, files in os.walk(archive_path):
            for name in files:
                abs_path = os.path.join(root, name)
                if should_recurse_archive(name, abs_path):
                    search_and_extract_files_from_archive(
                        abs_path, patterns_list, output_dir,
                        target_parent_zips, parent_stack, result,
                        os.path.join(virtual_path, name)
                    )
                elif is_in_any_parent(parent_stack, target_parent_zips):
                    match_and_extract(name, abs_path)
    elif zipfile.is_zipfile(archive_path):
        try:
            with zipfile.ZipFile(archive_path, 'r') as z, tempfile.TemporaryDirectory() as temp_dir:
                parent_stack.append(os.path.basename(archive_path))
                z.extractall(temp_dir)
                for root, dirs, files in os.walk(temp_dir):
                    for name in files:
                        abs_path = os.path.join(root, name)
                        if should_recurse_archive(name, abs_path):
                            search_and_extract_files_from_archive(
                                abs_path, patterns_list, output_dir,
                                target_parent_zips, parent_stack, result,
                                os.path.join(virtual_path, name)
                            )
                        elif is_in_any_parent(parent_stack, target_parent_zips):
                            match_and_extract(name, abs_path)
                parent_stack.pop()
        except zipfile.BadZipFile:
            print(f"[ERROR] can't extract: {archive_path}, maybe ZIP file is corrupted.")

    elif tarfile.is_tarfile(archive_path):
        try:
            with tarfile.open(archive_path, 'r:*') as tar, tempfile.TemporaryDirectory() as temp_dir:
                parent_stack.append(os.path.basename(archive_path))
                try:
                    _safe_extract_tar(tar, temp_dir)
                    for root, dirs, files in os.walk(temp_dir):
                        for name in files:
                            abs_path = os.path.join(root, name)
                            if should_recurse_archive(name, abs_path):
                                search_and_extract_files_from_archive(
                                    abs_path, patterns_list, output_dir,
                                    target_parent_zips, parent_stack, result,
                                    os.path.join(virtual_path, name)
                                )
                            elif is_in_any_parent(parent_stack, target_parent_zips):
                                match_and_extract(name, abs_path)
                finally:
                    parent_stack.pop()
        except (tarfile.TarError, OSError, PermissionError) as e:
            print(f"[ERROR] can't extract tar: {archive_path}, reason: {e}")
    elif archive_path.endswith('.xz'):
        with tempfile.TemporaryDirectory() as temp_dir:
            out_file = os.path.join(
                temp_dir, os.path.basename(archive_path).replace('.xz', '')
            )
            with lzma.open(archive_path, 'rb') as xz_file, open(out_file, 'wb') as out:
                shutil.copyfileobj(xz_file, out)
            if is_valid_archive_file(out_file):
                parent_stack.append(os.path.basename(archive_path))
                search_and_extract_files_from_archive(
                    out_file, patterns_list, output_dir,
                    target_parent_zips, parent_stack, result,
                    os.path.join(virtual_path, os.path.basename(out_file))
                )
                parent_stack.pop()
            elif is_in_any_parent(parent_stack, target_parent_zips):
                match_and_extract(os.path.basename(out_file), out_file)
    elif archive_path.endswith('.gz') and not archive_path.endswith('.tar.gz'):
        with tempfile.TemporaryDirectory() as temp_dir:
            out_file = os.path.join(
                temp_dir, os.path.basename(archive_path).replace('.gz', '')
            )
            with gzip.open(archive_path, 'rb') as gz_file, open(out_file, 'wb') as out:
                shutil.copyfileobj(gz_file, out)
            if is_valid_archive_file(out_file):
                parent_stack.append(os.path.basename(archive_path))
                search_and_extract_files_from_archive(
                    out_file, patterns_list, output_dir,
                    target_parent_zips, parent_stack, result,
                    os.path.join(virtual_path, os.path.basename(out_file))
                )
                parent_stack.pop()
            elif is_in_any_parent(parent_stack, target_parent_zips):
                match_and_extract(os.path.basename(out_file), out_file)
    else:
        if is_in_any_parent(parent_stack, target_parent_zips):
            match_and_extract(os.path.basename(archive_path), archive_path)

    return result


def _safe_extract_tar(tar: tarfile.TarFile, dest_dir: str):
    base = os.path.abspath(dest_dir)
    for member in tar.getmembers():
        raw_name = member.name
        # Rewrite absolute names to relative names under destination.
        safe_name = os.path.normpath(raw_name.lstrip('/\\'))
        if safe_name in ('', '.'):
            # Root placeholder entries are harmless; skip silently.
            continue
        if safe_name == '..' or safe_name.startswith('..' + os.sep):
            print(f"[WARN] Skip unsafe tar member: {raw_name}")
            continue

        target = os.path.abspath(os.path.join(dest_dir, safe_name))
        # Block path traversal outside temporary extraction directory.
        if not (target == base or target.startswith(base + os.sep)):
            print(f"[WARN] Skip unsafe tar member: {raw_name}")
            continue

        if member.isdir():
            os.makedirs(target, exist_ok=True)
            continue

        if not member.isfile():
            # Skip symlink/device/fifo entries quietly to avoid log spam.
            continue

        os.makedirs(os.path.dirname(target), exist_ok=True)
        src = tar.extractfile(member)
        if src is None:
            print(f"[WARN] Failed to read tar member: {raw_name}")
            continue

        with src, open(target, 'wb') as dst:
            shutil.copyfileobj(src, dst)


def get_ru_rad_param_current_value(output, param_names):
    """
    search the currentValue of specific debug paramters from get_ru_rad_debug_parameters
    :param output: dict, get_ru_rad_debug_parameters
    :param param_names: str or list
    :return: dict, such as {'PARAM1': value1, 'PARAM2': value2}
    """
    if isinstance(param_names, str):
        param_names = [param_names]
    result = {}
    try:
        rus = output.get('rus', [])
        for ru in rus:
            domains = ru.get('domains', [])
            for domain in domains:
                params = domain.get('parameters', [])
                for param in params:
                    name = param.get('name')
                    if name in param_names:
                        result[name] = param.get('currentValue')
        return result
    except Exception as e:
        raise RuntimeError(f"Failed to parse param values: {e}")


def check_log_print_interval_after_time(log_content, expected_interval, onair_time):
    time_pattern = re.compile(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})')
    onair_dt = datetime.strptime(onair_time, "%Y-%m-%dT%H:%M:%S")
    times = []
    for line in log_content.splitlines():
        match = time_pattern.search(line)
        if match:
            log_dt = datetime.strptime(match.group(1), "%Y-%m-%dT%H:%M:%S")
            if log_dt >= onair_dt:
                times.append(match.group(1))
    # just keep unique times
    unique_times = []
    last_time = None
    for t in times:
        if t != last_time:
            unique_times.append(t)
            last_time = t
    # check intervals
    for i in range(1, len(unique_times)):
        t1 = datetime.strptime(unique_times[i-1], "%Y-%m-%dT%H:%M:%S")
        t2 = datetime.strptime(unique_times[i], "%Y-%m-%dT%H:%M:%S")
        interval = (t2 - t1).total_seconds()
        if int(interval) != int(expected_interval):
            raise AssertionError(
                f"[ERROR] Log interval error: {unique_times[i-1]} -> {unique_times[i]}, "
                f"interval={interval}s, expected={expected_interval}s"
            )


def check_log_after_time(log_content, onair_time, keyword, should_exist=True):
    """
    :param log_content: str, grep result
    :param onair_time: str, reference time point, format like '2025-08-21T06:35:26'
    :param keyword: str, target keyword
    :param should_exist: bool, True means must exist, False means must not exist
    """
    time_pattern = re.compile(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})')
    onair_dt = datetime.strptime(onair_time, "%Y-%m-%dT%H:%M:%S")
    found = False
    for line in log_content.splitlines():
        match = time_pattern.search(line)
        if match:
            log_dt = datetime.strptime(match.group(1), "%Y-%m-%dT%H:%M:%S")
            if log_dt >= onair_dt and keyword in line:
                found = True
                break
    if should_exist and not found:
        raise AssertionError(f"[ERROR] No '{keyword}' log found after {onair_time}")
    if not should_exist and found:
        raise AssertionError(f"[ERROR] Found '{keyword}' log after {onair_time}, but should not exist")


def search_and_extract_files_with_original_paths(
    archive_path,
    target_patterns,
    output_dir,
    target_parent_zips=None,
    parent_stack=None
):
    """
    search_and_extract_files_from_archive
    """
    result = search_and_extract_files_from_archive(
        archive_path,
        target_patterns,
        output_dir,
        target_parent_zips,
        parent_stack
    )
    original_paths = []
    for pattern_dict in result.values():
        for file_name, info in pattern_dict.items():
            if 'original_path' in info:
                original_paths.append(info['original_path'])
            else:
                original_paths.append(file_name)
    return result, original_paths


def check_no_keyword_after_time(log_paths, fatal_keyword, forbidden_keyword, onair_time):
    time_pattern = re.compile(r'(\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2})')
    onair_dt = datetime.strptime(onair_time, "%Y-%m-%dT%H:%M:%S")
    fatal_time = None

    # Step 1: find fatal_time
    for log_path in log_paths:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                if fatal_keyword in line:
                    match = time_pattern.search(line)
                    if match:
                        log_dt = datetime.strptime(match.group(1), "%Y-%m-%dT%H:%M:%S")
                        if log_dt >= onair_dt:
                            fatal_time = log_dt + timedelta(seconds=5)
                            print(
                                f"[INFO] Found {fatal_keyword} at {match.group(1)}, "
                                f"check start time: {fatal_time.strftime('%Y-%m-%dT%H:%M:%S')}"
                            )
                            break
            if fatal_time:
                break

    if not fatal_time:
        print(f"[INFO] No {fatal_keyword} found after {onair_time} in any l1_runtime.log, nothing to check.")
        return

    # Step 2: check forbidden_keyword after fatal_time
    for log_path in log_paths:
        with open(log_path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                match = time_pattern.search(line)
                if match:
                    log_dt = datetime.strptime(match.group(1), "%Y-%m-%dT%H:%M:%S")
                    if log_dt >= fatal_time and forbidden_keyword in line:
                        raise AssertionError(
                            f"[ERROR] Found forbidden '{forbidden_keyword}' after "
                            f"{fatal_time.strftime('%Y-%m-%dT%H:%M:%S')} in {log_path}: {line.strip()}"
                        )
    print(
        f"[PASS] No '{forbidden_keyword}' found after "
        f"{fatal_time.strftime('%Y-%m-%dT%H:%M:%S')} in all l1_runtime.log files."
    )


if __name__ == "__main__":
    pass
