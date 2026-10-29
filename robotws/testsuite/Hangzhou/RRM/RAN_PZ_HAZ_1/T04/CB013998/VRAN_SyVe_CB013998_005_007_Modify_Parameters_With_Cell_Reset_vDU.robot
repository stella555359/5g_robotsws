*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
#Parameter type is condition RAT Reset which will trigger rat reset
&{plan_info_13998_005_reset1}      scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-0     #MRBTS-11084/NRBTS-11084/NRCELL-1
...    parameter_name=actCceSplit    value1=true    value2=false
&{plan_info_13998_005_reset2}      scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-0
...    parameter_name=actCceSplit    value1=true    value2=false
@{plan_info_005_reset_list}    ${plan_info_13998_005_reset1}    ${plan_info_13998_005_reset2}
#Parameter type is condition RAT Reset which will not trigger rat reset
&{plan_info_13998_005_online1}      scf_distName=MRBTS-11084/NRBTS-11084
...    parameter_name=applyPriorityAccess    value1=none    value2=HPA
&{plan_info_13998_005_online2}      scf_distName=MRBTS-11084/NRBTS-11084
...    parameter_name=applyPriorityAccess    value1=none    value2=HPA
@{plan_info_005_online_list}    ${plan_info_13998_005_online1}    ${plan_info_13998_005_online2}
${RECOVERY_FLAG}    ${False}
${vDU_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CB013998_005_007_Modify_Parameters_With_Cell_Reset_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.03.2025, yuyan.xu@nokia-sbell.com
    #Scenario1:not trigger cell reset
    Step 1: Random Select Not Cell Reset Parameter
    Step 2: Modify Parameter On vDU And Check Not Cell Reset Behavior
    Step 3: Create Plan SyVe For Not Cell Reset
    Step 4: Provision The Plan SyVe On NetAct And Check Not Cell Reset Behavior
    Step 5: Check Modified Not Cell Reset Parameter On Netact
    #Scenario2:trigger cell reset
    Step 6: Random Select Cell Reset Parameter
    Step 7: Modify Parameter On vDU And Check Cell Reset Behavior
    Step 8: Create Plan SyVe For Cell Reset
    Step 9: Provision The Plan SyVe On NetAct And Check Cell Reset Behavior
    Step 10: Check Modified Cell Reset parameter On NetAct

Step ${index}: Random Select Not Cell Reset Parameter
    Log To Console    Step ${index}: Random Select Not Cell Reset Parameter
    ${plan_info_online}    Evaluate    random.choice(${plan_info_005_online_list})    modules=random, sys
    Set Test Variable    ${plan_info_online}
    Log To Console    plan_info_online:${plan_info_online}    console=True
    ${origin_value}    Get Parameter Value From vDU    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_online['value2']}"
    ...    ${plan_info_online['value1']}    ${plan_info_online['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_online}    value=${origin_value}

Step ${index}: Modify Parameter On vDU And Check Not Cell Reset Behavior
    Log To Console    Step ${index}: Modify Parameter On vDU And Check Not Cell Reset Behavior
    @{para_list}    Create List    ${plan_info_online['parameter_name']}
    @{value_list}    Create List    ${value_to_set_webem}
    @{mo_list}    Create List    ${plan_info_online['scf_distName']}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${False}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Log To Console    Start Check Action
    FOR    ${index}    IN RANGE    0    20
        vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
        Sleep    5s
    END
    #yuki need check module new operation status
    #Get Status Of Perform Delta Recommissioning operation_id=${operation_id}, should_activate=${should_activate}

Step ${index}: Create Plan SyVe For Not Cell Reset
    Log To Console    Step ${index}: Create Plan SyVe For Not Cell Reset
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_online['parameter_name']}=${plan_info_online['value']}
    ${value_tmp}    Set Variable If    "${params["applyPriorityAccess"]}"=="none"    0    1
    ${parameter_NA}    Create Dictionary    ${plan_info_online['parameter_name']}=${value_tmp}
    Set Test Variable    ${parameter_NA}

    ${mo_params}    Create Dictionary    ${plan_info_online['scf_distName']}=${parameter_NA}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Provision The Plan SyVe On NetAct And Check Not Cell Reset Behavior
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct And Check Not Cell Reset Behavior
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vDU_id}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    FOR    ${index}    IN RANGE    0    20
        vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
        Sleep    5s
    END
    ${result_Activate}    tafssh.Read Output
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${plan_name}_backup   operation_type=plan
    [Teardown]    tafssh.disconnect

Step ${index}: Check Modified Not Cell Reset Parameter On Netact
    Log To Console    Step ${index}: Check Modified Not Cell Reset Parameter On Netact
    Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}   dist_name=PLMN-PLMN/${plan_info_online['scf_distName']}   &{parameter_NA}


Step ${index}: Random Select Cell Reset Parameter
    Log To Console    Step ${index}: Random Select Cell Reset Parameter
    ${plan_info_reset}    Evaluate    random.choice(${plan_info_005_reset_list})    modules=random, sys
    Set Test Variable    ${plan_info_reset}
    Log To Console    plan_info_online:${plan_info_reset}    console=True
    vDU Login By Rest
    ${origin_value}    Get Parameter Value From vDU    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_reset['value2']}"
    ...    ${plan_info_reset['value1']}    ${plan_info_reset['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_reset}    value=${origin_value}

Step ${index}: Modify Parameter On vDU And Check Cell Reset Behavior
    Log To Console    Step ${index}: Modify Parameter On vDU And Check Cell Reset Behavior
    @{para_list}    Create List    ${plan_info_reset['parameter_name']}
    @{value_list}    Create List    ${value_to_set_webem}
    @{mo_list}    Create List    ${plan_info_reset['scf_distName']}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vdu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${False}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Log To Console    Start Check Action
    vDU Login By Rest
    ${cellState_disable}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    administrativeState=Unlocked
    Wait Until Keyword Succeeds    5min    2s    Check Specified Cell Status On vDU
    ...    ${plan_info_reset['scf_distName'].split("/")[-1]}    ${cellState_disable}
    Wait Until Keyword Succeeds    10min    5s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    #yuki need check module new operation status
    #Get Status Of Perform Delta Recommissioning operation_id=${operation_id}, should_activate=${should_activate}


Step ${index}: Create Plan SyVe For Cell Reset
    Log To Console    Step ${index}: Create Plan SyVe For Cell Reset
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_reset['parameter_name']}=${plan_info_reset['value']}
    ${mo_params}    Create Dictionary    ${plan_info_reset['scf_distName']}=${params}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Provision The Plan SyVe On NetAct And Check Cell Reset Behavior
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct And Check Cell Reset Behavior
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vDU_id}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    vDU Login By Rest
    ${cellState_disable}    Create Dictionary
    ...    operationalState=disabled    availabilityStatus=off line    administrativeState=Unlocked
    Wait Until Keyword Succeeds    3min    2s    Check Specified Cell Status On vDU
    ...    ${plan_info_reset['scf_distName'].split("/")[-1]}    ${cellState_disable}
    ${result_Activate}    tafssh.Read Output
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    10min    5s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${plan_name}_backup   operation_type=plan
    [Teardown]    tafssh.disconnect

Step ${index}: Check Modified Cell Reset Parameter On Netact
    Log To Console    Step ${index}: Check Modified Cell Reset Parameter On Netact
    Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}   dist_name=PLMN-PLMN/${plan_info_reset['scf_distName']}   &{params}


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    vDU Login By Rest
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Log    ${ReIntegrate_vCU}
    Run Keyword If    ${ReIntegrate_vDU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${du_ip}    PLMN-PLMN/MRBTS-${vDU_id}    ${du_release}    ${du_mr}

Case Postcondition
    Log To Console    Case Postcondition
    ${out}   Run Keyword If    ${RECOVERY_FLAG}
    ...    Parameter Operation    operation=full_commission    product_type=vdu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml
    Wait Until Keyword Succeeds    20min    30s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct