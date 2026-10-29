*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
#Parameter type is condition RAT Reset which will trigger rat reset
&{plan_info_13998_004_reset1}      scf_distName=MRBTS-11084/NRBTS-11084/NRDU-1
...    parameter_name=crntiAllocationOption    value1=max72cells    value2=max144cells
&{plan_info_13998_004_reset2}      scf_distName=MRBTS-11084/NRBTS-11084
...    parameter_name=actLteNrDss    value1=true    value2=false
@{plan_info_004_reset_list}    ${plan_info_13998_004_reset1}      #${plan_info_13998_004_reset2}
#Parameter type is condition RAT Reset which will not trigger rat reset
&{plan_info_13998_004_online1}      scf_distName=MRBTS-11084/NRBTS-11084
...    parameter_name=actAutoPrachConfigIndexFdd    value1=true    value2=false
&{plan_info_13998_004_online2}      scf_distName=MRBTS-11084/NRBTS-11084
...    parameter_name=actAutoPrachConfigIndexFdd    value1=true    value2=false
@{plan_info_004_online_list}    ${plan_info_13998_004_online1}    ${plan_info_13998_004_online2}
${RECOVERY_FLAG}    ${False}
${vDU_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CB013998_004_Modify_Parameters_With_RAT_Reset_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.03.2025, yuyan.xu@nokia-sbell.com
    #Scenario1:not trigger rat reset
    Step 1: Random Select Not RAT Reset Parameter
    Step 2: Modify Parameter On vDU And Check Not RAT Reset Behavior
    Step 3: Create Plan SyVe For Not RAT Reset
    Step 4: Provision The Plan SyVe On NetAct And Check Not RAT Reset Behavior
    Step 5: Check Modified Not RAT Reset Parameter On Netact
    #Scenario2:trigger rat reset
    Step 6: Random Select RAT Reset Parameter
    Step 7: Modify Parameter On vDU And Check RAT Reset Behavior
    Step 8: Create Plan SyVe For RAT Reset
    Step 9: Provision The Plan SyVe On NetAct And Check RAT Reset Behavior
    Step 10: Check Modified RAT Reset parameter On NetAct

Step ${index}: Random Select Not RAT Reset Parameter
    Log To Console    Step ${index}: Random Select Not RAT Reset Parameter
    ${plan_info_online}    Evaluate    random.choice(${plan_info_004_online_list})    modules=random, sys
    Set Test Variable    ${plan_info_online}
    Log To Console    plan_info_online:${plan_info_online}    console=True
    ${origin_value}    Get Parameter Value From vDU    ${plan_info_online['scf_distName']}    ${plan_info_online['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_online['value2']}"
    ...    ${plan_info_online['value1']}    ${plan_info_online['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_online}    value=${origin_value}

Step ${index}: Modify Parameter On vDU And Check Not RAT Reset Behavior
    Log To Console    Step ${index}: Modify Parameter On vDU And Check Not RAT Reset Behavior
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

Step ${index}: Create Plan SyVe For Not RAT Reset
    Log To Console    Step ${index}: Create Plan SyVe For Not RAT Reset
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_online['parameter_name']}=${plan_info_online['value']}
    ${mo_params}    Create Dictionary    ${plan_info_online['scf_distName']}=${params}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Provision The Plan SyVe On NetAct And Check Not RAT Reset Behavior
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct And Check Not RAT Reset Behavior
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

Step ${index}: Check Modified Not RAT Reset Parameter On Netact
    Log To Console    Step ${index}: Check Modified Not RAT Reset Parameter On Netact
    Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}   dist_name=PLMN-PLMN/${plan_info_online['scf_distName']}   &{params}


Step ${index}: Random Select RAT Reset Parameter
    Log To Console    Step ${index}: Random Select RAT Reset Parameter
    ${plan_info_reset}    Evaluate    random.choice(${plan_info_004_reset_list})    modules=random, sys
    Set Test Variable    ${plan_info_reset}
    Log To Console    plan_info_online:${plan_info_reset}    console=True
    vDU Login By Rest
    ${origin_value}    Get Parameter Value From vDU    ${plan_info_reset['scf_distName']}    ${plan_info_reset['parameter_name']}
    Set Test Variable    ${origin_value}
    ${value_to_set_webem}    Set Variable If    "${origin_value}"=="${plan_info_reset['value2']}"
    ...    ${plan_info_reset['value1']}    ${plan_info_reset['value2']}
    Set Test Variable    ${value_to_set_webem}
    Set To Dictionary    ${plan_info_reset}    value=${origin_value}
    ${rat_str}    Set Variable    ${plan_info_reset['scf_distName'].split("/")[1].split("-")[0]}
    ${cell_str}    Set Variable If    "${rat_str}" == "LNBTS"    LNCEL    "${rat_str}" == "NRBTS"    NRCELL
    ${cells_list}    vdu.get_vdu_cell_id
    ${impact_cell_list}    Create List
    FOR    ${cell}    IN    @{cells_list}
        ${key}    Get Dictionary Keys    ${cell}
        Run Keyword If    "${key[0].split("-")[0]}"=="${cell_str}"    Append To List    ${impact_cell_list}    ${key[0]}
    END
    Set Test Variable    ${impact_cell_list}

Step ${index}: Modify Parameter On vDU And Check RAT Reset Behavior
    Log To Console    Step ${index}: Modify Parameter On vDU And Check RAT Reset Behavior
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
    ${check_impact_cell_list}    Copy List    ${impact_cell_list}
    FOR    ${index}    IN RANGE    0    50
        FOR    ${impact_cell}    IN    @{check_impact_cell_list}
            ${status}    run keyword and return status    Check Specified Cell Status On vDU    ${impact_cell}    ${cellState_disable}
            Run Keyword If    ${status}    Remove Values From List    ${check_impact_cell_list}    ${impact_cell}
        END
        Sleep    5s
        Exit For Loop If    "${check_impact_cell_list.__len__()}"=="${0}"
    END
    Should Be True    "${check_impact_cell_list.__len__()}"=="${0}"
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0


Step ${index}: Create Plan SyVe For RAT Reset
    Log To Console    Step ${index}: Create Plan SyVe For RAT Reset
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${params}    Create Dictionary    ${plan_info_reset['parameter_name']}=${plan_info_reset['value']}

    ${value_tmp}    Set Variable If    "${params["crntiAllocationOption"]}"=="max72cells"    72    144
    ${parameter_NA}    Create Dictionary    ${plan_info_reset['parameter_name']}=${value_tmp}
    Set Test Variable    ${parameter_NA}

    ${mo_params}    Create Dictionary    ${plan_info_reset['scf_distName']}=${parameter_NA}
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup
    Set Test Variable    ${params}

Step ${index}: Provision The Plan SyVe On NetAct And Check RAT Reset Behavior
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct And Check RAT Reset Behavior
    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
    Log To Console    Start Plan Provision
    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vDU_id}
    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
    Log To Console    Start Check Action
    ${reset_status}    Set Variable
    FOR    ${index}    IN RANGE    0    20
        ${reset_status}    Run Keyword And Return Status    Check IP Is Pingable    ${vDU_oamssh_ip}    expect_pingable=${False}
        Exit For Loop If    ${reset_status}
        Sleep    10s
    END
    ${result_Activate}    tafssh.Read Output
    Set Test Variable    ${RECOVERY_FLAG}    ${False}
    Wait Until Keyword Succeeds    20min    60s    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    Should Be True    ${reset_status}
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${plan_name}_backup   operation_type=plan
    [Teardown]    tafssh.disconnect

Step ${index}: Check Modified RAT Reset Parameter On Netact
    Log To Console    Step ${index}: Check Modified RAT Reset Parameter On Netact
    Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}   dist_name=PLMN-PLMN/${plan_info_reset['scf_distName']}   &{parameter_NA}


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