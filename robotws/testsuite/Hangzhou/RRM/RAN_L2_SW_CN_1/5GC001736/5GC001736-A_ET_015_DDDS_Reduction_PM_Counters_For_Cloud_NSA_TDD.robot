*** Settings ***
Documentation    ...
#Suite Setup       Run Keywords    Suite Setup Update GNB    ${SWCONFIG_PARAM}    scf_file=${DELTA_FILE}
##...               AND    Set Suite Variable    ${VENDOR_PATH}    ${SUITE_LOG_DIRECTORY}/vendor.xml
##...               AND    Modify Vendor File And Do Full Commission    vendor_path=${VENDOR_PATH}
##...               old_params=@{VENDOR_OLD_PARAMS}    new_params=@{VENDOR_NEW_PARAMS}
#...               AND    Suite Setup Copy WTS Config Files From QT
##No Need Now...               AND    Modify Text File    ${WTS_DIR}/${WTS_CFG}    ${OLD_CFG_PARAMS}    ${NEW_CFG_PARAMS}
#...               AND    Suite Setup Start WTS And Check OnAir
#Suite Teardown    Common Suite Teardown
#Test Setup        Common Test Setup
#Test Teardown     Common Test Teardown
#Force Tags        CLOUD_5G_I_LO_AP_LO_SANSA_FS_ECPRI_CMWV_TDD    CRT    FR1    Owner_molyang    RAN_5G
#...               RAN_5G_TDD    SBTS00    SBTS23R1    SBTS22R4
#Resource          5GC001736_Common_Keywords.robot
#
#*** Variables ***
#${SWCONFIG_PARAM}         0x45005a=1
#${SCF_PATH}               ${CURDIR}/config
#${DELTA_FILE}             Delta_Configuration_scf_NSA_actDDDSPeriodOptimization_actDddsReduction.json
#${UE_ID}                  11   #NSA UE_ID
#${PROFILE_ID}             1
#${GNB_ID}                 2
#${CELL_ID}                1
#${BEARER_ID}              2
##No Need @{OLD_CFG_PARAMS}         plmn=[0-9]+:[0-9]+
##No Need @{NEW_CFG_PARAMS}         plmn=302:610
#@{LOG_NAME_LIST}          btslog    snapshot
#@{VENDOR_OLD_PARAMS}      <p name="dddsPeriod">[0-9]+</p>
#@{VENDOR_NEW_PARAMS}      <p name="dddsPeriod">40</p>
#${DL_DATA_SEND_MBPS}      25
#${DL_DATA_DURATION_S}     20
#${DL_DATA_EXPECT_MBPS}    20
#
#*** Test Cases ***
#5GC001736-A_ET_015_DDDS_Reduction_PM_Counters_For_Cloud_NSA_TDD
#    NSA LTE Attach    ${UE_ID}    ${PROFILE_ID}
#    NSA 5G Attach    ${UE_ID}    ${GNB_ID}    ${CELL_ID}    ${BEARER_ID}
#    NSA Verify If Attach Passed
#    Wait Until Keyword Succeeds    20min    1min    Verify Two PM Counters Before Traffic
#    NSA Start DL Traffic    ${UE_ID}    ${BEARER_ID}    ${DL_DATA_SEND_MBPS}
#    Sleep    ${DL_DATA_DURATION_S}
#    NSA Check Average Traffic Bigger Than Target    ${UE_ID}    ${BEARER_ID}    dl    ${DL_DATA_EXPECT_MBPS}
#    NSA Stop Traffic    ${UE_ID}    ${BEARER_ID}    dl
#    Wait Until Keyword Succeeds    20min    1min    Verify Two PM Counters After Traffic
#
#*** Keywords ***
#Verify PM Counters Less Than Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True    ${counter_values} < ${threshold_value}
#
#Verify PM Counters Bigger Than Value
#    [Arguments]    ${counter_id}    ${threshold_value}
#    ${counter_values}    Get Latest PM Counter Value With Admin    ${counter_id}
#    Should Be True    ${counter_values} > ${threshold_value}
#
#Verify Two PM Counters Before Traffic
#    Verify PM Counters Less Than Value    M55323C14001    10
#    Verify PM Counters Less Than Value    M55313C24001    10
#
#Verify Two PM Counters After Traffic
#    Verify PM Counters Bigger Than Value    M55323C14001    1000
#    Verify PM Counters Bigger Than Value    M55313C24001    500
#
#
