*** Settings ***
Documentation       Test case for BOAM ET
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Suite Setup       Common BTS Suite Setup
Suite Teardown    Common BTS Suite Teardown
Test Setup        Private Test Setup
Test Teardown     Common BTS Test Teardown
Force Tags        TEAM-BTS_MANO_SOAM5    FEATURE-CB006530-5G-A    CRT    CLOUD_5G_I_LN_AP_LO_SANSA_FS_ECPRI_CMWV_TDD
...    SBTS00    SBTS23R1    RAN_5G_TDD    RAN_5G    OWNER-jet_li.li
Resource          ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/BOAM_ET/TAF_Common_Resource.robot
Library           OperatingSystem
Library           XML
Library           Process

*** Test Cases ***
#CB006530-5G-A_05_Activate the restriction of cell parameters by specific child parameter in a structure is restricted
#    ${BWP_PROFILE_DN}    Set Variable    MRBTS-${BTS_INFO.ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-1
#    Create Delta    delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-cellBwpList.cellBwpId    delta_id=delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
#    ${delta1_data}    Get Delta    delta1
#    Log    ${delta1_data}
#    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
#    Create Delta    delta2
#    Append Complex Item To Delta    ${NRCELL_DN}    list_name=cellBwpList    cellBwpId=2    bwpDN=${BWP_PROFILE_DN}    delta_id=delta2
#    ${delta2_data}    Get Delta    delta2
#    Log    ${delta2_data}
#    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta2_data}    skip_parameter_relation_errors=True
#    Log    ${feedback}
#    Should Be Equal    ${feedback[0]}    FAIL
#    Should Contain    ${feedback[1]}    Modification of restricted parameter NRCELL-1-[cellBwpList.cellBwpId] is not allowed
#
#CB006530-5G-A_06_Activate the restriction of cell parameters where full structure are restricted
#    ${BWP_PROFILE_DN}    Set Variable    MRBTS-${BTS_INFO.ID}/NRBTS-${NRBTS_ID}/BWP_PROFILE-2
#    Create Delta    delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-cellBwpList    delta_id=delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
#    ${delta1_data}    Get Delta    delta1
#    Log    ${delta1_data}
#    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
#    Create Delta    delta2
#    Append Complex Item To Delta    ${NRCELL_DN}    list_name=cellBwpList    cellBwpId=2    bwpDN=${BWP_PROFILE_DN}    delta_id=delta2
#    ${delta2_data}    Get Delta    delta2
#    Log    ${delta2_data}
#    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta2_data}    skip_parameter_relation_errors=True
#    Log    ${feedback}
#    Should Be Equal    ${feedback[0]}    FAIL
#    Should Contain    ${feedback[1]}    Modification of restricted parameter NRCELL-1-[cellBwpList] is not allowed
#
#CB006530-5G-A_07_Activate the restriction of cell parameters where specified parameter under MOC is restricted
#    ${Scf}    ADMIN Get SCF
#    ${current_value}    BTS Get ParaValue    ${Scf}    actAperCsi    com.nokia.srbts.nrbts:NRCELL    ${NRCELL_DN}
#    ${new_value}    Set Variable If    '${current_value}' == 'true'    false    true
#    Create Delta    delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-actAperCsi    delta_id=delta1
#    ${delta1_data}    Get Delta    delta1
#    Log    ${delta1_data}
#    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
#    ${feedback}    Run Keyword and Ignore Error    coam.Perform Parameter Recommissioning
#    ...    ${NRCELL_DN}    actAperCsi    update    ${new_value}    skip_parameter_relation_errors=True
#    Log    ${feedback}
#    Should Be Equal    ${feedback[0]}    FAIL
#    Should Contain    ${feedback[1]}    Modification of restricted parameter NRCELL-1-[actAperCsi] is not allowed
#    ${feedback2}    Run Keyword and Ignore Error    coam.Perform Parameter Recommissioning
#    ...    ${NRCELL2_DN}    actAperCsi    update    ${new_value}    skip_parameter_relation_errors=True
#    Log    ${feedback2}
#    Should Be Equal    ${feedback2[0]}    FAIL
#    Should Contain    ${feedback2[1]}    Modification of restricted parameter NRCELL-2-[actAperCsi] is not allowed
#    ${Case_Status13}    Set Variable    PASS
#    Set Suite Variable    ${Case_Status13}
#
#CB006530-5G-A_11_Validate invalid restricted parameters failure from NMS
#    [Documentation]    This case will cover all kinds of invalid restricted parameters
##    Check Feedback Type1
#    Check Feedback Type2
#    Check Feedback Type6
#
#CB006530-5G-A_02_Activation or creation of restriction list in a full configuration plan by Ne3s User
#    Run Keyword If    '${Case_Status13}'=='PASS'    Pass Execution    already covered by case 07    ELSE    Fail
#
#CB006530-5G-A_13_Check restricted parameters without target cell manage objects defined will apply to all cells
#    Run Keyword If    '${Case_Status13}'=='PASS'    Pass Execution    already covered by case 07    ELSE    Fail

#CB006530-5G-A_14_BTS reject the delta plan when preventParamModifTargetDN elements pointing MO instance does not exist
#    Run Keyword If    '${Case_Status14}'=='PASS'    Pass Execution    already covered by case 11    ELSE    Fail

#CB006530-5G-A_17_BTS reject the delta plan when preventParamModifList MOC does not exist in the configuration based on merging plan
#    Create Delta    delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-pMax    delta_id=delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
#    Append managed object to delta  ${NRCELL_DN}    operation=delete    delta_id=delta1
#    ${delta1_data}    Get Delta    delta1
#    Log    ${delta1_data}
#    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}    skip_parameter_relation_errors=True
#    Log    ${feedback}
#    Should Be Equal    ${feedback[0]}    FAIL
#    Should Contain    ${feedback[1]}
#    ...    MOC of restricted parameter preventParamModifTargetDN:[/${NRCELL_DN}] does not exist in any cell-level parameter
#    Should Contain    ${feedback[1]}    corresponding to the cell's technology

CB006530-5G-A_18_BTS reject the delta plan when preventParamModifTargetDN has no related restricted parameter defined based on merged plan
    Create Delta    delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-pMax    delta_id=delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
    ${delta1_data}    Get Delta    delta1
    Log    ${delta1_data}
    coam.Perform Delta Recommissioning    ${delta1_data}    skip_parameter_relation_errors=True
    Create Delta    delta2
    Append Parameter Delete To Delta    ${FEATCADM_DN}    preventParamModifList    delta_id=delta2
    ${delta2_data}    Get Delta    delta2
    Log    ${delta2_data}
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta2_data}    skip_parameter_relation_errors=True
    Log    ${feedback}
    Should Be Equal    ${feedback[0]}    FAIL
    Should Contain    ${feedback[1]}    Restricted parameter in the list and targetDN are in different technology.
    Should Contain    ${feedback[1]}
    ...    preventParamModifTargetDN:[/${NRCELL_DN}] cannot find restricted parameter in preventParamModifList with same technology

CB006530-5G-A_19_BTS reject the delta plan when MO is not the same even subMO
    Create Delta    delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL_FDD-nrarfcnDl    delta_id=delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
    ${delta1_data}    Get Delta    delta1
    Log    ${delta1_data}
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}    skip_parameter_relation_errors=True
    Log    ${feedback}
    Should Be Equal    ${feedback[0]}    FAIL
    Should Contain    ${feedback[1]}    Restricted parameter in the list and targetDN are in different technology.
    Should Contain    ${feedback[1]}
    ...    preventParamModifTargetDN:[/${NRCELL_DN}] cannot find restricted parameter in preventParamModifList with same technology

#CB006530-5G-A_20_BTS accept the delta plan when parameter is not restricted based on merging plan
#    ${Scf}    ADMIN Get SCF
#     ${current_value}    BTS Get ParaValue    ${Scf}    a1MeashoEnabled    com.nokia.srbts.nrbts:NRCELL    ${NRCELL_DN}
#    ${new_value}    Set Variable If    '${current_value}' == 'none'    rsrp    none
#    Create Delta    delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-pMax    delta_id=delta1
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
#    Append Parameter Update To Delta    ${NRCELL2_DN}    a1MeashoEnabled    ${new_value}    delta_id=delta1
#    ${delta1_data}    Get Delta    delta1
#    Log    ${delta1_data}
#    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
#    ${Scf}    ADMIN Get SCF
#    ${current_value}    BTS Get ParaValue    ${Scf}    a1MeashoEnabled    com.nokia.srbts.nrbts:NRCELL    ${NRCELL2_DN}
#    Should Be Equal    ${current_value}    ${new_value}

CB006530-5G-A_27_Modify the restrictions by adding and deleting the target cell managed objects and restricted parameters from WEBEM
    ${Scf}    ADMIN Get SCF
    ${current_value}    BTS Get ParaValue    ${Scf}    actAperCsi    com.nokia.srbts.nrbts:NRCELL    ${NRCELL_DN}
    ${new_value}    Set Variable If    '${current_value}' == 'true'    false    true
    ${current_value2}    BTS Get ParaValue    ${Scf}    a1MeashoEnabled    com.nokia.srbts.nrbts:NRCELL    ${NRCELL_DN}
    ${new_value2}    Set Variable If    '${current_value2}' == 'none'    rsrp    none
    Create Delta    delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-actAperCsi    delta_id=delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRCELL_DN}    delta_id=delta1
    ${delta1_data}    Get Delta    delta1
    Log    ${delta1_data}
    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
    Create Delta    delta2
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-actAperCsi    delta_id=delta2
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-a1MeashoEnabled    delta_id=delta2
    ${delta2_data}    Get Delta    delta2
    Log    ${delta2_data}
    coam.Perform Delta Recommissioning    ${delta2_data}  skip_parameter_relation_errors=True
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Parameter Recommissioning
    ...    ${NRCELL_DN}    actAperCsi    update    ${new_value}    skip_parameter_relation_errors=True
    Log    ${feedback}
    Should Be Equal    ${feedback[0]}    FAIL
    Should Contain    ${feedback[1]}    Modification of restricted parameter NRCELL-1-[actAperCsi] is not allowed
    ${feedback2}    Run Keyword and Ignore Error    coam.Perform Parameter Recommissioning
    ...    ${NRCELL_DN}    a1MeashoEnabled    update    ${new_value2}    skip_parameter_relation_errors=True
    Log    ${feedback2}
    Should Be Equal    ${feedback2[0]}    FAIL
    Should Contain    ${feedback2[1]}    Modification of restricted parameter NRCELL-1-[a1MeashoEnabled] is not allowed
    Create Delta    delta3
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-actAperCsi    delta_id=delta3
    ${delta3_data}    Get Delta    delta3
    Log    ${delta3_data}
    coam.Perform Delta Recommissioning    ${delta3_data}  skip_parameter_relation_errors=True
    coam.Perform Parameter Recommissioning    ${NRCELL_DN}    a1MeashoEnabled    update    ${new_value2}    skip_parameter_relation_errors=True
    ${Scf}    ADMIN Get SCF
    ${current_value2}    BTS Get ParaValue    ${Scf}    a1MeashoEnabled    com.nokia.srbts.nrbts:NRCELL    ${NRCELL_DN}
    Should Be Equal    ${current_value2}    ${new_value2}

*** Keywords ***
Delete NRCELL
    Create Delta    delta
    Append managed object to delta  ${NRCELL2_DN}    operation=delete    delta_id=delta
    Append managed object to delta  MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-2    operation=delete    delta_id=delta
    Append List Items To Delta    ${NRBTS_DN}/NRCELLGRP-0    nrCellList    1    delta_id=delta
    ${delta_data}    Get Delta    delta
    Log    ${delta_data}
    coam.Perform Delta Recommissioning    ${delta_data}    skip_parameter_relation_errors=True

Private Test Setup
    Common BTS Test Setup
    Set MRBTS DN
    Remove All Delta Id
    Clear Restrict Parameters
    Set NRCELL DN

Private Suite Teardown
    Common Suite Teardown

Set NRCELL DN
    ${Scf}    ADMIN Get SCF
    ${result}    Process.run process    cat ${Scf} | grep 'NRBTS"' | awk -F '"' '{print $4}'    shell=${True}     cwd=${CURDIR}    timeout=30
    ${NRBTS_DN}    Set Variable    ${result.stdout}
    ${result}    Process.run process    cat ${Scf}| grep 'NRBTS"' | awk -F '"' '{print $4}' | awk -F '-' '{print $3}'
    ...    shell=${True}     cwd=${CURDIR}    timeout=30
    ${NRBTS_ID}    Set Variable    ${result.stdout}
    ${NRCELL_DN}    Set Variable    ${NRBTS_DN}/NRCELL-1
    ${NRCELL2_DN}    Set Variable    ${NRBTS_DN}/NRCELL-2
    Set Test Variable    ${NRBTS_DN}
    Set Test Variable    ${NRBTS_ID}
    Set Test Variable    ${NRCELL_DN}
    Set Test Variable    ${NRCELL2_DN}
    Sleep    1 sec

Set MRBTS DN
    ${Scf}    ADMIN Get SCF
    ${result}    Process.run process    cat ${Scf} | grep 'MRBTS"' | awk -F '"' '{print $4}'    shell=${True}     cwd=${CURDIR}    timeout=30
    ${MRBTS_DN}    Set Variable    ${result.stdout}
    ${BTS_INFO.ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable   ${BTS_INFO.ID}
    Set Test Variable   ${FEATCADM_DN}        MRBTS-${BTS_INFO.ID}/MNL-1/MNLENT-1/FEATCADM-1

Clear Restrict Parameters
    Create Delta
    Append Parameter Delete To Delta    ${FEATCADM_DN}    preventParamModifTargetDN
    Append Parameter Delete To Delta    ${FEATCADM_DN}    preventParamModifList
    Save Delta    ${OUTPUT_DIR}/${TEST_NAME}/clear_delta.json
    coam.Perform Delta Recommissioning    ${OUTPUT_DIR}/${TEST_NAME}/clear_delta.json  skip_parameter_relation_errors=True

Prepare Fullplan With Restrict
    [Arguments]    ${modify_list}    ${DN_list}
    ${timestamp}    Get Timestamp
    ${FullPlan}    Set Variable    ${OUTPUT_DIR}/${TEST_NAME}${/}ResrictionFullPlan_${timestamp}.xml
    ${Scf}    ADMIN Get SCF
    ${FullPlanXml}    Parse Xml    ${Scf}
    XML.Add Element    ${FullPlanXml}    ${modify_list}    xpath=.//*[@class="com.nokia.srbts.mnl:FEATCADM"]
    XML.Add Element    ${FullPlanXml}    ${DN_list}    xpath=.//*[@class="com.nokia.srbts.mnl:FEATCADM"]
    Save Xml    ${FullPlanXml}    ${FullPlan}
    [Return]    ${FullPlan}

Prepare Deltaplan With Restrict
    [Arguments]    ${modify_list}    ${DN_list}
    ${timestamp}    Get Timestamp
    ${Deltaplan}    Set Variable    ${OUTPUT_DIR}/${TEST_NAME}${/}ResrictionDeltaPlan_${timestamp}.xml
    ${Scf}    ADMIN Get SCF
    ${FullPlanXml}    Parse Xml    ${Scf}
    ${DeltaPlanXml}    Get Element    ${FullPlanXml}    xpath=.//*[@class="com.nokia.srbts.mnl:FEATCADM"]
    ${DeltaBaseXml}    Parse Xml    ${DeltaBase}
    XML.Add Element    ${DeltaBaseXml}    ${DeltaPlanXml}    xpath=.//*[@type="plan"]
    XML.Add Element    ${DeltaBaseXml}    ${modify_list}    xpath=.//*[@class="com.nokia.srbts.mnl:FEATCADM"]
    XML.Add Element    ${DeltaBaseXml}    ${DN_list}    xpath=.//*[@class="com.nokia.srbts.mnl:FEATCADM"]
    Save Xml    ${DeltaBaseXml}    ${Deltaplan}
    [Return]    ${Deltaplan}

Check Restrictions Exist
    [Arguments]    ${modify_list_value}    ${DN_list_value}
    ${FEATCADM_DN_IM}    Set Variable     MRBTS_A-${BTS_INFO.ID}/MNL_A-1/MNLENT_A-1/FEATCADM_A-1
    ${currentNp}    ADMIN Get Parameters By Dist    /MRBTS-1/RAT-1/BTS_L-1/BTS_CONF-1    currentNp
    ${current_modify_value}    ADMIN Get Parameters By Dist    ${currentNp['currentNp']}/SCF-1/${FEATCADM_DN_IM}     preventParamModifList
    Should Be Equal    ${current_modify_value['preventParamModifList'][0]}    ${modify_list_value}
    ${current_DN_value}    ADMIN Get Parameters By Dist    ${currentNp['currentNp']}/SCF-1/${FEATCADM_DN_IM}     preventParamModifTargetDN
    Should Contain    ${current_DN_value['preventParamModifTargetDN'][0]}    ${DN_list_value}

Check Feedback Type1
    Create Delta    delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-pMax    delta_id=delta1
    # already covered by owner MRT
#    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    LNCEL-pMax    delta_id=delta1
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${NRBTS_DN}/NRCELL-10    delta_id=delta1
    ${delta1_data}    Get Delta    delta1
    Log    ${delta1_data}
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta1_data}  skip_parameter_relation_errors=True
    Log    ${feedback}
    Should Be Equal    ${feedback[0]}    FAIL
    Should Contain    ${feedback[1]}    MOC of restricted parameter preventParamModifTargetDN:[/${NRBTS_DN}/NRCELL-10]
    # already covered by owner MRT
#    Should Contain    ${feedback[1]}    MOC of restricted parameter preventParamModifTargetDN:[/${NRBTS_DN}/NRCELL-10],
#    Should Contain    ${feedback[1]}
#   ...    preventParamModifList:[LNCEL-pMax] does not exist in any cell-level parameter corresponding to the cell's technology
    ${Case_Status14}    Set Variable    PASS
    Set Suite Variable    ${Case_Status14}

Check Feedback Type2
    Create Delta    delta2
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCELL-pMax    delta_id=delta2
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN
    ...    ${NRCELL_DN}/NRCELL_FDD-1    delta_id=delta2
    ${delta2_data}    Get Delta    delta2
    Log    ${delta2_data}
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta2_data}  skip_parameter_relation_errors=True
    Log    ${feedback}
    Should Be Equal    ${feedback[0]}    FAIL
    Should Contain    ${feedback[1]}    Restricted parameter in the list and targetDN are in different technology.
    Should Contain    ${feedback[1]}
    ...    preventParamModifTargetDN:[/${NRCELL_DN}/NRCELL_FDD-1] cannot find restricted parameter in preventParamModifList with same technology

Check Feedback Type6
    Create Delta    delta3
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifList    NRCEL-pMax    delta_id=delta3
    Append List Items To Delta    ${FEATCADM_DN}    preventParamModifTargetDN    ${FEATCADM_DN}    delta_id=delta3
    ${delta3_data}    Get Delta    delta3
    Log    ${delta3_data}
    ${feedback}    Run Keyword and Ignore Error    coam.Perform Delta Recommissioning    ${delta3_data}  skip_parameter_relation_errors=True
    Log    ${feedback}
    Should Be Equal    ${feedback[0]}    FAIL
    Should Contain    ${feedback[1]}
    ...    Restricted parameter preventParamModifList:[NRCEL-pMax],preventParamModifTargetDN:[/${FEATCADM_DN}] includes unsupported MOC
