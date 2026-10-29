*** Settings ***
Resource    ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource    ../resources/common_variables.robot
Resource     ../CB008379_GBR_Services_for_SA/keywords_CB008379.robot
Resource     keywords_CB008379_AiC.robot
Resource     ../resources/common_configuration.robot

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 24R3

Suite Setup     Run Keywords    Enable AiC ActPdcpRlcBufCongestionMechsm
    ...       AND    Configure SA VM interfaces AiC
    ...       AND    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SA_FDD_AIC}
    ...       AND    Enable AiC Vonr And Rohc
    ...       AND    Enable AiC ActNonVoNRGbrService
    ...       AND    Add AiC Profiles For GBR 5QI
    ...       AND    Enable AiC ActPrioNonVoNRGBRTraffic
    ...       AND    Disable AiC Uplane Ciphering
    ...       AND    Set Internal Traffic Type To UEs

Test Teardown     Run Keywords    Deregister Ue   ue_id=1
    ...        AND    Sleep    5s    Waiting for deregister

*** Variables ***
${TRAFFIC_DURATION_SEC}=   30s

*** Test Cases ***
CB008379-F_B3_1_PDCP_prioritisation_of_GBR_DRB_5QI3_over_non_GBR_DRB_Cloud
    Attach AiC Ue With Gbr Um 5QI 3
    Start 180Mbps In Dl For Non Gbr Bearer
    Sleep    60s   Waiting for packets buffering
    Check Non Gbr Traffic Statistic        expected_throughput_mbps=180
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Check Non Gbr Traffic Statistic    expected_throughput_mbps=150

CB008379-F_B3_2_PDCP_prioritisation_of_GBR_DRB_5QI4_over_non_GBR_DRB_Cloud
    Attach AiC Ue With Gbr Am 5QI 4
    Start 180Mbps In Dl For Non Gbr Bearer
    Sleep    60s   Waiting for packets buffering
    Check Non Gbr Traffic Statistic        expected_throughput_mbps=180
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Check Non Gbr Traffic Statistic    expected_throughput_mbps=150

*** Keywords ***
Start 180Mbps In Dl For Non Gbr Bearer
    Execute Egate Command    cmd=sim_debug_log level=6
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=100 trf_id=1
    Execute Egate Command    cmd=trf_data_start ue=1 pdu=1 qfi=1 dir=dl mbps=80 trf_id=2

Enable AiC ActPdcpRlcBufCongestionMechsm
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_enable_ActPdcpRlcBufCongestionMechsm_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_enable_ActPdcpRlcBufCongestionMechsm_DU.json
    Sleep    180s
