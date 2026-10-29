*** Settings ***
Documentation     Author: yanyan.shao@nokia-sbell.com
Force Tags    QCD_MN_RAN    QCP_RAN_ET
Resource          ../resources/KISS/robot/common_logs_operate.robot

*** Variables ***
${TARGET_FILE_NAME}         /tmp
${COVERAGE}                 Full
${FORCE}                    ${True}
${TIMEOUT}                  300
${REGEXP_FILTER}            None
${REASON}                   None
${CELLS}                    None
${DETAILED_OUTPUT}          ${False}


*** Test Cases ***
Collect_GNB_SnapShot_Test
    Collect GNB SnapShot    target_file_name=${TARGET_FILE_NAME}${/}gnb_comon_snapshot.zip
