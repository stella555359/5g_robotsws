*** Settings ***
Documentation
...   author: Patryk Janas
...   contact: patryk.janas@nokia.com
...   This is the ROBOT KEYWORDS file for feature CB006030

Variables    testsuite/Wroclaw/RRM/VRF_WRO2_T07/regression/config_path.py

Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB006030/resources/keywords_netact.py
Library      testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB006030/resources/test_keywords.py
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils.AdminUtils    WITH NAME    AdminUtils
Library      testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation    WITH NAME    testline_preparation


*** Variables ***
${ORG_SW_VERSION}
${ORG_SW_PATH}
${20A_SW_PATH}
${20A_SW_VERSION}=  9.1800.1537
${SCF_PATH}=        ${testline_config_dir}/scf/scf_20A.xml


*** Keywords ***
[1][1.0] CB006030_A_Migration_via_NetAct
    Netact sw upload                   ${ORG_SW_VERSION}   ${ORG_SW_PATH}
    Netact provision software          ${ORG_SW_VERSION}   ${mrbts_id}
    BuiltIn.Sleep                              180s
    AdminUtils.wait_for_all_cells_on_air_state
    Adj object check
    Wait until keyword succeeds        600  30    X2 link availability
    Wait until keyword succeeds        900  30    Xn link availability


[1][1.0] CB006030_A_Runtime_SCF_Migration_Case#1
    Run keyword if                     '${False}'=='Software version check'    Fail     Wrong software
    Scf update                         ${SCF_PATH}
    BuiltIn.Sleep                              180s
    AdminUtils.wait_for_all_cells_on_air_state
    Adj object check
    Wait until keyword succeeds        600  30    X2 link availability
    Wait until keyword succeeds        900  30    Xn link availability


TestCase setup
    ${ORG_SW_VERSION}=   Get sw version from bts
    Set global variable    ${ORG_SW_VERSION}  ${ORG_SW_VERSION}
    ${ORG_SW_PATH}=      Download current sw build
    Set global variable    ${ORG_SW_PATH}     ${ORG_SW_PATH}
    ${20A_SW_PATH}=      Download software from artifactory  ${20A_SW_VERSION}
    Set global variable    ${20A_SW_PATH}     ${20A_SW_PATH}


Netact setup
    TestCase setup
    Configuration reset
    BuiltIn.Sleep                           600s
    Sw update       ${20A_SW_PATH}    ${20A_SW_VERSION}
    AdminUtils.wait_for_all_cells_on_air_state
    Scf update      ${SCF_PATH}


Netact teardown
    Netact clean    ${ORG_SW_VERSION}
    Teardown clean  ${ORG_SW_PATH}    ${ORG_SW_VERSION}

Start setup
    ${ORG_SCF_PATH}=       Save current scf   ORG_SCF.xml
    Set global variable    ${ORG_SCF_PATH}    ${ORG_SCF_PATH}
