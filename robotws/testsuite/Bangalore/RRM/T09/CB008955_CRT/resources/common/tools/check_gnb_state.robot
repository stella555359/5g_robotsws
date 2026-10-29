*** Settings ***
Documentation
...    cmd: you need to change 2_16_UTE5GCLASSICAL1462 to your testline name.
...    robot -V /home/ute/Auto5G/config/Wroclaw/2_16_UTE5GCLASSICAL1686 -L trace check_gnb_state.robot
Resource         ../common_setup_teardown.robot

*** Test Cases ***
Check Testline State
    Verify Coam Site Is Ready


