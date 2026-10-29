*** Settings ***
Documentation    ...
##Suite Setup       Suite Setup Update GNB
#Suite Setup       Check TL Type And Suite Setup
#Suite Teardown    Common Suite Teardown
#
#Force Tags        Force Tags    Classical    IPV4    FR1    PRI-High    SBTS00    SBTS23R1
#...               5GC001817    master_classicalbts_all    STATE_CONFIGURED    CRT
#...               RAN_5G    RAN_5G_FDD    CN1_SQ    CLOUD_5G_I_LO_AP_LO_SANSA_FS_CPRI_CMWV_FDD
#...               CLOUD_5G_I_BN_AP_KL_SANSA_FS_CPRI_CMWV_FDD
#Resource          ../CUDU_L2/common_setup_teardown.robot
#Resource          ../5GC001808/AirPhone_common_resource_UTE_CR.robot
#Resource          ./keywords_1817_common_AP.robot
#Resource          ../5GC002063/5GC002063_common_keywords.robot
#Library           BuiltIn
#Library           String
#Library           taf.wts.runner    WITH NAME    wtsrunner
#
#*** Variables ***
#${L3_CALL_TYPE_for_various_case}    "SA_basic_L3CALL"
#
#${NSA_DL}        5
#${NSA_UL}        5
#${GSCN}          1589
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${DELTA_PATH_10M_HO}    Delta_conf_5GC001817_ET_10M_HO.json
#${WTS_CFG_A010_INTERHO}             basic_wts_A010_InterHO.cfg
#${WTS_AP_XML}                      AirPhoneConfig_A010_InterHO.xml
#${LOCAL_WTS_DIR}                   ${CURDIR}/Resource/
#${WTS_DIR}                         /opt/wts/latest
#${SCF_BASIC}         ${CURDIR}/config/scf_2F.xml
#${IPHY_BASIC}        ${CURDIR}/config/iphy_2F.xml
#${RD}             0x4B000F=1
#
#*** Test Cases ***
#5GC001817_A010_SA_Inter_GNB_Handover_ACSI_Report_Reconfigure_SUE
#    [Documentation]    The purpose
#    [Tags]    Owner_LiuHaiyan   case_A010
#    Setup TL For Test Case
#    WTS Config Setup For InterHO
#    L3 Call With SA Before HO
#    Sleep    30s    reason=For the egate log
#    Check ACSI Info From Egate Log   2
#    #Download MCShark To UTE
#    Copy Preference For MCShark    ${CURDIR}/Resource/preferences_a_10M
#    Check A-CSI DTX CRC BeforeHO
#    L3 Call With SA After HO
#    Check A-CSI DTX CRC AfterHO
#    [Teardown]    Recover TL For Each Case
#
#*** Keywords ***
#Check A-CSI DTX CRC BeforeHO
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq BeforeHO    A10
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    A10_1
#    Check csiPart1CrcCheck in PuschReceiveRespPs    A10_1
#    Check csiPart2CrcCheck in PuschReceiveRespPs    A10_1
#    Check dtxCsiPart1 in PuschReceiveRespPs    A10_1
#    Check dtxCsiPart2 in PuschReceiveRespPs    A10_1
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU BeforeHO    A10_1
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    A10_1
#
#Check A-CSI DTX CRC AfterHO
#    Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq AfterHO    A10
#    Check l1_common_dtx_t.value in PuschReceiveRespPs    A10_2
#    Check csiPart1CrcCheck in PuschReceiveRespPs    A10_2
#    Check csiPart2CrcCheck in PuschReceiveRespPs    A10_2
#    Check dtxCsiPart1 in PuschReceiveRespPs    A10_2
#    Check dtxCsiPart2 in PuschReceiveRespPs    A10_2
#    Convert BIP To CSV By MCShark For PuschReceiveRespHarqU AfterHO    A10_2
#    #Check CRCNOK Rate in PuschReceiveRespHarqU    A10_2
#
#Setup TL For Test Case
#    Backup Gnb Sw Configuration HO
#    Modify Gnb Sw Coniguration 1817A    40
#    Backup AP Config File HO
#    Configure Airphone 1817A
#    Set Config Path 1817A
#    Configure Gnb HO   ${JSON_PATH}/${DELTA_PATH_10M_HO}
#    Hard Reboot Testline
#    Verify Coam Site Is Ready
#
#Backup Gnb Sw Configuration HO
#    ${cmd}    Set Variable    cd /ffs/run/;cp ./swconfig.txt ./swconfig-TA.txt
#    SSH.Execute    command=${cmd}    connection=${GNB_ASIK.connection}
#
#Backup AP Config File HO
#    ${cmd}    Set Variable    cd /ffs/run/simmode/;cp ./iphy.xml ./iphy-bak-TA.xml
#    SSH.Execute    command=${cmd}    connection=${AP_ASIK.connection}
#
#Configure Gnb HO
#    [Arguments]    ${delta_file}
#    Delta Commission Json File With Admin    delta_json=${delta_file}
#
#Recover TL For Each Case
#    Delete InterHO IP
#    Recover Gnb Sw Configuration HO
#    Recover AP Config File HO
#    Recover Config HO
#    Clean Edaemon And Egate
#
#Recover Gnb Sw Configuration HO
#    ${cmd}    Set Variable    cd /ffs/run/;rm -rf ./swconfig.txt;mv swconfig-TA.txt swconfig.txt;crasign swconfig.txt
#    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${GNB_ASIK.password} ssh ${GNB_ASIK.username}@${GNB_ASIK.ip} '${cmd}'
#
#Recover AP Config File HO
#    ${cmd}    Set Variable    cd /ffs/run/simmode/;rm -rf ./iphy.xml;mv iphy-bak-TA.xml iphy.xml
#    OperatingSystem.Run And Return Rc And Output
#    ...    sshpass -p ${AP_ASIK.password} ssh ${AP_ASIK.username}@${AP_ASIK.ip} '${cmd}'
#
#Recover Config HO
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
#Delete InterHO IP
#    [Documentation]    This keyword is to delete VM interfaces for InterHO.
#    Log To Console    delete VM interfaces for InterHO ...
#    OperatingSystem.Run    sudo ip addr del 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr del 10.0.3.153/32 dev eth3
#    OperatingSystem.Run    sudo ip addr del 192.168.6.252/32 dev eth2
#
#Modify Gnb Sw Coniguration 1817A
#    [Arguments]    ${para1}
#    SSH.Execute    command=echo "0x5900bf=${para1}">>/ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
#    SSH.Execute    command=echo "0x5900d4=0x0">>/ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
#    SSH.Execute    command=echo "0x580422=0">>/ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
#    SSH.Execute    command=echo "0x580431=0">>/ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
#    #SSH.Execute    command=echo "0x59004D=1">>/ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
#    SSH.Execute    command=crasign /ffs/run/swconfig.txt    connection=${GNB_ASIK.connection}
#
#Configure Airphone 1817A
#    SSH.Execute    sed -i "s|<GSCN>[0-9]*<\/GSCN>|<GSCN>${GSCN}<\/GSCN>|" /ffs/run/simmode/iphy.xml    connection=${AP_ASIK.connection}
#
#Set Config Path 1817A
#    Log To Console    ${SW_BRANCH}
#    Set Suite Variable    ${JSON_PATH}    ${CURDIR}/${SW_BRANCH}/SCF
#    Log To Console    ${JSON_PATH}
#
#WTS Config Setup For InterHO
#    Configure IP For InterHO
#    Setup WTS Config For InterHO 1817
#    Start WTS And Check OnAir
#    Set Parameter For Trigger Hanover By A3 Event
#
#Configure IP For InterHO
#    [Documentation]    This keyword is to configure VM interfaces for InterHO.
#    Log To Console    configure VM interfaces for InterHO ...
#    OperatingSystem.Run    sudo ip addr add 10.0.3.151/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.3.153/32 dev eth3
#    OperatingSystem.Run    sudo ip addr add 192.168.6.252/32 dev eth2
#    OperatingSystem.Run    sudo ip addr add 10.0.1.131/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.132/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.133/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.134/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.135/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.136/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.137/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.2.99/24 dev eth3
#    OperatingSystem.Run    sudo ip addr add 10.0.1.121/24 dev eth3
#
#Start WTS And Check OnAir
#    Modify UTE SCTP Timeout
#    Modify AP SCTP Timeout
#    Configure UTE ETH3
#    Start UTE WTS
#    Setup X2 Connection
#    Verify Cell Setup
#    Sleep   10s
#
#L3 Call With SA Before HO
#    SA 5G Attach    ${UE_ID}
#    SA 5G PDU Session Setup    ${UE_ID}
#    Teardown All Connections
#    Start Gnb BIP Log
#    SA Start DL Traffic    10    20
#    SA Start UL Traffic    10    20
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}/BeforeHO
#    SA Stop DL Traffic
#    SA Stop UL Traffic
#    SA Check Average Traffic Bigger Than Target    dl    10
#    SA Check Average Traffic Bigger Than Target    ul    10
#
#L3 Call With SA After HO
#    SA Start DLUL Traffic For InterHO    10    10
#    Trigger A3 Rsrp Measurement From Real To Sim
#    Trigger A3 Rsrp Measurement From Sim To Real
#    Start Gnb BIP Log
#    Sleep   20s
#    Stop Gnb BIP Log    ${SUITE_LOG_DIRECTORY}/AfterHO
#    SA Stop DL Traffic
#    SA Stop UL Traffic
#    SA 5G Detach    ${UE_ID}
#    SA Check Average Traffic Bigger Than Target    dl    10
#    SA Check Average Traffic Bigger Than Target    ul    10
#
#SA Start DLUL Traffic For InterHO
#    [Arguments]    ${dlmbps}=5    ${ulmbps}=5    ${duration}=50
#    [Documentation]    This keyword is to start DL and UL traffic by iperf at the same time.
#    ...    | Input Parameters | Man. | Description |
#    ...    | dlmbps | Yes | mbps, default is 5M |
#    ...    | ulmbps | Yes | mbps, default is 5M |
#    ...    | duration | Yes | duration, default is 10s |
#    ...    Example:
#    ...    | SA Start DLUL Traffic | 20 | 10 | 10 |
#    Log To Console    ready to start DL and UL traffic at the same time...
#    Log To Console    start DL traffic...
#    Execute Iperf In Linux    args=-c 1.2.4.2 -u -p ${DL_PORT} -l 1300 -b ${dlmbps}M -i 1 -t ${duration}
#    Execute Iperf In Linux    args=-s -u -p ${DL_PORT} -i 1 -B 10.0.2.1
#    ...    pipe_args=| tee /tmp/iperf_dl.txt
#    Log To Console    Running DL Traffic ${dlmbps}M for ${duration}s
#    Log To Console    start UL traffic...
#    Execute Iperf In Linux    args=-c 72.23.0.1 -u -p ${UL_PORT} -l 1300 -b ${ulmbps}M -i 1 -t ${duration}
#    Execute Iperf In Linux    args=-s -u -p ${UL_PORT} -i 1 -B 10.0.2.1
#    ...    pipe_args=| tee /tmp/iperf_ul.txt
#    Log To Console    Running UL Traffic ${ulmbps}M for ${duration}s
#    Sleep    5s
#
#Check ACSI Info From Egate Log
#    [Arguments]    ${open_loop_flag}
#    Log To Console    \nStart check A-CSI info from egate log.\n
#    ${openloop_qua}    Set Variable    reportQuantity cri-RI-CQI
#    ${closeloop_qua}    Set Variable    reportQuantity cri-RI-PMI-CQI
#    ${config_id}    Set Variable    reportConfigId 1
#    ${trigger_size}    Set Variable    reportTriggerSize 1
#
#    ${check_rst1}    Run Keyword If    '${open_loop_flag}'=='OpenLoop'
#    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${openloop_qua}"|wc -l
#    ...    ELSE
#    ...    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${closeloop_qua}"|wc -l
#    ${check_rst2}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${config_id}"|wc -l
#    ${check_rst3}    Run    cat /opt/wts/latest/egate_console.log.001|grep -i "${trigger_size}"|wc -l
#    Should Be True    ${check_rst1}>=2
#    Should Be True    ${check_rst2}>=2
#    Should Be True    ${check_rst3}>=0
#
#Setup WTS Config For InterHO 1817
#    Set Suite Variable    ${WTS_CFG}    ${WTS_CFG_A010_INTERHO}
#    Log To Console    ${WTS_CFG}    ${WTS_AP_XML}
#    Suite Setup Copy WTS Config Files From Local    local_wts_dir=${LOCAL_WTS_DIR}
#
#Set Parameter For Trigger Hanover By A3 Event
#    Log To Console    Set parameter for InterHO...
#    ${prepare_1}    Set Variable
#    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
#    ${prepare_2}    Set Variable
#    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=3 time_ue_stayed_in_cell=98
#    ${prepare_3}    Set Variable
#    ...    ue_history_information_list_add_ngran id=1 cell_type=large nrcgi=311:489|0x01 gnb_id=2 time_ue_stayed_in_cell=97
#    ${prepare_4}    Set Variable    ue_history_information_list id=1 action=commit
#    ${prepare_5}    Set Variable    ue_enb_param id=1 ue_history_list=1
#    ute_wtssim.Execute Egate Command    ${prepare_1}
#    ute_wtssim.Execute Egate Command    ${prepare_2}
#    ute_wtssim.Execute Egate Command    ${prepare_3}
#    ute_wtssim.Execute Egate Command    ${prepare_4}
#    ute_wtssim.Execute Egate Command    ${prepare_5}
#    ${cmd1}    Catenate    gnb_param id=3 xn_listening_socket=1 send_xn_setup=True measEvent=A3
#    ute_wtssim.Execute Egate Command    ${cmd1}
#    ${cmd2}    Catenate    gnb_xn_link_up    gnb=3 target=2
#    ute_wtssim.Execute Egate Command    ${cmd2}
#
#Convert BIP To CSV By MCShark BeforeHO
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
#    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
#    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}/BeforeHO   5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_1_a.csv    ${filter}    ${csv_title_list}
#    END
#
#Convert BIP To CSV By MCShark AfterHO
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    dci.dci01.CSIrequest == 1||UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits != 0x00||uldata_puschreceiverespps
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    dci.dci01.CSIrequest    UlData_puschReceiveReqGrant_t.numOfUciCsiPart1Bits
#    ...    UlData_UePuschReceiveRespPs_t.dtx    UlData_UePuschReceiveRespPs_t.csiPart1CrcCheck    UlData_UePuschReceiveRespPs_t.csiPart2CrcCheck
#    ...    UlData_UePuschReceiveRespPs_t.dtxCsiPart1    UlData_UePuschReceiveRespPs_t.dtxCsiPart2
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}/AfterHO   5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_2_a.csv    ${filter}    ${csv_title_list}
#    END
#
#Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq BeforeHO
#    [Arguments]    ${tc_id}
#    Log To Console    Check A-CSI in PdcchSendReq.
#    Convert BIP To CSV By MCShark BeforeHO    ${tc_id}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_1_a.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_1_a.csv
#
#Check A-CSI in PdcchSendReq and numOfUciCsiPart1Bits in PuschReceiveReq AfterHO
#    [Arguments]    ${tc_id}
#    Log To Console    Check A-CSI in PdcchSendReq.
#    Convert BIP To CSV By MCShark AfterHO    ${tc_id}
#    A2A_Check_CSV_Table    ${CURDIR}/Resource/TC${tc_id}/ttitrace_2_a.ini    ${OUTPUT_DIR}/csv_TC${tc_id}_2_a.csv
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
#Convert BIP To CSV By MCShark For PuschReceiveRespHarqU BeforeHO
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    uldata_puschreceiverespharqu
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
#    ...    UlData_UePuschReceiveRespHarqU_t.dtx
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}/BeforeHO    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
#    END
#
#Convert BIP To CSV By MCShark For PuschReceiveRespHarqU AfterHO
#    [Arguments]    ${tc_id}
#    ${filter}=    Set Variable    uldata_puschreceiverespharqu
#    @{csv_title_list}=    Create List    3gpp.sfn    3gpp.slot    UlData_UePuschReceiveRespHarqU_t.crc
#    ...    UlData_UePuschReceiveRespHarqU_t.dtx
#    ${bip_names}    OperatingSystem.List Files In Directory    ${SUITE_LOG_DIRECTORY}/AfterHO    5GBipL2L1_filtering_off*.pcap*    ${True}
#    FOR    ${index}    ${name}    IN ENUMERATE    @{bip_names}
#         Convert BIP To CSV By MCShark   ${name}    ${OUTPUT_DIR}/csv_TC${tc_id}_HarqU.csv    ${filter}    ${csv_title_list}
#    END
#
#Check CRCNOK Rate in PuschReceiveRespHarqU
#    [Arguments]    ${tc_id}
#    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU.
#    ${total_number}    Get Total UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
#    ${failed_number}    Get Total Failed UlDataPuschReceiveRespHarqU Message Number 1817    ${tc_id}
#    ${rate}    Evaluate    float(${failed_number})/(${total_number})
#    Log To Console    CRCNOK Rate in PuschReceiveRespHarqU is ${rate}
#    Should Be True    ${rate}<0.1
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
