# @Time    : 2025/7/25 13:32
# @Author  : Chun.li
# @Email   : chun.li@nokia-sbell.com
# @File    : Globe_CSV4ALL_UUF_25R2.robot
# @Software: PyCharm
# @Doc     : CSV UUF4ALL Test cases for Globe
*** Settings ***

Documentation
...    author: Chun Li
...    Contact: chun.li@nokia-sbell.com
...    Team: RAN RD VRF HAZ3 5
...    Feature: CSV_Globe

#Suite Setup       SISO Coam Suite Setup
#Suite Teardown    SISO Coam Suite Teardown
#Test Setup        MMW5 Common Case Setup
#Test Teardown     MMW5 Common Case Teardown
#Force Tags        CRT_TRUNK    PY310
#
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/robot_common_operations/interface.robot
#Resource    testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/lines/MMW_SG5/class_monitor.robot
Library             Collections
Library             taf/rfrl/csv4all/CSV4AllTestCases.py
Resource            taf/rfrl/uuf4all/uuf4all_keywords.robot
#Resource            taf/rfrl/ue/robot/REAL_UE.robot

*** Variables ***
${RP_CA}                    VRF_SiSo
${RP_LOCATION}              VRF_HAZ
${RP_ORGANIZATION}          VRF_HAZ_T07
${QC_DOMAIN}=               MN_RAN
${QC_PROJECT}=              RAN_VRF
${EMAIL_RECIPIENTS}         chun.li@nokia-sbell.com
@{CUSTOMERS}                Globe

${UPDATE_TEST_ITERATION}        3
${ACTIVATION_RESET_TEST_ITERATION}    20
${REPORT}                   ${True}

${INITIAL_SW}               ${EMPTY}
${TARGET_SW}                ${EMPTY}

@{CUSTOM_ALARMS_2011}            4290  4291  6129
#@{CUSTOM_ALARMS_2012}            4589  181    # Allowed alarms can be passed as e.g 1234  2345

&{NODE1}                    testline_object=${tl.enbs[0]}
...                         node_alias=RFS4G
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         alarm_timer=${480}
...                         temporary_allowed_alarms=${6134, 6129, 62003, 1898, 4038, 1811, 7513, 7509, 2412}
...                         custom_allowed_alarms=${CUSTOM_ALARMS_2011}
...                         testline_scout_name=7_5_UTE5G402T2012_1

&{NODE2}                    testline_object=${tl.gnbs[0]}
...                         node_alias=RFS5G
...                         source_sw=${INITIAL_SW}
...                         target_sw=${TARGET_SW}
...                         temporary_allowed_alarms=${10, 62003, 6327, 7513, 7509}
#...                         custom_allowed_alarms=${CUSTOM_ALARMS_2012}
...                         hw_to_onair_timeout=${1200}
...                         testline_scout_name=7_5_UTE5G402T2012_2

@{NODES}                    ${NODE2}  ${NODE1}

${LOG_PATH}                 ${OUTPUT_DIR}

*** Test Cases ***
E2E_TL_SW_upgrade_rollback_with_OAM_KPI
#    [Setup]      Prepare Ue for L3 Call    alias=UE1    capabilities=REAL_UE   reboot_ue=False
    [Timeout]   24h
    Set Initial And Candidate
    E2E TL SW UPGRADE ROLLBACK WITH OAM KPI    ${NODES}  ${NODES}  ${UPDATE_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     restore_to_target_sw=${False}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${105458}
#    ...    l3_call_method=Verify L3 Call Data Transfer DL&UL

E2E_TL_Activation_Reset_with_OAM_KPI
    [Timeout]   48h
    E2E TL Activation Reset Test    ${NODES}  ${NODES}  ${ACTIVATION_RESET_TEST_ITERATION}
    ...     customers_list=${CUSTOMERS}
    ...     report=${REPORT}
    ...     qc_domain=${QC_DOMAIN}
    ...     qc_project=${QC_PROJECT}
    ...     qc_id=${219366}

*** Keywords ***
Set Initial And Candidate
    ${initial_sw}=    run keyword if  '${INITIAL_SW}'=='${EMPTY}'  Get Source SW
    ...   ELSE  set variable  ${INITIAL_SW}
    ${candidate_sw}=    run keyword if  '${TARGET_SW}'=='${EMPTY}'  Get Target SW
    ...   ELSE  set variable  ${TARGET_SW}
    FOR    ${node}    IN    @{NODES}
        Set to dictionary    ${node}    source_sw=${initial_sw}    target_sw=${candidate_sw}
    END
