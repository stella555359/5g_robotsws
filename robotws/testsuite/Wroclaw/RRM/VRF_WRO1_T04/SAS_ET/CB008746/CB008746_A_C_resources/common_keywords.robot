*** Settings ***

Documentation
...    author: Mateusz Lesniak
...    maintainer: Beata Kapusta, Marcin Trebunia
...    contact: I_CD_ET_TESTERS@internal.nsn.com
...    description: CB008746-A-C common keywords

Library    OperatingSystem
Library    ta5g_enb
Library    ta5g_syslog
Library    ute_wtssim
Library    ta5g_egate
Library    ute_fsmaccess
Library    ute_tshark
Library    ta5g_pm_counters
Library    taf.sbts.oam.coam.admin                                               WITH NAME    admin
Library    attach_and_traffic_keywords.py
Library    pmqap_counters.py
Library    iphy_modification.py
Library    common_keywords.py
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_gnb            WITH NAME    common_gnb
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_wts            WITH NAME    common_wts
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.common_airphone       WITH NAME    common_airphone
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.logs_collector        WITH NAME    logs_collector
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.bip_management        WITH NAME    bip_management
Library    testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.pm_counters           WITH NAME    pm_counters
Library    syscom_keywords.py

Resource   testsuite/Wroclaw/RRM/sim_resources/Krk_regression/MN_RAN_L2/resources/Robot/TtiTrace/tti_trace_collector.robot

Variables    variables.py

*** Keywords ***
Suite Setup
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}
    common_airphone.Log Airphone Build
    common_gnb.Log Gnb Build
    common_wts.Configure IPs On Vm Interfaces
    ...    cfg_filepath=/opt/wts/latest/basic_setup.cfg
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml

Test Setup
    [Arguments]    ${qos_flows}=${None}    ${qos_rules}=${None}    ${reconfigure_sa_ue_to_second_plmn}=${None}
    ...            ${reconfigure_nsa_ue_to_second_plmn}=${None}    ${plmn}=${None}    ${snssai}=${None}
    ...            ${bearers}=${None}    ${target_number_of_nsa_ues}=2    ${target_number_of_sa_ues}=2
    ...            ${sib_reception_dict}=${None}    ${net_arch}=SA    ${nr_ue_caps}=${None}    ${mrdc_ue_caps}=${None}
    ...            ${gscn_value}=${None}    ${nrarfcn_value}=${None}    ${arfcn_gscn_change}=${None}
    ...            ${syscom_validation_path}=${None}    ${carrier_aggregation}=${False}    ${ue_id}=${None}
    ...            ${remove_cell}=${None}    ${mu_mimo}=${False}    ${TC22}=${False}    ${cell_id}=50
    ...            ${first_sa_ue}=1    ${first_nsa_ue}=101    ${delta_path}=${None}
    Log    \nStart setup with params like ${nrarfcn_value},${ue_id}  console=True
    Create Directory    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ${new_wts_config_path}=    Prepare Wts Config File
    ...    target_number_of_nsa_ues=${target_number_of_nsa_ues}
    ...    target_number_of_sa_ues=${target_number_of_sa_ues}
    ...    snssai=${snssai}
    ...    plmn=${plmn}
    ...    reconfigure_sa_ue_to_second_plmn=${reconfigure_sa_ue_to_second_plmn}
    ...    reconfigure_nsa_ue_to_second_plmn=${reconfigure_nsa_ue_to_second_plmn}
    ...    qos_flows=${qos_flows}
    ...    qos_rules=${qos_rules}
    ...    bearers=${bearers}
    ...    nr_ue_caps=${nr_ue_caps}
    ...    mrdc_ue_caps=${mrdc_ue_caps}
    ...    first_sa_ue=${first_sa_ue}
    ...    first_nsa_ue=${first_nsa_ue}
    ...    net_arch=${net_arch}
    ...    arfcn_gscn_change=${arfcn_gscn_change}
    ...    mu_mimo=${mu_mimo}
    ...    remove_cell=${remove_cell}
    ...    target_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/new_basic_setup.cfg
    Run Keyword If  ${TC22} == ${True}  Download Bsr Package And Upload To Gnb
    Run Keyword If  ${carrier_aggregation} == ${True}  Change Gscn In Iphy
    ...    gscn_value=${gscn_value}
    ...    reset=${True}
    Run Keyword If  ${mu_mimo} == ${True}  Adjust Iphy File For Mu Mimo
    ...    optlink_obj=${OPTLINK}
    ...    ru_type=AQQL
    ...    resource_build_key=LTX_AQQL_E1
    ...    product_code=475732A
    ...    subcells_ul_value={'1': '2'}
    ...    index=1
    Run Keyword If  ${TC22} == ${False}  Log To Console    Performing delta recommissioning...
    Run Keyword If  ${TC22} == ${False}  common_gnb.Perform Recomissioning With Delta
    ...    path_to_delta=${delta_path}
    common_gnb.Wait For All Radio Modules To Be Online
    Wait Until Keyword Succeeds    5min    30s    common_gnb.Assert BTS In State
    ...    bts_state=configured
    common_keywords.Start Collecting Syslog
    ...   log_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    bip_management.Start Syscom Collection
    common_wts.Wait For Environment Prepared For WTS Ready State
    ...    allow_first_reboot=${False}
    ...    timeout=${60}
    ...    wts_config_filename=${new_wts_config_path}
    ...    sib_reception_dict=${sib_reception_dict}
    common_wts.Setup X2 Link
    Wait For NSA Cells Readiness
    bip_management.Stop Syscom Collection
    ...    output_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    syscom_keywords.Get Latest Collected Syscom For Cell
    ...     output_dir=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}
    ...     cell_id=${cell_id}
    syscom_keywords.Validate Cellsetupreq Pcap
    ...    txt_syscom_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/itf_l2_ps_cell_cellsetupreq.txt
    ...    syscom_validation_template_path=${syscom_validation_path}
    common_wts.Start Collecting Ueapp Sosreport

Test Teardown
    [Arguments]    ${carrier_aggregation}=${False}    ${mu_mimo}=${False}
    Log    \nStart teardown    console=True
    common_keywords.Stop Collecting Syslog
    common_gnb.Collect SCF File
    ...    final_path=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/modified_scf.xml
    Run Keyword If Test Passed    common_gnb.Collect Gnb Snapshot
    ...    output_filepath=${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/snapshot.zip
    Run Keyword If Test Failed    common_wts.Stop Collecting Ueapp Sosreport
    ...    destination_path_for_sosreport=${OUTPUT_DIR}/${SUITE_NAME}/${TEST_NAME}
    common_gnb.Assert BTS In State
    ...    bts_state=OnAir
    common_wts.Stop WTS And Clear
    Run Keyword If  ${mu_mimo} == ${True} or ${carrier_aggregation} == ${True}  common_airphone.Upload Default Iphy File
    ...    default_iphy_filepath=${DEFAULT_IPHY_PATH}
    ...    site_reset=${False}
    common_gnb.Perform gNB Commissioning
    ...    scf_file=${OUTPUT_DIR}/${SUITE_NAME}/default_scf.xml
    common_gnb.Wait For All Radio Modules To Be Online

Perform Online Parameter Change
    Log To Console    Online Parameter Change
    common_gnb.Perform Recomissioning With Delta
    ...    path_to_delta=${DELTA_TC17_ONLINE_CHANGE}
    common_gnb.Assert Bts In State
    ...    bts_state=onair

Wait For PM Counters From Full Period With Traffic To Appear In WebEM
    Log to console    Wait for full PM interval with traffic to start
    ta5g_pm_counters.Wait For Next Full Pm Interval
    Log to console    Wait for full PM interval with traffic to end
    ta5g_pm_counters.Wait For Next Full Pm Interval

Collect TTI Traces Sample
    [Arguments]    ${cell_ids}=${CELL_IDS_1}    ${filename}=tti_trace.pcap
    Start TTI Trace Collection
    ...    cell_ids=${cell_ids}
    Wait For TTI Sample
    Stop TTI Trace Collection
    Relocate TTI Traces Collected
    Move File
    ...    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/tcpdump.pcap
    ...    ${OUTPUT_DIR}/${SUITE_NAME}/${TEST NAME}/${filename}

Wait For NSA Cells Readiness
    Log    Wait For NSA Cells Readiness   console=True
    BuiltIn.Sleep    10s

Wait For TTI Sample
    Log    Wait For TTI Sample   console=True
    BuiltIn.Sleep    2s
