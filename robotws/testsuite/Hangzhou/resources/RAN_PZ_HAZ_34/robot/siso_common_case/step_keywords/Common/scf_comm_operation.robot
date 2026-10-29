*** Settings ***
Documentation    This is common keywords for LTE siso RRH related cases
...              Please do not modify the file without notification to author
...              Author: tingting.zhong
...              Contact: tingting.zhong@nokia-sbell.com
...              Squard: HZ SG4

Library       taf.config.scf    WITH NAME    scf
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/coam_gnb_classical.robot
Resource      testsuite/Hangzhou/resources/RAN_PZ_HAZ_34/robot/bts/common/selenium.robot

*** Keywords ***
Commissioning SCF And Check On Air for Common
    [Arguments]  ${scf_path}    ${connection}=GNB_OAM
    Log to console    +++Commissioning SCF And Check On Air+++
    Log to console    SCF Path:${scf_path}
    COAM Commission with scf file  scf_file_path=${scf_path}    timeout=600    is_pdl_checking_needed=${if_pdl_check}
    ...    connection=${connection}
    sleep    100s
    Wait until keyword succeeds    20 min    20 sec   verify all cells should be onair    cell_type=${cell_type}
    Run Keyword And Ignore Error    Close Start Up View Window    timeout=5
    log to console    \n Wait 5 minutes for the first calibration
    sleep   5min
