import json
import shutil
from pathlib import Path

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.file_processors import unzip, merge_pcaps, merge_text_files, \
    merge_bip_from_zip


def _merge_tti(target_dir, *files):
    return merge_pcaps(target_dir / 'tti.pcap', *files)


def _merge_syslog(target_dir, *files):
    return merge_text_files(target_dir / 'syslog.LOG', *files)


def _merge_tcpdump(target_dir, *files):
    return merge_pcaps(target_dir / 'tcpdump.pcap', *files)


def _just_get_first(path, *files):
    if not len(files):
        raise ValueError("File list to merge should not be empty. Please inspect log.")
    return merge_text_files(path, files[0])


def _merge_scf(target_dir, *files):
    return _just_get_first(target_dir / 'scf.xml', *files)


def _merge_snapshot(target_dir, *files):
    return _just_get_first(target_dir / 'snapshot.zip', *files)


def _merge_pm_files(target_dir, *files):
    return _just_get_first(target_dir / 'pmFiles.zip', *files)


def _merge_bip(target_dir, *files):
    bip_zip = _just_get_first(target_dir / 'bip.zip', *files)
    return merge_bip_from_zip(target_dir / 'bip.pcap', bip_zip)


log_files_processors = {
    'bip': _merge_bip,
    'udptracer': _merge_tti,
    'syslog': _merge_syslog,
    'scf': _merge_scf,
    'pmFiles': _merge_pm_files,
    'IP-capture': _merge_tcpdump,
    'snapshot': _merge_snapshot,
}


def extract_logs(zip_path):
    unzipped_dir = Path('/tmp/dcap_logs')
    target_dir = Path(zip_path).parent
    unzip(zip_path, unzipped_dir)
    contents = _load_dcap_contents(unzipped_dir)
    logs = _extract_logs_from_contents(contents)
    extracted_logs = _merge_log_files(logs, unzipped_dir, target_dir)
    shutil.rmtree(unzipped_dir)
    return extracted_logs


def _load_dcap_contents(target_dir):
    contents_file = Path(target_dir, 'contents.json')
    with contents_file.open('r') as f:
        return json.load(f)


def _extract_logs_from_contents(contents):
    logs = {}
    for key, value in contents.items():
        if key.isdigit():
            _update_log_dict(logs, _recursive_log_extracion_from_contents(value))
    return logs


def _recursive_log_extracion_from_contents(contents):
    logs = {}
    for key, value in contents.items():
        if key.isdigit() or key in ('bts', '5g', 'lte'):
            _update_log_dict(logs, _recursive_log_extracion_from_contents(value))
        elif 'path' in value:
            _append_log_to_dict(logs, key, value['path'])
        else:
            for subvalue in value.values():
                _append_log_to_dict(logs, key, subvalue['path'])
    return logs


def _update_log_dict(log_dict, updating_dict):
    for key in updating_dict:
        if key in log_dict:
            log_dict[key].extend(updating_dict[key])
        else:
            log_dict[key] = updating_dict[key]


def _append_log_to_dict(log_dict, log_type, path):
    if log_type not in log_dict:
        log_dict[log_type] = [path]
    else:
        log_dict[log_type].append(path)


def _merge_log_files(logs, root_dir, target_dir):
    merged_logs = {}
    for log_type, log_files in logs.items():
        expanded_paths = [root_dir / log for log in log_files]
        for log_file_processor in log_files_processors:
            if log_file_processor in log_type:
                merged_logs[log_type] = log_files_processors[log_file_processor](target_dir, *expanded_paths)
                break
        else:
            merged_logs[log_type] = log_files
    return merged_logs
