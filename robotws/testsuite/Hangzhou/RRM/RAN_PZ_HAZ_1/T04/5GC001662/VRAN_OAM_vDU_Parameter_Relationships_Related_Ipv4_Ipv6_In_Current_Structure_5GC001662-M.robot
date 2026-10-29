*** Settings ***
Documentation
...   Author: lixin.kang@nokia-sbell.com
...   Description: This robot cases is for [1][1.0] OAM__vDU_Parameter_Relationships_Related_Ipv4_Ipv6_In_Current_Structure__5GC001662-M
...   unambiguity to the live NE
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Keywords ***
VRAN_OAM_vDU_Parameter_Relationships_Related_Ipv4_Ipv6_In_Current_Structure_5GC001662-M
    [Documentation]
    ...    Author: lixin.kang@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    17.06.2024, lixin.kang@nokia-sbell.com, draft,
    ...    New case,based to transfer from PZ2 case:
    ...    [1][1.0] OAM__vDU_Parameter_Relationships_Related_Ipv4_Ipv6_In_Current_Structure__5GC001662-M
    ...    06.01.2025, lixin.kang@nokia-sbell.com, update for CB012840
    Log To Console    ${TEST_NAME} start.
    Step 1: Check Current Ip Version
    Step 2: Prepare Mixed Ipv4 And Ipv6 Config
    Step 3: Validate New SCF And Confirm Errors Are Raised
    Step 4: Correct SCF And Revalidate Confirm Errors Disappear
#    Step 3: Upload New SCF And Validate
#    Step 4: Confirm Errors Are Raised
#    Step 5: Correct Values And Revalidate
#    Step 6: Confirm Errors Disappear

Step ${index}: Check Current Ip Version
    Log To Console    Step ${index}: Check Current Ip Version
    ${NRDU_DISTNAME}    Set Variable    MRBTS-${vDU_id}/NRBTS-${NRBTS_ID}/NRDU-1
    scf.Load_Scf  file_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    ${result}  ${F1CPLANE_ADDRESS4_DISTNAME}   Run Keyword And Ignore Error   scf.Get_Value_From_Scf
    ...      dist_name=${NRDU_DISTNAME}   list_name=f1Cplane   p_name=ipV4AddressDN1
    ${F1CPLANE_IPV4_VERSION}   Set Variable If   "IPADDRESSV4" in "${F1CPLANE_ADDRESS4_DISTNAME}"    4   6
    Should Be True  ${F1CPLANE_IPV4_VERSION}==4
    ${result}  ${dummy}   Run Keyword And Ignore Error   scf.Get_Value_From_Scf
    ...      dist_name=${NRDU_DISTNAME}   list_name=f1Cplane   p_name=ipV6AddressDN1
    Should Be True   "${result}"=="FAIL"
    Set Test Variable   ${NRDU_DISTNAME}
    Set Test Variable   ${F1CPLANE_ADDRESS4_DISTNAME}

Step ${index}: Prepare Mixed Ipv4 And Ipv6 Config
    Log To Console    Step ${index}: Prepare Mixed Ipv4 And Ipv6 Config
    Set Test Variable    ${new_scf_path}    ${TEST_LOG_DIRECTORY}/backup_scf/new_scf.xml
    ${F1CPLANE_ADDRESS6_DISTNAME}   Set Variable  MRBTS-${vDU_id}/TNLSVC-1/TNL-1/IPNO-1/IPIF-1/IPADDRESSV6-1
    scf.Load_Scf  file_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    L_XML.Add Element    ${scf_xml}    <p name="ipV6AddressDN1"/>
    ...    xpath=cmData/managedObject[@distName="${NRDU_DISTNAME}"]/list[@name="f1Cplane"]/item
    L_XML.Set Element Text    ${scf_xml}    ${F1CPLANE_ADDRESS6_DISTNAME}    \r\n
    ...    xpath=cmData/managedObject[@distName="${NRDU_DISTNAME}"]/list[@name="f1Cplane"]/item/p[@name="ipV6AddressDN1"]
    L_XML.Save XML    ${scf_xml}    ${new_scf_path}
    ${file_content}    OperatingSystem.Get File    ${new_scf_path}
    ${file_content}    Replace String    ${file_content}    \&\#13;    ${EMPTY}
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${new_scf_path}
    Sleep    10s    time for file creation
    Set Test Variable   ${F1CPLANE_ADDRESS6_DISTNAME}

Step ${index}: Validate New SCF And Confirm Errors Are Raised
    Log To Console    Step ${index}: Validate New SCF And Confirm Errors Are Raised
    ${status}    ${out}    Run Keyword And Ignore Error    vdu.perform_commissioning    ${new_scf_path}
    Should Be Equal    ${status}    FAIL
    Should Contain    ${out}    Plan validation failed
    ${error_msg}   Set Variable
     ...   It is required that NRDU-1.f1Cplane-1.ipV6AddressDN1 (value: ${F1CPLANE_ADDRESS6_DISTNAME}) is not configured
    ${error_msg}   Set Variable
     ...   ${error_msg} if having NRDU-1.f1Cplane-1.ipV4AddressDN1 (value: ${F1CPLANE_ADDRESS4_DISTNAME}) is configured
    Should Be True  """${error_msg}""" in """${out}"""

    ${error_msg}   Set Variable
     ...   It is required that NRDU-1.f1Cplane-1.ipV4AddressDN1 (value: ${F1CPLANE_ADDRESS4_DISTNAME}) is not configured
    ${error_msg}   Set Variable
     ...   ${error_msg} if having NRDU-1.f1Cplane-1.ipV6AddressDN1 (value: ${F1CPLANE_ADDRESS6_DISTNAME}) is configured
    Should Be True   """${error_msg}""" in """${out}"""

Step ${index}: Correct SCF And Revalidate Confirm Errors Disappear
    Log To Console    Step ${index}: Correct SCF And Revalidate Confirm Errors Disappear
    ${status}    ${out}    Run Keyword And Ignore Error
    ...    vdu.perform_commissioning    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Wait Until Keyword Succeeds    5x    60s     vDU Check All Cells Status Should Be Onair
    vDU Login By Rest
    Should Be Equal    ${status}    PASS
#    Should Contain    ${out}    Plan validation success
    # 20250106: wait for new api to provide validate function

Case Precondition
    Log To Console    Case Precondition
    Common Test Setup For AIC
    vDU Login By Rest

Case Postcondition
    Log To Console    Case Postcondition
    Run Keyword And Ignore Error    vdu.delete_staged_plan_file    plan_id=${plan_id}
    vDU Logout By Rest
    Common Test Teardown For AIC