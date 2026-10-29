*** Settings ***
Documentation
...   Author: yuyan.xu@nokia-sbell.com
...   Description: This robot cases is for NFTA CB013998_009_010
Variables       ../TestCases/My_NetAct.py
Resource        ../../Resources/Cloud/AIC_Common_Resource.robot

*** Variables ***
&{plan_info_13998_009_rat}      scf_distName=MRBTS-11084/NRBTS-11084/NRDU-1
...    parameter_name=actNonBfAndBfCa    value1=true    value2=false
&{plan_info_13998_009_cell}      scf_distName=MRBTS-11084/NRBTS-11084/NRCELL-1
...    parameter_name=actPcsiOnF2Fdm    value1=true    value2=false
@{plan_info_009_list}    ${plan_info_13998_009_rat}    ${plan_info_13998_009_cell}
${RECOVERY_FLAG}    ${False}
${vDU_oamssh_ip}    ${tl.gnbs[0].dus[0].oam_http_connection_details.addr}

*** Keywords ***
VRAN_SyVe_CB013998_009_010_Modify_Parameters_With_Different_Modification_Type_vDU
    [Documentation]
    ...    Author: yuyan.xu@nokia-sbell.com
    ...    history change: <date>,<who>,<what and how>
    ...    25.03.2025, yuyan.xu@nokia-sbell.com

    Step 1: Create And Edit Plan SyVe For Different Modification Type
    Step 2: Provision The Plan SyVe On NetAct
    Step 3: Check Modified Parameters On NetAct
    Step 4: Provsion The Backup Plan On NetAct

Step ${index}: Create And Edit Plan SyVe For Different Modification Type
    Log To Console    Step ${index}: Create And Edit Plan SyVe For Different Modification Type
    ${year}    ${month}    ${day}    ${hour}    ${min}    Get Time    format=year,month,day,hour,min
    ${timestamp}    Set Variable    ${year}-${month}-${day}_${hour}-${min}
    Set Test Variable    ${plan_name}    MRBTS-${vDU_id}_${timestamp}
    ${mo_params}    Create Dictionary
    FOR    ${plan_info}    IN    @{plan_info_009_list}
        ${origin_value}    Get Parameter Value From vDU    ${plan_info['scf_distName']}    ${plan_info['parameter_name']}
        ${value_to_set}    Set Variable If    "${origin_value}"=="${plan_info['value2']}"
        ...    ${plan_info['value1']}    ${plan_info['value2']}
        Set To Dictionary    ${plan_info}    value=${value_to_set}
        ${params}    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['value']}
        Set To Dictionary    ${mo_params}    ${plan_info['scf_distName']}=${params}
    END
    ${plan_name}    Create Plan To Modify Mutiple Parameters On NetAct
    ...    ${TEST_LOG_DIRECTORY}/backup_scf/scf_backup.xml    ${plan_name}    Automation SyVe for MRBTS-${vDU_id}    &{mo_params}
    Set Test Variable    ${plan_name}
    Set Test Variable    ${backup_plan}    ${plan_name}_backup

Step ${index}: Provision The Plan SyVe On NetAct
    Log To Console    Step ${index}: Provision The Plan SyVe On NetAct
#    tafssh.Connect To    ${NETACT['was_host']}    ${NETACT['user']}    ${NETACT['password']}
#    Log To Console    Start Plan Provision
#    ${cmd1}    Set Variable    racclimx.sh -planName ${plan_name} -DN PLMN-PLMN/MRBTS-${vDU_id}
#    ${cmd2}    Set Variable    -createBackupPlan true -backupPlanName ${backup_plan} -v
#    ${cmd3}    Set Variable    -provisioningOperation activate -validateBeforePreactivationForLTE true -op Provision
#    tafssh.Send Command     ${cmd1} ${cmd2} ${cmd3}
#    ${result_Activate}    tafssh.Read Output
#    Should Contain    ${result_Activate}    5G/LTE/SRAN plan provision finished
    NetAct Provision Plan    plan_name=${plan_name}    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=${backup_plan}
    ...    create_backup_plan=True    provisioning_operation=activate
    Set Test Variable    ${RECOVERY_FLAG}    ${True}
    Wait Until Keyword Succeeds    20min    1min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    NetAct Export Plan    local_dir=${TEST_LOG_DIRECTORY}    file_name=${plan_name}_backup.csv
    ...    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    plan_name=${plan_name}_backup   operation_type=plan
    #[Teardown]    tafssh.disconnect
    Sleep    120s

Step ${index}: Check Modified Parameters On NetAct
    Log To Console    Step ${index}: Check Modified Parameters On NetAct
    FOR    ${plan_info}    IN    @{plan_info_009_list}
        ${params}    Create Dictionary    ${plan_info['parameter_name']}=${plan_info['value']}
        Wait Until Keyword Succeeds    5min    30s    NetAct Check Actual Configuration Parameters
    ...    ne=PLMN-PLMN/MRBTS-${vDU_id}   dist_name=PLMN-PLMN/${plan_info['scf_distName']}   &{params}
    END

Step ${index}: Provsion The Backup Plan On NetAct
    Log    Step ${index}: Provsion The Backup Plan On NetAct    console=True
    NetAct Provision Plan    plan_name=${plan_name}_backup    dist_names=PLMN-PLMN/MRBTS-${vDU_id}    backup_plan_name=None
    ...    create_backup_plan=False    provisioning_operation=activate
    Wait Until Keyword Succeeds    20min    1min    vDU Check All Cells Status Should Be Onair    vdu_index=0    gnb_index=0
    Set Test Variable    ${RECOVERY_FLAG}    ${False}


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