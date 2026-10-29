*** Settings ***
Library          taf.transport.ssh           WITH NAME    taf_ssh
Library          Collections
Resource         ../CB008541/resources/CB008541_Keywords.robot
Resource         ../../../resources/robot/common_log_collection.robot
Resource         ../../../resources/robot/wts_sim_keywords.robot
Library          taf.sw.scout    WITH NAME     scout
Library          ta5g_pm_counters
Library          ute_wtssim
Library          cb008963_discard_pm.py

Documentation
...      INTRODUCTION: generic keywords for CB008963

*** Keywords ***
Register UE with GBR and check default bearer and PDCP length
    [Arguments]    ${ue_id}    ${default_drb}    ${pdcplength}
    Run Keyword If    ${Validation}==${True}    Start Log    btslog   cprt
    ${rnti}    wts_sim_keywords.UE Register should be Successful And Fetch RNTI    ue_id=${UEID}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     dl_rate=1     pdu_id=1   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     ul_rate=1     pdu_id=1   trf_id=1
    ${attach_5QI1}    Run Keyword If    ${Validation}==${True}    Stop Log    btslog   cprt    test_scenario=attach_${UEID}
    Run Keyword If    ${Validation}==${True}    Checkdrbdefault    ${attach_5QI1}[cprt]   ${default_drb}
    Run Keyword If    ${Validation}==${True}    CheckPDCPLength    ${attach_5QI1}[cprt]   ${pdcplength}

Add Qos flow and check PDCP Lenght and Default DRB
    [Arguments]   ${ue_id}   ${pdu_id}    ${flow_dict}    ${5QI}
    Run Keyword If    ${Validation}==${True}     Start Log    btslog   cprt
    ${value}    Get From Dictionary   ${flow_dict}    ${5QI}
    wts_sim_keywords.UE PDU Modfication should be Successful    ue_id=${ue_id}      pdu_id=${pdu_id}     qosflows_to_add=${value}[0]
    wts_sim_keywords.Trigger DL Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     dl_rate=1     pdu_id=${pdu_id}   trf_id=1    qfi_id=${5QI}
    wts_sim_keywords.Trigger UL Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     ul_rate=1     pdu_id=${pdu_id}   trf_id=1    qfi_id=${5QI}
    ${add_qosflow}    Run Keyword If    ${Validation}==${True}     Stop Log    btslog   cprt    test_scenario=add_PDU1_${5QI}
    Run Keyword If    ${Validation}==${True}    CheckPDCPLength   ${add_qosflow}[cprt]   ${value}[1]
    Run Keyword If    ${Validation}==${True}    Checkdrbdefault    ${add_qosflow}[cprt]   ${value}[2]

Add PDU to UE and send data Check PDCP Lenght and Default DRB
    [Arguments]   ${ue_id}   ${pdu_id}    ${nw_id}    ${gw_id}    ${default_drb}    ${pdcplength}
    Run Keyword If    ${Validation}==${True}    Start Log    btslog   cprt
    wts_sim_keywords.UE PDU Addition should be Successful    ue_id=${ue_id}     pdu_id=${pdu_id}     nw_id=${nw_id}    gw_id=${gw_id}
    wts_sim_keywords.Trigger DL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     dl_rate=1     pdu_id=${pdu_id}   trf_id=1
    wts_sim_keywords.Trigger UL Data Traffic for SA    ue_id=${ue_id}      Traffic_rate=mbps     ul_rate=1     pdu_id=${pdu_id}   trf_id=1
    ${add_pdu}  Run Keyword If    ${Validation}==${True}   Stop Log    btslog   cprt    test_scenario=add_pdu_${ue_id}_${pdu_id}
    Run Keyword If    ${Validation}==${True}  Checkdrbdefault    ${add_pdu}[cprt]     ${default_drb}
    Run Keyword If    ${Validation}==${True}  CheckPDCPLength    ${add_pdu}[cprt]     ${pdcplength}

Checkdrbdefault
    [Arguments]    ${file_path}   ${status}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}/NODECPRT_GNB.pcap    filterExp=e1ap
    ${defaultDRB}   Set Variable If    '${status}' == 'false'    defaultDRB: ${status} (1)     defaultDRB: ${status} (0)
    ${pdmlentry}     get_pdml_entries    ${pdmlFile}
	...          field_name=e1ap.defaultDRB     attrib_name=showname  attrib_value=${defaultDRB}
    ${attrib_value}    taf_pdml_analyser.get_attrib_value_from_pdml_entries   ${pdmlentry}
	...          field_name=e1ap.defaultDRB     attrib_name=showname
    Run Keyword And Continue On Failure    Should Contain   ${attrib_value}[0]    ${status}

CheckPDCPLength
    [Arguments]    ${file_path}   ${length}
    ${pdmlFile} =    Get filtered PDML file from pcap   pcapFile=${file_path}/NODECPRT_GNB.pcap    filterExp=e1ap
    Set Suite Variable    ${length}
    IF   ${length}==18
        Run Keyword   PDCPLength for 18 bits    ${pdmlFile}
    ELSE
        Run Keyword   PDCPLength for 12 bits    ${pdmlFile}
    END
    ${pdml_entriesUL}    taf_pdml_analyser.get_attrib_value_from_pdml_entries   ${pdmlentryUL}
	  ...          field_name=e1ap.pDCP_SN_Size_UL     attrib_name=showname
	  ${pdml_entriesDL}    taf_pdml_analyser.get_attrib_value_from_pdml_entries   ${pdmlentryDL}
    ...          field_name=e1ap.pDCP_SN_Size_DL     attrib_name=showname
	  Run Keyword And Continue On Failure    Should Contain   ${pdml_entriesUL}[0]    ${length}
	  Run Keyword And Continue On Failure    Should Contain   ${pdml_entriesDL}[0]    ${length}

PDCPLength for 18 bits
    [Arguments]    ${pdmlFile}
    ${pdmlentryUL}     get_pdml_entries    ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_UL     attrib_name=showname    attrib_value=pDCP-SN-Size-UL: s-${length} (1)
    Set Suite Variable    ${pdmlentryUL}
	  ${pdmlentryDL}     get_pdml_entries     ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_DL     attrib_name=showname    attrib_value=pDCP-SN-Size-DL: s-${length} (1)
    Set Suite Variable    ${pdmlentryDL}

PDCPLength for 12 bits
    [Arguments]    ${pdmlFile}
    ${pdmlentryUL}     get_pdml_entries    ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_UL     attrib_name=showname    attrib_value=pDCP-SN-Size-UL: s-${length} (0)
    Set Suite Variable    ${pdmlentryUL}
	  ${pdmlentryDL}     get_pdml_entries     ${pdmlFile}
	  ...          field_name=e1ap.pDCP_SN_Size_DL     attrib_name=showname    attrib_value=pDCP-SN-Size-DL: s-${length} (0)
    Set Suite Variable    ${pdmlentryDL}

Verify legacy Counters
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    >100     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    >100     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    >100     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
#    ...     M55310C01007      0      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008      0      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009      0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    >100     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    >100     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    >100     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    >100     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    >100     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    >100     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
#    ...     M55310C03007      0      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008      0      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009      0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    >100     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    >100     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    >100     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}

Trigger multiple UE HO to Target Cell
    [Arguments]    ${start_ue}   ${end_ue}   ${meas_id}   ${target_cell}
    Run Keyword If    ${Validation}==${True}    Start Log    btslog   cprt
    FOR   ${ue_id}   IN RANGE    ${start_ue}   ${end_ue}+1
        wts_sim_keywords.Get Configured Measurements of UE1
	    wts_sim_keywords.Trigger A3 RsrpAndRsrq Measurement for intragnb HO    ${ue_id}   ${meas_id}    ${target_cell}
    END
    Run Keyword If    ${Validation}==${True}    Stop Log    btslog   cprt    test_scenario=Trigger_HO_NRcell_${target_cell}

Change Default 5QI Value Qos Flow
   [Arguments]   ${qos_flow}    ${5qi}   ${type}=gbr   ${default}=on   ${dummy}=9
   ${change_default_5QI}   Set Variable    qosflow_modify qos_flow=${qos_flow} 5qi=${5qi} fiveqi_type=${type} default=${default}
   ${change_default_5QI_to_dummy}   Set Variable  qosflow_modify qos_flow=${qos_flow} 5qi=${dummy} fiveqi_type=non-gbr default=${default}
   ute_wtssim.Execute Egate Command    ${change_default_5QI_to_dummy}    timeout=${EGATE_COMMAND_TIMEOUT}
   ute_wtssim.Execute Egate Command    ${change_default_5QI}    timeout=${EGATE_COMMAND_TIMEOUT}

Verify RLC legacy Counters Feature Specific
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    >100     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    >100     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    0     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
    ...     M55310C01007    >100      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008      0      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009      0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    >100     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    0     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    0     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    >100     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    >100     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    0     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
    ...     M55310C03007    >100      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008      0      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009      0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    >100     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    0     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    0     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     M55125C05505    1     NNGCC_PDU_SES_STP_REQ_EC_RECD_emergency
    ...     M55125C05506    1     NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    2     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2     NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-1
    ...     file_path=${pm_counter_file}


Verify RLC legacy Counters after HO to in Target NRcell-${id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    >100     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    >100     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    >100     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    >100     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    >100     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    0     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
    ...     M55310C01007    >100      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008    >100      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009      0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    >100     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    0     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    0     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    >100     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    >100     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    >100     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    >100     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    >100     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    0     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
    ...     M55310C03007    >100      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008    >100      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009      0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    >100     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    0     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    0     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     M55125C05505    1     NNGCC_PDU_SES_STP_REQ_EC_RECD_emergency
    ...     M55125C05506    1     NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    2     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    2     NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-${id}
    ...     file_path=${pm_counter_file}

Verify RLC legacy Counters after HO in source NRcell-${id}
    Wait For Next Full Pm Interval
    ${pm_counter_file}=      Get Latest Unpacked Full Pm Counters File
    Verify Last Counters In File
    ...     M55310C01001    0     DL_RLC_VOL_TX_L_QOS_GRP_01_5QI_1
    ...     M55310C01002    0     DL_RLC_VOL_TX_L_QOS_GRP_02_5QI_2
    ...     M55310C01003    0     DL_RLC_VOL_TX_L_QOS_GRP_03_5QI_3
    ...     M55310C01004    0     DL_RLC_VOL_TX_L_QOS_GRP_04_5QI_4
    ...     M55310C01005    0     DL_RLC_VOL_TX_L_QOS_GRP_05_5QI_5
    ...     M55310C01006    0     DL_RLC_VOL_TX_L_QOS_GRP_06_5QI_6
    ...     M55310C01007    0      DL_RLC_VOL_TX_L_QOS_GRP_07_5QI_7
    ...     M55310C01008    0      DL_RLC_VOL_TX_L_QOS_GRP_08_5QI_8
    ...     M55310C01009    0      DL_RLC_VOL_TX_L_QOS_GRP_09_5QI_9
    ...     M55310C01010    0     DL_RLC_VOL_TX_L_QOS_GRP_10_5QI_71
    ...     M55310C01011    0     DL_RLC_VOL_TX_L_QOS_GRP_11_5QI_72
    ...     M55310C01012    0     DL_RLC_VOL_TX_L_QOS_GRP_12_5QI_76
    ...     M55310C03001    0     UL_RLC_VOL_RX_L_QOS_GRP_01_5QI_1
    ...     M55310C03002    0     UL_RLC_VOL_RX_L_QOS_GRP_02_5QI_2
    ...     M55310C03003    0     UL_RLC_VOL_RX_L_QOS_GRP_03_5QI_3
    ...     M55310C03004    0     UL_RLC_VOL_RX_L_QOS_GRP_04_5QI_4
    ...     M55310C03005    0     UL_RLC_VOL_RX_L_QOS_GRP_05_5QI_5
    ...     M55310C03006    0     UL_RLC_VOL_RX_L_QOS_GRP_06_5QI_6
    ...     M55310C03007    0      UL_RLC_VOL_RX_L_QOS_GRP_07_5QI_7
    ...     M55310C03008    0      UL_RLC_VOL_RX_L_QOS_GRP_08_5QI_8
    ...     M55310C03009    0      UL_RLC_VOL_RX_L_QOS_GRP_09_5QI_9
    ...     M55310C03010    0     UL_RLC_VOL_RX_L_QOS_GRP_10_5QI_71
    ...     M55310C03011    0     UL_RLC_VOL_RX_L_QOS_GRP_11_5QI_72
    ...     M55310C03012    0     UL_RLC_VOL_RX_L_QOS_GRP_12_5QI_76
    ...     M55125C05505    0    NNGCC_PDU_SES_STP_REQ_EC_RECD_emergency
    ...     M55125C05506    0    NNGCC_PDU_SES_STP_RESP_EC_SENT
    ...     M55125C05509    0     NNGCC_PDUSESMODREQ_EC_RECD
    ...     M55125C05510    0     NNGCC_PDUSESMODRSP_SUC_EC_SENT
    ...     local_moid=MRBTS-1/NRBTS-1/NRCELL-${id}
    ...     file_path=${pm_counter_file}

Update GNB R&D Parameter
   [Arguments]   ${LOG_PATH}   ${r&d_parameter}
   common_deal_config_file.Get GNB Swconfig File     ${LOG_PATH}
   Modify Swconfig File Parameters    ${LOG_PATH}/swconfig_gnb.txt    ${r&d_parameter}
   common_deal_config_file.Send Swconfig for GNB    ${LOG_PATH}/swconfig_gnb.txt