*** Settings ***
Documentation
...    The purpose of this test case is to verify if single UE attach procedure with blind SCell addition is performed successfully and
...    DSS allocation ratio of DL slots to NR, DL, UL throughput reaches expected levels.

Metadata    branch    ${ENB_BRANCH}
Metadata    build    ${ENB_BUILD}
Metadata    topology    CLOUD_5G_I_BOO_AP_LOO
Metadata    variant    SANSA_FS_ECPRI_CMWV_FDD+TDD_GMC

Force Tags    OPTION_RELATED_ARTIFACTS_5G    TOOLS_PROFILE_AP_WTS    PY310    RF50

Variables    ${RESOURCES}/dist_names.py

Resource    ../../resources/main_resources.robot

# -- setup/teardown --
Suite Setup    RUN KEYWORDS    Prepare Testing Environment
...    AND    Start Mandatory Logging
...    AND    Backup BTS Configuration Files
...    AND    Get Active BTS Alarms

Suite Teardown  RUN KEYWORDS
...    Get Active BTS Alarms    AND
...    Collect Mandatory Logs    AND
...    Cleanup Testing Environment

*** Variables ***
${RESOURCES}    ${CURDIR}/CNI67972_DSS_CA.resources
${LUA}    ${RESOURCES}/epc_sim.lua
${SCFC}    ${RESOURCES}/scfc.xml

${DATA_TRAFFIC_TIME_MINUTES}    ${10}
${DATA_TRAFFIC_VOLUME_MBPS_DL}    ${165}
${DATA_TRAFFIC_VOLUME_MBPS_UL}    ${50}
${UE_EXPECTED_TPUT_MBPS_DL}    ${475}
${UE_EXPECTED_TPUT_MBPS_UL}    ${45}
${counter_ids}    M55316C05001,M55316C09000
${M55316C05001_VALUE}    ${1}
${M55316C09000_VALUE}    ${1}
${NUMBER_OF_MEASUREMENTS}    ${10}
${NUMBER_OF_RMODS}    ${4}

*** Test Cases ***
CNI67972_Single_UE_Call_DSS_phase_3_with_blind_SCell_addition
    [Documentation]
    ...    This test case is designed to verify CNI67972 DSS & CA. Sub features 5GC001745-C and 5GC001390 were selected for this purpose.
    [Setup]    [PRE]CNI67972_Single_UE_Call_DSS_phase_3_with_blind_SCell_addition
    [Teardown]    [POST]CNI67972_Single_UE_Call_DSS_phase_3_with_blind_SCell_addition
    Attach and setup PDU for UE
    Start DL and UL traffic for UE
    Verify if SCell was added correctly
    Perform data traffic for UE
    Verify DSS Allocation ratio of DL slots assigned to NR
    Verify DL and UL throughput for UE using PM counters

*** Keywords ***
[PRE]CNI67972_Single_UE_Call_DSS_phase_3_with_blind_SCell_addition
    Add flag to swconfig    0x340000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Add Flag To Swconfig    0x9D0000    5    WRITE_PM_COUNTERS_EVERY_MINUTE
    Configure Required IP Addresses
    Perform Commissioning    scfc_path=${SCFC}
    Check if BTS is correctly configured    ${NUMBER_OF_RMODS}
    Start WTS    ${LUA}    check_version=False
    Setup XP
    Check if BTS is OnAir
    Setup DSS on LTE
    Establish DSS cell partnership
    Start DSS resource allocation

[POST]CNI67972_Single_UE_Call_DSS_phase_3_with_blind_SCell_addition
    Report miscellaneous KPIs
    Detach UE
    Stop WTS

# -- test steps --
Attach and setup PDU for UE
    [Tags]    DESIGNSTEP
    SA 5G Attach UE"1"
    SA Set Traffic Type For PDU"1" UE"1"
    SA Setup Primary PDU Session For PDU"1" UE"1" GW"1" NWSLICE"1"

Verify if SCell was added correctly
     [Tags]    DESIGNSTEP
     Get PM counters
     RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55316C05001 counter
     RUN KEYWORD AND CONTINUE ON FAILURE    Verify M55316C09000 counter

Start DL and UL traffic for UE
    [Tags]    DESIGNSTEP
    SA Start Traffic In SA Mode    pdu=1    ue=1    qfi=1    dir=dl    mbps=${DATA_TRAFFIC_VOLUME_MBPS_DL}    trf_id=1
    SA Start Traffic In SA Mode    pdu=1    ue=1    qfi=1    dir=dl    mbps=${DATA_TRAFFIC_VOLUME_MBPS_DL}    trf_id=2
    SA Start Traffic In SA Mode    pdu=1    ue=1    qfi=1    dir=dl    mbps=${DATA_TRAFFIC_VOLUME_MBPS_DL}    trf_id=3
    SA Verify If Throughput Is Started    ue=1    pdu=1    qfi=1    dir=dl
    SA Start Traffic In SA Mode    pdu=1    ue=1    qfi=1    dir=ul    mbps=${DATA_TRAFFIC_VOLUME_MBPS_UL}
    SA Verify If Throughput Is Started    ue=1    pdu=1    qfi=1    dir=ul

Verify DL and UL throughput for UE using PM counters
    [Tags]    DESIGNSTEP
    Verify Throughput Using PM Counter    dir=dl
    Verify Throughput Using PM Counter    dir=ul

# -- internals --
Setup XP
    ute_wtssim.execute_egate_command
    ...    cmd=enb_xp_param id=1 ignore_xp=off xp_listening_socket=on
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_xp_param id=1 xp_peers=2
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=enb_xp_link_up enb=1 target=2
    ...    pass_regexp=XpAP Link with GNB-2.*is up|Xp Link is already active
    ...    timeout=5min

Setup DSS on LTE
    ute_wtssim.execute_egate_command
    ...    cmd=enb_dss_param id=1 feature_flag=on message_sets=DMS3
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_cell_param enb=1 id=1 lte_nr_dss_mode=DSS_PHASE_3 antenna_ports_num=2
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_cell_dss_feature enb=1 id=1 nr_dl_peak_rate_increase=on
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_cell_dss_feature enb=1 id=1 superfast_allocation=off
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_cell_dss_param enb=1 id=1 dl_resource_sharing_algo=dl_prb_load_based
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=enb_dss_configure_partnership enb=1 cell=1 dss_peer=2:1
    ...    pass_regexp=CRM Partnership Creation
    ...    timeout=1min

Establish DSS cell partnership
    ${cell_resource_reservation_cmd}=    Catenate
    ...    enb_crm_cell_resource_reservation enb=1 cell=1 tgt_enb=2 tgt_cell=1 assigned_dl_minimum_share_to_nr=30
    ...    assigned_dl_maximum_share_to_nr=95 assigned_dl_minimum_share_to_lte=15 assigned_dl_maximum_share_to_lte=75
    ...    assigned_ul_minimum_share_to_nr=20 assigned_ul_maximum_share_to_nr=70
    ute_wtssim.execute_egate_command
    ...    cmd=${cell_resource_reservation_cmd}
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_crm_param id=1 ul_qos_load_meas_timer=200 dl_qos_load_meas_timer=200
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=sim_trace enb=1 protocol=xp
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=enb_dss_establish_partnership enb=1 cell=1 tgt_enb=2 tgt_cell=1
    ...    pass_regexp=EN DSS DL Cell Resource Area Coordination success on remote NE.*Subcarrier Resource Coordination success on remote NE
    ...    timeout=5min

Start DSS resource allocation
    ute_wtssim.execute_egate_command
    ...    cmd=enb_dss_cell_resource_reservation_dl enb=1 cell=1 reset
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_dss_cell_resource_reservation_ul enb=1 cell=1 reset
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_dss_dl_resource_cell_reservation cell=1 enb=1 prb_area_reservation_list=0,0,0-10-none+0,0,5-10-none+0,0,9-10-none
    ...    fail_regexp=Error:
    ${dl_resource_cell_reservation_cmd}=    Catenate
    ...    enb_dss_dl_resource_cell_reservation cell=1 enb=1
    ...    reserved_fixed_normal_subframes=0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000-0000000000
    ute_wtssim.execute_egate_command
    ...    cmd=${dl_resource_cell_reservation_cmd}
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command
    ...    cmd=enb_dss_dl_resource_cell_reservation cell=1 enb=1 min_lte_nr_dss_ratio=30 max_lte_nr_dss_ratio=95
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=enb_dss_cell_resource_coordination enb=1 cell=1 tgt_enb=2 tgt_cell=1 dir=DL
    ...    pass_regex=EN DSS DL Cell Resource Area Coordination: both NEs synchronized
    ...    timeout=1min
    ute_wtssim.execute_egate_command
    ...    cmd=enb_dss_ul_resource_cell_reservation cell=1 enb=1 minimum_prb_share=30 maximum_prb_share=70
    ...    fail_regexp=Error:
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=enb_dss_cell_resource_coordination enb=1 cell=1 tgt_enb=2 tgt_cell=1 dir=UL
    ...    pass_regexp=EN DSS UL Cell Subcarrier Resource Coordination: both NEs synchronized
    ...    timeout=1min
    ute_wtssim.execute_egate_command
    ...    cmd=enb_crm_status enb=1 cell=1
    ...    fail_regexp=Error:
    ${dl_resource_allocation_cmd}=    Catenate    SEPARATOR=
    ...    enb_dss_resource_allocation enb=1 cell=1 tgt_enb=2 tgt_cell=1 dir=DL allocation_start_time=immediate dl_allocated_normal
    ...    _subframes=1011111001-1111111111-1011111001-1111111111-1011111001-1111111111-1011111001-1111111111 dl_prb_area_allocation_list=
    ...    0:0,52+1:0,52+2:0,52+3:0,52+4:0,52+5:0,52+6:0,52+7:0,52+8:0,52+9:0,52+10:0,52+11:0,52+12:0,52+13:0,52+14:0,52+15:0,52+16:0,52+17:0,52
    ...    +18:0,52+19:0,52+20:0,52+21:0,52+22:0,52+23:0,52+24:0,52+25:0,52+26:0,52+27:0,52+28:0,52+29:0,52+30:0,52+31:0,52+32:0,52+33:0,52+34:
    ...    0,52+35:0,52+36:0,52+37:0,52+38:0,52+39:0,52+40:0,52+41:0,52+42:0,52+43:0,52+44:0,52+45:0,52+46:0,52+47:0,52+48:0,52+49:0,52+50:0,52
    ...    +51:0,52+52:0,52+53:0,52+54:0,52+55:0,52+56:0,52+57:0,52+58:0,52+59:0,52+60:0,52+61:0,52+62:0,52+63:0,52+64:0,52+65:0,52+66:0,52+67:
    ...    0,52+68:0,52+69:0,52+70:0,52+71:0,52+72:0,52+73:0,52+74:0,52+75:0,52+76:0,52+77:0,52+78:0,52+79:0,52
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${dl_resource_allocation_cmd}
    ...    pass_regexp=DSS DL Resource Area Allocation Response SequenceNumber=0
    ...    timeout=1min
    ${ul_resource_allocation}=    Catenate
    ...    enb_dss_resource_allocation enb=1 cell=1 tgt_enb=2 tgt_cell=1 dir=UL allocation_start_time=immediate
    ...    ul_allocated_prb_list=0,3|5,35|49,3
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=${ul_resource_allocation}
    ...    pass_regexp=Received EN DSS UL Subcarrier Resource Allocation Response SequenceNumber=0
    ...    timeout=1min

Get PM counters
     SLEEP    180    reason=Wait for generating at least one PM counter
     ${connection}=    Set Variable    get_pm_counters
     ${log_path}=    Prepare Logs Directory Path    admin_logs/${connection}
     admin.connect_to    bts_host=${__LOCAL_BTS_IP__}    admin_api_log_dir=${log_path}    name=${connection}
     ${counters_info}=    admin.get_pm_counters    counter_ids=${counter_ids}    connection=${connection}
     SET SUITE VARIABLE    ${COUNTERS_INFO}    ${counters_info}

Verify M55316C05001 counter
     ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55316C05001_PATH}    ${NUMBER_OF_MEASUREMENTS}
     ${error_msg}=    Catenate
     ...    The number of PCell UEs with 1 activated Scell in DL didn't meet expected amount.
     ...    Was: "${actual_value}", expected: "${M55316C05001_VALUE}".
     SHOULD BE TRUE    ${actual_value} >= ${M55316C05001_VALUE}
     ...    msg=${error_msg}

Verify M55316C09000 counter
     ${actual_value}=    pm_counter.get_sum_pm_counter_value    ${COUNTERS_INFO}    ${M55316C09000_PATH}    ${NUMBER_OF_MEASUREMENTS}
     ${error_msg}=    Catenate
     ...    The number of Scell activations didn't meet expected amount.
     ...    Was: "${actual_value}", expected: "${M55316C09000_VALUE}".
     SHOULD BE TRUE    ${actual_value} == ${M55316C09000_VALUE}
     ...    msg=${error_msg}

Perform data traffic for UE
    [Tags]    DESIGNSTEP
    SLEEP    10 min    reason=Perform data traffic for established time range

Verify DSS Allocation ratio of DL slots assigned to NR
    [Tags]    DESIGNSTEP
    SLEEP    120    reason=Wait for generating at least one PM counter
    ${nr_dl_slots_values}=    Get PM Counter "${EN_DSS_DL_NR_SLOTS_PATH}" Measurements Untill Success
    ${all_avlbl_dl_slots_values}=    Get PM Counter "${EN_DSS_NBR_AVLBL_DL_SLOTS_PATH}" Measurements Untill Success
    ${sum_of_nr_dl_slots_values}=    pm_counter.get_sum_pm_counter_value    ${nr_dl_slots_values}    ${EN_DSS_DL_NR_SLOTS_PATH}
    ...    ${NUMBER_OF_MEASUREMENTS}
    ${sum_of_all_avlbl_dl_slots_values}=    pm_counter.get_sum_pm_counter_value    ${all_avlbl_dl_slots_values}    ${EN_DSS_NBR_AVLBL_DL_SLOTS_PATH}
    ...    ${NUMBER_OF_MEASUREMENTS}
    ${DSS_AVG_R_DL_SLOT_ASSIGN_NR}=    EVALUATE    100 * (${sum_of_nr_dl_slots_values} / ${sum_of_all_avlbl_dl_slots_values})
    SHOULD BE TRUE    ${DSS_AVG_R_DL_SLOT_ASSIGN_NR} == 95
    ...    msg=DSS Allocation ratio of DL slots assigned to NR didn't meet expected amount. Was: "${DSS_AVG_R_DL_SLOT_ASSIGN_NR}%", expected: "95%".

Verify Throughput Using PM Counter
    [Arguments]    ${dir}
    ${EXPECTED_TPUT_MBPS}    SET VARIABLE IF    '${dir}' == 'dl'
    ...    ${UE_EXPECTED_TPUT_MBPS_DL}
    ...    ${UE_EXPECTED_TPUT_MBPS_UL}
    ${PM_COUNTER}=    SET VARIABLE IF    '${dir}' == 'dl'
    ...    ${THROUGHPUT_DL_PM_COUNTER_PATH}
    ...    ${THROUGHPUT_UL_PM_COUNTER_PATH}
    ${avg_tput_kilobytes}    Get Average Value Of PM Counter    ${PM_COUNTER}    ${NUMBER_OF_MEASUREMENTS}
    ${avg_tput_mbps}    EVALUATE    ${avg_tput_kilobytes} * 8 / 1000 / 60
    SET TEST VARIABLE    ${REAL_TPUT_MBPS_PM_COUNTER}    ${avg_tput_mbps}
    SHOULD BE TRUE    ${avg_tput_mbps} >= ${EXPECTED_TPUT_MBPS}
    ...               msg=Throughput less than expected ${EXPECTED_TPUT_MBPS} mbps: ${avg_tput_mbps} mbps
    ute_wtssim.execute_egate_command_and_wait_for_data
    ...    cmd=ue_stats_nr id=1 type=pdsch,pusch scell=0-15
    ...    pass_regexp=.*Mbps
    ...    timeout=5

Detach UE
    SA 5G Detach UE"1"
