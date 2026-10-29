*** Settings ***
Documentation   CB012369 Keyword file

#Resource         ../../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../../resources/robot/common_log_collection.robot
#Resource         ../../../../resources/robot/wts_sim_keywords.robot
Resource         ../../../../resources/robot/WTS_Runner_Keywords.robot
Resource         ../../../../resources/robot/common_log_collection.robot
Library          taf.analyzer.pdml    WITH NAME    taf_pdml_analyser
Library          taf.analyzer.pcap    WITH NAME    parser
Resource         ../../../../resources/robot/Airphone.robot
Resource         ../../../../resources/robot/PM_Counters.robot
Resource         ../../5GC000937/resources/5GC000937_Keywords.robot
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          taf.wts.runner              WITH NAME    wtsrunner
Resource         taf/rfrl/common_resources/robot/coam.robot
Resource         ../../../../resources/robot/Setup_Env.robot
Library          ../../../../resources/python/BIP_Capture.py
Library          ../../../../resources/python/CPRT_Capture.py
Library          ../../../../resources/python/avg_dl_data.py
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_enb

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
${RTP_COD}            custom
${QFI_ID_2}           5
${QFI_ID_3}           6

*** Keywords ***
Attach UE and validate DSCP value
    [Arguments]    ${ue_id}    ${nsa_UEID}=0    ${exp_dscp}=0
    [Documentation]    This keyword trigger SA L3 call and checks the dscp value during attach
    Start log    cprt
    WTS_Runner_Keywords.UE Register should be Successful      ${ue_id}
    ${path_cprtlog_SA}   Stop log   cprt    test_scenario=UE_attach_SA_${ue_id}
    WTS_Runner_Keywords.Trigger DL Data Traffic for SA    ${ue_id}     Mbps		${dl_data}
    WTS_Runner_Keywords.Trigger UL Non Bursty Data Traffic for SA    ${ue_id}    Mbps		50
    Run Keyword if   ${nsa_UEID}!=0    NSA attach    ${nsa_UEID}
    Validate DSCP value from cprt log    ${path_cprtlog_SA}    ${exp_dscp}
    Run Keyword if   ${nsa_UEID}!=0    Validate DSCP value from cprt log    ${path_cprtlog_NSA}    ${exp_dscp}

NSA attach
    [Arguments]     ${nsa_UEID}
    [Documentation]    This keyword trigger NSA L3 call and checks the dscp value during attach
    Start log    cprt
    X2AP Link Should be UP
    LTE Attach should be Successful    ${nsa_UEID}
    UE Attach should be Successful     ${nsa_UEID}    ${Target_Cells}
    ${path_cprtlog_NSA}   Stop log   cprt    test_scenario=UE_attach_NSA_${nsa_UEID}
    Set Suite Variable    ${path_cprtlog_NSA}
    WTS_Runner_Keywords.Trigger DL Traffic for NSA      ${nsa_UEID}        Mbps     ${dl_data}
    WTS_Runner_Keywords.Trigger UL Traffic for NSA      ${nsa_UEID}        Mbps     70

Validate DSCP value from cprt log
    [Arguments]     ${test_scenario}    ${exp_dscp}
    [Documentation]    This keyword validates DSCP value from cprt log
    common_log_analyzer.Download MCShark To UTE    ${GNB_SW_VERSION}
    ${pdmlFile}=    analyzer.pcap_to_pdml    ${test_scenario}[cprt]/NODECPRT_GNB.pcap
    ...      itf_l2_hi_cu_user_bearersetupreq||itf_l2_hi_du_user_BearerSetupReq_t.logicalChannelId > 3
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

Trigger HO to simulated GNB and back with online modification
    [Documentation]    This keyword validates triggers ping pong HO with DSCP value check from cprt log
    WTS_Runner_BF_CA_HO_Keywords.Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB    1    2    63
    sleep    10s
    Start log    cprt
    WTS_Runner_BF_CA_HO_Keywords.Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB    1    2    51
    ${path_cprtlog_SAHO}   Stop log   cprt    test_scenario=UE_HO_SA
    sleep    10s
    WTS_Runner_BF_CA_HO_Keywords.Trigger A3 RsrpAndRsrq Measurement from real gnb to simulated gNB    ${ue_id}    10    63
    sleep    10s
    5GC000937_Keywords.Perform SCF Delta Commissioning with Delta_Configuration_scf_Disable.json
    Start log    cprt
    WTS_Runner_BF_CA_HO_Keywords.Trigger A3 RsrpAndRsrq Measurement from simulated gnb to real gNB    ${ue_id}    1    51
    sleep    10s
    ${path_cprtlog_SAHO_disable}   Stop log   cprt    test_scenario=UE_HO_dis_SA
    Validate DSCP value from cprt log    ${path_cprtlog_SAHO_disable}    ${exp_dscp_0}

Trigger SgNB and PDU session Modification
    [Documentation]    This keyword triggers SGNB modification
    BuiltIn.Log    Triggerring SGNB Modification    console=${True}
    Start log    cprt
    wtsrunner.bearer_add    ue=${NSA_UE_ID_51}    id=3     filter=2     precedence=5
    wtsrunner.enb_ue_dc_modify    ue=${NSA_UE_ID_51}    by=enb    bearer_to_add=3    cause=off
    ${sgnb_mod}   Stop log   cprt    test_scenario=sgnb_mod
    Validate DSCP value from cprt log    ${sgnb_mod}    ${exp_dscp_2}
    WTS_Runner_Keywords.Trigger DL Traffic for NSA      ${NSA_UE_ID_51}        Mbps     ${dl_data}     3
    WTS_Runner_Keywords.Trigger UL Traffic for NSA      ${NSA_UE_ID_51}        Mbps     70     3
    BuiltIn.Log    Triggerring SGNB Modification    console=${True}
    WTS_Runner_Keywords.UE PDU Modfication should be Successful    ${start_ueid}      ${Pdu_session_ID}      ${QFI_ID_2}
    Start log    cprt
    WTS_Runner_Keywords.UE PDU Modfication should be Successful    ${start_ueid}      ${Pdu_session_ID}      ${QFI_ID_3}
    ${pdu_mod}   Stop log   cprt    test_scenario=pdu_mod
    WTS_Runner_Keywords.Trigger VoNR DL Traffic for SA    ${start_ue_id}     ${Pdu_session_ID}     ${trf_id}     3     ${RTP_COD}
    WTS_Runner_Keywords.Trigger VoNR UL Traffic for SA    ${start_ue_id}     ${Pdu_session_ID}     ${trf_id}     3     ${RTP_COD}
    Validate DSCP value from cprt log    ${sgnb_mod}    ${exp_dscp_3}


Validate DL and UL data transfer
    [Arguments]     ${start_ueid}    ${end_ueid}    ${NSA_UE_ID_51}
    [Documentation]    This keyword validates the throughput per UE
    WTS_Runner_Keywords.Validate DL Traffic For SA      ${start_ueid}      160
    WTS_Runner_Keywords.Validate UL Traffic For SA      ${start_ueid}      ${expected_ul_thp}
    WTS_Runner_Keywords.Validate DL Traffic For SA      ${end_ueid}      160
    WTS_Runner_Keywords.Validate UL Traffic For SA      ${end_ueid}      ${expected_ul_thp}
    Log to Console    ${NSA_UE_ID_51}

Get Active gNB Alarms
    [Documentation]    Keyword to check the active gNB alarms before and after lock/unlock
    ...                Modified Date: 09/04/2025
    ...                Last Modified by: anjana.kulkarni@nokia.com
    [Arguments]    ${alaram_dict}
    ${alarm_list}=    CoamAdmin.get_active_alarms    timeout=50s
    ${alarm_len}=    Get Length    ${alarm_list}
    FOR    ${index}    IN RANGE    0    ${alarm_len}    1
        Set To Dictionary    ${alaram_dict}    ${alarm_list[${index}]['faultName']}=${alarm_list[${index}]['faultId']}
    END
