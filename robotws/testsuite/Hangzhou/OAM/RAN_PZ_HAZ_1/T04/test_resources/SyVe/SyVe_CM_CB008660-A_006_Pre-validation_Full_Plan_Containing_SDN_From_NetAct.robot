*** Settings ***
Documentation       Test case for xxx
...                 Author: xxx
...                 Contact: xxx.xx@nokia.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
${SRNCLAB}      SRNCLAB1019    # Netact info defined in NetActs.py under Variables folder
${NETACT}    &{${SRNCLAB}}
&{plan_info_8660_006}      scf_distName=MRBTS-1905/GNBTS-1/GNBCF-1
...    mo_id=MRBTS-1905/LNBTS-4801/TRSNW-0    parameter_name=ipV4AddressDN1
...    shortenedDN=TNL-1/IPNO-1/IPIF-1/IPADDRESSV4-1    incorrect_shortenedDN=IPADDRESSV4-1

*** Keywords ***
SyVe_CM_CB008660-A_006_Pre-validation_Full_Plan_Containing_SDN_From_NetAct
    [Documentation]    [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-xxx
    ...
    ...    *****************
    ...    Basic information
    ...    *****************
    ...    Test for performing mainly to check pre-validates a full configuration plan containing distname-type
    ...    parameter(s) in Shortened Distinguished Name format
    ...
    ...    The main steps performed for the test are:
    ...
    ...    - Random Select Parameter
    ...    - Check initial BTS state
    ...    - Upload configuration status
    ...    - Export the plan SyVe
    ...    - Modify Plan File With Correct SDN
    ...    - Import the plan With Correct SDN
    ...    - PreValidate Plan And Check Result With Correct SDN
    ...    - Modify Plan File With Incorrect SDN
    ...    - Import the plan With Incorrect SDN
    ...    - PreValidate Plan And Check Result With Incorrect SDN
    ...    - Check final BTS state
    ...    - Check final number and state of Cells and RMs
    ...
    ...    Pass criteria: create, edit, export and provision operation works as expected; states and alarms are as expected
    ...
    ...    ******************
    ...    History of changes
    ...    ******************
    ...    - 02.02.2023 - New by Xu Yuyan - New case
    ...    - 10.03.2023 - Add autom download and import sw build to NetAct, delete NE data for temp MRBTS_DN  by Kang Lixin
    Set Tags    OWNER-I_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com    AUTHOR-yuyan.xu@nokia-sbell.com
    Step 1: TC parameters check
    Step 2: Check initial BTS state
    Step 3: Check Builds Exist In NetAct
    Step 4: Upload configuration status
    Step 5: Export the plan SyVe
    Step 6: Modify Plan File With Correct SDN
    Step 7: Import the plan With Correct SDN
    Step 8: PreValidate Plan And Check Result With Correct SDN
    Step 9: Modify Plan File With Incorrect SDN
    Step 10: Import the plan With Incorrect SDN
    Step 11: PreValidate Plan And Check Result With Incorrect SDN
    Step 12: Check final BTS state
    Step 13: Check final number and state of Cells and RMs

Step ${index}: TC parameters check
    Log    Step ${index}: TC parameters check    console=True
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    &{parameter}    Create Dictionary    ${plan_info_8660_006['parameter_name']}=${plan_info_8660_006['shortenedDN']}
    &{incorrect_parameter}    Create Dictionary    ${plan_info_8660_006['parameter_name']}=${plan_info_8660_006['incorrect_shortenedDN']}
    ${tmp_str1}    Set Variable
    ...    Distname parameter '${plan_info_8660_006['parameter_name']}' value '${plan_info_8660_006['incorrect_shortenedDN']}' is invalid
    ${tmp_str2}    Set Variable    because the shortened distinguished names pointing to objects under TNL object model tree
    ${error_message}    Set Variable    ${tmp_str1} ${tmp_str2} must start at least from TNL and cannot be shortened further
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${plan_info_8660_006}
    Set Test Variable    ${parameter}
    Set Test Variable    ${incorrect_parameter}
    Set Test Variable    ${error_message}
    SSHLibrary.Open Connection    ${MPLANE_IP}    BTS_1
    SSHLibrary.Login    toor4nsn    oZPS0POrRieRtu
    ${output}    SSHLibrary.Execute Command    ls /ffs/run/TargetBD*.xml
    ${tmp_ver_str}    Fetch From Left    ${output}    .xml
    ${CUR_VER_BTS}    Fetch From Right    ${tmp_ver_str}    /ffs/run/TargetBD_
    Set Test Variable    ${CUR_VER_BTS}
    SSHLibrary.Switch Connection    BTS_1
    SSHLibrary.Close Connection
    Log    ${plan_info_8660_006}    console=True
    ${same_values}=    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    dist_name=${plan_info_8660_006['mo_id']}    &{parameter}
    Set Test Variable    ${same_values}
    Run Keyword If    ${same_values}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_values}
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MRBTS_DN}1
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MRBTS_DN}2
    Log    plan_info_8660_006:${plan_info_8660_006}    console=True

Step ${index}: Check ${when} BTS state
    [Documentation]    BTS each RAT procedural state is checked to be OnAir (at least one cell operational)
    ...    BTS State is checked according to ute_admin get parameters for all BTS. The JSON returned contains
    ...    informations   such as btsName, btsId, btsProceduralstate
    ...    KW checks if BTS State is onAir. If not, it will fail with received state.
    Log    Step ${index}: Check ${when} BTS state    console=True
    Wait Until Keyword Succeeds    3 min    10 sec    Check BTS RAT Procedural State
    Admin Check Overall BTS Procedural State TAF

Step ${index}: Check ${when} alarms status from WebEM
    Log    Step ${index}: Check ${when} alarms status from WebEM    console=True
    Get and Check Alarms SyVe    source=Bts    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}

Step ${index}: Check ${when} alarms status from Netact
    Log    Step ${index}: Check ${when} alarms status from Netact    console=True
    Get and Check Alarms SyVe    source=Netact    expected_alarms=@{EMPTY}    ignored_alarms=${IGNORED_ALARMS}
    ...   critical_alarms=${CRITICAL_ALARMS}    dist_name=${MRBTS_DN}

Step ${index}: Upload configuration status
    [Documentation]    Uploads configuration data from the network is checked
    Log    Step ${index}: Upload configuration status    console=True
    NetAct CM Upload    dist_names=${MRBTS_DN}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${mrbts_id}_${timestamp}
    Set Test Variable    ${name}    MRBTS-${mrbts_id}_${timestamp}
    NetAct Export Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${name}.xml    dist_names=${MRBTS_DN}
    ...    plan_name=${name}    operation_type=actual

Step ${index}: Modify Plan File With Correct SDN
    Log    Step ${index}: Modify Plan File With Correct SDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${new_name_correct_SDN}    MRBTS-${mrbts_id}1_${timestamp}
    Set Test Variable    ${new_scf_file_name}    ${new_name_correct_SDN}.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name}.xml
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="MNL"]/p[@name="plannedSWReleaseVersion"]    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="${MRBTS_DN}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${CUR_VER_BTS}    \r\n
    ...    cmData/managedObject[@distName="${MRBTS_DN}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="GNBCF"]/p[@name="mPlaneLocalIpAddressDN"]
    ...    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="mPlaneLocalIpAddressDN"/>    xpath=cmData/managedObject[@distName="${MRBTS_DN}/GNBTS-1/GNBCF-1"]
    L_XML.Set Element Text    ${scf_xml}    ${plan_info_8660_006['shortenedDN']}    \r\n
    ...    cmData/managedObject[@distName="${MRBTS_DN}/GNBTS-1/GNBCF-1"]/p[@name="mPlaneLocalIpAddressDN"]

    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    ${file_content}    OperatingSystem.Get File    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    ${file_content}    Replace String    ${file_content}    BTS-${MRBTS_DN.split('-')[-1]}    BTS-${MRBTS_DN.split('-')[-1]}1
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    sleep    10s    time for file creation

Step ${index}: Import the plan With Correct SDN
    Log    Step ${index}: Import the plan With Correct SDN    console=True
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${new_scf_file_name}    plan_name=${new_name_correct_SDN}

Step ${index}: PreValidate Plan And Check Result With Correct SDN
    Log    Step ${index}: PreValidate Plan And Check Result With Correct SDN   console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}    NetAct_1
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${output}    SSHLibrary.Execute Command    racclimx.sh -op PreValidate -DN ${MRBTS_DN}1 -planName ${new_name_correct_SDN} -v
    Log    ${output}    console=${true}
    SSHLibrary.Switch Connection    NetAct_1
    SSHLibrary.Close Connection
    Should Not Contain    ${output}    FAILURE    failed
    Should Not Contain    ${output}    pre-validate failed
    Should Contain    ${output}    pre-validate successful

Step ${index}: Modify Plan File With Incorrect SDN
    Log    Step ${index}: Modify Plan File With Incorrect SDN    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}=    Get Time    format=year,month,day,hour,min
    ${timestamp}=    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${new_name_incorrect_SDN}    MRBTS-${mrbts_id}2_${timestamp}
    Set Test Variable    ${new_scf_file_name}    ${new_name_incorrect_SDN}.xml
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${scf_xml}    L_XML.Parse xml    ${Test Results Dir}/NetActLogs/${name}.xml
    L_XML.Set Elements Attribute    ${scf_xml}    operation    create    cmData/managedObject
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="com.nokia.srbts.mnl:MNL"]/p[@name="plannedSWReleaseVersion"]
    ...    remove_tail=${True}
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="MNL"]/p[@name="plannedSWReleaseVersion"]    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="plannedSWReleaseVersion"/>    xpath=cmData/managedObject[@distName="${MRBTS_DN}/MNL-1"]
    L_XML.Set Element Text    ${scf_xml}    ${CUR_VER_BTS}    \r\n
    ...    cmData/managedObject[@distName="${MRBTS_DN}/MNL-1"]/p[@name="plannedSWReleaseVersion"]
    L_XML.Remove Elements    ${scf_xml}    cmData/managedObject[@class="GNBCF"]/p[@name="mPlaneLocalIpAddressDN"]
    ...    remove_tail=${True}
    L_XML.Add Element    ${scf_xml}    <p name="mPlaneLocalIpAddressDN"/>    xpath=cmData/managedObject[@distName="${MRBTS_DN}/GNBTS-1/GNBCF-1"]
    L_XML.Set Element Text    ${scf_xml}    ${plan_info_8660_006['incorrect_shortenedDN']}    \r\n
    ...    cmData/managedObject[@distName="${MRBTS_DN}/GNBTS-1/GNBCF-1"]/p[@name="mPlaneLocalIpAddressDN"]
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    ${file_content}    OperatingSystem.Get File    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    ${file_content}    Replace String    ${file_content}    BTS-${MRBTS_DN.split('-')[-1]}    BTS-${MRBTS_DN.split('-')[-1]}2
    ${scf_xml}    L_XML.Parse xml    ${file_content}
    L_XML.Save XML    ${scf_xml}    ${Test Results Dir}/NetActLogs/${new_scf_file_name}
    sleep    10s    time for file creation

Step ${index}: Import the plan With Incorrect SDN
    Log    Step ${index}: Import the plan With Incorrect SDN    console=True
    NetAct Import Plan    local_dir=${Test Results Dir}/NetActLogs    file_name=${new_scf_file_name}    plan_name=${new_name_incorrect_SDN}

Step ${index}: PreValidate Plan And Check Result With Incorrect SDN
    Log    Step ${index}: PreValidate Plan And Check Result With Incorrect SDN    console=True
    SSHLibrary.Open Connection    ${NETACT['was_host']}    NetAct_1
    SSHLibrary.Login    ${NETACT['user']}    ${NETACT['password']}
    ${status}    ${feedback}    Run Keyword And Ignore Error
    ...    SSHLibrary.Execute Command    racclimx.sh -op PreValidate -DN ${MRBTS_DN}2 -planName ${new_name_incorrect_SDN} -v
    Log    ${feedback}    console=${true}
    SSHLibrary.Switch Connection    NetAct_1
    SSHLibrary.Close Connection
    Should Contain    ${feedback}    ${error_message}
    Should Contain    ${feedback}    FAILURE    failed
    Should Contain    ${feedback}    pre-validate failed

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]   Check if number of configured cells and radio modules in SCF are properly mapped on BTS running view.
    ...    Check operational states for cells and radio modules
    Log    Step ${index}: Check final number and state of Cells and RMs    console=True
    Final Checks SyVe

Step ${index}: Check Builds Exist In NetAct
    Log    Step ${index}: Check Builds Exist NetAct    console=True
    ${tmp_build_str}    Fetch From Right    ${CUR_VER_BTS}    ENB_
    ${sw_build_pkg}    Set Variable    SBTS00_ENB_${tmp_build_str}
    ${build_exist}    netact.Is Imported    ${CUR_VER_BTS}
    Run Keyword If    not ${build_exist}    Download And Import Build To NetAct    ${sw_build_pkg}

Download And Import Build To NetAct
    [Arguments]    ${target_sw_name}
    Download SBTS SW Build    ${target_sw_name}
    Import SBTS SW Build To NetAct    ${target_sw_name}

Particular Teardown
    Log    Particular Teardown    console=True
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${new_name_correct_SDN}
    Run Keyword And Continue On Failure    Check If NetAct Plan Is Deleted    plan_name=${new_name_incorrect_SDN}
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MRBTS_DN}1
    Run Keyword And Continue On Failure    netact.Delete NE Data From Configurator    ${MRBTS_DN}2
    Common Test Teardown

TC Setup
    Common Test Setup

TC Teardown
    Log    TC Teardown   console=True
    Particular Teardown

