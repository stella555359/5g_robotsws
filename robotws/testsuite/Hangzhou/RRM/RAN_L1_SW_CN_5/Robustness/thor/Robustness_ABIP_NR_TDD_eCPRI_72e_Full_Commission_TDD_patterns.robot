*** Settings ***
Documentation
...    Author:  Jiang Wei
...    Feature: Robustness

Suite Setup       common_resource_suite.Common Suite Setup
Suite Teardown    common_resource_suite.Common Suite Teardown

Test Setup        common_resource_suite.Common Test Setup
Test Teardown     common_resource_suite.Common Test Teardown
Resource          ../../resources/common_resources.robot
Force Tags    5G_RAN_TDD    QL3    SBTS00    QCD_MN_RAN    QCP_RAN_RF

*** Variables ***
@{ALLOWED_FAULT}
&{enable_72e_dict}    actEcpri72e=Ecpri72eULDL
&{disable_72e_dict}    actEcpri72e=disabled
${cellband}    78

${scfc_file_1cell_A1}    Robustness_scf_BTS11148_ABIP_AVQL_NRTDD_eCPRI_72e_100M_1208_A1.xml
${scfc_file_1cell_A3}    Robustness_scf_BTS11148_ABIP_AVQL_NRTDD_eCPRI_72e_100M_1070_A3.xml
${scfc_file_1cell_A8}    Robustness_scf_BTS11148_ABIP_AVQL_NRTDD_eCPRI_72e_100M_1116_A8.xml
${scfc_file_1cell_72e}    ABIP_AVQL_NRTDD_100M_A1_gscn_640000_1xNRCELL_72e.xml

*** Test Cases ***
Robustness_ABIP_NR_TDD_eCPRI_Full_Commission_TDD_patterns
    [Tags]    QL3    Trunk    Robustness    ABIP    TddPattern    jw
    FOR    ${round}    IN RANGE    1
        Log To Console     --------------------------------------- Round-${round} Starting ----------------------------------------
        Full Commission TDDFrameStructure    A1
        SMAwave L3 call    180125707    500M    140M    10%    5G    ${cellband}
        Full Commission TDDFrameStructure    A3
        SMAwave L3 call    180125707    450M    220M    10%    5G    ${cellband}
        Full Commission TDDFrameStructure    A8
        SMAwave L3 call    180125707    500M    140M    10%    5G    ${cellband}
        Log To Console     ------------------------------------------ Round-${round} END ------------------------------------------
    END

*** Keywords ***
Full Commission TDDFrameStructure
    [Arguments]    ${tdd_pattern}=A1
    ${scf_file}    Run Keyword If    '${tdd_pattern}'=='A1'    Set Variable    ${scfc_file_1cell_A1}
    ...    ELSE IF    '${tdd_pattern}'=='A3'    Set Variable    ${scfc_file_1cell_A3}
    ...    ELSE IF    '${tdd_pattern}'=='A8'    Set Variable    ${scfc_file_1cell_A8}
    ...    ELSE    Log To Console    [ERROR] tdd pattern should be A1 | A3 | A8.
    Configure TL With Vendor Update    ${enable_72e_dict}    ${SCFC_path}/Robustness/${btsid}/${scf_file}    ${btsid}
