*** Settings ***
Documentation     Copyright 2022 Nokia Solution and Networks. All rights reserved
...               Author: Jet Li.Li (NSB - CN/Hangzhou)
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_Resource.robot
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_CMVTK.robot
Force Tags        TEAM-BOAM OSSEMS ET    FEATURE-LTE4934-H   RAN_4G_TDD
...    SBTS00    SBTS22R4    SBTS23R1    Owner-jiajun.jin   CLOUD_5G_I_BL_AP_KL_SANSA_FS_CPRI_CMWV_FDD
Suite Setup       Run Keywords    Common BTS Suite Setup   AND   Prepare Ne3sVTK Test Env   AND   Create Jython Script
Suite Teardown    Common BTS Suite Teardown
Test Setup        Common BTS Test Setup
Test Teardown     Run Keywords    Backup Jython Log    AND    Common BTS Test Teardown

*** Variables ***
${S_NE3S_PATH}    /home/ute/ValidationToolKit_21.12/NE3S_VTK/webservice

*** Test Cases ***
LTE4934-H-a_1_2_Configure BTS and register BTS to NetAct(VTK)
    [Tags]   CIT
	Wait Until Keyword Succeeds    300s    60s    Check Jython Case Passed    Register    ${CURDIR}/LTE4934-H_jython.robot

LTE4934-H-c_1_1_NE3S connection supervision between NMS an cOAM BTS
    [Tags]    CIT
	Wait Until Keyword Succeeds    300s    60s    Check Jython Case Passed    Ping    ${CURDIR}/LTE4934-H_jython.robot


*** Keywords ***
Create Jython Script
        Run    cp ${CURDIR}/LTE4934-H_jython.skip ${CURDIR}/LTE4934-H_jython.robot

Backup Jython Log
	Run    cp /home/ute/logs/log.html ${TEST_LOG_DIR}/Jython_log.html

Check Jython Case Passed
    [Arguments]    ${case_name}    ${robot_file}
    ${Result}    Run    bash ${CURDIR}/../../../resources/BOAM_ET/Start_Jython_Case.sh '${case_name}' ${robot_file}
	Log    ${Result}
	Should Contain    ${Result}    0 failed