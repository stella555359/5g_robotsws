*** Settings ***
Resource    ../resources/common_keywords.robot
Resource     ../resources/common_keywords_vran.robot
Resource    ../resources/common_variables.robot
Resource     ../CB008379_GBR_Services_for_SA/keywords_CB008379.robot
Resource     keywords_CB008379_AiC.robot
Resource     ../resources/common_configuration.robot
Library     keywords_CB008379_AiC.py

Documentation
...    author: Marcin Kotuła
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    testline: CLOUD_5GC_dRNIC_1vDU_P_AP_LO_DC
...    release: 24R3

Suite Setup     Run Keywords    Configure SA VM interfaces AiC
    ...       AND    Reach OnAir AiC    lua_cfg=${EPCSIM_CFG_PATH_SANSA_TDD_FDD_AIC}
    ...       AND    Enable AiC Vonr And Rohc
    ...       AND    Enable AiC ActNonVoNRGbrService
    ...       AND    Add AiC Profiles For GBR 5QI
    ...       AND    Enable AiC ActPrioNonVoNRGBRTraffic
    ...       AND    Disable AiC Uplane Ciphering
    ...       AND    Set AiC Discard Timer To 100ms For Gbr

Test Setup     Run Keywords    Prepare Bler Testmode For Bad Rf Condition Target Mcs 3
    ...       AND    Set Internal Traffic Type To UEs
    ...       AND    Wait For Next PM counters Interval

Test Teardown     Run Keywords    Deregister Ue    ue_id=1
    ...        AND    Sleep    5s    Waiting for deregister

*** Test Cases ***
CB008379-F_B2_1_PDCP_discard_GBR_DRB_5QI3_using_18_bit_PDCP_SN_Cloud
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN}
    Attach AiC Ue With Gbr Um 5QI 3
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Deteriorate Rf Condition
    Wait For Next PM counters Interval
    Check AiC Pm Counters For Timer Discarding And Pdcp Packet Delay
    Improve Rf Condition
    Check Traffic Statistic

CB008379-F_B2_2_PDCP_discard_GBR_DRB_5QI4_using_18_bit_PDCP_SN_Cloud
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_WITHOUT_SHORT_PDCP_SN}
    Attach AiC Ue With Gbr Am 5QI 4
    Start 30Mbps In Dl and Ul For Gbr
    Check Traffic Statistic
    Deteriorate Rf Condition
    Wait For Next PM counters Interval
    Check AiC Pm Counters For Timer Discarding And Pdcp Packet Delay
    Improve Rf Condition
    Check Traffic Statistic

*** Keywords ***
Set AiC Discard Timer To 100ms For Gbr
    Perform CU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_set_discardTimer_to_100ms_for_GBR_CU.json
    Perform DU Delta Commissioning    ${DELTA_FILES_PATH_AIC}/GBR/delta_set_discardTimer_to_100ms_for_GBR_DU.json
