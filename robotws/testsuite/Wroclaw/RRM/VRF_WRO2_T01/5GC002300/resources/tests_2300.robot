*** Settings ***
Documentation
...  author:        Pawel Wisniewski
...  contact:       pawel.1.wisniewski@nokia.com
...  maintainer:    pawel.1.wisniewski@nokia.com
...  Description:   Test cases have been refactored to single one due to TMO CVR program recomendations.
...                 Test scenario was introduced in a mail discussion and here is a snapshot:
...                 5GC002300_TMO_CVR_001
...                 verfify counters for 1329 are present after activation	Test with AEHC or AVHA on either ABIO or ABIP TMO Configurations
...             	5GC002052_TMO_CVR_001
...                 first activate 1329 , then implement  6dB Power Reduction factor, and observe reduction in reported coutners.
...                 Test with AEHC or AVHA on either ABIO or ABIP TMO Configurations
...                 5GC001329	EIRP monitor	5GC001329_TMO_CVR_001
...                 verfify counters for 1329 are present after activation.
...                 ( Name: ACTUAL_TX_POWER_BEAM_<0÷63>)

Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/5GC002300/resources/keywords.robot
Resource        testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/multi_ue.robot
Library         testsuite/Wroclaw/RRM/VRF_WRO2_T01/resources/webem_operations.py

*** Variables ***
@{ues}              ue1
${ue_capability}    RFCX51BXKLV
${tput_duration}    10m

*** Keywords ***
[1]5GC002300_5GC002052_5GC001329_EIRP_TMO_CVR
    [Documentation]    Scenario was prepared basing on TMO 25R3 CVR avtion. 5GC002300	Actual EIRP control extension.
    ...    5GC002300_TMO_CVR_001
    ...    verfify counters for 1329 are present after activation	Test with AEHC or AVHA on either ABIO or ABIP TMO Configurations
    ...    5GC002052	EIRP control	5GC002052_TMO_CVR_001
    ...    first activate 1329 , then implement  6dB Power Reduction factor, and observe reduction in reported coutners.
    ...    Test with AEHC or AVHA on either ABIO or ABIP TMO Configurations
    ...    5GC001329	EIRP monitor	5GC001329_TMO_CVR_001	verfify counters for 1329 are present after activation.
    ...    ( Name: ACTUAL_TX_POWER_BEAM_<0÷63>)
    ...    Target topology -> CLOUD_5G_CLASSICAL_ANDROID_ATT_ASILL_ABILB1B2B3_3xAEQN_FRGU -> T177

    # Scenario
    # 5GC001329 part
    Activate 5GC001329 feature
    Wait for eirp counters
    Check 5GC001329 counters are present after activation
    Check EIRP beamset_6 counter incrementation
#    # 5GC002052 part
    Get UEs    ${ues}    ${ue_capability}
    detach ues from cell    ${ues}
    attach ues to cell      ${ues}
    Start DL for UEs    ${ues}    duration=${tput_duration}
    # Wait two interval, to get maximum counter value
    sleep  ${tput_duration}
    stop all datatransfers
    detach ues from cell    ${ues}

    Check Cell Power Counter with no power reduction
    Activate 6dB power reduction

    attach ues to cell      ${ues}
    Start DL for UEs    ${ues}    duration=${tput_duration}
    # Wait two interval, to get maximum counter value
    sleep  ${tput_duration}
    stop all datatransfers
    detach ues from cell    ${ues}

    Check 5GC001329 counters after power reduction
#    # 5GC002300 part
    Activate 5GC002300 feature
    Wait for eirp counters

    Check 5GC001329 counters after 5GC002300 activation
