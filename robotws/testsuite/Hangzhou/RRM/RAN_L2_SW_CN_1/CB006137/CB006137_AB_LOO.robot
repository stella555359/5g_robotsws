*** Settings ***
Documentation    ...
#Resource          ./CB006137_resource.robot
#Resource          ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup       Common Suite Setup
#Test Setup        Common Test Setup 2
#Test Teardown     Common Test Teardown 2    ${True}
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    CN1_SG09_SM3    RAN_5G    RAN_5G_TDD    CRT
#
#*** Variables ***
#${UE_ID}                          1
#${PROFILE_ID}                     1
#${GNB_ID}                         2
#${CELL_ID}                        1
#${BEARER_ID}                      2
#${Egatelog_path}                  ${CURDIR}
#${LOCAL_IPHY_DIR}                 ${CURDIR}/config
#${SCF_DIR}                        ${CURDIR}/config
#${6137_BO_10M_N66_60M_N77_SCF}    ${SCF_DIR}/SCF_BO_5cell.xml
#${WTS_CFG_10M_N66_60M_N77}        wts_config_ASIB_ABIO_FDD_CPRI_cmwv_SANSA_FS_2T3F.cfg
#${IPHY_10M_N66_60M_N77_SCF}       iphy_2T3F_LOO.xml
#
#*** Test Cases ***
#CB006137-ET-AB103_Verify_UL_data_over_Pcell_and_scell_with_blind_scell_addition_and_activation_with_non-BF
#    [Tags]    caseAB103    Fangping    Owner_Susie
#    [Setup]    Setup TL For Each Case    ${6137_BO_10M_N66_60M_N77_SCF}    ${IPHY_10M_N66_60M_N77_SCF}    ${WTS_CFG_10M_N66_60M_N77}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_AB103.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture Ttitrace For AB103
#    SA 5G Detach    ue_id=${UE_ID}
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check Egate Log For Scell UL Configuration
#
#CB006137-ET-AB501_Verify_single_UE_blind_scell_addition_and_bufferBased_activation_by_UL_data_with_BF
#    [Tags]    caseAB501    Johnney    Owner_Susie
#    [Setup]    Setup TL For Each Case    ${6137_BO_10M_N66_60M_N77_SCF}    ${IPHY_10M_N66_60M_N77_SCF}    ${WTS_CFG_10M_N66_60M_N77}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture BIP And Ttitrace For AB501
#    Check Scell Activation From BIP
#    Check Scells Deactivation From BIP
#    SA 5G Detach    ue_id=${UE_ID}
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#
#CB006137-ET-AB703_Verify_single_UE_A1MR_scell_addition_and_bufferBbased_activation_by_DLUL_data_and_A2MR_Scell_release_with_BF
#    [Tags]    caseAB703    Susie    Owner_Susie    CIT
#    [Documentation]
#    ...    lcrId/cellTechnology/Band/physCellId/NR cell ID/chBw
#    ...    cell1    FDD    n71    50    16385    20MHz
#    ...    cell2    FDD    n25    51    16386    20MHz
#    ...    cell3    FDD    n66    52    16387    20MHz
#    ...    cell11   TDD    n77    60    16395    40MHz
#    ...    cell12   TDD    n41    61    16396    60MHz
#    [Setup]    Setup TL For Each Case    ${6137_BO_10M_N66_60M_N77_SCF}    ${IPHY_10M_N66_60M_N77_SCF}    ${WTS_CFG_10M_N66_60M_N77}
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_AB703.xml
#    Delta Commission With SCF File    ${json_file}
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call For AB703
#    SA 5G Detach    ue_id=${UE_ID}
#
#CB006137-ET-AB102_Verify_UCI_over_PUSCH_on_Scell__by_RAD_with_PDU_session_setup_together_with_ICS_blind_scell_addition_and_activation_with_non-BF
#    [Tags]    caseAB102    Anne    Owner_Susie
#    [Setup]    Setup TL For Each Case    ${6137_BO_10M_N66_60M_N77_SCF}    ${IPHY_10M_N66_60M_N77_SCF}    ${WTS_CFG_10M_N66_60M_N77}    true
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_DIR}/delta_AB102.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    Start UTE WTS And Check Cell Setup    ${WTS_CFG_10M_N66_60M_N77}
#    L3 Call And Capture BIP And Ttitrace For AB102
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/1/
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/
#    Check PCSI For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/3/
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/2/
#    Check UL Bler For Each Cell    ${TEST_LOG_DIRECTORY}/ttitrace/3/
#
#*** Keywords ***
#Check Egate Log For Scell UL Configuration
#    Save Egate Log    ${OUTPUT_DIR}
#    OperatingSystem.Run    mv ${OUTPUT_DIR}/egate_console.log ${OUTPUT_DIR}/egate_console-AB103.log
#    ${egate_console_file}=    Set Variable    ${OUTPUT_DIR}/egate_console-AB103.log
#    ${content}=    Grep File    ${egate_console_file}    SCellIndex 1 activated successfully
#    Should Contain    ${content}    SCellIndex 1 activated successfully
#    ta_a2a.Check Log With Au2anlysis    ${CURDIR}/A2A/CB006137_AB_103.ini
#    ...    p    save_log_directory=${OUTPUT_DIR}
#
#L3 Call And Capture Ttitrace For AB103
#    [Arguments]    ${UE_ID}=1    ${dl_tp_set}=175    ${ul_tp_set}=175    ${dl_tp_threshold}=397    ${ul_tp_threshold}=55
#    ...    ${duration}=5
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup For Blind ScellAdd And ScellAct    ue_id=${UE_ID}
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=1
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=2
#    SA Start DL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${dl_tp_set}    trf_id=3
#    SA Start UL Traffic Internal    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp_set}    trf_id=4
#    Sleep    ${duration}s    reason=Wait for bip logs
#    Capture And Decode TTitrace
#    ${list_tp_all}=    _Get Multi SA CA UE Traffic    ${UE_ID}
#    ${time_stamp}=    DateTime.Get Current Date
#    Run    echo "${time_stamp}:${list_tp_all}" >> ${OUTPUT_DIR}/tp_record.txt
#    _Stop Multi SA CA UE Traffic    ${UE_ID}
#    Check UL On Pcell And Scell    ${ul_tp_threshold}    ${list_tp_all}
#    Check DL On Pcell And Scell    ${dl_tp_threshold}    ${list_tp_all}
#
#SA 5G PDU Session Setup For Blind ScellAdd And ScellAct
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session Setup CA...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=SCellIndex 1 activated successfully    timeout=3minutes
#    Log To Console    ${output}
#
#Check PCSI For Each Cell
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcsi.ini    output_ul.csv    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_pcsi_dtx.ini    output_ul.csv    ${csv_file_path}
#
#Capture And Decode TTitrace
#    [Arguments]    ${log_id}=1    ${duration}=5
#    Start Ttitrace With Streaming Mode
#    Sleep    ${duration}s    reason=Wait for logs
#    Stop Ttitrace    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#    Decode Ttitrace Log    log_dir=${TEST_LOG_DIRECTORY}/ttitrace/${log_id}
#
#Common Suite Setup
#    Suite Setup Update GNB    log=${False}
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Configure UTE ETH For GNB3
#    Add RD Parameters To GNB Swconfig File    0x58056B=0
#
#Configure UTE ETH For GNB3
#    [Documentation]    This keyword is to configure VM interfaces.
#    Log To Console    configure VM interfaces...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth1
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth4
#
#L3 Call And Capture BIP And Ttitrace For AB501
#    [Arguments]    ${UE_ID}=1    ${ul_tp}=50    ${ul_tp_threshold}=1
#    ...    ${duration}=3
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup For Blind ScellAdd And Bufferbased ScellAct    ue_id=${UE_ID}
#    Teardown All Connections
#    Start Gnb BIP Log
#    SA Start UL Traffic Internal And Check Scell Activation    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp}    trf_id=1    seconds=600
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/1
#    Sleep    ${duration}s    reason=Wait for bip logs
#    Capture And Decode TTitrace
#    ${list_tp_all}=    _Get Multi SA CA UE Traffic    ${UE_ID}
#    Start Gnb BIP Log
#    SA Stop Data Traffic Internal And Check Scell Deactivation    ue_id=${UE_ID}
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/2
#    Sleep    ${duration}s    reason=Wait for bip logs
#    _Check Muti SA CA UE UL Throughput    ${ul_tp_threshold}    ${list_tp_all}
#
#SA 5G PDU Session Setup For Blind ScellAdd And Bufferbased ScellAct
#    [Arguments]    ${ue_id}
#    Log To Console    start 5G PDU Session Setup CA...
#    ${command}    Set Variable    ue_pdu_session_setup pdu=1 ue=${ue_id} nwslice=1 gw=${ue_id}
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=3minutes
#    Log To Console    ${output}
#
#SA Start UL Traffic Internal And Check Scell Activation
#    [Arguments]    ${ue_id}    ${pdu_id}    ${mbps}    ${trf_id}=1    ${seconds}=60
#    Log To Console    start UL traffic...
#    ${pattern}    Set Variable    SCellIndex 1 activated successfully
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir=ul mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
#    ...    pass_regexp=${pattern}    timeout=5min
#
#SA Stop Data Traffic Internal And Check Scell Deactivation
#    [Arguments]    ${ue_id}    ${pdu_id}=1
#    Log To Console    start stop traffic...
#    ${pattern}    Set Variable    SCellIndex 1 deactivated successfully
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_stop ue\=${ue_id} pdu\=${pdu_id} qfi=1 dir=bi
#    ...    pass_regexp=${pattern}    timeout=5min
#
#Check Scell Activation From BIP
#    [Arguments]    ${id}=1    ${cell_nums}=2
#    Log To Console  verify Scell activation from bip...
#    ${filter}=    Catenate    mac-nr.dlsch.lcid == 0x3A
#    @{csv_title_list}=    Create List    mac-nr.control.scell-act-deact.cell1    mac-nr.control.scell-act-deact.cell2
#    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${id}/5GBipL2L1_filtering*.pcap
#    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scellactive.csv    ${filter}    ${csv_title_list}
#    FOR    ${index}    IN RANGE    1    ${cell_nums}
#    ${active_number}   Get Total Active Number   ${index}
#    Should Be True    ${active_number}>=1
#    END
#
#Get Total Active Number
#    [Arguments]    ${id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scellactive.csv   mac-nr.control.scell-act-deact.cell${id}   ["1"]   include   no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check Scells Deactivation From BIP
#    [Arguments]    ${id}=2    ${cell_nums}=2
#    Log To Console    verify Scells Deactivation from bip...
#    ${filter}=    Catenate    mac-nr.dlsch.lcid == 0x3A
#    @{csv_title_list}=    Create List    mac-nr.control.scell-act-deact.cell1    mac-nr.control.scell-act-deact.cell2
#    Convert BIP to CSV By MCShark    ${TEST_LOG_DIRECTORY}/bip/${id}/5GBipL2L1_filtering*.pcap
#    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scelldeactive.csv    ${filter}    ${csv_title_list}
#    FOR    ${id}    IN RANGE    1    ${cell_nums}
#    ${deactive_number}    Get Total DeActive Number    ${id}
#    Should Be True    ${deactive_number}>=1
#    END
#
#Get Total DeActive Number
#    [Arguments]    ${id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${TEST_LOG_DIRECTORY}/bip/csv_scelldeactive.csv    mac-nr.control.scell-act-deact.cell${id}    ["0"]    include   no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check UL Bler For Each Cell
#    [Arguments]    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_ul_bler.ini    output_ul.csv    ${csv_file_path}
#    A2A_Check_CSV_Table    ${CURDIR}/A2A/ttitrace_ul_no_bler.ini    output_ul.csv    ${csv_file_path}
#
#L3 Call For AB703
#    [Arguments]    ${UE_ID}=1    ${dl_tp}=175    ${ul_tp}=175    ${A1_add}=${True}    ${A2_rel}=${True}
#    Attach Single SA CA UE    ${UE_ID}    ${A1_add}
#    SA Start UL Traffic Internal And Check Scell Activation    ue_id=${UE_ID}    pdu_id=1    mbps=${ul_tp}    trf_id=1    seconds=1800
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=2    seconds=1800
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=3    seconds=1800
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=4    seconds=1800
#    ${pcell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=scell    scell_index=1
#    ${pcell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    ${scell_ul_tp}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=scell    scell_index=1
#    log     DL Troughput of pcell and scell is ${pcell_dl_tp},${scell_dl_tp}
#    log     UL Troughput of pcell and scell is ${pcell_ul_tp},${scell_ul_tp}
#    ${tp_syslog}=    Get Cell Throughput From Btslog    10s
#    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16387    dl    5
#    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16387    ul    5
#    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16395    dl    5
#    Check Cell Throughput Quality From Btslog    ${tp_syslog}    16395    ul    5
#    Check DTXNACK Rate From Ttitrace
#    common_CA.Trigger A2 Scell Release    ${UE_ID}    1    36    60
#    Sleep    10s    reason=wait A2 process
#    ${pcell_dl_tp2}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=dl    cell_type=pcell    scell_index=0
#    ${pcell_ul_tp2}=    Get CA Cell Average Throughput    ue_id=${UE_ID}    dir=ul    cell_type=pcell    scell_index=0
#    Should Be True    ${pcell_dl_tp2}>0
#    Should Be True    ${pcell_ul_tp2}>0
#
#Trigger A1 Scell Addition
#   [Arguments]    ${UE_ID}    ${meas_id}=1    ${srsrp_nr}=126    ${phycell_id}=52
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_measurement_send_nr id=${UE_ID} meas_id=${meas_id} event=A1 srsrp_nr=126 phycell_id=52
#    ...    pass_regexp=rrcReconfigurationComplete
#
#Start SA Internal Traffic
#    [Arguments]    ${ue_id}    ${pdu_id}    ${dir}    ${mbps}    ${trf_id}=1    ${seconds}=6000
#    [Documentation]    This keyword is to start traffic on eGate.
#    ...    Expected output is: "UE IS ACTIVE" on eGate.
#    ...    | Input Parameters | Man. | Description |
#    ...    | ue_id | Yes | ue id |
#    ...    | bearer_id | Yes | bearer_id |
#    ...    | mbps | Yes | mbps |
#    ...    | trf_id | No | trf_id, default is 1 |
#    Log To Console    start Internal traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${ue_id} pdu\=${pdu_id} dir\=${dir} mbps\=${mbps} trf_id\=${trf_id} seconds\=${seconds}
#    Sleep    5s    reason=wait traffic is stable
#
#L3 Call And Capture BIP And Ttitrace For AB102
#    [Arguments]    ${UE_ID}=1    ${ul_tp}=175    ${ul_tp_threshold}=32    ${dl_tp}=175    ${dl_tp_threshold}=397
#    ...    ${duration}=3
#    SA 5G Attach    ue_id=${UE_ID}
#    SA Set Traffic Type To Internal    ue_id=${UE_ID}    pdu_id=1
#    SA 5G PDU Session Setup For Blind ScellAdd And ScellAct    ue_id=${UE_ID}
#    Teardown All Connections
#    Capture BIP And Ttitrace Together        log_id=1
#    Log To Console    start Internal traffic...
#    ute_wtssim.Execute Egate Command
#    ...    cmd=trf_data_start ue\=${UE_ID} pdu\=1 dir\=ul mbps\=150 trf_id\=1 seconds\=1800
#    Sleep    5s    reason=wait traffic is stable
#    Capture BIP And Ttitrace Together        log_id=2
#    ${list_tp_all}=    _Get Multi SA CA UE Traffic    ${UE_ID}
#    Check UL Only On Scell    ${ul_tp_threshold}    ${list_tp_all}
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=ul    mbps=${ul_tp}    trf_id=2    seconds=900
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=3    seconds=900
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=4    seconds=900
#    Start SA Internal Traffic    ue_id=${UE_ID}    pdu_id=1    dir=dl    mbps=${dl_tp}    trf_id=5    seconds=900
#    Capture BIP And Ttitrace Together        log_id=3
#    ${list_tp_all}=    _Get Multi SA CA UE Traffic    ${UE_ID}
#    Check UL Only On Scell    ${ul_tp_threshold}    ${list_tp_all}
#    Check DL On Pcell And Scell    ${dl_tp_threshold}    ${list_tp_all}
#
#Capture BIP And Ttitrace Together
#    [Arguments]    ${log_id}=1    ${duration}=3
#    Capture And Decode TTitrace    ${log_id}    ${duration}
#    Start Gnb BIP Log
#    Sleep    ${duration}s    reason=Wait for bip logs
#    Stop Gnb BIP Log    ${TEST_LOG_DIRECTORY}/bip/${log_id}
#    Sleep    ${duration}s    reason=Wait for bip logs
#
#Check UL Only On Scell
#    [Arguments]    ${ul_tp_threshold}    ${list_tp_all}
#    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
#        Should Be True    ${dic_tp_ue.scell_ul}>${ul_tp_threshold}
#    END
#
#Check UL On Pcell And Scell
#    [Arguments]    ${ul_tp_threshold}    ${list_tp_all}
#    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
#        ${ulsum_tp}    evaluate    ${dic_tp_ue.pcell_ul}+${dic_tp_ue.scell_ul}
#        Log To Console    UL Troughput is ${ulsum_tp}    console=True
#        Should Be True    ${ulsum_tp}>${ul_tp_threshold}
#    END
#
#Check DL On Pcell And Scell
#    [Arguments]    ${dl_tp_threshold}    ${list_tp_all}
#    FOR    ${dic_tp_ue}    IN    @{list_tp_all}
#        ${dlsum_tp}    evaluate    ${dic_tp_ue.pcell_dl}+${dic_tp_ue.scell_dl}
#        Log To Console    DL Troughput is ${dlsum_tp}    console=True
#        Should Be True    ${dlsum_tp}>${dl_tp_threshold}
#    END
#
