*** Settings ***
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
#Resource         ../../resources/robot/WTS_Runner_Keywords.robot
Library        ta5g_commissioning

Library          verify_randomization.py

*** Keywords ***
Capture TTI trace and verify RBG Randomization
     [Arguments]   ${pysical_cell_ids}   ${LOG_PATH}   ${filename}    ${uernti}=
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=1s
     5GC000937_Keywords.Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate Randomization From TTI Trace  ${LOG_PATH}/ttitrace_streaming/${filename}    ${uernti}

Validate Randomization From TTI Trace
    [Arguments]   ${csv_file_path}    ${uernti}
    ${Check}   validate_randomization   ${csv_file_path}/output_dl_formated.csv    ${uernti}
    run keyword and continue on failure   Run Keyword if   ${Check}!=${True}   Fail   Randomization is not matching

Verify 8955 counters
    [Arguments]    ${cell_id}
    Wait until the next Measurement Period starts
    ${PM_dir1}=     PM_Counters.Collect PM Counter    gnb_id=${0}    collector_alias=pm_counters_gnb1
    Validate PM Counters bigger    PM_dir=${PM_dir1}    PM_counter=M55337C00001    expected_value=0   moc=${cell_id}

Capture TTI Traces and Validate UE bwpid
     [Arguments]   ${LOG_PATH}   ${filename}    ${rnti}   ${bwp}   ${flag}
     Start And Stop Tti Trace Per Cell  ${LOG_PATH}/ttitrace_streaming/${filename}
     ...    pysical_cell_ids=${pysical_cell_ids}    duration=1s
     5GC000937_Keywords.Convert Tti To CSV Mode     ${LOG_PATH}/ttitrace_streaming/${filename}
     Validate UE bwpid from TTI traces    ${LOG_PATH}/ttitrace_streaming/${filename}     ${rnti}   ${bwp}   ${flag}

Perform SCF Delta Commissioning with ${delta_commissioning_file_json}
    Find Scfc And Send Delta Commissioning      scfc_filename=${delta_commissioning_file_json}
Change IPHY File Value
    [Arguments]    ${RU_TYPE}   ${GSCN}
    ${file_path}    Get IPHY XML From Airphone    ${OUTPUT_DIR}
    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "card"|tail -n 2|awk -F'>' '{print $2 }'|awk -F '<' '{print $1}'|
    ${c2}    Set Variable    xargs -I {} sed -i 's/{}/${RU_TYPE}/g' ${file_path}
    Run    ${c1}${c2}

    ${c1}    Set Variable    cat ${file_path}|grep -m 2 "GSCN"|tail -n 2|awk -F'>' '{print $2 }'|
    ${c2}    Set Variable    awk -F '<' '{print $1}'|xargs -I {} sed -i 's/{}/${GSCN}/g' ${file_path}
    Run    ${c1}${c2}
    Send IPHY XML To Airphone   ${file_path}
    Run    ssh toor4nsn@192.168.200.1 reboot
    sleep  120s
