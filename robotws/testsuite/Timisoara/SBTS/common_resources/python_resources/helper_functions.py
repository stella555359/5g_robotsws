import bz2
import gzip
import lzma
import tarfile
import zipfile
from contextlib import contextmanager, ExitStack
from io import BytesIO
from os import path

"""
This resource provides a memory-efficient context manager to stream files from nested archives.
This utility allows reading file content from deep within an archive structure
(e.g., tar-in-zip) without extracting the entire bundle to disk, making it
ideal for inspecting large software snapshots.
"""


def get_decompressor(filename):
    """Returns the appropriate decompress function for a given compression type."""
    if filename.endswith('.gz'):
        return gzip.decompress
    if filename.endswith('.bz2'):
        return bz2.decompress
    if filename.endswith(('.xz', '.lzma')):
        return lzma.decompress
    return None


@contextmanager
def stream_file_in_nested_archive(archive_path_string, decompress=True):
    """
    A context manager that provides a file-like object (stream) for a file
    located within a potentially nested archive structure.
    This is a memory-efficient way to access nested files.

    :param archive_path_string: Full, slash-separated path to the target file.
    :param decompress: If True, decompress the final file stream.
    :yield: A file-like object (stream) for the target file.
    """
    archive_extensions = ('.zip', '.tar', '.tar.gz', '.tgz', '.tar.bz2', '.tbz2', '.tar.xz')
    parts = archive_path_string.replace(path.sep, '/').split('/')
    fs_path, path_in_archive_parts = None, []
    for i in range(len(parts), 0, -1):
        potential_path = path.normpath('/'.join(parts[:i]))
        if path.exists(potential_path):
            fs_path = potential_path
            path_in_archive_parts = parts[i:]
            break

    if not fs_path:
        print(f"Error: Base file path not found for '{archive_path_string}'")
        yield None
        return
    # ExitStack automatically closes all opened streams and archive handlers
    # in the reverse order they were opened, preventing resource leaks.
    with ExitStack() as stack:
        try:
            current_stream = stack.enter_context(open(fs_path, 'rb'))
            container_name = path.basename(fs_path)

            for member_name in path_in_archive_parts:
                if container_name.endswith('.zip'):
                    archive = stack.enter_context(zipfile.ZipFile(current_stream, 'r'))
                    current_stream = stack.enter_context(archive.open(member_name, 'r'))
                elif container_name.endswith(archive_extensions):
                    # tarfile's stream mode 'r:*' can handle non-seekable streams
                    archive = stack.enter_context(tarfile.open(fileobj=current_stream, mode='r:*'))
                    member_info = archive.getmember(member_name)
                    if not member_info.isfile():
                        raise FileNotFoundError(f"Member '{member_name}' in tar '{container_name}' is not a file.")
                    extracted_file = archive.extractfile(member_info)
                    if not extracted_file:
                        raise FileNotFoundError(f"Could not extract '{member_name}' from tar '{container_name}'.")
                    current_stream = stack.enter_context(extracted_file)
                else:
                    print(f"Error: Cannot extract from '{container_name}'. Not a supported archive type.")
                    yield None
                    return
                container_name = member_name

            if decompress:
                decompressor = get_decompressor(container_name)
                if decompressor:
                    # Must read into memory for decompression, but only the final file
                    compressed_data = current_stream.read()
                    data = decompressor(compressed_data)
                    yield BytesIO(data)
                else:
                    yield current_stream
            else:
                yield current_stream

        except (KeyError, FileNotFoundError, zipfile.BadZipFile, tarfile.ReadError) as e:
            print(f"Error during archive traversal of '{archive_path_string}'. Details: {e}")
            yield None
        except Exception as e:
            print(f"An unexpected error occurred while streaming '{archive_path_string}': {e}")
            yield None
