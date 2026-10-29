*** Settings ***

Documentation     author: Himanshu Singh
...               contact: himanshu.3.singh@nokia.com
...               Description: Testing CB009514D 8DL2UL scenario for Cell Lock Unlock

Resource        ../../../Resources/robot/ue_operations.robot
Resource        ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB009514D_8DL2UL

*** Variables ***
${WTS_FILE}                      basic_setup.lua
${WTS_CFG_PATH}                  ${CURDIR}/Config_Files_8DL2UL/wts
${dl_tput}                       100
${ul_tput}                       10
@{SA_UE_List}             1    2    3    4    5    6    7    8    9    10
@{logical_cell_list}             1
${EDAEMON_PORT}                  50000

*** Test Cases ***
CB009514D_8DL2UL_Verify Lock Unlock scenario in 7.2e
    [Documentation]    Verify Cell Lock and Unlock for 8DL2UL
    [Tags]    AP_REG    CB009514D_8DL2UL_TC1
    [Setup]    Generic Test Setup    feature=CB009514D_8DL2UL    cell_deployment=SA        syslog_err_count=255
    FOR    ${index}    IN RANGE    3
        Run Keyword If    '${index}' != '0'    Perform NR Cell Lock and Unlock
        Register and Start Traffic For SA UEs    ${SA_UE_List}    ${ul_tput}    ${dl_tput}
        Sleep    30s
        Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${dl_tput}
        ...    expected_ul_tput=${ul_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${SA_UE_List}
    END
    [Teardown]    Simple Test Teardown    ${SA_UE_List}
