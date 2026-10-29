import os
import shutil
import zipfile
import tarfile
import gzip
import lzma
from traceback import format_exception
import re

from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import ScriptIssue


def remove_file_or_folder(filer_or_folder):
    """
    Remove a file or folder from the filesystem.

    This function attempts to remove a specified file or folder. If the specified path is a file, it will be deleted
    If the specified path is a directory, it and all its contents will be deleted.

    :param str filer_or_folder: The path to the file or folder to be removed.
    :raises PermissionError: If the function does not have the necessary permissions to remove the file or folder.
    :raises FileNotFoundError: If the specified file or folder does not exist.
    :raises SyntaxWarning: If there is a syntax warning during the removal process.
    """
    f_type = "file"
    try:
        if os.path.exists(filer_or_folder):
            if os.path.isfile(filer_or_folder):
                os.remove(filer_or_folder)
            elif os.path.isdir(filer_or_folder):
                shutil.rmtree(filer_or_folder)
                f_type = "folder"
    except (PermissionError, FileNotFoundError, SyntaxWarning) as e:
        info(f"Cannot remove {f_type} {filer_or_folder}: {e.__class__.__name__}")
        info(''.join(format_exception(type(e), e, e.__traceback__)))


def get_file_from_archived_folder(filename_to_get, archived_path=None, folder_to_extract=None, upper_folder=None,
                                  upper_upper_folder=None, add_name_to_get_file="", not_in_name=None,
                                  extra_name="", get_multiple_files=False, print_if_not_found=True):
    """
    Get file from archive, zip or tar. Extracts a file that name has user given 'filename_to_get' in it from the given
    archived file.
    User can also define folder from where the file is and give name for the saved file. These are optional.

    :param str filename_to_get: Name of the file to extract from the zip.
    :param str archived_path: Path to the archived file. For example /home/ute/Snapshot.zip.
    :param str folder_to_extract: Directory to extract the file to.
    :param str upper_folder: If file should be in specific folder the folder or part of the folder name can be given
                             here. (OPTIONAL)
    :param str upper_upper_folder: If file should be in specific folder under another specific folder the folder or
                                   part of the folder name can be given here. (OPTIONAL)
    :param str add_name_to_get_file: If you want to get multiple files from different folder to logs you can add extra
                                     name with this parameter. (OPTIONAL)
    :param str not_in_name: If you want to specify what should not be in the name. (OPTIONAL)
    :param str extra_name: Use this if you want to give extra name for example because file has same name in other
                           folder. (OPTIONAL)
    :param bool get_multiple_files: If True, the function will return a list of all matching files found in the archive.
                                    If False, it will return only the first matching file found. (OPTIONAL)
    :param bool print_if_not_found: If True, prints to eventlog if file is not found. (OPTIONAL)
    :return str/list: Path to the extracted file or None if no such file is found.
    """
    if not filename_to_get:
        error("Filename to get is not given to method get_file_from_archived_folder")
        raise ScriptIssue("Filename to get is not given")
    if archived_path is None:
        error(f"No path offered to archived folder.")
        raise ScriptIssue("Unable to get file, no path given to archived folder")
    if not os.path.exists(archived_path):
        error(f"'{archived_path}' doesn't exists.")
        raise ScriptIssue("Archived file doesn't exists.")
    if not os.path.isfile(archived_path):
        error(f"'{archived_path}' is not a file.")
        raise ScriptIssue("Given archived file is not a file.")
    if folder_to_extract:
        if not os.path.isdir(folder_to_extract):
            error(f"Directory '{folder_to_extract}' does not exist.")
            raise ScriptIssue(f"Directory that is given to where given file will be collected does not exist.")
    else:
        error(f"No path offered for folder_to_extract parameter.")
        raise ScriptIssue(f"No path offered for folder_to_extract.")
    if os.name != "nt":
        os.makedirs("/home/ute/extract", exist_ok=True)
        extract_to = "/home/ute/extract"
    else:
        extract_to = r"C:\Temp\extract"
        os.makedirs(r"C:\Temp\extract", exist_ok=True)
    delete_extracted_files = []
    results = []

    def extract_and_rename(archive_ref, file_name, et, archived_with="zip", archive_folder=None):
        """
        Extracts a file from an archive and renames it if necessary.

        This function extracts a specified file from a given archive (zip or tar) to a specified directory.
        If the `add_name_to_get_file` parameter is provided, the extracted file will be renamed accordingly.

        :param archive_ref: Reference to the archive object (zipfile.ZipFile or tarfile.TarFile).
        :param str file_name: Name of the file to extract from the archive.
        :param str et: Directory to extract the file to.
        :param str archived_with: Type of the archive ('zip' or 'tar'). Default is 'zip'.
        :param str archive_folder: The path to the archive file. Used for tracking extracted files.
        :return: Path to the extracted (and possibly renamed) file, or None if extraction fails.
        :raises PermissionError: If the function does not have the necessary permissions to extract the file.
        :raises FileNotFoundError: If the specified file is not found in the archive.
        :raises SyntaxWarning: If there is a syntax warning during the extraction process.
        """
        try:
            if archived_with == "zip":
                archive_ref.extract(file_name, et)
            elif archived_with == "tar":
                if hasattr(tarfile, 'data_filter'):
                    archive_ref.extract(file_name, et, filter="data")
                else:  # older python version, no filter in tarfile
                    archive_ref.extract(file_name, et)
            org_path = os.path.join(et, file_name)
            if archive_folder and archive_folder.replace('.zip', '').replace('.tar', '') not in delete_extracted_files:
                delete_extracted_files.append(archive_folder.replace('.zip', '').replace('.tar', ''))
            fn = os.path.basename(archive_folder)
            if add_name_to_get_file:
                new_path = org_path.replace(file_name, f"{add_name_to_get_file}{extra_name}{file_name}")
                new_path_dir = os.path.dirname(new_path)
                if not os.path.exists(new_path_dir):
                    os.makedirs(new_path_dir, exist_ok=True)
                print(f"Get {file_name} from {fn} to {extract_to} and rename it to {new_path}")
                shutil.move(org_path, new_path)
                return new_path
            else:
                print(f"Get {file_name} from {fn} to {extract_to}")
                return org_path
        except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError, UnicodeDecodeError, TypeError,
                zipfile.BadZipFile, zipfile.LargeZipFile) as ear:
            info(f"Cannot extract {archived_with} {file_name}: {ear.__class__.__name__}:{ear}")
            info(''.join(format_exception(type(ear), ear, ear.__traceback__)))
            return None

    def search_in_zip(zp=archived_path, et=extract_to):
        """
        Search for a file within a zip archive and extract it if found.

        This function searches for a specified file within a given zip archive. If the file is found, it is extracted to
         a specified directory. The function also handles nested zip and tar files, extracting and searching within them
        recursively.

        :param str zp: Path to the zip archive.
        :param str et: Directory to extract the file to.
        :return: Path to the extracted file, or None if the file is not found.
        """
        try:
            with zipfile.ZipFile(zp, 'r') as zip_ref:
                for file_name in zip_ref.namelist():
                    extracted_file = None
                    if filename_to_get in file_name:
                        if (upper_upper_folder and len(delete_extracted_files) > 1 and
                            upper_upper_folder in delete_extracted_files[-2]) and (
                                upper_folder and upper_folder in delete_extracted_files[-1]) and (
                                (not not_in_name) or (
                                not_in_name and not_in_name not in delete_extracted_files[-1])):
                            # return extract_and_rename(zip_ref, file_name, et)
                            extracted_file = extract_and_rename(zip_ref, file_name, et, archive_folder=zp)
                            if not extracted_file:
                                info(f"File {filename_to_get} was found {file_name} but could not be extracted from "
                                     f"the archive {zp}.")
                        elif ((upper_folder and upper_folder in delete_extracted_files[-1]) or (
                                not upper_folder)) and ((not not_in_name) or (
                                not_in_name and not_in_name not in delete_extracted_files[-1])):
                            extracted_file = extract_and_rename(zip_ref, file_name, et, archive_folder=zp)
                            if not extracted_file:
                                info(f"File {filename_to_get} was found {file_name} but could not be extracted from "
                                     f"the archive {zp}.")
                        if extracted_file:
                            if get_multiple_files:
                                results.append(extracted_file)
                            else:
                                return extracted_file
                    elif file_name.endswith('.zip'):
                        nested_zip_path = os.path.join(et, file_name)
                        delete_extracted_files.append(nested_zip_path)
                        zip_ref.extract(file_name, et)
                        zip_result = search_in_zip(zp=nested_zip_path, et=extract_to)
                        if zip_result:
                            return zip_result
                    elif file_name.endswith('.tar'):
                        path_to_unzip = zp.replace(".zip", "")
                        uf = os.path.basename(path_to_unzip)
                        path_to_unzip = os.path.join(et, uf)
                        if not (os.path.exists(path_to_unzip) and os.path.isdir(path_to_unzip) and
                                path_to_unzip in delete_extracted_files):
                            delete_extracted_files.append(path_to_unzip)
                            try:
                                shutil.unpack_archive(zp, path_to_unzip)
                            except shutil.ReadError as eze:
                                info(f"Cannot unpack {zp}: {eze.__class__.__name__}: {eze}")
                                info(''.join(format_exception(type(eze), eze, eze.__traceback__)))
                                return None
                        nested_tar_path = os.path.join(path_to_unzip, file_name)
                        delete_extracted_files.append(nested_tar_path)
                        zip_tar_result = search_in_tar(tp=nested_tar_path, et=extract_to)
                        if zip_tar_result:
                            return zip_tar_result
            return None
        except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError, UnicodeDecodeError, TypeError,
                zipfile.BadZipFile, zipfile.LargeZipFile) as ear:
            info(f"Cannot extract zip. {ear.__class__.__name__}:{ear}")
            info(''.join(format_exception(type(ear), ear, ear.__traceback__)))
            return None

    def search_in_tar(tp, et):
        """
        Search for a file within a tar archive and extract it if found.

        This function searches for a specified file within a given tar archive. If the file is found, it is extracted to
        a specified directory.
        The function also handles nested tar files, extracting and searching within them recursively.

        :param str tp: Path to the tar archive.
        :param str et: Directory to extract the file to.
        :return: Path to the extracted file, or None if the file is not found.
        :rtype: str
        :raises tarfile.ReadError: If there is an error reading the tar file.
        """
        try:
            if os.path.exists(tp) and int(os.path.getsize(tp)) > 0:
                with tarfile.open(tp, 'r') as tar_ref:
                    for file_name in tar_ref.getnames():
                        extracted_file = None
                        if filename_to_get in file_name:
                            if (upper_upper_folder and len(delete_extracted_files) > 1 and
                                upper_upper_folder in delete_extracted_files[-2]) and (
                                    upper_folder and upper_folder in delete_extracted_files[-1]):
                                extracted_file = extract_and_rename(tar_ref, file_name, et, archived_with="tar",
                                                                    archive_folder=tp)
                                if not extracted_file:
                                    info(f"File {filename_to_get} was found {file_name} but could not be extracted "
                                         f"from the archive {tp}.")
                            elif (upper_folder and upper_folder in delete_extracted_files[-1]) or (
                                    not upper_folder):
                                extracted_file = extract_and_rename(tar_ref, file_name, et, archived_with="tar",
                                                                    archive_folder=tp)
                                if not extracted_file:
                                    info(f"File {filename_to_get} was found {file_name} but could not be extracted "
                                         f"from the archive {tp}.")
                            if extracted_file:
                                if get_multiple_files:
                                    results.append(extracted_file)
                                else:
                                    return extracted_file
                        elif file_name.endswith('.tar'):
                            nested_tar_path = os.path.join(et, file_name)
                            delete_extracted_files.append(nested_tar_path)
                            if hasattr(tarfile, 'data_filter'):
                                tar_ref.extract(file_name, et, filter="data")
                            else:  # older python version, no filter in tarfile
                                tar_ref.extract(file_name, et)
                            t_result = search_in_tar(tp=nested_tar_path, et=extract_to)
                            if t_result:
                                return t_result
                        elif file_name.endswith('.zip'):
                            nested_zip_path = os.path.join(et, file_name)
                            delete_extracted_files.append(nested_zip_path)
                            nested_tar_path = os.path.join(et, file_name)
                            delete_extracted_files.append(nested_tar_path)
                            try:
                                shutil.unpack_archive(nested_tar_path, et)
                            except shutil.ReadError as sit:
                                info(f"Cannot unpack {nested_tar_path}: {sit.__class__.__name__}: {sit}")
                                info(''.join(format_exception(type(sit), sit, sit.__traceback__)))
                                return None
                            f_name = delete_extracted_files[-1]
                            delete_extracted_files.append(f_name[:f_name.rfind('.zip')])
                            t_result = search_in_zip(zp=nested_zip_path, et=extract_to)
                            if t_result:
                                return t_result
        except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError, UnicodeDecodeError, TypeError,
                tarfile.ReadError) as tre:
            info(f"Unable to extract tar file {tp}. {tre.__class__.__name__}:{tre}")
            info(''.join(format_exception(type(tre), tre, tre.__traceback__)))
        return None

    result = search_in_zip(archived_path, extract_to)  # find just one file
    final_results = []
    try:
        if get_multiple_files:
            if results:
                for extracted_file_path in results:
                    name_of_file = os.path.basename(extracted_file_path)
                    nm = os.path.join(folder_to_extract, name_of_file)
                    shutil.move(extracted_file_path, nm)
                    final_results.append(nm)
            else:
                if print_if_not_found:
                    info(f"Files with {filename_to_get} in name were not found from the given archive '{archived_path}'"
                         f" (upper_folder: {upper_folder}, upper_upper_folder:{upper_upper_folder})")
                else:
                    print(f"Files with {filename_to_get} in name were not found from the given archive "
                          f"'{archived_path}' (upper_folder: {upper_folder}, upper_upper_folder:{upper_upper_folder})")
        else:
            if result:
                print(f"result: {result}")
                name_of_file = os.path.basename(result)  # file is renamed when extracted
                nm = os.path.join(folder_to_extract, name_of_file)
                print(f"Move file from extract folder to test folder {result} -> {nm}")
                shutil.move(result, nm)
                result = nm
            else:
                info(f"File {filename_to_get} was not found from the given archive '{archived_path}' (upper_folder: "
                     f"{upper_folder}, upper_upper_folder:{upper_upper_folder})")
        print(f"Remove extracted files: {delete_extracted_files}")
        remove_file_or_folder(extract_to)
    except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError, UnicodeDecodeError, TypeError,
            zipfile.BadZipFile, zipfile.LargeZipFile) as e:
        info(f"Problems to gathering requested file {e.__class__.__name__}:{e}")
        info(''.join(format_exception(type(e), e, e.__traceback__)))
    return final_results if get_multiple_files else result


def _sanity_check_of_xz_gz_file_path(file_path):
    """
    Sanity check for the given file path.
    """
    if not file_path:
        error("No value for parameter file_path. Filepath is not given.")
        return False
    if not os.path.exists(file_path):
        error(f"Given archived file '{file_path}' doesn't exists.")
        return False
    if not os.path.isfile(file_path):
        error(f"Given archived file '{file_path}' is not a file.")
        return False
    return True


def unarchive_xz_gz_file(file_path, save_path=None, add_to_folder=None, remove_compressed=True):
    """
    Unarchive xz gz file -function unarchives a .gz or .xz compressed file to a specified location.

    :param str file_path: Path to the compressed file (must end with .gz or .xz)
    :param str save_path: Path where the uncompressed file will be saved. If None, saves in the same directory as the
                          compressed file with the same name minus the extension.
    :param str add_to_folder: If specified, the uncompressed file will be saved in a subfolder with this name.
    :param bool remove_compressed: If True, removes the original compressed file after unarchiving.
    :return: Path to the uncompressed file if successful, otherwise None
    """
    if not _sanity_check_of_xz_gz_file_path(file_path):
        return None
    open_func = gzip.open if file_path.endswith('.gz') else lzma.open if file_path.endswith('.xz') else None
    if not open_func:
        error(f"Unsupported file type: {file_path}")
        return None
    # Prepare save path
    base_name = os.path.basename(file_path)
    if base_name.endswith('.gz'):
        new_name = base_name[:-3]
    elif base_name.endswith('.xz'):
        new_name = base_name[:-3]
    else:
        new_name = base_name
    save_dir = save_path
    if save_path is None:
        save_dir = os.path.dirname(file_path)
    if add_to_folder:
        save_dir = os.path.join(save_dir, add_to_folder)
        if not os.path.exists(save_dir):
            os.makedirs(save_dir, exist_ok=True)
    save_path = os.path.join(save_dir, new_name)
    try:
        for encoding in ['utf-8', 'latin-1']:
            try:
                with open_func(file_path, 'rt', encoding=encoding) as f, open(
                        save_path, 'w', encoding=encoding) as out_f:
                    for line in f:
                        out_f.write(line)
                break
            except UnicodeDecodeError as e:
                print(f"UnicodeDecodeError with encoding {encoding}: {e}")
                print(''.join(format_exception(type(e), e, e.__traceback__)))
                continue
            except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError) as e:
                info(f"Problems when unarchiving file '{file_path}'. {e.__class__.__name__}:{e}")
                info(''.join(format_exception(type(e), e, e.__traceback__)))
                break
        if remove_compressed:
            remove_file_or_folder(file_path)
        return save_path
    except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError) as e:
        info(f"Problems when unarchiving file '{file_path}'. {e.__class__.__name__}:{e}")
        info(''.join(format_exception(type(e), e, e.__traceback__)))
        return None


def search_from_xz_gz_archive(file_path, search_string, return_multiple=False, add_to_folder=None,
                              remove_compressed=False):
    """
    Searches for a given string in a .gz or .xz compressed file. Tries utf-8 first, then falls back to latin-1 if
    decoding fails.

    :param file_path: Path to the compressed file (must end with .gz or .xz)
    :param search_string: The string to search for in the file
    :param add_to_folder: If specified, the uncompressed file will be saved in a subfolder with this name.
    :param remove_compressed: If True, removes the original compressed file after unarchiving.
    :param return_multiple: If True, returns all matching lines as a list. If False, returns the first matching line.
    :return: The line containing the search string if found or list of lines, otherwise None
    """
    list_for_return = []
    found_line = None
    if not _sanity_check_of_xz_gz_file_path(file_path):
        return None
    if not search_string:
        error("No string offered to be searched. Value for parameter search_string is missing.")
        return None
    open_func = gzip.open if file_path.endswith('.gz') else lzma.open if file_path.endswith('.xz') else None
    if not open_func:
        error(f"Unsupported file type: {file_path}")
        return None
    # Prepare save path
    base_name = os.path.basename(file_path)
    save_dir = os.path.dirname(file_path)  # file_path[:file_path.find(base_name)]
    if add_to_folder:
        save_dir = os.path.join(save_dir, add_to_folder)
        if not os.path.exists(save_dir):
            os.makedirs(save_dir, exist_ok=True)
    if base_name.endswith('.gz'):
        new_name = base_name[:-3]
    elif base_name.endswith('.xz'):
        new_name = base_name[:-3]
    else:
        new_name = base_name
    save_path = os.path.join(save_dir, new_name)
    for encoding in ['utf-8', 'latin-1']:
        try:
            with (open_func(file_path, 'rt', encoding=encoding, errors='replace') as f,
                  open(save_path, 'w', encoding=encoding, errors='replace') as out_f):
                for line in f:
                    out_f.write(line)
                    if (search_string in line) or (re.search(search_string, line)):
                        print(f"Search string {search_string} found: {line.strip()}")
                        if return_multiple:
                            list_for_return.append(line.strip())
                        elif found_line is None:
                            found_line = line.strip()
                            break
            break
        except UnicodeDecodeError as e:
            print(f"UnicodeDecodeError with encoding {encoding}: {e}")
            print(''.join(format_exception(type(e), e, e.__traceback__)))
            continue
        except (PermissionError, FileNotFoundError, SyntaxWarning, FileExistsError) as e:
            info(f"Problems when searching string '{search_string}' from the file '{file_path}'."
                 f"{e.__class__.__name__}:{e}")
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            break
    if remove_compressed:
        remove_file_or_folder(file_path)
    if return_multiple and list_for_return:
        return list_for_return, save_path
    if found_line:
        return found_line
    info(f"The search string '{search_string}' was not found")
    return None


def unarchive_tgz_file(file_path, extract_to=None, remove_compressed=True):
    """
    Unarchives a .tgz (tar.gz) file to the specified directory.

    :param file_path: Path to the .tgz file.
    :param extract_to: Directory to extract files to. Defaults to the same directory as the archive.
    :param remove_compressed: If True, deletes the original .tgz file after extraction.
    :return: Path to the extraction directory or None if failed.
    """
    if not file_path.endswith('.tgz') and not file_path.endswith('.tar.gz'):
        print(f"Unsupported file type: {file_path}")
        return None
    if not os.path.exists(file_path):
        print(f"File does not exist: {file_path}")
        return None
    if extract_to is None:
        extract_to = os.path.dirname(file_path)
    with tarfile.open(file_path, 'r') as tar:
        for member in tar.getmembers():
            try:
                if hasattr(tarfile, 'data_filter'):
                    tar.extract(member, path=extract_to, filter="data")
                else:
                    tar.extract(member, path=extract_to)
            except Exception as e:
                print(f"Skipping {member.name}: {e}")
    if remove_compressed:
        os.remove(file_path)
    return extract_to


def search_from_tgz_archive(tgz_file_path, search_string="", file_to_search=None, return_multiple=False,
                            remove_compressed=False, return_unit="files"):
    """
    Searches for a given string in a .tgz (tar.gz) archive. Extracts the archive to a temporary location and searches
    through the files. Temporary files can be removed after searching. Temporary location is /home/ute/extract_tgz

    :param str tgz_file_path: Path to the .tgz file.
    :param str search_string: The string to search for in the files.
    :param str file_to_search: If specified, only searches within this file inside the archive.
    :param bool return_multiple: If True, returns all matching lines as a list. If False, returns the first matching
                                 line.
    :param bool remove_compressed: If True, deletes the original .tgz file after searching.
    :param str return_unit: Can have value 'files','lines_and_files' or 'lines' or 'line'. Default is 'files', then
                            returns paths of the files where the search string was found or files that names includes
                            the filename is search_string is empty. If 'lines_and_files', returns a list of
                            tuples. Each tuple contains a line and the corresponding file path. If 'lines', returns only
                            lines list. If 'line', returns only the first line found.
    :return: The line containing the search string if found or list of lines, otherwise None
    """
    if not tgz_file_path.endswith('.tgz') and not tgz_file_path.endswith('.tar.gz'):
        print(f"Unsupported file type: {tgz_file_path}")
        return None
    if return_unit not in ['files', 'lines_and_files', 'lines', 'line']:
        error(f"Invalid return_unit value: {return_unit}. Must be 'files', 'lines_and_files', 'line' or 'lines'.")
        return None
    if os.name != "nt":
        os.makedirs("/home/ute/extract_tgz", exist_ok=True)
        extract_to = "/home/ute/extract_gz"
    else:
        extract_to = r"C:\Temp\extract_tgz"
        os.makedirs(r"C:\Temp\extract_tgz", exist_ok=True)
    temp_dir = unarchive_tgz_file(tgz_file_path, extract_to=extract_to, remove_compressed=remove_compressed)
    if not temp_dir:
        print(f"Failed to unarchive file: {tgz_file_path}")
        return None
    matches = []
    return_str = ""
    files_to_return = []
    tuple_list_to_return = []
    for root, _, files in os.walk(temp_dir):
        for file in files:
            if file_to_search and file != file_to_search:
                continue
            file_path = os.path.join(root, file)
            if search_string:
                print(f"Searching in file: {file_path}")
                try:
                    with open(file_path, 'r', encoding='utf-8', errors='replace') as f:
                        for line in f:
                            if (search_string in line) or (re.search(search_string, line)):
                                print(f"Search string {search_string} found in {file_path}: {line.strip()}")
                                if return_multiple:
                                    matches.append(line.strip())
                                    if file_path not in files_to_return:
                                        files_to_return.append(file_path)
                                else:
                                    if file_path not in files_to_return:
                                        files_to_return.append(file_path)
                                    return_str = line.strip()
                                    break
                except Exception as e:
                    print(f"Error reading {file_path}: {e}")
            else:
                print("No search string provided.")
                files_to_return.append(file_path)
            if return_unit == 'lines_and_files' and matches:
                tuple_list_to_return.append((matches, file_path))
    print(f"Files: {files_to_return}")
    if return_unit == 'files' and files_to_return:
        return files_to_return
    if return_unit == 'lines_and_files' and tuple_list_to_return:
        return tuple_list_to_return
    if return_unit == 'lines' and matches:
        return matches
    if return_unit == 'line' and return_str:
        return return_str
    if search_string:
        error(f"The search string '{search_string}' was not found in any files.")
    if file_to_search:
        error(f"The file '{file_to_search}' was not found in the archive.")
    return None
