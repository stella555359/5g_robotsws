*** Settings ***
Documentation    Running test as profile
...              Hardcoded solution for
...              10_16_UTESRAN3719
...              CLOUD_SRAN_N_ASOH_AZQP_LM
...              as target solution do not use data about configs of BTS
...              need to change that in that which are running

Library          DateTime
Library          OperatingSystem
Library          String
Library          BuiltIn
Library          taf.sbts.oam.coam.admin
Library          taf.rfrl.common_resources.reporting_portal.bts_metadata

*** Variables ***
&{BTS_PARAMS}           admin_connection=UTESRAN3719
...                     scout_bts_name=10_16_UTESRAN3719
${NMS_LAB}              srnclab2009

*** Test Cases ***
OAM_LM_Preliminary_Upgrade
    [Tags]    SKIP_REPORT
    Run Test For Given Path    LM_Preliminary_ST47STUB
    ...    ${CURDIR}/../../../LM_tools/LM_Preliminary_Upgrade/ST47STUB.robot

OAM_Changer_LM
    [Tags]    SKIP_REPORT
    Run Test For Given Path    OAM_Changer_LM_v2
    ...    ${CURDIR}/../../../LM_tools/LM_Clab_Setup.robot

OAM_LM_IP_Traffic_Guard_Changer
    [Tags]    SKIP_REPORT
    Run Test For Given Path    OAM_IpTrafficGuard_checker
    ...    ${CURDIR}/../../../LM_tools/LM_IP_Traffic_Guard_Checker_5G_2liner.robot

[1][1.0] OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R
    [Tags]    QC_217052    QCD_MN_RAN    QCP_RAN_VRF
    Run Test For Given Path   OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R
    ...    ${CURDIR}/../../../100797_CRT/OAM_LM_CB011088-D_003_ASOGH_NR_TDD_cell_set_upto_100MHz_4T4R.robot
    Report Scout ID

*** Keywords ***
Report Scout ID
    [Documentation]    Adding BTS metadata to report
    Setup Admin  name=UTESRAN3719
    Run Keyword And Ignore Error    Add Bts Metadata To Report    bts_params=${BTS_PARAMS}
    Teardown Admin  connection=UTESRAN3719

Run Test For Given Path
    [Documentation]    Running test for given path
    [Arguments]    ${test_name}    ${path_to_test}
    ${current_date}=    DateTime.Get Current Date    result_format=%d%m%Y%H%M%S    exclude_millis=True
    ${testline_localisation}    ${testline_label}=    Split String    ${CONFIGURATION}    .
    ${testline_localisation}=    Strip String    ${testline_localisation}
    ${testline_label}=    Strip String    ${testline_label}
    ${robot_command_parts}=    Set Variable    robot -X --variable NMS_LAB:${NMS_LAB} --variable CONFIGURATION:${CONFIGURATION} \
    ...    -V /home/ute/testline_configuration/${testline_label}/__init__.py --variable ENB_MPLANE_IP:192.168.255.129 \
    ...    --variable RESULTS:${OUTPUT_DIR}/${current_date}_${test_name} -L TRACE -b ${OUTPUT_DIR}/${current_date}_${test_name}/debug.log \
    ...    -d ${OUTPUT_DIR}/${current_date}_${test_name}/ ${path_to_test}
    ${robot_command}=    Evaluate    ''.join(${robot_command_parts})
    ${rc}    ${output}=    Run and Return RC and Output    ${robot_command}
    Log    ${output}    console=true
    Should Be Equal As Integers    ${rc}    0
