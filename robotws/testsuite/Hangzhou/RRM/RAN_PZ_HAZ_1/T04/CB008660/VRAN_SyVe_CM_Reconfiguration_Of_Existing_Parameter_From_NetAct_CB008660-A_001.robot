*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for VRAN_SyVe_CB008660-A_001_CM_Reconfiguration of existing distname-type parameter from NMS
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{plan_info_8660_vran001_1}      scf_distName=MRBTS-11084/NRBTS-11084/NRDU-1
...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRDU-1    parent_parameter_name=f1Cplane    parameter_name=ipV4AddressDN1
...    shortenedDN=TNL-2/IPNO-1/IPIF-1/IPADDRESSV4-1    incorrect_shortenedDN=IPADDRESSV4-1
&{plan_info_8660_vran001_2}      scf_distName=MRBTS-11084/NRBTS-11084/NRDU-1
...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRDU-1    parent_parameter_name=f1Uplane    parameter_name=ipV4AddressDN1
...    shortenedDN=TNL-3/IPNO-1/IPIF-1/IPADDRESSV4-1   incorrect_shortenedDN=IPADDRESSV4-1
#&{plan_info_8660_vran001_3}      scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-0
#...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRCELL-0    parent_parameter_name=cellBwpList    parameter_name=bwpDN
#...    shortenedDN=BWP_PROFILE-5    incorrect_shortenedDN=BWP_PROFILE-1    # can't create mandatory parameter auto from nms
&{plan_info_8660_vran001_4}      scf_distName=MRBTS-11084/MNL-1/MNLENT-1/MPLANENW-1
...    mo_id=PLMN-PLMN/MRBTS-11084/MNL-1/MNLENT-1/MPLANENW-1   parent_parameter_name=None    parameter_name=mPlaneIpv4AddressDN
...    shortenedDN=TNL-1/IPNO-1/IPIF-2/IPADDRESSV4-1    incorrect_shortenedDN=IPADDRESSV4-1
&{plan_info_8660_vran001_5}      scf_distName=MRBTS-11084/NRBTS-11084/NRDRB-1
...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRDRB-1   parent_parameter_name=None    parameter_name=nrDrbMacDN
...    shortenedDN=NRDRB_MAC-1   incorrect_shortenedDN=NRDRB_MAC-11
&{plan_info_8660_vran001_6}      scf_distName=MRBTS-11084/NRBTS-11084/NRDRB-1
...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRDRB-1   parent_parameter_name=None    parameter_name=nrDrbRlcAmDN
...    shortenedDN=NRDRB_RLC_AM-1    incorrect_shortenedDN=NRDRB_RLC_AM-2
&{plan_info_8660_vran001_7}      scf_distName=MRBTS-11084/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1
...    mo_id=PLMN-PLMN/MRBTS-11084/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-1    parent_parameter_name=None    parameter_name=linkSelectorDN
...    shortenedDN=TNL-2/ETHSVC-1/ETHLK-1     incorrect_shortenedDN=ETHLK-1
&{plan_info_8660_vran001_8}      scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-0
...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRCELL-0    parent_parameter_name=None    parameter_name=nrSysInfoProfileDN
...    shortenedDN=NRSYSINFO_PROFILE-1    incorrect_shortenedDN=NRSYSINFO_PROFILE-0
#&{plan_info_8660_vran001_9}      scf_distName=MRBTS-11084/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1
#...    mo_id=PLMN-PLMN/MRBTS-11084/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-1/CHANNEL-1    parent_parameter_name=None
#...    parameter_name=resourceDN
#...    shortenedDN=PHYANT-1   incorrect_shortenedDN=RMOD-2/PHYANT-1
&{plan_info_8660_vran001_10}      scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-0
...    mo_id=PLMN-PLMN/MRBTS-11084/NRBTS-11084/NRCELL-0    parent_parameter_name=None    parameter_name=trackingAreaDN
...    shortenedDN=TRACKINGAREA-1   incorrect_shortenedDN=TRACKINGAREA-2

*** Keywords ***
TC__VRAN_SyVe_CM_Reconfiguration_Of_Existing_Parameter_From_NetAct_CB008660-A_001
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    03.02.2023, yuyan.xu@nokia-sbell.com, draft
    Step 1: Random Select Parameter
    Step 2: Create and edit plan SyVe
    Step 3: Export the plan SyVe
    Step 4: Provision the plan SyVe And Check Action
    Step 5: Check modified parameter in Netact after provision plan
    Step 6: Provision the backup plan
    Step 7: Create and edit plan SyVe with incorrect shortenedDN
    Step 8: Export the plan SyVe
    Step 9: Provision the plan SyVe with incorrect shortenedDN

Step ${index}: Random Select Parameter
    Log    Step ${index}: TC parameters check started    console=True
    ${tmp_list}    Create List    ${plan_info_8660_vran001_1}    ${plan_info_8660_vran001_2}    #${plan_info_8660_vran001_3}
    ...    ${plan_info_8660_vran001_4}    ${plan_info_8660_vran001_5}    ${plan_info_8660_vran001_6}    ${plan_info_8660_vran001_7}
    ...    ${plan_info_8660_vran001_8}   ${plan_info_8660_vran001_10}
    ${plan_info}    Evaluate    random.choice(${tmp_list})    modules=random, sys
    Set Test Variable    ${plan_info}
    ${parameter}    Run Keyword If    "${plan_info['parent_parameter_name']}"=="None"
    ...    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['shortenedDN']}
    ...    ELSE    Set_Complex_Parameter    ${plan_info}    ${plan_info['shortenedDN']}
    ${incorrect_parameter}    Run Keyword If    "${plan_info['parent_parameter_name']}"=="None"
    ...    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['incorrect_shortenedDN']}
    ...    ELSE    Set_Complex_Parameter    ${plan_info}    ${plan_info['incorrect_shortenedDN']}
    ${TNL_RELATED}    Run Keyword And Return Status    Should Contain    ${plan_info['shortenedDN']}    TNL
    ${error_message}    Run Keyword If    ${TNL_RELATED}    Set Error Msg For TNL
    ...    ELSE    Set Error Msg For no TNL
    Set Test Variable    ${parameter}
    Set Test Variable    ${incorrect_parameter}
    Set Test Variable    ${error_message}
    ${same_value}=    Run Keyword And Return Status    Check Actual Configuration Parameters    ne=PLMN-PLMN/MRBTS-${vDU_id}
    ...    dist_name=${plan_info['mo_id']}    &{parameter}
    Set Test Variable    ${same_value}
    Run Keyword If    ${same_value}    Log
    ...    TC parameters check failed: Parameters values to be provisioned are identical to the existing ones!    level=WARN
    ...    ELSE    Log    TC parameters successfully checked    console=True
    Should Not Be True    ${same_value}
    Log    plan_info:${plan_info}    console=True

Set Error Msg For TNL
    ${tmp_err_1}    Set Variable    Distname parameter '${plan_info['parameter_name']}' value '${plan_info['incorrect_shortenedDN']}' is invalid
    ${tmp_err_2}    Set Variable    because the shortened distinguished names pointing to objects under TNL object model tree
    ${tmp_err_3}    Set Variable    Distname parameter '${plan_info['parent_parameter_name']}-1.${plan_info['parameter_name']}'
    ${tmp_err_4}    Set Variable    value '${plan_info['incorrect_shortenedDN']}' is invalid
    ${tmp_err_5}    Set Variable    must start at least from TNL and cannot be shortened further
    ${error_message}    Set Variable If    "${plan_info['parent_parameter_name']}"=="None"    ${tmp_err_1} ${tmp_err_2} ${tmp_err_5}
    ...    "${plan_info['parent_parameter_name']}"!="None"    ${tmp_err_3} ${tmp_err_4} ${tmp_err_2} ${tmp_err_5}
    [Return]    ${error_message}

Set Error Msg For no TNL
    ${tmp_err_1}    Set Variable    references non-existing '${plan_info['incorrect_shortenedDN']}' object
    ${tmp_err_2}    Set Variable    Distname parameter '${plan_info['parameter_name']}'
    ${tmp_err_3}    Set Variable    Distname parameter '${plan_info['parent_parameter_name']}-1.${plan_info['parameter_name']}'
    ${error_message}    Set Variable If    "${plan_info['parent_parameter_name']}"=="None"    ${tmp_err_2} ${tmp_err_1}
    ...    "${plan_info['parent_parameter_name']}"!="None"    ${tmp_err_3} ${tmp_err_1}
    [Return]    ${error_message}

Step ${index}: Create and edit plan SyVe
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    vDU Login By Rest
    ${scf_initial_vdu}    vdu.Get Current Plan File     local_dir_path=${TEST_LOG_DIRECTORY}
    ...    filename=actual_plan_${timestamp}.xml    include_runtime_data=${False}
    vDU Logout By Rest
    Set Test Variable    ${scf_initial_vdu}
    ${plan}    NetAct Create And Edit Plan    BTS_scf_initial=${scf_initial_vdu}    name=${plan_name}
    ...    description=Automation SyVe for MRBTS-${vDU_id}    mo_id=${plan_info['mo_id']}
    ...    scf_distName=${plan_info['scf_distName']}    &{parameter}
    Set Test Variable    ${plan}

Step ${index}: Export the plan SyVe
    Log    Step ${index}: Export the plan SyVe    console=True
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}/NetActLogs    file_name=${plan_name}.xml    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    plan_name=${plan_name}    operation_type=plan

Step ${index}: Provision the plan SyVe And Check Action
    Log    Step ${index}: Provision the plan SyVe And Check Action    console=True
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vDU_id} -createBackupPlan true
    ${cmd2}    Set Variable    -backupPlanName ${plan_name}_backup -v -provisioningOperation activate
    ${cmd3}    Set Variable    -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command    ${cmd1} ${cmd2} ${cmd3}
    ${NEED_SCF_RECOVERY_FLAG}    Set Variable    True
    Log    Check Action    console=True
    FOR    ${index}    IN RANGE    0    30
        sleep    1s
        vDU Check All Cells Status Should Be Onair For All DUs
    END
    ${result_Activate}    tafssh.Read Output
    Should Contain    ${result_Activate}    Provision of the plan was successful

Step ${index}: Check modified parameter in Netact after provision plan
    Log    Step ${index}: Check modified parameter in Netact after provision plan    console=True
    Wait Until Keyword Succeeds    5x    10s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}    dist_name=${plan_info['mo_id']}    &{parameter}

Step ${index}: Provision the backup plan
    Log    Step ${index}: Provision the backup plan    console=True
    NetAct Provision Plan    plan_name=${plan_name}_backup    dist_names=PLMN-PLMN/MRBTS-${vDU_id}
    ...    backup_plan_name=None    create_backup_plan=False    provisioning_operation=activate

Step ${index}: Create and edit plan SyVe with incorrect shortenedDN
    Log    Step ${index}: Create and edit plan SyVe    console=True
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Should Be String    MRBTS-${vDU_id}_${timestamp}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${plan}    NetAct Create And Edit Plan    BTS_scf_initial=${scf_initial_vdu}    name=${plan_name}
    ...    description=Automation SyVe for MRBTS-${vDU_id}    mo_id=${plan_info['mo_id']}
    ...    scf_distName=${plan_info['scf_distName']}    &{incorrect_parameter}
    Set Test Variable    ${plan}

Step ${index}: Provision the plan SyVe with incorrect shortenedDN
    Log    Step ${index}: Provision the plan SyVe with incorrect shortenedDN    console=True
    ${status}    ${feedback}    Run Keyword And Ignore Error    netact.Provision Plan    plan_name=${plan_name}
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    create_backup_plan=False    provisioning_operation=activate
    Should Contain    ${feedback}    ${error_message}
    Should Contain    ${feedback}    FAILURE    failed
    Should Contain    ${feedback}    Validation failed

Set_Complex_Parameter
    [Arguments]    ${plan_info}    ${value}
    &{parameter_child}    Create Dictionary    ${plan_info['parameter_name']}=${value}
    @{parameter_child_list}    Create List    ${parameter_child}
    &{parameter}    Create Dictionary    ${plan_info['parent_parameter_name']}=@{parameter_child_list}
    [Return]    ${parameter}

Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    ${NEW_PLAN_NAME}   Get Test Case Name
    Set Test Variable  ${NEW_PLAN_NAME}
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

Particular Teardown
    Log    Particular Teardown   console=True
    ${current_value}    Run Keyword And Return Status    Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}    dist_name=${plan_info['mo_id']}    &{parameter}
    Run Keyword If    ${current_value} and not ${same_value}    Run Keywords
    ...    Log   Parameters were not reset to initial values! Probably backup plan was not provisioned! Will perform commissioning with initial scf!
    ...    level=WARN
    ...    AND    Recovery Parameter Value

Recovery Parameter Value
    vDU Login By Rest
    ${plan_id}    ${action_id}    ${validation_id}    Upload And Validate Plan    plan_file=${scf_initial_vdu}
    Activate Plan By REST    ${plan_id}
    vdu.disconnect
    Wait Until Keyword Succeeds    20x    60s    vDU Check All Cells Status Should Be Onair For All DUs
