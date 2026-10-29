*** Settings ***
Documentation
...   author:        Marcin Wolczynski
...   contact:       marcin.wolczynski@nokia.com
...   Description:   Feature CB013152

Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_8409.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB012439/resources/test_specyfic_keywords_CB012439.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/test_specyfic_keywords_CB013152.robot
Resource     testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009059/resources/test_specific_keywords_9059.robot
Library        taf.ue
Library        taf.rfrl.bts.devices.du.pm_counters.GnbPmCounter   WITH NAME      GnbCounter
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/test_specific_keywords_CB013152.py
Library        testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py



Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB008409/resources/test_specific_keywords_CB008409.py


*** Variables ***
${UE_ALIAS_13152}             UE_13156
${UE_CAPA_13152}              REAL_UE_SA
@{cells_to_be_locked_13152}        1    2   3   5   6   7   8   9
${auto_responder}       +555800903300998
${VC_ALIAS}              callVoNR
${handover_off}         0
${tput}           10 Mbits/sec
${log_path_13152}      t119CrtNew/[1][1.0] CB013152-SR-A_Interworking_with_CB010850/cplane_collector/cplane_collector.pcap
${log_path_bwp}   t119CrtNew/[1]CB013152-SR-A_IWK3_Interworking_with_CB008954/cplane_collector/cplane_collector.pcap
${pucch_resource_id}    8   9
${protocol_f1ap}        f1ap
${filter_of_rrcsetuprequest}    initiatingMessage
${CB013152_blanking}            l1l2Blanking
${protocol_l1l2}        uldata_pucchreceivereql1sw
${protocol_l1l2_prbs}        UlData_puschReceiveReqGrant_t.fakeUe == False
${filter_of_l1l2}      UlData_PucchReceiveReqL1sw_t
${filter_of_l1l2_prbs}  UlData_PuschReceiveReq_t
${l1l2_keys}        startPrb (Uint16)    secondHopPrb (Uint16)
${l1l2_keys_prbs}        startPrb (Uint16)    numOfPrb (Uint16)
${l1l2_keys_cyclic}        initialCyclicShift (Uint8)
${expected_pucch_values}    0   2   76  79
${expected_pucch_values_bwp}    0   1   4   6   51
${expected_pucch_values_cyclic}     0   1   6   3   5   11
${expected_size_of_pusch}   106
@{pucch_format_1_prbs}      0   79
@{pucch_format_2_prbs}      2   76
@{pucch_format_1_prbs_bwp}      0   1
@{pucch_format_2_prbs_bwp}      4   6
${scf_path_bwp}             testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB013152/resources/bwpProfile.xml



*** Keywords ***
[1]CB013152 PRB Blanking
	[Documentation]   This test case is for CB013152 feature with PRB blanking interaction
	AdminUtils.unlock_all_cells
    preparing_for_prb_blanking_13152
    AdminUtils.Lock Cells     ${cells_to_be_locked_13152}
    Start Logging Bip 13152  pcap_filename=${CB013152_blanking}
    Setup cplane tcpdump collector
    Start cplane Logs
    Attach Ue            ${UE_ALIAS_13152}
    Stop Logging Bip 13152
    Data Transfer procedure 12439     ${UE_ALIAS_13152}     ${tput}
    Check data transfer procedure
    Stop cplane logs
    Detach Ue                  ${UE_ALIAS_13152}
    ${expected_cplane_value}    Load Expected Cplane Config
    ${f1ap_list}    check_pcap_13152   pcap_file=${LOG_PATH}/${log_path_13152}  protocol=${protocol_f1ap}
    ...                                filter_pcap=${filter_of_rrcsetuprequest}
    ${l1l2_list}    check_pcap_13152   pcap_file=${LOG_PATH}/l1l2Blanking_L1L2.pcap  protocol=${protocol_l1l2}
    ...                                filter_pcap=${filter_of_l1l2}
    ${f1ap_list}    pucch configuration pcap searcher     ${f1ap_list}  ${pucch_resource_id}
    validation_of_cplane    ${f1ap_list}    ${expected_cplane_value}
    validation_of_bip_log    ${l1l2_list}   ${l1l2_keys}    ${expected_pucch_values}
    #validation_of_bip_log    ${l1l2_list}   ${l1l2_keys_cyclic}    ${expected_pucch_values_cyclic}
    ${data}    validate_pucch     ${l1l2_list}
    checking pucch prbs l1l2     ${data}     ${pucch_format_1_prbs}    ${pucch_format_2_prbs}


[1]CB013152 BWP profile IWK
	[Documentation]   This test case is for CB013152 feature with PRB blanking interaction
    AdminUtils.unlock_all_cells
	Backup SCF    ${OUTPUT DIR}/CB013152basicScf
	upload_scf_from_path    scf_path_robot=${scf_path_bwp}
    AdminUtils.Lock Cells     ${cells_to_be_locked_13152}
    attenuation for bwp 13152
    Setup cplane tcpdump collector
    Start cplane Logs
    Attach Ue            ${UE_ALIAS_13152}
    Start Logging Bip 13152  pcap_filename=${CB013152_blanking}
    Data Transfer procedure 12439     ${UE_ALIAS_13152}     ${tput}
    Stop Logging Bip 13152
    Check data transfer procedure
    Stop cplane logs
    Detach Ue                  ${UE_ALIAS_13152}
    ${expected_cplane_value}    Load Expected Cplane Config for BWP
    ${f1ap_list}    check_pcap_13152   pcap_file=${LOG_PATH}/${log_path_bwp}  protocol=${protocol_f1ap}
    ...                                filter_pcap=${filter_of_rrcsetuprequest}
    ${f1ap_list}    pucch configuration pcap searcher     ${f1ap_list}  ${pucch_resource_id}
    ${l1l2_list}    check_pcap_13152   pcap_file=${LOG_PATH}/l1l2Blanking_L1L2.pcap  protocol=${protocol_l1l2}
    ...                                filter_pcap=${filter_of_l1l2}
    ${l1l2_list_prbs}    check_pcap_13152   pcap_file=${LOG_PATH}/l1l2Blanking_L1L2.pcap  protocol=${protocol_l1l2_prbs}
    ...                                filter_pcap=${filter_of_l1l2_prbs}
    validation_of_cplane    ${f1ap_list}    ${expected_cplane_value}
    validation_of_bip_log    ${l1l2_list}   ${l1l2_keys}    ${expected_pucch_values_bwp}
    ${found_val}    find_all_values_for_keys   ${l1l2_list_prbs}    ${l1l2_keys_prbs}
    check size of pusch   ${found_val}    ${expected_size_of_pusch}
    ${data}    validate_pucch     ${l1l2_list}
    checking pucch prbs l1l2     ${data}     ${pucch_format_1_prbs_bwp}    ${pucch_format_2_prbs_bwp}


Rollback SCF afer test
    upload_scf_from_path    scf_path_robot=${OUTPUT DIR}/CB013152basicScf
