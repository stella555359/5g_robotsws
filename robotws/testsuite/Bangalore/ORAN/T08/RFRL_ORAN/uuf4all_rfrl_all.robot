*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Sreekumar Narimuri Kumaran
...                 Contact: sreekumar.narimuri_kumaran@nokia.com

Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library	            taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library	            DownloadPassBuilds.py
Library             taf.sbts.oam.coam.admin    WITH NAME    admin
Library             BuiltIn
Library             Collections
Library    taf.collectors.btslog  WITH NAME   btslog
Library    taf.collectors.core   WITH NAME   core
Library    taf.collectors.tcpdump    WITH NAME    tcpdump
Library    taf.collectors.tshark    WITH NAME    tshark
Library    taf.transport.ssh    WITH NAME    ssh
Library    taf.ue    WITH NAME    ue
Library    taf.hw.pdu    WITH NAME    pdu
Library    taf.ul.alarms_watchdog
Library    taf.analyzer.netconf
Library    taf.collectors.simple    WITH NAME    simple
Library    taf.fdsw.rc     WITH NAME    rc
Library    taf.sw.dcap.rd   WITH NAME   rd
Library    testsuite/Bangalore/ORAN/resources/python/ta_ultracaller/
Library    taf.sw.scout    WITH NAME    scout
Library    taf.nms.netact  WITH NAME    netact
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/Topyoung_Attenuator_T08.robot
Resource    testsuite/Bangalore/ORAN/T08/resources/robot/CommonKeywordResourceFile.robot
Resource	testsuite/Bangalore/ORAN/T08/resources/robot/Reporting_Portal_Keywords.robot

Suite Setup    Run Keywords      UTE_ORAN_TL_Bringup_Precondition
...    AND    Check fault 23 and fix
...    AND    Wait Until BTS is OnAir
...    AND    Set export yml    ${VM_IP}
...    AND    Copy swconfig to BTS    ${swconfig_path}
...    AND    Suite Setup

*** Variables ***
@{CUSTOM_ALARMS}=               4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  8000  4647
@{critical_alarms}=             10  6450  4383  4590  1868  1900  30  4681  1806  4383
${ITERATIONS_sw}                   3
${QC_REPORT}                    ${True}
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${RP_CA}                        VRF_ORAN
${RP_LOCATION}                  VRF_BLR1
${RP_ORGANIZATION}              VRF_BLR1_T08
@{CUSTOMERS_LIST}=              TEST
${DOWNLOAD_PATH}=               /home/ute/
&{NODE1}                         node_vm=10.58.238.125
...                             source_sw=
...                             target_sw=
...                             temporary_allowed_alarms=${1234, 2345}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
${report}                       ${True}
@{NODES}                        ${NODE1}
${ITERATIONS_reset}             20
${local_ip}                     192.168.255.129
${BTS_URL}      https://192.168.255.129
${username}     Nemuadmin
${password}     nemuuser
${VM_IP}     10.58.238.125
${pva_ip}    10.45.153.212
${pva_vendor}    TOPYOUNG
${pva_model}	 TAS16T16-51-120-1N-DEJS
${scf_ofegsa_only}=   /home/ute/testline_configuration/7_2_UTE5GCLOUD1024/node1/SCF_MRBTS_1024_OFEGSA_ONLY.xml
${swconfig_path}=     testsuite/Bangalore/ORAN/T08/resources/config/swconfig.txt


*** Test Cases ***
E2E_TL_SW_Upgrade_Rollback_with_OAM_KPI_single_node_upgrade
    [Timeout]   24h
    Admin_Connection
    Set Test Variable  ${ALARM_TIMEOUT}  180
    Set Test Variable  ${HARDWARE_CHECK_TIMEOUT}  900
    Set Test Variable  @{SYSLOG_IGNORED_PRINTS}  INF
    e2e_tl_sw_upgrade_rollback_with_oam_kpi
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS_sw}
    ...          report=${report}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          use_dcap=${False}
    ...          download_path=${DOWNLOAD_PATH}
    ...          qc_domain=MN_RAN
    ...          qc_id=274263
    ...          qc_project=RAN_VRF
    ...          report=${report}


E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL ACTIVATION RESET TEST
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS_reset}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${report}
    ...          qc_domain=MN_RAN
    ...          qc_id=274269
    ...          qc_project=RAN_VRF
    ...          report=${report}


E2E_TL_Site_Reset_with_OAM_KPI
    [Timeout]   24h
    E2E TL SITE RESET WITH OAM KPI
    ...          nodes_details=${NODES}
    ...          test_nodes_details=${NODE1}
    ...          iterations_per_node=${ITERATIONS_reset}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          report=${report}
    ...          qc_domain=MN_RAN
    ...          qc_id=274268
    ...          qc_project=RAN_VRF
    ...          report=${report}


E2E_TL_RU_Reset_with_OAM_KPI
    [Timeout]    64h
    Set Test Variable    &{OAM_KPI_TARGETS}    kpi51a=200    kpi51b=200
    CSV4AllTestCases.e2e_tl_ru_reset_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=10
    ...    customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_id=274262
    ...          qc_project=RAN_VRF
    ...          report=${report}


E2E_TL_Cell_Lock_Unlock_NR_with_OAM_KPI
    [Timeout]    64h
    Set Test Variable    &{OAM_KPI_TARGETS}    kpi16a=35    kpi16b=35
    CSV4AllTestCases.e2e_tl_cell_lock_unlock_nr_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=10
    ...    customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_id=274264
    ...          qc_project=RAN_VRF
    ...          report=${report}


E2E_TL_Cell_Block_Unblock_NR_with_OAM_KPI
    [Timeout]    64h
    Set Test Variable    &{OAM_KPI_TARGETS}    kpi17a=20    kpi17b=20
    CSV4AllTestCases.e2e_tl_cell_block_unblock_nr_with_oam_kpi
    ...    nodes_details=${nodes}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=10
    ...    customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=MN_RAN
    ...          qc_id=274266
    ...          qc_project=RAN_VRF
    ...          report=${report}

E2E_TL_Cell_Lock_Unlock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${nodes}  ${NODE1}
    ...          iterations_per_node=10
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=274265
    ...          qc_project=${QC_PROJECT}
    ...          report=${report}


E2E_TL_Cell_Block_Unblock_LTE_with_OAM_KPI
    [Timeout]   24h
    E2E TL CELL LOCK UNLOCK LTE WITH OAM KPI    ${nodes}  ${NODE1}
    ...          iterations_per_node=10
    ...          report=${report}
    ...          customers_list=${CUSTOMERS_LIST}
    ...          qc_domain=${QC_DOMAIN}
    ...          qc_id=274267
    ...          qc_project=${QC_PROJECT}


***Keywords***

Admin_Connection
    Log To Console    making admin connection to BTS
    admin.setup_admin     bts_host=${local_ip}    alias=nom
    Fetch_curr_sw_version
    Log To Console    teardown of admin connection
    admin.teardown    nom

Fetch_curr_sw_version
    Log to console      !-------fetching current sw version-------!
    ${current_sw_version_raw}=      admin.get sw version     connection=nom
	${5G_SOURCE_SW}=	replace_sbts_version_prefix_to_sbts00    ${current_sw_version_raw}
	${5G_TARGET_SW}=	return_target_build_to_rfrl		${5G_SOURCE_SW}
	${NODE1}    Set To Dictionary    ${NODE1}    source_sw=${5G_SOURCE_SW}    target_sw=${5G_TARGET_SW}
	set global variable		${NODE1}

Suite Setup
    Log to console    \n--Suite Setup--\n
    Open_Admin_Connection
    SCF commissioning    ${scf_ofegsa_only}	  600   suite_oam
    Wait Until BTS is OnAir
    ${SUITE_PATH}    set variable    ${OUTPUT_DIR}/
    Set Suite Variable    ${SUITE_PATH}
    log to console    .....--Precondition--.....
    Close_Admin_Connection


Open_Admin_Connection
    Log To Console    connecting to BTS
    admin.teardown_all_aliases_for_admin
    admin.Setup_Admin    bts_host=192.168.255.129    alias=suite_oam

Close_Admin_Connection
    admin.teardown    suite_oam
    Log To Console    BTS IS Disconnected