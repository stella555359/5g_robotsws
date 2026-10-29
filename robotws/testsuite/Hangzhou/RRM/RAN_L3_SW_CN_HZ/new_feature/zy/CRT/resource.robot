*** Settings ***
Documentation
...    author: Zhang Yin
...    contact: yin.zhang@nokia-sbell.com
...    squad group: NSB_MN_RAN_RD_VRF_HAZ3_07
Library           Process
Library           OperatingSystem

*** Variables ***
${CONFIGURATION}    Wroclaw.7_16_UTE5GAP099    # will overwrite by UTE agent

*** Keywords ***
Run Test Suite
    [Arguments]    ${suite}
    ${out}    Process.Run Process    hostname
    ${robot_cmd}    catenate    robot -L TRACE -d ${OUTPUT_DIR}/${TEST_NAME}
    ...    -v ERR_WRN_STATISTICS:True
    ...    -v CONFIG_WA:False
    ...    -v CONFIGURATION:${CONFIGURATION}
    ...    -V /home/ute/testline_configuration/${out.stdout.replace("-","_")}
    ...    --pythonpath /home/ute/MN/UTE/robotws
    ...    -e not-ready
    ...    ${suite} | tee -a ${ROBOT_LOG}
    ${result}    Process.Run Process    ${robot_cmd}
    ...    shell=True
    Log    ${result.rc}
    Log    ${result.stdout}
    Log    ${result.stderr}
    ${status}    Run Keyword And Return Status    Should Contain    ${result.stdout}    passed, 0 failed
    Run Keyword If    ${status}    Log To Console    ${EMPTY}
    Run Keyword If    ${status}    Log To Console    ${result.stdout.splitlines()[-5]}
    Run Keyword If    not ${status}    Fail    ${result.stderr}

Suite Setup
    Set Suite Variable    ${ROBOT_LOG}    ${OUTPUT_DIR}/robot.log
    Create File    ${ROBOT_LOG}
