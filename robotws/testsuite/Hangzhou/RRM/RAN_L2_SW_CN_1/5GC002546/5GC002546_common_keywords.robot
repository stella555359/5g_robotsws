** Settings ***
Documentation    Author :
...              Squad group : SG_06
...              Feature : 5GC002546-D
Resource          ./../CUDU_L2/common_setup_teardown.robot
Resource          ./../CUDU_L2/common_CA_DSS.robot


*** Variables ***
${ALLOC_SUBFRAME_10M_20M_50_50}    1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001-1000010001
${ALLOC_SUBFRAME_CELL}             0010000000-0111101000-0011100000-0111100000-0011100000-0111101000-0011100000-0011000000
${SCF_FILE_10M}                    ${CURDIR}/resource/2546_10_DSS.xml
${SCF_FILE_10M_PRB}                ${CURDIR}/resource/2546_10_DSS_PRB.xml
${SCF_FILE_20M}                    ${CURDIR}/resource/2546_20_DSS.xml
${SCF_FILE_20M_PRB}                ${CURDIR}/resource/2546_20_DSS_PRB.xml
${IPHY_XML}                        ${CURDIR}/resource/iphy_4F_2T.xml
${LOCAL_WTS_DIR}                   ${CURDIR}/resource
${WTS_CFG_10M}                     basic_wts_2546_10M.cfg
${WTS_AP_XML_NONE}                 airphone.xml
${WTS_CFG_20M}                     basic_wts_2546_20M.cfg
${WTS_CFG_PRB}                     basic_2546.cfg
${ENBID}                            2
${GNBID}                            1
${ALLOC_SUBFRAME1}                  0011100010-0111101110-0011100010-0111101110-0011100010-0111101110-0011100010-0111101110
${PRB_LIST_20M_WITHOUT_BLANKING}    0,5|5,35|101,5
${CELL1_ID}                         1
${MINDL_DSS_RATIO}                  30
${MAXDL_DSS_RATIO}                  100
${MINUL_DSS_RATIO}                  20
${MAXUL_DSS_RATIO}                  70
${ANTP_NUM}                         2



*** Keywords ***
Suite Setup DSS
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    Suite Setup Update GNB    scf_file=${SCF_FILE_10M}    iphy_file=${IPHY_XML}
    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_10M}
    Set Suite Variable    ${WTS_AP_XML}    ${WTS_AP_XML_NONE}
    Set Suite Variable    ${scf_path}    ${LOCAL_WTS_DIR}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Start WTS And Check OnAir DSS
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup XP And Config Resource

Prepare ENV PH3
    [Arguments]    ${SCF_FILE}    ${WTS_CFG_TMP}
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_XML}
    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_TMP}
    Set Suite Variable    ${WTS_AP_XML}    ${WTS_AP_XML_NONE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Start WTS And Check OnAir DSS
    Setup XP LINK
    Enable DSS DMS3 Feature On    ${ENBID}
    Set LTE NR DSS Mode PHASE3    ${ENBID}    ${CELL1_ID}    ${ANTP_NUM}
    Setup XP And Config Resource
    Sleep    30s    reason=dss on

Prepare ENV
    [Arguments]    ${SCF_FILE}    ${WTS_CFG_TMP}
    Run Keyword And Ignore Error    Clean Edaemon And Egate
    Suite Setup Update GNB    scf_file=${SCF_FILE}    iphy_file=${IPHY_XML}
    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_TMP}
    Set Suite Variable    ${WTS_AP_XML}    ${WTS_AP_XML_NONE}
    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
    Start WTS And Check OnAir DSS
    Setup XP LINK
    Set LTE NR DSS Mode
    Setup XP And Config Resource

Setup XP And Config Resource
    Setup DSS Link PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}
    Set DL RESOURCE Cell Reservation    ${MINDL_DSS_RATIO}    ${MAXDL_DSS_RATIO}    ${ENBID}    ${CELL1_ID}
    Cell Resource Coordination PHASE3    ${ENBID}    ${GNBID}    ${CELL1_ID}    DL
    UL Resource Cell Reservation    ${MINUL_DSS_RATIO}    ${MAXUL_DSS_RATIO}    ${ENBID}    ${GNBID}    ${CELL1_ID}
    Cell Allocation    ${ALLOC_SUBFRAME1}    ${PRB_LIST_20M_WITHOUT_BLANKING}    ${ENBID}    ${GNBID}    ${CELL1_ID}
    ute_wtssim.Execute Egate Command    uec_param id\=1 reordering_window_size\=500 reordering_timer\=300

Check CA UE Scell PhycellID
    [Arguments]    ${ue_id}    ${scell_id}
    Save Egate Log
    ${t_scell_id}    Get PhysCellId With UE Id From Egate Log    ${ue_id}    1    ${SUITE_LOG_DIRECTORY}/egate_console.log
    Should Be True    "${scell_id}"=="${t_scell_id}"

A1 Triggered Scell Addition
    [Arguments]    ${ueId}    ${rsrpnr}=80    ${measId}=1
    ${command}    Set Variable    ue_measurement_send_nr id=${ueId} meas_id=${measId} event=A1 srsrp_nr=${rsrpnr} phycell_id=51
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    ${command}    pass_regexp=rrcReconfigurationComplete    timeout=1minutes
    Run Keyword And Ignore Error    Get And Check Scell Infos    ('1', '52', '41')

Start WTS And Check OnAir DSS
    [Arguments]    ${log}=${True}
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Start UTE WTS
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Configure With Parameter    2    1
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="${True}"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Setup X2 Configure With Parameter
    [Arguments]    ${enbid}=2    ${gnbid}=1
    [Documentation]    This keyword is to setup X2 connection and check x2 is ok
    Log To Console    setup X2 connection...
    ${pattern}    Set Variable    ENB-2: X2AP Link with GNB-1 .* is up
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data    enb_x2_link_up enb\=${enbid} target\=${gnbid}
    ...    pass_regexp=${pattern}    timeout=5min
    ${output}    String.Get Lines Matching Regexp    ${output}    ${pattern}    partial_match=True
    Log To Console    \n${output}
    Log    x2_is_ok

SA Attach
    [Arguments]    ${sa_ue_id}
    [Documentation]    This keyword is to start SA UE attach. it includes 3 steps
    ...    ue_register
    ...    set_pdu_param
    ...    ue_pdu_session_setup
    SA 5G Attach    ue_id=${sa_ue_id}
    SA Set Traffic Type To Internal    ue_id=${sa_ue_id}    pdu_id=1
    SA 5G PDU Session Setup    ue_id=${sa_ue_id}

Check UE Pcell Scell Tput On Target
    CA UE Check DL Throughput    1    100
    CA UE Check DL Throughput    2    100
    CA UE Check DL Throughput    3    100
    CA UE Check DL Throughput    4    100

Check UE Pcell Scell Tput On Target 10M
    CA UE Check DL Throughput    1    50
    CA UE Check DL Throughput    2    50
    CA UE Check DL Throughput    3    50
    CA UE Check DL Throughput    4    50

CA UE Check DL Throughput
    [Arguments]    ${ueId}    ${dlTput}
    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=1
    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=2
    SA Start DL Traffic Internal    ue_id=${ueId}    pdu_id=1    mbps=150    trf_id=3
    Wait Until Keyword Succeeds    1min    5s    SA UE Check DL Tput    ${ueId}    ${dlTput}
    ${pcell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    pcell  0
    ${scell_TP}     Get CA Cell Average Throughput      ${ueId}    dl    scell  1
    Log To Console    pcell DL Troughput is ${pcell_TP}    console=True
    Log To Console    scell DL Troughput is ${scell_TP}    console=True

SA UE Check DL Tput
    [Arguments]    ${UE_ID}=11    ${dl_tp_threshold}=5     ${qfi}=1
    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${UE_ID}    pdu_id=1    dir=dl    qfi=${qfi}
    log    DL Troughput is ${dl_tp}    console=True
    ${tp_delta}    Evaluate    ${dl_tp}-${dl_tp_threshold}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${dl_tp_threshold}M \n
    [Return]    ${dl_tp}

Check UE Pcell Scell Tput On Target PRB
    CA UE Check DL Throughput    1    100
    CA UE Check DL Throughput    2    100
    CA UE Check DL Throughput    3    100
    CA UE Check DL Throughput    4    100
    CA UE Check DL Throughput    9    120


