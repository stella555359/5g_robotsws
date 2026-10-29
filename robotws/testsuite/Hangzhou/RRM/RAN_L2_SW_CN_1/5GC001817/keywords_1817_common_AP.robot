*** Settings ***
#Library          ./../CUDU_L2/scripts/python/egate_operator.py
Library          ute_ue
*** Keywords ***
Prepare TL And Suite Setup
    Suite Setup Copy WTS Config Files From Local    ${CURDIR}/config/
    Suite Setup Update GNB    swconfig_param=${RD}    scf_file=${SCF_BASIC}    iphy_file=${IPHY_BASIC}
    Backup Scf    ${OUTPUT_DIR}    before_suite

Set Config Path
    Log To Console    ${SW_BRANCH}
    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/${SW_BRANCH}/SCF/
    Log To Console    ${JSON_PATH}

Modify UE Capbility For 1817C
    [Arguments]    ${TestLine_Type}
    Run Keyword If    '${TestLine_Type}'=="NSA"
    ...    Modify UE Capabilities In CFG    ${WTS_DIR}/${WTS_CFG}    ${old_values_patts}    ${new_values_NSA}
    Run Keyword If    '${TestLine_Type}'=="SA"
    ...    Modify UE Capabilities In CFG    ${WTS_DIR}/${WTS_CFG}    ${old_values_patts}    ${new_values_SA}

Backup Gnb Sw Configuration
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
#    SSH.Execute    command=${cmd}    connection=${GNB_ASIK.connection}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${cmd}'

Modify Gnb Sw Configuration 1817-C
    [Arguments]    ${EnableDynBetaOff}    ${EnableBetaOptimistic}    ${ACsiCheckDlLoad}    ${ucionly}
    ...    ${ModeratePayloadSizeThr}    ${CqiJitterTimer}    ${AcsiHighJitterTimer}    ${CqiDeltaThreshold}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x5900d4=${EnableDynBetaOff}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580385=${EnableBetaOptimistic}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580422=${ACsiCheckDlLoad}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580431=${ucionly}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580384=${ModeratePayloadSizeThr}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x58041f=${CqiJitterTimer}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580420=${AcsiHighJitterTimer}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x58045D=${CqiDeltaThreshold}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580458=${CqiDeltaThreshold}">>/ffs/run/swconfig.txt'
    #Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x59004D=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'crasign /ffs/run/swconfig.txt'

Recover Gnb Sw Configuration
    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'

Backup AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml ./iphy-bak-TA.xml
#    SSH.Execute    command=${cmd}    connection=${AP_ASIK.connection}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 '${cmd}'

Configure Gnb
    [Arguments]    ${delta_file}
    Delta Commission Json File With Admin    delta_json=${delta_file}

Configure Airphone
    [Arguments]    ${gscn}
    ${cmd}    Set Variable    sed -i "s|<GSCN>[0-9]*<\/GSCN>|<GSCN>${gscn}<\/GSCN>|" /ffs/run/simmode/iphy.xml
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 '${cmd}'

Recover AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;rm -rf ./iphy.xml;mv iphy-bak-TA.xml iphy.xml
    OperatingSystem.Run And Return Rc And Output
    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'

Recover Config
    ${bts_id}    Get BTS Id
    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
    Log To Console    recover gnb configuratio...
    COAM.Perform Commissioning
    ...    bts_id=${bts_id}
    ...    scf_file=${OUTPUT_DIR}/SCF_before_suite.xml
    ...    skip_parameter_relation_errors=True
    ...    should_activate=True
    ...    timeout=500
    Run Keyword And Ignore Error    COAM.Teardown

Check ACSI Info From Egate Log
    [Arguments]    ${open_loop_flag}
    Log To Console    \nStart check A-CSI info from egate log.\n
    ${openloop_qua}    Set Variable    reportQuantity cri-RI-CQI
    ${closeloop_qua}    Set Variable    reportQuantity cri-RI-PMI-CQI
    ${config_id}    Set Variable    reportConfigId 1
    ${trigger_size}    Set Variable    reportTriggerSize 1

    ${check_rst1}    Run Keyword If    '${open_loop_flag}'=='OpenLoop'
    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${openloop_qua}"|wc -l
    ...    ELSE
    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${closeloop_qua}"|wc -l
    ${check_rst2}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${config_id}"|wc -l
    ${check_rst3}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${trigger_size}"|wc -l
    Should Be True    ${check_rst1}>=2
    Should Be True    ${check_rst2}>=2
    Should Be True    ${check_rst3}>=1

Check BetaOffsets From Egate Log
    [Arguments]    ${sa_flag}
    Log To Console    \nStart check betaOffset info from egate log.\n
    ${betaoffset}    Set Variable    betaOffset
    ${check_rst}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${betaoffset}"|wc -l
    Run Keyword If    '${sa_flag}'=='SA'
    ...    Should Be True    ${check_rst}==37 or ${check_rst}==39 or ${check_rst}==40
    Run Keyword If    '${sa_flag}'=='NSA'
    ...    Should Be True    ${check_rst}==29 or ${check_rst}==31

Convert BIP To CSV By MCShark For 5GC001817-A
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}

Check l1_common_dtx_t.value in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check DTX in Ul PuschReceiveRespPs.
    ${total_number}    Get Total l1_common_dtx_t.value Number    ${tc_id}
    ${failed_number}    Get Total Failed l1_common_dtx_t.value Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    DTX Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total l1_common_dtx_t.value Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed l1_common_dtx_t.value Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check csiPart1CrcCheck in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check csiPart1CrcCheck in Ul PuschReceiveRespPs.
    ${total_number}    Get Total csiPart1CrcCheck Number    ${tc_id}
    ${failed_number}    Get Total Failed csiPart1CrcCheck Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    CRCNOK Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total csiPart1CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed csiPart1CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check csiPart2CrcCheck in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check csiPart2CrcCheck in Ul PuschReceiveRespPs.
    ${total_number}    Get Total csiPart2CrcCheck Number    ${tc_id}
    ${failed_number}    Get Total Failed csiPart2CrcCheck Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    CRCNOK Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total csiPart2CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed csiPart2CrcCheck Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check dtxCsiPart1 in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check dtxCsiPart1 in Ul PuschReceiveRespPs.
    ${total_number}    Get Total dtxCsiPart1 Number    ${tc_id}
    ${failed_number}    Get Total Failed dtxCsiPart1 Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    dtxCsiPart1 Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total dtxCsiPart1 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed dtxCsiPart1 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Check dtxCsiPart2 in PuschReceiveRespPs
    [Arguments]    ${tc_id}
    Log To Console    Check dtxCsiPart2 in Ul PuschReceiveRespPs.
    ${total_number}    Get Total dtxCsiPart2 Number    ${tc_id}
    ${failed_number}    Get Total Failed dtxCsiPart2 Number    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    dtxCsiPart2 Rate is ${rate}
    Should Be True    ${rate}<0.1

Get Total dtxCsiPart2 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1", "0"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed dtxCsiPart2 Number
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Convert BIP To CSV By MCShark For PuschReceiveRespHarqU
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    uldata_puschreceiverespharqu
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
    ...    UlData_UePuschReceiveRespHarqU_t.dtx
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}

Check CRCNOK Rate in PuschReceiveRespHarqU
    [Arguments]    ${tc_id}
    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU.
    ${total_number}    Get Total UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
    ${failed_number}    Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
    ${rate}    Evaluate    float(${failed_number})/(${total_number})
    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU is ${rate}
    Should Be True    ${rate}<0.1

Get Total UlDataPuschReceiveRespHarqU Message Number 1817
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["0", "1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817
    [Arguments]    ${tc_id}
    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["1"]    include    no
    ${count}    Get Length    ${data_list}
    [Return]    ${count}

Convert BIP To CSV By MCShark For 5GC001817-C
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
    @{csv_title_list}=    Create List    3gpp.sfn    dci.dci01.CSIrequest
    ...    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_c.csv    ${filter}    ${csv_title_list}
    Convert BIP To CSV By MCShark   ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_c.csv    ${filter}    ${csv_title_list}

Check_Betaoffset_MCShark
    [Arguments]    ${tc_id}
    Convert BIP To CSV By MCShark For 5GC001817-C    ${tc_id}
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_c.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_c.csv

Convert BIP To CSV By MCShark For 5GC001817 Ucionly
    [Arguments]    ${tc_id}
    ${filter}=    Catenate    dci.dci01.CSIrequest==1||UlData_UePuschReceiveRespPs_t.numOfUciCsiPart2Bits >0
    ...    ||(UlData_pucchReceiveRespPsPucchResource_t.pucchFormat == 3&&uldata_pucchreceiverespps)
    @{csv_title_list}=    Create List    3gpp.sfn    uci.cqi     dci.dci01.CSIrequest    uci.pucch.ucibits
    Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_cucionly.csv    ${filter}    ${csv_title_list}
    Convert BIP To CSV By MCShark    ${SUITE_LOG_DIRECTORY}/5GBipL2L1_filtering_off*.pcap*
    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_cucionly.csv    ${filter}    ${csv_title_list}

Check_Ucionly_MCShark
    [Arguments]    ${tc_id}
    Log To Console    Ucionly in MCShark...
    Convert BIP To CSV By MCShark For 5GC001817 Ucionly    ${tc_id}
    CALC CSV UCIBITS AS CQI    ${OUTPUT_DIR}/csv_TC${tc_id}_cucionly.csv    ${OUTPUT_DIR}/csv_TC${tc_id}_c_new.csv
    ...    uci.pucch.ucibits    uciBits.qci
    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_2.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_c_new.csv

SA Traffic Type Setting
    [Arguments]    ${ue_id}
    ute_wtssim.Execute Egate Command    cmd=set_pdu_param ue=${ue_id} pdu=1 trf_type=internal

SA Start DL Traffic Egate Command
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start DL Traffic | 1 | 2 | 10 |
    Log To Console    start DL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu=1 qfi=1 trf_id\=${trf_id} mbps\=${mbps} dir=dl size=500 seconds=180
    Sleep    5s    reason=wait DL traffic is stable

SA Start UL Traffic Egate Command
    [Arguments]    ${ue_id}    ${mbps}    ${trf_id}=1
    [Documentation]    This keyword is to start traffic on eGate.
    ...    Expected output is: "UE IS ACTIVE" on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | mbps | Yes | mbps |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Start UL Traffic | 1 | 2 | 10 |
    Log To Console    start UL traffic...
    ute_wtssim.Execute Egate Command
    ...    cmd=trf_data_start ue\=${ue_id} pdu=1 qfi=1 trf_id\=${trf_id} mbps\=${mbps} size=500 dir=ul seconds=180
    Sleep    5s    reason=wait UL traffic is stable

SA Stop DL Traffic Egate Command
    [Arguments]    ${ue_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Stop Traffic | 1 | 2 | dl |
    Log To Console    stop SA UL&DL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu=1 qfi=1 dir=dl trf_id\=${trf_id}

SA Stop UL Traffic Egate Command
    [Arguments]    ${ue_id}    ${trf_id}=1
    [Documentation]    This keyword is to stop traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | ue_id | Yes | ue id |
    ...    | bearer_id | Yes | bearer_id |
    ...    | dir | Yes | ul or dl |
    ...    | trf_id | No | trf_id, default is 1 |
    ...    Example:
    ...    | NSA Stop Traffic | 1 | 2 | dl |
    Log To Console    stop SA UL&DL traffic...\n
    ute_wtssim.Execute Egate Command    cmd=trf_data_stop ue\=${ue_id} pdu=1 qfi=1 dir=ul trf_id\=${trf_id}

SA Check Average Traffic Bigger Than Target Egate Command
    [Arguments]    ${ue_id}    ${dir}    ${tp_rate}
    [Documentation]    This keyword is to Check traffic on eGate.
    ...    | Input Parameters | Man. | Description |
    ...    | dir | Yes | Direction of Traffic |
    ...    | tp_rate | Yes | Throughput Rate for traffic |
    ...    Example:
    ...    | SA Check Average Traffic bigger than target | 1 | 2 | ul | 10 |
    ...    | SA Check Average Traffic bigger than target | 1 | 2 | dl | 10 |
    ${output}    ute_wtssim.Execute Egate Command    cmd=qfi_stats ue\=${ue_id} pdu=1 qfi=1 type=l3 dir\=${dir}
    ...    pass_regexp=Average packet interval    timeout=150
    OperatingSystem.Create File    /tmp/${dir}.txt    ${output}
    ${avg}    OperatingSystem.Run    cat /tmp/${dir}.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${mavg}    Evaluate    ${avg}*0.000001
    Log To Console    \n The average ${dir} tput is: ${mavg}M \n
    ${tp_delta}    Evaluate    ${avg}*0.000001-${tp_rate}
    Should Be True    ${tp_delta}>=0    Throughtput is not in the accetable range
    Log To Console    The TPUT is bigger than target: ${tp_rate}M \n



