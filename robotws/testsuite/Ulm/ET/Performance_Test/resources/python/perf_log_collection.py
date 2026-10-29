
import json
import glob
import shutil
import logging
import subprocess
from pathlib import Path

from robot.libraries.BuiltIn import BuiltIn

from testsuite.Ulm.ET.Performance_Test.resources.python import perf_keywords


logger = logging.getLogger(__name__)

rbi = BuiltIn()


def queue_logs_to_turandot(path, rename=None, **kwargs):
    rbi.log(f"queue_logs_to_turandot: {path}, {kwargs}")
    queue = rbi.get_variable_value("${TURANDOT_FILES_QUEUE}")
    if rename:
        td = Path(rbi.get_variable_value("${P_resultTestDir}"))
        newparent = td.joinpath('queued_logs', path.parent.name)
        newparent.mkdir(parents=True, exist_ok=True)
        shutil.move(path, newparent.joinpath(rename))
        queue.append({'path': newparent.joinpath(rename), **kwargs})
    else:
        queue.append({'path': path, **kwargs})
    rbi.set_test_variable('$TURANDOT_FILES_QUEUE', queue)


def save_queued_logs_to_turandot():
    queue = rbi.get_variable_value("${TURANDOT_FILES_QUEUE}")
    td = rbi.get_variable_value("${P_resultTestDir}")
    tp = rbi.get_variable_value("${TP}")
    testname = rbi.get_variable_value("${TEST_NAME}")
    turandot_link = f"{tp['P_TURANDOT_LINK']}/{tp['P_TESTLINE_NAME']}/{testname}/{tp['BUILD_ID']}/"
    rbi.log_to_console(f"Saving Logs to turandot:\n - {turandot_link}")
    for file in queue:
        path = file.pop('path')
        if path is None:
            logger.error("File in queue does not exist, skipping: %s", file)
            continue
        is_dir = file.pop('is_dir', False)
        short_path = path.removeprefix(f'{td}/')
        rbi.log_to_console(f".../{file.get('subfolder', '')}/{short_path} ({file.get('archive_name', '')})")
        if is_dir:
            save_directory_to_turandot(path, **file)
        else:
            save_logs_to_turandot(path, **file)


def save_logs_to_turandot(path_to_file, compress=None, archive_name='', subfolder='', turandot_dir=None, tar=False,
                          compression_flags="-q"):
    """    archive_name    |   use if multiple files, or path to file has askterisk
    """
    tp = rbi.get_variable_value("${TP}")
    test_name = rbi.get_variable_value("${TEST_NAME}")
    build_id = tp['BUILD_ID']
    turandot_dir = rbi.get_variable_value("${P_TURANDOT_DIR}") if str(turandot_dir).lower() == "none" else turandot_dir
    compress = tp['ENABLE_LOG_ARCHIVE_COMPRESSION'] if str(compress).lower() == "none" else compress
    if any([
        tp['ENABLE_LOG_ARCHIVE'] != "true",
        str(path_to_file).lower() == "none"
    ]):
        return
    if str(turandot_dir).lower().rstrip() in ['/', '', 'none']:
        turandot_dir = '/tmp'
        logger.warning("turandot_dir is invalid, defaulting to: %s", turandot_dir)
    subfolder = subfolder[1:] if subfolder.startswith('/') else subfolder
    remote_dir = Path(turandot_dir).joinpath(test_name, build_id, subfolder)
    remote_dir.mkdir(parents=True, exist_ok=True)
    if archive_name != "":
        archive_dir = remote_dir.joinpath(archive_name)
        archive_dir.mkdir(parents=True, exist_ok=True)
        archive_path = _append_index_until_path_not_exist(archive_dir.joinpath(f"{Path(path_to_file).name}"))
    else:
        archive_path = _append_index_until_path_not_exist(remote_dir.joinpath(f"{Path(path_to_file).name}"))
    if tar or '*' in str(path_to_file):
        archive_path = f"{archive_path}.tar"
        path_to_file = tar_files(path_to_file)
    if str(compress).lower() != "false":
        if not _compress_file(archive_path, path_to_file, flags=compression_flags):
            _copy_file(archive_name, remote_dir, path_to_file)
    else:
        _copy_file(archive_name, remote_dir, path_to_file)


def save_directory_to_turandot(directory, *args, **kwargs):
    files = [x for x in Path(directory).glob('*') if x.is_file()]
    for file in files:
        save_logs_to_turandot(file, *args, **kwargs)


def save_all_var_to_json(label='default', compress='false'):
    try:
        test_variables = rbi.get_variables(no_decoration=True)
        test_variables = perf_keywords.convert_rf_dict_to_json(test_variables)
        result_test_dir = rbi.get_variable_value("${P_resultTestDir}", None)
        filepath = f"{result_test_dir}/variables_{label}.json"
        with open(filepath, 'w+', encoding='utf-8') as fstream:
            usage_json = json.dumps(test_variables, indent=4)
            fstream.write(usage_json)
        save_logs_to_turandot(filepath, compress=compress, subfolder='900_jenkins_debug')
    except FileExistsError as e:
        logger.error("failed: save_all_var_to_json %s", label)
        logger.exception(e)


def _append_index_until_path_not_exist(path):
    path = Path(path)
    index = 1
    new_path = path
    while new_path.is_file() or new_path.is_dir():
        new_path = path.parent.joinpath(f"{path.stem}_{index}{path.suffix}")
        logger.warning("path exists %s, new: %s", path, new_path.name)
        index = index + 1
    return new_path


def _copy_file(archive_name, remote_dir, path_to_file):
    remote_dir = Path(remote_dir)
    archive_name = Path(archive_name)
    final_remote_dir = remote_dir.joinpath(archive_name)
    final_remote_dir.mkdir(parents=True, exist_ok=True)
    try:
        for file in glob.glob(path_to_file):
            target = final_remote_dir.joinpath(Path(file).name)
            shutil.copy(file, target)
            logger.debug("Saving log: '%s' --> %s", str(file), str(target))
    except FileExistsError as e:
        logger.warning("failed to copy to turandot %s", path_to_file)
        logger.exception(e)


def _compress_file(archive_path, path_to_file, flags="-q"):
    archive_path = str(archive_path).replace(".*", '').replace("*", '')
    zstd_cmd = ['zstd', flags, '--force', str(path_to_file), '-o', f"{archive_path}.zst"]
    if not Path(path_to_file).is_file():
        logger.error("Unable to compress, file not existing : %s", path_to_file)
        return False
    logger.debug("Compressing file with command: %s", ' '.join(zstd_cmd))
    subprocess.run(zstd_cmd, check=False)
    return True


def tar_files(path_to_file, flags="-cvf"):
    tar_path = str(path_to_file).replace(".*", '').replace("*", '')
    tar_path = f"{tar_path}.tar"
    if Path(path_to_file).is_dir():
        tar_cmd = ['cd', str(Path(path_to_file)), '&&',
                   'tar', flags, tar_path, r"$(ls)"]
    else:
        tar_cmd = ['cd', str(Path(path_to_file).parent), '&&',
                   'tar', flags, tar_path, f"$(ls {str(Path(path_to_file).name)})"]
    logger.debug("Tar file with command: %s, cwd=%s", ' '.join(tar_cmd), str(Path(path_to_file).parent))
    subprocess.run(' '.join(tar_cmd), check=False, cwd=str(Path(path_to_file).parent), shell=True)
    if not Path(tar_path).is_file():
        logger.error("Unable to create archive: %s, %s", path_to_file, tar_path)
    return tar_path
