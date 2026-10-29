*** Settings ***
Documentation
...    Author: Wu Guoliang
...    Contact: guoliang.wu@nokia-sbell.com
...    this file is for CB010411.
...    Please do not modify the file without notification to author


Suite Setup    Common Suite Setup For AIC
Suite Teardown     Custom Suite Teardown For AIC

Force Tags
...      CRT             #Tag Item
...      RAN_PZ_HAZ_1             #Competence Area
...      RAN_PZ_HAZ1_VRF02_ST_RRM  #Organization


Test Timeout    600 minutes

Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource          ../../T02/Common_Case/common_resource_new.robot

*** Variables ***
${TESTLINE_NAME}             7-5-UTE5GAIC018T004
${DEFAULT_SCF_PATH}         ${CURDIR}/../../../../../../commissionings/RRM/SRAN_5G/7-5-UTE5GAIC018T004

*** Test Cases ***
CB012331-SR_01 Inter-PLMN CA with Blind Scell addition 2CC
    [Tags]    CRT    CB012331
    [Timeout]    30min
    [Documentation]
    ...    Author: guoliang.wu@nokia-sbell.com
    ...    Notice: Only on branch
    ...    history change: <date>,<who>,<what and how>
    ...    08.04.2023,guoliang.wu@nokia-sbell.com, draft
    [Setup]    Common Case Precondition
#    Prepare PA
    Prepare And Attach UE For Qualcomm    ue_index=0
    Start DL Call For UE    ue_index=0    ue_type=qualcomm
    wait until keyword succeeds   30min  30s   Check DU Counter For Scell Activation
    [Teardown]    Case Postcondition

*** Keywords ***
Common Case Precondition
    log to console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}

Case Postcondition
    log to console    Case Postcondition
    vDU Login By Rest
    Common Test Teardown For AIC
    Run Keyword And Ignore Error    vDU Logout By Rest

Prepare And Attach UE For Qualcomm
    [Arguments]    ${ue_index}=${0}    ${capabilities}=REAL_QUALCOMM_UE
    set test variable    ${ue_type}    qualcomm
    Log to Console    \n***Prepare UE***
    ute_ue.Require Ue    ue_alias=UE_${ue_index}    capabilities=${capabilities}
    Detach UE    ue_index=${ue_index}    ue_type=qualcomm
    UE Attach    ${ue_type}    ue_index=${ue_index}    verify_attach=True
    [Return]     ${ue_type}

Start DL Call For UE
    [Arguments]    ${ue_index}=${0}     ${ue_type}=${ue_${ue_index}_type}    ${direction}=dl
    Start traffic    ue_type=${ue_type}    ue_index=${ue_index}    direction=${direction}    dt_index=${ue_index}
    ...              throughput=1200M    duration=${300}
    sleep    5s    reason=wait call sucessfully

Detach UE0
    UE Detach    ${ue0_type}    ue_index=${0}

Prepare PA
    ${attenuation_channels}     Get Attenuation port    RU_id=0    du_id=0
    ${initial_att_values}    Get Initial Attenuation Values    RU_id=0    vendor=HBTE    du_id=0
    &{channels_to_modify}    create dictionary   ${attenuation_channels[0]}=11    ${attenuation_channels[1]}=11
    ...                                          ${attenuation_channels[2]}=11    ${attenuation_channels[3]}=11
    Modify Attenuation Value    ${channels_to_modify}    RU_id=0    du_id=0
    sleep    10s
    Log to console    PA Attenuation Changed.

Custom Suite Teardown For AIC
    Common Suite Teardown For AIC
    ${cmd}=    Set Variable    find ${SUITE_LOG_DIRECTORY} -type f -size +50M ! -name "*.xml" ! -name "*.html"
    ${result}    Run Process    ${cmd}    shell=True
    log to console    ${result.stdout}

    ${cmd_new}=    Set Variable    ${cmd} -exec rm -f {} \\;
    ${result}    Run Process    ${cmd_new}    shell=True
    log to console    ${result.stdout}
    log to console    ${result.stderr}
    log to console    ${result.rc}

##########    CB012331    ##########

Check DU Counter For Scell Activation
    ${du_counter_id_list}    Create List    M55316C03001
    ${du_counter_values_final_list}    Create List
    FOR    ${du_counter_id}    IN    @{du_counter_id_list}
        ${du_counter_values_final_list}    Check Counter For vDU   counter_id=${du_counter_id}
        ...                                            dimension_dn=MRBTS-${MRBTS_ID}/NRBTS-${MRBTS_ID}/NRCELL-3
        ...                                            expected_value=0
        ...                                            get_number=2
    END