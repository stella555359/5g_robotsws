from taf.transport.ssh import ssh
from robot.api import logger
import os
import zipfile
import fnmatch
import re

ssh = ssh()


def unzip_cloud_logs(file_path, timestamp, connection):
    """
    Unzips cloud logs from a given file path and extracts the files to a directory.

    Args:
        file_path (str): The path of the zip file to be downloaded and extracted.
        timestamp (str): The timestamp used to create the local path and directory name.
        connection: The connection object used to download the file.

    Returns:
        list: A list containing the success status and the directory path where the logs are extracted.
    """
    local_path = '/tmp/syslog_{}.zip'.format(timestamp)
    print('Starts to download log {} to {}'.format(file_path, local_path))
    if ssh.file_exists(file_path, connection=connection):
        try:
            ssh.download_file(
                remote_path=file_path,
                local_path=local_path,
                connection=connection
            )
            dir_name = '/tmp/syslog_' + timestamp
            print("{} will be extracted to {}". format(local_path, dir_name))
            with zipfile.ZipFile(local_path, 'r') as zip_ref:
                zip_ref.extractall(dir_name)
            for item in os.listdir(dir_name):  # loop through items in dir
                # check for ".zip" extension and exclude syslog-err_latest zip file
                if item.endswith('.zip') and not fnmatch.fnmatch(item, 'syslog-err_latest_*.zip'):
                    file_name = os.path.join(dir_name, item)  # get full path of files
                    with zipfile.ZipFile(file_name, 'r') as zip_ref:
                        zip_ref.extractall(dir_name)  # extract file to dir
            print("Below files are extracted from zip file:")
            for item in os.listdir(dir_name):
                print(item)
        except Exception as e:
            print("An error occurred while unzipping the file: ", e)
            return [False, dir_name]
        combined_log = "combined_syslog{}.log".format(timestamp)
        cmd = (
                "cd {} && "
                "ls -ltr | "
                "grep 'syslog_.*[^.zip]$' | "
                "awk '{{print $9}}' | "
                "xargs cat > {}"
            ).format(dir_name, combined_log)
        print("Combine syslog files with cmd {}".format(cmd))
        try:
            res = os.popen(cmd).read()
            print('response is {}'.format(res))
            return [os.path.isfile(dir_name + '/' + combined_log), dir_name + '/' + combined_log]
        except Exception as e:
            print("An error occurred when trying to combine logs: ", e)
            return [False, dir_name + '/' + combined_log]
    else:
        print('File {} does not exist'.format(file_path))
        return [False, '']


def get_crash_info_from_syslog(skip_regex_str,
                               file_path='/tmp/btslog2',
                               crash_pattern='exception report',
                               is_cloud=False):
    """
    Search syslog files for crash information starting from the first matching line.

    This function recursively searches all files under the specified directory for lines matching
    the given crash pattern. For each match, it extracts the file name and line number, then uses
    `tail` and `grep` to collect all subsequent lines matching the crash pattern, skipping lines
    that match the provided skip regex. The function returns up to 15 lines of crash information
    per match, with additional formatting for non-cloud environments.

    Args:
        skip_regex_str (str): Regex pattern for lines to skip in the output (used with grep -v).
        file_path (str, optional): Path to the directory containing syslog files.
                                Defaults to '/tmp/btslog2'.
        crash_pattern (str, optional): Pattern to search for in the logs.
                                    Defaults to 'Error Handler exception report'.
        is_cloud (bool, optional): Whether the environment is cloud-based.
                                If False, additional formatting is applied.

    Returns:
        str: Aggregated crash information found in the logs,
            or an empty string if no crash info is detected.

    Example:
        crash_info = get_crash_info_from_syslog(
            skip_regex_str='rvu_af',
            file_path='/var/log/syslogs',
            crash_pattern='Segmentation fault'
        )
        if crash_info:
            print("Crash details found:", crash_info)
        else:
            print("No crash info detected.")
    """
    max_line_num = 15
    if not os.path.exists(file_path):
        logger.console(
            "\nCrash info check in syslog is skipped due to {} does not exist.".format(
                file_path
            )
        )
        return ""
    if os.path.isdir(file_path):
        cmd = f"grep -r -n '{crash_pattern}' {file_path}"
    else:
        cmd = f"grep -n '{crash_pattern}' {file_path}"
    output = os.popen(cmd).read()
    if output:
        logger.console("\n")
        full_crash_info_list = []
        logger.info("Crash information found:")
        logger.info(output)
        for line in output.splitlines():
            if os.path.isdir(file_path):
                syslog_file = line.split(':')[0]
                line_num = int(line.split(':')[1])
                line_content = line.split(':', 2)[2].strip()
            else:
                # For single file, we don't have a directory structure
                syslog_file = file_path
                line_num = int(line.split(':')[0])
                line_content = line.split(':', 1)[1].strip()
            logger.debug("Processing line {} in file {}: {}".format(
                line_num, syslog_file, line_content
            ))
            crash_pattern = re.findall(r'ERR/[A-Za-z0-9]+(?:/[A-Za-z0-9]+)?', line_content)
            if crash_pattern:
                crash_info_pattern_cmd = (
                    f"tail -n +{line_num} {syslog_file} "
                    f"| grep -E '{crash_pattern[0]}' "
                    f"| grep -v '{skip_regex_str}'"
                )
                logger.debug("Executing command to get crash info pattern: {}".format(
                    crash_info_pattern_cmd
                ))
                full_crash_info = os.popen(crash_info_pattern_cmd).read()
                if full_crash_info:
                    if not is_cloud:
                        full_crash_info = re.sub(
                            r'{}/[\w]+.LOG:[\d]+'.format(file_path), '', full_crash_info
                        )
                    full_crash_info_lines = full_crash_info.splitlines()
                    if len(full_crash_info_lines) > max_line_num:
                        console_output = "\n".join(full_crash_info_lines[:max_line_num])
                        logger.warn("Crash info is found (first {} lines):\n".format(max_line_num))
                        logger.console(console_output + "\n")
                    else:
                        logger.warn("Crash info is found:\n")
                        logger.console(full_crash_info)
                    full_crash_info_list.append(full_crash_info + "\n")
                else:
                    logger.warn(
                        f"Failed to get crash info details from syslog for crash:\n {line_content}, \
please check syslog for more details."
                    )
                    full_crash_info_list.append(line_content)
            else:
                logger.warn(
                    f"Failed to get crash pattern from syslog for crash:\n {output}, \
please check syslog for more details."
                )
                full_crash_info_list.append(line_content)
        full_crash_info_str = "\n".join(full_crash_info_list)
        return full_crash_info_str
    else:
        logger.console("\nNo crash info is detected in syslog.")
    return ""


def get_post_check_summary_if_deploy_failed(file_path, save_to_file_path, regex_pattern='post-install-check', ):
    """
    Extracts and saves the post-install check summary from a log file if deployment failed.

    This function searches the specified log file for lines matching the given regex pattern
    (default: 'post-install-check').
    If a "Check summary" line is found, it collects all lines from that point to the end of the log.
    If the last line indicates "Post check successful", it returns without saving anything.
    If a summary is found, it appends a header and the summary to the specified output file.

    Args:
        file_path (str): The path to the log file to search.
        save_to_file_path (str): The path to the file where the summary will be appended.
        regex_pattern (str, optional): The pattern to search for in the log file. Defaults to 'post-install-check'.

    Returns:
        None

    Example:
        get_post_check_summary_if_deploy_failed(
            file_path='/home/ute/Downloads/syslog_20250922132234',
            save_to_file_path='/tmp/gnb_startup_failure.log'
        )
        # If a post-install check summary is found, it will be appended to the output file.
    """
    post_check_log_cmd = f"grep '{regex_pattern}' {file_path}"
    post_check_log = os.popen(post_check_log_cmd).read()
    check_summary = ""
    if post_check_log:
        logger.info("Post-install check summary found:")
        logger.info(post_check_log)
        post_check_log_list = post_check_log.strip().splitlines()
        if post_check_log_list[-1].find("Post check successful") != -1:
            logger.info("Post check successful.")
            return
        start_idx = None
        end_idx = None
        for idx, line in enumerate(post_check_log_list):
            if start_idx is None and line.find("Check summary") != -1:
                start_idx = idx
            if start_idx is not None and line.find("Post check failed") != -1:
                end_idx = idx
                break
        end_idx = end_idx if end_idx is not None else len(post_check_log_list)
        if start_idx is not None and end_idx is not None:
            check_summary = "\n".join(post_check_log_list[start_idx:end_idx])
    else:
        logger.info("No post-install check summary found.")
    if check_summary:
        logger.warn(f"\nPlease check Post-install check summary:\n{check_summary}")
        with open(save_to_file_path, "a") as f:
            f.write("\n>>>>>>>Below logs are about post check summary:<<<<<\n")
            f.write(check_summary + "\n")


if __name__ == '__main__':
    print(get_post_check_summary_if_deploy_failed(
        file_path="/home/ute/Downloads/syslog_20250922132234",
        save_to_file_path="/home/ute/Downloads/gnb_startup_failure.log"
    ))
