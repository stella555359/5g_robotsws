*** Settings ***
Resource    ../test_resources/FM__Check_RU_restart_indication_is_sent_to_OAM_4527_BTS_fault.robot

*** Test Cases ***
FM__Check_RU_restart_indication_is_sent_to_OAM_4527_BTS_fault
    [Setup]    TC Setup
    [Teardown]    TC Teardown
    TC__FM__Check_RU_restart_indication_is_sent_to_OAM_4527_BTS_fault

