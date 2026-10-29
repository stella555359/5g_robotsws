*** Settings ***
Suite Setup       self suite setup
Suite Teardown     common suite teardown
Resource          ./../resources/KISS/robot/common_resource.robot

*** Variables ***
${GNB_SW_BUILD}    SBTS00_ENB_9999_221017_000001      #221013_000005    #220831_000005       #220830_000006
${AP_SW_BUILD}    4.0.22722       #22672      #4.0.22663     # 21954      #
${L1_TYPE}        L1b

*** Test Cases *** 
AP_upgrade
    upgrade ap and check status      ${AP_SW_BUILD}

gnb_upgrade
    upgrade gnb and check status    ${GNB_SW_BUILD} 

*** keywords ***
self suite setup
    make sure gnb and ue ping and ssh ok
    Check 5G gnb or not
    wait until keyword Succeeds     120    20     common suite setup