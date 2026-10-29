*** Settings ***
Documentation   UUF
...     Author: Furkan Tombul Edit by Michele
...     RAN_PZ_ULM
...     Michele.Bertolini@nokia.com

Library    Collections
Library    OperatingSystem
Library    String
Library    taf.sbts.oam.coam.admin           WITH NAME   admin
#Library    lib.oam.admin.other_admin_ops    WITH NAME   admin_ops
Library    taf.sw.scout    WITH NAME    scout
Library    taf.ul.hanging_resources.listener

Resource    ../../resources/Common/testline.robot
Resource    ../../resources/Common/log_collection.robot
Resource    ../../resources/Common/btslog.robot
Resource    ../../resources/Common/snapshot.robot
Resource    ../../resources/Common/commissioning.robot
Resource    ../../resources/Common/connect.robot
Resource    ../../resources/Common/gnb.robot
Resource    ../../resources/Common/tcpdump.robot
Resource    testsuite/Ulm/SyVe/resources/syve_testline.robot
Resource    ../resources/installation.robot
Resource    ../resources/enb.robot
Resource    resources/UUF-keywords.robot
Resource    resources/Software_upgrade-keywords.robot

Suite Setup     UUF Check Suite Setup
Suite Teardown      UUF Check Suite Teardown

*** Variables ***
# Target Software and current Customer SW are to be set in the robot call. The same is needed for the ENB and GNB nodes
${TARGET_SW_VERSION_ENB}    None
${ENB_SW_UPDATE_NODES}      None
${TARGET_SW_VERSION_GNB}    None
${GNB_SW_UPDATE_NODES}      None
# Customer SW Version is only needed for CDRT / UUF Tests. This Software will be installed first.
${CUSTOMER_SW_VERSION_GNB}  None
${CUSTOMER_SW_VERSION_ENB}  None
${USE_SCOUT_INTERNAL_ID}                          True

${PACKAGE_PATH}     /mnt/etfiles/images/sbts/
${ITERATIONS}       3


*** Test Cases ***
UUF_upgrade_update_fallback
    [Documentation]     UUF software installation loop:
    ...     First all needed log collections and traces are started
    ...     Then uboot downgrade is checked and Software upgrade to Target Software is triggered
    ...     After all traces stopped and logs are compared / checked
    ...     After all checks for enb and gnb in current iteration,
    ...     UUF rollback is started to fallback to curent Customer SW
    [Tags]  UUF_Tests
    [Setup]    Perform Preconditions of UUF checks
    FOR    ${iteration}    IN RANGE   ${ITERATIONS}
        ${iteration}=   Evaluate    ${iteration} + 1
        admin.teardown_all_aliases_for_admin
        append to log directory      ${iteration}
        Log To Console    gNB UUF check - iteration: ${iteration}
        Log To Console    ${\n}Current Logging PATH: ${\n}${LOG_DIR}
        gnb UUF checks before
        UUF Software Upgrade procedure gnb
        gnb UUF checks after
        Log To Console    UUF check for eNB - iteration: ${iteration}
        enb UUF checks before
        UUF Software Upgrade procedure enb
        enb UUF checks after
        IF      ${iteration}!=${ITERATIONS}     UUF Rollback to customer Software
    END
    Check eNB and gNB OnAir STATE and X2 Available
    Log To Console    ${\n}...The End.
    [Teardown]    Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...           AND    Save Snapshot
    ...           AND    Run Keyword If Test Failed    Stop eNB SysLog in Teardown


Prepare testline for CDRT UUF
    [Documentation]     UUF preperation:
    ...     Install customer software before start UUF test
    ...     Also uboot downgrade will happen here
    [Tags]  UUF_Preperation
    [Setup]     Perform Preconditions of UUF checks
    Software_upgrade-keywords.Execute Update GNB Software
    Software_upgrade-keywords.Execute Update ENB Software
    Check eNB and gNB OnAir STATE and X2 Available
    [Teardown]    Save Snapshot


UUF_reset_without_HWF
    [Documentation]     UUF software installation loop:
    ...     First all needed log collections and traces are started
    ...     Then uboot downgrade is checked and Software upgrade to Target Software is triggered
    ...     After all traces stopped and logs are compared / checked
    ...     After all checks for enb / gnb in iteration, UUF rollback is started to fallback to curent Customer SW
    [Tags]  UUF_hwf
    [Setup]     Perform Preconditions of Testcase
    FOR    ${index}    IN RANGE   ${ITERATIONS}
        log to console   hwf loop iteration: ${index}
        Delete HWF and RESET gNB
        Delete HWF and RESET eNB
    END
    Check eNB and gNB OnAir STATE and X2 Available
    Log To Console    ${\n}...The End.
    [Teardown]    Run Keywords    Link SCOUT SCF to Configuration ID for Reporting
    ...           AND    Save Snapshot
    ...           AND    Run Keyword If Test Failed    Stop eNB SysLog in Teardown


*** Keywords ***
UUF Check Suite Setup
    Log Variables
    Set Console Output
    Save Snapshot
    Log To Console    ${\n}Create Log Folders. ${\n}
    Create Test Suite Log Folders
    Log To Console    Planned number of ITERATIONS: ${ITERATIONS} ${\n}


Perform Preconditions of Testcase
    Create testcase log directory
    ${LOG_DIR}=   Get testcase log directory
    Set Test variable       ${LOG_DIR}
    log to console  Log directory:  ${LOG_DIR} ${\n}


Perform Preconditions of UUF checks
    Perform Preconditions of Testcase
    Log to Console    This test is explicitly written for Customer UUF Tests
    IF    '${CUSTOMER_SW_VERSION_GNB}'=='None' and '${CUSTOMER_SW_VERSION_ENB}'=='None'
    ...    Fail    Please enter the Customer SW which you want to install
    IF    '${TARGET_SW_VERSION_GNB}'=='None' and '${TARGET_SW_VERSION_ENB}'=='None'
    ...    Fail    Please enter the Target Software defined in CDRT scope which you want to install
    IF    '${GNB_SW_UPDATE_NODES}'=='None' and '${ENB_SW_UPDATE_NODES}'=='None'
    ...    Fail    Please selecht atleast one Node which you want to update


Request Scout SCF
    [Arguments]   ${scout_testline_name}
    scout.setup_scout  scout_testline_name=${scout_testline_name}
    ${external_scf_id}=   scout.request_scf   use_scout_internal_id=${USE_SCOUT_INTERNAL_ID}
    scout.teardown_scout_api
    RETURN   ${external_scf_id}


Link SCOUT SCF to Configuration ID for Reporting
    [Documentation]    :Author: Michele
    ...    Associate the SCF to the Configuration ID in Reporting Portal using SCOUT.
    ${scout_testline_name}=    Set Variable    gNB390-1    #ToDo: Remove HardCode, Select Name from setup..
    ${external_scf_id}=   Request Scout SCF   ${scout_testline_name}
    ${TC_ID}=    Set Variable    ute:id:${external_scf_id}
    Set Tags  ${TC_ID}
    Set Tags    uuf_test


Save Snapshot  #ToDo: Use [Arguments]     node_id=${0}  node_type=gNB|eNB
    Save gNB Snapshot
    Save eNB Snapshot


Save gNB Snapshot
    Log to Console    ${\n}Save gNB Snapshot...
    ${status}  ${target_dir}   Run Keyword And Ignore Error    testline.Get test suite log directory
    ${target_dir}=    Set Variable If    '${status}'=='PASS'    ${target_dir}    ${OUTPUT_DIR}

    ${gNB_oam_alias}=    Setup OAM http session    node_id=${0}  node_type=gnb
    ${snapshot_path}=    Get Snapshot From BTS    alias=${gNB_oam_alias}    target_dir=${target_dir}
    Log to Console    ${\n}gNB Snapshot PATH:${snapshot_path}
    [Teardown]  Teardown OAM http session    node_id=${0}  node_type=gnb


Save eNB Snapshot
    Log to Console    ${\n}Save eNB Snapshot...
    ${status}  ${target_dir}   Run Keyword And Ignore Error    testline.Get test suite log directory
    ${target_dir}=    Set Variable If    '${status}'=='PASS'    ${target_dir}    ${OUTPUT_DIR}
    ${eNB_oam_alias}=    Setup OAM http session    node_id=${0}  node_type=enb
    ${snapshot_path}=    Get Snapshot From BTS    alias=${eNB_oam_alias}    target_dir=${target_dir}
    Log to Console    ${\n}eNB Snapshot PATH:${snapshot_path}
    [Teardown]     Teardown OAM http session    node_id=${0}  node_type=enb


Stop eNB SysLog in Teardown
    Log to Console    ${\n}Stop eNB SysLog in Teardown...(Could be that they are not yet stopped!)
    Run Keyword And Warn On Failure    Stop the following enb logs     enb_id=${0}


Check eNB and gNB OnAir STATE and X2 Available
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=enb    node_id=${0}    retry_interval=60 sec
    Run Keyword And Warn On Failure    gnb.Wait Until Node To Be Onair State   node_type=gnb    node_id=${0}    retry_interval=60 sec
    Run Keyword And Warn On Failure    Wait until X2 Link Status is Available    gnb_id=${0}


UUF Check Suite Teardown
    Log to Console    ${\n}Suite Teardown.
    syve_testline.Save current loads
