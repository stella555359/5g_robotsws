*** Settings ***
Documentation    ...
##Suite Setup       Run Keywords   Common Suite Setup    Set Config Path    #Download MCShark To UTE
#Suite Setup       Run Keywords   Prepare TL And Suite Setup    Set Config Path
#Suite Teardown    Common Suite Teardown
#
#Force Tags        Force Tags        Classical    IPV4    FR1    PRI-High    SBTS00    SBTS23R1
#...               5GC001817     CRT
#...               RAN_5G    RAN_5G_FDD    CN1_SQ    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ../5GC001808/AirPhone_common_resource_UTE_CR.robot
#Resource          ../5GC001817/keywords_1817_common_AP.robot
#Library           BuiltIn
#Library           String
#Library           taf.wts.runner    WITH NAME    wtsrunner
#Library           ../5GC001817/csv_bit_to_qci.py
#
#*** Variables ***
#${scf_path}    ${CURDIR}
#${L3_CALL_TYPE_for_various_case}    "SA_basic_L3CALL"
#${NSA_DL}              5
#${NSA_UL}              5
#${GSCN_10M_CA002}          1582
#${GSCN_20M}          1
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
##${JSON_PATH}           /home/ute/Auto5G/testsuite/RRM/ECE/5GC001817/
#${DELTA_PATH_20M}      Delta_conf_5GC001817_ET_20M_A005.json
#${DELTA_PATH_10M_DRX}    Delta_conf_5GC001817_ET_10M_A006.json
#${file_path}          /opt/wts/latest/wts_config_LO_AP_LO_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
#@{old_values_patts}    ue_nr_capabilities=[0-9a-zA-Z]+
#@{new_values_NSA}    ue_nr_capabilities=${ue_capacity_NSA}
#${ue_capacity_NSA}        E1201000014F5E0342C00201404820D9C4C3E140426C020FFCC31E50B03826010188A01014C200141F11B586368E9315047F2
#                   ...    CA49940220B64C1203063C63FF30C7942C0E070F0113804E0001083011B9343E01C8200000148200000548200000949280000
#                   ...    D300F81B795378195BA40141000009652404000065949010000296524040000E594941000049652424000154B29200BA07174
#                   ...    AA2E81C4D2A89A55115D88020F00340201000000100
#@{new_values_SA}    ue_nr_capabilities=${ue_capacity_SA}
#${ue_capacity_SA}         E1A01000014F5E0342C0020640024106CE261F0A1201360107FE618F28581C130080C450180531800507C46D618DA3A4C5411FCB
#                   ...    29265048082D930480C18F18FFCC31E50B0381C3C04CEC3B0CEC3B004003000000000711800000001083011B9343E01C82000001
#                   ...    48200000548200000949280000D300B81B791B5BA40141000009652404000065949010000296524040000E594941000049652424
#                   ...    000154B292009A071748E2E8544D2A88AEC409007801A01008000000000020040084
#${TestLine_Type_NSA}    NSA
#${TestLine_Type_SA}    SA
#${OPENLOOP_FLAG}     OpenLoop
#${CLOSELOOP_FLAG}     CloseLoop
#${NO_UL_ZEROPADDING}    False
#${UL_ZEROPADDING}    True
#${UciOnly_False}    0
#${UciOnly_True}    1
#${WTS_CFG}        wts_config_LO_AP_LO_FDD_CPRI_cmwv_SANSA_FS_2S_1CC.cfg
#${SCF_BASIC}         ${CURDIR}/config/scf_2F.xml
#${IPHY_BASIC}        ${CURDIR}/config/iphy_2F.xml
#${RD}             0x4B000F=1
#
#
#*** Test Cases ***
#5GC001817_A005_SA_NSA_OL_MIMO4_2_MG_Enable_20Mhz_UL_64QAM_UeCap_withoutPMI_SUE
#    [Documentation]    The purpose
#    [Tags]    Owner_y1xin    case_A005
#    [setup]   Modify UE Capbility For 1817C    ${TestLine_Type_NSA}
#    [Timeout]  40min
#    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_20M}     20
#    L3 Call With NSA measurement_gap
#    Sleep    10s    reason=For the egate log
#    Check ACSI Info From Egate Log    1
#    #Download MCShark To UTE    ${SW_VERSION_TOTAL}
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    001
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    001
#    Check csiPart1CrcCheck in PuschReceiveRespPs    001
#    Check csiPart2CrcCheck in PuschReceiveRespPs    001
#    Check dtxCsiPart1 in PuschReceiveRespPs    001
#    Check dtxCsiPart2 in PuschReceiveRespPs    001
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    001
#    [Teardown]    Recover TL For Each Case
#
##5GC001817_A006_SA_NSA_CL_MIMO4_2_DRX_Enable_10Mhz_Ulzeropadding_256QAM_SUE
##    [Documentation]    The purpose
##    [Tags]    Owner_xinwang    case_A006
##    [setup]   Modify UE Capbility For 1817C    ${TestLine_Type_NSA}
##    [Timeout]  40min
##    Delete PM BTS counter file
##    Setup TL For Test Case   ${JSON_PATH}/${DELTA_PATH_10M_DRX}     20
##    L3 Call With NSA
##    Sleep    10s    reason=For the egate log
##    Check ACSI Info From Egate Log    0
##    Download MCShark To UTE    ${SW_VERSION_TOTAL}
##    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_c_20M
##    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq    006
##    Check l1_common_dtx_t.value in PuschReceiveRespPs    006
##    Check csiPart1CrcCheck in PuschReceiveRespPs    006
##    Check csiPart2CrcCheck in PuschReceiveRespPs    006
##    Check dtxCsiPart1 in PuschReceiveRespPs    006
##    Check dtxCsiPart2 in PuschReceiveRespPs    006
##    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU    006
##    [Teardown]    Recover TL For Each Case
#
#*** Keywords ***
#Setup TL For Test Case
#    [Arguments]    ${delta_file}    ${para1}
#    Verify Coam Site Is Ready
#    Backup Gnb Sw Coniguration
#    Modify Gnb Sw Coniguration    ${para1}
#    Backup AP Config File
#    Configure Gnb   ${delta_file}
#    Reboot TL And Check Configured
#    Suite Setup Start WTS And Check OnAir
#
#Recover TL For Each Case
#    Recover Gnb Sw Configuration
#    Recover AP Config File
#    Recover Config
#    Clean Edaemon And Egate
#    Stop Edaemon Egate
#
#Backup Gnb Sw Coniguration
#    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
#    SSH.Execute    command=${cmd}    connection=${GNB_ASIK.connection}
#
#Modify Gnb Sw Coniguration
#    [Arguments]    ${para1}
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x5900bf=${para1}">>/ffs/run/swconfig.txt'
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x59006A=1">>/ffs/run/swconfig.txt'
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580422=0">>/ffs/run/swconfig.txt'
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "0x580431=0">>/ffs/run/swconfig.txt'
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 'echo "command=crasign /ffs/run/swconfig.txt'
#
#Recover Gnb Sw Coniguration
#    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${cmd}'
#
#Backup AP Config File
#    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml ./iphy-bak-TA.xml
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.200.1 '${cmd}'
#
#Configure Gnb
#    [Arguments]    ${delta_file}
#    Delta Commission Json File With Admin    delta_json=${delta_file}
#
#Recover AP Config File
#    ${cmd}    Set Variable    cd /ffs/run/simmode/;rm -rf ./iphy.xml;mv iphy-bak-TA.xml iphy.xml
#    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'
#
#Recover Config
#    ${bts_id}    Get BTS Id
#    COAM.Setup Admin    bts_host=${GNB_ASIK.ip}
#    Log To Console    recover gnb configuratio...
#    COAM.Perform Commissioning
#    ...    bts_id=${bts_id}
#    ...    scf_file=${OUTPUT_DIR}/SCF_before_suite.xml
#    ...    skip_parameter_relation_errors=True
#    ...    should_activate=True
#    ...    timeout=500
#    Run Keyword And Ignore Error    COAM.Teardown
#
#Set Config Path
#    Log To Console    ${SW_BRANCH}
#    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/config/${SW_BRANCH}
#    Log To Console    ${JSON_PATH}
#
#L3 Call With NSA measurement_gap
#	${UE_ID}=    Set Variable    11
#    Setup X2 Connection
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Measurement Gap Configuration Setup
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#	Start Gnb BIP Log
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    Sleep    10s    reason=Keep the traffic stable
# 	NSA Stop Traffic    11    2    dl
#	NSA Stop Traffic    11    2    ul
#	Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    #NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
#    #NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5
#	NSA LTE Detach     ${UE_ID}
#
#
#L3 Call With NSA
#	${UE_ID}=    Set Variable    11
#    Setup X2 Connection
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Measurement Gap Configuration Setup
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#	Start Gnb BIP Log
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    Sleep    10s    reason=Keep the traffic stable
#    NSA Stop Traffic    11    2    dl
#    NSA Stop Traffic    11    2    ul
#	Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5
#
#
#Start L3 Call And BIP Log
#    [Arguments]    ${sa_flag}    ${ul_zeropadding}    ${ucionly}
#    Run Keyword If    '${sa_flag}'=='SA'
#    ...    L3 Call With SA_C    ${ul_zeropadding}    ${ucionly}
#    Run Keyword If    '${sa_flag}'=='NSA'
#    ...    L3 Call With NSA_C    ${ul_zeropadding}    ${ucionly}
#    sleep    10s
#
#
#Measurement Gap Configuration Setup
#    ute_wtssim.Execute Egate Command
#    ...    cmd=ue_enb_param id=1 measurement_gap=gp6:10 mgta=ms0 gap_purpose=perUE
#
#
#Check Traffic On NSA In WTS
#    [Arguments]    ${throughput_dl}    ${throughput_ul}
#    ${check_cmd}    Set Variable    bearer_stats ue=1 id=2 type=l3
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    cmd=${check_cmd}    pass_regexp=${WTS_AVG_INTERVAL}    timeout=150
#    Create File    /tmp/nsa_traffic.txt    ${output}
#    ${avg_dl}    Run    cat /tmp/nsa_traffic.txt | grep -m 2 'Average data rate' | awk '{print $4}' | sed -n '2p'
#    ${real_tp_dl}    Evaluate    ${avg_dl}*0.000001
#    Should Be True    ${throughput_dl}<=${real_tp_dl}
#    ${avg_ul}    Run    cat /tmp/nsa_traffic.txt | grep -m 1 'Average data rate' | awk '{print $4}'
#    ${real_tp_ul}    Evaluate    ${avg_ul}*0.000001
#    Should Be True    ${throughput_ul}<=${real_tp_ul}
#
#Check ACSI Info From Egate Log
#    [Arguments]    ${open_loop_flag}
#    Log To Console    \nStart check A-CSI info from egate log.\n
#	${openloop_qua}    Set Variable    reportQuantity cri-RI-CQI
#	${closeloop_qua}    Set Variable    reportQuantity cri-RI-PMI-CQI
#	${config_id}    Set Variable    reportConfigId 1
#	${trigger_size}    Set Variable    reportTriggerSize 1
#	${check_rst1}    Run Keyword If    '${open_loop_flag}'=='1'
#    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${openloop_qua}"|wc -l
#    ...    ELSE
#    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${closeloop_qua}"|wc -l
#	${check_rst2}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${config_id}"|wc -l
#	${check_rst3}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${trigger_size}"|wc -l
#    Should Be True    ${check_rst1}>=2
#	Should Be True    ${check_rst2}>=2
#	Should Be True    ${check_rst3}>=1
#
#Common Suite Setup
#    Suite Setup Update GNB
#    Suite Setup Copy WTS Config Files From QT
#
#L3 Call With SA
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    Start Gnb BIP Log
#    SA Start DL Traffic    10    10
#    SA Start UL Traffic    10    10
#    SA Stop DL Traffic
#    SA Stop UL Traffic
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    SA 5G Detach    ${UE_ID}
#    SA Check Average Traffic Bigger Than Target    dl    10
#    SA Check Average Traffic Bigger Than Target    ul    10
#
#L3 Call With SA_C
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
#    ...    SA Stop UL Traffic Egate Command    1
#
#Change CQI For UCIonly SA
#    Log To Console    Change CQI ...
#    ${prepare_1}    Set Variable
#    ...    csi_override_testmode_nr profile_id=2 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
#
#    ${prepare_2}    Set Variable
#    ...    ue_testmode_set_nr id=1 testmode=csi_override profile_id=2 action=activate
#    ute_wtssim.Execute Egate Command    ${prepare_1}
#    ute_wtssim.Execute Egate Command    ${prepare_2}
#
#
#L3 Call With NSA_C
#    [Arguments]    ${ul_zeropadding}    ${ucionly}
#    ${UE_ID}=    Set Variable    11
#    Setup X2 Connection
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    Run Keyword If    '${ucionly}'=='1'
#    ...    ute_wtssim.Execute Egate Command    enb_endc_param id\=1 serving_cell_index_range_scg\=5:31
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    NSA Start UL Traffic    ${UE_ID}    ${BEARER_ID}    20    1
#    Start Gnb BIP Log
#    Run Keyword If    '${ucionly}'=='1'
#    ...    Change CQI For UCIonly NSA
#    Sleep    4s    reason=Keep the traffic stable
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}
#    NSA Stop Traffic    11    2    dl
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    NSA Stop Traffic    11    2    ul
#    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    dl    5
#    Run Keyword If    '${ul_zeropadding}'=='False'
#    ...    NSA Check Average Traffic bigger than target    ${UE_ID}    ${BEARER_ID}    ul    5
#    NSA LTE Detach     ${UE_ID}
#
#
#Change CQI For UCIonly NSA
#    Log To Console    Change CQI ...
#    ${prepare_1}    Set Variable
#    ...    csi_override_testmode_nr profile_id=3 cqi=15 cqi_mode=oneway cqi_min=4 cqi_max=15 cqi_step=-1 cqi_period=32
#    ${prepare_2}    Set Variable
#    ...    ue_testmode_set_nr id=11 testmode=csi_override profile_id=3 action=activate scell=5
#    ute_wtssim.Execute Egate Command    ${prepare_1}
#    ute_wtssim.Execute Egate Command    ${prepare_2}
#
#
#Convert BIP To CSV By MCShark For 5GC001817-A
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
#    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
#    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}   5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    ${filter}    ${csv_title_list}
#    END
#
#Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq
#    [Arguments]    ${tc_id}
#    Log To Console    Check A-CSI in PdcchSendReq.
#    Convert BIP To CSV By MCShark For 5GC001817-A    ${tc_id}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv
#
#Check l1_common_dtx_t.value in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check DTX in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total l1_common_dtx_t.value Number    ${tc_id}
#    ${failed_number}    Get Total Failed l1_common_dtx_t.value Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    DTX Rate is ${rate}
#    Should Be True    ${rate}<0.1
#
#Get Total l1_common_dtx_t.value Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed l1_common_dtx_t.value Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtx    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check csiPart1CrcCheck in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check csiPart1CrcCheck in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total csiPart1CrcCheck Number    ${tc_id}
#    ${failed_number}    Get Total Failed csiPart1CrcCheck Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    CRCNOK Rate is ${rate}
#    Should Be True    ${rate}<0.1
#
#Get Total csiPart1CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed csiPart1CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check csiPart2CrcCheck in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check csiPart2CrcCheck in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total csiPart2CrcCheck Number    ${tc_id}
#    ${failed_number}    Get Total Failed csiPart2CrcCheck Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    CRCNOK Rate is ${rate}
#    Should Be True    ${rate}<0.1
#
#Get Total csiPart2CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed csiPart2CrcCheck Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check dtxCsiPart1 in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check dtxCsiPart1 in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total dtxCsiPart1 Number    ${tc_id}
#    ${failed_number}    Get Total Failed dtxCsiPart1 Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    dtxCsiPart1 Rate is ${rate}
#    Should Be True    ${rate}<0.1
#
#Get Total dtxCsiPart1 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed dtxCsiPart1 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Check dtxCsiPart2 in PuschReceiveRespPs
#    [Arguments]    ${tc_id}
#    Log To Console    Check dtxCsiPart2 in Ul PuschReceiveRespPs.
#    ${total_number}    Get Total dtxCsiPart2 Number    ${tc_id}
#    ${failed_number}    Get Total Failed dtxCsiPart2 Number    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    dtxCsiPart2 Rate is ${rate}
#    Should Be True    ${rate}<0.1
#
#Get Total dtxCsiPart2 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1", "0"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed dtxCsiPart2 Number
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_a.csv    UlData_UePuschReceiveRespPs_t.dtxCsiPart2    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Convert BIP To CSV By MCShark For PuschReceiveRespHarqU
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    uldata_puschreceiverespharqu
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
#    ...    UlData_UePuschReceiveRespHarqU_t.dtx
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
#    END
#
#
#
#Get Total UlDataPuschReceiveRespHarqU Message Number 1817
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["0", "1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817
#    [Arguments]    ${tc_id}
#    ${data_list}=    TTITRACEANALYZER.Filter Source Column Return Self
#    ...    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    UlData_UePuschReceiveRespHarqU_t.crc    ["1"]    include    no
#    ${count}    Get Length    ${data_list}
#    [Return]    ${count}
#
#
#Modify UE Capbility For 1817C
#    [Arguments]    ${TestLine_Type}
#    Run Keyword If    '${TestLine_Type}'=="NSA"
#    ...    Modify UE Capabilities In CFG    ${file_path}    ${old_values_patts}    ${new_values_NSA}
#    Run Keyword If    '${TestLine_Type}'=="SA"
#    ...    Modify UE Capabilities In CFG    ${file_path}    ${old_values_patts}    ${new_values_SA}
#
#Delete PM BTS counter file
#    BuiltIn.Log To Console    Delete PM BTS counter file on SA
#    ${cmd}    Set Variable    rm /tmp/PM.BTS*
#    Run    sshpass -p oZPS0POrRieRtu ssh toor4nsn@192.168.255.1 '${cmd}'
#    [Teardown]
#
#Check PM counter
#    wait until keyword succeeds    30min    1min    Get M55308C11001
#    wait until keyword succeeds    1min    10sec    Get M55308C11002
#    ${value}    Evaluate    float(${M55308C11002})/float(${M55308C11001})
#    should be true    ${value}>2.98
#    should be true    ${value}<3.02
#
#
#
#Get M55308C11001
#    BuiltIn.Log To Console    check M55308C11001...
#    #SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}
#    #ssh.execute    gunzip /tmp/PM.BTS*.gz
#    #ssh.execute    rm /tmp/PM.BTS*.xml
#    SSH.Execute    command=gunzip /tmp/PM.BTS*.gz    connection=${GNB_ASIK.connection}
#	SSH.Execute    command=rm /tmp/PM.BTS*.xml    connection=${GNB_ASIK.connection}
#	#${counter_info1}    ssh.execute    cat /tmp/PM.BTS* | grep M55308C11001
#    ${counter_info1}    SSH.Execute    cat /tmp/PM.BTS* | grep M55308C11001    connection=${GNB_ASIK.connection}
#	${M55308C11001_list}    get regexp matches    ${counter_info1}    <M55308C11001>(\\d+)</M55308C11001>    1
#    BuiltIn.Log    ${M55308C11001_list}
#    ${M55308C11001}    get from list    ${M55308C11001_list}    1
#    set suite variable    ${M55308C11001}
#    [Teardown]
#
#Get M55308C11002
#    BuiltIn.Log To Console    check M55308C11002...
#    #SSH.Connect To    ${GNB.ip}    ${GNB.username}    ${GNB.password}
#    #${counter_info2}    ssh.execute    cat /tmp/PM.BTS* | grep M55308C11002
#	${counter_info2}    SSH.Execute    cat /tmp/PM.BTS* | grep M55308C11002    connection=${GNB_ASIK.connection}
#    ${M55308C11002_list}    get regexp matches    ${counter_info2}    <M55308C11002>(\\d+)</M55308C11002>    1
#
#
#	BuiltIn.Log    ${M55308C11002_list}
#    ${M55308C11002}    get from list    ${M55308C11002_list}    1
#    set suite variable    ${M55308C11002}
#    [Teardown]    Run Keyword And Ignore Error    ssh.Disconnect
#
#Check BeataOffset And UL256 QAM In CSV File
#    [Arguments]    ${case_id}
#    Convert BIP To CSV By MCShark FOR BetaOffsets And UL256    ${case_id}
#    ${bip_csv_names}    OperatingSystem.List Files In Directory    ${OUTPUT_DIR}    csv_CA${case_id}_*.csv    ${True}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${case_id}/ttitrace_CA${case_id}.ini    ${bip_csv_names}[0]
#
#Convert BIP To CSV By MCShark FOR BetaOffsets And UL256
#    [Arguments]    ${case_id}
#    ${filter}=    Set Variable
#    ...    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00
#    @{csv_title_list}=    Create List    3gpp.sfn    dci.dci01.CSIrequest
#    ...    dci.dci01.BetaOffsetInd    UlData_puschReceiveReqGrant_t.numOfUciAckBits    UlData_puschReceiveReqGrant_t.mcsTable
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#        Convert BIP To CSV By MCShark    ${name}    ${OUTPUT_DIR}/csv_CA${case_id}_${index}.csv    ${filter}    ${csv_title_list}
#    END
#
