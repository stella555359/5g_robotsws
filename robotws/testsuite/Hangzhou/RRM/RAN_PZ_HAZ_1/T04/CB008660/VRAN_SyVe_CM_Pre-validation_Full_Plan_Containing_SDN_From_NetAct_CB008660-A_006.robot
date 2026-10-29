*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for VRAN_SyVe_CM_Pre-validation_Full_Plan_Containing_SDN_From_NetAct_CB008660-A_006
...    unambiguity to the live NE
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{plan_info_8660_006}      scf_distName=MRBTS-${vDU_id}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1
...    mo_id=PLMN-PLMN/MRBTS-${vDU_id}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1    parameter_name=linkSelectorDN
...    shortenedDN=TNL-2/ETHSVC-1/ETHLK-1     incorrect_shortenedDN=ETHLK-1
${download_sw_to_dir}    /home/ute/Downloads

*** Keywords ***
TC__VRAN_SyVe_CM_Pre-validation_Full_Plan_Containing_SDN_From_NetAct_CB008660-A_006
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.02.2023, lixin.kang@nokia-sbell.com, draft
    Step 1: TC Parameters Precondition
    Step 2: Check Builds Exist In NetAct
    Step 3: Upload NE Configuration
    Step 4: Export the plan SyVe
    Step 5: Modify Plan File With Correct SDN
    Step 6: Import the plan With Correct SDN
    Step 7: PreValidate Plan And Check Result With Correct SDN
    Step 8: Modify Plan File With Incorrect SDN
    Step 9: Import the plan With Incorrect SDN
    Step 10: PreValidate Plan And Check Result With Incorrect SDN

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    ${CUR_VDU_VER}    Get vDU Version
    ${releaseid}    Fetch From Right    ${CUR_VDU_VER}   _
    Set Test Variable    ${CUR_VER_BTS}    vDUCNF00_${releaseid}
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    Particular Teardown
    Common Test Teardown For AIC
    Teardown NetAct

Step ${index}: TC Parameters Precondition
    Log    Step ${index}: TC Parameters Precondition    console=True
    ${ne_dn}    Set Variable   PLMN-PLMN/MRBTS-${vDU_id}
    Set Test Variable    ${ne_dn}
    ${plan_info}    Create Dictionary
    Set Test Variable    ${plan_info}    ${plan_info_8660_006}
    &{parameter}    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['shortenedDN']}
    &{incorrect_parameter}    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['incorrect_shortenedDN']}
    ${tmp_str1}    Set Variable    Distname parameter '${plan_info['parameter_name']}' value '${plan_info['incorrect_shortenedDN']}' is invalid
    ${tmp_str2}    Set Variable    because the shortened distinguished names pointing to objects under TNL object model tree
    ${error_message}    Set Variable    ${tmp_str1} ${tmp_str2} must start at least from TNL and cannot be shortened further
    Set Test Variable    ${plan_info}
    Set Test Variable    ${parameter}
    Set Test Variable    ${incorrect_parameter}
    Set Test Variable    ${error_message}
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    ne=${ne_dn}    dist_name=${plan_info['mo_id']}    &{parameter}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Fail
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!
    ...    ELSE    Log    TC parameters successfully checked    console=True

Step ${index}: Check Builds Exist In NetAct
    Log    Step ${index}: Check Builds Exist NetAct    console=True
    ${sw_build_pkg}    Set Variable   ${CUR_VER_BTS}
    ${plugin_build_pkg}    Set Variable   ${CUR_VER_BTS}_pdl_validation_service_plugin
    ${build_exist}    netact.Is Imported    ${sw_build_pkg}
    Run Keyword If    not ${build_exist}    Download And Import Build To NetAct    ${sw_build_pkg}    ${sw_build_pkg}    ${download_sw_to_dir}
    ${build_exist}    netact.Is Imported    ${plugin_build_pkg}
    Run Keyword If    not ${build_exist}    Download And Import Build To NetAct    ${sw_build_pkg}    ${plugin_build_pkg}   ${download_sw_to_dir}

Download And Import Build To NetAct
    [Arguments]    ${build_folder_name}    ${build_name}    ${sw_stored_local_path}
    Download vRAN SW Build    ${build_folder_name}    ${build_name}    ${sw_stored_local_path}
    Import vRAN SW Build To NetAct    ${build_name}    ${sw_stored_local_path}

Step ${index}: Upload NE Configuration
    [Documentation]    Uploads configuration data from the network is checked
    Log To Console    ${index}
    Log    Upload NE Configuration     console=True
    NetAct CM Upload    dist_names=${ne_dn}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${vDU_id}_${timestamp}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}   file_name=${name}.xml     dist_names=${ne_dn}
    ...    plan_name=${name}   operation_type=actual

Step ${index}: Modify Plan File With Correct SDN
    Log    Step ${index}: Modify Plan File With Correct SDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${new_name_correct_SDN}    MRBTS-${vDU_id}1_${timestamp}
    Set Test Variable    ${new_scf_file_name}    ${new_name_correct_SDN}.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/${name}.xml
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="MNL"]/p[@name="plannedSWReleaseVersion"]    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="${ne_dn}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${CUR_VER_BTS}    \r\n
    ...    cmData/managedObject[@distName="${ne_dn}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@distName="${plan_info['mo_id']}"]/p[@name="${plan_info['parameter_name']}"]
    ...    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="${plan_info['parameter_name']}"/>    xpath=cmData/managedObject[@distName="${plan_info['mo_id']}"]
    L_XML.Set Element Text    ${scf_xml}    ${plan_info['shortenedDN']}    \r\n
    ...    cmData/managedObject[@distName="${plan_info['mo_id']}"]/p[@name="${plan_info['parameter_name']}"]
    L_XML.Save XML    ${scf_xml}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    ${file_content}    Replace String    ${file_content}    BTS-${ne_dn.split('-')[-1]}    BTS-${ne_dn.split('-')[-1]}1
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    Sleep    10s    time for file creation

Step ${index}: Import the plan With Correct SDN
    Log    Step ${index}: Import the plan With Correct SDN    console=True
    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${new_scf_file_name}    plan_name=${new_name_correct_SDN}

Step ${index}: PreValidate Plan And Check Result With Correct SDN
    Log    Step ${index}: PreValidate Plan And Check Result With Correct SDN   console=True
    ${netactcon}    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    tafssh.Send Command    racclimx.sh -op PreValidate -DN ${ne_dn}1 -planName ${new_name_correct_SDN} -v
    ${output}    tafssh.Read Output
    tafssh.Disconnect    ${netactcon}
    Should Not Contain    ${output}    failed
    Should Contain    ${output}    pre-validate successful

Step ${index}: Modify Plan File With Incorrect SDN
    Log    Step ${index}: Modify Plan File With Incorrect SDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${new_name_incorrect_SDN}    MRBTS-${vDU_id}2_${timestamp}
    Set Test Variable    ${new_scf_file_name}    ${new_name_incorrect_SDN}.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/${name}.xml
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="MNL"]/p[@name="plannedSWReleaseVersion"]    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="${ne_dn}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${CUR_VER_BTS}    \r\n
    ...    cmData/managedObject[@distName="${ne_dn}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@distName="${plan_info['mo_id']}"]/p[@name="${plan_info['parameter_name']}"]
    ...    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="${plan_info['parameter_name']}"/>    xpath=cmData/managedObject[@distName="${plan_info['mo_id']}"]
    L_XML.Set Element Text    ${scf_xml}    ${plan_info['incorrect_shortenedDN']}    \r\n
    ...    cmData/managedObject[@distName="${plan_info['mo_id']}"]/p[@name="${plan_info['parameter_name']}"]
    L_XML.Save XML    ${scf_xml}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    ${file_content}    Replace String    ${file_content}    BTS-${ne_dn.split('-')[-1]}    BTS-${ne_dn.split('-')[-1]}2
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    Sleep    10s    time for file creation

Step ${index}: Import the plan With Incorrect SDN
    Log    Step ${index}: Import the plan With Incorrect SDN    console=True
    NetAct Import Plan    local_dir=${TEST_LOG_DIRECTORY}   file_name=${new_scf_file_name}    plan_name=${new_name_incorrect_SDN}

Step ${index}: PreValidate Plan And Check Result With Incorrect SDN
    Log    Step ${index}: PreValidate Plan And Check Result With Incorrect SDN    console=True
    ${netactcon}    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    tafssh.Send Command    racclimx.sh -op PreValidate -DN ${ne_dn}2 -planName ${new_name_incorrect_SDN} -v
    ${output}    tafssh.Read Output
    Log To Console   ${output}
    tafssh.Disconnect    ${netactcon}
    Should Contain    ${output}    ${error_message}
    Should Contain    ${output}    pre-validate failed

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${new_name_correct_SDN}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${new_name_incorrect_SDN}

