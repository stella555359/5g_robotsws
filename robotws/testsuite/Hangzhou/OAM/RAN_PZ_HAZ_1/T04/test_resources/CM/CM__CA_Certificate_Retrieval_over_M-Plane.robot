*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
&{Target_CMP_CONFIG}    serverHost=10.110.91.111    serverPath=/pkix    serverPort=8080    	caSubjectName=CN=zhouv4
${CMP_RECOVER_FLAG}    False
*** Keywords ***
CM__CA_Certificate_Retrieval_over_M-Plane
    [Documentation]    *****************
    ...    Basic information
    ...    *****************
    ...    For case:Top50 optus acceptance case,CA Certificate Retrieval over M-Plane
    ...    Reference case script:testsuite/Wroclaw/CIS/testsuite/Certificate_retrieval_over_Mplane
    ...    The main steps performed for the test are:
    ...    - Update Parameter cmpCrlSrcIpv4AddressDN To mPlaneIpv4AddressDN
    ...    - Initialize The Certificate
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 05.20.2024 - New case
    Set Tags    AUTHOR-yuan.1.gao@nokia-sbell.com    Maintainer–I_NSB_MN_RAN_RD_VRF_HAZ1_8@internal.nsn.com
    Log To Console    ${TEST_NAME} start
    Step 1: Update Parameter cmpCrlSrcIpv4AddressDN To mPlaneIpv4AddressDN
    Step 2: CMP Config If Needed
    Step 3: Initialize The Certificate

TC SetUp
    Log    TC SetUp    console=True
    Set Test Variable    ${NEED_RECOVER}    ${False}
    Common Test Setup SBTS
    ${MRBTS_ID}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${MRBTS_ID}

TC TearDown
    Log    TC TearDown    console=True
    ${result}    Run Keyword And Return Status    Recover Parameters
    Run Keyword If    '${result}'=='False'    Run Keywords
    ...    coam.Perform Commissioning    bts_id=${MRBTS_ID}    scf_file=${BTS_scf_initial}    should_activate=True    timeout=400
    ...    AND    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms
    Common Test Teardown SBTS

Step ${index}: Update Parameter cmpCrlSrcIpv4AddressDN To mPlaneIpv4AddressDN
    Log    Step ${index}: Update Parameter cmpCrlSrcIpv4AddressDN To mPlaneIpv4AddressDN    console=True
    ${mPlaneIpv4AddressDN}    Create List    mPlaneIpv4AddressDN
    ${mPlaneIpv4AddressDN_rtn}=    coam.get parameter by dist name    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/MPLANENW-1    ${mPlaneIpv4AddressDN}
    ${mPlaneIpv4AddressDN_value}=    Set variable        ${mPlaneIpv4AddressDN_rtn[0]['parameters']['mPlaneIpv4AddressDN']}
    ${cmpCrlSrcIpv4AddressDN}     Create List    cmpCrlSrcIpv4AddressDN
    ${cmpCrlSrcIpv4AddressDN_rtn}=    coam.get parameter by dist name    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CERTHENT-1    ${cmpCrlSrcIpv4AddressDN}
    ${cmpCrlSrcIpv4AddressDN_Paremeter}=    Set variable    ${cmpCrlSrcIpv4AddressDN_rtn[0]['parameters']}
    ${cmpCrlSrcIpv4AddressDN_Paremeterstr}=    Convert To String    ${cmpCrlSrcIpv4AddressDN_Paremeter}
    Run Keyword If    "${cmpCrlSrcIpv4AddressDN_Paremeterstr}"=="{}"    Set Test Variable    ${cmpCrlSrcIpv4AddressDN_value}    Need_update
    ...    ELSE    Set Test Variable
    ...    ${cmpCrlSrcIpv4AddressDN_value}    ${cmpCrlSrcIpv4AddressDN_rtn[0]['parameters']['cmpCrlSrcIpv4AddressDN']}
    Return From Keyword If    '${mPlaneIpv4AddressDN_value}'=='${cmpCrlSrcIpv4AddressDN_value}'
    Delta Commission to Update Parameter    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CERTHENT-1    cmpCrlSrcIpv4AddressDN    ${mPlaneIpv4AddressDN_value}
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Check SBTS SMOD RMOD Cells Alarms

Step ${index}: CMP Config If Needed
    Log    Step ${index}: CMP Config If Needed    console=True
    ${cmpParameters_list}    Get Dictionary Keys    ${Target_CMP_CONFIG}
    ${Initial_CMP_CONFIG}     Create Dictionary
    ${Initial_CMP_CONFIG}     Get The Initial Value For Given ParameterList    MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1    ${cmpParameters_list}
    Set Test Variable     ${Initial_CMP_CONFIG}
    Return From Keyword If    "${Initial_CMP_CONFIG["serverHost"]}"!="None"
    coam.Create Delta
    FOR  ${Item}  IN  @{cmpParameters_list}
        Run Keyword If    "${Initial_CMP_CONFIG["${Item}"]}"!="${Target_CMP_CONFIG["${Item}"]}"
        ...    coam.Append Parameter Update To Delta    MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1    ${Item}    ${Target_CMP_CONFIG["${Item}"]}
    END
    ${json}    coam.Get Delta
    Set Test Variable    ${CMP_RECOVER_FLAG}    ${True}
    coam.Perform Delta Recommissioning    ${json}
    ${certificate}    coam.Cmp Initialize Certificate    timeout=180

Step ${index}: Initialize The Certificate
    Log    Step ${index}: Initialize The Certificate    console=True
    Log To Console    Getting Current Certificate
    ${old_certificate}    coam.Get Certificate List    BTS
    Log To Console    Updating Certificate
    ${certificate}    coam.Cmp Initialize Certificate    timeout=180
    Log To Console    Getting updated certificate
    ${new_certificate}    coam.Get Certificate List    BTS
    Log To Console    Verifing If Certificate Is Properly Updated
    ${is_installed}    Check If New Certificate Is Installed    ${old_certificate}    ${new_certificate}
    Should Be Equal    '${is_installed}'    'True'
    log to console    Certificate updated
    Check SBTS SMOD RMOD Cells Alarms

Get The Initial Value For Given ParameterList
    [Arguments]    ${dist_name}    ${ParameterList}
    ${Parameter}    Create Dictionary
    FOR  ${Item}  IN  @{ParameterList}
	    ${tmp_list}    Create List    ${Item}
        ${Item_rtn}=    coam.get parameter by dist name    ${dist_name}    ${tmp_list}
        ${Item_Exist}    Set variable    ${Item_rtn[0]['parameters']}
        ${Item_Exist_str}=    Convert To String    ${Item_Exist}
        Run Keyword If    "${Item_Exist_str}"=="{}"    Set To Dictionary    ${Parameter}    ${Item}=${None}
        ...    ELSE    Set To Dictionary    ${Parameter}    ${Item}=${Item_rtn[0]['parameters']['${Item}']}
    END
    [Return]    ${Parameter}

Check If New Certificate Is Installed
    [Arguments]    ${old_cert}    ${new_cert}
    ${date_old_cert}    set variable    ${EMPTY}
    ${date_new_cert}    set variable    ${EMPTY}
    FOR    ${cert}    IN    @{old_cert}
        ${date_old_cert}    Set variable If    '${cert['type']}' == 'EndEntity'     ${cert['validFrom']}    ${date_old_cert}
    END
    ${date_old_cert_datetime}    Convert Date    ${date_old_cert}
    FOR    ${cert}    IN    @{new_cert}
        ${date_new_cert}    Set variable If    '${cert['type']}' == 'EndEntity'     ${cert['validFrom']}    ${date_new_cert}
    END
    ${date_new_cert_datetime}    Convert Date     ${date_new_cert}
    ${delta}    Subtract Date From Date    ${date_new_cert_datetime}    ${date_old_cert_datetime}
    ${result}    Set Variable if    ${delta} > 0    ${True}    ${False}
    [Return]    ${result}

Delta Commission to Update Parameter
    [Arguments]    ${dist_name}    ${parameter}    ${value}
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${dist_name}   parameter=${parameter}    value=${value}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}

Delta Commission to Delete Parameter
    [Arguments]    ${dist_name}    ${parameter}
    coam.Create Delta
    coam.Append Parameter Delete To Delta    dist_name=${dist_name}   parameter=${parameter}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}

Create Config Recover Delta
    [Arguments]     ${dist_name}    ${Origin_ParameterDic}    ${Target_ParameterDic}    ${DeltaplanID}
    ${ParameterList}    Get Dictionary Keys    ${Target_ParameterDic}
    FOR  ${Item}  IN  @{ParameterList}
        Run Keyword If    "${Origin_ParameterDic["${Item}"]}"=="None"
        ...    coam.Append Parameter Delete To Delta    ${dist_name}    ${Item}    delta_id=${DeltaplanID}
        ...    ELSE IF	  "${Origin_ParameterDic["${Item}"]}"!="${Target_ParameterDic["${Item}"]}"
        ...    coam.Append Parameter Update To Delta    ${dist_name}     ${Item}    ${Origin_ParameterDic["${Item}"]}    delta_id=${DeltaplanID}
    END
Recover Parameters
    Log To Console    Starting to recover parameter
    coam.Create Delta    delta_id=recover
    Run Keyword If     '${cmpCrlSrcIpv4AddressDN_value}'=='Need_update'
    ...    coam.Append Parameter Delete To Delta    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CERTHENT-1    cmpCrlSrcIpv4AddressDN    delta_id=recover
    ...    ELSE IF    '${NEED_RECOVER}'=='True'
    ...    coam.Append Parameter Update To Delta    MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CERTHENT-1    cmpCrlSrcIpv4AddressDN
    ...    ${cmpCrlSrcIpv4AddressDN_value}    delta_id=recover
    Run Keyword If      '${CMP_RECOVER_FLAG}'=='True'     Create Config Recover Delta    MRBTS-${MRBTS_ID}/MNL-1/CERTH-1/CMP-1
    ...    ${Initial_CMP_CONFIG}    ${Target_CMP_CONFIG}    recover
    ${json}    coam.Get Delta    delta_id=recover
    ${length}    Get Length    ${json}
    Run Keyword If    '${length}'>'2'    coam.Perform Delta Recommissioning    ${json}
    Check SBTS SMOD RMOD Cells Alarms