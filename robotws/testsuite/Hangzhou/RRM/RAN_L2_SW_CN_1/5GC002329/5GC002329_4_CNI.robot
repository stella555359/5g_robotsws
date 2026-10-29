*** Settings ***
Documentation    ...
#Resource    ./5GC002329_resource.robot
#Resource    ./../CUDU_L2/common_setup_teardown.robot
#Suite Setup    Common Suite Setup
#Test Setup    Common Test Setup 2
#Test Teardown    Common Test Teardown 2
#Suite Teardown    Common Suite Teardown 2
#Force Tags        CLOUD_5G_I_BOO_AP_LOO    SBTS00    SBTS23R1    SBTS22R4    ying_anne
#...                RAN_5G    RAN_5G_TDD
#*** Variables ***
#${UE_ID}               1
#${PROFILE_ID}          1
#${GNB_ID}              2
#${CELL_ID}             1
#${BEARER_ID}           2
#${SCF_PATH}    ${CURDIR}/config
#${ROOT_TYPE}    hard_reboot
#*** Test Cases ***
#5GC002329-ET-AAB1003-Verify DL data split to PCell and Scell with T-F CA activation for SA Option 2
#    [Documentation]
#    ...    1.set carrierAggregationSupportList enumeration parameter contains 500 ( ca_Fr1Tdd_Fdd_Sa).
#    ...    2.set sCellActivationMethod parameter = 0 (blind)
#    ...    3.CA relation between FR1-TDD and FDD cell is configured by adding NRREL object referring to the FDD cell and containing parameter
#    ...    sCellAdditionMethod is set to blind
#    [Tags]    case0    CIT    CDRT
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA CA UE and Get Throughput    UE_ID=1    dl_tp_set=700
#    ...    ul_tp_set=175    dl_tp_threshold=5    ul_tp_threshold=5
#
#
#CNI-69782-ET-ADB3003_SUE_FR1_T+F_CA_VoNR_smaller_onduration_2200_off_CovBased_Scell_addition_A2_Scell_release_1116-B
#    [Tags]    case1    CRT
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/Delta_ADB3003.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Save CPRT Info Log    cp_rt_all_info_onair    ${OUTPUT_DIR}/cprt_log/
#    SA 5G Attach    ue_id=3
#    SA Set Traffic Type To Internal    ue_id=3    pdu_id=1
#    SA CA 5G PDU Session Setup    ue_id=3    A1_add=${True}    drx_on=${True}
#    Save CPRT Info Log    cp_rt_all_info_attach    ${OUTPUT_DIR}/cprt_log/
#    SA Start DL Traffic Internal    3    1    175    1
#    SA Start DL Traffic Internal    3    1    175    2
#    SA Start DL Traffic Internal    3    1    175    3
#    SA Start DL Traffic Internal    3    1    175    4
#    Save CPRT Info Log    cp_rt_all_info_trf    ${OUTPUT_DIR}/cprt_log/
#    ${tcp_qfi}    ${udp_qfi}    Modify PDU Session with VONR    3    ${True}
#    Save CPRT Info Log    cp_rt_all_info_vonr    ${OUTPUT_DIR}/cprt_log/
#    SA Start VONR DL TCP and UDP Traffic    3    ${tcp_qfi}    ${udp_qfi}
#    Save CPRT Info Log    cp_rt_all_info_vonr_trf    ${OUTPUT_DIR}/cprt_log/
#    Get and Check CA UE DL throughput    3    250    10
#    Release PDU Session with VONR    3    ${True}
#    Trigger A2 Scell Release    3
#    SA 5G Detach    3
#    Save CPRT Info Log    cp_rt_all_info_detach    ${OUTPUT_DIR}/cprt_log/
#
#CNI-69782-ET-ADB3005_MUE_FR1_T+F_CA_DRX_smaller_onduration_2200_on_CovBased_Scell_addition_A2_Scell_release_1070
#    [Tags]    case2    CRT
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/Delta_ADB3005.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Save CPRT Info Log    cp_rt_all_info_onair    ${OUTPUT_DIR}/cprt_log/
#    Attach SA CA UE and Get Throughput    UE_ID=1    dl_tp_set=700    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#    ...    A2_rel=${True}
#    Save CPRT Info Log    cp_rt_all_info_ue_1    ${OUTPUT_DIR}/cprt_log/
#    Attach SA CA UE and Get Throughput    UE_ID=2    dl_tp_set=700    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#    ...    A2_rel=${True}
#    Save CPRT Info Log    cp_rt_all_info_ue_2    ${OUTPUT_DIR}/cprt_log/
#    Attach SA CA UE and Get Throughput    UE_ID=1-2    dl_tp_set=700    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#    ...    A2_rel=${True}
#    Save CPRT Info Log    cp_rt_all_info_two_ue    ${OUTPUT_DIR}/cprt_log/
#
#CNI-69782-ET-ADB3006_MUE_FR1_T+F_CA_DRX_bigger_onduration_2200_on_CovBased_Scell_addition_A2_Scell_release_1208
#    [Tags]    case3    CRT
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/Delta_ADB3006.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Attach SA CA UE and Get Throughput    UE_ID=1    dl_tp_set=700    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#    ...    A2_rel=${True}
#    Attach SA CA UE and Get Throughput    UE_ID=2    dl_tp_set=700    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#    ...    A2_rel=${True}
#    Attach SA CA UE and Get Throughput    UE_ID=1-2    dl_tp_set=700    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#    ...    A2_rel=${True}
#
#CNI-70851-ET-ADB4002_SUE_FR1_T_F_CA_blind_ScellAdd_blind_ScellAct_maxCsirsNumber4_DRX_bigger_onduration_drxLongCycle80ms_1116
#    [Tags]    case4    CRT
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_ADB4002.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Sleep    5s
#    Attach SA CA UE and Get Throughput    UE_ID=1    dl_tp_set=500    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1
#
#CNI-70851-ET-ADB4005_MUE_FR1_T_F_CA_covBasedA1_ScellAdd_buffBased_ScellAct_maxCsirsNumber4_DRX_bigger_onduration_drxLongCycle160ms_1116B
#    [Tags]    case5    CRT
#    ${json_file}=    Change Delta XML File To Delta Json File    ${SCF_PATH}/delta_ADB4005.xml
#    Delta Commission With SCF File    ${json_file}
#    Reboot TL And Check Configured
#    5GC002329_resource.Start WTS And Check OnAir
#    Sleep    10s
#    Attach SA CA UE and Get Throughput    UE_ID=1-2    dl_tp_set=500    ul_tp_set=175    dl_tp_threshold=1    ul_tp_threshold=1    A1_add=${True}
#
#*** Keywords ***
#Modify PDU Session with VONR
#    [Arguments]    ${ue_id}    ${vonr_drx}=${False}
#    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=2 by=amf
#    ${output_0}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#    ...    timeout=3minutes
#    ${qfi_5qi_5}    Get QFI for 5QI setup    ${output_0}    5
#    Log To Console    ${output_0}
#    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_add=3 by=amf
#    ${output_1}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#    ...    timeout=3minutes
#    Run Keyword If    ${vonr_drx}    String.Get Lines Matching Regexp    ${output_1}    drx-Config setup    partial_match=${true}
#    ${qfi_5qi_1}    Get QFI for 5QI setup    ${output_1}    1
#    Log To Console    ${output_1}
#    [Return]    ${qfi_5qi_5}    ${qfi_5qi_1}
#
#Release PDU Session with VONR
#    [Arguments]    ${ue_id}    ${common_drx}=${False}
#    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=3 by=amf
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#    ...    timeout=3minutes
#    Run Keyword If    ${common_drx}    String.Get Lines Matching Regexp    ${output}    drx-Config setup    partial_match=${true}
#    ${command}    Set Variable    ue_pdu_session_modify ue=${ue_id} pdu=1 qosflows_to_del=2 by=amf
#    ${output}    ute_wtssim.Execute Egate Command And Wait For Data
#    ...    ${command}
#    ...    pass_regexp=Pdu Session Resource Modify Response Message with RAN UE NGAP ID [0-9]{1,9} handled successfully
#    ...    timeout=3minutes
#    ${output}    String.Get Lines Matching Regexp    ${output}    Initial Context Setup Successful    partial_match=${true}
#    Log To Console    ${output}
#
#Get QFI for 5QI setup
#    [Arguments]    ${content}    ${5QI_id}
#    ${qosflow_added}    Set Variable    Added QosFlow with QFI:(\\d) 5QI:${5QI_id} SEID:1
#    ${qfi_id}    String.Get Regexp Matches    ${content}    ${qosflow_added}    1
#    Log to Console    ${qfi_id}
#    [Return]    ${qfi_id}[0]
#
#SA Start VONR DL TCP and UDP Traffic
#    [Arguments]    ${ue_id}    ${tcp_qfi}    ${udp_qfi}
#    Log To Console    Start DL TCP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${ue_id} pdu=1 qfi\=${tcp_qfi} trf_id=1 protocol=tcp dir=dl
#    Log To Console    Start DL UDP Traffic
#    ute_wtssim.Execute Egate Command    cmd=trf_data_start ue\=${UE_ID} pdu=1 qfi\=${udp_qfi} trf_id=2 mbps=10 dir=dl protocol=udp
#    Sleep    5s    reason=wait DL TCP traffic is stable
#
#Get and Check CA UE DL throughput
#    [Arguments]    ${ue_id}    ${pcell_dl_tp_threshold}    ${scell_dl_tp_threshold}
#    ${dl_tp}=    SA Get UE Average Traffic Internal    ue_id=${ue_id}    pdu_id=1    dir=dl
#    ${pcell_dl}=    Wait Until Keyword Succeeds    3min    5s
#    ...    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=pcell    scell_index=0
#    ${scell_dl}=    Wait Until Keyword Succeeds    3min    10s
#    ...    Get CA Cell Average Throughput    ue_id=${ue_id}    dir=dl    cell_type=scell    scell_index=1
#    Should Be True    ${pcell_dl}>${pcell_dl_tp_threshold} and ${scell_dl}>${scell_dl_tp_threshold}
#
