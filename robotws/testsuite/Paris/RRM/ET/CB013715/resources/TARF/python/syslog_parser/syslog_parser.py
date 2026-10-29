"""
scann SYSLOG file for errors
"""
import os
import sys
import traceback
import logging
from argparse import ArgumentParser
from datetime import datetime
import tarfile
import shutil
import tempfile


ONAIR = "OnAirDone"

error_array = ["NOK", "ERR/"]

STOP_PARSING = "INF/L2-PS/src/sgnl/psUser/client/UserDelete.hpp"

DATE = datetime.now().strftime("%Y%m%d%H%M%S%f")

CURRENT_VERSION = "0.10"
# 27.10.2022   0.0 search is not case sensitiv, we find "ERROR "
# and "error " and "Error "
# 24.11.2022   0.1 print only errors which are defined in requirenment file
# 29.11.2022   0.2 serach for ERROR ERR/ WRN/ case insensitive
# 01.12.2022   0.3 stop parsing after first occurence of
#                 "INF/L2-PS/src/sgnl/psUser/client/UserDelete.hpp"
# 30.01.2023   0.4 use logger instead of print cmd + some code improvement
# 04.04.2023   0.5 UserDelete as command line flag (defined with Bernd)
# 17.04.2023   0.6
# - log in a seperate function
# - function find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
#   - will be called with ignorefname, requirementfname instead of
#     exceptionarray, requirementarray
#   - keyparameter insted of positional parameter
# - ignore instead of exception (wording changed -> Thorsten)
# - output filename with milliseconds
# - error_array: NOK added
# 20.04.2023   0.7 read tgz file
# 04.05.2023   0.8 only code improvements no functional extensions
# xx.xx.xxxx   x.x Bernd changed error_array
#   - from ["ERROR ","NOK","ERR/","WRN/","error ","err/","wrn/"]
#   - to ["NOK","ERR/"]
# 26.06.2023   0.9 members of tarfile will be copied in alphabetic order
#                  -> the errormessages in the output file (*.ERRORS) file
#                  will be consecutive
# 06.07.2023   0.10 - use '~/tmp_syslog/$DATE_SYSLOG path to store temporary
#                   unpacked syslog files ( more space available than /tmp )
#                   temporary complete syslog file name: SYSLOG_complete.LOG
#                   - sort unpacked files not alphabetical but according last
#                   modification date (mtime)
#                   - option -a "errordefinition_filename" added
#


logger = logging.getLogger()


def check_strings(search_list, input_string):
    return [s in input_string for s in search_list]


def read_file(filename):
    """
    Reads the content of a file.

    Args:
        filename (str): The path to the file to be read.

    Returns:
        str: The content of the file as a string.
    """
    file_content = []
    try:
        with open(filename, 'r') as inputfile:
            for line in inputfile:
                file_content.append(line.rstrip("\n"))
    except FileNotFoundError:
        raise ValueError("file "+filename+" not found !")

    return file_content


def check_occurence_of_ignore_requirenments(line, ignore_strings,
                                            required_strings):
    """
    check if line contains any error string in error_array.
    all lines containig any of the ignore_strings will be
    skipped
    all lines which do not contain any string defined in
    required_strings will be skipped

    Args:
        line (str): line to be scanned
        ignore_strings (str[]): array of ignore strings
        required_strings(str[]): array of required strings

    Returns:
        line (str): error line if it fullfill the requirements of
                    ignore_strings and requierd_strings
        otherwise None
    """
    for error_string in error_array:
        if error_string in line.upper():
            result = check_strings(ignore_strings, line)
            if True in result:
                # Ignore the error line if it contains ignore string
                pass
            else:
                # Return the error line if it contains any required string or
                # if no required strings are specified
                result = check_strings(required_strings, line)
                if True in result or not required_strings:
                    return line
    return None


def log_infos(outfile, inputfile, start_flag, stop_flag, ignorefname,
              ignore, requirementfname, requirements):
    """
    Logs all information.
    """
    logger.info("\tPARSE SYSLOG FILE FOR ERRORS")
    logger.info("\tinputfile:\t%s", inputfile)
    logger.info("\toutfile:\t%s", outfile)

    logger.info("\tSYSLOG file %s will be scanned for errors: ", inputfile)
    logger.info("\t* all lines containing string")
    for error_str in error_array:
        logger.info("\t  - %s", error_str)
    logger.info("\t* will be stored in %s ", outfile)

    if ignorefname:
        logger.info("\t* Ignore file provided: %s", ignorefname)
        logger.info("\t* ignore those lines with following strings inside:")
        for ignore_str in ignore:
            logger.info("\t  - %s", ignore_str)

    if requirementfname:
        logger.info("\t* Requirement file provided: %s", requirementfname)
        logger.info("\t* only those lines which contains following strings")
        for req_str in requirements:
            logger.info("\t  - %s", req_str)
        logger.info("\t* will be kept in %s", outfile)

    if start_flag:
        logger.info("\t* start parsing after first occurrence of %s", ONAIR)

    if stop_flag:
        logger.info("\t* stop parsing after first occurrence of %s",
                    STOP_PARSING)


def get_outputfile_name(inputfile):
    """
    Provides the name of the output file in following format:
    YYYYMMDDHHMMSSf_<inputfile>.ERRORS
    e.g. for inputfile=SYSLOG_2.LOG: 20230425115319347888_SYSLOG_2.ERRORS

    Args:
        inputfile (str): The path to the file to be read.

    Returns:
        str: The name of the output file.

    """
    outputfile = os.path.join(os.path.dirname(os.path.normpath(inputfile)),
                              DATE +
                              "_" +
                              os.path.splitext(os.path.basename(inputfile))[0] +
                              ".ERRORS")
    return outputfile


def find_errors_and_warnings_in_logfile_and_write_them_into_resultfile(
               inputfile, start_flag=None, stop_flag=None, ignorefname=None,
               requirementfname=None, errordeffname=None):
    """
    Finds errors in inputfile.
    If start_flag is TRUE starts only after fist occurence of "OnAirDone"
    If stop_flag is True stopps after first occurence of
       "INF/L2-PS/src/sgnl/psUser/client/UserDelete.hpp"
    If ignorefname is given then ignore all error lines which
       containes strings defined in this file
    If requirementfname is given take only those error lines
       which contains strings defined in this file

    Args:
        inputfile (str): The path to the file to be read.
        start_flag (bool)
        stop_flag (bool)
        ignorefname (str): name of the file containing ignore strings
        requirementfname (str): name of the file containing required strings

    Returns:
        outputfile (str): name and path of the output file
    """
    global error_array
    try:
        syslog_file_c = get_unpacked_syslog_file(inputfile)
        outputfile = get_outputfile_name(inputfile)
        ignore = get_file_content(ignorefname)
        requirements = get_file_content(requirementfname)
        if errordeffname:
            error_array = get_file_content(errordeffname)
        log_infos(outputfile, inputfile, start_flag, stop_flag, ignorefname,
                  ignore, requirementfname, requirements)

        print_line = True
        if start_flag:
            print_line = False

        with open(outputfile, 'w') as f_out, \
                open(syslog_file_c, encoding="utf8", errors='ignore') as slog:
            for line in slog:
                if start_flag and (ONAIR in line):  # onAirDone
                    print_line = True

                if print_line is True:
                    if stop_flag and (STOP_PARSING in line):
                        return outputfile

                    error_line = check_occurence_of_ignore_requirenments(
                        line, ignore, requirements)
                    if error_line is not None:
                        f_out.write(error_line)

        # remove temporary unpacked syslog files
        if os.path.isdir(os.path.dirname(syslog_file_c)):
            # input("remove temp files ? ")
            shutil.rmtree(os.path.dirname(syslog_file_c))

    except FileNotFoundError:
        logger.error("***ERROR: file not found !!! no output generated !!!")
        traceback.print_exc()
        sys.exit(1)
    except ValueError as e:
        logger.error("\t* %s ", e)
        logger.error("\t* !!! no output generated !!!")
        sys.exit(1)
    except Exception:
        traceback.print_exc()
        sys.exit(1)

    return outputfile


def parse_cmdline_arguments():
    """
    Parse command line arguments.

    Args:
        None

    Returns:
        parser.parse_args()
    """
    parser = ArgumentParser(
             description="parse a SYSLOGFILE for errors except those listed in an \
             IGNOREFNAME file. Default error strings searched for are {}.\
             If you would like to define other error strings please provide an error \
             definition file with the option -a. If a requirement file is provided \
             only those errors are provided. Parsing will be stopped after first  \
             occurence of {} if --UserDelete option is given. The result will be stored in\
             YYYYMMDDHHMMSSf_<SYSLOGFILE>.ERRORS".format(error_array, STOP_PARSING))

    parser.add_argument("-f", "--filename",
                        dest="syslogfile",
                        required=True,
                        help="name of syslogfile to be parsed")

    parser.add_argument("-e", "--ignorefile",
                        dest="ignorefname",
                        help="name of ignore file, means error lines with strings contained \
                        in this ignore file will not be stored in the \
                        output file ")

    parser.add_argument("-r", "--requirementfile",
                        dest="requirementfname",
                        help="name of requirement file, means  ONLY error lines with strings \
                        contained in this requirement file will be stored in \
                        the output file ")

    parser.add_argument("-a", "--errordefinitionfile",
                        dest="errordeffname",
                        help="name of error definition file, containing all error strings \
                        being searched for. If no error definition file is provided for \
                        \"ERR\\\" and \"NOK\" will be searched")

    parser.add_argument("--onAir", help="start parsing after {} found, default start at the\
                        beginning of the SYSLOGFILE".format(ONAIR),
                        action="store_true")

    parser.add_argument("--UserDelete", help="stop parsing after first occurence of {} found,\
                        default stop at the end of the SYSLOGFILE".
                        format(STOP_PARSING),
                        action="store_true")

    parser.add_argument("-v", "--version",
                        action="version",
                        version=CURRENT_VERSION)
    return parser.parse_args()


def get_file_content(filename):
    """
    Reads the content of a file.

    Args:
        filename (str): The path to the file to be read.

    Returns:
        content: The content of the file as a list of strings.
    """
    if filename:
        file = os.path.normpath(filename)
        content = read_file(file)
    else:
        content = ""
    return content


def get_unpacked_syslog_file(log_file):
    """
    Extracts and concatenates syslog files from a compressed archive (tgz)
    or a single file to a temporary directory.

    Args:
        log_file (str): Path to a compressed archive or a single file
                        containing syslog data.

    Returns:
        str: Path to a temporary file containing concatenated syslog data.
    """

    # tmp dir to unpack syslog file tgz
    unpacked_tmp_path = os.path.join(os.path.expanduser('~/tmp_syslog'),
                                     DATE + '_SYSLOG')
    result_file_path = os.path.join(unpacked_tmp_path, 'SYSLOG_complete.LOG')
    try:
        os.makedirs(unpacked_tmp_path)

        if tarfile.is_tarfile(log_file):
            with tarfile.open(log_file, 'r:gz') as tar:
                tar.extractall(path=unpacked_tmp_path)
            file_paths = sorted([os.path.join(unpacked_tmp_path, filename)
                                for filename in os.listdir(unpacked_tmp_path)],
                                key=os.path.getmtime)
            with open(result_file_path, 'wb') as result_file:
                for file_path in file_paths:
                    with open(file_path, 'rb') as source_file:
                        shutil.copyfileobj(source_file, result_file)
        else:
            shutil.copy2(log_file, result_file_path)
    except FileNotFoundError:
        raise ValueError("file "+log_file+" not found")
    return result_file_path


if __name__ == "__main__":

    logging.basicConfig(level=logging.DEBUG)
    cmdargs = parse_cmdline_arguments()
    syslog_file = os.path.normpath(cmdargs.syslogfile)

    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile(
        syslog_file,
        start_flag=cmdargs.onAir,
        stop_flag=cmdargs.UserDelete,
        ignorefname=cmdargs.ignorefname,
        requirementfname=cmdargs.requirementfname,
        errordeffname=cmdargs.errordeffname)
