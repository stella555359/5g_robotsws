*** Settings ***
Library    ta5g_enb
Library    ta5g_pm_counters
Library    taf.config.wts
Library    taf.gnb.oam.coam.cu       WITH NAME    admin_cu
Library    taf.gnb.oam.coam.vdu      WITH NAME    admin_du
Library    taf.transport.ssh         WITH NAME    ssh
Library    taf.collectors.core       WITH NAME    core
Library    ute_syslog                WITH NAME    syslog
Library    taf.alias.store           WITH NAME    alias_store
Library    taf.collectors.dcap       WITH NAME    dcap
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_gnb            WITH NAME    common_gnb
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_vcu.vCU        WITH NAME    vcu
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_vdu.vDU        WITH NAME    vdu
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.common_wts            WITH NAME    common_wts
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.vdu_bip               WITH NAME    bip_logs
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.logs_collector_AIC    WITH NAME    logs_collector
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.pm_counters           WITH NAME    pm_counters
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.pm_counters_AIC.CountersDU    WITH NAME    pm_counters_vDU
Library    testsuite.Wroclaw.RRM.VRF_WRO1_T04.L2PS_WRO.resources.Python.pm_counters_AIC.CountersCU    WITH NAME    pm_counters_vCU
Library    common_variables_vran.py
Library    taf.gnb.oam.coam.cu
Library    taf.gnb.oam.coam.vdu
Library    taf.ccs.aashell   WITH NAME    aashell
Resource   vran_delta.robot
Resource   common_keywords.robot
Resource   taf/rfrl/common_resources/robot/libraries_instances.robot
Resource   taf/rfrl/cbts/robot/vdu/vdu_cm.robot
Resource   taf/rfrl/cbts/robot/vcu/vcu_cm.robot

Documentation
...    This file contains general keywords used for testing on Cloud TL.

*** Variables ***
${vCU_admin}                 192.168.100.129
${vDU_admin}                 192.168.255.129
${ICS_SETUP_RESP_SUCCESS}    ngap.procedureCode == 14 && ngap.NGAP_PDU == 1
${scf_path}                  /home/ute/testline_init_results/execution/configs/topology_configs/node_1

*** Keywords ***
Download Scf Files From Vcu and Vdu
    [Arguments]    ${vcu_plan_file}=default_scf_vcu.xml   ${vdu_plan_file}=default_scf_vdu.xml
    ...            ${dir}=${OUTPUT_DIR}/${SUITE_NAME}
    [Documentation]      Download plan files from testline
    ...                  Creation Date: 28.02.2022
    ...                  Modified Date: 25.04.2022
    ...                  Last Modified by: szymon.lange@nokia.com

    vcu.Get Plan File
    ...    file_path=${dir}/${vcu_plan_file}
    vdu.Get Plan File
    ...    file_dir=${dir}
    ...    file_name=${vdu_plan_file}

Common Rinline Test Setup
    Wait for vCU and Radio Online Status
    Enable miNrNGCC
    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    Start Default Logging    output_dirpath=${OUTPUT_DIR}
    Wait For Next PM counters Interval

Common Rinline Test Teardown
    Stop Default Logging    output_dirpath=${OUTPUT_DIR}
    Stop Default Processes And Gather Logs And Compress Logs
    Fix SerialNumberPlanned And ProdCodePlanned And Send Full Commissioning Vdu With Given Scf Filepath
    ...    scfc_filepath=${scf_path}/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD/scfc_du.xml
    ...    output_dirpath=${OUTPUT_DIR}
    Perform Commissioning Vcu Aic
    ...    path_to_plan_file=${scf_path}/SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD/scfc_cu.xml
    Wait for vCU and Radio Online Status

Suite setup
    Wait Until Keyword Succeeds    5min    30s    vcu.Assert Vcu Status
    ...    status=enabled
    Wait Until Keyword Succeeds    5min    30s    vdu.Check Radio Status
    ...    expected_status=on line
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    Download Scf Files From Vcu and Vdu
    Set Scf Object Variables

Test setup SA
    [Arguments]    ${delta_vcu}=None    ${delta_vdu}=None
    Log    \nStart setup    console=True
    Set Suite Variable    ${DELTA_VCU}    ${delta_vcu}
    Set Suite Variable    ${DELTA_VDU}    ${delta_vdu}
    Run Keyword If    '${DELTA_VCU}' != 'None'
    ...    vcu.Update And Activate Delta Plan    ${DELTA_VCU}
    Run Keyword If    '${DELTA_VDU}' != 'None'
    ...    vdu.Upload And Activate Delta File    ${DELTA_VDU}
#    Wait Until Keyword Succeeds    2x    2s    Reset Airphone And Wait Until Tl Ready
#    ${wts_cfg_file_path}=    common_wts.Configure SA UEs In WTS Cfg File
#    ...    num_of_ues=${num_of_ues}
#    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/new_basic_setup_${num_of_ues}UE.cfg
#    ...    ue_caps=${ue_caps}
    Configure SA VM interfaces
    Run  sudo ip addr add 10.0.1.131/24 dev eth3
    Run  sudo ip addr add 10.0.1.132/24 dev eth3
    Run  sudo ip addr add 10.0.1.133/24 dev eth3
    Run  sudo ip addr add 10.0.1.134/24 dev eth3
    Run  sudo ip addr add 10.0.1.135/24 dev eth3
    Run  sudo ip addr add 10.0.1.136/24 dev eth3
    Run  sudo ip addr add 10.0.1.137/24 dev eth3
    Run  sudo ip addr add 10.0.11.100/24 dev eth8
    Run  sudo ip addr add 10.0.12.100/24 dev eth9
    common_wts.Wait For Environment Prepared For Wts Ready State Aic
    ...    wts_config_filename=${wts_cfg_file_path}
    Execute Egate Command   cmd=enb_x2_link_up enb=1 target=2

Test Teardown SA
    Log to console  \nStart Teardown
    logs_collector.Collect Basic Logs Vdu
    ...   local_path=${OUTPUT_DIR}/${SUITE_NAME}
    logs_collector.Collect Basic Logs Vcu
    ...   local_path=${OUTPUT_DIR}/${SUITE_NAME}
    common_wts.Stop WTS And clear
    Download Scf Files From Vcu and Vdu
    ...    vcu_plan_file=scf_vcu_after_test.xml
    ...    vdu_plan_file=scf_vdu_after_test.xml

Reach OnAir AiC
    [Arguments]    ${lua_cfg}
    common_wts.Wait For Environment Prepared For Wts Ready State Aic
    ...    wts_config_filename=${lua_cfg}
    Execute Egate Command   cmd=enb_x2_link_up enb=1 target=2

Configure SA VM interfaces AiC
    Configure SA VM interfaces
    Run  sudo ip addr add 10.0.1.131/24 dev eth3
    Run  sudo ip addr add 10.0.1.132/24 dev eth3
    Run  sudo ip addr add 10.0.1.133/24 dev eth3
    Run  sudo ip addr add 10.0.1.134/24 dev eth3
    Run  sudo ip addr add 10.0.1.135/24 dev eth3
    Run  sudo ip addr add 10.0.1.136/24 dev eth3
    Run  sudo ip addr add 10.0.1.137/24 dev eth3
    Run  sudo ip addr add 10.0.11.100/24 dev eth8
    Run  sudo ip addr add 10.0.12.100/24 dev eth9

Connect To Vdu And Vcu
    Wait Until Keyword Succeeds    5min    30s    admin_cu.Connect to  host=${vCU_admin}
    ...    port=443  username=Nemuadmin  password=Nokia@123  secure=True
    Wait Until Keyword Succeeds    5min    30s    admin_du.Connect to  host=${vDU_admin}
    ...    port=443  username=Nemuadmin  password=Nokia@123  secure=True

Check PM counters vDU
    [Arguments]    ${counter_list}=${PM_COUNTERS_BASIC}
    pm_counters_vDU.get_pm_counters_vdu
    ...    mrbts_id=${MRBTS_ID}
    ...    nrbts_id=${NRBTS_ID}
    ...    counter_list=${counter_list}

Check PM counters vCU
    pm_counters_vCU.get_pm_counters_vcu
    ...    mrbts_id=${MRBTS_ID}
    ...    nrbts_id=${NRBTS_ID}
    ...    counter_list=${VCU_COUNTER_LIST}

Wait Until Next Pm Interval Starts On vDU
    Log To Console    Waiting For Next Interval Start
    pm_counters_vDU.Wait For Next Pm Counter Files To Generate

Wait Until Next Pm Interval Starts On vCU
    Log To Console    Waiting For Next Interval Start
    pm_counters_vCU.Wait For Next Pm Counter Files To Generate

Get Counters File From vDU
    [Arguments]    ${rad_counters}=${False}
    ${counters_after_attach_vdu}=    pm_counters_vDU.Get Latest Pm Counters File From Vdu
    ...                              pm_counters_after_traffic_vdu.xml
    ...                              ${rad_counters}
    [Return]    ${counters_after_attach_vdu}

Get Counters File From vCU
    [Arguments]    ${rad_counters}=${False}
    ${counters_after_attach_vcu}=    pm_counters_vCU.Get Latest Pm Counters File From Vcu
    ...                              pm_counters_after_traffic_vcu.xml
    ...                              ${rad_counters}
    [Return]    ${counters_after_attach_vcu}

Set Scf Object Variables
    ${mrbts_id}  ${nrbts_id}=   vcu.get_mrbts_nrbts_val_from_vcu_plan
    ...    file_path=${OUTPUT_DIR}/${SUITE_NAME}/default_scf_vcu.xml
    Set Suite Variable    ${MRBTS_ID}    ${mrbts_id}
    Set Suite Variable    ${NRBTS_ID}    ${nrbts_id}

#Verify Postconditions
#    [Documentation]      Check PM counters and BIP log
#    ...                  Download BIP log after checking PM counters to prevent going out of meas period
#    ...                  Creation Date: 11.03.2022
#    ...                  Modified Date: 18.05.2022
#    ...                  Last Modified by: szymon.lange@nokia.com
#
#    Log To Console    Postconditions Verification
#    pm_counters_vDU.Check PM counters vDU with transient phase
#    ...    counter_list=${PM_COUNTERS_BASIC}
#    ...    pm_file=${COUNTERS_AFTER_ATTACH}
#    bip_logs.collect_bip_logs_from_vdu
#    ...    files=/var/home/core/l1bipl1.pcap
#    ...    local_path=${OUTPUT_DIR}/${SUITE_NAME}/tcpdump.pcap
#    Validate BIP Messages
#    ...    initial_bip_file_path=${OUTPUT_DIR}/${SUITE_NAME}/tcpdump.pcap

Aic Delta Commisioning
    Log to console    Sending Delta Commissioning
    [Arguments]    ${cu_delta}    ${du_delta}
    Connect To Vdu And Vcu
    Send CU delta commissioning   input_filepath=${cu_delta}
    Send DU delta commissioning   input_filepath=${du_delta}
    Sleep    180s

Reset Aic Testline
    Log to console    Reseting Testline
    admin_cu.reset_cu
    admin_du.reset_vdu
    ssh.connect_to   hostname=192.168.200.1   username=toor4nsn   password=oZPS0POrRieRtu
    ssh.send command   system-module-reboot
    ssh.disconnect
    Sleep    360s
    Wait Until Keyword Succeeds    5min    30s    vcu.Assert Vcu Status
    ...    status=enabled
    Wait Until Keyword Succeeds    5min    30s    vdu.Check Radio Status
    ...    expected_status=on line

Reset Aic Airphone
    Log to console    Reseting Airpphone
    ssh.connect_to   hostname=192.168.200.1   username=toor4nsn   password=oZPS0POrRieRtu
    ssh.send command   system-module-reboot
    ssh.disconnect
    Sleep    360s
    Wait Until Keyword Succeeds    5min    30s    vdu.Check Radio Status
    ...    expected_status=on line

Wait for vCU and Radio Online Status
    Wait Until Keyword Succeeds    5min    30s    vcu.Assert Vcu Status
    ...    status=enabled
    Wait Until Keyword Succeeds    5min    30s    vdu.Check Radio Status
    ...    expected_status=on line

Enable AiC DCAP Params
    Send XML DU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/DCAP/Enable_DCAP_DU.xml
    Send XML CU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/DCAP/Delete_Unmodifiable_DCAP_Params_CU.xml
    Send XML CU Delta Commisioning    ${DELTA_FILES_PATH_AIC}/DCAP/Enable_DCAP_CU.xml

Enable AiC Vonr And Rohc
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Vonr_and_Rohc/Vonr_And_Rohc_CU_delta.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Vonr_and_Rohc/Vonr_And_Rohc_DU_delta.json
    Sleep    180s

Enable AiC Maxcidallowed 1
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Vonr_and_Rohc/Maxcidallowed_Value_1_CU_delta.json
    Sleep    180s

Enable AiC Emergency Call
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Vonr_and_Rohc/Emergency_Call_CU_delta.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/Vonr_and_Rohc/Emergency_Call_DU_delta.json
    Sleep    180s

Enable miNrNGCC
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_set_miNrNGCC_to_5.json

Enable AiC NSA Mobility
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_enable_NSA_Mobility_CU.json

Enable AiC A3 Measurements
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/5GC001354/delta_enable_a3meas_CU.json

Disable AiC Uplane Ciphering
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/delta_disable_uplane_ciphering_CU.json

Verify CU Counter Value Is Bigger Than The Given Value
    [Arguments]    ${value}    ${local_moid}    ${counter_id}
    ${latest_value}     Get Cu Counter    counter_id=${counter_id}    local_moid=${local_moid}

    Compare Counter Value    value=${value}    counter_value=${latest_value}
    ...    counter_id=${counter_id}    comparison_type=bigger

Verify CU Counter Value Is Lower Than The Given Value
    [Arguments]    ${value}    ${local_moid}    ${counter_id}
    ${latest_value}     Get Cu Counter    counter_id=${counter_id}    local_moid=${local_moid}

    Compare Counter Value    value=${value}    counter_value=${latest_value}
    ...    counter_id=${counter_id}    comparison_type=lower

Verify CU Counter Value Is Exact As Given Value
    [Arguments]    ${value}    ${local_moid}    ${counter_id}
    ${latest_value}     Get Cu Counter    counter_id=${counter_id}    local_moid=${local_moid}

    Compare Counter Value    value=${value}    counter_value=${latest_value}
    ...    counter_id=${counter_id}    comparison_type=exact

Verify CU Counters Value And Compare Them
    [Arguments]    ${first_counter_name}    ${second_counter_name}    ${local_moid1}    ${local_moid2}
    ${first_counter_value}      Get Cu Counter    counter_id=${first_counter_name}     local_moid=${local_moid1}
    ${second_counter_value}     Get Cu Counter    counter_id=${second_counter_name}    local_moid=${local_moid2}

    Check If Values Of Pm Counters Are Same    actual_value_for_first_counter_id=${first_counter_value}
    ...    actual_value_for_second_counter_id=${second_counter_value}

Verify DU Counters Value And Compare Them
    [Arguments]    ${first_counter_name}    ${second_counter_name}    ${local_moid1}    ${local_moid2}
    ${first_counter_value}      Get Du Counter    counter_id=${first_counter_name}     local_moid=${local_moid1}
    ${second_counter_value}     Get Du Counter    counter_id=${second_counter_name}    local_moid=${local_moid2}

    Check If Values Of Pm Counters Are Same    actual_value_for_first_counter_id=${first_counter_value}
    ...    actual_value_for_second_counter_id=${second_counter_value}

Get CU PM counters last timestamp
    ${counter}     admin_cu.Get counter
    ...    measurement_id=None
    ...    dimension_dist_name=MRBTS-1/NRBTS-1/NRCELL-1
    ...    counter_id=M55125C00001

    ${all_counter_values}    Get From Dictionary    ${counter}    values
    ${last_timestamp}    Get From Dictionary    ${all_counter_values[-1]}    start_time
    [Return]    ${last_timestamp}

Check if new CU PM counters are saved
    ${current_cu_counter_values_timestamp}    Get CU PM counters last timestamp
    Should not be equal   ${current_cu_counter_values_timestamp}    ${previous_cu_counter_values_timestamp}

Wait For Next PM counters Interval
    Connect To Vdu And Vcu
    ${previous_cu_counter_values_timestamp}    Get CU PM counters last timestamp
    Set test variable  ${previous_cu_counter_values_timestamp}
    Log to console    Wait For Next PM counters Interval...
    Wait until keyword succeeds  30x  15s    Check if new CU PM counters are saved

Modify AiC Config Addr To Ipv6
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    wts.Modify    set          UPF_ADDR="10.12.2.1/24,2001::1/48"
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}

Modify AiC Config To Emergency Call
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    wts.Modify    set_qosflow id=1          5qi=6 default=off
    wts.Modify    set_qosflow id=2 5qi=5                default=on
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}

Modify AiC Config To 2CC CA
    wts.Load Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    wts.Modify    enb_endc_param id=1          serving_cell_index_range_scg=8:9
    wts.Modify    set_cell id=1 gnb=2          nr_arfcn=632000:632000 gscn=7832
    wts.Modify    set_cell id=2 gnb=2          nr_arfcn=638700:638700 gscn=7902
    wts.Save Wts Cfg        ${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}


Collect U-plane Traces
    Run    utf_lab-IP 10.0.1.1
    Start Process      utf_lab-controller      start           alias=start_dcap
    ${result}=         Wait For Process        start_dcap
    Log to console     ${result.stdout}
    Should contain     ${result.stdout}        started successfully

    &{vcu}=  Create Dictionary
    ...  host=192.168.100.129
    ...  port=443
    ...  username=Nemuadmin
    ...  password=Nokia@123

    @{vcu_custom_profile}=    Create List    L2HiPdcp_Component

    &{vcu_trace}=  Create Dictionary
    ...  bts=${vcu}
    ...  vcu_custom_profile=${vcu_custom_profile}

    Create DCAP Trace Collector
    ...  name=dcap_vcu
    ...  trace=${vcu_trace}

    &{vdu}=  Create Dictionary
    ...  host=192.168.255.129
    ...  port=443
    ...  username=Nemuadmin
    ...  password=Nokia@123

    @{vdu_custom_profile}=    Create List    L2HiRlc_Component

    &{vdu_trace}=  Create Dictionary
    ...  bts=${vdu}
    ...  vdu_custom_profile=${vdu_custom_profile}

    Create DCAP Trace Collector
    ...  name=dcap_vdu
    ...  trace=${vdu_trace}

    dcap.Create Collector Group
    ...  name=dcap
    ...  members=dcap_vcu,dcap_vdu

    dcap.Setup Collectors   names=dcap
    dcap.Start Collectors   names=dcap
    dcap.Set Suite Alias     dcap

Stop Collect U-plane Traces
    dcap.Stop_collectors     names=dcap
    dcap.Collect Collectors  names=dcap
    dcap.Teardown Collectors  names=dcap

Get TL config from file
    [Arguments]  ${filename}=${None}
    Run keyword and return if  ${filename} != ${None}  Import variables  ${filename}
    ${hostname}=   Run  hostname | tr \"-\" \"_\"
    ${tl_config}=  Set variable  /home/ute/testline_configuration/${hostname}
    Import variables  ${tl_config}

Get TL config
    [Arguments]    ${filename}=${None}
    ${tl}=  Get variable value  $tl
    Run keyword if  "${tl}" == "${None}"  Get TL config from file  ${filename}
    Variable should exist  $tl  msg=Please execute test with parameter -V or set proper filename

    Set suite variable  ${NAMESPACE_CU}  ${tl.cloud_hostings[0].namespace}
    Set suite variable  ${NAMESPACE_DU}  ${tl.cloud_hostings[1].namespace}
    Set suite variable  &{MASTER_CU}
    ...  hostname=${tl.cloud_hostings[0].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[0].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[0].master_node.ssh_connection_details.password}
    ...  alias=cu_master
    Set suite variable  &{MASTER_DU}
    ...  hostname=${tl.cloud_hostings[1].master_node.ssh_connection_details.addr}
    ...  username=${tl.cloud_hostings[1].master_node.ssh_connection_details.username}
    ...  password=${tl.cloud_hostings[1].master_node.ssh_connection_details.password}
    ...  alias=du_master
    Set suite variable  &{OAM_CU}
    ...  host=${tl.gnbs[0].cu.oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].cu.oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].cu.oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].cu.oam_http_connection_details.password}
    ...  secure=${True}
    ...  alias=cu_admin
    Set suite variable  &{OAM_DU}
    ...  host=${tl.gnbs[0].dus[0].oam_http_connection_details.addr}
    ...  port=${tl.gnbs[0].dus[0].oam_http_connection_details.port}
    ...  username=${tl.gnbs[0].dus[0].oam_http_connection_details.username}
    ...  password=${tl.gnbs[0].dus[0].oam_http_connection_details.password}
    ...  secure=${True}
    ...  connection_name=du_admin
    Set suite variable  ${RRH_VLAN}  ${tl.ues[0].preferred_vlan_id}
    ${FHUC_VLANS}=  Get variable value  ${tl.gnbs[0].dus[0].fhuc_vlans}  ${None}
    Set suite variable  ${FHUC_VLANS}

Perform R&D flag change on CU
    [Arguments]    ${pod_name}    ${rd_flag}    ${rd_flag_value}

    &{mapping}=    Create Dictionary
    Set To Dictionary    ${mapping}    ${pod_name}=${rd_flag}

    &{k8s_CU}=    Create Dictionary
    ...    host=${MASTER_CU}[hostname]
    ...    user=${MASTER_CU}[username]
    ...    password=${MASTER_CU}[password]

    ${aashell_name}=    Set Variable    aashell_${pod_name}
    ${cu_pod_name}=    Set Variable    ute-${pod_name}-0

    aashell.create_aashell_cli
    ...    name=${aashell_name}
    ...    hops=${k8s_CU}
    ...    namespace=${NAMESPACE_CU}
    ...    pod=${cu_pod_name}
    ...    port=15007

    aashell.setup    ${aashell_name}
    ${params_CU}=    Create List
    ...    ${mapping}[${pod_name}]  ${rd_flag_value}

    aashell.change_rad_params    ${aashell_name}    ${params_CU}    is_permanent=True
    aashell.execute_aashell_command  ${aashell_name}  command=rad -u

    [Teardown]    aashell.teardown   ${aashell_name}

Perform R&D flag change on DU
    [Arguments]    ${pod_name}    ${rd_flag}    ${rd_flag_value}

    &{mapping}=    Create Dictionary
    Set To Dictionary    ${mapping}    ${pod_name}=${rd_flag}

    &{k8s_DU}=    Create Dictionary
    ...    host=${MASTER_DU}[hostname]
    ...    user=${MASTER_DU}[username]
    ...    password=${MASTER_DU}[password]

    ${aashell_name}=    Set Variable    aashell_${pod_name}
    ${du_pod_name}=    Set Variable    ute-${NAMESPACE_DU}-${pod_name}-0

    aashell.create_aashell_cli
    ...    name=${aashell_name}
    ...    hops=${k8s_DU}
    ...    namespace=${NAMESPACE_DU}
    ...    pod=ute-${du_pod_name}
    ...    port=15007

    aashell.setup    ${aashell_name}
    ${params_DU}=    Create List
    ...    ${mapping}[${pod_name}]  ${rd_flag_value}

    aashell.change_rad_params    ${aashell_name}    ${params_DU}    is_permanent=True
    aashell.execute_aashell_command  ${aashell_name}  command=rad -u

    [Teardown]    aashell.teardown   ${aashell_name}

Attach Ue And Perform SgNBAdditionRequest
    [Arguments]    ${ue_id}=11    ${tshark_msg_num}=1
    Attach Ue To Enb    ue_id=${ue_id}
    Execute Egate Command    cmd=ue_dc_enb_start ue=${ue_id} target_gnb=2 target_cells=1 bearer=2 type=split_scg
    Sleep    5s
    Verify Tshark For At Least Given Number Of Messages    alias=${DEFAULT_S1_MME_ALIAS}
    ...    packet_filter=${SGNB_RECONFIG_COMPLETE}    number_of_messages=${tshark_msg_num}
