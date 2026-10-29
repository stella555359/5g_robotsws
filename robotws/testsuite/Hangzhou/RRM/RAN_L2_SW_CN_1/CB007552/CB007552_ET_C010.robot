*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    swconfig_param=${RD_PARAM}    scf_file=${DELTA_FILE}
#...               AND    Suite Setup Copy WTS Config Files From Local    ${LOCAL_WTS_DIR}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO    FR1    CRT    RAN_5G_FDD    Owner_fanjin
#...               SBTS00    RAN_5G
#Resource          ./CB007552_Resource.robot
#
#*** Variables ***
#${RD_PARAM}         0x590072=1    # CP Debug
#${SCF_PATH}         ${CURDIR}/resources/config
#${DELTA_FILE}       Delta_Conf_CB007552_C.json
#${LOCAL_WTS_DIR}    ${CURDIR}/resources/wts
#${WTS_CFG}          basic_setup-7552-C-NSA-FDD.cfg
#@{UE_ID}            151    152    153
#${PROFILE_ID}       1
#${GNB_ID}           2
#${CELL_ID}          3
#${BEARER_ID}        2
#@{LOG_NAME_LIST}    btslog    snapshot
#
#*** Test Cases ***
#CB007552_ET_C010_Verify_PM_Counters_For_Max_Ues_With_Different_Dedicated_BWP_With_FDD_FR1_NSA_Mode
#    Attach Multiple UEs
#    Sleep    10s    reason=Wait For Transmission Stable
#    Wait Until Keyword Succeeds    20min    1min    Verify CB007552 PM Counters After Traffic
#    Report Pm Counter    M55308C28002    2    Passed
#    Report Pm Counter    M55308C28004    2    Passed
#    Report Pm Counter    M55308C28006    1    Passed
#    Report Pm Counter    M55308C28008    1    Passed
#    Report Pm Counter    M55308C28001    40000    Passed
#    Report Pm Counter    M55308C28003    10000    Passed
#    Report Pm Counter    M55308C28005    20000    Passed
#    Report Pm Counter    M55308C28007    10000    Passed
#
#*** Keywords ***
#Attach Multiple UEs
#    FOR    ${index}    IN    @{UE_ID}
#    Log To Console    =============[INFO]UE: ${index}==========
#    NSA LTE Attach    ${index}    ${PROFILE_ID}
#    NSA 5G Attach    ${index}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
##    NSA Verify If Attach Passed
#    NSA Start DL Traffic    ${index}    ${BEARER_ID}    50
#    NSA Start UL Traffic    ${index}    ${BEARER_ID}    10
#    END
#
#Verify PM Counters Equal To Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True    ${counter_values} == ${threshold_value}
#
#Verify PM Counters Bigger Than Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True    ${counter_values} > ${threshold_value}
#
#Verify Max PM Counters Equal To Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True    ${counter_values} == ${threshold_value}
#
#Verify CB007552 PM Counters After Traffic
#    Verify PM Counters Equal To Value    M55308C28002    2
#    Verify PM Counters Equal To Value    M55308C28004    2
#    Verify PM Counters Equal To Value    M55308C28006    1
#    Verify PM Counters Equal To Value    M55308C28008    1
#    Verify PM Counters Bigger Than Value    M55308C28001    40000
#    Verify PM Counters Bigger Than Value    M55308C28003    10000
#    Verify PM Counters Bigger Than Value    M55308C28005    20000
#    Verify PM Counters Bigger Than Value    M55308C28007    10000
#
