*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
#Parameter type is condition RAT Reset which will trigger rat reset
&{plan_info_13998_002_reset1}      scf_distName=MRBTS-11083/NRBTS-11084/NRCELL-0
...    parameter_name=actAperCsi     value1=true    value2=false
&{plan_info_13998_002_reset2}      scf_distName=MRBTS-11083/NRBTS-11084/NRCELL-0
...    parameter_name=actCceSplit    value1=true    value2=false
@{plan_info_002_reset_list}    ${plan_info_13998_002_reset1}    ${plan_info_13998_002_reset2}
#Parameter type is condition RAT Reset which will not trigger rat reset
&{plan_info_13998_002_online1}      scf_distName=MRBTS-11083/NRBTS-11084
...    parameter_name=actUserPreemption    value1=true    value2=false
&{plan_info_13998_002_online2}      scf_distName=MRBTS-11083/NRBTS-11084/NRCELL-0
...    parameter_name=maxNumOfUsersPerNRCell    value1=275    value2=276
@{plan_info_002_online_list}    ${plan_info_13998_002_online1}    ${plan_info_13998_002_online2}
${RECOVERY_FLAG}    ${False}
${vCU_oamssh_ip}    ${tl.gnbs[0].cu.oam_ssh_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CB013998_002_003_Modify_Parameters_With_Cell_Reset_CU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.03.2025, yuyan.xu@nokia-sbell.com
    #Scenario1:not trigger rat reset
    Step 1: Random Select Not Cell Reset Parameter
    Step 2: Modify Parameter On vCU And Check Not Cell Reset Behavior
    Step 3: Create Plan SyVe For Not Cell Reset
    Step 4: Provision The Plan SyVe On NetAct And Check Not Cell Reset Behavior
    Step 5: Check Modified Not Cell Reset Parameter On Netact
    #Scenario2:trigger rat reset
    Step 6: Random Select Cell Reset Parameter
    Step 7: Modify Parameter On vCU And Check Cell Reset Behavior
    Step 8: Create Plan SyVe For Cell Reset
    Step 9: Provision The Plan SyVe On NetAct And Check Cell Reset Behavior
    Step 10: Check Modified Cell Reset parameter On NetAct

Step ${index}: Random Select Not Cell Reset Parameter
    Log To Console    Step ${index}: Random Select Not Cell Reset Parameter
    ${plan_info_online}    Evaluate    random.choice(${plan_info_002_online_list})    modules=random, sys
    Set Test Variable    ${plan_info_online}
    Log To Console    plan_info_online:${plan_info_online}
    ${origin_value}    Get Parameter Value From vCU    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_online['value2']}"
    ...    ${plan_info_online['value1']}    ${plan_info_online['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_online}    value=${origin_value}

Step ${index}: Modify Parameter On vCU And Check Not Cell Reset Behavior
    Log To Console    Step ${index}: Modify Parameter On vCU And Check Not Cell Reset Behavior
    @{para_list}    Create List    ${plan_info_online['parameter_name']}
    @{value_list}    Create List    ${value_to_set_webem}
    @{mo_list}    Create List    ${plan_info_online['scf_distName']}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vcu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${False}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Log To Console    Start Check Action
    FOR    ${index}    IN RANGE    0    20
        Check All Cells On Air In vCU    gnb_index=0
        Sleep    5s
    END
    #yuki need check module new operation status

Step ${index}: Create Plan SyVe For Not Cell Reset
    Log To Console    Step ${index}: Create Plan SyVe For Not Cell Reset
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vCU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_online['parameter_name']}=${plan_info_online['value']}
    ${mo_params}    Create Dictionary    ${plan_info_online['scf_distName']}=${params}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf_vcu/vCU_scf.xml    ${plan_name}    Automation SyVe for MRBTS-${vCU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Provision The Plan SyVe On NetAct And Check Not Cell Reset Behavior
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct And Check Not Cell Reset Behavior
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vCU_id}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    FOR    ${index}    IN RANGE    0    20
        Check All Cells On Air In vCU    gnb_index=0
        Sleep    5s
    END
    ${result_Activate}    tafssh.Read Output
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vCU_id}    plan_name=${plan_name}_backup   operation_type=plan
    [Teardown]    tafssh.disconnect

Step ${index}: Check Modified Not Cell Reset Parameter On Netact
    Log To Console    Step ${index}: Check Modified Not Cell Reset Parameter On Netact
    Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vCU_id}   dist_name=PLMN-PLMN/${plan_info_online['scf_distName']}   &{params}


Step ${index}: Random Select Cell Reset Parameter
    Log To Console    Step ${index}: Random Select Cell Reset Parameter
    ${plan_info_reset}    Evaluate    random.choice(${plan_info_002_reset_list})    modules=random, sys
    Set Test Variable    ${plan_info_reset}
    Log To Console    plan_info_online:${plan_info_reset}
    Login To vCU By Rest
    ${origin_value}    Get Parameter Value From vCU    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_reset['value2']}"
    ...    ${plan_info_reset['value1']}    ${plan_info_reset['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_reset}    value=${origin_value}

Step ${index}: Modify Parameter On vCU And Check Cell Reset Behavior
    Log To Console    Step ${index}: Modify Parameter On vCU And Check Cell Reset Behavior
    @{para_list}    Create List    ${plan_info_reset['parameter_name']}
    @{value_list}    Create List    ${value_to_set_webem}
    @{mo_list}    Create List    ${plan_info_reset['scf_distName']}
    ${out}    Parameter Operation    operation=parameter_update    product_type=vcu
    ...    para_list=@{para_list}    mo_list=@{mo_list}    value_list=@{value_list}    wait_for_completion=${False}
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Log To Console    Start Check Action
    Login To vCU By Rest
    ${cellState_disable}    Create Dictionary
    ...    operationalState=disabled    administrativeState=Unlocked
    Wait Until Keyword Succeeds    5min    2s    Check Specified Cell Status On vCU
    ...    ${plan_info_reset['scf_distName'].split("/")[-1]}    ${cellState_disable}
    Wait Until Keyword Succeeds    10min    5s    Check All Cells On Air In vCU    gnb_index=0
    #yuki need check module new operation status

Step ${index}: Create Plan SyVe For Cell Reset
    Log To Console    Step ${index}: Create Plan SyVe For Cell Reset
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vCU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_reset['parameter_name']}=${plan_info_reset['value']}
    ${mo_params}    Create Dictionary    ${plan_info_reset['scf_distName']}=${params}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf_vcu/vCU_scf.xml    ${plan_name}    Automation SyVe for MRBTS-${vCU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Provision The Plan SyVe On NetAct And Check Cell Reset Behavior
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct And Check Cell Reset Behavior
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vCU_id}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    Login To vCU By Rest
    ${cellState_disable}    Create Dictionary
    ...    operationalState=disabled    administrativeState=Unlocked    #availabilityStatus=off line
    Wait Until Keyword Succeeds    5min    2s    Check Specified Cell Status On vCU
    ...    ${plan_info_reset['scf_distName'].split("/")[-1]}    ${cellState_disable}
    ${result_Activate}    tafssh.Read Output
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    10min    5s    Check All Cells On Air In vCU    gnb_index=0
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vCU_id}    plan_name=${plan_name}_backup   operation_type=plan
    [Teardown]    tafssh.disconnect

Step ${index}: Check Modified Cell Reset Parameter On Netact
    Log To Console    Step ${index}: Check Modified Cell Reset Parameter On Netact
    Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vCU_id}   dist_name=PLMN-PLMN/${plan_info_reset['scf_distName']}   &{params}


Case Precondition
    [Arguments]    ${ReIntegrate_vCU}=False    ${ReIntegrate_vDU}=False
    Log To Console    Case Precondition
    Common Test Setup For AIC
    Login To vCU By Rest
    Setup NetAct    ${NETACT}
    #ReIntegrate NE
    Log    ${ReIntegrate_vDU}
    Run Keyword If    ${ReIntegrate_vCU}    Wait Until Keyword Succeeds    2x    15s
    ...    Integrate NE To NetAct    ${cu_ip}    PLMN-PLMN/MRBTS-${vCU_id}    ${cu_release}    ${cu_mr}

Case Postcondition
    Log To Console    Case Postcondition
    ${out}   Run Keyword If    ${RECOVERY_FLAG}
    ...    Parameter Operation    operation=full_commission    product_type=vcu    scf_path=${TEST_LOG_DIRECTORY}/backup_scf_vcu/vCU_scf.xml
    Wait Until Keyword Succeeds    20min    30s    Check All Cells On Air In vCU    gnb_index=0
    Common Test Teardown For AIC
    Teardown NetAct