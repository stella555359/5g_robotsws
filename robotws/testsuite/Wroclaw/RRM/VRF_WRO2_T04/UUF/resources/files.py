import os
import glob
import shutil
from robot.api import logger
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.utilities import get_robot_output_dir


def find_log_files(directory):
    pattern = f"{directory}/MULTI_SW_UPDATE/**/*[.tar.gz|.log|.zip|.txt|.ims2]"
    all_files = glob.glob(f"{directory}/MULTI_SW_UPDATE/**", recursive=True)
    logger.debug(all_files)
    expected_files = [f for f in glob.glob(pattern, recursive=True)
                      if ('passed_iteration' not in f) and (not os.path.isdir(f))]
    logger.debug(expected_files)
    return list(set(expected_files))


def move_logs_to_destination(destination_directory, current_iteration, current_operation):
    current_operation = current_operation.replace(' ', '_')
    files = find_log_files(get_robot_output_dir())
    files = sorted(files, key=os.path.isfile)
    dest_dir = os.path.join(destination_directory, f'{current_iteration}_{current_operation}')
    if not os.path.exists(dest_dir):
        os.makedirs(dest_dir)

    for f in files:
        dest_filepath = f.replace(os.path.join(get_robot_output_dir(), 'MULTI_SW_UPDATE'), dest_dir)
        if not os.path.exists(os.path.dirname(dest_filepath)):
            os.makedirs(os.path.dirname(dest_filepath))
        logger.debug(f"Moving {f} to {dest_filepath}")
        shutil.move(f, dest_filepath)
        logger.debug(f"Moved {f} to {dest_filepath}")


def cleanup_pcap_files_if_iteration_passed(iteration):
    output_dir = get_robot_output_dir()
    pcaps_dir = os.path.join(output_dir, 'pcaps')
    os.system(f'rm -rf {pcaps_dir}/*iter_n{iteration}.pcap')
