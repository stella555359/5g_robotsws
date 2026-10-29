*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
Resource          ../../Resources/Cloud/AIC_Common_Resource.robot
Resource         ../Resources/PZ2/ru.robot
Resource         ../Resources/PZ2/vdu_oam_cm.robot
Resource         ../Resources/PZ2/aic_common_resources_new.robot
Resource         ../Resources/PZ2/kw_to_be_optimized.robot
Resource         ../Resources/PZ2/vdu_sec_authorization.robot
Library          taf.hw.fhgw.cli                       WITH NAME    issh
Library          ../Resources/PZ2/py_tool/utils.py


*** Variables ***
${NEED_RECONNECT_RU}             ${False}
${VDU_CONTAINER_PROMPT}          bash-\\d\\.\\d\\$\\s
${VDU_CONTAINER_PROMPT_ROOT}     \\[root@\\S+:\\S+\\][\\r\\n]+#\\s
${VDU_OE_SERVER_PROMPT}          \\[core@\\S+\\s\\S+\\]\\$\\s
${VDU_OE_SERVER_PROMPT_TENANT}   \\[cranuser\\d+@\\S+\\s+\\S+\\]\\$
@{VDU_REDUNDENCY_POD_LIST}       up  rcpsdl  oamasm  oamcm  oamext  oamconfig  oamfm
@{VDU_REDUNDENCY_OAM_POD_LIST}   oamasm  oamcm  oamext  oamconfig  oamfm

@{VDU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b  cuoam_22r2  cuoam_22r4  cuoam_23r1  cuoam_23r2
...                                     cuoam_23r3  cuoam_23r4  cuoam_24r1
&{VDU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   16.300=cuoam_22r4  15.300=cuoam_22r2  17.300=cuoam_23r1    18.300=cuoam_23r2  19.300=cuoam_23r3
                                          ...  20.300=cuoam_23r4  0.300=${VDU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}
@{VCU_REST_TAF_LIB_SUPPORTED_VERSION}   cuoam_19b   cuoam_21b   cuoam_22r4  cuoam_23r1  cuoam_23r2
&{VCU_RESTAPI_TAF_VERSION_SW_STREAM_MAPPING}   15.250=cuoam_21b    16.250=cuoam_22r4  17.250=cuoam_23r1   18.250=cuoam_23r2
                                          ...   0.250=${VCU_REST_TAF_LIB_SUPPORTED_VERSION[-1]}

*** Keywords ***
VRAN_OAM_vDU_RMOD_R_VNFC_R_Subtree_Creation_RUHW_Detection_and_Refreshing_5GC001662-L
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    11.06.2024, yuyan.xu@nokia-sbell.com, draft,
    ...    New case,based to transfer from PZ2 case:[1][1.0] OAM__vDU_RMOD_R_and_VNFC_R_Subtree_Creation_on_NOM__5GC001662-L
    ...    [1][1.0] OAM__vDU_RU_HW_Detection_and_Refreshing_on_NOM__5GC001662-L
    Log To Console    ${TEST_NAME} start.
    Step1: Upload vDU Actual Configuration On NetAct
    Step2: Check Actual Configuration On Netact
    Step3: Disconnect RU 2 From vDU
    Step4: Upload vDU Actual Configuration On NetAct
    Step5: Check Actual Configuration On Netact
    Step6: Reconnect RU 2 To vDU
    Step7: Upload vDU Actual Configuration On NetAct
    Step8: Check Actual Configuration On Netact


Step${index}: Upload vDU Actual Configuration On NetAct
    Log To Console  Step${index}: Upload vDU Actual Configuration On NetAct
    ${parameters}   Create Dictionary  -sranBtsHwContentInUse=${True}
    NetAct CM Upload    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    parameters=${parameters}

Step2: Check Actual Configuration On Netact
    Log To Console   Step2: Check Actual Configuration On Netact
    Check Actual Configuration On Netact   2nd_ru_state=connected

Step3: Disconnect RU 2 From vDU
    Log To Console   Step3: Disconnect RU 2 From vDU
    ${conn_info}   ${DELTA_PLAN_RESULT}   Disconnect RU From vDU   ru_index=2
    Set Test Variable   ${DELTA_PLAN_RESULT}
    Set Test Variable   ${NEED_RECONNECT_RU_TO_VDU}   1
    Wait Until Keyword Succeeds  120  10   Check Expected Alarms Is Appear    expected_fault_id=10
    ${NEED_RECONNECT_RU}    Set Variable    ${True}

Step5: Check Actual Configuration On Netact
    Log To Console   Step5: Check Actual Configuration On Netact
    Wait Until Keyword Succeeds  5min  20  Check Actual Configuration On Netact   2nd_ru_state=disconnected

Step6: Reconnect RU 2 To vDU
    Log To Console   Step6: Reconnect RU 2 To vDU
    Connect RU To vDU  ru_index=2
    Set Test Variable   ${NEED_RECONNECT_RU_TO_VDU}   0
    Wait Until Keyword Succeeds    7min    20    vDU Check All Cells Status Should Be Onair For All DUs     gnb_index=${0}
    Wait Until Keyword Succeeds  120  10   Check Expected Alarms Is Not Appear    expected_fault_id=10
    ${NEED_RECONNECT_RU}    Set Variable    ${False}

Step8: Check Actual Configuration On Netact
    Log To Console  Step8: Check Actual Configuration On Netact
    Check Actual Configuration On Netact   2nd_ru_state=connected

Get INVUNIT Distname From RMOD Id
    [Arguments]   ${full_plan}    ${rf_dn}
    ${INVUNIT_dn}    Set Variable
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}=    L_XML.Parse xml    ${full_plan}
    ${INVUNIT_MOs}=    L_XML.Get Elements    ${scf_xml}    .//managedObject[@class="com.nokia.eqm.hw:INVUNIT"]
    FOR    ${object}    IN    @{INVUNIT_MOs}
        ${parame_configDN}    L_XML.Get Elements    ${object}    .//p[@name="configDN"]
        ${configDN_value}    Run Keyword If    ${parame_configDN.__len__()}==1    L_XML.Get Element Text    ${parame_configDN[0]}
        ${INVUNIT_dn}    Run Keyword If    ${parame_configDN.__len__()}==1 and "${configDN_value}"=="${rf_dn}"
        ...    L_XML.Get Element Attribute    ${object}    distName
        Exit For Loop If    ${parame_configDN.__len__()}==1 and "${configDN_value}"=="${rf_dn}"
    END
    [Return]    ${INVUNIT_dn}

Check Actual Configuration On Netact
    [Arguments]  ${2nd_ru_state}=connected
    vDU Login By Rest
    ${fullplan_vdu}    vdu.Get Current Plan File
    ...    local_dir_path=${TEST_LOG_DIRECTORY}    filename=MRBTS-${vDU_id}_fullplan.xml    include_runtime_data=${True}
    vDU Logout By Rest
    ${INVUNIT_dn_rmod1}    Get INVUNIT Distname From RMOD Id    ${fullplan_vdu}    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1
    ${INVUNIT_dn_rmod2}    Get INVUNIT Distname From RMOD Id    ${fullplan_vdu}    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-2
    ${actual_conf}    netact.get_actual_configuration
    #first RU
    ${managed_object}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM_R-1/APEQM_R-1/RMOD_R-1
    Should Be True   ${managed_object.parameters["usageState"]}==1
    Should Be True   ${managed_object.parameters["proceduralStatus"]}==5

    #2nd RU
    ${managed_object}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM_R-1/APEQM_R-1/RMOD_R-2
    ${expected_usageState}  Set Variable If   "${2nd_ru_state}"=="connected"  1  2
    ${expected_proceduralStatus}  Set Variable If   "${2nd_ru_state}"=="connected"  5  1
    Should Be True   ${managed_object.parameters["usageState"]}==${expected_usageState}
    Should Be True   ${managed_object.parameters["proceduralStatus"]}==${expected_proceduralStatus}

    ${managed_object_invunit}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/${INVUNIT_dn_rmod2}
    ${expected_state}  Set Variable If  "${2nd_ru_state}"=="connected"   working   faulty
    Should Be True    "${managed_object_invunit.parameters["state"]}"=="${expected_state}"

    ${managed_object_invunit}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/${INVUNIT_dn_rmod1}
    Should Be True    "${managed_object_invunit.parameters["state"]}"=="working"

    #1st cell
    ${managed_object}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-1
    Should Be True   ${managed_object.parameters["proceduralStatus"]}==4

    #2nd cell
    ${expected_proceduralStatus}  Set Variable If   "${2nd_ru_state}"=="connected"  4  0
    ${managed_object}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRCELL-2
    Should Be True   ${managed_object.parameters["proceduralStatus"]}==${expected_proceduralStatus}

    #VNFC_R
    ${managed_object}   netact.get_managed_object   configuration=${actual_conf}   mo_id=PLMN-PLMN/MRBTS-${vDU_id}/EQM_R-1/VNFC_R-1
    Should Be True   ${managed_object.parameters["usageState"]}==1

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword If   ${NEED_RECONNECT_RU}    Step6: Reconnect RU 2 To vDU
    Common Test Teardown For AIC
    Teardown NetAct