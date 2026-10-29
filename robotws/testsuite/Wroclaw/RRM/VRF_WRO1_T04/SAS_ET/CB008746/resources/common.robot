*** Settings ***
Documentation
...   author: Adrianna Pienkowska, Jacek Kozmic, Agata Sidlo
...   contact: adrianna.pienkowska@nokia.com, jacek.kozmic@nokia.com, agata.sidlo@nokia.com
...   description: Krakow Verification Engineering team testcases for CB008746 feature

Library    ute_fsmaccess
Library    ute_wtssim
Library    taf.ul.ue.sim.env_setup                                           WITH NAME  env__
Library    ta5g_egate
Library    ta5g_syslog
Library    common_keywords.py                                                WITH NAME  common__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_txt.py
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/counters.py                          WITH NAME  counters__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/mcshark_management.py                WITH NAME  mcshark__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_egate.py    WITH NAME  egate__

Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/file_management.py                      WITH NAME  file__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/recom.py               WITH NAME  recom__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/suite.py               WITH NAME  suite__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/attach.py              WITH NAME  attach__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/logs.py                WITH NAME  logs__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_bip.py         WITH NAME  bip__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_wts.py                              WITH NAME  wts__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/common_gnb.py                              WITH NAME  gnb__
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_counters.py    WITH NAME  c_v
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validate_target_share.py  WITH NAME  ts_v
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/var_preparation.py        WITH NAME  c_p
Library    testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Python/slice_scheduling/validation_txt.py         WITH NAME  txt__


*** Keywords ***
Suite Setup 8746
    wts__.Ensure Eth3 Bh Is Ok
    ...    ${BH_ETH3_IP_ADDR}
    wts__.Ensure Eth4 Bh Is Ok
    ...    ${BH_ETH4_IP_ADDR}
    mcshark__.Download Mcshark If Not Present
    gnb__.Collect Scf File
    ...    final_path=${OUTPUT_DIR}/Default_scf.xml
    ...    set_variable=True

Test Setup 8746
    [Arguments]    ${tc}    ${test_cell_tech}
    common__.Set Variables Based On Deployment And Release    ${test_cell_tech}
    common__.Set Variables Based On Tc
    ...    tc=${tc}
    Prepare Environment For Tests Without Rebooting
    ...    tc=${tc}

Prepare Environment For Tests Without Rebooting
    [Arguments]    ${tc}
    wts__.Ensure Wts Is Not Running
    gnb__.Ensure Short Pmstats Flag Existence In Swconfig
    gnb__.Ensure Cplane Flags Existence In Swconfig
    gnb__.Ensure Cp Runtime Ini Has LoggingSeverity Set On Trace
    suite__.Create Output Dir Tc
    ...    tc=${tc}
    suite__.Remove Admin Logs If Exists

Test Teardown 8746
#    suite__.try_to_send_result_to_rep_portal
    Run Keyword And Ignore Error
    ...    SYSCOM Stop
    Run Keyword And Ignore Error
    ...    Ng Link Logs Stop
    Run Keyword And Ignore Error
    ...    LOG SYSLOG BIP Stop
    Run Keyword And Ignore Error
    ...    wts__.Stop Wts And Clear
    gnb__.Perform Gnb Commissioning
    ...    scf_file=${COLLECTED_SCF_FILE}

Custom Config Setup
    [Arguments]   ${scf}    ${iphy}
    env__.add_gnb_configuration
    ...  scfc=${scf}
    env__.add_simulator
    ...  sim_type=Airphone
    ...  config=${iphy}
    env__.configure_environment

Custom Config Setup PRB DSS
    Log    Custom Config Setup PRB DSS
    Custom Config Setup
    ...    scf=${SCF_PATH_PRB_DSS}
    ...    iphy=${IPHY_PATH_PRB_DSS}

Perform Delta Recomissioning And Reboot Setup
    [Arguments]    ${delta}    ${delta_setup}
    Perform Delta Recomissioning
    ...    delta=${delta}
    ...    delta_setup=${delta_setup}
    gnb__.Reset Units And Wait For Radio Head Online

Perform Delta Recomissioning
    [Arguments]    ${delta}    ${delta_setup}
    recom__.Set Dynamically Quotas Sd Cell Celldeptype Mapping
    ...    delta_file=${delta}
    ...    delta_setup=${delta_setup}
    common__.Perform Delta Recomissioning
    ...    delta_file=${DELTA_READY_TO_COM}
    ...    full_path=${TRUE}

SYSLOG Start
    Log    SYSLOG Start
    logs__.Start Syslog Capture
    ...    output_dir=${OUTPUT_DIR_TC}

SYSLOG Stop
    Log    SYSLOG Stop
    logs__.Stop Syslog Capture

SHERPA Start
    Log    SHERPA Start
    logs__.Start Sherpa Capture
    ...    output_dir=${OUTPUT_DIR_TC}

SHERPA Stop
    Log    SHERPA Stop
    logs__.Stop Sherpa Capture
    ...    output_dir_csv=${OUTPUT_DIR_TC}/SHERPA

BIP Start
    Log    BIP Start
    logs__.Start Bip Capture

BIP Stop
    Log    BIP Stop
    logs__.Stop Bip Capture

SYSCOM Start
    Log    SYSCOM Start
    logs__.Start Syscom Collection

SYSCOM Stop
    Log    SYSCOM Stop
    logs__.Stop Syscom Collection
    ...    output_dir=${OUTPUT_DIR_TC}/SYSCOM

LOG SYSLOG BIP SHERPA Start
    SYSLOG Start
    SHERPA Start
    BIP Start

LOG SYSLOG BIP SHERPA Stop
    BIP Stop
    SHERPA Stop
    SYSLOG Stop

LOG SYSLOG BIP Start
    SYSLOG Start
    BIP Start

LOG SYSLOG BIP Stop
    BIP Stop
    SYSLOG Stop

Start Log Collection
    Run Keyword And Ignore Error
    ...    SYSLOG Start
    Run Keyword And Ignore Error
    ...    SHERPA Start
    Run Keyword And Ignore Error
    ...    BIP Start

Validate CellSetupReq Pcap
    [Arguments]    ${delta_setup}    ${expected_status}
    common__.Set Variables For Bip Validation
    ...    delta_setup=${delta_setup}
    bip__.Save Filtered Pcap To Txt File
    ...    output_dir=${OUTPUT_DIR_TC}/SYSCOM
    ...    prefix=${BIP_MSG_CELLSETUPREQ}
    ...    using_mcshark=${ENABLE_MCSHARK_USAGE}
    ...    filter=${BIP_FILTER_CELLSETUPREQ}
    bip__.Ensure Decoded Txt File Exists
    bip__.Ensure Slice Aware Scheduler Is Activated
    ...    expected_status=${expected_status}
    bip__.Ensure Quotas Contain Correct Values NSA
    ...    expected_quotas=${QUOTAS}
    bip__.Ensure NRG Ids Are Correct
    ...    expected_resource_group_ids=${RESOURCE_GROUP_IDS}

Validate Bip UserSetupReq ResourceGroupId Not Set
    [Arguments]    ${ues}
    bip__.Save Filtered Pcap To Txt File
    ...    output_dir=${OUTPUT_DIR_TC}/SYSCOM
    ...    prefix=${BIP_MSG_USERSETUPREQ}
    ...    using_mcshark=${ENABLE_MCSHARK_USAGE}
    ...    filter=${BIP_FILTER_USERSETUPREQ}
    bip__.Ensure Decoded Txt File Exists
    bip__.Ensure ResourceGroupId Not Set In UserSetupReq
    ...    ues=${ues}

Validate Bip UserSetupReq ResourceGroupId
    [Arguments]    ${ues}    ${expected_nrg_ids}
    bip__.Save Filtered Pcap To Txt File
    ...    output_dir=${OUTPUT_DIR_TC}/SYSCOM
    ...    prefix=${BIP_MSG_USERSETUPREQ}
    ...    using_mcshark=${ENABLE_MCSHARK_USAGE}
    ...    filter=${BIP_FILTER_USERSETUPREQ}
    bip__.Ensure Decoded Txt File Exists
    bip__.Ensure ResourceGroupId Properly Set In UserSetupReq
    ...    ues=${ues}
    ...    expected_nrg_ids=${expected_nrg_ids}

Ng Link Logs Start
    Log    Ng Link Logs Start
    logs__.Ng Link Logs Start

Ng Link Logs Stop
    Log    Ng Link Logs Stop
    logs__.Ng Link Logs Stop

Activate Feature And Start Basic Logs
    [Arguments]    ${delta}    ${delta_setup}    ${wts}
    SYSLOG Start
    Perform Delta Recomissioning And Reboot Setup
    ...    delta=${delta}
    ...    delta_setup=${delta_setup}
    BIP Start
    SYSCOM Start
    Start WTS For NSA
    ...    wts=${wts}

Start WTS For NSA
    [Arguments]    ${wts}
    wts__.Start Wts
    ...    wts_config_filename=${wts}
    gnb__.Wait Till Admin Is Online

Attach Multiple Ues To Plmns And Start Traffic
    [Arguments]    ${nr_ues}    ${spid}    ${plmn}    ${dl_mbps}    ${first_ue_id}=11    ${x2_setup}=${True}   ${cell_id}=1
    common__.Set Nsa Ues Ids
    ...    nr_ues=${nr_ues}
    ...    first_ue_id=${first_ue_id}
    attach__.Configure Spid For Ues
    ...    ue_ids=${UE_IDS}
    ...    spid=${spid}
    Attach NSA UEs And Start Traffic
    ...    nr_ues=${nr_ues}
    ...    plmn=${plmn}
    ...    dl_mbps=${dl_mbps}
    ...    first_ue_id=${first_ue_id}
    ...    x2_setup=${x2_setup}
    ...    cell_id=${cell_id}


Attach NSA UEs And Start Traffic
    [Arguments]    ${nr_ues}    ${plmn}    ${dl_mbps}    ${first_ue_id}=11    ${x2_setup}=${True}   ${cell_id}=1
    Ng Link Logs Start
    common__.Set Nsa Ues Ids
    ...    nr_ues=${nr_ues}
    ...    first_ue_id=${first_ue_id}
    common__.Set Bearers For Many Ues
    ...    nr_ues=${UE_IDS}
    attach__.Attach Many Nsa Ues
    ...    ues_id=${UE_IDS}
    ...    bearer=${BEARERS}
    ...    plmn=${plmn}
    ...    x2_setup=${x2_setup}
    ...    cell_id=${cell_id}
    common__.Wait For Ng Logs To Be Collected
    Ng Link Logs Stop
    wts__.Start Traffic For Multiple Ues
    ...    number_of_ues=${nr_ues}
    ...    traffic_direction=dl
    ...    first_ue_id=${first_ue_id}
    ...    dl_mbps=${dl_mbps}
    ...    net_arch=nsa
    ...    bearer=2
    common__.Wait For Tput Stabilization


Check SPID Values For UEs
    [Arguments]    ${delta_setup}    ${ue_spid}    ${plmns}    ${step}
    c_p.Get Spid Values From Delta
    ...    delta_dict=${delta_setup}
    For Ues Check Pmqap Object Value
    ...    ue_spid=${ue_spid}
    ...    plmns=${plmns}
    ...    step=${step}

Check SPID Values For UEs After Recomissioning
    [Arguments]    ${delta_setup}    ${prev_delta}    ${ue_spid}    ${plmns}    ${step}
    c_p.Get Spid Values From Delta
    ...    delta_dict=${delta_setup}
    common__.Prepare Check Spids Dict
    ...    prev_delta=${prev_delta}
    For Ues Check Pmqap Object Value
    ...    ue_spid=${ue_spid}
    ...    plmns=${plmns}
    ...    step=${step}

Prepare Environment For DSS Test
    Prepare Environment For Tests without rebooting
    ...    tc=EB101_DSS
    suite__.change_setup_from_l1bypass_to_fs
    gnb__.Reset Units And Wait For Radio Head Online
    ...    retry_interval=60
    recom__.Perform Delta Recomissioning
    ...    output_dir=${OUTPUT_DIR}
    ...    delta=${DELTA_DSS}
    gnb__.Reset Units And Wait For Radio Head Online
    ...    retry_interval=60


Prepare Environment For PRB And DSS Test
    Prepare Environment For Tests without rebooting
    ...    tc=EB101_DSS_PRB
    Prepare Environment For PRB
    ...    vendor_file_path=${VENDOR_PRB_DSS}
    ...    delta=${DELTA_B_PRB_DSS}

Prepare Environment For PRB
    [Arguments]    ${vendor_file_path}    ${delta}
    recom__.Perform Delta Recomissioning
    ...    output_dir=${OUTPUT_DIR_TC}
    ...    delta=${delta}
    gnb__.collect_scf_file
    ...    set_variable=${SET_VARIABLE_DURING_SCF_COLLECTION}
    suite__.rewrite_vendor_file
    ...    vendor_file_path=${vendor_file_path}
    gnb__.send_vendor_file_and_perform_gnb_commissioning
    ...    scf_file=${COLLECTED_SCF_FILE}
    ...    vendor_file=${vendor_file_path}
    gnb__.Reset Units And Wait For Radio Head Online
    ...    retry_interval=60


Setup DSS Partnership
    [Arguments]    ${wts_cfg}
    wts__.start_wts
    ...    wts_config_filename=${wts_cfg}
    ...    wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...    edaemon_port=${EDAEMON_PORT}
    ...    egate_port=${EGATE_PORT}
    suite__.wait_for_starting_wts_procedure
    ...    seconds=200
    attach__.create_partnership_between_eNB_and_gNB_for_all_cells
    ...    egate_log=${EGATE_CONSOLE_LOG}
    attach__.create_partnership_for_many_cells
    ...    egate_log=${EGATE_CONSOLE_LOG}
    ...    cell_list=${PRB_DSS_CELLS}
    ...    ue_id_list=${PRB_DSS_UES}
    ...    port=4
    attach__.wait_for_sib_for_all_cells
    ...    sib_reception_list=${SIB_RECEPTION_LIST}
    ...    egate_log=${EGATE_CONSOLE_LOG}


Setup For One Cell DSS Partnership
    [Arguments]    ${wts_cfg}
    wts__.start_wts
    ...    wts_config_filename=${wts_cfg}
    ...    wts_dir_path=${IPHY_DIR_PATH_DEFAULT}
    ...    edaemon_port=${EDAEMON_PORT}
    ...    egate_port=${EGATE_PORT}
    attach__.create_partnership_between_eNB_and_gNB_for_all_cells
    ...    egate_log=${EGATE_CONSOLE_LOG}
    attach__.create_partnership_for_one_cell
    ...    egate_log=${EGATE_CONSOLE_LOG}
    ...    ue_id=11
    ...    cell=1
    ...    port=2
    wts__.wait_for_information_block_reception
    ...    sib_reception_dict=${SIB_RECEPTION_DICT_SA_SANSA}
