*** Settings ***
Force Tags      CLOUD_5G_I_BLLL_AP_LOO
...             CRT    RAN_5G    5G_RAN_FDD    5G_RAN     SBTS00    CONFIGURED
...             CONFIGS_Bangalore/RRM/ET/CB007798_A_C/CB007798_A_C_config.yaml    PY36

Documentation    :copyright: Nokia
...              :authors: Pradeep
...              :contact: pradeep.k1.singh@nomia.com
...         The aim of the CB007798 feature is to test ACSI support for ABIL hardware


Resource         ../resources/ECEcommon/common_ue_command.robot
Resource         ../resources/ECEcommon/common_admin.robot
Resource         ../resources/ECEcommon/common_setup_teardown.robot
Resource         ../resources/ECEcommon/common_log_analyzer.robot
#Resource          ../CB007798/AirPhone_common_resource_UTE_CR.robot
Resource         ../CB007798/keywords_1817_common_AP.robot
Library           BuiltIn
Library           String
Library           taf.wts.runner    WITH NAME    wtsrunner


Suite Setup       Run Keywords   Common Suite Setup    Set Config Path

#Start WTS Using WTS_Runner          ${wts_cfg_file}

#...                 AND     Check and active the BTS l2ps DBG log
#...               AND        Set Config Path
Suite Teardown    Common Suite Teardown
#Suite Teardown    Run Keywords   Kill WTS processes Using WTS_Runner  #  Run Keyword and Ignore Error
#...                 AND     Run Keyword and Ignore Error    Stop Default Processes And Gather Logs And Compress Logs



*** Variables ***
#${wts_cfg_file}      ${CURDIR}/config/wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS_2CC.cfg
#${WTS_CFG}     wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS_2CC.cfg
##&{WTS}         Ip=127.0.0.1        Username=ute         Connection=Wts
#${WTS_DIR}          /opt/iphy/latest/wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS_2CC.cfg
#${epc_log_path}    /tmp/
#${Large_BWP}      bwp:1
#${PS_BWP}      bwp:2
#@{syslog_regex_bwp}     DCI11   DCI01
${scf_path}    ${CURDIR}
${L3_CALL_TYPE_for_various_case}    "SA_basic_L3CALL"
${NSA_DL}              175
${NSA_UL}              20
${UE_ID}               1
${PROFILE_ID}          1
${GNB_ID}              2
${CELL_ID}             1
${BEARER_ID}           2
${JSON_PATH}           /home/ute/robotws5g/testsuite/migration/Bangalore/RRM/5GET_BLR/CB007798
${DELTA_PATH_20M}      Delta_conf_5GC001817_ET_20M_A001.json
${DELTA_PATH_10M_DRX}    Delta_conf_5GC001817_ET_10M_A006.json
${OPENLOOP_FLAG}     1
${CLOSELOOP_FLAG}     2
#${file_path}          /opt/wts/latest/wts_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS_2CC.cfg
#@{old_values_patts}    ue_nr_capabilities=[0-9a-zA-Z]+
#@{new_values_NSA}    ue_nr_capabilities=${ue_capacity_NSA}
#${ue_capacity_NSA}        E1201000014F5E0342C00201404820D9C4C3E140426C020FFCC31E50B03826010188A01014C200141F11B586368E9315047F2
#                   ...    CA49940220B64C1203063C63FF30C7942C0E070F0113804E0001083011B9343E01C8200000148200000548200000949280000
#                   ...    D300F81B795378195BA40141000009652404000065949010000296524040000E594941000049652424000154B29200BA07174
#                   ...    AA2E81C4D2A89A55115D88020F00340201000000100
#@{new_values_SA}    ue_nr_capabilities=${ue_capacity_SA}
#${ue_capacity_SA}         E1201000014F5E0342C002024024106CE261F0A0609B0083FF30C7942C0E0980406228040531800507C46D618DA3A4C5411FCB2
#                   ...    926500882D930480C18F18FFCC31E50B0381C3C044E01380020000000000420C046E4D0F8072080000052080000152080000252
#                   ...    4A000034C03E06DE54DE0656E900504000025949010000196524040000A594901000039652504000125949090000552CA4802E8
#                   ...    1C5D2A8BA07134AA26954457620181E0068040200000020
${TestLine_Type_NSA}    NSA
${TestLine_Type_SA}    SA
${WTS_CFG_A010_INTERHO}            basic_setup_1.cfg
${WTS_AP_XML}                      wts_ap_config_ASIB_ABIL_FDD_CPRI_cmwv_SANSA_FS_2CC.xml
${LOCAL_WTS_DIR}                   ${CURDIR}/Resource/
${WTS_DIR}                         /opt/wts/latest
*** Test Cases ***

#NSA Test case subfeature E
[1][1.0] CB007798_A002_NSA_A-CSI_Handling_CL_MIMO4x4_256QAM_SUE_15MHZ
    [Timeout]  40min
    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M}     40
    L3 Call With NSA measurement_gap
    Sleep    10s    reason=For the egate log
    Check ACSI Info From Egate Log    ${CLOSELOOP_FLAG}
    Download MCShark To UTE    ${SW_VERSION_TOTAL}
    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A003
    Check l1_common_dtx_t.value in PuschReceiveRespPs    A003
    Check csiPart1CrcCheck in PuschReceiveRespPs    A003
    Check csiPart2CrcCheck in PuschReceiveRespPs    A003
    Check dtxCsiPart1 in PuschReceiveRespPs    A003
    Check dtxCsiPart2 in PuschReceiveRespPs    A003
    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    A003
    Check CRCNOK Rate in PuschReceiveRespHarqU    A003
    [Teardown]    Recover TL For Each Case

#SA Test case subfeature D
#
#     [Timeout]  40min
#    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M}     20
#    L3 Call With SA
#    Sleep    10s    reason=For the egate log
#    Check ACSI Info From Egate Log    ${CLOSELOOP_FLAG}
#    Download MCShark To UTE    ${SW_VERSION_TOTAL}
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_10M
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    A003
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    A003
#    Check csiPart1CrcCheck in PuschReceiveRespPs    A003
#    Check csiPart2CrcCheck in PuschReceiveRespPs    A003
#    Check dtxCsiPart1 in PuschReceiveRespPs    A003
#    Check dtxCsiPart2 in PuschReceiveRespPs    A003
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    A003
#    Check CRCNOK Rate in PuschReceiveRespHarqU    A003
#    [Teardown]    Recover TL For Each Case



*** Keywords ***
Start_capture_testcase_default_logging
    ${TEST_NAME}=       replace string  ${TEST_NAME}      ${SPACE}        _
    set suite variable      ${TEST_NAME}
    Start Default Logging    output_dirpath=${LOG_PATH}/${TEST_NAME}

Setup TL For Test Case
    [Arguments]    ${delta_file}    ${para1}
    Verify Coam Site Is Ready
    Backup Gnb Sw Coniguration
    Modify Gnb Sw Coniguration    ${para1}
    Backup AP Config File
#    Configure Gnb   ${delta_file}
#    Delta Commission Json File With Admin    delta_json=${delta_file}
    Reboot TL And Check Configured
    Suite Setup Start WTS And Check OnAir tc

Recover TL For Each Case
    Recover Gnb Sw Coniguration
    Recover AP Config File
    Recover Config
    Clean Edaemon And Egate
    Stop Edaemon Egate

Backup Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
    SSH.Execute    command=${cmd}    connection=${GNB_ASIK.connection}

Modify Gnb Sw Coniguration
    [Arguments]    ${para1}
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x5900bf=${para1}">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x59006A=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580117=3">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x570010=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580019=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x5900d4=2">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580385=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580422=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580431=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580369=90">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x1003F=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x10040=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x10041=1">>/ffs/run/swconfig.txt'
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "command=crasign /ffs/run/swconfig.txt'


Recover Gnb Sw Coniguration
    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${cmd}'

Backup AP Config File
    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml ./iphy-bak-TA.xml
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 '${cmd}'

Configure Gnb
    [Arguments]    ${delta_file}
    Delta Commission Json File With Admin    delta_json=${delta_file}

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

Set Config Path
    Log To Console    ${SW_VERSION}
    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/config/${SW_VERSION}
    Log To Console    ${JSON_PATH}



L3 Call With NSA measurement_gap
	${UE_ID}=    Set Variable    11
    Setup X2 Connection
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    Measurement Gap Configuration Setup
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
    Start Gnb BIP Log
    Sleep    20s
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20     2
    Sleep    10s    reason=Keep the traffic stable
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    100
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    10
	NSA Stop Traffic    11    2    dl   1
	NSA Stop Traffic    11    2    ul    2
	Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    100
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    10
	NSA LTE Detach     ${UE_ID}


#L3 Call With NSA measurement_gap
#	${UE_ID}=    Set Variable    11
#    Setup X2 Connection
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Measurement Gap Configuration Setup
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    Start Gnb BIP Log
#    Sleep    20s
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20     2
#    Sleep    10s    reason=Keep the traffic stable
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    100
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    10
#	NSA Stop Traffic    11    2    dl   1
#	NSA Stop Traffic    11    2    ul    2
#	Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
##    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    100
##    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    10
#	NSA LTE Detach     ${UE_ID}


L3 Call With NSA
	${UE_ID}=    Set Variable    11
    Setup X2 Connection
    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
    Measurement Gap Configuration Setup
    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
    NSA Verify If Attach Passed
	Start Gnb BIP Log
    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    175    1
    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20    2
    Sleep    10s    reason=Keep the traffic stable
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    100
    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    10
    NSA Stop Traffic    11    2    dl   1
	NSA Stop Traffic    11    2    ul   2
	Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
L3 Call With SA
    SA 5G Attach    ${UE_ID}
    SA Traffic Type Setting     ${UE_ID}
    SA 5G PDU Session Setup    ${UE_ID}
    Start Gnb BIP Log
    SA Start DL Traffic Egate Commands    1    175    1
    SA Start UL Traffic Egate Commands    1    20     2
    Sleep    10s    reason=Keep the traffic stable
    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    dl    100
    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    10
    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
    SA Stop DL Traffic Egate Command    1      1
    SA Stop UL Traffic Egate Command    1      2
    SA 5G Detach    ${UE_ID}

SA Start DL Traffic Egate Commands
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
    ...    cmd=trf_data_start ue\=${ue_id} pdu=1 qfi=1 trf_id\=${trf_id} mbps\=${mbps} dir=dl
    Sleep    2s    reason=wait DL traffic is stable

SA Start UL Traffic Egate Commands
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
    ...    cmd=trf_data_start ue\=${ue_id} pdu=1 qfi=1 trf_id\=${trf_id} mbps\=${mbps} dir=ul
    Sleep    5s    reason=wait UL traffic is stable

#L3 Call With SA
#    [Arguments]    ${ul_zeropadding}    ${ucionly}
#    SA Traffic Type Setting    ${UE_ID}
#    Start Gnb BIP Log
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    SA Start DL Traffic Egate Command    1    20
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...       SA Start UL Traffic Egate Command    1    20
#    Start Gnb BIP Log
#    Run Keyword If    '${ucionly}'=='1'
#    ...    Change CQI For UCIonly SA
#    sleep    4s
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    SA Stop DL Traffic Egate Command    1
#    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    dl    5
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    SA Check Average Traffic Bigger Than Target Egate Command    ${UE_ID}    ul    5
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    SA Stop UL Traffic Egate Command    1\
Measurement Gap Configuration Setup
    ute_wtssim.Execute Egate Command
    ...    cmd=ue_enb_param id=1 measurement_gap=gp6:10 mgta=ms0 gap_purpose=perUE


Check Traffic On NSA In WTS
    [Arguments]    ${throughput_dl}    ${throughput_ul}
    ${check_cmd}    Set Variable    bearer_stats ue=1 id=2 type=l3
    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
    ...    cmd=${check_cmd}    pass_regexp=${WTS_AVG_INTERVAL}    timeout=150
    Create File    /tmp/nsa_traffic.txt    ${output}
    ${avg_dl}    Run    cat /tmp/nsa_traffic.txt | grep -m 2 'Average data rate' | awk '{print $4}' | sed -n '2p'
    ${real_tp_dl}    Evaluate    ${avg_dl}*0.000001
    Should Be True    ${throughput_dl}<=${real_tp_dl}
    ${avg_ul}    Run    cat /tmp/nsa_traffic.txt | grep -m 1 'Average data rate' | awk '{print $4}'
    ${real_tp_ul}    Evaluate    ${avg_ul}*0.000001
    Should Be True    ${throughput_ul}<=${real_tp_ul}

Check ACSI Info From Egate Log
    [Arguments]    ${open_loop_flag}
    Log To Console    \nStart check A-CSI info from egate log.\n
	${openloop_qua}    Set Variable    reportQuantity cri-RI-CQI
	${closeloop_qua}    Set Variable    reportQuantity cri-RI-PMI-CQI
	${config_id}    Set Variable    reportConfigId 1
	${trigger_size}    Set Variable    reportTriggerSize 1
	${check_rst1}    Run Keyword If    '${open_loop_flag}'=='1'
    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${openloop_qua}"|wc -l
    ...    ELSE
    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${closeloop_qua}"|wc -l
	${check_rst2}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${config_id}"|wc -l
	${check_rst3}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${trigger_size}"|wc -l
    Should Be True    ${check_rst1}>=2
	Should Be True    ${check_rst2}>=2
	Should Be True    ${check_rst3}>=1

Common Suite Setup
    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From QT



Convert BIP To CSV By MCShark For 5GC001817-A
    [Arguments]    ${tc_id}
    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}   5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}
    END

Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq
    [Arguments]    ${tc_id}
    Log To Console    Check A-CSI in PdcchSendReq.
    Convert BIP To CSV By MCShark For 5GC001817-A    ${tc_id}
    #A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv

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
    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
    END



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


Modify UE Capbility For 1817C
    [Arguments]    ${TestLine_Type}
    Run Keyword If    '${TestLine_Type}'=="NSA"
    ...    Modify UE Capabilities In CFG    ${file_path}    ${old_values_patts}    ${new_values_NSA}
    Run Keyword If    '${TestLine_Type}'=="SA"
    ...    Modify UE Capabilities In CFG    ${file_path}    ${old_values_patts}    ${new_values_SA}

Delete PM BTS counter file
    BuiltIn.Log To Console    Delete PM BTS counter file on SA
    ${cmd}    Set Variable    rm /tmp/PM.BTS*
    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${cmd}'
    [Teardown]

Check PM counter
    wait until keyword succeeds    30min    1min    Get M55308C11001
    wait until keyword succeeds    1min    10sec    Get M55308C11002
    ${value}    Evaluate    float(${M55308C11002})/float(${M55308C11001})
    should be true    ${value}>2.98
    should be true    ${value}<3.02

Get M55308C11001
    BuiltIn.Log To Console    check M55308C11001...
    #SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}
    #ssh.execute    gunzip /tmp/PM.BTS*.gz
    #ssh.execute    rm /tmp/PM.BTS*.xml
    SSH.Execute    command=gunzip /tmp/PM.BTS*.gz    connection=${GNB_ASIK.connection}
	SSH.Execute    command=rm /tmp/PM.BTS*.xml    connection=${GNB_ASIK.connection}
	#${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep M55308C11001
    ${counter_info1}    SSH.Execute    cat /tmp/PM.BTS* | grep M55308C11001    connection=${GNB_ASIK.connection}
	${M55308C11001_list}    get regexp matches    ${counter_info1}    <M55308C11001>(\\d+)</M55308C11001>    1
    BuiltIn.Log    ${M55308C11001_list}
    ${M55308C11001}    get from list    ${M55308C11001_list}    1
    set suite variable    ${M55308C11001}
    [Teardown]

Get M55308C11002
    BuiltIn.Log To Console    check M55308C11002...
    #SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}
    #${counter_info2}    ssh.execute    cat /tmp/PM.BTS* | grep M55308C11002
	${counter_info2}    SSH.Execute    cat /tmp/PM.BTS* | grep M55308C11002    connection=${GNB_ASIK.connection}
    ${M55308C11002_list}    get regexp matches    ${counter_info2}    <M55308C11002>(\\d+)</M55308C11002>    1


	BuiltIn.Log    ${M55308C11002_list}
    ${M55308C11002}    get from list    ${M55308C11002_list}    1
    set suite variable    ${M55308C11002}
    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect


Suite Setup Start WTS And Check OnAir tc
    [Arguments]        ${log}=yes
    [Documentation]    This keyword is to modify vlan, start WTS, wait for onAir
    Modify UTE SCTP Timeout
    Modify AP SCTP Timeout
    Configure UTE ETH3
    Setup WTS Config
    Start UTE WTS
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    NG Link Should Be UP
#    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    Address Distribution Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SANSA'    UE SIB Decoding Should Be Successful
    Run Keyword If    '${GNBCUTYPE}'=='SA'    UE SIB Decoding
    Run Keyword If    '${GNBCUTYPE}'=='NSA' or '${GNBCUTYPE}'=='SANSA'    Setup X2 Connection
    Verify Cell Setup
    [Teardown]    Run Keyword If    "${log}"=="yes"    common_log_capture.Stop Logs    ${LOG_NAME_SUITE_SETUP}    ${SUITE_LOG_DIRECTORY}

Setup WTS Config
    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_A010_INTERHO}
    Log To Console    ${WTS_CFG}    ${WTS_AP_XML}
    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}

