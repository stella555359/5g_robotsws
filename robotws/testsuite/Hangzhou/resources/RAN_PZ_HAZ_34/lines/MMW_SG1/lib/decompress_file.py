import os
import sys
import logging
import subprocess


def get_file_path_after_decompress(file_path_compressed):
    """
    Author: Ding Binmei
    This function is used to get the file path after decompressing a .gz file.

    Args:
        file_path_compressed (str): The file path of the compressed .gz file.

    Returns:
        str: The file path after decompression.
    """
    file_name_compressed = file_path_compressed.split("/")[-1]
    local_file_folder = os.path.dirname(file_path_compressed)
    if file_name_compressed.endswith(".gz"):
        file_name_decompressed = file_name_compressed.replace(".gz", "")
        file_path_decompressed = os.path.join(local_file_folder, file_name_decompressed)
        logging.debug("File is in gz format, will decompress firstly")
        cmd_decompress_file = "cd {}; gzip -d {}".format(local_file_folder, file_name_compressed)
        output_decompress_file = subprocess.getoutput(cmd=cmd_decompress_file)
        logging.debug("Decompress with command: {}, output message is: {}".format(cmd_decompress_file,
                                                                                  output_decompress_file))
        cmd_is_file_decompressed = "ls {}".format(file_path_decompressed)
        output_decompress_file_path = subprocess.getoutput(cmd=cmd_is_file_decompressed).strip()
        if output_decompress_file_path == file_path_decompressed:
            return file_path_decompressed
        else:
            raise Exception("Fail to decompress file {} under {} on test pc".format(file_name_compressed,
                                                                                    local_file_folder))
    else:
        raise Exception("Unsupported file format.")
