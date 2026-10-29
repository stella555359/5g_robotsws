*** Settings ***
Force Tags    CLOUD_5GC_dRNIC_1vDU_P_AP_LO_SWFH    CONFIGURED  CRT  RAN_5G_TDD
...           RAN_5G    SBTS00    PY36
...           NoResUsage

Documentation    :copyright: Nokia
...              :authors: Cristinel Sava
...              :maintainer: Cristinel Sava

Resource      ../../../resourcesKRK/krk3_common/main_vran.robot
Resource      ../../../resourcesKRK/krk3_common/aic/aic_common_resources.robot
Resource     5GC00638_D_keywords.robot
Library      ta5g_tshark
Library      ta5g_ue_mobility
Library      ute_tshark
Library       ute_reporting_portal
Library      638_D_Keywords.py
Library      ta5g_pm_counters

Suite Setup       Testline Setup
Suite Teardown    Testline Teardown
Test Teardown     Test Case Teardown     pod_logs=yes    oam_logs=yes


*** Variables ***
@{IP_ADDR_EXAMPLE}    eth3:10.0.12.100/24    eth3:10.0.11.100/24
&{CONFIG_638_D}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_638_D}   delta_vdu=${DELTA_VDU_5}
${DELTA_VCU_638_D}     ${CURDIR}/configs/CU_DELTA_638_D.xml
&{CONFIG_PM_5min}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_5}   delta_vdu=${DELTA_VDU_5}
${DELTA_VCU_5}     ${CURDIR}/configs/CU_Delta_5min.xml
${DELTA_VDU_5}     ${CURDIR}/configs/DU_Delta_5min.xml
${DELTA_VCU_LK_CELL1}     ${CURDIR}/configs/CU_Delta_lock_cell1.xml
${DELTA_DCU_LK_CELL1}     ${CURDIR}/configs/DU_Delta_lock_cell1.xml
&{CONFIG_LK_CELL1}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_LK_CELL1}   delta_vdu=${DELTA_DCU_LK_CELL1}
${DELTA_VCU_LK_CELL2}     ${CURDIR}/configs/CU_Delta_lock_cell2.xml
${DELTA_DCU_LK_CELL2}     ${CURDIR}/configs/DU_Delta_lock_cell2.xml
&{CONFIG_LK_CELL2}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_LK_CELL2}   delta_vdu=${DELTA_DCU_LK_CELL2}
${DELTA_VCU_ULK_CELL1}     ${CURDIR}/configs/CU_Delta_unlock_cell1.xml
${DELTA_DCU_ULK_CELL1}     ${CURDIR}/configs/DU_Delta_unlock_cell1.xml
&{CONFIG_ULK_CELL1}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_ULK_CELL1}  delta_vdu=${DELTA_DCU_uLK_CELL1}
&{CONFIG_ULK_CELL2}     ip_addr=${IP_ADDR_EXAMPLE}   delta_vcu=${DELTA_VCU_ULK_CELL2}  delta_vdu=${DELTA_DCU_uLK_CELL2}
${DELTA_VCU_uLK_CELL2}     ${CURDIR}/configs/CU_Delta_unlock_cell2.xml
${DELTA_DCU_ULK_CELL2}     ${CURDIR}/configs/DU_Delta_unlock_cell2.xml
&{CONFIG_ULK_CELL1}     ip_addr=${IP_ADDR_EXAMPLE}  delta_vcu=${DELTA_VCU_ULK_CELL1}  delta_vdu=${DELTA_DCU_ULK_CELL1}
${DELTA_VCU_REVERT}     ${CURDIR}/configs/Delta_VCU_revert.xml
${DELTA_DCU_REVERT}     ${CURDIR}/configs/Delta_VDU_revert.xml
&{CONFIG_REVERT}     ip_addr=${IP_ADDR_EXAMPLE}  delta_vcu=${DELTA_VCU_REVERT}  delta_vdu=${DELTA_DCU_REVERT}

${NGAP_RAN_CONFIGURATION_UPDATE_ACKNOWLEDGE}    ngap.RANConfigurationUpdateAcknowledge_element
${NGAP_RAN_CONFIGURATION_UPDATE}                ngap.RANConfigurationUpdate_element
${NGAP_RAN_CONFIGURATION_UPDATE_2}                ${NGAP_RAN_CONFIGURATION_UPDATE} && ngap.protocolIEs == 1

${NUBMER_OF_RAN_CONF_MESSAGES_SENT}=    6
${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}=  5
${ngSetupRespTmr}=    1
@{NG_CU_RAN_CONFIG_UPD_NO_RSP}           M55119C00024

@{PM_OBJECTS_LIST}           NNGCB
${pcap_file_path}    /home/ute/robotws/results/anypcap.pcap

*** Test Cases ***
5G000638_D_TC4_RAN_Configuration_Update_Failure
   [Documentation]    This test case describes RAN Configuration Update Failure
    ...                5G_RAN_USR_RRM_1245    config=&{CONFIG_PM_5min}
    ...                Test case checks:        config=&{CONFIG_638_D}     reach_on_air=without_x2_link
    ...                - if time of sending Ran Configuration Update messages is correct
    ...                - if counter NG_CU_RAN_CONFIG_UPD_NO_RSP is incremented properly
    [Setup]    Run Keywords     Log to console      Start test setup
    ...     AND    Test Case Setup    config=&{CONFIG_PM_5min}   reboot_after_config=no
    ...     AND    Test Case Setup    reach_on_air=yes    config=&{CONFIG_638_D}   reboot_after_config=no
    sleep    10s
    start tcpdump on remote interface aic
    ...   alias=default_s1_x2
    ...   log_filename_prefix=anypcap
    ...   log_dirpath=${OUTPUT DIR}
    sleep    5s
    log to console    amf_config_update id=1 amfi=1:1:1,1:2:2
    Execute egate command    cmd=amf_config_update id=1 amfi=1:1:1,1:2:2
    sleep    5s
    log to console    amf_ran_config_update_param id=1 action=ignore ntimes=indefinite
    Execute egate command    cmd=amf_ran_config_update_param id=1 action=ignore ntimes=indefinite
    log to console    lock cell 1
    Send Custom delta_vCU    config=&{CONFIG_LK_CELL1}
    sleep    10s
    log to console    lock cell 2
    Send Custom delta_vCU    config=&{CONFIG_LK_CELL2}
    sleep    10s
    log to console    unlock cell 1
    Send Custom delta_vCU    config=&{CONFIG_ULK_CELL1}
     sleep    10s
     sleep    ${TIME_OF_SENDING_RAN_CONF_UPD_MESSAGES}     Waiting for Ran_Conf_Update
     Log to console    Get Next vRAN XML PM Counters Files
    ${dirpath}  Set Variable   ${OUTPUT DIR}/Logs/${TEST NAME}/
    Create Directory    ${dirpath}/vcu
    Create Directory    ${dirpath}/vdu
    &{pm_files_dict}    get_next_vran_unpacked_full_pm_counters_files    output_dirpath=${dirpath}     timeout=3600      expected_interval=5
    Log to console    sleep 10s
    Log to console    check counter M55119C00024
    verify last counters in file
    ...  M55119C00024   6       NG_CU_RAN_CONFIG_UPD_NO_RSP
    ...  local_moid=PLMN-PLMN/MRBTS-1/NRBTS-1
    ...  file_path=${pm_files_dict.vcu}
    ...  measurement_type=NNGCB
    Log to console    sleep 10s
     sleep    10s
#    sleep    30s
    log to console    Verify tshark NGAP_RAN_CONFIGURATION_UPDATE_ACKNOWLEDGE
    Verify tshark
    ...     alias=default_s1_x2
    ...     packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE_ACKNOWLEDGE}
    ...     pass_criteria= >=0
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    Log to console    sleep 10s
    sleep    10s
    log to console    Verify tshark NGAP_RAN_CONFIGURATION_UPDATE
    Verify tshark
    ...     alias=default_s1_x2
    ...     packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE}
    ...     pass_criteria=${NUBMER_OF_RAN_CONF_MESSAGES_SENT}
    ...     pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    Log to console    sleep 10s
    sleep    10s
    log to console    Verify Timestamps Related NG Setup Resp Tmr
    Verify Timestamps Related NG Setup Resp Tmr
    log to console    unlock cell 2
    Send Custom delta_vCU    config=&{CONFIG_ULK_CELL2}
    Log to console      stop tcpdump on remote interface
    stop tcpdump on remote interface
    Report pm counter    M55119C00024  6           Passed
    Execute Egate Command    cmd=reset
    Log to console    Egate reseted
    Run     sudo killall edaemon egate
    Log to console    Egate killed
    sleep    5s


*** Keywords ***

Verify Timestamps Related NG Setup Resp Tmr
    ${list_of_timestamps}=   Get List of Timestamps From Tshark Messages   alias=default_s1_x2
    ...                                                          output_pdml_filepath=${OUTPUT_DIR}/converted_pcap.pdml
    ...                                                          packet_filter=${NGAP_RAN_CONFIGURATION_UPDATE_2}
    ...                                                          pcap_file_path=${OUTPUT_DIR}/anypcap.pcap
    Check If All Time Differences Are Equal NG Setup Resp Tmr    times_table=${list_of_timestamps}    ng_setup_resp_tmr=${ngSetupRespTmr}

Set Cell Lock vDU
    [Arguments]    ${cell_id}
    ${conn_du}    vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  vdu.lock_cells  cell_id_list=${cell_id}    vdu_connection=${conn_du}
    [Teardown]    vdu.disconnect   vdu_connection=${conn_du}

Set Cell UnLock vDU
    ${conn_du}    vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  vdu.unlock_cells  cell_id_list=${cell_id}   vdu_connection=${conn_du}
    [Teardown]    vdu.disconnect   vdu_connection=${conn_du}

Set Cell Block vDU
    [Arguments]    ${cell_id}
    ${conn_du}    vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  vdu.block_cell  cell_id=${cell_id}    vdu_connection=${conn_du}
    [Teardown]    vdu.disconnect   vdu_connection=${conn_du}

Set Cell UnBlock vDU
    [Arguments]    ${cell_id}
    ${conn_du}    vdu.connect_to   host=${OAM_DU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  vdu.unblock_cell  cell_id=${cell_id}   vdu_connection=${conn_du}
    [Teardown]    vdu.disconnect   vdu_connection=${conn_du}

Set Cell Block vCU
    [Arguments]    ${cell_ids}
    ${conn_du}    cu.connect_to   host=${OAM_CU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  cu.block_cell  cell_id=${cell_id}    vdu_connection=${conn_cu}
    [Teardown]    vcu.disconnect   vdu_connection=${conn_cu}

Set Cell UnBlock vCU
    [Arguments]    ${cell_ids}
    ${conn_du}    vcu.connect_to   host=${OAM_CU}[host]   port=443   username=Nemuadmin   password=Nokia@123   secure=${True}
    ${cell_info}=  vcu.unblock_cell  cell_id=${cell_id}   vdu_connection=${conn_cu}
    [Teardown]    vcu.disconnect   vdu_connection=${conn_cu}
