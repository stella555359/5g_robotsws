*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
&{Sync_to_FHS}    platLoginBannerText=hello, this is SBTS SSH notice
...    sshClientAliveTimer=1
...    sshSessionLoginDelayTimer=5
...    sshSessionIdleTimer=15
&{Not_Sync_to_FHS}    platLoginBannerText=hello, this message should be seen via ssh connection.
...    sshClientAliveTimer=5
...    sshSessionLoginDelayTimer=7
...    sshSessionIdleTimer=25
@{value_list}   2    100    5
&{SPECIAL_PARAM}    sshMaxAuthAttempts=@{value_list}
&{PARAMS_BACKUP_DiC}

*** Keywords ***
CM__CB005868_RP002695_SSH_Configuration_Update_via_WebEM
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   - Source case:Automated__CM__SSH_configuration_update_via_WebEM_CB005868_RP002695.robot
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.07.2023 - Commit to robotws
    ...  - 20.09.2024 - Change from WEBUI case to API case due to CB012236 Nokia rebranding in WebEM and CuDo
    Set Tags    CM    UI    OWNER-II_NSB_MN_RAN_PZ_1_HAZ_11@internal.nsn.com
    LOG    ${TEST_NAME} start.    console=${True}
    Step 1: Check Current FHS Parameters
    Step 2: Update Sync FHS Param Via WebEM And Check By SSH
    Step 3: Update Not Sync FHS Param Via WebEM And Check By SSH
    Step 4: Recover Parameters

CaseSetUp
    Common Test Setup SBTS   scf_check=${FALSE}
    Set Test Variable    ${NEED_RECOVER}    ${False}
    ${mrbts_id}    Should Match Regexp    ${MRBTS_DN}    \\d+
    Set Test Variable    ${mrbts_id}
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actSyncToFronthaul    operation=update    value=true

CaseTearDown
    Log    Case Special Teardown    console=${True}
    Run Keyword If    ${NEED_RECOVER}    Admin Get bts_id and perform commissioning    ${COMMISSIONING_PATH}
    Wait Until Keyword Succeeds    20 min    10 sec    Check_SBTS_SMOD_RMOD_Cells_Alarms
    Common Test Teardown SBTS

Step ${index}: Check Current FHS Parameters
    Log    Step ${index}: Check Current FHS Parameters    console=${True}
    ${PARAM_IN_FHS_BEFORE}    Get Parameters From FHS Via SSH
    Set Test Variable    ${PARAM_IN_FHS_BEFORE}
    LOG    ${PARAM_IN_FHS_BEFORE}    console=${True}
    ${param_list}    Get Dictionary Keys    ${Sync_to_FHS}
    FOR    ${param}    IN     @{param_list}
        Should Not Be Equal As Strings    ${Sync_to_FHS["${param}"]}    ${PARAM_IN_FHS_BEFORE["${param}"]}
    END

Step ${index}: Update Sync FHS Param Via WebEM And Check By SSH
    Log    Step ${index}: Update Sync FHS Param Via WebEM And Check By SSH    console=${True}
    ${special_param_list}    Get Dictionary Keys    ${SPECIAL_PARAM}
    ${param_to_modify_dic}    Copy Dictionary    ${Sync_to_FHS}
    FOR     ${key}    IN    @{special_param_list}
         ${special_value_list}    Get From Dictionary    ${SPECIAL_PARAM}    ${key}
         ${value}    Get Parameter Value From WebEM    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1    ${key}
         Remove Values From List     ${special_value_list}    ${value}
         ${special_value_select}    Evaluate    random.choice(${special_value_list})    modules=random, sys
         Set To Dictionary    ${param_to_modify_dic}    ${key}    ${special_value_select}
    END
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Modify Parameters By Delta Recommision    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1    ${param_to_modify_dic}
    ${PARAM_IN_FHS}    Get Parameters From FHS Via SSH
    Set Test Variable    ${PARAM_IN_FHS}
    ${param_list}    Get Dictionary Keys    ${Sync_to_FHS}
    FOR    ${param}    IN     @{param_list}
        Should Be Equal As Strings    ${Sync_to_FHS["${param}"]}    ${PARAM_IN_FHS["${param}"]}
    END

Step ${index}: Update Not Sync FHS Param Via WebEM And Check By SSH
    Log    Step ${index}: Update Not Sync FHS Param Via WebEM And Check By SSH    console=${True}
    coam.Perform Parameter Recommissioning    dist_name=MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1
    ...    parameter=actSyncToFronthaul    operation=update    value=false
    Set Test Variable    ${NEED_RECOVER}    ${True}
    Modify Parameters By Delta Recommision    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1    ${Not_Sync_to_FHS}    ${False}
    ${param_not_sync}    Get Parameters From FHS Via SSH
    Dictionaries Should Be Equal    ${param_not_sync}    ${PARAM_IN_FHS}

Step ${index}: Recover Parameters
    Log    Step ${index}: Recover Parameters    console=${True}
    Set To Dictionary   ${PARAMS_BACKUP_DiC}    actSyncToFronthaul    true
    Modify Parameters By Delta Recommision    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/SECADM-1    ${PARAMS_BACKUP_DiC}    ${False}
    ${PARAM_IN_FHS}    Get Parameters From FHS Via SSH
    Dictionaries Should Be Equal    ${PARAM_IN_FHS_BEFORE}    ${PARAM_IN_FHS}
    Set Test Variable    ${NEED_RECOVER}    ${False}

Modify Parameters By Delta Recommision
    [Arguments]     ${mo}    ${param_dic}    ${need_backup}=${True}
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    ${keys}    Get Dictionary Keys    ${param_dic}
    FOR    ${param}    IN    @{keys}
        coam.append_parameter_update_to_delta    ${mo}   ${param}    ${param_dic["${param}"]}    ${mrbts_id}_${time}
        ${back_value}    Get Parameter Value From WebEM    ${mo}    ${param}
        Run Keyword If    ${need_backup}    Set To Dictionary    ${PARAMS_BACKUP_DiC}    ${param}    ${back_value}
    END
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}

Get Parameters From FHS Via SSH
    ${param_dic}    Create Dictionary
    ${FHS_params}    coam.get_managed_objects    FHS_L
    ${ip}    Set Variable    ${FHS_params[0]["parameters"]["ipAddress"]}
    ${index}    Establish SSH to SBTS    host_ip=${MPLANE_IP}    alias=monkey
    #if FHS connect to master, no need connect to fct-4a
    ${output}    Execute CMD Via SSH connection    ssh toor4nsn@fct-4a    assword\|yes/no
    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    assword
    ${output}    Execute CMD Via SSH connection    oZPS0POrRieRtu    root\@fct-4a
    #${is_pass}    ${output}    Run Keyword And Ignore Error    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt | grep "MDCD\\|MDEA"    MD
    #${output}    Run Keyword If    '${is_pass}'=='FAIL'    Change To Right CABINET
    #...    ELSE    Set Variable    ${output}
    #${ip}    Should Match Regexp    ${output}    \\d+\\.\\d+\\.\\d+\\.\\d+
    ${output}    Execute CMD Via SSH connection    lxc-ls --active    0x\\d018
    ${id_FHNET}    Should Match Regexp    ${output}    0x\\d018
    ${cmd_to_FHNET}    Set Variable    lxc-attach -n ${id_FHNET}
    Execute CMD Via SSH connection    ${cmd_to_FHNET}    root\@FHNET
    ${output}    Execute CMD Via SSH connection    rm /user/toor4nsn/.ssh/known_hosts    root\@FHNET
    ${output}    Execute CMD Via SSH connection    ssh serviceuser@${ip}    password\|yes/no    console_delay=1s
    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    password
    ${output}    Execute CMD Via SSH connection    Pl(FzaYj5~c5;q    serviceuser\@fhs
    ${output}    Execute CMD Via SSH connection    su toor4nsn    Password
    ${output}    Execute CMD Via SSH connection    oZPS0POrRieRtu    \#
    ${output}    Execute CMD Via SSH connection    echo ===;cat /ffs/run/etc/ssh/banner;echo ===    \#
    ${output}    Set Variable    ${output.split('===')[1].strip()}
    Set To Dictionary    ${param_dic}    platLoginBannerText    ${output}
    ${output}    Execute CMD Via SSH connection    cat /ffs/run/etc/ssh/sshd_config | grep ClientAliveInterval    \#
    ${ClientAliveInterva}    Should Match Regexp    ${output}    \\s+\\d+\\s+
    ${ClientAliveInterva}    Evaluate    ${ClientAliveInterva.strip()}/20
    ${ClientAliveInterva}    Convert To Integer    ${ClientAliveInterva}
    Set To Dictionary    ${param_dic}    sshClientAliveTimer    ${ClientAliveInterva}
    ${output}    Execute CMD Via SSH connection    cat /ffs/run/etc/pam.d/sshd | grep delay    \#
    ${delay}    Should Match Regexp    ${output}    delay=\\d+\\s+
    ${delay}    Fetch From Right    ${delay}    =
    ${delay}    Evaluate    ${delay.strip()}/1000000
    ${delay}    Convert To Integer    ${delay}
    Set To Dictionary    ${param_dic}    sshSessionLoginDelayTimer    ${delay}
    ${output}    Execute CMD Via SSH connection    cat /ffs/run/etc/profile | grep TMOUT    \#
    ${time_out}    Should Match Regexp    ${output}    TMOUT=\\d+\\s+
    ${time_out}    Fetch From Right    ${time_out}    =
    Set To Dictionary    ${param_dic}    sshSessionIdleTimer   ${time_out.strip()}
    [Teardown]    SSHLibrary.Close Connection
    [Return]    ${param_dic}

Change To Right CABINET
    ${output}    Execute CMD Via SSH connection    ssh toor4nsn@fct-4a    assword\|yes/no
    Run Keyword If    "yes/no" in """${output}"""    Execute CMD Via SSH connection    yes    assword
    ${output}    Execute CMD Via SSH connection    oZPS0POrRieRtu    root\@fct-4a
    ${output}    Execute CMD Via SSH connection    cat /rom/config/FRIps.txt | grep "MDCD\\|MDEA"    MD
    [Return]    ${output}
