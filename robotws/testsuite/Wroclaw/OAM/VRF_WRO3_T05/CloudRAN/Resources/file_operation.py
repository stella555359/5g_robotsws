import os
import zipfile
import tarfile
import gzip
import shutil
import lzma


def unpack_file_to_destination(archive_path, destination_path):
    """
    Unpacks an archive (ZIP, TAR, GZ, XZ) into a destination folder.
    Deletes the original archive after extraction.

    Args:
        archive_path (str): Path to the archive file.
        destination_path (str): Path to extract the contents.

    Raises:
        FileNotFoundError: If the archive does not exist.
        ValueError: If the file format is unsupported.
    """
    if not os.path.exists(archive_path):
        raise FileNotFoundError(f'Archive file does not exist: {archive_path}')

    os.makedirs(destination_path, exist_ok=True)

    try:
        if zipfile.is_zipfile(archive_path):
            with zipfile.ZipFile(archive_path, 'r') as zf:
                zf.extractall(destination_path)
        elif tarfile.is_tarfile(archive_path):
            with tarfile.open(archive_path, 'r:*') as tf:
                tf.extractall(destination_path)
        elif archive_path.endswith('.gz') and not archive_path.endswith('.tar.gz'):
            _decompress_gzip(archive_path, destination_path)
        elif archive_path.endswith('.xz') and not archive_path.endswith('.tar.xz'):
            _decompress_xz(archive_path, destination_path)
        else:
            raise ValueError(f'Unsupported archive format: {archive_path}')
    finally:
        if os.path.exists(archive_path):
            os.remove(archive_path)


def _decompress_gzip(file_path, destination_path):
    output_file = os.path.join(destination_path, os.path.basename(file_path)[:-3])
    with gzip.open(file_path, 'rb') as f_in, open(output_file, 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)


def _decompress_xz(file_path, destination_path):
    output_file = os.path.join(destination_path, os.path.basename(file_path)[:-3])
    with lzma.open(file_path, 'rb') as f_in, open(output_file, 'wb') as f_out:
        shutil.copyfileobj(f_in, f_out)


def merge_text_files(input_directory, output_filename, encoding='utf-8'):
    """
    Merge all text files in folder into one and remove original files.

    Args:
        input_directory (str): Directory containing text files.
        output_filename (str): Path of the merged output file.
        encoding (str): Text encoding to use. Defaults to 'utf-8'.

    Returns:
        str: Summary message about the number of merged files.
    """
    txt_files = sorted(os.listdir(input_directory))
    merged_count = 0

    with open(output_filename, 'w', encoding=encoding) as outfile:
        for file in txt_files:
            file_path = os.path.join(input_directory, file)
            if os.path.abspath(file_path) == os.path.abspath(output_filename):
                continue
            with open(file_path, 'r', encoding=encoding) as infile:
                outfile.write(infile.read())
            os.remove(file_path)
            merged_count += 1

    return f'Merged {merged_count} files into {output_filename}'
