*** Settings ***
Documentation
...    Test suite for regression testing for feature CB009493
...    authors: Wioleta Swies
...    maintainer: wioleta.swies@nokia.com
...    group: RAN_PZ_KRK_SG_7
...    contact: wioleta.swies@nokia.com

Resource    ./resources/keywords.robot

Suite Setup      Run Keywords    Common Suite Setup With Commissioning      asir_hub=${True}    AND
...                              gnbbbu.Upload Swconfig
...                              sw_config_path=commissionings/Krakow/swconfig/default_swconfig.txt

Suite Teardown    Common Suite Teardown

Test Setup       Common Preconditions With Watching Alarms
Test Teardown    Common Postconditions With Watching Alarms

*** Variables ***
${BBMOD_RESET_TEST_ITERATION}=      70
@{CUSTOM_ALARMS}=                   61648    7115    4420    4123    4125    8150    4459    4479
@{CRITICAL_FAULTS}=                 10  1806  16  4341  4383  4352  1868  69

&{NODE1}                            testline_object=${tl.gnbs[0]}
...                                 custom_allowed_alarms=${CUSTOM_ALARMS}

@{NODES}                            ${NODE1}

@{CUSTOMERS_LIST}                   Generic
${QC_DOMAIN}                        MN_RAN
${QC_PROJECT}                       RAN_VRF

${RP_CA}                            VRF_OAM
${RP_ORGANIZATION}                  VRF_KRK_T07
${RP_LOCATION}                      VRF_KRK


*** Test Cases ***
Call_NR_Cell_on_pRRH_Reset_APHG
    Set Test Variable    ${expected_tput_NR_DL}    658Mbits/sec
    Set Test Variable    ${expected_tput_NR_UL}    75Mbits/sec
    Run Keyword And Ignore Error    Check data transfer via Quectel with APHG Reset
    ...                                     throughput_DL=${expected_tput_NR_DL}
    ...                                     throughput_UL=${expected_tput_NR_UL}

BTS_Site_Reset
    Reset gNB
    Wait Until Keyword Succeeds    600 sec    5 sec   gnbcell.Verify All Cells Are Onair
    Wait Until Keyword Succeeds    900 sec    5 sec   Verify gNB is onAir

RU_Reset_Lock_Unlock
    [Setup]    Run Keywords    Set Test Variable    @{CUSTOM_ALLOWED_ALARMS}    Transmission path failure    AND
    ...                        Common Preconditions With Watching Alarms
    FOR    ${i}    IN RANGE    5
           BuiltIn.Log To Console    ${i} iterations
           gnbru.Reset All Radio Unit    timeout=180
           Sleep    20s
           Wait Until Keyword Succeeds    600 sec    5 sec   gnbcell.Verify All Cells Are Onair
           Wait Until Keyword Succeeds    900 sec    5 sec   Verify gNB is onAir
           gnbru.Lock All Radio Unit
           Sleep    20s
           gnbru.Verify Radio Unit Is Locked
           gnbru.Unlock All Radio Unit
           Wait Until Keyword Succeeds    600 sec    5 sec   gnbcell.Verify All Cells Are Onair
           Wait Until Keyword Succeeds    900 sec    5 sec   Verify gNB is onAir
    END

BBMOD_Multiple_Reset
    E2E TL CAPACITY MODULE RESET WITH OAM KPI
    ...                                     nodes_details=${NODES}
    ...                                     test_nodes_details=${NODE1}
    ...                                     iterations_per_node=${BBMOD_RESET_TEST_ITERATION}
    ...                                     report=${False}
