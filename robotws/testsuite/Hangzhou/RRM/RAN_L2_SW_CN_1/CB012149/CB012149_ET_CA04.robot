*** Settings ***
Suite Setup       Run Keywords    Suite Setup Update GNB    scf_file=${FULL_SCF}    iphy_file=${IPHY_FILE}
...               AND    Suite Setup Copy WTS Config Files From Local
...               local_wts_dir=${WTS_LOCAL}
Suite Teardown    Common Suite Teardown    debug
Force Tags        CLOUD_5G_I_LO_AP_LO
...               SBTS00    SBTS24R3    Pz4_12    CB012149    RAN_5G    RAN_5G_TDD    #CRT
Resource          ./../CUDU_L2/common_setup_teardown.robot
Library          ./Resources/python_keyword_for_ttitrace_filter.py
Library          ./Resources/python_keyword_for_bler_check_in_ttitraceLog.py
Library          ./Resources/python_keyword_for_12149_CA_allow-list_check_in_ttitraceLog.py

*** Variables ***
${SCF_PATH}                       ${CURDIR}/Config
${FULL_SCF}                       CB012149_CA04_scfc.xml
${WTS_LOCAL}                      ${CURDIR}/Resources/wts
${IPHY_FILE}                      ${WTS_LOCAL}/iphy_2T_2F_CA04.xml
${WTS_CFG}                        CB012149_CA04.cfg
${SA_CA_UE_CAP_T_F_9169}   SEPARATOR=${EMPTY}    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C012A3626EB
...    04010D05941A007AD82D2020E1DE38720C38002064F1F57001FF001C007FC00A83E236B04610D04083E5068020B64C55010E7C639F30C7BC7
...    C1E070F013F8000000FE0000000B80001C00158789A001C46000000120E0020268BA000380404402808CF617001800140E0A00E0601300380
...    0341F0040100000000800001007953581B401040000259650100001965340074AA6A01C85801200340E000008080100202008010C58980008
...    101820283038405880889098C9092931394250
#${SA_CA_UE_CAP_T_F_12149}  SEPARATOR=${EMPTY}    E1A00000074E5A031E00038420007824C1900010F09003100D00980C0301C012A3626EB
#...    04010D05941A007AD82D2020E1DE38720C38002064F1F57001FF001C007FC00A83E236B04610D04083E5068020B64C55010E7C639F30C7BC7
#...    C1E070F013F8000000FE0000000B80001C00158789A001C46000000120E006026C04617600070080880501182440584B0F13400388C000004
#...    240800C008101EC2E003000281C1401C0C026007000683E008020000000100000200F2A6B0368040800004B2CA02000032CA680800014B29A
#...    805A553540E6E955D0B002400681C0002101002004040100208080100602008010C58980008101820283038405880889098C909293139425
${ttiPath1}     ttitrace-Ue1HighData-Ue2LowData
${ttiPath2}     ttitraceBothUeHighData
${ttiPath3}     ttitrace-Ue1LowData-Ue2HighData
${ttiPath4}     ttitrace-UE1-peak
${ttiPathPM}     ttitrace-forPM
${ulTtitraceName}      output_ul.csv
@{L2STREAM_COMPONENT_CONFIG}       &{TTITRACE_CONFIG_L2PS}

*** Test Cases ***
CB012149ET-CA04_UE_can_not_enter_to_allow_list_when_FDD_bufe_is_less
    [Setup]    Run Keywords    Wait Until Keyword Succeeds    300sec    15sec    Verify BTS Is Configured
    ...    AND    Suite Setup Start WTS And Check OnAir
    ...    AND    Common Test Setup
#    [Setup]    Run Keywords    Start UTE WTS with cfg file '${WTS_CFG}'    AND    Common Test Setup
    Set egate rrc log 'on'
    UE '1'-'2' Attach with ueCapability '${SA_CA_UE_CAP_T_F_9169}' to Cell '1' and setup PDU Session '1'
    Trigger A1 Scell Addition on UE '1'-'2' by report rsrp '85' on Pcell of phyCell ID '50'
    Start ul Trafficon on UE '1' PDU ID '1' TRF ID '1' with '150'mbps
    Start dl Trafficon on UE '1' PDU ID '1' TRF ID '1' with '100'mbps
    Start ul Trafficon on UE '2' PDU ID '1' TRF ID '1' with '5'mbps
    Wait 'ul' TPut get Target of '100'mbps on UE '1' of PDU ID '1'
    Wait 'ul' TPut get Target of '2'mbps on UE '2' of PDU ID '1'
    Capture Ttitrace for duration '1s' to log dir '${ttiPath1}'
    Start ul Trafficon on UE '2' PDU ID '1' TRF ID '1' with '150'mbps
    Wait 'ul' TPut get Target of '50'mbps on UE '2' of PDU ID '1'
    Capture Ttitrace for duration '1s' to log dir '${ttiPath2}'
    Start ul Trafficon on UE '1' PDU ID '1' TRF ID '1' with '5'mbps
    Wait 'ul' TPut get Target of '100'mbps on UE '2' of PDU ID '1'
    Capture Ttitrace for duration '1s' to log dir '${ttiPath3}'
    Stop 'ul' Traffic on UE '1'-'2' on PDU ID '1'
    SA 5G UE '2'-'2' Detach
    Start ul Trafficon on UE '1' PDU ID '1' TRF ID '1' with '260'mbps
    run keyword and ignore error    Wait 'ul' TPut get Target of '230'mbps on UE '1' of PDU ID '1'
    Capture Ttitrace for duration '1s' to log dir '${ttiPath4}'
    ${ret_AllowList}    Verify UlCaAllowList as expected
    ${bler_status}    Verify ttitrace bler should not high than '0.1'
    ${ret_overlapSchedule}    Verify Scell should be Scheduled on overlap ulSlot
    run keyword and continue on failure    should be true    ${bler_status} and ${ret_AllowList} and ${ret_overlapSchedule}
    Stop 'bi' Traffic on UE '1'-'1' on PDU ID '1'
    Wait until this counter refresh period end
    Start capture Ttitrace
    Start ul Trafficon on UE '1' PDU ID '1' TRF ID '1' with '150'mbps
    Wait 'ul' TPut get Target of '80'mbps on UE '1' of PDU ID '1'
    Stop 'ul' Traffic on UE '1'-'1' on PDU ID '1'
    Stop capture Ttitrace and convert to Excelcsv to log dir '${ttiPathPM}'
    Get Cs2BlockUeReason in ulPreTdBlockUeData
    run keyword and ignore error    Get and Check RD PM Counter
    [Teardown]    run keywords      run keyword and ignore error    SA 5G UE '1'-'1' Detach
    ...      AND    Common Test Teardown    snapshot

*** Keywords ***
Start UTE WTS with cfg file '${WTS_CFG}'
    Start UTE WTS    ${WTS_CFG}

Set egate rrc log '${flag}'
    ute_wtssim.Execute Egate Command    cmd=trace uec\=1 protocol\=rrc,nr_rrc ${flag}

SA 5G Attach on UE '${ue_id}' with UEcap '${ueCapability}'
    Log To Console    start 5G attach...
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    ue_register id\=${ue_id} ue_nr_capabilities\=${ueCapability}
    ...    pass_regexp=REGISTRATION COMPLETE|No response to RRCSetupRequest    timeout=3minutes
    ${ret}=    Run Keyword And Return Status    Should Contain    ${output}    REGISTRATION COMPLETE
    Run Keyword If    "${ret}"=="${False}"    Fail    SA 5G Attach fails!!!
    Should Be True    ${ret}
    ${output1}    String.Get Lines Matching Regexp    ${output}    REGISTRATION COMPLETE    partial_match=${true}
    Log To Console    \n${output1}
    Should Match Regexp    ${output}    Initial UE Message .*Success
    Sleep    3s    reason=wait 5G attach is stable

UE '${sid}'-'${eid}' Attach with ueCapability '${ueCapability}' to Cell '${cell_id}' and setup PDU Session '${pdu_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA 5G Attach on UE '${ue_id}' with UEcap '${ueCapability}'
        SA Set Traffic Type To Internal    ${ue_id}    ${pdu_id}
        SA 5G PDU Session Setup    ${ue_id}    ${pdu_id}
    END

Trigger A1 Scell Addition on UE '${sid}'-'${eid}' by report rsrp '${srsrp_nr}' on Pcell of phyCell ID '${phycell_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        Trigger A1 Scell Addition    ${ue_id}    ${srsrp_nr}    ${phycell_id}
    END

Start ul Trafficon on UE '${ue_id}' PDU ID '${pdu_id}' TRF ID '${trf_id}' with '${mbps}'mbps
    SA Start UL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}

Start dl Trafficon on UE '${ue_id}' PDU ID '${pdu_id}' TRF ID '${trf_id}' with '${mbps}'mbps
    SA Start DL Traffic Internal    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}

Wait '${dir}' TPut get Target of '${target_tput}'mbps on UE '${ue_id}' of PDU ID '${pdu_id}'
   Wait until keyword succeeds    2min  10s    SA Check UE Cell TPut On Target
   ...    ${ue_id}    ${pdu_id}    ${dir}    ${target_tput}

Stop '${dir}' Traffic on UE '${sid}'-'${eid}' on PDU ID '${pdu_id}'
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA Stop Data Traffic Internal    ${ue_id}    ${pdu_id}    ${dir}
    END

SA 5G UE '${sid}'-'${eid}' Detach
    ${eid}          Evaluate          ${eid}+1
    FOR    ${ue_id}    IN RANGE          ${sid}          ${eid}
        SA 5G Detach    ${ue_id}
    END

Capture Ttitrace for duration '${capture_time}' to log dir '${log_dir}'
    Capture Convert Format Ttitrace With Streaming Mode    ${capture_time}    ${TEST_LOG_DIRECTORY}/${log_dir}

Verify ttitrace bler should not high than '${rate}'
    ${ret1}    common_check_harq_info_bler_rate_in_path    ${TEST_LOG_DIRECTORY}/${ttiPath1}/    ${rate}
    ${ret2}    common_check_harq_info_bler_rate_in_path    ${TEST_LOG_DIRECTORY}/${ttiPath2}/    ${rate}
    ${ret3}    common_check_harq_info_bler_rate_in_path    ${TEST_LOG_DIRECTORY}/${ttiPath3}/    ${rate}
    ${ret4}    common_check_harq_info_bler_rate_in_path    ${TEST_LOG_DIRECTORY}/${ttiPath4}/    ${rate}
    [Return]    ${ret1}&${ret2}&${ret3}&${ret4}

Get rntis Id From Egate Log
    ${rnti_reg}=    Set Variable    crnti: (\\d+)
    ute_wtssim.Execute Egate Command    sim_log_set flush
    ${content}=    OperatingSystem.Get File    /opt/iphy/latest/egate_console.log
    ${rntiList}=    String.Get Regexp Matches    ${content}    ${rnti_reg}      1
    ${rnti2}=    Set Variable    ${rntiList}[-1]
    ${rnti1}=    Set Variable    ${rntiList}[-2]
    [Return]    ${rnti1}    ${rnti2}

create_ueList_from_egateLog
    ${ue1rnti1}      ${ue1rnti2}      Get rntis Id From Egate Log
    ${UlCaAllowList_ue1}      Create List      ${ue1rnti1}
    ${UlCaAllowList_ue2}      Create List      ${ue1rnti2}
    ${UlCaAllowList_ue1ue2}      Create List      ${ue1rnti1}      ${ue1rnti2}
    [Return]      ${UlCaAllowList_ue1}      ${UlCaAllowList_ue2}      ${UlCaAllowList_ue1ue2}

check UlCaAllowList in '${filename}' as expected to '${UlCaAllowList_expect}'
    ${ret}    common_check_UlCaAllowList_in_file_as_expected    ${filename}    ${UlCaAllowList_expect}
    [Return]      ${ret}

Verify UlCaAllowList as expected
    ${ListUe1}      ${ListUe2}      ${ListUe12}      create_ueList_from_egateLog
    ${ret1}    check UlCaAllowList in '${TEST_LOG_DIRECTORY}/${ttiPath1}/${ulTtitraceName}' as expected to '${ListUe1}'
    ${ret2}    check UlCaAllowList in '${TEST_LOG_DIRECTORY}/${ttiPath2}/${ulTtitraceName}' as expected to '${ListUe12}'
    ${ret3}    check UlCaAllowList in '${TEST_LOG_DIRECTORY}/${ttiPath3}/${ulTtitraceName}' as expected to '${ListUe2}'
    ${ret4}    check UlCaAllowList in '${TEST_LOG_DIRECTORY}/${ttiPath4}/${ulTtitraceName}' as expected to '${ListUe1}'
    [Return]      ${ret1}&${ret2}&${ret3}&${ret4}

check Scell be Scheduled on overlap ulSlot in '${filename}' with filter '${Scell_overlapULSlot_filter}'
    ${ret}    python_keyword_for_ttitrace_filter.common_filter_in_ttitraceLog
    ...    ${filename}      ${Scell_overlapULSlot_filter}
    [Return]      ${ret}

check scell be Scheduled on overlap ulSlot in '${filename}' with multi filter
    @{Scell_overlapULSlot_filter1}      Create List      ulFdSchedData.ueType==SCELL      slot==2
    @{Scell_overlapULSlot_filter2}      Create List      ulFdSchedData.ueType==SCELL      slot==4
    @{Scell_overlapULSlot_filter3}      Create List      ulFdSchedData.ueType==SCELL      slot==7
    @{Scell_overlapULSlot_filter4}      Create List      ulFdSchedData.ueType==SCELL      slot==9
    @{filterList}      Create List      ${Scell_overlapULSlot_filter1}      ${Scell_overlapULSlot_filter2}
    ...    ${Scell_overlapULSlot_filter3}      ${Scell_overlapULSlot_filter4}
    ${ret}    set variable      True
    FOR    ${filter}    IN    @{filterList}
        ${count}    check Scell be Scheduled on overlap ulSlot in '${filename}' with filter '${filter}'
        ${ret1}      Evaluate      ${count}>0
        ${ret}    set variable      ${ret}&${ret1}
    END
    [Return]      ${ret}

Verify Scell should be Scheduled on overlap ulSlot
    ${path1}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath1}/${ulTtitraceName}
    ${path2}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath2}/${ulTtitraceName}
    ${path3}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath3}/${ulTtitraceName}
    ${ret1}    check scell be Scheduled on overlap ulSlot in '${path1}' with multi filter
    ${ret2}    check scell be Scheduled on overlap ulSlot in '${path2}' with multi filter
    ${ret3}    check scell be Scheduled on overlap ulSlot in '${path3}' with multi filter
    [Return]      ${ret1}&${ret2}&${ret3}

Wait until this counter refresh period end
    #<p name="miNrUlHarqOne">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for the period end.
    Sleep    5s    wait for a while.

Start capture Ttitrace
    common_Log_capture.Start Ttitrace With Streaming Mode

Stop capture Ttitrace and convert to Excelcsv to log dir '${log_dir}'
    Sleep    5s    wait for a while.
    common_Log_capture.Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/${log_dir}
    common_Log_analyzer.Convert Ttitrace From Pcap To Excelcsv    ${TEST_LOG_DIRECTORY}/${log_dir}

Get Cs2BlockUeReason in ulPreTdBlockUeData
    ${path1}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath1}/${ulTtitraceName}
    ${path2}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath2}/${ulTtitraceName}
    ${path3}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath3}/${ulTtitraceName}
    ${path4}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPath4}/${ulTtitraceName}
    ${pathPM}=    Set Variable    ${TEST_LOG_DIRECTORY}/${ttiPathPM}/${ulTtitraceName}
    @{pathList}      Create List    ${path1}    ${path2}    ${path3}    ${path4}    ${pathPM}
    ${columnName}=    Set Variable    ulPreTdBlockUeData.cs2BlockUeList
    FOR    ${path}    IN    @{pathList}
        ${ret}    common_get_column_value_summarize_in_file   ${path}    ${columnName}
        run keyword if   ${ret} !={}     Log    ${path}       WARN
        run keyword if   ${ret} !={}     Log    ${ret}      WARN
    END

Gunzip RD Counter File
    #<p name="miNrUlHarqOne">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    2s    wait pm counter file generated stable.
    OperatingSystem.Run    sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.1:/tmp/RD.BTS* ${TEST_LOG_DIRECTORY}/
    OperatingSystem.Run And Return Rc And Output    gunzip ${TEST_LOG_DIRECTORY}/RD.BTS*.gz

Get RD counter value from xml
    [Arguments]    ${counter}    ${cellid}=1
    ${counter_info}    OperatingSystem.Run    cat ${TEST_LOG_DIRECTORY}/RD.BTS*.xml|grep ${counter}
    ${Scell_var}    Set Variable    PLMN-PLMN\/MRBTS-1\/NRBTS-1\/NRCELL-${cellid}<\/DN><\/MO><NE-WBTS_1.0 measurementType="NCADU">
    ${count_var}    Set Variable    \\S+<${counter}>(?P<couner_num>\\d+)<\/${counter}>
    ${regex} =    Catenate    SEPARATOR=    ${Scell_var}    ${count_var}
    Log To Console    ${regex}
    ${scell}    Get Regexp Matches    ${counter_info}    ${regex}    1
    ${len}    Get Length    ${scell}
    FOR    ${id}    IN RANGE    0    ${len}
        ${counter_value}    Get From List    ${scell}    ${id}
        Exit For Loop If    '${counter_value}'>'0'
    END
    [Return]      ${counter_value}
#    Log To Console    \n ${counter} is ${counter_value}\n
#    should be true    ${counter_value}>0

Get and Check RD PM Counter
    Gunzip RD Counter File
    ${counter1}    Get RD counter value from xml      ACC_NUM_UL_CA_TDD_AL
    ${counter2}    Get RD counter value from xml      ACC_NUM_UL_CA_TDD_AL_FAIL_SCHD
    [Return]      ${counter1}      ${counter2}

Get and Check PM Counter
    #<p name="miNrUlHarqOne">5min</p>
    ${time}=    ta_kiss_gnb.Get Counter File Remaining Time    counter_refresh_period=5min
    Log To Console    to reach next pm counter update time, need to wait ${time}...
    Sleep    ${time}    wait for pm counter file updated.
    Sleep    20s    wait pm counter file generated stable.
    ${file_name}=    ta_kiss_gnb.Download Latest Pmcounter    ${TEST_LOG_DIRECTORY}/test_pmcounter.gz
    ${ACC_NUM_UL_CA_TDD_AL1}=
    ...    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55370CRD50000    cell_id=1
    ${ACC_NUM_UL_CA_TDD_AL2}=
    ...    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55370CRD50000    cell_id=3
#    Run Keyword And Continue On Failure    should Be True    "${ACC_NUM_UL_CA_TDD_AL1}"=="1"
    ${ACC_NUM_UL_CA_TDD_AL_FAIL_SCHD1}=
    ...    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55370CRD50001    cell_id=1
    ${ACC_NUM_UL_CA_TDD_AL_FAIL_SCHD3}=
    ...    ta_kiss_gnb.Get Counter Value From Counter File    ${file_name}    M55370CRD50001    cell_id=3
#    Run Keyword And Continue On Failure    should Be True    "${ACC_NUM_UL_CA_TDD_AL_FAIL_SCHD1}"=="0"
#    M55370CRD50000      ACC_NUM_UL_CA_TDD_AL
#    M55370CRD50001      ACC_NUM_UL_CA_TDD_AL_FAIL_SCHD
