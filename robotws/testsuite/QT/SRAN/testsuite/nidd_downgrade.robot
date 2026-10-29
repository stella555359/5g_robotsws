*** Settings ***
Force Tags    PY39    RF50
Documentation    NIDD Downgrade Test

Library      BuiltIn
Library      taf.sbts.oam.coam.admin    WITH NAME    coam
Library      ${CURDIR}/../resources/python/TestCaseRequirement.py

Resource     ${CURDIR}/../resources/robot/common.robot
Resource     ${CURDIR}/../resources/robot/common_variables.robot
Resource     ${CURDIR}/../resources/robot/classical_keywords.robot
Resource     ${CURDIR}/../resources/robot/states.robot
Resource     ${CURDIR}/../resources/robot/additional_check.robot
Resource     ${CURDIR}/../resources/robot/allowed_alarms.robot
Resource     ${CURDIR}/../resources/robot/states.robot
Resource     ${CURDIR}/../resources/robot/smart_recovery.robot
Resource     ${CURDIR}/../resources/robot/huawei_router_and_iphy_keywords.robot
Resource     ${CURDIR}/../resources/robot/log_collector.robot

Suite Setup        Run Keywords    NIDD Downgrade Suite Setup
Suite Teardown     Run Keyword And Ignore Error    NIDD Downgrade Suite Teardown


*** Test Cases ***
Install T0 package via YAFT
    [Tags]    T0    ONAIR    SW_DEPL
    Install Software Using YAFT
    Run Keyword And Ignore Error    Perform Firmware Downgrade

Verify BTS Startup
    [Tags]    T0    ONAIR    STARTUP
    [Setup]    Requires TC    Install T0 package via YAFT
    Verify SMOD And BBMOD Detection    bbmod_detection_time=20

Perform Commissioning
    [Tags]    T0    ONAIR    scf    COMMISSIONING
    [Setup]    Requires TC    Verify BTS Startup
    Perform Commissioning For NIDD Downgrade

Verify BTS Startup After Commissioning
    [Tags]    T0    ONAIR    COMMISSIONING    POST_COMISSION
    [Setup]    Requires TC    Perform Commissioning
    Verify SMOD And BBMOD Detection
    Check GPS Receiver Alarm    check_times=10    gps_status_check_after_firmware_upgrade=${False}

Verify Cell Setup
    [Tags]    T0    ONAIR    COMMISSIONING    CELL_SETUP    POST_COMISSION
    [Setup]    Requires TC    Verify BTS Startup After Commissioning
    Verify RF Detection And Reach OnAir

Install Package T1
    [Tags]    T1
    [Setup]    Requires TC    Verify Cell Setup
    ${sw_package}   Replace String   ${basebuild_path}   downloadable   downloadable_testpackage_T1
    Install package on cOAM   T1orT2=T1    sw_package=${sw_package}

Verify Cell Setup T1
    [Tags]    T1
    [Setup]    Requires TC    Install Package T1
    ${is_cell_onair}    Run Keyword And Return Status    Wait Until Keyword Succeeds    12min  1min    Verify Cells Setup
    IF    ${is_cell_onair}
        Log To Console      \tOnAir Reached!
        Check active SW version on cOAM    T1orT2=T1   AF_PATH=${basebuild_path}
    ELSE
        Check Unexpected Active Alarms
        Fail    msg=BTS did not reach OnAir!
    END

*** Keywords ***
NIDD Downgrade Suite Setup
    Log To Console      ============================== [ SUITE SETUP ] ===============================\n
    Log To Console      \t\t - - - Setting variables for test - - -
    Check VM Disc Usage
    Set Color For Logs
    Create Directory    ${OUTPUT DIR}/Additional_Execution_Logs
    Run  command=ps -ef | grep admin | grep -v grep | awk '{print "kill "$2}' | sh
    WA for coam connect    bts_host=${LMP_IP}
    Set Stream Variables
    Set GNB or ENB Flag
    Get BBmod And Smod Type
    Set UE Type
    ${dualcore}                    Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIM_ASIM
    BuiltIn.Set Global Variable    ${dualcore}
    ${airscale_fsmf}                Run Keyword And Return Status    Should Contain    ${NODE_NAME}    ASIB_FSMF
    BuiltIn.Set Global Variable    ${airscale_fsmf}
    ${fsmf_cus}                Run Keyword And Return Status    Should Contain    ${NODE_NAME}    FSMF_FBBC
    BuiltIn.Set Global Variable    ${fsmf_cus}
    Run Keyword If       'cus' in @{UEs}
    ...                  Setup WTS
    Run Keyword And Ignore Error    Start BTSlogs Collection
    Log To Console      \n============================ [ SUITE SETUP DONE ] ============================
    Log To Console      ------------------------------------------------------------------------------

NIDD Downgrade Suite Teardown
    coam.Setup Admin     bts_host=${LMP_IP}    name=admin
    ${sw_d}=  coam.get_sw_version    connection=admin
    Set Suite Variable    ${sw_d}
    Stop BTSlogs Collection And Get Logs  target_path=${OUTPUT_DIR}
    Save Snapshot For Classical    connection=admin
    Run Keyword If       'cus' in @{UEs}
    ...   Teardown WTS  subdirectory=${OUTPUT DIR}/Additional_Execution_Logs
    [Teardown]    Run Keywords    Run Keyword and ignore error    coam.Teardown admin    connection=admin
    ...                    AND    Run Keyword and ignore error    coam.teardown    connection=coam_admin
    ...                    AND    Run Keyword If All Tests Passed
    ...      Log To Console      \n========================== TL Preparation to NIDD downgrade finished ===========================\n
