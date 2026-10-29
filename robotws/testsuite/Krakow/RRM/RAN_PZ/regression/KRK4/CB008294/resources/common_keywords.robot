*** Settings ***
Documentation
...    author: Damian Zak, Mateusz Plinta, Mateusz Pajor
...    maintainer: Damian Zak, Mateusz Plinta, Mateusz Pajor
...    contact: damian.zak@nokia.com, mateusz.plinta@nokia.com, mateusz.pajor@nokia.com
...    description: CB008294 common keywords

Library    OperatingSystem
Library    ute_wtssim
Library    ute_fsmaccess
Library    ta5g_egate
Library    ta5g_tshark
Library    ta5g_syslog
Library    ta_egate_cmd_parser
Library    ta5g_testline_management

Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_gnb        WITH NAME    common_gnb
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_wts        WITH NAME    common_wts
Library    testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.resources.Python.common_airphone   WITH NAME    common_airphone

Library    egate.py
Library    wts_config.py
Library    log_collection.py
Library    iphy_modification.py
Library    tcpdump_verification.py
Library    suite_specific_keywords.py
Library    pm_counters.py
Library    tti_trace_verification.py
Library    utf_installer.py
Library    taf.rfrl.common_resources.reporting_portal.bts_metadata
Library    taf/rfrl/procedures/resources/python/setups_and_teardowns_keywords.py
Library    ta_messaging
Library    emil_pmi_ticket_verification.py

Resource    taf/rfrl/utilities/utf_lab/utf_lab.robot
Resource    taf/rfrl/common_resources/robot/libraries_instances.robot
Resource    testsuite/Krakow/RRM/RAN_PZ/regression/KRK4/resources/Robot/TtiTrace/tti_trace_collector.robot
Resource    ta_messaging/flow.robot

Variables    variables.py
Variables    ue_caps_variables.py
Variables    deltas/delta_vars.py

*** Keywords ***
Suite Environment Preparation
    [Arguments]    ${scf_filename}=scf_A_B3XX.xml
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    common_airphone.Log Airphone Build
    common_gnb.Log Gnb Build
    Set Variables Based On Deployment And Release
    Set SCTP Timeouts For Vm
    Set Proper Vlan Id In Base Scf    scf_filename=${scf_filename}
    common_wts.Configure IPs On Vm Interfaces
    ...    cfg_filepath=/opt/wts/latest/basic_setup.cfg
    common_gnb.Ensure Flags Existence In Swconfig    ${K2MIN_RDNUMOFSCELLCHECKS}
    Prepare Iphy File    dest_filepath=${BASE_IPHY_PATH}
    Log To Console    Applying default 8294 SCF
    common_gnb.Perform gNB Commissioning    scf_file=${SCFS_DIRECTORY_PATH}/${scf_filename}
    Collect Base SCF File
    Install Latest Utf


Set SCTP Timeouts For Vm
    [Documentation]    Vm system commands that need to be run in order for 7CC & 8CC configurations to work
    Run    sudo sysctl -w net.sctp.sack_timeout=200
    Run    head -1 /proc/sys/net/sctp/sack_timeout
    Run    sudo sysctl -w net.sctp.rto_min=25000
    Run    head -1 /proc/sys/net/sctp/rto_min
    Run    sudo sysctl -w net.sctp.rto_initial=25000
    Run    head -1 /proc/sys/net/sctp/rto_initial
    Run    sudo sysctl -w net.sctp.rto_max=40000
    Run    head -1 /proc/sys/net/sctp/rto_max


Set Common Test Environment Preparation Keywords
    Log    \nStart setup    console=True
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    common_gnb.Delete Localhost Ssh Key From Known Hosts
    Wait For Testline Icmp Echo Replies And Ssh Services


Wait For Radio Head Online And Perform Delta Commissioning If Needed
    [Arguments]    ${delta}=${None}
    Run Keyword If    ${delta} is not None
    ...    common_gnb.Reset Units And Wait For Radio Head Online    recovery_reboot_retires=${1}    skip_reset=${True}
    Run Keyword If    ${delta} is not None
    ...    Log To Console    Sending delta commissioning...
    Run Keyword If    ${delta} is not None
    ...    common_gnb.Perform Recomissioning With Delta    path_to_delta=${delta}


Common Test Environment Preparation
    [Arguments]    ${delta}=${None}
    ...            ${nr_ue_caps}=${UE_CAPS_8DL_4UL}
    ...            ${mrdc_ue_caps}=${None}
    ...            ${cells_arfcn_gscn}=${None}
    ...            ${ue_ids}=(1,)
    ...            ${pcell}=${1}
    ...            ${cell_subcell_map}=${None}
    ...            ${cc_dl}=${8}
    ...            ${cc_ul}=${4}
    ...            ${sib_reception_dict}={2:[${pcell}]}
    Set Common Test Environment Preparation Keywords
    Set Test Specific Variables
    ...    cell_subcell_map=${cell_subcell_map}
    ...    pcell=${pcell}
    ...    cc_dl=${cc_dl}
    ...    cc_ul=${cc_ul}
    ...    ue_ids=${ue_ids}
    Wait For Testline Icmp Echo Replies And Ssh Services
    Prepare Iphy File Default
    ${wts_config_path}=    Prepare Wts Config
    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/test_adapted_basic_setup.cfg
    ...    nr_ue_caps=${nr_ue_caps}
    ...    mrdc_ue_caps=${mrdc_ue_caps}
    ...    cells_arfcn_gscn=${cells_arfcn_gscn}
    ...    ue_ids=${ue_ids}
    ...    pcell=${pcell}
    ${delta} =    Combine Test Specific Delta With Subcell Delta    ${delta}
    Wait For Radio Head Online And Perform Delta Commissioning If Needed    delta=${delta}
    ${sib_reception_dict} =    Evaluate    eval("${sib_reception_dict}")
    Setup Radio Modules And Wts And Wait For Mib-Sib Reception
    ...    sib_reception_dict=${sib_reception_dict}
    ...    cell_subcell_map=${CELL_SUBCELL_MAP}
    ...    wts_config_path=${wts_config_path}
    Start Collecting Logs
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report


Test Environment Preparation For B6
    [Arguments]    ${delta}=${None}
    ...            ${nr_ue_caps}=${UE_CAPS_8DL_4UL}
    ...            ${ues_fr2_sa}=(1,)
    ...            ${ues_fr2_nsa}=(11,)
    ...            ${pcell}=${1}
    ...            ${nr_ue_caps_fr2_nsa}=${UE_CAPS_NR_FR2_NSA}
    ...            ${sib_reception_dict}={2:[${pcell}]}
    ...            ${mib_reception_list}=[1,2,3,4,5,6,7,8,9,10]
    Set Common Test Environment Preparation Keywords
    ${pcell}=    Convert To Integer    ${pcell}
    Set Test Variable    ${PCELL_PCI}    ${${50}+${pcell}}
    Prepare Iphy File B6
    ${wts_config_path}=    Prepare Wts Config A_B6
    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/test_adapted_basic_setup.cfg
    ...    nr_ue_caps=${nr_ue_caps}
    ...    nr_ue_caps_fr2_nsa=${nr_ue_caps_fr2_nsa}
    ...    ues_fr2_sa=${ues_fr2_sa}
    ...    ues_fr2_nsa=${ues_fr2_nsa}
    ...    pcell=${pcell}
    ${delta} =    Combine Test Specific Delta With Subcell Delta For B6 B7    ${delta}
    Wait For Radio Head Online And Perform Delta Commissioning If Needed    delta=${delta}
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds    10min    30s    common_gnb.Assert BTS In State    bts_state=configured
    ${sib_reception_dict} =    Evaluate    eval("${sib_reception_dict}")
    ${mib_reception_list} =    Evaluate    eval("${mib_reception_list}")
    common_wts.Wait For Environment Prepared For Wts Ready State
    ...    sib_reception_dict=${sib_reception_dict}
    ...    wts_config_filename=${wts_config_path}
    ...    allow_first_reboot=False
    ...    retry=${1}
    ...    timeout=${300}
    common_wts.Setup X2 Link
    Wait For Cells MIBs    mib_reception_list=${mib_reception_list}
    Start Collecting Logs
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report


Test Environment Preparation For B7
    [Arguments]    ${delta}=${None}
    ...            ${nr_ue_caps}=${UE_CAPS_8DL_4UL}
    ...            ${nr_ue_caps_fr1_sa}=${UE_CAPS_NR_FR1_SA}
    ...            ${ues_fr2_sa}=(1,)
    ...            ${ues_fr1_sa}=(2,)
    ...            ${pcell}=${1}
    ...            ${sib_reception_dict}={2:[${pcell},9]}
    ...            ${mib_reception_list}=[1,2,3,4,5,6,7,8,9,10]
    Set Common Test Environment Preparation Keywords
    ${pcell}=    Convert To Integer    ${pcell}
    Set Test Variable    ${PCELL_PCI}    ${${50}+${pcell}}
    Prepare Iphy File B7
    ${wts_config_path}=    Prepare Wts Config A_B7
    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/test_adapted_basic_setup.cfg
    ...    nr_ue_caps=${nr_ue_caps}
    ...    nr_ue_caps_fr1_sa=${nr_ue_caps_fr1_sa}
    ...    ues_fr2_sa=${ues_fr2_sa}
    ...    ues_fr1_sa=${ues_fr1_sa}
    ...    pcell=${pcell}
    ${delta} =    Combine Test Specific Delta With Subcell Delta For B6 B7    ${delta}
    Wait For Radio Head Online And Perform Delta Commissioning If Needed    delta=${delta}
    ${sib_reception_dict} =    Evaluate    eval("${sib_reception_dict}")
    ${mib_reception_list} =    Evaluate    eval("${mib_reception_list}")
    Setup Radio Modules And Wts And Wait For Mib-Sib Reception
    ...    sib_reception_dict=${sib_reception_dict}
    ...    mib_reception_list=${mib_reception_list}
    ...    wts_config_path=${wts_config_path}
    Start Collecting Logs
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report


Test Environment Preparation For D_B102
    [Arguments]    ${sib_reception_dict}
    ...            ${mib_reception_list}
    ...            ${ue_ids}=(1,)
    ...            ${cc_dl}=${8}
    ...            ${cc_ul}=${4}
    Set Common Test Environment Preparation Keywords
    ${CC_DL} =    Set Test Variable    ${cc_dl}
    ${CC_UL} =    Set Test Variable    ${cc_ul}
    ${UE_IDS} =    Set Test Variable    ${ue_ids}
    ${sib_reception_dict} =    Evaluate    eval("${sib_reception_dict}")
    ${mib_reception_list} =    Evaluate    eval("${mib_reception_list}")
    Wait For Testline Icmp Echo Replies And Ssh Services
    Prepare Iphy File D_B102
    ${wts_config_path}=    Prepare Wts Config D_B102
    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/test_adapted_basic_setup.cfg
    ...    nr_ue_caps=${UE_CAPS_8DL_4UL}
    Setup Radio Modules And Wts And Wait For Mib-Sib Reception
    ...    sib_reception_dict=${sib_reception_dict}
    ...    mib_reception_list=${mib_reception_list}
    ...    wts_config_path=${wts_config_path}
    Start Collecting Logs
    Run Keyword And Ignore Error    setups_and_teardowns_keywords.Add Main BTS Metadata to Report


Setup Radio Modules And Wts And Wait For Mib-Sib Reception
    [Arguments]    ${wts_config_path}    ${sib_reception_dict}    ${mib_reception_list}=${None}    ${cell_subcell_map}=${None}
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds    10min    30s    common_gnb.Assert BTS In State
    ...    bts_state=configured
    common_wts.Wait For Environment Prepared For Wts Ready State
    ...    sib_reception_dict=${sib_reception_dict}
    ...    wts_config_filename=${wts_config_path}
    ...    allow_first_reboot=False
    ...    retry=${1}
    ...    timeout=${300}
    Wait For Cells MIBs    mib_reception_list=${mib_reception_list}    cell_subcell_map=${cell_subcell_map}


Test Environment Teardown
    Log To Console  \nStart Teardown
    Teardown Collecting Logs In Robot
    Restore Default Iphy
    Restore Default SCF


Collect Base SCF File
    common_gnb.Collect SCF File
    ...    final_path=${BASE_SCF_PATH}


Restore Default SCF
    ${status} =    Run Keyword And Return Status
    ...    common_gnb.Perform gNB Commissioning    scf_file=${BASE_SCF_PATH}
    Run Keyword If    ${status} is ${False}
    ...    Reset Units And Retry Restoring Default SCF


Reset Units And Retry Restoring Default SCF
    Log To Console    Restoring SCF failed, will try to reboot the units...
    common_gnb.Reset Units
    Wait For Testline Icmp Echo Replies And Ssh Services
    Run Keyword And Ignore Error    common_gnb.Wait For All Radio Modules To Be Online
    common_gnb.Perform gNB Commissioning    scf_file=${BASE_SCF_PATH}


Start TTI Trace
    Start TTI Trace Collection    yaml_config_path=${CURDIR}/tti_config.yaml    release=${RELEASE_NO_CONV}


Stop Attach TTI Trace Collection
    Stop TTI Trace Collection    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/tti_trace_attach


Stop Traffic TTI Trace Collection
    [Arguments]    ${folder}=tti_trace_traffic
    Stop TTI Trace Collection    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/${folder}


Stop Detach TTI Trace Collection
    Stop TTI Trace Collection    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/tti_trace_detach


Stop Beam Change TTI Trace Collection
    Stop TTI Trace Collection    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/tti_trace_beam_change


Collect Traffic TTI Traces
    [Arguments]    ${seconds}=2    ${folder}=tti_trace_traffic
    Start TTI Trace
    Sleep    ${seconds}
    Stop Traffic TTI Trace Collection    folder=${folder}


Collect Traffic TTI Traces And With Testmode Activation
    [Arguments]    ${folder}=tti_trace_traffic_with_testmode_act
    Start TTI Trace
    Activate Testmode Profile    ue_id=${1}    profile_id=${6}    scell=${3}    testmode=bler
    Activate Testmode Profile    ue_id=${1}    profile_id=${3}    scell=${3}    testmode=csi_override
    Stop Traffic TTI Trace Collection    folder=${folder}

Perform Beam Change With TTI Collection
    Start TTI Trace
    Wait For TTI Trace Collection
    Perform Beam Switch
    Wait For TTI Trace Collection
    Stop Beam Change TTI Trace Collection


Perform 5G Attach With TTI Collection
    [Arguments]    ${number_of_ues}=${1}    ${net_arch}=SA    ${cell_id}=${None}
    Start TTI Trace
    Perform 5G Attach     number_of_ues=${number_of_ues}    net_arch=${net_arch}    cell_id=${cell_id}
    Stop Attach TTI Trace Collection


Perform 5G Attach For Specific UE With TTI Collection
    [Arguments]    ${ue_ids}=(1,)    ${net_arch}=SA    ${cell_id}=${None}
    Start TTI Trace
    Perform 5G Attach For Specific UE    ue_ids=${ue_ids}    net_arch=${net_arch}    cell_id=${cell_id}
    Stop Attach TTI Trace Collection


Perform 5G Attach And Expect Release With TTI Collection
    [Arguments]    ${ue_ids}=(1,)
    Start TTI Trace
    Perform 5G Attach And Expect Release    ue_ids=${ue_ids}
    Stop Attach TTI Trace Collection


Perform 5G Detach With TTI Collection
    [Arguments]    ${ue_ids}=(1,)    ${net_arch}=SA
    Start TTI Trace
    Perform 5G Detach    ue_ids=${ue_ids}    net_arch=${net_arch}
    Stop Detach TTI Trace Collection


Teardown Collecting Logs In Robot
    Teardown Collecting Logs
    Run Keyword If Test Failed    Collect Additional Logs
    Collect Admin Api Logs    subdir=${SUITE_NAME}/${TEST_NAME}    dir_name=admin_api_logs


Collect Additional Logs
    Collect Gnb Snapshot    output_filepath=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/snapshot_gNB.zip
    common_wts.Collect Sos Report Log    log_output_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}/sos_report


Wait For Traffic Stabilization
    [Arguments]    ${wait_time}=60
    Sleep    ${wait_time}


Wait For TTI Trace Collection
    Sleep    2


Wait For SCells To Deactivate
    [Arguments]    ${wait_time}=10
    Sleep    ${wait_time}


Wait For FR2 CA Activation
    Sleep    10


Setup DCAP
    utf_lab.Start UTF Lab On UTE VM
    utf_lab.Connect     username=${None}    password=${None}
    utf_lab.Add Gnb     gnb_ip=10.0.1.2    gnb_port=${443}


Start Emil Collection
    Set Test Variable    ${DCAP_RESULTS_COLLECTED}    ${False}
    ${cplane_custom_profile} =    Create List    cp_5g
    ${trace_id} =    utf_lab.Start Trace Gnb
    ...    gnb_ip=10.0.1.2
    ...    gnb_port=${443}
    ...    gnb_custom_profile=${cplane_custom_profile}
    ...    control_plane_interface=${True}
    [Return]    ${trace_id}


Stop Emil Collection
    [Arguments]    ${trace_id}
    utf_lab.Stop Trace    trace_id=${trace_id}


Extract 5gm File From DCAP Logs
    [Arguments]    ${trace_id}
    ${zip_filepath} =    utf_lab.Get Results    ${trace_id}
    ${filename} =    Extract 5gm Logfile From Zip
    ...    path=${zip_filepath}
    ...    log_name=start_trace_control-plane
    ...    delete_zip=${False}
    ...    collect_trace_logs=${False}
    ...    filename=emil_traces.5gm
    Set Test Variable    ${DCAP_RESULTS_COLLECTED}    ${True}
    [Return]    ${filename}


Get Results From DCAP If Test Failed
    Run Keyword If Test Failed    Run Keyword If    ${DCAP_RESULTS_COLLECTED} is ${False}    utf_lab.Get Results
