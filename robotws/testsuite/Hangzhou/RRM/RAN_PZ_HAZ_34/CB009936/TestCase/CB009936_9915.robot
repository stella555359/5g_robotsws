*** Settings ***
Force Tags    PY36
Documentation     author: qingqing zhang
...                 contact: qingqing.zhang@nokia-sbell.com
...                 squad group: SG_03
...                 feature : CB008140-AB

Resource         testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB009936/Resources/CB009936_Case_Step.robot

Suite Setup    Run Keywords
...               robot_common_operations.Common Suite Setup
...               AND    Common Suite Setup for COAM
...               AND    Get sagnb release
...               AND    Common Case TestLine Setup for gnb1

Suite Teardown    Run Keywords
...               robot_common_operations.Common Suite Teardown    AND
...               Common Case TestLine Setup    is_commission=True
...                                             golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}.xml    AND
...               Run Keyword And Ignore Error    Common Suite Teardown for COAM   AND
...               Run Keyword And Ignore Error    COAM Teardown gnb connections


*** Variables ***
${gnb_path}    /tmp
${scf_path}    /opt/workspace/SCF/
${dl_throughput}    400M
${expected_tput_dl_100M}    1450
${expected_tput_dl_10M_1116}    104
${expected_tput_dl_10M_1208}    101
${expected_tput_ul_10M}    11
${expected_tput_ul_100M}    200
${filename_gnb1_9915_attach}    CB009936_9915_attach.pcap
${filename_gnb1_10MHZ_attach}    CB009936_10MHZ_cell_attach.pcap
${allow_fault_list}               4291    6327
${biplog_9915}    l1l2bip_9915/l1l2bip_9915.pcap
*** Test Cases ***
[1]CB009936_9915_B_IWK11_04_PRB_blanking_interworking_with_Carrier_Aggregation_T+T_SA
    [Documentation]
    ...    This case is check bip when enable actPrachMultiplexingLevel
    [Tags]    classical    CRT_TRUNK
    [Setup]    robot_common_operations.Common Case Setup    allowed_faults_ids=4291,6327
    AlarmWatchdog.add_allow_alarms    fault_id=${allow_fault_list}
    Spark_multiUE.prepare UE
    MCS SETUP AND SET ATT for dingli_UE    gnb_cell1_PA_value_dingli_UE1=${25}
    UE attach and collect log    filename=${filename_gnb1_9915_attach}
    Check tput and BIP log
    #####Modify tddFrameStructure to 1208#####
    Common Case TestLine Setup    ModifySCF_Beforecommission=True
    ...    golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}.xml     ParameterToDelete=${PARAMS_TO_delete_framestructure_1208}
    ...    ParamterToModify=${PARAMETERS_TO_MODIFY_GNB1_1208}    ListToAdd=${PARAMS_TO_add_framestructure_1208}
    ...    ListParamterToModify=${LIST_TO_modify_1208}
    UE attach and collect log    filename=${filename_gnb1_10MHZ_attach}
    Check tput for 10MHZ cell
    [Teardown]    Run Keywords    Run Keyword And Ignore Error    mcs_common.Teardown MCS    mcs_type=${mcs_type}
    ...    AND    Run Keyword And Ignore Error    Spark_multiUE.stop ue log
    ...    AND    Run keyword and ignore error    Tear down the all connections
    ...    AND    Common Case Teardown for COAM

*** Keywords ***
Common Case TestLine Setup for gnb1
    Common Case TestLine Setup    ModifySCF_Beforecommission=True    ParameterToDelete=${PARAMS_TO_delete_9915}
    ...    golden_scf_name=MRBTS-${MRBTS1_ID}_${release_info}_72e.xml    ParamterToModify=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_9915}
    ...    ListToAdd=${PARAMS_TO_add_9915}     ListParamterToModify=${LIST_TO_modify_9915}

Modify tddFrameStructure to 1208
    [Arguments]    ${connection}=GNB_OAM    ${gnb_index}=${0}
    Wait Until Keyword Succeeds    3 min    5 sec    Connect to gnb coam via ssl    gnb_index=${gnb_index}    connection=${connection}
    COAM Update Several Parameters Via Rest Api    connection=${connection}
    ...    parameters_to_update_via_api=${PARAMETERS_TO_ONLINE_MODIFY_GNB1_1208}
    COAM delete parameters via rest api    connection=${connection}
    ...    parameters_to_delete_via_api=${PARAMS_TO_delete_framestructure}
    Sleep    60s
    COAM add several parameters via rest api    connection=${connection}
    ...    parameters_to_add_via_api=${PARAMS_TO_add_framestructure_1208}
    COAM Wait For Gnb Ready And Cell Setup    connection=${connection}    timeout=${timeout}    gnb_type=${gnb_type}
    ...    is_x2_check_from_gnb_needed=${False}    gnb_index=${gnb_index}    ALLOWED_FAULT=${ALLOWED_FAULT}
    [Teardown]    Run Keyword And Ignore Error    COAM Teardown gnb connections    connection=${connection}

Check tput and BIP log
    [Arguments]    ${ue_index}=${1}
#    Start UL Data Transfer with pioneer client    ues_index=${ue_index}
#    Start MUE dltraffic with appserver      ue_addr=${${uegroup}[${${ue_index}}]_IP}    dl_port=${DL_PORT_dingli}
#        ...    dl_throughput=${dl_throughput}    process_num=${5}
    Spark_multiUE.start UL traffic    ue_index=${ue_index}
    Spark_multiUE.start DL traffic    ue_index=${ue_index}    dl_throughput=${dl_throughput}    process_num=${5}
    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_dl_100M}   tput_dl_scell=${expected_tput_dl_10M_1116}    ue_type=huawei
    ...    tput_ul_pcell=${expected_tput_ul_100M}    scellid=16   pcellid=4
    Collect Interface Mirroring Bip Collector from WEBUI    gnb_index=${gnb_index}    times=1s    target_file_name=l1l2bip_9915
    Get Bip Log Via Interface Mirroring Collector to UTE    target_file_name=l1l2bip_9915
    Check the DL and UL blank PRB    biplog=${biplog_9915}
    [Teardown]    Run Keywords    Spark_multiUE.stop UL traffic    ue_index=${ue_index}
    ...    AND    Spark_multiUE.stop DL traffic    ue_index=${ue_index}
    ...    AND    Spark_multiUE.detach UE    ue_index=${ue_index}
#    [Teardown]    Run Keywords    Stop UL Data Transfer with pioneer client    ues_index=${ue_index}
#    ...    AND    Stop traffic with appserver    iperf_port=${DL_PORT_dingli}
#    ...    AND    Detach MultiUE    ue=${uegroup}[${UE_index}]

Check tput for 10MHZ cell
    [Arguments]    ${ue_index}=${1}
#    Start UL Data Transfer with pioneer client    ues_index=${ue_index}
    Spark_multiUE.start UL traffic    ue_index=${ue_index}
    Spark_multiUE.start DL traffic    ue_index=${ue_index}    dl_throughput=${dl_throughput}    process_num=${5}
#    Start MUE dltraffic with appserver      ue_addr=${${uegroup}[${${ue_index}}]_IP}    dl_port=${DL_PORT_dingli}
#        ...    dl_throughput=${dl_throughput}    process_num=${5}
    Check 2CC DLUL tput    tput_dl_pcell=${expected_tput_dl_10M_1208}    ue_type=huawei
    ...    tput_ul_pcell=${expected_tput_ul_10M}   pcellid=16
    [Teardown]    Run Keywords    Spark_multiUE.stop UL traffic    ue_index=${ue_index}
    ...    AND    Spark_multiUE.stop DL traffic    ue_index=${ue_index}
    ...    AND    Spark_multiUE.detach UE    ue_index=${ue_index}
#    [Teardown]    Run Keywords    Stop UL Data Transfer with pioneer client    ues_index=${ue_index}
#    ...    AND    Stop traffic with appserver    iperf_port=${DL_PORT_dingli}
#    ...    AND    Detach MultiUE    ue=${uegroup}[${UE_index}]

UE attach and collect log
    [Arguments]    ${filename}    ${gNB_index}=${0}    ${UE_index}=${1}
    Start capture gNB log on master    filename=${filename}   gNB_index=${gNB_index}
#    Run Keyword And Ignore Error
#    ...    MultiUE one Attach with client    ue_alias=${uegroup}[${UE_index}]
    Sleep    5s
#    Run keyword and Ignore Error      client.sendat    command=AT+GTACT=14,,,5077    ue=${uegroup}[${UE_index}]
#    Sleep    15s
#    MultiUE one Attach with client    ue_alias=${uegroup}[${UE_index}]
    Spark_multiUE.attach UE    ue_index=${UE_index}
    [Teardown]    Stop and download the Logs    filename=${filename}    gNB_index=${gNB_index}

Check the DL and UL blank PRB
    [Arguments]    ${biplog}
    ###check PCell DL slot 8 use 270 PRBs ,it means 3 PRB block
    ${pcell_pdsch}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(dldata_pdschsendreql1sw) && (3gpp.subcellid == 6) && (3gpp.slot == 8) && !(3gpp.rnti == 65535)
    ...    xpath=.//DlData_PdschGrantL1sw.startPrb
    Should be equal    ${pcell_pdsch}[0]    0
    ${result_start_PRB}=    Evaluate    all(x == '${pcell_pdsch}[0]' for x in ${pcell_pdsch})
    Should Be True    ${result_start_PRB}
    ${pcell_numofPRB}=    Check wireshark log    logname=${biplog}
    ...    message_filter=(dldata_pdschsendreql1sw) && (3gpp.subcellid == 6) && (3gpp.slot == 8) && !(3gpp.rnti == 65535)
    ...    xpath=.//DlData_PdschGrantL1sw.numOfPrb
    Should be equal    ${pcell_numofPRB}[0]    270
    ${pcell_result_numofPRB}=    Evaluate    all(x == '${pcell_numofPRB}[0]' for x in ${pcell_numofPRB})
    Should Be True    ${pcell_result_numofPRB}
    ###check Pcell UL slot 4,5,14,15 小于 270 PRBs
    ${pusch_slot}    Create list    ${4}    ${5}    ${14}    ${15}
    FOR    ${slot}    IN    @{pusch_slot}
        ${pcell_pusch}=    Check wireshark log    logname=${biplog}
        ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 6) && (3gpp.slot == ${slot}) && !(3gpp.rnti == 65521)
        ...    xpath=.//UlData_puschReceiveReqGrant_t.startPrb
        ${pcell_numofPRB_UL}=    Check wireshark log    logname=${biplog}
        ...    message_filter=(uldata_puschreceivereq) && (3gpp.subcellid == 6) && (3gpp.slot == ${slot}) && !(3gpp.rnti == 65521)
        ...    xpath=.//UlData_puschReceiveReqGrant_t.numOfPrb
        Should Be True    ${${pcell_pusch}[0]+${pcell_numofPRB_UL}[0]} <= 270
    END