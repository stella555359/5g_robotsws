*** Settings ***
Resource       CB008294_variables.robot
Library        ute_ue
Library        taf.sbts.oam.coam.admin    WITH NAME    coam
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/qualcomm_cpe.robot
Library        ./../../../../resources/RAN_PZ_HAZ_34/lines/MMW_SG1/lib/online_nidd_process.py    WITH NAME    nidd_modify
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG1/CA/Resources/CA_keywords.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/siso_common_case/step_keywords/5G/operate_cell_and_check.robot
Library        String
Library        DateTime
Library        XML    True
Library        Collections
Library        OperatingSystem
Resource       testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/common/taf_coam.robot
Library        testsuite/Hangzhou/OAM/RAN_PZ_HAZ_34/libraries/global_vars.py
Variables      testsuite/Hangzhou/RRM/RAN_PZ_HAZ_34/CB008294/TestData/nidd_8294_common.py
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/CI_Operations/CI_interface.robot
Resource       testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
Library        taf.transport.ssh    WITH NAME    ssh


*** Keywords ***
8294 suite preparation
    [Documentation]    author: Wang Yixiang
    set suite variable    ${PARAMS_TO_DELETE}    ${DELETE_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_ADD}       ${ADD_SCF_DEFAULT}
    set suite variable    ${PARAMS_TO_MODIFY}    ${MODIFY_SCF_8294_DEFAULT}
    Suite common setup preparation     NSA_SA=SA
    coam_gnb_classical.connect to gnb coam via ssl
    ${CELL_MAPPING}    coam_gnb_classical.get_relation_mapping_between_cell_index_and_other_ids
    ${all_cell_ids}    Get dictionary keys    ${CELL_MAPPING}
    Set suite variable    ${CELL_MAPPING}
    Set suite variable    ${all_cell_ids}
    Set suite variable   ${CELL_INDEX_PCELL}  ${all_cell_ids}[0]
    Set suite variable    ${pcell_nrCellIdentity}    ${CELL_MAPPING}[${CELL_INDEX_PCELL}][nrCellIdentity]
    import variables   ${CURDIR}/../TestData/nidd_8294_params.py

8294 case teardown
    [Documentation]    author: Wang Yixiang
    [Arguments]  ${ue_index}=${0}    ${attach_result}=${ATTACH_RESULT}
    run keyword and ignore error    Close the iperf process on APPserver CPE
    run keyword and ignore error    Close the iperf process on APPserver    port=${APPSERVER_PORT}
    run keyword and ignore error    Cpe_operation.stop_ul_data_transfer
    ...   hostname=${UE_PC_IP}
    ...   username=${UE_PC_USERNAME}
    ...   password=${UE_PC_PASSWD}
    ...   port=${APPSERVER_PORT}
    ...   ue_sn=${UE_SN}
    run keyword and ignore error    power_ue.UE detach    ue_type=${UE_TYPE}    ue_index=${ue_index}
    run keyword if    ${attach_result}==${False}    run keyword and ignore error    Restart the UE Proxy
    run keyword if    ${attach_result}==${False}    sleep    60s
    Teardown the Aasyslog save progress
    coam teardown gnb connections
    Common case teardown

8294 case setup
    [Documentation]    author: Wang Yixiang
    [Arguments]  ${nidd_modify_via_api}=${None}    ${NSA_SA}=SA    ${require_UE}=${True}   ${alias}=AT_BASED_UE
    Common case setup    nidd_modify_via_api=${nidd_modify_via_api}    NSA_SA=${NSA_SA}
    run keyword if   ${require_UE}==${True}   Kill At commnad process
    run keyword if   ${require_UE}==${True}   Require UE with retry    ue_alias=${alias}

Check NO CA in tcpdump log
    [Documentation]    author: Wang Yixiang
    ...      Check NO CA in tcpdump log
    [Arguments]     ${log_path_pcap}
    ${filter}    set variable    nr-rrc&&f1ap.procedureCode == 12
    ${pkt_CPE_attach}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
    ${sCellToAddModList}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_CPE_attach}        attribute_name=showname
    ...    xpath=.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellToAddModList
    ${sCellToAddModList_len}    get length    ${sCellToAddModList}
    should be true     ${sCellToAddModList_len}==${0}     msg=sCell should not add if actCarrierAggregationFr2Sa=false

Check DL and UL CA in tcpdump log
    [Documentation]    author: Wang Yixiang
    ...      Check DL and UL CA in tcpdump log
    [Arguments]     ${log_path_pcap}   ${DL_CC}    ${UL_CC}
    ${SCELL_DL_CC}    evaluate    ${DL_CC}-1
    ${SCELL_UL_CC}    evaluate    ${UL_CC}-1
    ${filter}    set variable    nr-rrc&&f1ap.procedureCode == 12
    ${pkt_CPE_attach}    Load pcap file with filter    log_path_pcap=${log_path_pcap}    filter=${filter}
    ${sCellToAddModList}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_CPE_attach}        attribute_name=showname
    ...    xpath=.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellToAddModList
    ${sCellToAddModList_DL}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_CPE_attach}        attribute_name=showname
    ...    xpath=.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellConfigCommon_element//nr-rrc.downlinkConfigCommon_element
    ${sCellToAddModList_UL}    pcap.get_field_value_by_xpath
    ...    pdml_list=${pkt_CPE_attach}        attribute_name=showname
    ...    xpath=.//nr-rrc.rrcReconfiguration_element//..//nr-rrc.sCellConfigCommon_element//nr-rrc.uplinkConfigCommon_element

    ${sCellToAddModList_len}    get length    ${sCellToAddModList}
    ${sCellToAddModList_DL_len}    get length    ${sCellToAddModList_DL}
    ${sCellToAddModList_UL_len}    get length    ${sCellToAddModList_UL}

    should be true     ${sCellToAddModList_DL_len}==${SCELL_DL_CC}     msg=${DL_CC}CC DL CA should add if actCarrierAggregationFr2Sa=true
    should be true     ${sCellToAddModList_UL_len}==${SCELL_UL_CC}     msg=${UL_CC}CC UL CA should add if actCarrierAggregationFr2Sa=true

Modify NIDD via rest api and wait onair
    [Documentation]   author: Wang Yixiang
    ...    Modify Nidd parameter and wait onair
    [Arguments]     ${parameters}    ${timeout_restapi}=3 min    ${connection}=GNB_OAM
    coam_gnb_classical.COAM Update several parameters via rest api
    ...    parameters_to_update_via_api=${parameters}    timeout=${timeout_restapi}    connection=${connection}
    Wait cell onair classical cloud

Start UL data transfer and verify Scell is activated CPE
    [Documentation]   author: Wang Yixiang
    [Arguments]    ${dl_tput}=${DL_TPUT_COMMON}    ${ul_tput}=${UL_TPUT_COMMON}    ${sleep_time}=20s
    ...    ${duration}=600s
    Prepare and start aasyslog
    Start data transfer based on direction for CPE    direction=ul    dl_tput=${dl_tput}     ul_tput=${ul_tput}    tput_duration=${duration}
    sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should be true    ${is_scell_activated}
    [Teardown]    Teardown the Aasyslog save progress

Start DL data transfer and verify Scell is activated CPE
    [Documentation]   author: Wang Yixiang
    [Arguments]    ${dl_tput}=${DL_TPUT_COMMON}    ${ul_tput}=${UL_TPUT_COMMON}    ${sleep_time}=20s
    ...    ${duration}=600s
    Prepare and start aasyslog
    Start data transfer based on direction for CPE    direction=dl    dl_tput=${dl_tput}     ul_tput=${ul_tput}    tput_duration=${duration}
    sleep    ${sleep_time}    reason=Wait for traffic to be stable.
    ${is_scell_activated}    Run keyword and return status    Stop aasyslog to check scell activation
    should be true    ${is_scell_activated}
    [Teardown]    Teardown the Aasyslog save progress

Check PM counter A_PMO1_001
    [Documentation]    author: Wang Yixiang
    ...        ...    1. Following counter/counters is/are updated on PCell as per the description in NIDD.
    ...    a. PMI ticket gets updated for the following counters
    ...    • RRC_RECONF_ADD7DLSCELL_ATT_SA:M55118C00003
    ...    • RRC_RECONF_ADD7DLSCELL_SUCC_SA:M55118C00006
    ...    • RRC_RECONF_ADD3ULSCELL_ATT_SA:M55118C00008
    ...    • RRC_RECONF_ADD3ULSCELL_SUCC_SA:M55118C00010
    ...    • UE_PCELL_7_CONF_SCELL_DL_SA:M55118C00015
    ...    • UE_PCELL_3_CONF_SCELL_UL_SA:M55118C00012
    ...    • GNB_DU_SCELL_7_ADMI_REQ_SA:M55139C03005
    ...    • GNB_DU_SCELL_7_ADMI_SUCC_SA:M55139C03008
    ...    • GNB_SCELL_7_ADMI_REQ_SA:M55138C03506
    ...    • GNB_SCELL_7_ADMI_SUCC_SA:M55138C03509
    ...    b. PMI ticket not updated for the following counters, todo(this counter not display)
    ...    • MAX_UE_PCEL_3_CONF_SCEL_UL_SA:M55156C00022
    ...    • MAX_UE_PCEL_7_CONF_SCEL_DL_SA:M55156C00029
    ...    2. Following counter/counters is/are updated on SCell(s) as per the description in NIDD.
    ...    UE_SCELL_3_CONF_SCELL_UL_SA (Updated only in UL SCells):M55118C00017
    ...    UE_SCELL_7_CONF_SCELL_DL_SA:M55118C00020

    [Arguments]       ${starting_log_timestamp}
    ${pm_files_local_path}    Wait for PM file generated and download    starting_log_timestamp=${starting_log_timestamp}
    ${cell_check_list}    create list     ${CELL_INDEX_1TH}   ${CELL_INDEX_2TH}   ${CELL_INDEX_3TH}
    ...    ${CELL_INDEX_4TH}    ${CELL_INDEX_5TH}   ${CELL_INDEX_6TH}   ${CELL_INDEX_7TH}   ${CELL_INDEX_8TH}

    ${list_measurement_ids}    create list    M55118C00003    M55118C00006   M55118C00008   M55118C00010
    ...   M55118C00015    M55118C00012   M55139C03005    M55139C03008   M55138C03506   M55138C03509
    ...   M55156C00022    M55156C00029
    ...   M55118C00017    M55118C00020
    ${dict_meas_val}    counter.get_total_cell_counter_from_multiple_files    list_file_path=${pm_files_local_path}
    ...      list_cell=${cell_check_list}          list_measurement_ids=${list_measurement_ids}

    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00003']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00006']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00008']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00010']}   1
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00015']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00012']}   0
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55139C03005']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55139C03008']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55138C03506']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55138C03509']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55156C00022']}   1
    run keyword and continue on failure     should be equal as strings    ${dict_meas_val['${CELL_INDEX_1TH}']['M55156C00029']}   1
    run keyword and continue on failure     should be equal as strings        ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00017']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_2TH}']['M55118C00017']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_3TH}']['M55118C00017']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_4TH}']['M55118C00017']}   0
    run keyword and continue on failure     should be equal as strings        ${dict_meas_val['${CELL_INDEX_1TH}']['M55118C00020']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_2TH}']['M55118C00020']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_3TH}']['M55118C00020']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_4TH}']['M55118C00020']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_5TH}']['M55118C00020']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_6TH}']['M55118C00020']}   0
    run keyword and continue on failure     should not be equal as strings    ${dict_meas_val['${CELL_INDEX_7TH}']['M55118C00020']}   0


