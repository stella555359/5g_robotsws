*** Settings ***

Library        String
Library        OperatingSystem
Library        Process
Library        taf.transport.ssh   WITH NAME    taf_ssh
Library        taf.gnb.oam.coam.admin.interface.admin   WITH NAME   taf_admin
#Library        taf.sw.ping      WITH NAME   taf_ping
Library        DateTime

Resource    ../../resources/admin.robot
Resource    ../../resources/pretest_posttest.robot
Resource    ../../resources/system.robot
Resource    ../../resources/get_build_wft.robot
Resource    ../../resources/admin_infomodel.robot
Resource    ../../resources/faults.robot
Resource    ../../resources/selenium.robot
Resource    ./keyword.robot

*** Variables ***
${LOGGING_ENB_SYSLOG}=           True
${LOGGING_IPHY_SYSLOG}=          True
${LOGGING_ADMIN_LOG}=            True
${LOGGING_ADMIN_INFOMODEL_LOG}=  True
${LOGGING_EMSSIM_LOG}=           True

${SW_DESTINATION}      /home/ute/
${WEBEM_IP}=           https://192.168.255.129
# scf TO BE OPTIMIZED
${Scf_Initial_SBTS22R3}=  Initial_22R3_Configuration_scf_MRBTS_AAFB_AAIB_n25_n66_BW5.xml
${Scf_Initial_SBTS22R4}=  Initial_22R4_Configuration_scf_MRBTS_AAFB_AAIB_n25_n66_BW5.xml
${Scf_Default_SBTS22R3}=   /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008993-SR-B_5GC000766-A/resources/${Scf_Initial_SBTS22R3}
${Scf_Default_Trunk}=      /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008993-SR-B_5GC000766-A/resources/${Scf_Initial_SBTS22R4}
${Actual_Branch}=        SBTS22R3
*** Keywords ***

TL_SETUP

    Log to Console  START SWR if needed
    Log to Console  ${SWR} :if PASS SWR not needed
    Log to Console  Branch: ${BRANCH_from_JENKINS}
    Run keyword If  '${SWR}'=='PASS' or '${SKIP}' == 'true'
    ...  log to console   SW already tested
    ...  ELSE IF  '${BRANCH_from_JENKINS}'=='${Actual_Branch}'
    ...  SWR and commisioning in Branch
    ...  ELSE IF  '${BRANCH_from_JENKINS}'=='SBTS00'
    ...  SWR and commisioning in Trunk
    ...  ELSE
    ...  log to console  Wrong value

    ${result_on_air}   Run Keyword and Return Status    Wait Until Keyword Succeeds  900    20    ADMIN INFOMODEL Check If BTS Is OnAir
    log to console  OnAir:${result_on_air}

    Run Keyword If  '${result_on_air}' == 'True'
    ...     Log To Console   BTS Is OnAir!
    ...     ELSE  Log To Console   Check Fault 23

    sleep  60

    ${result_fault23}   Run Keyword and Return Status    ADMIN Check If Alarm Is Active  fault_id=23
    log to console  Fault23:${result_fault23}

    Run Keyword If  '${result_fault23}' == 'True'   Run Keywords   Log To Console  Fault ID23 found. Start RF Software Update
    ...     AND     Update Software With Activation

    Wait Until Keyword Succeeds    900    20    ADMIN INFOMODEL Check If BTS Is OnAir


