# # #*** Settings ***
# # #Resource   ../Resources/5GC001726_keywords_cobham.robot
# # #
# # #
# # #Documentation    Suite description
# # #...   author: Wang Yixiang
# # #...   contact: yixiang.x.wang@nokia-sbell.com
# # #...   squad group: MMW_SG1
# # #...   Feature 1726 in 5G19B program
# # #
# # #Force Tags    5G_RRM      
# # #
# # #Suite Setup    Suite preparation
# # #Suite Teardown    run keyword and ignore error     5GC001726_keywords.Common Suite Teardown
# # #
# # #*** Test Cases ***
# # #[1]5GC001726_GF_601_GNB-5CCDL_1CCUL_maxScell4DL0UL_contiguous_UE5DL1UL_1UE_enhanced_csi-rs configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when contiguous frequency 5CC DL and 1CC UL with a
# ...nalog beamforming in mmW band
# # s
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_8CC_CC0_CC7_5DL_1UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_602_GNB-5CCDL_2CCUL_maxScell4DL1UL_non-contiguous_UE5DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
# # #    ...    5CC DL and 2CC UL with analog beamforming in mmW bands
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_1_1_3_5DL_2UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_603_GNB-6CCDL_1CCUL_maxScell5DL0UL_contiguous_UE6DL1UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when contiguous frequency 6CC DL and 1CC UL with a
# ...nalog beamforming in mmW band
# # s
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_8CC_CC0_CC7_6DL_1UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_604_GNB-6CCDL_2CCUL_maxScell5DL1UL_non-contiguous_UE6DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
# # #    ...    6CC DL and 2CC UL with analog beamforming in mmW bands
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_2_2_2_6DL_2UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_605_GNB-7CCDL_1CCUL_maxScell6DL0UL_contiguous_UE7DL1UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when contiguous frequency 7CC DL and 1CC UL with a
# ...nalog beamforming in mmW band
# # s
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_8CC_CC0_CC7_7DL_1UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_606_GNB-7CCDL_2CCUL_maxScell6DL1UL_non-contiguous_UE7DL2UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
# # #    ...    7CC DL and 2CC UL with analog beamforming in mmW bands
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_1_3_3_7DL_2UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_607_GNB-8CCDL_1CCUL_maxScell7DL0UL_contiguous_UE8DL1UL_1UE_enhanced_csi-rs_configure_and_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when non-contiguous frequency
# # #    ...    7CC DL and 2CC UL with analog beamforming in mmW bands
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_8CC_C14_CC21_8DL_1UL}
# # #    Cobham attach UE and start traffic    e500_script_path=${E500_SCRIPTS_BASE}    dl_tput_size=50    ul_tput_size=20
# # #    ...    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7,8
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown
# # #
# # #[1]5GC001726_GF_609_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_UE8DL2UL_11UE_same_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when multi-UE with same simultaneousCSI-ReportsAllCC value
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_CON_8CC_CC0_CC7_8DL_2UL}
# # #    Cobham multiple UEs attach and start traffic    number_of_ue=${NUMBER_OF_UE}    iperf_ul_port_list=${IPERF_UL_PORT_LIST}
# # #    ...    dl_tput_size=30    ul_tput_size=20    e500_script_path=${E500_SCRIPTS_MULTI_UE}    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7,8    multi_ue=${True}
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown multi-UE
# # #
# # #[1]5GC001726_GF_610_GNB-8CCDL_2CCUL_maxScell7DL1UL_contiguous_UE7DL2UL_11UE_diferent_simultaneousCSI-ReportsAllCC
# # #    [Tags]
# # #    [Documentation]    author: Wang Yixiang
# # #    ...    Verify enhanced CSI configuration and reporting support when multi-UE with different simultaneousCSI-ReportsAllCC value
# # #    [Setup]    Case preparation    scf_paras_via_api=${MODIFY_VIA_API_NON_CON_8CC_1_1_3_3_8DL_2UL}
# # #    Cobham multiple UEs attach and start traffic    number_of_ue=${NUMBER_OF_UE}    iperf_ul_port_list=${IPERF_UL_PORT_LIST}
# # #    ...    dl_tput_size=30    ul_tput_size=20    e500_script_path=${E500_SCRIPTS_MULTI_UE}    dl_bler_threshold=${EXPECTED_BLER}
# # #    Capture log and verify CSI-ReportsAllCC and DL HARQ feedback success anb bler    cell_id=1,2,3,4,5,6,7,8    multi_ue=${True}
# # #    [Teardown]     Run Keyword And Ignore Error    Cobham Common Test Teardown multi-UE
# # #
# # #
# # #*** Keywords ***
# # #Case preparation
# # #    [Documentation]  Author: Wang Yixiang
# # #    ...              Description: Case preparation
# # #    [Arguments]      ${scf_paras_via_api}
# # #    COAM Create log directory
# # #    Connect to gnb coam via ssl
# # #    Connect to Common Unit Master    alias=ASIK Master
# # #    Connect to Common Unit Slave     alias=ASIK Slave
# # #    COAM Update several parameters via rest api    parameters_to_update_via_api=${scf_paras_via_api}
# # #    ...    timeout=${TIMEOUT_REST_API_RESTART}
# # #    COAM Wait for gnb ready and cell setup    timeout=60 sec
# # #
# # #Cobham multiple UEs attach and start traffic
# # #    [Documentation]    Author: Wang Yixiang
# # #    ...    This keyword is to perform tm500 attach for multiple UEs and return with their IP addresses.
# # #    ...    ${number_of_ue} specify the number of UEs.
# # #    ...    Each UE attach will attempt for ${retry_time}, if one of them fail to attach after retry times, this keyword will fail.
# # #    ...    ${UE_IP_LIST} contains all UEs' IP addresses, and will be set as TEST varilble after all UEs attach successfully.
# # #    [Arguments]    ${number_of_ue}    ${iperf_ul_port_list}    ${dl_tput_size}=10    ${ul_tput_size}=10
# # #    ...    ${e500_script_path}=${E500_SCRIPTS_MULTI_UE}    ${retry_time}=${10}    ${e500_alias}=${TMA_APP_ALIAS}
# # #    ...    ${dl_bler_threshold}=${None}
# # #    ${UE_IP_LIST}    create list
# # #    Cobham connection and start logging    e500_script_path=${e500_script_path}    connection=${TMA_SSH_ALIAS}
# # #    connection_alias_store.Connect to Common Unit Master     alias=ASIK Master
# # #    wait until keyword succeeds    2 min    10 s    Connect to cobham control pc via ssh    tma_ssh_alias=${TMA_SSH_ALIAS}
# # #    Synchron gNB and cobham    alias=ASIK Master
# # #    sleep    10s
# # #    tm500.Perform cell search    cell_search_script_path=${e500_script_path}/NSA_5G_Cell_Config.txt    tm500_alias=${TMA_APP_ALIAS}
# # #
# # #    Switch pcell for attach based on cell index    cell_index_for_attach=${PCELL_INDEX[0]}
# # #    :For    ${i}    IN RANGE    ${number_of_ue}
# # #    \    run keyword if    '${i}'=='6'   Switch pcell for attach based on cell index    cell_index_for_attach=${PCELL_INDEX[1]}
# # #    \    Cobham retry ue attach if failed    e500_script_path=${e500_script_path}/script_ue${i}    retry_time=${retry_time}
# # #        ...    e500_alias=${e500_alias}
# # #    \    append to list    ${UE_IP_LIST}    ${UE_IP}
# # #
# # #    Iperf send DL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${10}    traffic_time=${99999}
# # #    ...    dl_port=${IPERF_DL_PORT}    dl_host_ip_list=${UE_IP_LIST}
# # #    Iperf send UL traffic with real epc for multiple UEs    number_of_ue=${number_of_ue}    throughput=${10}    traffic_time=${99999}
# # #    ...    ul_port_list=${IPERF_UL_PORT_LIST}
# # #
# # #    Sleep   2 s
# # #
# # #    :For    ${ue_idx}    IN RANGE    0    ${number_of_ue}
# # #    \   wait until keyword succeeds    1 min    3s   Evaluate throughput for DL data transfer    dl_data_transfer_exp=${1}
# # #        ...    ue_index=${ue_idx}
# # #    \   run keyword and continue on failure    Evaluate throughput for UL data transfer    ul_data_transfer_exp=${1}
# # #
# # #    run keyword if    ${dl_bler_threshold}!=${None}
# # #    ...    Cobham check multiple UEs DL bler    number_of_ue=${number_of_ue}    dl_bler_threshold=${dl_bler_threshold}
# # #
# # #
