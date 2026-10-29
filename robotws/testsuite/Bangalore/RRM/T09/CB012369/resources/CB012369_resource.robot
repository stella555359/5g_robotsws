*** Settings ***
Documentation   CB012369 Keyword file

Resource         ../../../5GET_BLR/resources/robot/wts_sim_keywords.robot
Resource         ../../../5GET_BLR/resources/robot/common_log_collection.robot
Resource         ../../../5GET_BLR/resources/robot/wts_sim_keywords.robot
Resource         ../../../5GET_BLR/resources/robot/common_log_collection.robot
Library          taf.analyzer.pdml    WITH NAME    taf_pdml_analyser
Library          taf.analyzer.pcap    WITH NAME    parser
Resource         ../../../5GET_BLR/resources/robot/Airphone.robot
Resource         ../../../5GET_BLR/resources/robot/PM_Counters.robot
Resource         ../../../5GET_BLR/5GC000937/resources/5GC000937_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
#Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../5GET_BLR/resources/robot/Setup_Env.robot
Library          ../../../5GET_BLR/resources/python/BIP_Capture.py
Library          ../../../5GET_BLR/resources/python/CPRT_Capture.py
Library          ../../../5GET_BLR/resources/python/avg_dl_data.py
Library          taf.sw.scout    WITH NAME     scout

*** Variables ***
${qfi}                1
${trf_id}             1
${eNB_ID}		      1
${eNB_target}         2
${Target_Cells}       1
${expected_dl_thp}    150
${expected_ul_thp}    50
${bearer_id}          2
${dl_data}            160
${scell_idx_SA}       0
${scell_idx_NSA}       8

*** Keywords ***
Attach UE and validate DSCP value
    [Arguments]    ${ue_id}    ${nsa_UEID}=0    ${exp_dscp}=0    ${pdu_id}=${Pdu_session_ID}
    [Documentation]    This keyword trigger L3 call and checks the dscp value during attach
    Start log    cprt
    UE Register should be Successful      ${ue_id}
    ${path_cprtlog_SA}   Stop log   cprt    test_scenario=UE_attach_SA_${ue_id}
    Trigger data    ${ue_id}     dl		${pdu_id}     ${trf_id}		${qfi}    Mbps		${dl_data}
    Trigger data    ${ue_id}     ul		${pdu_id}     ${trf_id}		${qfi}    Mbps		50
    Run Keyword if   ${nsa_UEID}!=0    NSA attach    ${nsa_UEID}
    Validate DSCP value from cprt log    ${path_cprtlog_SA}    ${exp_dscp}
    Run Keyword if   ${nsa_UEID}!=0    Validate DSCP value from cprt log    ${path_cprtlog_NSA}    ${exp_dscp}

NSA attach
    [Arguments]     ${nsa_UEID}
    Start log    cprt
    NSA X2AP Link Should be UP    ${eNB_ID}		${eNB_target}
    NSA LTE Attach should be Successful    ${nsa_UEID}
    NSA UE Attach should be Successful     ${nsa_UEID}    ${Target_Cells}
    ${path_cprtlog_NSA}   Stop log   cprt    test_scenario=UE_attach_NSA_${nsa_UEID}
    Set Suite Variable    ${path_cprtlog_NSA}
    Trigger DL Traffic for NSA    ${nsa_UEID}        Mbps     ${dl_data}    ${bearer_id}    ${trf_id}
    Trigger UL Traffic for NSA    ${nsa_UEID}        Mbps     70    ${bearer_id}    ${trf_id}

Validate DSCP value from cprt log
    [Arguments]     ${test_scenario}    ${exp_dscp}
    [Documentation]    This keyword validates DSCP value from cprt log
    common_log_analyzer.Download MCShark To UTE    ${GNB_SW_VERSION}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${test_scenario}[cprt]/NODECPRT_GNB.pcap
    ...      itf_l2_hi_cu_user_bearersetupreq||itf_l2_hi_du_user_BearerSetupReq_t.logicalChannelId == 4
    ${path_cu} =   Catenate  SEPARATOR=  icom_5g/hiusercu/itf_l2_hi_cu_user_bearersetupreq/itf_l2_hi_cu_user
    ...  _bearersetupreq_t/itf_l2_hi_cu_qos_params/itf_l2_hi_cu_qos_mapping/itf_l2_hi_cu_qos_Mapping.dscp
    ${packet}    set variable    itf_l2_hi_cu_qos_Mapping.dscp
    ${dscp_cu}   analyzer.get_unique  pdmlFile=${pdmlFile}
    ...                               packetName=${packet}
    ...                               path=${path_cu}
    ...                               endPacket=1
    Log to Console   ${dscp_cu}
    Run Keyword if   ${dscp_cu} !=${exp_dscp}   Fail   CU Dscp check failed
    ...         else    Pass     Dscp check passed
    ${path_du} =   Catenate  SEPARATOR=  icom_5g/hiuserdu/itf_l2_hi_du_user_bearersetupreq/itf_l2_hi_du_user
    ...    _bearersetupreq_t/itf_l2_hi_du_qos_params/itf_l2_hi_du_qos_mapping/itf_l2_hi_du_qos_Mapping.dscp
    ${packet}    set variable    itf_l2_hi_du_qos_Mapping.dscp
    ${filter}  set variable
    ${dscp_du}    analyzer.get_unique    pdmlFile=${pdmlFile}
    ...                                  packetName=${packet}
    ...                               path=${path_du}
    ...                                  endPacket=1
    Run Keyword if   ${dscp_du} !=${exp_dscp}   Fail   DU Dscp check failed
    ...     else    Pass     Dscp check passed


Validate DL and UL data transfer
    [Arguments]     ${start_ueid}    ${end_ueid}    ${NSA_UE_ID_51}
    ${UE1_dl_tp}    Get AVG DL DATA TRAFFIC For Given CC    ${start_ueid}    ${scell_idx_SA}
    ${UE1_ul_tp}    Get AVG UL DATA TRAFFIC For Given CC    ${start_ueid}    ${scell_idx_SA}
    ${UE2_dl_tp}    Get AVG DL DATA TRAFFIC For Given CC    ${end_ueid}    ${scell_idx_SA}
    ${UE2_ul_tp}    Get AVG UL DATA TRAFFIC For Given CC    ${end_ueid}    ${scell_idx_SA}
    ${UE51_dl_tp}    Get AVG DL DATA TRAFFIC For Given CC   ${NSA_UE_ID_51}    ${scell_idx_NSA}
    ${UE51_ul_tp}    Get AVG UL DATA TRAFFIC For Given CC   ${NSA_UE_ID_51}    ${scell_idx_NSA}
    Should Be True    ${UE1_dl_tp} > ${expected_dl_thp}
    Should Be True    ${UE1_ul_tp} > ${expected_ul_thp}
    Should Be True    ${UE2_dl_tp} > ${expected_dl_thp}
    Should Be True    ${UE2_ul_tp} > ${expected_ul_thp}
    Should Be True    ${UE51_dl_tp} > ${expected_dl_thp}
    Should Be True    ${UE51_ul_tp} > ${expected_ul_thp}
