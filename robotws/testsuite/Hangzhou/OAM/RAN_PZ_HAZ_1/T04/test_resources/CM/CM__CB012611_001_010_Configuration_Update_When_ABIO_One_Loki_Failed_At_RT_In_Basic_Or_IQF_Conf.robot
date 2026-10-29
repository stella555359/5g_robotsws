*** Settings ***
Documentation       Test case for
...                 Author: Xu Yuyan
...                 Contact: yuyan.xu@nokia-sbell.com
# Test Timeout    3h
Resource          ../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_cm_resources/hran_frame_taf_oam.robot

*** Variables ***
@{BB_Types}    ABIO    #Will randomly select one BBMOD with this type.
&{BBMODs_Fixed_Dic}    BBMOD-6=3    #If want fix one BBMOD can set it BBMOD-X:Y X is id, Y is position, left and right rack both are 1, 2, 3
                                   # e.g.BBMOD-2=1. If ${BBMODs_Fixed_Dic} not defined, can random select one BB by ${BB_Types},
                                   #because now it cann't find the selected bbmod's position, so this case only support ${BBMODs_Fixed_Dic} defined.

*** Keywords ***
CM__CB012611_001_010_Configuration_Update_When_ABIO_One_Loki_Failed_At_RT_In_Basic_Or_IQF_Conf
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The main steps performed for the test are:
    ...  For these two cases, only ABIO with one Loki failed at runtime in basic conf and IQF conf:
    ...  RAN_ST_CB012611_001_CM_Configuration update for impacted ABIO and cells when ABIO with one Loki failed at runtime in basic conf
    ...  RAN_ST_CB012611_010_CM_Configuration update for impacted ABIO and cells when ABIO with one Loki failed at runtime in IQF conf
    ...  When ABIO Loki A or Loki B HW permanent failure occurred at run time with basic cells configured,
    ...  check CM operations like configuration update (online, RAT reset, cell locking, site reset, cell block, etc.)
    ...  for impacted ABIO and cells.
    ...    Randomly Select One BBMOD
    ...    Failed One Selected Loki On Selected BBMOD
    ...    Delte Plan With Online Parameter And No Redeployment
    ...    Delte Plan With RatReset Parameter And No Redeployment
    ...    Delte Plan With ObjLock Parameter And No Redeployment
    ...    Block Unblock Cell And No Redeployment
    ...    Delte Plan With SiteReset Parameter And Redeployment
    ...    Delte Plan With Multiple Type Parameters And Redeployment
    ...    Recovery failed Loki
    ...  Pass criteria: configuration update for impacted ABIO and cells is successful.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 19.08.2024 - New Case
    Set Tags    CA-CM    AUTHOR-yuyan.xu@nokia-sbell.com    OWNER-I_NSB_MN_RAN_RD_VRF_HAZ1_8_GMS@internal.nsn.com
    Log To Console    ${TEST_NAME} start.
    Step 1: Randomly Select One BBMOD
    Step 2: Failed One Selected Loki On Selected BBMOD
    Step 3: Delte Plan With Online Parameter And Check No Redeployment
    Step 4: Delte Plan With RatReset Parameter And Check No Redeployment
    Step 4: Delte Plan With ObjLock Parameter And Check No Redeployment
    Step 5: Block Unblock Cell And Check No Redeployment
    Step 6: Delte Plan With SiteReset Parameter And Check Redeployment
    Step 7: Recovery One Failed Loki
    Step 8: Failed One Selected Loki On Selected BBMOD
    Step 9: Delte Plan With Multiple Type Parameters And Check Redeployment
    [teardown]    Recovery One Failed Loki

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
    ${loki_type_selected}    Set Variable    A
    ##${loki_type_selected}    Evaluate    random.choice(["A","B"])    modules=random, sys
    ${loki_type_selected}    Set Variable If    "${bb_type_selected}"=="ABIN"    A    ${loki_type_selected}
    ${powergroup_selected}    Set Variable    POWERGROUP_R-1
    ${powergroup_selected}    Set Variable If    "${loki_type_selected}"=="A"    POWERGROUP_R-1    POWERGROUP_R-2
    #Get related cells
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${cell_dic}    Get BBMOD Related Cells    ${bbmod_selected['id']['runtime']}/${powergroup_selected}    ${full_scf_xml}
    ${nrcell_selected}    Evaluate    random.choice(${cell_dic["5G"]})    modules=random, sys
    ##maybe not have 5G, need check 4G or 5G
    Set Test Variable    ${bbmod_fixed}
    Set Test Variable    ${Impacted_Cells}    ${cell_dic}
    Set Test Variable    ${bbmod_selected}
    Set Test Variable    ${bb_type_selected}
    Set Test Variable    ${loki_type_selected}
    Set Test Variable    ${nrcell_selected}
    Set Test Data
    Log To Console    ${bbmod_selected['id']['configuration']}
    Log To Console    ${Impacted_Cells}
    Log To Console    ${nrcell_selected}

Set Test Data
    ${paramName_Online}    Set Variable    actARPBasedAC
    @{paramValuesPool_Online}    Create List    on    off
    ${paramScfDN_Online}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_selected.split("-")[-1]}
    ${paramName_SiteReset}    Set Variable    actMplaneFronthaulFirewall
    @{paramValuesPool_SiteReset}     Create List    true    false
    ${paramScfDN_SiteReset}    Set Variable    MRBTS-${mrbts_id}/MNL-1/MNLENT-1/FEATCADM-1
    ${paramName_RatReset}    Set Variable    actFdmUeSkippingOlc
    @{paramValuesPool_RatReset}    Create List    true    false
    ${paramScfDN_RatReset}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}
    ${paramName_ObjLock}    Set Variable    actCceSplit
    @{paramValuesPool_ObjLock}    Create List    true    false
    ${paramScfDN_ObjLock}    Set Variable    MRBTS-${mrbts_id}/NRBTS-${nrbts_id}/NRCELL-${nrcell_selected.split("-")[-1]}
    Set Test Variable    ${paramName_Online}
    Set Test Variable    ${paramValuesPool_Online}
    Set Test Variable    ${paramScfDN_Online}
    Set Test Variable    ${paramName_SiteReset}
    Set Test Variable    ${paramValuesPool_SiteReset}
    Set Test Variable    ${paramScfDN_SiteReset}
    Set Test Variable    ${paramName_RatReset}
    Set Test Variable    ${paramValuesPool_RatReset}
    Set Test Variable    ${paramScfDN_RatReset}
    Set Test Variable    ${paramName_ObjLock}
    Set Test Variable    ${paramValuesPool_ObjLock}
    Set Test Variable    ${paramScfDN_ObjLock}

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
    ${lokiType}    Set Variable    0
    #${lokiType}    Set Variable If    "${loki_type_selected}"=="A"    0    1
    ${failed_command}    Create List    bmutool -s ${position} -r 0x1${lokiType} 0xA0
    Sleep    2s
    Log To Console    ${failed_command}
    Operate BBMOD Loki By Command    ${active_role}    ${failed_command}
    #Check BBmod status:degrade
    Set Test Variable   ${BBMOD_degraded_state}    administrativeState=Unlocked, operationalState=enabled, availabilityStatus=degraded
    #Set Test Variable   ${BBMOD_degraded_state}    administrativeState=Unlocked, operationalState=disabled, availabilityStatus=failed
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

Step ${index}: Delte Plan With ${Type} Parameter And Check No Redeployment
    Log To Console    Step ${index}: Delte Plan With ${Type} Parameter And Check No Redeployment
    ${current_value}    Get Parameter Value From WebEM    ${paramScfDN_${Type}}    ${paramName_${Type}}
    Remove Values From List    ${paramValuesPool_${Type}}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_${Type}})    modules=random, sys
    Run Keyword If    "${Type}"=="Online"    Set Test Variable    ${current_value_Online}    ${current_value}
    Run Keyword If    "${Type}"=="RatReset"    Set Test Variable    ${current_value_RatReset}     ${current_value}
    Run Keyword If    "${Type}"=="ObjLock"    Set Test Variable    ${current_value_ObjLock}     ${current_value}
    coam.perform_parameter_recommissioning    ${paramScfDN_${Type}}    ${paramName_${Type}}    update    ${valueToSet}
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120    connection=default
    #Fault252 check. impact cell on fault info need check?
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Critical    timeout=300s
    Check WebEM After Modify Parameters    ${paramScfDN_${Type}}    ${paramName_${Type}}=${valueToSet}


Step ${index}: Block Unblock Cell And Check No Redeployment
    Log To Console    Step ${index}: Block Unblock Cell And Check No Redeployment
    Log To Console    Block Cell:${nrcell_selected}
    coam.block_cell    ${nrcell_selected}
    ${cell_state_blocked}    Set Variable   administrativeState=Unlocked, operationalState=disabled, availabilityStatus=failed, blockingState=Blocked
    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120    connection=default
    coam.assert    NRCEL    ${nrcell_selected}    ${cell_state_blocked}    timeout=120
    ${Impacted_Cell_Status_blocked}    Create Dictionary
    ...    NRCEL=operationalState=disabled, availabilityStatus=failed
    ...    LNCEL=operationalState=disabled, availabilityStatus=failed
    ...    WNCEL=operationalState=disabled, availabilityStatus=failed
    ...    GNCEL=operationalState=disabled, availabilityStatus=failed
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status_blocked}
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Critical    timeout=300s
    sleep    30s
    Log To Console    Unblock Cell:${nrcell_selected}
    coam.unblock_cell    ${nrcell_selected}
    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120
    ${cell_state_unblocked}    Set Variable
    ...    administrativeState=Unlocked, operationalState=disabled, availabilityStatus=failed, blockingState=Unblocked
    coam.assert    NRCEL    ${nrcell_selected}    ${cell_state_unblocked}    timeout=120
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Critical    timeout=300s
    [Teardown]    Run Keyword And Ignore Error    coam.unblock_cell    ${nrcell_selected}

Step ${index}: Delte Plan With SiteReset Parameter And Check Redeployment
    Log To Console    Step ${index}: Delte Plan With SiteReset Parameter And Check Redeployment
    ${current_value}    Get Parameter Value From WebEM    ${paramScfDN_SiteReset}    ${paramName_SiteReset}
    Remove Values From List    ${paramValuesPool_SiteReset}    ${current_value}
    ${valueToSet}    Evaluate    random.choice(${paramValuesPool_SiteReset})    modules=random, sys
    Set Test Variable    ${current_value_SiteReset}     ${current_value}
    coam.perform_parameter_recommissioning    ${paramScfDN_SiteReset}    ${paramName_SiteReset}    update    ${valueToSet}
    Sleep    300s
    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120
    #${empty_list}    Create List
    #${impacted_cells_empty}    Create Dictionary    5G=${empty_list}    LTE=${empty_list}    WCDMA=${empty_list}    GSM=${empty_list}
    #Wait Until Keyword Succeeds    10x    60 sec    Check All Cells Status As Expected Status    ${impacted_cells_empty}    ${Impacted_Cell_Status}
    #For SBTS1910 BBMOD-6:
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    ${alarms_list}    coam.assert_alarm_active    faultId=1868    timeout=300s
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Minor    timeout=300s
    Check WebEM After Modify Parameters    ${paramScfDN_SiteReset}    ${paramName_SiteReset}=${valueToSet}

Step ${index}: Recovery One Failed Loki
    Log To Console    Step ${index}: Recovery One Failed Loki
    Recovery One Failed Loki

Step ${index}: Delte Plan With Multiple Type Parameters And Check Redeployment
    Log To Console    Step ${index}: Delte Plan With Multiple Type Parameters And Check Redeployment
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_Online}    parameter=${paramName_Online}    value=${current_value_Online}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_RatReset}    parameter=${paramName_RatReset}    value=${current_value_RatReset}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_ObjLock}    parameter=${paramName_ObjLock}    value=${current_value_ObjLock}
    coam.Append Parameter Update To Delta   dist_name=${paramScfDN_SiteReset}    parameter=${paramName_SiteReset}    value=${current_value_SiteReset}
    #coam.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/MNL-1   parameter=validatePlanAgainstDetectedHW   value=${validateHW_curValue}
    ${json}    coam.Get Delta
    Wait Until Keyword Succeeds    10x    60 sec    coam.Perform Delta Recommissioning    ${json}
    Sleep    300s
    coam.assert    BBMOD    ${bbmod_selected['id']['internal']}    ${BBMOD_degraded_state}    timeout=120
    #${empty_list}    Create List
    #${impacted_cells_empty}    Create Dictionary    5G=${empty_list}    LTE=${empty_list}    WCDMA=${empty_list}    GSM=${empty_list}
    #Wait Until Keyword Succeeds    20x    60 sec    Check All Cells Status As Expected Status    ${impacted_cells_empty}    ${Impacted_Cell_Status}
    #For SBTS1910 BBMOD-6:
    Wait Until Keyword Succeeds    10x    30 sec
    ...    Check All Cells Status As Expected Status    ${Impacted_Cells_Formatted}    ${Impacted_Cell_Status}
    ${alarms_list}    coam.assert_alarm_active    faultId=1868    timeout=300s
    ${alarms_list}    coam.assert_alarm_active    faultId=252, severity=Minor    timeout=300s
    Check WebEM After Modify Parameters    ${paramScfDN_Online}    ${paramName_Online}=${current_value_Online}
    Check WebEM After Modify Parameters    ${paramScfDN_RatReset}    ${paramName_RatReset}=${current_value_RatReset}
    Check WebEM After Modify Parameters    ${paramScfDN_ObjLock}    ${paramName_ObjLock}=${current_value_ObjLock}
    Check WebEM After Modify Parameters    ${paramScfDN_SiteReset}    ${paramName_SiteReset}=${current_value_SiteReset}

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

Recovery SBTS
    coam.Create Delta
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_Online}    parameter=${paramName_Online}    value=${current_value_Online}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_RatReset}    parameter=${paramName_RatReset}    value=${current_value_RatReset}
    coam.Append Parameter Update To Delta    dist_name=${paramScfDN_ObjLock}    parameter=${paramName_ObjLock}    value=${current_value_ObjLock}
    coam.Append Parameter Update To Delta   dist_name=${paramScfDN_SiteReset}    parameter=${paramName_SiteReset}    value=${current_value_SiteReset}
#    coam.Append Parameter Update To Delta   dist_name=MRBTS-${BTS_ID}/MNL-1   parameter=validatePlanAgainstDetectedHW   value=${validateHW_curValue}
    ${json}    coam.Get Delta
    coam.Perform Delta Recommissioning    ${json}
    Wait Until Keyword Succeeds    20min    60s    Check SBTS SMOD RMOD Cells Alarms



Step ${index}: Randomly Select One BBMOD-bk
    [Documentation]    this keyword can suport ${BB_Types} or ${BBMODs_Fixed_Dic} defined. If ${BBMODs_Fixed_Dic} not defined,can random select one
    ...    BB by ${BB_Types}, because now it cann't find the selected bbmod's position, so this case only support ${BBMODs_Fixed_Dic} defined.
    Log To Console    Step ${index}: Randomly Select One BBMOD
    #Get All BTS IDs
    ${mrbts_id}    ${nrbts_id}    ${lnbts_id}    ${wnbts_id}    ${gnbts_id}    Fetch BTS IDs
    Set Test Variable    ${mrbts_id}
    Set Test Variable    ${nrbts_id}
    Set Test Variable    ${lnbts_id}
    #Select BBMOD and other info
    ${btsInfo}    coam.Get Bts Info
    Set Test Variable    ${bbmod_list}     ${btsInfo['basebandModules']}
    log    ${bbmod_list}
    ${bbmod_selected}    Set Variable
    ${BBMODs_Fixed_key}    Get Dictionary Keys    ${BBMODs_Fixed_Dic}
    ${bbmod_fixed}    Evaluate    random.choice(${BBMODs_Fixed_key})    modules=random, sys
    FOR    ${bbmod}    IN    @{bbmod_list}
        Run Keyword If    "${bbmod['id']['configuration'].split("/")[-1]}"=="${bbmod_fixed}"    Run Keywords
        ...    Set Test Variable    ${bbmod_selected}    ${bbmod}    AND    Exit For Loop
        Continue For Loop If    "${bbmod_fixed.__len__()}">"${0}"
        ${is_case_type}    Run Keyword And Return Status    List Should Contain Value    ${BB_Types}    ${bbmod["productName"].split(" ")[0]}
        Continue For Loop If    ${is_case_type}
        Remove Values From List    ${bbmod_list}    ${bbmod}
    END
    log    ${bbmod_list}
    ${bbmod_selected_tmp}    Run Keyword If    "${bbmod_list.__len__()}"!="0"    Evaluate    random.choice(${bbmod_list})    modules=random, sys
    ${bbmod_selected}    Set Variable If   "${bbmod_fixed}"==""    ${bbmod_selected_tmp}    ${bbmod_selected}
    Should Be True    "${bbmod_selected}"!="None" and "${bbmod_selected}"!=""   Can not find BBMOD match this case.
    Set Test Variable    ${bb_type_selected}    ${bbmod_selected["productName"].split(" ")[0]}
    ${loki_type_selected}    Evaluate    random.choice(["A","B"])    modules=random, sys
    ${loki_type_selected}    Set Variable If    "${bb_type_selected}"=="ABIN"    A    ${loki_type_selected}
    ${powergroup_selected}    Set Variable If    "${loki_type_selected}"=="A"    POWERGROUP_R-1    POWERGROUP_R-2
    #Get related cells
    ${full_scf}    coam.Get Scf    configurationAndRuntimeObjects
    Import Library    XML    use_lxml=True    WITH NAME    L_XML
    ${full_scf_xml}    L_XML.Parse Xml    ${full_scf}
    ${cell_dic}    Get BBMOD Related Cells    ${bbmod_selected['id']['runtime']}/${powergroup_selected}    ${full_scf_xml}
    ##${nrcell_selected}    Evaluate    random.choice(${cell_dic["5G"]})    modules=random, sys
    ##maybe not have 5G, need check 4G or 5G
    Set Test Variable    ${bbmod_fixed}
    Set Test Variable    ${Impacted_Cells}    ${cell_dic}
    Set Test Variable    ${bbmod_selected}
    Set Test Variable    ${loki_type_selected}
    ##Set Test Variable    ${nrcell_selected}
    ##Set Test Data
    Log To Console    ${bbmod_selected['id']['configuration']}
    Log To Console    ${Impacted_Cells}

