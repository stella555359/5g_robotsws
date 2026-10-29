*** Settings ***
Documentation       Test case for CB012611 case 5 ABIO reset when ABIO with one loki failed mode
...                 Author: YuaGao
...                 Contact: yuan.1.gao@nokia-sbell.com
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
@{BB_Types}    ABIO    #Will randomly select one BBMOD with this type.
&{BBMODs_Fixed_Dic}    BBMOD-2=2    #If want fix one BBMOD can set it BBMOD-X=Y X is id, Y is position, left and right rack both are 1, 2, 3
                                   # e.g.BBMOD-2=1. If ${BBMODs_Fixed_Dic} not defined, can random select one BB by ${BB_Types},
                                   #because now it cann't find the selected bbmod's position, so this case only support ${BBMODs_Fixed_Dic} defined.

*** Keywords ***
CM__CB012611_005_CM_ABIO_reset_for_impacted_ABIO_when_ABIO_with_one_Loki_failed_in_basic_conf
    [Documentation]
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...  For these two cases, only ABIO with one Loki failed at runtime in basic conf and IQF conf:
    ...  RAN_ST_CB012611_005_CM_ABIO reset for impacted ABIO when ABION with one  failed in basic conf
    ...  When ABIO Loki A or Loki B HW permanent failure occurred at run time with basic cells configured,
    ...  Perform Rest Operation on the impacted ABIO
    ...    Randomly Select One BBMOD
    ...    Failed One Selected Loki On Selected BBMOD
    ...    Perform Reset The Selected BBMOD
    ...    Perform Site Reset For Startup
    ...    Perform Reset The Selected BBMOD
    ...    Recovery One Failed Loki
    ...  Pass criteria: reset the impacted ABIO successful and cell status as expected.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.08.2024 - New Case

    Set Tags    AUTHOR-yuan.1.gao@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_4@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Randomly Select One BBMOD
    Step 2: Failed One Selected Loki On Selected BBMOD
    Step 3: Perform Reset The Selected BBMOD
    Step 4: Perform Site Reset For Startup
    Step 5: Perform Reset The Selected BBMOD
    [Teardown]    Recovery One Failed Loki

Step ${index}: Randomly Select One BBMOD
    [Documentation]    this keyword only suport ${BBMODs_Fixed_Dic} defined.
    Log To Console    Step ${index}: Randomly Select One BBMOD
    #Get All BTS IDs
    ${mrbts_id}    ${nrbts_id}    ${lnbts_id}    ${wnbts_id}    ${gnbts_id}    Fetch BTS IDs
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}
    Set Test Variable    ${lnbts_id}
    #Select BBMOD and related info
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${bbmod_list}     ${btsInfo['basebandModules']}
    log    ${bbmod_list}
    ${bbmod_selected}    Set Variable
    ${BBMODs_Fixed_key}    Get Dictionary Keys    ${BBMODs_Fixed_Dic}
    ${bbmod_fixed}    Evaluate    random.choice(${BBMODs_Fixed_key})    modules=random, sys
    FOR    ${bbmod}    IN    @{bbmod_list}
        Run Keyword If    "${bbmod['id']['configuration'].split("/")[-1]}"=="${bbmod_fixed}"    Run Keywords
        ...    Set Test Variable    ${bbmod_selected}    ${bbmod}    AND    Exit For Loop
    END
    Should Be True    "${bbmod_selected}"!="None" and "${bbmod_selected}"!=""   Can not find BBMOD match this case.
    ${bb_type_selected}    Set Variable    ${bbmod_selected["productName"].split(" ")[0]}
    ${loki_type_selected}    Set Variable    B
    ##${loki_type_selected}    Evaluate    random.choice(["A","B"])    modules=random, sys
    ${loki_type_selected}    Set Variable If    "${bb_type_selected}"=="ABIO"    A    ${loki_type_selected}
    ${powergroup_selected}    Set Variable    POWERGROUP_R-1
    ${powergroup_selected}    Set Variable If    "${loki_type_selected}"=="A"    POWERGROUP_R-1    POWERGROUP_R-2
    #Get related cells
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${cell_dic}    Get BBMOD Related Cells    ${bbmod_selected['id']['runtime']}/${powergroup_selected}    ${full_scf_xml}
    Set Test Variable    ${bbmod_fixed}
    Set Test Variable    ${Impacted_Cells}    ${cell_dic}
    Set Test Variable    ${bbmod_selected}
    Set Test Variable    ${bb_type_selected}
    Set Test Variable    ${loki_type_selected}
    Log To Console    ${bbmod_selected['id']['configuration']}
    Log To Console    ${Impacted_Cells}

Step ${index}: Failed One Selected Loki On Selected BBMOD
    Log To Console    Step ${index}: Failed One Selected Loki On Selected BBMOD
    ${smods_bbmods_mapping}    Get Relationship Between SMODs And BBMODs
    ${smods_role}    Get SMODs Role
    ${smods}    Get Dictionary Keys    ${smods_bbmods_mapping}
    ${active_role}    Set Variable    Primary
    FOR    ${sm}    IN    @{smods}
        ${in_smod}    Run Keyword And Return Status    List Should Contain Value
        ...    ${smods_bbmods_mapping["${sm}"]}    ${bbmod_selected['id']['configuration']}
        ${active_role}    Set Variable If    ${in_smod}    ${smods_role["${sm}"]}    ${active_role}
        Exit For Loop If    ${in_smod}
    END
    Log    ${active_role}
    Set Test Variable    ${active_role}
    Set Test Variable    ${position}    ${BBMODs_Fixed_Dic["${bbmod_selected['id']['configuration'].split("/")[-1]}"]}
    #${lokiType}    Set Variable    0
    ${lokiType}    Set Variable If    "${loki_type_selected}"=="A"    0    1
    ${failed_command}    Create List    bmutool -s ${position} -r 0x1${lokiType} 0xA0
    Sleep    2s
    Log To Console    ${failed_command}
    Operate BBMOD Loki By Command    ${active_role}    ${failed_command}
    #Check BBmod status:degrade
    Set Test Variable   ${BBMOD_degraded_state}    administrativeState=Unlocked, operationalState=enabled, availabilityStatus=degraded
    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120    connection=default
    #Check related cells status
    ${Impacted_Cells_Formatted}    Create Dictionary    NRCEL=${Impacted_Cells["5G"]}    LNCEL=${Impacted_Cells["LTE"]}
    ...    WNCEL=${Impacted_Cells["WCDMA"]}    GNCEL=${Impacted_Cells["GSM"]}
    Set Test Variable    ${Impacted_Cells_Formatted}
    ${Impacted_Cell_Status}    Create Dictionary
    ...    NRCEL=operationalState=disabled, availabilityStatus=failed, blockingState=Unblocked
    ...    LNCEL=operationalState=disabled, availabilityStatus=failed, blockingState=Unblocked
    ...    WNCEL=operationalState=disabled, availabilityStatus=failed, blockingState=Unblocked
    ...    GNCEL=operationalState=disabled, availabilityStatus=failed, blockingState=Unblocked
    Set Test Variable    ${Impacted_Cell_Status}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    #Fault252 check. impact cell on fault info need check?
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Critical    timeout=300s

Operate BBMOD Loki By Command
    [Arguments]     ${role}    ${commands_list}
    ${ssh_index}    Establish SSH to SBTS    192.168.255.129
    ${output}    Execute CMD Via SSH connection    pwd    >
    Sleep    2s
    ${prefix}    Should Match Regexp    ${output}      root@fct-\\da
    Log To Console    prefix:${prefix}
    ${loginSecdCmd}    Set Variable If    "${prefix}"=="root@fct-0a"    ssh toor4nsn@fct-4a    ssh toor4nsn@fct-0a
    ${output}    Run Keyword If    "${role}"=="Secondary"    Execute CMD Via SSH connection    ${loginSecdCmd}    Password:
    Sleep    2s
    ${output}    Run Keyword If    "${role}"=="Secondary"    Execute CMD Via SSH connection    oZPS0POrRieRtu    >
    Sleep    2s
    FOR    ${command}    IN    @{commands_list}
        Log To Console    execute command:${command}
        ${output}    Execute CMD Via SSH connection    ${command}    >
        Sleep    10s
    END
    [Teardown]    SSHLibrary.Close All Connections

Recovery One Failed Loki
    Log To Console    Teardown: Recovery One Failed Loki
    Log To Console    ${active_role}
    ${recovery_command}    Create List    bmutool -s ${position} -r 0x1F 1
    Log To Console    ${recovery_command}
    Operate BBMOD Loki By Command    ${active_role}    ${recovery_command}
    coam.reset_site
    Wait Until Keyword Succeeds    25min    30s    Check SBTS SMOD RMOD Cells Alarms
    #Fault252 check.
    ${alarms_list}    coam.assert_alarm_inactive    faultId=252    timeout=300s

Step ${index}: Perform Reset The Selected BBMOD
    Log To Console    Step ${index}: Perform Reset The Selected BBMOD
    ${parameter_list}=    Create List
    Run Keyword AND Ignore Error    coam.perform_object_recommissioning
    ...    dist_name=MRBTS-${mrbts_id}/MNL-1/CMD-1    parameter=${parameter_list}    operation=delete    skip_parameter_relation_errors=True
    ${time}    Get Time    epoch
    coam.create_delta    delta_id=${mrbts_id}_${time}
    coam.append_managed_object_to_delta
    ...    MRBTS-${mrbts_id}/MNL-1/CMD-1    create    ${mrbts_id}_${time}
    coam.append_managed_object_to_delta
    ...    MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1    create    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1
    ...    hwResetReqId    1    ${mrbts_id}_${time}
    coam.append_parameter_update_to_delta    MRBTS-${mrbts_id}/MNL-1/CMD-1/HWRESETREQ-1
    ...    targetHwResetUDN    ${bbmod_selected['id']['configuration']}    ${mrbts_id}_${time}
    ${delta_json}    coam.get_delta    delta_id=${mrbts_id}_${time}
    ${result}    coam.perform_delta_recommissioning    ${delta_json}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    ${severity}    Set Variable If    "${index}"=="3"   Critical    Minor
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=${severity}    timeout=300s

Step ${index}: Perform Site Reset For Startup
    Log To Console    Step ${index}: Perform Site Reset For Startup
    Log To Console    Start To Site Reset
    coam.reset site
    Sleep    300s
    ${Current_BBMOD_Infor}    Fetch ID Mapping From Admin For Module
    ...    identifier=${bbmod_selected['id']['configuration']}    identifier_type=configuration    mod_type=BBMOD
    coam.assert    BBMOD    ${Current_BBMOD_Infor['internal']}    ${BBMOD_degraded_state}    timeout=120
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    ${alarms_list}    coam.assert_alarm_active    faultId=1868    timeout=300s
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Minor    timeout=300s