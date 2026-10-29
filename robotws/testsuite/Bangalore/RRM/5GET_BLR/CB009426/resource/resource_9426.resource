*** Settings ***
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Library          verify_randomization_A3.py

*** Keywords ***
Capture TTI trace and verify RBG Randomization
     [Arguments]   ${LOG_PATH}   ${filename}
#     Start And Stop Tti Trace Streaming after BWP switch   ${LOG_PATH}/ttitrace_streaming/${filename}
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=1s
     5GC000937_Keywords.Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate Randomization From TTI Trace  ${LOG_PATH}/ttitrace_streaming/${filename}

 Validate Randomization From TTI Trace
    [Arguments]   ${csv_file_path}
    ${Check}   validate_randomization   ${csv_file_path}/output_dl_formated.csv
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Randomization is not matching

