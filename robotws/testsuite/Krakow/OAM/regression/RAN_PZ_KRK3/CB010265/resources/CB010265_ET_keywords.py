import os
import tarfile
import logging


def search_phrase_in_tar(directory, search_phrase):
    """
    Searches for a phrase within files located inside a ne3s_atl_logUploadNotification.tar
    archive in the specified directory.

    Args:
        directory (str): Path to the directory containing the .tar archive.
        search_phrase (str): Phrase to search for within the files inside the .tar archive.

    Returns:
        list: A list of filenames inside the archive that contain the specified phrase.
    """
    matching_files = []

    for filename in os.listdir(directory):
        if filename.startswith("ne3s_atl_logUploadNotification") and filename.endswith(".tar"):
            tar_path = os.path.join(directory, filename)
            with tarfile.open(tar_path, 'r') as tar:
                for member in tar.getmembers():
                    if member.isfile():
                        file_obj = tar.extractfile(member)
                        if file_obj:
                            try:
                                content = file_obj.read().decode('utf-8', errors='ignore')
                                if search_phrase in content:
                                    matching_files.append(member.name)
                            except Exception as e:
                                logging.info(f"Failed to read file {member.name}: {e}")
            break

    return matching_files
