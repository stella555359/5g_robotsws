import os
import tarfile
import shutil
from robot.api import logger


def found_target_file_in_compress_package(tgz_path, target_file_name):
    """
    Extracts a .tgz file to a specified directory and searches for a target file within the extracted directories.
    Returns the size of the target file if found.

    Args:
    tgz_path (str): The path to the .tgz file.
    extract_path (str): The directory to extract the files into.
    target_file_name (str): The name of the target file to search for.

    Returns:
    int or None: The size of the target file if found, None otherwise.
    """
    extract_path = tgz_path[:-4]
    print(f'extra path is: {extract_path}')
    try:
        if not os.path.exists(extract_path):
            os.makedirs(extract_path)
        with tarfile.open(tgz_path, "r:gz") as tar:
            for member in tar.getmembers():
                if ":" in member.name:
                    member.name = member.name.replace(":", "_")
                tar.extract(member, extract_path)
        for root, dirs, files in os.walk(extract_path):
            for file in files:
                print(file)
                if 'NrUnHappy' in file:
                    logger.error(f"Don't capture valid IQ data as {file}")
                    return False
                elif target_file_name in file:
                    if 'NrFine' in target_file_name:
                        logger.info(f"Capture valid IQ data as {file}")
                        return True
                    target_file_path = os.path.join(root, file)
                    logger.info(f"Found {file} at {target_file_path}")
                    logger.info(f"Size of {file}: {os.path.getsize(target_file_path)}")
                    return True if os.path.getsize(target_file_path) > 0 else False

        for root, dirs, files in os.walk(extract_path):
            for file in files:
                if file.endswith('.tgz'):
                    tgz_path = os.path.join(root, file)
                    if found_target_file_in_compress_package(tgz_path, target_file_name):
                        return True
        return False
    except Exception as e:
        logger.error(f"Error extracting {tgz_path}: {e}")
        return False
    finally:
        shutil.rmtree(extract_path)


def is_target_files_exist_in_captured_package(tgz_path, target_file_list):
    found_flag_list = []
    for target_file_name in target_file_list:
        if not found_target_file_in_compress_package(tgz_path, target_file_name):
            print(f"{target_file_name} not found in {tgz_path}.")
            found_flag_list.append(False)
        else:
            found_flag_list.append(True)
    return True if all(found_flag_list) else False
