*** Settings ***
Documentation     author: Bhanu Vamsi
...               contact: vamsi.gundlur@nokia.com
...               Description:FR2 SA option-2 basic call with FWA

Resource          ../../../Resources/robot/ue_operations.robot
Resource          ../../../Resources/robot/suite_common_keywords.robot

Suite Setup       Common Suite Setup    feature_folder=CB008285

*** Variables ***
${WTS_CFG_PATH}                        ${CURDIR}/Config_Files/wts
${NUMBER_OF_CELLS}                     2
@{SA_UE_List}                          1    2
@{dl_tput_list}                        150    150    150
${multi_dl_tput}                       175
${ul_tput}                             70


*** Test Cases ***
CB008285_TC1_Basic call with SA option_2 FWA
    [Documentation]    Verify FR2 SA option-2 basic call with FWA
    [Tags]    AP_REG    CB008285_TC1
    [Setup]    Generic Test Setup    feature=CB008285    cell_deployment=SA
    Register For SA UEs    sa_ue_list=${SA_UE_List}
    Start Traffic for multiple SA UEs    ue_list=${SA_UE_List}    downlink_tput=${multi_dl_tput}
    Sleep    30s
    Validate UE stats for multiple UEs    ${SA_UE_List}    ${multi_dl_tput}    ${ul_tput}    scell=${SA_Scell_Index}
    Validate Bearer Stats for multiple UEs    ue_list=${SA_UE_List}    expected_dl_tput=${multi_dl_tput}    expected_ul_tput=${ul_tput}    mode=SA
    Stop Traffic And Detach SA UEs    sa_ue_list=${SA_UE_List}
    [Teardown]    Generic Test Teardown    feature=CB008285    sa_ue_list=${SA_UE_List}    scf_update=false
