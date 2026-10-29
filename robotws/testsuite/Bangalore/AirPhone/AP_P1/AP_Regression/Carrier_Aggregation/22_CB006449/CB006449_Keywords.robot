*** Settings ***
Documentation   Keywords for CB006449 feature
Resource        ../CA_Common_Keywords.robot
Resource        ../4CC_Common_Keywords.robot


*** Variables ***
&{blind_addition}                            sCellAdditionMethod=blind
&{blind_activation}                          sCellActivationMethod=blind
&{Deactivation_Timer_infinity}               sCellDeactivationTimerGNB=infinity
&{bufferBased_Activation}                    sCellActivationMethod=bufferBased
&{bufferAndRLQualityBased_Activation}        sCellActivationMethod=bufferAndRLQualityBased
&{covBasedA1_Addition}                       sCellAdditionMethod=covBasedA1
&{Deactivation_Timer}                        sCellDeactivationTimerGNB=ms1280
@{scell_act_index_list}                      1
${interrat_gnb_delta_json}                   ${CURDIR}/cfg/6449_buffer_delta.json

*** Keywords ***
Test Setup for CB006449
    [Documentation]
    [Arguments]    ${Gnb_Commissioning}=False
    Recommission GNB With Delta    delta_file=${interrat_gnb_delta_json}    should_activate=${True}
    Wait Until Keyword Succeeds     2min     30sec     Check if gNB is reachable    ${GNB_IP}
    Test Setup    Gnb_Commissioning=${Gnb_Commissioning}
