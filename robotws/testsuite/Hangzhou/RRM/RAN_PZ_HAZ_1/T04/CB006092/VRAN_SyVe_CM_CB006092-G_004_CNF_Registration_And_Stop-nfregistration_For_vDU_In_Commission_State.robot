*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for RAN_ST_CB006092-G_004_CM_CNF Registration and stop-nfregistration for vDU in commission state
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
${RECOVERY_FLAG}    ${False}

*** Keywords ***
VRAN_SyVe_CM_CB006092-G_004_CNF_Registration_And_Stop-nfregistration_For_vDU_In_Commission_State
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    29.08.2025, yuyan.xu@nokia-sbell.com
    Step 1: Initial And Enable Registration And Check Status
    Step 2: Reset vDU And Check Status
    Step 3: Update nfRegistrationScenarioTimeout To 0 And Check
    Step 4: Disable Registration And Check Status
    Step 5: Enable Registration And Check Status
    Step 6: Disable NetconfService And Check Status


Step ${index}: Initial And Enable Registration And Check Status
    Log To Console    Step ${index}: Initial And Enable Registration And Check Status
    @{para_list}    Create List    activateSendingNfRegistration
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Sleep    10s
    @{para_list}    Create List    activateSendingNfRegistration    nfRegistrationScenarioTimeout    nfRegistrationEventSendingInterval
    @{value_list}    Create List    true    5    60
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ...    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    sleep    30s
    Check Registration Status    ongoing
    Sleep    300s
    Check Registration Status    timed out

Step ${index}: Reset vDU And Check Status
    Log To Console    Step ${index}: Reset vDU And Check Status
    vdu.reset_vdu
    Sleep    240s
    Wait Until Keyword Succeeds    10min    10s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Wait Until Keyword Succeeds    3x    15s    Check Registration Status    ongoing

Step ${index}: Update nfRegistrationScenarioTimeout To 0 And Check
    Log To Console    Step ${index}: Update nfRegistrationScenarioTimeout To 0 And Check
    @{para_list}    Create List    activateSendingNfRegistration
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    @{para_list}    Create List    activateSendingNfRegistration    nfRegistrationScenarioTimeout
    @{value_list}    Create List    true    0
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    FOR   ${index}    IN RANGE    0    2
        Check Registration Status    ongoing
        Sleep    60s
    END

Step ${index}: Disable Registration And Check Status
    Log To Console    Step ${index}: Disable Registration And Check Status
    @{para_list}    Create List    activateSendingNfRegistration
    @{value_list}    Create List    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Check Registration Status    disabled

Step ${index}: Enable Registration And Check Status
    Log To Console    Step ${index}: Enable Registration And Check Status
    @{para_list}    Create List    activateSendingNfRegistration
    @{value_list}    Create List    true
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Check Registration Status    ongoing

Step ${index}: Disable NetconfService And Check Status
    Log To Console    Step ${index}: Disable NetconfService And Check Status
    @{para_list}    Create List    activateOranO1NetconfService    actCmEventsReporting
    @{value_list}    Create List    false    false
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Check Registration Status    ongoing

    @{para_list}    Create List    activateOranO1NetconfService    actCmEventsReporting
    @{value_list}    Create List    true    true
    @{mo_list}    Create List    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}
    vDU Login By Rest
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0

Check Registration Status
    [Arguments]    ${expected_status}
    Log To Console    Check Registration Status
    ${time}    Get Time    epoch
    Run Keyword And Ignore Error    vDU Login By Rest
    ${BTS_Scf_With_Runtime}    vdu.get_current_plan_file    local_dir_path=${TEST_LOG_DIRECTORY}    filename=current_scf_${time}.xml
    ...    include_runtime_data=True     #include_auto_config_data=${False}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_content}    L_XML.Parse Xml    ${BTS_Scf_With_Runtime}
    ${nfRegistationStatus}    L_XML.Get Element Text    ${scf_content}
    ...    .//managedObject[@distName="MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1/MPLANEONAP_R-1"]/p[@name="nfRegistationStatus"]
    Should Be Equal As Strings    ${nfRegistationStatus}    ${expected_status}

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Log    ${ReIntegrate_vCU}
    Common Test Setup For AIC
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}
    Set Test Variable    ${host_ip}    ${ONAP["host_ip"]}
    Set Test Variable    ${user}    ${ONAP["user"]}
    Set Test Variable    ${pwd}    ${ONAP["pwd"]}
    vDU Login By Rest
    ${vesSourceName}    Get Parameter Value From vDU     MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANEONAP-1    vesSourceName
    Set Test Variable    ${vesSourceName}
    ${dnPrefix}    Get Parameter Value From vDU     MRBTS-${vDU_id}    dnPrefix
    Set Test Variable    ${dnPrefix}

Case Postcondition
    Log To Console    Case Postcondition
#    ${out}   Run Keyword If    ${RECOVERY_FLAG}
#    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
#    Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC