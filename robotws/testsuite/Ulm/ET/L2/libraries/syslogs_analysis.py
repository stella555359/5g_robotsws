import logging
import os
from pathlib import Path


# Robot Framework Libraries:
from robot.libraries.BuiltIn import BuiltIn

# ET or Feature Specific Libraries:
from testsuite.Ulm.ET.L2.libraries.logger import log_begin_end_func_name
from testsuite.Ulm.resources.Common.syslog_parser.syslog_parser import (
    find_errors_and_warnings_in_logfile_and_write_them_into_resultfile)


@log_begin_end_func_name
def check_no_fatality_error_in_syslogs(path_to_syslog_tgz):
    return check_no_error_in_syslogs(path_to_syslog_tgz, "Fatality")


@log_begin_end_func_name
def check_no_error_in_syslogs(path_to_syslog_tgz, error_string):
    is_error_not_in_syslogs = True
    if error_string:
        try:
            outfile = prepare_syslogs_for_analyses(path_to_syslog_tgz)
            if outfile:
                is_error_not_in_syslogs = not search_for_word_in_file(error_string, outfile)
        except Exception as e:
            log_exception("check_no_error_in_syslogs", e)
    return is_error_not_in_syslogs


@log_begin_end_func_name
def check_no_errors_from_list_in_syslogs(path_to_syslog_tgz, error_string_list):
    no_errors_in_syslogs = True
    if error_string_list:
        try:
            outfile = prepare_syslogs_for_analyses(path_to_syslog_tgz)
            if outfile:
                is_any_error_found = False
                for error_string in error_string_list:
                    is_any_error_found = is_any_error_found or search_for_word_in_file(error_string, outfile)
            no_errors_in_syslogs = not is_any_error_found
        except Exception as e:
            log_exception("check_no_errors_from_list_in_syslogs", e)
    return no_errors_in_syslogs


@log_begin_end_func_name
def search_for_word_in_file(word, file_path):
    is_word_found = False
    try:
        if os.path.isfile(file_path):
            logging.info("File exists: %s" % file_path)
            with open(file_path, 'r') as file:
                content = file.read()
                if word in content:
                    is_word_found = True
                    logging.info("'%s' was found" % word)
                else:
                    logging.info("'%s' was NOT found" % word)
        else:
            logging.info("File does NOT exists: %s" % file_path)
    except Exception as e:
        log_exception("search_for_word_in_file", e)
    return is_word_found


@log_begin_end_func_name
def prepare_syslogs_for_analyses(path_to_syslog_tgz):
    outfile = ""
    try:
        absolut_path_to_Ulm = str(Path(__file__).parents[3])
        logging.info("absolut_path_to_Ulm = %s" % absolut_path_to_Ulm)
        EXCEPTIONFILE = absolut_path_to_Ulm + "ET/L2/syslog_parser_resources/SYSLOG_ERROR_EXCEPTION.TXT"
        logging.info("EXCEPTIONFILE = %s" % EXCEPTIONFILE)
        ignorefname = EXCEPTIONFILE if os.path.isfile(EXCEPTIONFILE) else None
        logging.info("ignorefname = %s" % ignorefname)
        max_allowed_file_size = 8000000
        if not os.path.isfile(path_to_syslog_tgz):
            logging.info("SYSLOG File does NOT exists: %s" % path_to_syslog_tgz)
        elif os.path.getsize(path_to_syslog_tgz) > max_allowed_file_size:
            logging.info("SYSLOG File size is larger than allowed: %s Bytes (actual) > %s Bytes (allowed)" %
                         (os.path.getsize(path_to_syslog_tgz), max_allowed_file_size))
        else:
            logging.info("SYSLOG File exists: %s" % path_to_syslog_tgz)
            logging.info("SYSLOG File size is lower than allowed: %s Bytes (actual) < %s Bytes (allowed)" %
                         (os.path.getsize(path_to_syslog_tgz), max_allowed_file_size))
            outfile = find_errors_and_warnings_in_logfile_and_write_them_into_resultfile(
                path_to_syslog_tgz, ignorefname=ignorefname, requirementfname=None)
            logging.info("outfile = %s" % (outfile))
    except Exception as e:
        log_exception("prepare_syslogs_for_analyses", e)
    return outfile


def log_exception(function_name_str, e, silent=False):
    RED = '\033[31m'
    RESET = '\033[0m'
    logging.info("%s(): Exception = <%s>" % (function_name_str, str(e)))
    if not silent:
        BuiltIn().log_to_console("" + RED + "  %s: exception happend (see log.html)" % function_name_str + RESET + "")
