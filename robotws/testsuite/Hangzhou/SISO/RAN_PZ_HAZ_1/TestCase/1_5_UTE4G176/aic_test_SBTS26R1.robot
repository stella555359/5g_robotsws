*** Settings ***
Documentation    Suite description
...    Author:        len.lin@nokia-sbell.com
...    Maintainer:    lin len

Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/AIC/robot/aic_setup_teardown.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/AIC/robot/aic_test_fv.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/AIC/robot/bts/aic_bts_common_oam.robot
#Resource    ../../l3call.robot
Resource    ../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/siso_resources/AIC/robot/aic_common_interface.robot

Suite Setup    Cloud Suite Precondition
Suite Teardown    Cloud Suite Postcondition

*** Variables ***
#&{T3}    CUS=CU_0:vDU_0:T3    ONAIR_TIME=20 min
#...    peak_rate_config={"301":[325,126],"302":[325,126],"303":[325,126]}

#&{T3_AZQS}    CUS=CU_0:vDU_0:T3_AZQS    ONAIR_TIME=30 min
#...    peak_rate_config={"301":[275,25],"302":[275,25],"303":[265,25]}
&{T1}    CUS=CU_0:vDU_0:T1    ONAIR_TIME=20 min
...    peak_rate_config={"91":[325,126],"92":[325,126]}

#${online_para}    {"CU_0-vDU_0":{"MRBTS-37025/NRBTS-37025/NRCELL-1": {'pMax':'40'}}}
#${reset_para}    {"CU_0-vDU_0":{"MRBTS-37025/NRBTS-37025/NRCELL-1": {'nrarfcn':'634000'}}}
#${online_para2}    {"CU_0-vDU_0":{"MRBTS-37025/NRBTS-37025/NRCELL-2": {'pMax':'34'}}}
#${reset_para2}    {"CU_0-vDU_0":{"MRBTS-37025/NRBTS-37025/NRCELL-2": {'nrarfcn':'642000'}}}

${delta_json_1}=    ${CURDIR}/delta_json_1.json
${delta_json}=    ${CURDIR}/delta_json.json

${GLO_TL_DESCRIPTOR_FILE_PATH}=      ${CURDIR}/TLdescriptor.xml
@{ADDITIONAL_VDU_ALLOWED_ALARMS}    PTP Master port Q_RF1_1 disabled    PTP Master port Q_RF1_2 disabled
@{ADDITIONAL_CU_ALLOWED_ALARMS}    Matching ServedCell not found over F1-C

#${INIT_CONFIG_ID}    T1
*** Test Cases ***

[1]Manual_SiSo_CM_Recommissioning
    [Tags]    QC_252159    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Cloud Testcase Basic Precondition    config_id=T1
    SiSo_CM_vDU_Recommissioning    vdu_delta_json=${delta_json_1}
    [Teardown]    Cloud Testcase Basic Postcondition

[1]Cell Block unblock
    [Tags]    QC_252158    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Cloud Testcase Basic Precondition    config_id=T1
    vDU Cells Block Unblock
    [Teardown]    Cloud Testcase Basic Postcondition

[2]Manual_SiSo_CM_Recommissioning
    [Tags]    QC_252157    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Cloud Testcase Basic Precondition    config_id=T1
    SiSo_CM_vDU_Recommissioning    vdu_delta_json=${delta_json}
    [Teardown]    Cloud Testcase Basic Postcondition

[1][1.0] Cloud_General_Status_RANNIC_reset_via_WebEM
    [Tags]    QC_252160    QCD_MN_RAN    QCP_RAN_VRF
    [Setup]    Cloud Testcase Basic Precondition    config_id=T1
    vDU RANNIC Reset    37025
    [Teardown]    Cloud Testcase Basic Postcondition



#Tput
#    [Tags]    QC_596492    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Cloud Testcase Basic Precondition     config_id=T3_AZQS
#    Make Tput
#    [Teardown]    Cloud Testcase Basic Postcondition

#Onair
#    [Tags]    QC_596339    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Cloud Testcase Basic Precondition
#    vDU Reset     required_cells=303
#    [Teardown]    Cloud Testcase Basic Postcondition

#<RU reset
#    [Tags]    QC_596340    QCD_MN_RAN    QCP_RAN_ST
#    [Setup]    Cloud Testcase Basic Precondition
#    vDU RF Module Reset    required_cells=303
#    [Teardown]    Cloud Testcase Basic Postcondition

*** Keywords ***
SiSo_CM_vDU_Recommissioning
    [Arguments]    ${cu_delta_json}=${Empty}    ${vdu_delta_json}=${Empty}
#    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}    ${required_cells}=${EMPTY}
#    [Documentation]
#    ...    Author: haoyun-lyle.sheng@nokia-sbell.com
#    ...    Maintainer: haoyun-lyle.sheng@nokia-sbell.com
#    ...    Example:
#    ...    ${reset_para}=["CU_0-vDU_0":{"dist_name1":{'para_name1':'para_value1','para_name2':'para_value2',...},...}]
#    ...    ${online_para}=["CU_0-vDU_0":{"dist_name1":{'para_name1':'para_value1','para_name2':'para_value2',...},...}]
#    ...    ${related_cu_para}={"CU_0":[{"distname1":
#    ...    [{"operation_type":"replace", "parameter_path":"parameter_path1","value":"value1"},...]},...],...}
#    ${cu_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${related_cu_para}
#    ${cu_para}    Run Keyword If    ${cu_para_status}    Evaluate    ${related_cu_para}
#    ${cu_index_list}    Run Keyword If    ${cu_para_status}    Get Dictionary Keys    ${cu_para}
#    ...    ELSE    Create List
#    FOR    ${cu_index}    IN    @{cu_index_list}
#        vCU Multi Parameters Recommission    ${cu_para["${cu_index}"]}    force_reset=${True}    cu_index=${cu_index}
#    END
#    ${reset_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${reset_para}
#    ${reset_para}    Run Keyword If    ${reset_para_status}    Evaluate    ${reset_para}    ELSE    Create List
#    ${reset_vdu_index_list}    Run Keyword If    ${reset_para_status}    Get Dictionary Keys    ${reset_para}
#    ...    ELSE    Create List
#    FOR    ${reset_vdu_index}    IN    @{reset_vdu_index_list}
#        ${vdu_index}    ${cu_index}    Split String    ${reset_vdu_index}    -
#        vDU Multi Parameters Recommission By Delta Plan    ${reset_para["${reset_vdu_index}"]}    operation=replace
#        ...    recommission_type=site_reset    vdu_index=${vdu_index}    cu_index=${cu_index}
#    END
#    ${online_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${online_para}
#    ${online_para}    Run Keyword If    ${online_para_status}    Evaluate    ${online_para}    ELSE    Create List
#    ${online_vdu_index_list}    Run Keyword If    ${reset_para_status}    Get Dictionary Keys    ${online_para}
#    ...    ELSE    Create List
#    FOR    ${online_vdu_index}    IN    @{online_vdu_index_list}
#        ${vdu_index}    ${cu_index}    Split String    ${online_vdu_index}    -
#        vDU Multi Parameters Recommission By Delta Plan    ${online_para["${online_vdu_index}"]}    operation=replace
#        ...    recommission_type=online    vdu_index=${vdu_index}    cu_index=${cu_index}
#    END
    ${cu_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${cu_delta_json}
    ${vdu_para_status}    Run Keyword And Return Status    Should Not Be Empty    ${vdu_delta_json}
    Run Keyword If    ${cu_para_status}
    ...    vCU Multi Parameters Recommission    ${cu_delta_json}
    ...    ELSE IF    ${vdu_para_status}
    ...    vDU Multi Parameters Recommission By Delta Plan    ${vdu_delta_json}
    ...    ELSE    Fail
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs
    ...    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs
    ...    additional_allowed_alarms=Previously downloaded plan dp_00000000 was overwritten by a new plan dp_00000000

vDU Cells Block Unblock
    [Arguments]    ${cell_id_list}=${ALL_CELL_LIST}    ${vdu_index}=vDU_0    ${cu_index}=CU_0
#    ...    ${extra_peak_rate_config}=${PEAK_RATE_CONFIG}
    Login To vDU By Rest    vdu_index=${vdu_index}    cu_index=${cu_index}
    FOR    ${cell_id}    IN    @{cell_id_list}
        ${out}    vdu.block_cell    cell_id=${cell_id['cellId']}
        Wait Until Keyword Succeeds    60    5    vDU Check Block Cell Operation Status
        ...    operation_id=${out["id"]}    expected_status=success
        ${out}    vdu.unblock_cell    cell_id=${cell_id['cellId']}
        Wait Until Keyword Succeeds    60    5    vDU Check Unblock Cell Operation Status
        ...    operation_id=${out["id"]}    expected_status=success
    END
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Cell blocked
    Check Historical Alarms In vDUs    additional_allowed_alarms=Cell blocked
    [Teardown]    Run Keyword And Ignore Error    Logout To vDU By Rest

vDU RANNIC Reset
    [Arguments]    ${mrbts_id}
    vDU Reset Rannic And Check Onair For All CUs    ${mrbts_id}
    vDU Lock Unlock All RUs And Check Status For All CUs
    Check RU List Status Should Be As Expected
    Check Alarms In CUs
    Check Alarms In vDUs
    Check Historical Alarms In CUs    additional_allowed_alarms=Matching ServedCell not found over F1-C
    Check Historical Alarms In vDUs
#    Make Tput    extra_peak_rate_config=${extra_peak_rate_config}    required_cells=${required_cells}
