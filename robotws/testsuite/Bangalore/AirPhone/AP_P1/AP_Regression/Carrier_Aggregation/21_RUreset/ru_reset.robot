*** Settings ***
Documentation     author: kusuma S
...               contact: kusuma.s@nokia.com

Resource    ../CA_Common_Keywords.robot
Suite Setup       Suite Setup    feature_folder=21_RUreset

*** Variables ***
${WTS_DIR}                   /opt/wts/latest/
${WTS_CFG}                   basic_setup.cfg
@{sa_ue_list}                1
${UL_tput}                   3
${DL_tput}                   5
${ue_id}                     1
${nooftimesreset}            2

*** Test Cases ***
RU_reset via WebGUI
    [Documentation]    This testcase is mainly for reset the radio modules and checking the traffic
    [Tags]    AP_REG    Reset_TC1
    [Setup]    Test Setup
    FOR    ${reset}    IN RANGE    ${nooftimesreset}
        RU reset via webgui
        Register and Start Traffic For SA UEs    sa_ue_list=${sa_ue_list}    uplink_tput=${UL_tput}    downlink_tput=${DL_tput}
        sleep    5
        Validate throughput from bearer stats    ue_id=${ue_id}     expected_dl_tput=${DL_tput}
        ...    expected_ul_tput=${UL_tput}    mode=SA
        Stop Traffic and Detach SA UEs    sa_ue_list=${sa_ue_list}
        sleep    30sec
    END
    [Teardown]    Test Teardown    sa_ue_list=${sa_ue_list}
