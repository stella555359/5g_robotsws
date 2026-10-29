*** Settings ***
Documentation    OAM operation keywords for AirPhone tests:
...              lock/unlock (cell, RMOD, AMF, lane),
...              resets (RU, BBMOD, site)

Resource        suite_common_keywords.robot
Resource        ue_operations.robot
Resource        gnb.robot

*** Variables ***
${sib_validation}               True

*** Keyword ***
Perform Cell Lock Unlock With Validation
    [Documentation]    Perform cell Lock/Unlock operation with alarm checking and SIB validation
    [Arguments]    ${previous_fault_dict}    ${iteration_index}
    Execute Egate Command    going to do CELL LOCK UNLOCK
    Perform NR Cell Lock and Unlock
    Sleep    60s
    ${fault_dict_after_cell_lock}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_cell_lock}
    Return From Keyword If    '${sib_validation}' == 'False'    ${fault_dict_after_cell_lock}
    ${expected_count}=    Evaluate    ${iteration_index} + 2
    Run Keyword And Continue On Failure    Check All SystemInformationBlockType Updates    expected_sib_count=${expected_count}
    [Return]    ${fault_dict_after_cell_lock}

Perform RMOD Lock Unlock With Validation
    [Documentation]    Perform RMOD Lock/Unlock operation with alarm checking and SIB validation
    [Arguments]    ${previous_fault_dict}    ${iteration_index}
    Execute Egate Command    going to do RU LOCK UNLOCK
    Perform RMOD lock Unlock operation
    Sleep    60s
    ${fault_dict_after_rmod_lock}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_rmod_lock}
    Return From Keyword If    '${sib_validation}' == 'False'     ${fault_dict_after_rmod_lock}
    ${expected_count}=    Evaluate    ${iteration_index} + 3
    Run Keyword And Continue On Failure    Check All SystemInformationBlockType Updates    expected_sib_count=${expected_count}
    [Return]    ${fault_dict_after_rmod_lock}

Perform AMF Lock Unlock With Validation
    [Documentation]    Perform AMF Lock/Unlock operation with alarm checking and SIB validation
    [Arguments]    ${previous_fault_dict}    ${iteration_index}
    Execute Egate Command    going to do AMF LOCK UNLOCK
    Perform AMF lock Unlock operation without NGlink validation
    Sleep    60s
    ${fault_dict_after_amf_lock}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_amf_lock}
    Return From Keyword If    '${sib_validation}' == 'False'     ${fault_dict_after_amf_lock}
    ${expected_count}=    Evaluate    ${iteration_index} + 5
    Run Keyword And Continue On Failure    Check All SystemInformationBlockType Updates    expected_sib_count=${expected_count}
    ...    diff_sib1_sib2_count=True
    [Return]    ${fault_dict_after_amf_lock}

Perform RU Reset With Validation
    [Documentation]    Perform RU reset operation with alarm checking and SIB validation
    [Arguments]    ${previous_fault_dict}    ${iteration_index}
    Execute Egate Command    going to do RU reset
    RU reset via webgui
    Sleep    60s
    ${fault_dict_after_ru_reset}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_ru_reset}
    Return From Keyword If    '${sib_validation}' == 'False'    ${fault_dict_after_ru_reset}
    ${expected_count}=    Evaluate    ${iteration_index} + 2
    Run Keyword And Continue On Failure    Check All SystemInformationBlockType Updates    expected_sib_count=${expected_count}
    [Return]    ${fault_dict_after_ru_reset}

Perform BBMOD Reset With Validation
    [Documentation]    Perform BBMOD reset operation with alarm checking and SIB validation
    [Arguments]    ${previous_fault_dict}    ${iteration_index}
    Execute Egate Command    going to do bbmod reset
    Perform BBMOD Reset and Check BTS Status
    ${fault_dict_after_bbmod_reset}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_bbmod_reset}
    Return From Keyword If    '${sib_validation}' == 'False'     ${fault_dict_after_bbmod_reset}
    ${expected_count}=    Evaluate    ${iteration_index} + 3
    Run Keyword And Continue On Failure    Check All SystemInformationBlockType Updates    expected_sib_count=${expected_count}
    [Return]    ${fault_dict_after_bbmod_reset}

Perform Site Reset With Validation
    [Documentation]    Perform Site reset operation with alarm checking and SIB validation
    [Arguments]    ${previous_fault_dict}    ${iteration_index}
    Execute Egate Command    going to do site reset
    Perform Reset Site and Check BTS Status
    Sleep    60s
    ${fault_dict_after_site_reset}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_site_reset}
    Return From Keyword If    '${sib_validation}' == 'False'     ${fault_dict_after_site_reset}
    ${expected_count}=    Evaluate    ${iteration_index} + 4
    Run Keyword And Continue On Failure    Check All SystemInformationBlockType Updates    expected_sib_count=${expected_count}
    [Return]    ${fault_dict_after_site_reset}

Perform Lane lock unlock with alarm validation
    [Documentation]    Perform lane lock unlock operation with alarm checking
    [Arguments]    ${previous_fault_dict}    ${lane_distname}=${EMPTY}
    Execute Egate Command    going to do lane lock unlock
    Perform LANE lock Unlock operation     lane_distname=${lane_distname}
    ${fault_dict_after_lane_lock}=    Run Keyword And Continue On Failure    Get Alarms
    Run Keyword And Continue On Failure    Check Alarms    ${previous_fault_dict}    ${fault_dict_after_lane_lock}
    [Return]    ${fault_dict_after_lane_lock}

