*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for [1][7.0] Loading SCF containing both Fully Distinguished Name (FDN) format
...   and Shortened Distinguished Name (SDN) format
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
#&{plan_info_8660_011_1}      scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
#...    parameter_name=resourceDN    shortenedDN=PHYANT-1
&{plan_info_8660_011_2}      scf_distName=MRBTS-${vDU_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-2
...    parameter_name=linkSelectorDN    shortenedDN=TNL-1/ETHSVC-1/ETHLK-2
&{plan_info_8660_011_3}      scf_distName=MRBTS-${vDU_id}/MNL-1/MNLENT-1/MPLANENW-1
...    parameter_name=mPlaneIpv4AddressDN    shortenedDN=TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1
&{INCORRECT_SDN}      scf_distName=MRBTS-${vDU_id}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-2
...    parameter_name=linkSelectorDN    shortenedDN=ETHLK-2
${NEED_RECOVERY}    False

*** Keywords ***
TC__VRAN_CM_Loading_SCF_Containing_Both_FDN_And_SDN_Format_011
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    13.02.2023, lixin.kang@nokia-sbell.com, draft
    ...    14.06.2024, bin.7.liu@nokia-sbell.com, merge check points of PZ2 case
    ...    OAM__vDU_Loading_and_Activating_a_configuration_plan__5GC001662-D ,
    ...    change step 3: activate plan -> preactivate + active preactivated plan
    ...    06.01.2025, lixin.kang@nokia-sbell.com, update for CB012840
    Step 1: Generate SCF Wtih Both SDN And LDN
    Step 2: Activate SCF And Wait Site OnAir
    Step 3: Generate Delta Plan With Incorrect SDN
    Step 4: Activate New Delta Plan And Check Feedback

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
    Set Test Variable    ${scf_initial_vdu}    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Run Keyword And Ignore Error    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Ignore Error    Delete Delta Plan By Plan Id In vDU    ${plan_id}
    Run Keyword And Ignore Error    vDU Logout By Rest
    Run Keyword If    ${NEED_RECOVERY}    Commission Backup SCF
    Common Test Teardown For AIC

Step ${index}: Generate SCF Wtih Both SDN And LDN
    Log    Step ${index}: Generate SCF Wtih Both SDN And LDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    ${new_name_correct_SDN}    Set Variable   MRBTS-${vDU_id}_${timestamp}
    ${new_scf_file_name}    Set Variable    ${new_name_correct_SDN}.xml
    ${plan_info}    Create List    ${plan_info_8660_011_2}    ${plan_info_8660_011_3}
    Set Test Variable    ${plan_info}
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${scf_initial_vdu}
    FOR    ${plan_item}   IN    @{plan_info}
        L_XML.Remove Elements    ${scf_xml}
        ...    cmData/managedObject[@distName="${plan_item['scf_distName']}"]/p[@name="${plan_item['parameter_name']}"]
        ...    remove_tail=${True}
        L_XML.Add Element    ${scf_xml}    <p name="${plan_item['parameter_name']}"/>
        ...    xpath=cmData/managedObject[@distName="${plan_item['scf_distName']}"]
        L_XML.Set Element Text    ${scf_xml}    ${plan_item['shortenedDN']}    \r\n
        ...    cmData/managedObject[@distName="${plan_item['scf_distName']}"]/p[@name="${plan_item['parameter_name']}"]
    END
    L_XML.Save XML    ${scf_xml}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    ${file_content}    OperatingSystem.Get File    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    Set Test Variable    ${full_scf_path}    ${TEST_LOG_DIRECTORY}/${new_scf_file_name}
    Sleep    10s    time for file creation

Step ${index}: Activate SCF And Wait Site OnAir
    Log    Step ${index}: Activate SCF And Wait Site OnAir    console=True
#    ${out}    Parameter Operation    operation=full_commission    product_type=vdu
#    ...       scf_path=${full_scf_path}
    ${out}    vdu.perform_commissioning    ${full_scf_path}    timeout=800
    Log To Console    VDU full commission result: ${out}
    Set Test Variable    ${NEED_RECOVERY}    True
    Wait Until Keyword Succeeds    20m    60s    vDU Check All Cells Status Should Be Onair For All DUs

Step ${index}: Generate Delta Plan With Incorrect SDN
    Log    Step ${index}: Generate Delta Plan With Incorrect SDN    console=True
    ${root_obj}    Fetch From Right    ${INCORRECT_SDN['scf_distName']}    /
    ${class_name}    Fetch From Left    ${root_obj}    -
    ${json_tmp1}    Set Variable    [{"className": "${class_name}",
    ${json_tmp2}    Set Variable    "distName": "${INCORRECT_SDN['scf_distName']}", "operation": "update", "parameters":[{"parameterName":
    ${json_tmp3}    Set Variable    "${INCORRECT_SDN['parameter_name']}", "operation": "update", "value": "${INCORRECT_SDN['shortenedDN']}"}]}]
    Set Test Variable    ${delta_plan}    ${json_tmp1}${json_tmp2}${json_tmp3}

Step ${index}: Activate New Delta Plan And Check Feedback
    Log    Step ${index}: Activate New Delta Plan And Check Feedback    console=True
    ${tmp_str1}    Set Variable    is invalid because the shortened distinguished names pointing to objects under TNL
    ${tmp_str2}    Set Variable    object model tree must start at least from TNL and cannot be shortened further.
    ${EXPECED_PDL_ERROR}    Set Variable
#    ...    Distname parameter '${INCORRECT_SDN['parameter_name']}' value '${INCORRECT_SDN['shortenedDN']}' ${tmp_str1} ${tmp_str2}
    ...    Distname parameter \\\'${INCORRECT_SDN['parameter_name']}\\\' value \\\'${INCORRECT_SDN['shortenedDN']}\\\' ${tmp_str1} ${tmp_str2}
    Run Keyword And Ignore Error    vDU Login By Rest
    ${status}    ${out}    Run Keyword And Ignore Error    vdu.perform_delta_recommissioning    ${delta_plan}
    Should Be Equal    ${status}    FAIL
    Should Contain    ${out}    Plan validation failed
    Should Contain    ${out}    ${EXPECED_PDL_ERROR}

Commission Backup SCF
    Log    Commission Backup SCF    console=True
    ${out}    vdu.perform_commissioning    ${scf_initial_vdu}    timeout=800
    Log To Console    VDU full commission result: ${out}
    Wait Until Keyword Succeeds    10m    60s    vDU Check All Cells Status Should Be Onair For All DUs