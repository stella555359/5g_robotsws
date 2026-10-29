*** Settings ***
Documentation
...  Description:   parse syslog file for errors and warnings and write them into a file
...                 an example for how to use "find_errors_and_warnings_in_logfile_and_write_them_into_resultfile" keywrod

Library            syslog_parser.py
Library            OperatingSystem
Library            Process

*** Variables ***

${IGNOREFILENAME}       SYSLOG_ERROR_EXCEPTION.TXT
${REQUIREDFILENAME}     SYSLOG_ERROR_REQUIREMENT.TXT

*** Test Cases ***
Find all Errors in a syslog file and store them in a result file
    [Documentation]      contact:lei.jia@nokia.com
    ...    ${SYSLOG_FILE} can be SYSLOG.tgz or SYSLOG.LOG file
    ...                   for example: /tmp/btslog2/SYSLOG.LOG or /tmp/btslog2/SYSLOG.tgz
    ...    ${errordeffname}: error_array get from this file.
    ...                      ERR/ -> only check errors in syslog
    ...                      ERR/    WRN/-> check both errors and warnings in syslog
    ...    ${ignorefname}: If ignorefname is given then ignore all error lines which
    ...                    containes strings defined in this file.
    ...                    you can define one in your case based on testline issue.
    ...    ${start_flag}:  start_flat should be set to True once gnb is restarted
    ...                    If start_flag is TRUE starts only after fist occurence of "OnAirDone"
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     inputfile=/tmp/btslog2/SYSLOG.tgz
    ...                     errordeffname=testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/syslog_parser/SYSLOG_ERR_ARRAY.TXT
    File Should be Empty    ${outfile}

Find all Errors and Warnings in a syslog file and store them in a result file
    File Should Exist       ${SYSLOG_FILE}
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    Log                     All Errors in ${SYSLOG_FILE} stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     ignorefname=${IGNOREFILENAME}
    Log                     All errors without ignore strings defined in ${IGNOREFILENAME} stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings defined in requirenment file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}    requirementfname=${REQUIREDFILENAME}
    Log                     All errors which are defined in ${REQUIREDFILENAME} are stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings defined in requirenment file except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     ignorefname=${IGNOREFILENAME}
    ...                     requirementfname=${REQUIREDFILENAME}
    Log                     All errors which are defined in ${REQUIREDFILENAME} except those defined in ${IGNOREFILENAME} are stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings in a syslog file after first occurence of OnAirDone
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    Log                     All errors after OnAirDone are stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings after first occurence of OnAirDone except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     ignorefname=${IGNOREFILENAME}
    Log                     All errors after OnAirDone except those defined in ${IGNOREFILENAME} are stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings after first occurence of OnAirDone which are defined in requirenment file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     requirementfname=${REQUIREDFILENAME}
    Log                     All errors after OnAirDone which are defined in ${REQUIREDFILENAME} are stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings after first occurence of OnAirDone which are defined in requirenment file except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     ignorefname=${IGNOREFILENAME}
    ...                     requirementfname=${REQUIREDFILENAME}
    Log                     ALL_ERRORS_ONAIRDONE_REQUIREDFILE_IGNOREFILE
    File Should be Empty    ${outfile}


Find all Errors and Warnings in a syslog file up to USERDELETE cmd and store them in a result file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     stop_flag=${TRUE}
    Log                     All errors until "INF/L2-PS/src/sgnl/psUser/client/UserDelete.hpp" are stored in ${outfile}
    File Should be Empty    ${outfile}


Find all Errors and Warnings up to USERDELETE cmd except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     stop_flag=${TRUE}
    ...                	    ignorefname=${IGNOREFILENAME}
    File Should be Empty    ${outfile}


Find all Errors and Warnings up to USERDELETE cmd defined in requirenment file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     stop_flag=${TRUE}
    ...                     requirementfname=${REQUIREDFILENAME}
    Log                     ALL_ERRORS_REQUIREMENTS_UNTIL_USERDELETE
    File Should be Empty    ${outfile}


Find all Errors and Warnings up to USERDELETE cmd defined in requirenment file except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     stop_flag=${TRUE}
    ...                     ignorefname=${IGNOREFILENAME}
    ...                     requirementfname=${REQUIREDFILENAME}
    Log                     ALL_ERRORS_IGNORE_REQUIREMENTS_UNTIL_USERDELETE
    File Should be Empty    ${outfile}


Find all Errors and Warnings in a syslog file after first occurence of OnAirDone up to USERDELETE cmd and store them in a result file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     stop_flag=${TRUE} 
    Log                     ALL_ERRORS_AFTER_ONAIRDONE_UNTIL_USERDELETE
    File Should be Empty    ${outfile}


Find all Errors and Warnings after first occurence of OnAirDone up to USERDELETE cmd except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     stop_flag=${TRUE}
    ...                     ignorefname=${IGNOREFILENAME}
    Log                     ALL_ERRORS_AFTER_ONAIRDONE_IGNORE_UNTIL_USERDELETE.TXT
    File Should be Empty    ${outfile}


Find all Errors and Warnings after first occurence of OnAirDone up to USERDELETE cmd which are defined in requirenment file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     stop_flag=${TRUE}
    ...                	    requirementfname=${REQUIREDFILENAME}
    Log                     ALL_ERRORS_AFTER_ONAIRDONE_REQUIREMENTS_UNTIL_USERDELETE
    File Should be Empty    ${outfile}


Find all Errors and Warnings after OnAirDone up to USERDELETE cmd which are defined in requirenment file except those defined in ignore file
    ${outfile}              find_errors_and_warnings_in_logfile_and_write_them_into_resultfile
    ...                     ${SYSLOG_FILE}
    ...                     start_flag=${TRUE}
    ...                     stop_flag=${TRUE}
    ...                     ignorefname=${IGNOREFILENAME}
    ...                     requirementfname=${REQUIREDFILENAME}
    Log                     ALL_ERRORS_AFTER_ONAIRDONE_IGNORE_REQUIREMENTS_UNTIL_USERDELETE
    File Should be Empty    ${outfile}

