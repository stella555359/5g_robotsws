*** Settings ***
Documentation       Test suite for basic CSV4ALL Tests in loop
...                 Author: Sreekumar Narimuri Kumaran
...                 Contact: sreekumar.narimuri_kumaran@nokia.com

#Test Setup          Admin_Connection
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Library	            taf/rfrl/uuf4all/resources/python/uuf_rfrl_update.py
Library	            DownloadPassBuilds.py
Library             taf.gnb.oam.coam.admin    WITH NAME    admin
Library             BuiltIn
Library             Collections

*** Variables ***
@{CUSTOM_ALARMS}=               4298  4694  6150  6351  7509  7513  8150  61631  4527  7307  62003  6450  7115  8000
${ITERATIONS_sw}                   3
${QC_REPORT}                    ${True}
${QC_DOMAIN}=                   MN_RAN
${QC_PROJECT}=                  RAN_VRF
${RP_CA}                        VRF_RRM
${RP_LOCATION}                  VRF_BLR1
${RP_ORGANIZATION}              VRF_BLR1_T08
@{CUSTOMERS_LIST}=              TEST
${DOWNLOAD_PATH}=               /home/ute/
&{NODE1}                         node_vm=10.58.238.143
...                             source_sw=
...                             target_sw=
...                             temporary_allowed_alarms=${1234, 2345}
...                             custom_allowed_alarms=${CUSTOM_ALARMS}
${report}                       ${True}
@{NODES}                        ${NODE1}
${ITERATIONS_reset}                   20
${local_ip}                     192.168.255.129
${BTS_URL}      https://192.168.255.129
${username}     Nemuadmin
${password}     nemuuser

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
    ...          qc_id=605448
    ...          qc_project=RAN_VRF
    ...          report=${report}

E2E_TL_Site_Reset_without_HWF_with_OAM_KPI
    [Timeout]   24h
    Set Test Variable  &{OAM_KPI_TARGETS}     kpi1a=300    kpi1b=300    kpi1c=300
    CSV4AllTestCases.e2e_tl_site_reset_without_hwf_with_oam_kpi
    ...    nodes_details=${NODES}
    ...    test_nodes_details=${NODE1}
    ...    iterations_per_node=${ITERATIONS_reset}
    ...    customers_list=${CUSTOMERS_LIST}
    ...    qc_domain=MN_RAN
    ...    qc_id=605447
    ...    qc_project=RAN_VRF
    ...    report=${report}

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