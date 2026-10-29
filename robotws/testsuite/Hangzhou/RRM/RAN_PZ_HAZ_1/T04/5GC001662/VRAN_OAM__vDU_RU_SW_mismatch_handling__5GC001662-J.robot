*** Settings ***
Documentation
...    VRF HAZ 1 Common Resources.

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource         ../Resources/PZ2/ru.robot
Resource         ../Resources/PZ2/vdu_oam_cm.robot
Resource         ../Resources/PZ2/aic_common_resources_new.robot
#Resource         ../Resources/PZ2/kw_to_be_optimized.robot
#Resource         ../Resources/PZ2/vdu_sec_authorization.robot
Library          taf.hw.fhgw.cli        WITH NAME    issh



*** Keywords ***
VRAN_OAM__vDU_RU_SW_mismatch_handling__5GC001662-J
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.06.2024, yuyan.xu@nokia-sbell.com, draft,
    ...    New case,based to transfer from PZ2 case:OAM__vDU_RU_SW_mismatch_handling__5GC001662-J
    Log To Console    ${TEST_NAME} start.
    Step1: RU Status On WebUI Are Green
    Step2: Downgrade RU Manually
    Step3: Reboot RU Manually
    Step4: Confirm There Is Fault 23 In History Alarm
    Step5: RU Is Not Upgraded

Step1: RU Status On WebUI Are Green
    Log To Console   Step1: RU status on WebUI are green
    ${administrative_state}    ${operational_state}    Get Specified RU Status In vDU
    Log To Console   operational_state:${operational_state}
    Should Be True  "${operational_state}"=="enabled"
    Check Expected Alarms Is Not Appear    expected_fault_id=23
    Check Expected Alarms Is Not Appear    expected_fault_id=10

Step2: Downgrade RU Manually
    [Teardown]  Run Keyword And Ignore Error   issh.disconnect   alias=${alias}
    Log To Console   Step2: Downgrade RU Manually

    ${handle}   Connect To RU
    ${alias}    Set Variable   ${handle["alias"]}
    ${out}   issh.Execute  command=sudo -i    check_result=${False}    alias=${alias}
    ${out}   issh.Execute  command=SWmanShellCommand -i    alias=${alias}
    ${out}   issh.Execute  command=SWmanShellCommand -i|grep "it's active" -B 1|grep version|awk '{print $2}'   alias=${alias}
    ${ORIGINAL_RU_VERSION_CHKSUM}   strip_prompt   ${out}
    Set Test Variable   ${ORIGINAL_RU_VERSION_CHKSUM}

    ${out}   issh.Execute  command=SWmanShellCommand -x   alias=${alias}
    ${out}   issh.Execute  command=SWmanShellCommand -i   alias=${alias}
    ${out}   issh.Execute  command=SWmanShellCommand -i|grep "it's active" -B 1|grep version|awk '{print $2}'   alias=${alias}
    ${DOWNGRADED_RU_VERSION_CHKSUM}   strip_prompt   ${out}
    Set Test Variable   ${DOWNGRADED_RU_VERSION_CHKSUM}

Step3: Reboot RU Manually
    Log To Console   Step3: Reboot RU Manually
    Reboot RU By CLI

Step4: Confirm There Is Fault 23 In History Alarm
    Log To Console      Step4: Confirm There is Fault 23 In Active Alarm
    Wait Until Keyword Succeeds   180    10    Check Expected Alarms Is Appear    expected_fault_id=10
    Wait Until Keyword Succeeds   600    10    Check Expected Alarms Is Appear    expected_fault_id=23
    Wait Until Keyword Succeeds   5min   20s   Check Expected Alarms Is Not Appear    expected_fault_id=10
    Wait Until Keyword Succeeds   5min   20s   Check Expected Alarms Is Not Appear    expected_fault_id=23
    Wait Until Keyword Succeeds   5min   20s   Check Expected Alarms Is Not Appear    expected_fault_id=4527
    Wait Until Keyword Succeeds   5min   20s   Check Expected Alarms Is Not Appear    expected_fault_id=4675
    Wait Until Keyword Succeeds   10min  20s    vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}

Step5: RU Is Not Upgraded
    Log To Console   Step5: RU Is Not Upgraded
    ${operational_state}    Get RU Operational State Via REST
    Log To Console   operational_state:${operational_state}
    Should Be True  "${operational_state}"=="enabled"
    ${ru_version}  ${handle}    Get RU Version Via CLI
    Should Be True  "${ru_version}"=="${ORIGINAL_RU_VERSION}"

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    ${ReIntegrate_vCU}
    Log To Console    ${ReIntegrate_vDU}
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${ORIGINAL_RU_VERSION}   ${handle}  Get RU Version Via CLI
    Set Test Variable    ${ORIGINAL_RU_VERSION}

Case Postcondition
    Log To Console    Case Postcondition
    Common Test Teardown For AIC