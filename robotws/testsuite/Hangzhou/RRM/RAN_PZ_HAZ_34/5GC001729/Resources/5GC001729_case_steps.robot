*** Settings ***
Documentation    CA Feature 5GC001729 Automation cases common steps
...              Auther: Stella.lin@nokia-sbell.com

Resource    ./5GC001729_keywords.robot

*** Variables ***
${1116_0ms_scf}    CA_blind_blind_1116_0ms.xml
${1116_3ms_scf}    CA_blind_blind_1116_3ms.xml

*** Keywords ***
#---  TestCases KW  ---#
5GC001729_A_05_SA_BF_Activated_Blind_Addition_Blind_Activation_Single_UE_connection_setup_and_DL_UL_data_scheduling_intra_band
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${CA_params}    Generate CA Related NIDD Params    pcell_chbw=80
    ...                                                scell_chbw=80
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         dl_data_transfer=2000M
    ...                         buffer_deactivate_round=1

5GC001729_A_06_SA_BF_Activated_A1_Addition_Buffer_Activation_Single_UE_connection_setup_and_DL_UL_data_scheduling_intra_band
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${CA_params}    Generate CA Related NIDD Params    pcell_chbw=80
    ...                                                scell_chbw=80
    ...                                                sCellAdditionMethod=covBasedA1
    ...                                                sCellActivationMethod=bufferBased
    ...                                                basicBeamSet=beamSet_5_1
    ...                                                numberOfTransmittedSsBlocks=6
    ...                                                sCellDeactivationTimerGNB=ms1280
    ...                                                actMeasBasedSCellAddition=true
    ...                                                actMeasBasedSCellAdditionNsa=true
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         scell_addition_method=A1
    ...                         scell_activation_method=buffer
    ...                         dl_data_transfer=2700M
    ...                         buffer_deactivate_round=1

5GC001729_A_08_SA_BF_Activated_A1_Addition_RLQ_deactivation_Single_UE_connection_setup_and_DL_UL_data_scheduling_intra_band
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${CA_params}    Generate CA Related NIDD Params    pcell_chbw=80
    ...                                                scell_chbw=80
    ...                                                sCellAdditionMethod=covBasedA1
    ...                                                sCellActivationMethod=bufferAndRLQualityBased
    ...                                                sCellDeactivationTimerGNB=ms1280
    ...                                                actMeasBasedSCellAddition=true
    ...                                                actMeasBasedSCellAdditionNsa=true
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         scell_addition_method=A1
    ...                         scell_activation_method=bufferAndRLQ
    ...                         dl_data_transfer=1700M
    ...                         buffer_deactivate_round=0
    ...                         is_ca_peak=${False}

5GC001729_A_19_SA_Online_modification_of_CA_Relationship_modification
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ${CA_params}    Generate CA Related NIDD Params    pcell_chbw=60
    ...                                                scell_chbw=60
    ...                                                srbInactivityTimerSA=15
    ...                                                drbInactivityTimerSA=15
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         dl_data_transfer=2000M
    ...                         buffer_deactivate_round=0
    Log To Console    \n***start to online modify sCellAdditionMethod from blind to covBasedA1***
    Online SCell Addition Method Modification
    Wait Gnb Ready And Cell On Air    timeout=5min
    Stop Traffic With Power UE    is_detach=${False}
    Sleep    20sec
    Start L3 Call Data Transfer    ul_data_transfer=10M
    ...                            dl_data_transfer=2700M
    ...                            need_get_ue_ip=${True}
    ...                            cpif_log_path=${attach_cpif_wireshark_log}
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${None}
    ...                         scell_addition_method=A1
    ...                         scell_activation_method=buffer
    ...                         dl_data_transfer=2700M
    ...                         buffer_deactivate_round=0
    ...                         is_do_require_ue=${False}

5GC001729_B_08_SA_Intra_gNB_Intra_Frequency_HO_From_Pcell_to_Other_Cell_with_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    1729_B_Common_Test_Steps        ul_data_transfer=100M
    ...                             dl_data_transfer=2400M
    ...                             expect_dl_tput_on_pcell=1033
    ...                             expect_dl_tput_on_scell=1033
    ...                             expect_ul_tput=95
    ...                             is_intra_gNB_inter_frequency_ho=${False}
    Intra-gnb HO Process            expect_dl_tput_on_pcell=1033
    ...                             expect_dl_tput_on_scell=1033
    ...                             expect_ul_tput=95



5GC001729_B_07_SA_Intra_gNB_Inter_Frequency_HO_From_Pcell_to_Other_Cell_with_CA
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    Update HO Related NIDD Params          actInterFreqHoSA=true
    ...                                    actIntraFreqHoSA=false
    1729_B_Common_Test_Steps               ul_data_transfer=100M
    ...                                    dl_data_transfer=2400M
    ...                                    expect_dl_tput_on_pcell=1033
    ...                                    expect_dl_tput_on_scell=1033
    ...                                    expect_ul_tput=95
    ...                                    is_intra_gNB_inter_frequency_ho=${True}
    Initial Inter-Frequency HO Process     expect_dl_tput_on_pcell=600
    ...                                    expect_dl_tput_on_scell=600
    ...                                    expect_ul_tput=50
    Intra-gnb HO Process                   expect_dl_tput_on_pcell=1033
    ...                                    expect_dl_tput_on_scell=1033
    ...                                    expect_ul_tput=95

5GC001729_C_11_Cell_Lock_of_TDD_Pcell_without_Graceful_Cell_Shutdown
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    ${CA_params}    Generate CA Related NIDD Params    pcell_chbw=60
    ...                                                scell_chbw=60
    ...                                                actCDrx=true
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         dl_data_transfer=2000M
    ...                         buffer_deactivate_round=0
    Log To Console    \n***start to online modify administrativeState of cell from Unlocked to Locked***
    Online Cell AdministrativeState Modification
    Wait Until Keyword Succeeds    5 min    20 sec    Connect to gnb coam via ssl    connection=GNB_OAM    gnb_index=${0}
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked    cell_idx=${PCELL_ID}
    ...                                                                   cell_group_idx=${PCELL_GROUP_ID}
    ...                                                                   timeout=10
    ...                                                                   connection=GNB_OAM
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Unlocked    cell_idx=${SCELL_ID}
    ...                                                                     cell_group_idx=${SCELL_GROUP_ID}
    ...                                                                     timeout=10
    ...                                                                     connection=GNB_OAM
    Sleep    30 sec
    Check No Tput Result    duration=90    cell_index=${SCELL_INDEX}
    Log To Console    \n***start to online modify administrativeState of cell from Locked to Unlocked***
    Online Cell AdministrativeState Modification    cell_administrativeState=Unlocked
    Wait Gnb Ready And Cell On Air    timeout=5min
    Stop Traffic With Power UE    is_detach=${True}
    Sleep    10 sec
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${None}
    ...                         dl_data_transfer=2000M
    ...                         buffer_deactivate_round=0
    ...                         is_do_require_ue=${False}
    ...                         wireshark_log_prefix=x2_log_reattach

5GC001729_C_09_Cell_Lock_of_TDD_Pcell_with_Graceful_Shutdown_UE_in_PCell_Handover_to_other_Cells
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]   ${is_ca_peak}=${False}   ${duration}=90   ${asik_alais}=ASIK Master   ${coam_connection}=GNB_OAM   ${gnb_index}=0
    Modify Attenuation Channel Vaules    value=63    vendor=HBTE    ru_id=1
    ${CA_params}    Update CA Related NIDD Params    pcell_chbw=80
    ...                                              scell_chbw=80
    ...                                              actGrflShdn=true
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         dl_data_transfer=1700M
    ...                         buffer_deactivate_round=0
    ...                         is_ca_peak=${is_ca_peak}
    Log To Console    \n***start to HO via online modify administrativeState of cell from Unlocked to Shutting Down***
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_handover
    ...                           asik_connection_alias=${asik_alais}
    ...                           gnb_index=${gnb_index}
    Modify Attenuation Channel Vaules    value=0    vendor=HBTE    ru_id=1
    Online Cell AdministrativeState Modification    cell_administrativeState=Shutting Down
    Wait Until Keyword Succeeds    5 min    20 sec    Connect to gnb coam via ssl    connection=${coam_connection}
    ...                                                                              gnb_index=${gnb_index}
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Locked    cell_idx=${PCELL_ID}
    ...                                                                   cell_group_idx=${PCELL_GROUP_ID}
    ...                                                                   timeout=10
    ...                                                                   connection=${coam_connection}
    Wait Until Keyword Succeeds   5 min  5 sec   Cell Should Be Unlocked    cell_idx=${SCELL_ID}
    ...                                                                     cell_group_idx=${SCELL_GROUP_ID}
    ...                                                                     timeout=10
    ...                                                                     connection=${coam_connection}
    Sleep    120 sec
    ${cpif_handover_log_on_testPC}    Stop tcpdump log collection    tcpdump_collector_name=cpif_handover
    ${cell_tput_check_info_dict}    Generate CA Call Tput Info Based On Chbw    is_ca_peak=${is_ca_peak}
    ...                                                                         pcell_idx=2
    ...                                                                         scell_idx=3
    Check L3 Call Tput    cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                   duration=${duration}
    ...                   asik_alais=${asik_alais}
    ...                   connection=${coam_connection}
    ...                   gnb_index=${gnb_index}
    Check IE Values On Measurement Report Message    wireshark_log=${cpif_handover_log_on_testPC}
    [Teardown]    Run Keywords    Log To Console    \n***start to online modify cell from Locked to Unlocked***    AND
    ...                           Online Cell AdministrativeState Modification    cell_administrativeState=Unlocked    AND
    ...                           Stop tcpdump log collection    tcpdump_collector_name=cpif_handover    AND
    ...                           Wait Gnb Ready And Cell On Air    timeout=5min

5GC001729_C_17_SA_DRX_Setup_For_CA_UE_Having_VoNR_measurement_based_1116_3ms
    [Documentation]    Author:jun.8.chen@nokia-sbell.com
    [Arguments]   ${is_ca_peak}=${True}   ${duration}=180   ${asik_alais}=ASIK Master   ${coam_connection}=GNB_OAM   ${gnb_index}=0
    ${CA_params}    Generate CA Related NIDD Params    pcell_chbw=80
    ...                                                scell_chbw=80
    ...                                                sCellAdditionMethod=covBasedA1
    ...                                                sCellActivationMethod=bufferBased
    ...                                                sCellDeactivationTimerGNB=ms1280
    ...                                                actMeasBasedSCellAddition=true
    ...                                                actMeasBasedSCellAdditionNsa=true
    ...                                                actCDrx=true
    ...                                                actVoNR=true
    ...                                                actCDrxVoNR=true
    ...                                                actEnhancedVoNR=true
    1729_A_Common_Test_Steps    CA_params_need_to_modify=${CA_params}
    ...                         scell_addition_method=A1
    ...                         scell_activation_method=buffer
    ...                         dl_data_transfer=2700M
    ...                         buffer_deactivate_round=0
    Start CP-IF Log Collection    tcpdump_collector_name=cpif_tcpdump_vonr
    ...                           asik_connection_alias=ASIK Master
    ...                           gnb_index=${0}
    ...                           du_index=${0}
    Make Voice Call    sleep_time=15 sec    phone_number=6688
    ${cpif_tcpdump_vonr_log_on_testPC}    Stop tcpdump log collection    tcpdump_collector_name=cpif_tcpdump_vonr
    Sleep    10 sec
    ${cell_tput_check_info_dict}    Generate CA Call Tput Info Based On Chbw    is_ca_peak=${is_ca_peak}
    Run Keyword And Continue On Failure    Check L3 Call Tput    cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                   duration=${duration}
    ...                   asik_alais=${asik_alais}
    ...                   connection=${coam_connection}
    ...                   gnb_index=${gnb_index}
    Sleep    5 min
    ${pcell_related_counters_list}    ${scell_related_counters_list}    Get CA Related PM Counters List

#---  TestSteps KW  ---#
1729_A_Common_Suite_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${PA_value}=8    ${PA_vendor}=HBTE    ${connection}=GNB_OAM    ${gnb_id}=0
    Common_setup_and_teardown.Common Suite Setup    is_commission=False
    Connect to gnb coam via ssl    connection=${connection}    gnb_index=${gnb_id}
    ${cell_mapping_res}    get_relation_mapping_between_cell_index_and_other_ids    connection_alias=${connection}
    Set Suite Variable    ${CELL_MAPPING_INFO}    ${cell_mapping_res}
    @{cell_ids}    Get Dictionary Keys    ${cell_mapping_res}
    Set Suite Variable    ${ALL_CELL_ID}    ${cell_ids}
    Modify Attenuation Channel Vaules    value=${PA_value}    vendor=${PA_vendor}    ru_id=0
    Modify Attenuation Channel Vaules    value=${PA_value}    vendor=${PA_vendor}    ru_id=1

1729_A_Common_Case_Teardown
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    Run Keyword And Ignore Error    Stop Traffic With Power UE
    Run Keyword And Ignore Error     Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=aasyslog
    Common Case Teardown    is_save_snapshot=False

1729_A_Common_Case_Setup
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${PA_value}=8    ${PA_vendor}=HBTE    ${scf_file_name}=${None}
    Connect to gnb coam via ssl
    ${lte_to_nr_frame_shift}    coam_parameter.get_single_value_from_scf_file
    ...                         parameter=lteToNrFrameShift
    ...                         dist_name=NRBTS-${NRBTS_ID}/NRCELL-${ALL_CELL_ID[0]}
    ...                         connection=GNB_OAM
    ${is_commission_status}    Set Variable If    '${scf_file_name.split('.')[0].split('_')[-1]}'=='${lte_to_nr_frame_shift}'
    ...                                            ${False}    ${True}
    Common Case Setup    scf_name=${scf_file_name}    is_commission=${is_commission_status}
    CA Common Variable Setting

1729_A_Common_Test_Steps
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                params:${scell_addition_method},value can be set to blind or A1
    ...                params:${scell_activation_method},value can be set to bilnd,buffer,bufferAndRLQ
    ...                TODO: 1. how to check buffer deactivate on syslog
    ...                      2. how to check multi drb on bip with luashark, no MAC-NR message.
    [Arguments]    ${CA_params_need_to_modify}=${None}
    ...            ${scell_addition_method}=blind
    ...            ${scell_activation_method}=blind
    ...            ${ul_data_transfer}=10M
    ...            ${dl_data_transfer}=50M
    ...            ${scell_addition_check_method}=cpif
    ...            ${buffer_deactivate_round}=2
    ...            ${is_multi_drb}=${False}
    ...            ${duration}=60
    ...            ${asik_alais}=ASIK Master
    ...            ${coam_connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${is_multi_pdu}=${False}
    ...            ${is_ca_peak}=${True}
    ...            ${is_do_require_ue}=${True}
    ...            ${wireshark_log_prefix}=x2_log_attach
    Run Keyword If    ${CA_params_need_to_modify} is not ${None}    Update Params Via RestApi
    ...                                                             params_need_to_modify=${CA_params_need_to_modify}
    ${attach_cpif_wireshark_log}    Start UE Attach With Power UE    is_wireshark_log_capture=${True}
    ...                                                              4G_check=${False}
    ...                                                              reset_sol=none
    ...                                                              sleep_interval=60 sec
    ...                                                              is_do_require_ue=${is_do_require_ue}
    ...                                                              wireshark_log_prefix=${wireshark_log_prefix}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Set Test Variable    ${attach_cpif_wireshark_log}
    ${status}    ${attach_aasyslog_list}    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC    log_prefix=5Grach
    Run Keyword If    '${scell_addition_check_method}'=='syslog'    Run Keyword And Ignore Error
    ...                5GC001729_keywords.Check Scell Addition Success
    ...                log_path=${attach_aasyslog_list[0]}
    ...                scell_addition_method=${scell_addition_method}
    ...                log_type=${scell_addition_check_method}
    ...    ELSE IF    '${scell_addition_check_method}'=='cpif'    Run Keyword And Ignore Error
    ...                5GC001729_keywords.Check Scell Addition Success
    ...                log_path=${attach_cpif_wireshark_log}
    ...                log_type=${scell_addition_check_method}
    PCELL And SCELL Related Params Setting    cpif_log_path=${attach_cpif_wireshark_log}
    ...                                       connection=${coam_connection}
    ...                                       gnb_index=${gnb_index}
    Run Keyword If    '${scell_activation_method}' == 'blind'    Run Keyword And Ignore Error
    ...                                                          5GC001729_keywords.Check Scell Activation Success
    ...                                                          log_path=${attach_aasyslog_list[0]}
    ...    ELSE    Run Keyword And Ignore Error    Check No Scell Activation    log_path=${attach_aasyslog_list[0]}
    Run Keyword If    '${scell_addition_method}' == 'A1'    Run Keyword And Continue On Failure
    ...                Check A1 Meaurement Report    log_path=${attach_cpif_wireshark_log}
    ${cell_tput_check_info_dict}    Generate CA Call Tput Info Based On Chbw    is_ca_peak=${is_ca_peak}
    ${data_transfer_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Ignore Error    Prepare And Start Aasyslog     log_name=aasyslog_for_data_transfer_${data_transfer_timestamp}.txt
    Run Keyword And Continue On Failure    Check Buffer Activate Procedure
    ...                                    cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                                    ul_data_transfer=${ul_data_transfer}
    ...                                    dl_data_transfer=${dl_data_transfer}
    ...                                    duration=${duration}
    ...                                    asik_alais=${asik_alais}
    ...                                    coam_connection=${coam_connection}
    ...                                    gnb_index=${gnb_index}
    ...                                    is_multi_pdu=${is_multi_pdu}
    Run Keyword If    '${scell_activation_method}' == 'bufferAndRLQ'    Run Keyword And Continue On Failure
    ...                                                                 Check RLQ Deactivate Procedure
    Run Keyword If    '${scell_activation_method}' == 'buffer' or '${scell_activation_method}' == 'blind'
    ...    Repeat Keyword    ${buffer_deactivate_round} times    Run Keyword And Continue On Failure
    ...                                                          Check Buffer Deactivate And Re_activate Procedure
    ...                                                          cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                                                          ul_data_transfer=${ul_data_transfer}
    ...                                                          dl_data_transfer=${dl_data_transfer}
    ...                                                          duration=${duration}
    ...                                                          asik_alais=${asik_alais}
    ...                                                          coam_connection=${coam_connection}
    ...                                                          gnb_index=${gnb_index}
    ...                                                          need_get_ue_ip=${True}
    ...                                                          cpif_log_path=${attach_cpif_wireshark_log}
    ...                                                          is_multi_pdu=${is_multi_pdu}
    ${status}    ${data_transfer_aasyslog}    Run Keyword And Ignore Error    Stop Aasyslog And Download To TestPC
    ...    log_prefix=aasyslog_for_data_transfer_${data_transfer_timestamp}
    Log To Console    \n*** start to check aasyslog ***
    ${buffer_activate_round}    Evaluate    ${buffer_deactivate_round}+${1}
    ${buffer_activate_round}    Set Variable If    '${scell_activation_method}' == 'blind'    ${buffer_deactivate_round}
    ...                                                                                       ${buffer_activate_round}
    Run Keyword And Ignore Error    5GC001729_keywords.Check Scell Activation Success    log_path=${data_transfer_aasyslog[0]}
    ...                                                               active_round=${buffer_activate_round}
    Run Keyword If  '${scell_activation_method}' == 'buffer'    Run Keyword And Ignore Error
    ...              Check Buffer Deactivate Success    log_path=${data_transfer_aasyslog[0]}
    ...                                                 deactive_round=${buffer_deactivate_round}
    Run Keyword If  '${scell_activation_method}' == 'bufferAndRLQ'    Run Keyword And Ignore Error
    ...              Check RLQ Deactivate Success    log_path=${data_transfer_aasyslog[0]}
    Run Keyword If    '${is_multi_drb}' == '${True}'    Check Multi DRB Procedure    cpif_log_path=${attach_cpif_wireshark_log}

1729_B_Common_Case_Setup
    [Documentation]    Authore:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${PA0_value}=0    ${PA1_value}=63    ${PA_vendor}=HBTE
    Common Case Setup
    Modify Attenuation Channel Vaules    value=${PA0_value}    vendor=${PA_vendor}    ru_id=0
    Sleep  5sec
    Modify Attenuation Channel Vaules    value=${PA1_value}    vendor=${PA_vendor}    ru_id=1
    Sleep  5sec
    CI_interface.Common Case Setup

1729_B_Common_Case_Teardown
    [Documentation]    Authore:xiangyue.zhou@nokia-sbell.com
    Run Keyword And Ignore Error     Stop Traffic With Power UE
    Run Keyword And Ignore Error     Close the iperf process on android ue    ue_index=${0}    iperf_port=${UL_PORT}
    Run Keyword And Ignore Error     run    command=ps -ef | grep firefox |awk '{print $2}' | xargs kill -9
    Run Keyword And Ignore Error     Stop Aasyslog And Download To TestPC    log_prefix=aasys
    Run Keyword And Ignore Error     Connect to gnb coam via ssl
    Run Keyword And Continue On Failure    Unexpect Alarm Should Not Exist   allowed_faults=${ALLOWED_FAULT}
    Run Keyword And Continue On Failure    Unexpect History Alarm Should Not Exist
    ...                                    allowed_faults=${ALLOWED_HISTORY_FAULT}
    Run Keyword And Ignore Error   COAM Teardown gnb connections
    CI_interface.Common Case Teardown

1729_B_Common_Suite_Setup
    [Documentation]    Auther: xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${scf_name}=None    ${is_commission}=${True}    ${connection}=ASIK Master
    Create Cplane Runtime File On Cluster    connection=${connection}
    Common_setup_and_teardown.Common Suite Setup    scf_name=${scf_name}    is_commission=${is_commission}

1729_B_Common_Test_Steps
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${scell_addition_check_method}=cpif
    ...            ${ul_data_transfer}=100M
    ...            ${dl_data_transfer}=2400M
    ...            ${expect_dl_tput_on_pcell}=1000
    ...            ${expect_dl_tput_on_scell}=1000
    ...            ${expect_ul_tput}=70
    ...            ${expect_dl_bler}=0.1
    ...            ${expect_ul_bler}=0.1
    ...            ${traffic_running_duration}=2400
    ...            ${duration}=240
    ...            ${check_drx_config}=${False}
    ...            ${is_intra_gNB_inter_frequency_ho}=${True}
    ...            ${actCarrierAggregation}=${True}
    ${attach_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure     Prepare And Start Aasyslog
    ...                             log_name=aasyslog_for_attach_procedure_${attach_timestamp}.txt
    ${attach_cpif_wireshark_log}    Start UE Attach With Power UE     is_wireshark_log_capture=${True}
    ...                             wireshark_log_prefix=attach_cpif_log_${attach_timestamp}
    ...                             4G_check=${False}
    ...                             detach_request=${False}
    ${attach_aasyslog_list}    Run Keyword And Continue On Failure    Stop Aasyslog And Download To TestPC
    ...                             log_prefix=aasyslog_for_attach_procedure
    Run Keyword If    '${scell_addition_check_method}'=='syslog'    Run Keyword And Continue On Failure
    ...                5GC001729_keywords.Check Scell Addition Success
    ...                log_path=${attach_aasyslog_list[0]}
    ...                log_type=${scell_addition_check_method}
    ...    ELSE IF    '${scell_addition_check_method}'=='cpif'    Run Keyword And Continue On Failure
    ...                5GC001729_keywords.Check Scell Addition Success
    ...                log_path=${attach_cpif_wireshark_log}
    ...                log_type=${scell_addition_check_method}
    Run Keyword And Ignore Error    5GC001729_keywords.Check Scell Activation Success    log_path=${attach_aasyslog_list[0]}
    Run Keyword If    '${check_drx_config}'=='${True}'    Check DRX Configure On CPIF Tcpdump
    ...                file_path=${attach_cpif_wireshark_log}
   ${event_id_list}    Run Keyword If    ${is_intra_gNB_inter_frequency_ho}   Create List    1
   ...                           ELSE     Create List    2    4
    Run Keyword And Continue On Failure   Add Meaurement Configuration For Target Event Id
    ...                             log_path=${attach_cpif_wireshark_log}
    ...                             event_id_list=${event_id_list}
    PCELL And SCELL Related Params Setting For CA HO   cpif_log_path=${attach_cpif_wireshark_log}
    ${data_transfer_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure          Start L3 Call And Check Throughput For CA Cell
    ...                                          ul_data_transfer=${ul_data_transfer}
    ...                                          dl_data_transfer=${dl_data_transfer}
    ...                                          expect_dl_tput_on_pcell=${expect_dl_tput_on_pcell}
    ...                                          expect_dl_tput_on_scell=${expect_dl_tput_on_scell}
    ...                                          expect_ul_tput=${expect_ul_tput}
    ...                                          expect_dl_bler=${expect_dl_bler}
    ...                                          expect_ul_bler=${expect_ul_bler}
    ...                                          traffic_running_duration=${traffic_running_duration}
    ...                                          duration=${duration}
    ...                                          pcell_index=${PCELL_INDEX}
    ...                                          scell_index=${SCELL_INDEX}
    ...                                          actCarrierAggregation=${actCarrierAggregation}

Check RLQ Deactivate Procedure
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                Decription: Adjust PA to trigger RLQ deactivate.
    [Arguments]     ${duration}=30
    ...             ${cell_index}=${PCELL_INDEX}
    ...             ${download_dir}=${TS_CASE_LOG_PATH}
    ...             ${asik_alais}=ASIK Master
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    Modify Attenuation Channel Vaules    value=63    ru_id=${cell_index}
    sleep    60sec
    Run Keyword And Continue On Failure    Check No Tput Result    duration=${duration}
    ...                                                            cell_index=${cell_index}
    ...                                                            download_dir=${download_dir}
    ...                                                            asik_alais=${asik_alais}
    ...                                                            connection=${connection}
    ...                                                            gnb_index=${gnb_index}
    Modify Attenuation Channel Vaules    value=8    ru_id=${cell_index}
    Sleep    30sec
    Check No Tput Result    duration=${duration}
    ...                     cell_index=${cell_index}
    ...                     download_dir=${download_dir}
    ...                     asik_alais=${asik_alais}
    ...                     connection=${connection}
    ...                     gnb_index=${gnb_index}
    [Teardown]        Run Keyword And Ignore Error    Modify Attenuation Channel Vaules    value=8    ru_id=${cell_index}

Check Buffer Activate Procedure
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                Decription: Buffer based scell activation procedure.
    [Arguments]    ${cell_tput_check_info_dict}
    ...            ${ul_data_transfer}=10M
    ...            ${dl_data_transfer}=50M
    ...            ${duration}=180
    ...            ${asik_alais}=ASIK Master
    ...            ${coam_connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${need_get_ue_ip}=${False}
    ...            ${cpif_log_path}=${None}
    ...            ${is_multi_pdu}=${False}
    ...            ${is_RLQ_reactivate}=${false}
    Start L3 Call Data Transfer    ul_data_transfer=${ul_data_transfer}
    ...                            dl_data_transfer=${dl_data_transfer}
    ...                            need_get_ue_ip=${need_get_ue_ip}
    ...                            cpif_log_path=${cpif_log_path}
    ...                            is_multi_pdu=${is_multi_pdu}
    sleep    10sec
    Check L3 Call Tput    cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                   duration=${duration}
    ...                   asik_alais=${asik_alais}
    ...                   connection=${coam_connection}
    ...                   gnb_index=${gnb_index}

Check Buffer Deactivate And Re_activate Procedure
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    ...                Decription: Buffer based scell de-activation and Re-activateion procedure.
    ...                TODO: how to check buffer deactivate on syslog
    [Arguments]    ${cell_tput_check_info_dict}
    ...            ${ul_data_transfer}=10M
    ...            ${dl_data_transfer}=50M
    ...            ${scell_activation_method}=blind
    ...            ${duration}=180
    ...            ${asik_alais}=ASIK Master
    ...            ${coam_connection}=GNB_OAM
    ...            ${gnb_index}=0
    ...            ${need_get_ue_ip}=${False}
    ...            ${cpif_log_path}=${None}
    ...            ${is_multi_pdu}=${False}
    Log To Console    \n***start buffer deactivate procedure***
    Stop Traffic With Power UE    is_detach=${False}
    Log To Console    \n***start to check buffer re-activate procedure***
    Check Buffer Activate Procedure    cell_tput_check_info_dict=${cell_tput_check_info_dict}
    ...                                ul_data_transfer=${ul_data_transfer}
    ...                                dl_data_transfer=${dl_data_transfer}
    ...                                duration=${duration}
    ...                                asik_alais=${asik_alais}
    ...                                coam_connection=${coam_connection}
    ...                                gnb_index=${gnb_index}
    ...                                need_get_ue_ip=${need_get_ue_ip}
    ...                                cpif_log_path=${cpif_log_path}
    ...                                is_multi_pdu=${is_multi_pdu}

Check No Tput Result
    [Documentation]    Author:stella.lin@nokia-sbell.com
    [Arguments]     ${duration}=30
    ...             ${cell_index}=${SCELL_INDEX}
    ...             ${download_dir}=${TS_CASE_LOG_PATH}
    ...             ${asik_alais}=ASIK Master
    ...             ${connection}=GNB_OAM
    ...             ${gnb_index}=0
    ${download_tput_file_dict}    Save Tput Result    connection=${connection}
    ...                                               gnb_index=${gnb_index}
    ...                                               asik_alais=${asik_alais}
    ...                                               duration=${duration}
    ...                                               download_dir=${download_dir}
    ${nrCellIdentity_list}   Get NR Cell Identity    connection=${connection}    gnb_index=${gnb_index}
    Log To Console    \n*** start to check no tput ***
    ${status}    ${cell_tput}    Run Keyword And Ignore Error    Check Tput With Single Direction
    ...                                                           direction=DL
    ...                                                           nrCellIdentity_list=${nrCellIdentity_list}
    ...                                                           tput_file_dict=${download_tput_file_dict}
    ...                                                           cell_index=${cell_index}
    ...                                                           expect_tput=0
    Should Be Equal    ${cell_tput}    ${0}    msg=the tupt of cell ${cell_index} is not 0.

Check Multi DRB Procedure
    [Documentation]    Auther: Stella.lin@nokia-sbell.com
    [Arguments]    ${cpif_log_path}
    Start Bip Capture    add_mirror_port=True
    Sleep    5sec
    ${drb_bip_log_list}    Stop Bip Capture    log_prefix=multi_drb
    Verify Multi DRB Function    cpif_log_path=${cpif_log_path}    bip_log_path=${drb_bip_log_list[0]}

Start L3 Call And Check Throughput For CA Cell
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]    ${ul_data_transfer}=10M
    ...            ${dl_data_transfer}=50M
    ...            ${expect_dl_tput_on_pcell}=1000
    ...            ${expect_dl_tput_on_scell}=1000
    ...            ${expect_ul_tput}=70
    ...            ${expect_dl_bler}=0.1
    ...            ${expect_ul_bler}=0.1
    ...            ${traffic_running_duration}=1200
    ...            ${duration}=240
    ...            ${pcell_index}=0
    ...            ${scell_index}=1
    ...            ${actCarrierAggregation}=${True}
    Start L3 Call With Power UE       ul_data_transfer=${ul_data_transfer}
    ...                               dl_data_transfer=${dl_data_transfer}
    ...                               duration=${traffic_running_duration}
    Sleep    10sec
    Verify Throughput For CA Cell       expect_dl_tput_on_pcell=${expect_dl_tput_on_pcell}
    ...                                 expect_dl_tput_on_scell=${expect_dl_tput_on_scell}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_dl_bler=${expect_dl_bler}
    ...                                 expect_ul_bler=${expect_ul_bler}
    ...                                 duration=${duration}
    ...                                 pcell_index=${pcell_index}
    ...                                 scell_index=${scell_index}
    ...                                 actCarrierAggregation=${True}

Intra-gnb HO Process
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Check HO process, check scell addition/activation
    ...                Check pcell/scell after HO
    ...                Check L3 Call througput
    [Arguments]    ${scell_addition_check_method}=cpif
    ...            ${asik_alais}=ASIK Master
    ...            ${expect_dl_tput_on_pcell}=1000
    ...            ${expect_dl_tput_on_scell}=1000
    ...            ${expect_ul_tput}=70
    ...            ${expect_dl_bler}=0.1
    ...            ${expect_ul_bler}=0.1
    ...            ${duration}=60
    ...            ${actCarrierAggregation}=${True}
    ${HO_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Prepare And Start Aasyslog    log_name=aasyslog_for_ho_procedure_${HO_timestamp}.txt
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log    tcpdump_collector_name=cpif_tcpdump_HO_${HO_timestamp}
    Modify Attenuation Channel Vaules    value=0    vendor=HBTE    ru_id=1
    Sleep  1sec
    Modify Attenuation Channel Vaules    value=10    vendor=HBTE    ru_id=0
    Sleep  10sec
    Modify Attenuation Channel Vaules    value=15    vendor=HBTE    ru_id=0
    Sleep  10sec
    Modify Attenuation Channel Vaules    value=63    vendor=HBTE    ru_id=0
    ${cpif_log_path_for_HO}    Run Keyword And Continue On Failure    Stop Container Wireshark Log Collection
    ...                        tcpdump_collector_name=cpif_tcpdump_HO_${HO_timestamp}
    ${HO_aasyslog_list}    Run Keyword And Continue On Failure    Stop Aasyslog And Download To TestPC
    ...                             log_prefix=aasyslog_for_ho_procedure
    Log To Console    \n*** start to analysis aasyslog ***
    Run Keyword If    '${scell_addition_check_method}'=='syslog'    Run Keyword And Continue On Failure
    ...                5GC001729_keywords.Check Scell Addition Success
    ...                log_path=${HO_aasyslog_list[0]}
    ...                log_type=${scell_addition_check_method}
    ...                scell_addition_method=A1
    ...    ELSE IF    '${scell_addition_check_method}'=='cpif'    Run Keyword And Continue On Failure
    ...                5GC001729_keywords.Check Scell Addition Success Via CPIF After HO
    ...                log_path=${cpif_log_path_for_HO}
    Run Keyword And Ignore Error  5GC001729_keywords.Check Scell Activation Success    log_path=${HO_aasyslog_list[0]}
    Check HO Process And Params Setting    cpif_log_path_for_HO=${cpif_log_path_for_HO}
    ...                                    syslog_log_path_for_HO=${HO_aasyslog_list[0]}
    ...                                    syslog_filter_pattern=(?i)SA\\s+handover\\s+completed\\s+with\\s+status\\s+Completed
    ${tp_check_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Verify Throughput For CA Cell
    ...                                 expect_dl_tput_on_pcell=${expect_dl_tput_on_pcell}
    ...                                 expect_dl_tput_on_scell=${expect_dl_tput_on_scell}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_dl_bler=${expect_dl_bler}
    ...                                 expect_ul_bler=${expect_ul_bler}
    ...                                 duration=${duration}
    ...                                 pcell_index=${pcell_index}
    ...                                 scell_index=${scell_index}
    ...                                 actCarrierAggregation=${True}
Check HO Process And Params Setting
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    [Arguments]        ${cpif_log_path_for_HO}
    ...                ${syslog_log_path_for_HO}
    ...                ${syslog_filter_pattern}
    ...                ${connection}=GNB_OAM
    ...                ${gnb_index}=0
    Run Keyword And Ignore Error    Verify HO Complete Via Btslog    log_path=${syslog_log_path_for_HO}
    ...                             syslog_filter_pattern=${syslog_filter_pattern}
    ${measId}    Check Target Item Value on CPIF Tcpdump    file_path=${cpif_log_path_for_HO}
    ...         filter_expression=(f1ap.procedureCode==13) && (nr-rrc.measId)
    ...         xpath=..//nr-rrc.measId
    List Should Contain Value    ${measId_list}    ${measId[0]}    msg=A3 or A5 Measurement report triggered failure For HO！
    PCELL And SCELL Related Params Setting For CA HO   cpif_log_path=${cpif_log_path_for_HO}
    ...                                                connection=${connection}
    ...                                                gnb_index=${gnb_index}

Initial Inter-Frequency HO Process
    [Documentation]    Author:xiangyue.zhou@nokia-sbell.com
    ...                Only used in intra-gnb iner-frequency process,
    ...                check A2 measurment is triggered
    ...                Check measurement gap configured
    ...                Check L3 Call througput
    [Arguments]    ${expect_dl_tput_on_pcell}=1000
    ...            ${expect_dl_tput_on_scell}=1000
    ...            ${expect_ul_tput}=70
    ...            ${expect_dl_bler}=0.1
    ...            ${expect_ul_bler}=0.1
    ...            ${duration}=60
    ...            ${actCarrierAggregation}=${True}
    ${HO_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Start Container Capture Wireshark Log
    ...                                    tcpdump_collector_name=cpif_tcpdump_initial_HO_${HO_timestamp}
    Modify Attenuation Channel Vaules    value=15    ru_id=0   gnb_id=0
    Sleep    20sec
    ${cpif_log_path_for_initial_HO}    Run Keyword And Continue On Failure   Stop Container Wireshark Log Collection
    ...                                tcpdump_collector_name=cpif_tcpdump_initial_HO_${HO_timestamp}
    ${measId}    Check Target Item Value on CPIF Tcpdump    file_path=${cpif_log_path_for_initial_HO}
    ...         filter_expression=(f1ap.procedureCode==13) && (nr-rrc.measResultServingMOList)
    ...         xpath=.//nr-rrc.measId
    Lists Should Be Equal    ${measId_list}    ${measId}    msg=A2 Measurement report triggered for failure For HO!
    Gnb Response To Add A2 Event via RRC reconfiguration    log_path=${cpif_log_path_for_initial_HO}
    ${ReportConfigId_value}    ${MeasId_value}    Delete Measurement Configuration Via RRC Reconfiguration
    ...                                           log_path=${cpif_log_path_for_initial_HO}
    Lists Should Be Equal    ${measId_list}    ${MeasId_value}
    Lists Should Be Equal    ${reportConfigId_list}    ${ReportConfigId_value}
    ${event_id_list}    Create List    0    2    4
    Add Meaurement Configuration For Target Event Id    log_path=${cpif_log_path_for_initial_HO}
    ...                                                 event_id_list=${event_id_list}
    ${gapUE_value}   Check Measurement Gap Configuration    log_path=${cpif_log_path_for_initial_HO}
    Should Be Equal    ${gapUE_value[0]}    1    msg=Measurement gap configuration failure!
    ${data_transfer_timestamp}    Get current date    result_format=%Y%m%d%H%M%S
    Run Keyword And Continue On Failure    Verify Throughput For CA Cell
    ...                                 expect_dl_tput_on_pcell=${expect_dl_tput_on_pcell}
    ...                                 expect_dl_tput_on_scell=${expect_dl_tput_on_scell}
    ...                                 expect_ul_tput=${expect_ul_tput}
    ...                                 expect_dl_bler=${expect_dl_bler}
    ...                                 expect_ul_bler=${expect_ul_bler}
    ...                                 duration=${duration}
    ...                                 pcell_index=${PCELL_INDEX}
    ...                                 scell_index=${SCELL_INDEX}
    ...                                 actCarrierAggregation=${True}

Update CA Related NIDD Params
    [Documentation]   Auther: jun.8.chen@nokia-sbell.com
    [Arguments]    ${pcell_chbw}=80
    ...            ${scell_chbw}=80
    ...            ${actGrflShdn}=false
    ...            ${miNrRSACU}=5min
    ${common_params}    Catenate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_PCELL_ID}', 'parameter': 'chBw', 'value': '${pcell_chbw}MHz'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'chBw', 'value': '${scell_chbw}MHz'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}', 'parameter': 'actGrflShdn', 'value': '${actGrflShdn}'},
    ...    {'dist_name': 'NRBTS-${NRBTS_ID}/NRPMRNL-1', 'parameter': 'miNrRSACU', 'value': '${miNrRSACU}'}
    ${scell_arfcn}    Set Variable    ${SCELL_ARFCN_TABLE['${pcell_chbw}_${scell_chbw}']}
    ${extra_param}    Catenate    {'dist_name': 'NRBTS-${NRBTS_ID}/NRCELL-${Pre_SCELL_ID}', 'parameter': 'nrarfcn', 'value': '${scell_arfcn}'}
    ${extra_param}    Evaluate    [${extra_param}]
    ${common_params}    Evaluate     [${common_params}]
    ${update_params}    Combine Lists    ${extra_param}    ${common_params}
    [Return]    ${update_params}
