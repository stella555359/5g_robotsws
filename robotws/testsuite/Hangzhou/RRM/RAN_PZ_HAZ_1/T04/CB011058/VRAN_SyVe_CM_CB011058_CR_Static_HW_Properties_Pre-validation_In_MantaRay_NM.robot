*** Settings ***
Documentation       Test suite for SyVe_CM_CB011058_CM_CR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot


*** Keywords ***
VRAN_SyVe_CM_CB011058_CR_Static_HW_Properties_Pre-validation_In_MantaRay_NM
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    01.14.2025, yuyan.xu@nokia-sbell.com, draft
    Step 1: Convert SCF To NetAct Model
    Step 2: Check Builds Exist In NetAct
    Step 3: Pre_Validate Plan

Step ${index}: Convert SCF To NetAct Model
    #Set Test Variable    ${vDU_id}    11084      #if need test non CRT bts
    Log To Console    Step ${index}: Convert SCF To NetAct Model
    ${time}    Get Time    epoch
    ${BTS_scf}    vdu.get_current_plan_file
    ...    local_dir_path=${TEST_LOG_DIRECTORY}    filename=current_scf_${time}.xml    include_runtime_data=${True}
    ${sub_build}    Fetch From Right    ${VDU_VERSION}     _    #e.g.vDUCNF25R2_0.300.27848
    ${head_build}    Fetch From Left    ${VDU_VERSION}     ${sub_build}
    log    ${VDU_VERSION}
    ${target_sw_name}    Set Variable If    "${Trunk_Prefix}_"=="${head_build}"    vDUCNF00_${sub_build}    ${VDU_VERSION}
    Set Test Variable    ${target_sw_name}
    ${SCF_File_Modifed}    Add PlannedSWReleaseVersion And Recommission    ${target_sw_name}    ${BTS_scf}
    ${file_name}    Fetch From Right    ${SCF_File_Modifed}    /
    ${file_path}    Fetch From Left    ${SCF_File_Modifed}    ${file_name}
    Set Test Variable    ${plan_name}    CB011085_TA_case_CR_plan_${time}
    ${status}=    Run Keyword And Return Status    netact.Import SCF   local_dir=${file_path}
    ...    file_name=${file_name}    plan_name=${plan_name}

Add PlannedSWReleaseVersion And Recommission
    [Arguments]    ${plannedSW}    ${scf_file}
    ${file_name}    Fetch From Right    ${scf_file}    /
    ${file_path}    Fetch From Left    ${scf_file}    ${file_name}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_file}
    ${mo_dn}    Set Variable    MRBTS-${vDU_id}/EQM-1/APEQM-1/RMOD-1/EAC_IN-1
    L_XML.Set Element Text    ${scf_xml}    10    \r\n
    ...    cmData/managedObject[@distName="${mo_dn}"]/p[@name="portId"]
    #${params_dic}    Create Dictionary    chBw=15MHz    type0CoresetConfigurationIndex=1    type0SearchSpaceConfigurationIndex=6
    #${keys}    Get Dictionary Keys    ${params_dic}
    #FOR    ${param}    IN    @{keys}
        #L_XML.Set Element Text    ${scf_xml}    ${params_dic["${param}"]}    \r\n
        #...    cmData/managedObject[@distName="${mo_dn}"]/p[@name="${param}"]
    #END

    #L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    #L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="MNL"]/p[@name="plannedSWReleaseVersion"]    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="MRBTS-${vDU_id}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${plannedSW}-amd64    \r\n
    ...    cmData/managedObject[@distName="MRBTS-${vDU_id}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Save XML    ${scf_xml}    ${file_path}modifed_${file_name}
    ${file_content}    OperatingSystem.Get File    ${file_path}modifed_${file_name}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${parsed_xml}    XML.Parse XML    ${file_content}
    XML.Save Xml    ${parsed_xml}    ${file_path}modifed_${file_name}
    [Return]    ${file_path}modifed_${file_name}

Step ${index}: Check Builds Exist In NetAct
    Log To Console    Step ${index}: Check Builds Exist In NetAct
    #${build_exist1}    netact.Is Imported    ${target_sw_name}-amd64
    #Log To Console    build_exist1:${build_exist1}
    ${build_exist2}    netact.Is Imported    ${target_sw_name}-amd64_pdl_validation_service_plugin
    Log To Console    build_exist:${build_exist2}
    Return From Keyword If    ${build_exist2}

    OperatingSystem.Run    mkdir /home/ute/Downloads/CB011058
    #Download vRAN SW Build    ${target_sw_name}    ${target_sw_name}-amd64    /home/ute/Downloads/CB011058
    Download vRAN SW Build    ${target_sw_name}    ${target_sw_name}-amd64_pdl_validation_service_plugin
    ...    /home/ute/Downloads/CB011058    clean_folder=${False}
    #${ret}    OperatingSystem.File Should Exist    /home/ute/Downloads/CB011058/${target_sw_name}-amd64.zip
    ${ret}    OperatingSystem.File Should Exist    /home/ute/Downloads/CB011058/${target_sw_name}-amd64_pdl_validation_service_plugin.zip
    #OperatingSystem.Run And Return Rc And Output
    #...    mv /home/ute/Downloads/CB011058/${target_sw_name}-amd64.zip /home/ute/Downloads/CB011058/${plannedSW}-amd64.zip
    #${tmp1}    Set Variable    mv /home/ute/Downloads/CB011058/${target_sw_name}-amd64_pdl_validation_service_plugin.zip
    #${tmp2}    Set Variable    /home/ute/Downloads/CB011058/${plannedSW}-amd64_pdl_validation_service_plugin.zip
    #OperatingSystem.Run And Return Rc And Output    ${tmp1} ${tmp2}
    #Import vRAN SW Build To NetAct    ${plannedSW}-amd64    /home/ute/Downloads/CB011058
    Import vRAN SW Build To NetAct    ${target_sw_name}-amd64_pdl_validation_service_plugin    /home/ute/Downloads/CB011058

Step ${index}: Pre_Validate Plan
    Log To Console    Step ${index}: Pre_Validate Plan
    #Deintegrate NE From NetAct    dist_name=PLMN-PLMN/MRBTS-${vDU_id}
    # Sleep    3s
    ${status}    ${out}    Run Keyword And Ignore Error    netact.prevalidate_plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    Log To Console    ${out}
    Should Be Equal As Strings    ${status}    FAIL
    Should Contain    ${out}    portId value must be less than or equal to number of supported EAC inputs for this RMOD


Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    vDU Login By Rest
    ${NETACT}    Copy Dictionary    ${NETACT_CB011058}
    Setup NetAct    ${NETACT}
    Set Test Variable    ${NETACT}

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${plan_name}
    Run Keyword And Ignore Error    vDU Logout By Rest
    Teardown NetAct
    Common Test Teardown For AIC