*** Settings ***
Documentation    Running test as profile
...              Hardcoded solution for
...              1_16_UTESRAN2007
...              CLOUD_SRAN_LWG_FSMF_FBBC_AHFIB_LM
...              as target solution do not use data about configs of BTS
...              need to change that in that which are running

Library          DateTime
Library          OperatingSystem
Library          String
Library          BuiltIn
Library          taf.sbts.oam.coam.admin
Library          taf.rfrl.common_resources.reporting_portal.bts_metadata

*** Variables ***
&{BTS_PARAMS}           admin_connection=CLOUD2007
...                     scout_bts_name=1_16_CLOUD2007
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
    ...    ${CURDIR}/../../../LM_tools/LM_IP_Traffic_Guard_Checker_5G_1liner.robot

[1][1.0] OAM_LM_CB006894_013_limitation_action_multiple_verification_RM_Rel.5

    [Tags]    QC_452372    QCD_MN_RAN    QCP_RAN_VRF
    #Run Test For Given Path   OAM_LM_FP_FSMF_CB006894_013_limitation_action_multiple_verification_RM_Rel5
    Run Test For Given Path   OAM_LM_CB006894_013_limitation_action_multiple_verification_RM_Rel.5
    ...    ${CURDIR}/../../../LM_FP/LM_FP_FSMF_CB006894_013_limitation_action_multiple_verification_RM_Rel5.robot
    Report Scout ID

[1][1.0] WRO5_LM_CB006584_29_Reset_during_limitation
    [Tags]    QC_452373    QCD_MN_RAN    QCP_RAN_VRF
    Run Test For Given Path   WRO5_LM_CB006584_29_Reset_during_limitation
    ...    ${CURDIR}/../../../LM_FP/LM_FP_FSMF_CB006584_29_Reset_during_limitation.robot
    Report Scout ID

*** Keywords ***
Report Scout ID
    [Documentation]    Adding BTS metadata to report
    Setup Admin  name=CLOUD2007
    Run Keyword And Ignore Error    Add Bts Metadata To Report    bts_params=${BTS_PARAMS}
    Teardown Admin  connection=CLOUD2007

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

