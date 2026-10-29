*** Settings ***
Force Tags    PY36
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace check_gnb_state.robot
Resource         ./../common_setup_teardown.robot
*** Variables ***
${gnb_swconfig}    /home/ute/testline_init_results/configs/gnb_swconfig.txt
${ap_swconfig}    /home/ute/testline_init_results/configs/ap_swconfig.txt
${iphy}    /home/ute/testline_init_results/configs/iphy.xml
${gnb_scf}    /home/ute/testline_init_results/configs/scfc.xml
${SCF_PATH}    ${CURDIR}/config
*** Test Cases ***
Test Case Recover Testline
    Recover Testline 2
*** Keywords ***
Recover Testline
    Suite Setup Update GNB    log=none
    Suite Setup Copy WTS Config Files From QT
    Send Swconfig for GNB    ${gnb_swconfig}
    Send Swconfig for AP    ${ap_swconfig}
    Send IPHY XML for AP    ${iphy}
    Send SCFC for GNB    ${gnb_scf}
    Reboot TL And Check Configured

Recover Testline 2
    Suite Setup Update GNB    log=none
    Suite Setup Copy WTS Config Files From QT
    Send Swconfig for GNB    ${gnb_swconfig}
    Send Swconfig for AP    ${ap_swconfig}
    Modify IPHY File And Send to Airphone    ${iphy}
    Full Commission With SCF File    ${gnb_scf}
    Reboot TL And Check Configured
