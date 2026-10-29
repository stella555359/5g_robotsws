*** Settings ***
Resource    ../resources/common_keywords.robot
Resource    keywords_CB008159.robot
Library     keywords_CB008159.py

Documentation
...    author: Marek Niescioruk
...    maintainer: Marcin Kotuła (marcin.kotula@nokia.com)
...    release: 23R4

*** Variables ***
${TRAFFIC_DURATION_SEC_C4}=   12s

*** Keywords ***
CB008159-C-4_The_Cumulative_Time_Qos_With_Flow_5qi1_5qi2_And_5qi6_In_Session_With_Pmqap_Profiles_Activated
    Execute Egate Command    cmd=ue_param id=1 ue_nr_capabilities=${UE_CAPA_SUPPORTING_ROHC}
    Execute Egate Command    cmd=ue_change_location id=2 cell=2
    Register Ue With Default Pdu Session
    Register Ue With Default Pdu Session    ue_id=2
    Add Qos To Ue    ue_id=1    qos_to_add=2, 3
    Start Collect Gpt Message
    Start Data Traffic And Increment Insession Time    ue_id=1    qfi_id=3    direction=dl    duration=10s
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=1    qfi_id=3
    ta5g_ue_mobility.Deregister Ue    ue_id=1
    Start Data Traffic And Increment Insession Time    ue_id=2    qfi_id=1    direction=dl    duration=10s
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=2    qfi_id=1
    ta5g_ue_mobility.Deregister Ue    ue_id=2
    Register Ue With Default Pdu Session
    Add Qos To Ue    ue_id=1    qos_to_add=3, 4
    Start Data Traffic And Increment Insession Time    ue_id=1    qfi_id=2    direction=ul    duration=10s
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Display Qfi stats    ue_id=1    qfi_id=2
    ta5g_ue_mobility.Deregister Ue    ue_id=1    pass_regexp=UE1: detached
    Execute Egate Command    cmd=ue_change_location id=1 cell=2
    Register Ue With Default Pdu Session
    Start Data Traffic And Increment Insession Time    ue_id=1    qfi_id=1    direction=ul    duration=10s
    BuiltIn.Sleep    ${TRAFFIC_DURATION_SEC_C4}
    Stop Collect Gpt Message
    Display Qfi stats    ue_id=1    qfi_id=1
    ta5g_ue_mobility.Deregister Ue    ue_id=1
    Verify If Qos Flow Duration PMQAP Counters Were Incremented
