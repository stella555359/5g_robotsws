*** Settings ***

Library        String
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME    taf_ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
Library        taf.selenium.gnb.oam.coam.classical      WITH NAME   taf_selenium
#Library        taf.sw.ping      WITH NAME   taf_ping
Library        DateTime

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/get_build_wft.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/faults.robot
Resource    ../../resources/selenium.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ./keyword.robot
Resource   ../../vduResourcesAIC/aic_vdu_deployment.robot



*** Variables ***

*** Keywords ***

TL_SETUP_Deployment_vDU

    Log to Console  vDU Deployement started
    Deployment_vDU

#    Log to Console  START SWR if needed
#    Log to Console  ${SWR} :if PASS SWR not needed
#
#    Run keyword If    ''${SWR}'=='PASS'  or  ${SKIP}= 'true'
#    ...  log to console  SW already tested
#    ...  ELSE
#    ...  Update Software With Activation
#
#    ${result}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
#    Run Keyword If  '${result}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
#    ...     AND     Update Software With Activation
#    ...     ELSE    Log To Console  Fault ID23 not found. Check BTS Is OnAir
#
#    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir





