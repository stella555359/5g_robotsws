*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_compa.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_admin.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_common.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/Mrat_resource_new.robot
Library    taf.sbts.oam.coam.admin
Library    String
Library     ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/SSHExecutor.py
Library     ../../../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/lib/file_operation.py
Library    DateTime
Library    OperatingSystem
Library    ute_async


*** Variables ***
@{BTS_BLOCKED_Alarm_info}    Critical    BTS blocked    50    7102    BASE STATION RESOURCE BLOCKED BY USER
...  7102 BASE STATION RESOURCE BLOCKED BY USER
@{FTM_RESET_Alarm_info}    Minor    The BTS booted at    61006    7665    BASE STATION TRANSMISSION ALARM    7665 BASE STATION TRANSMISSION ALARM
${Command_Trigger}    iptables -I INPUT -s 10.41.0.0/16 -j DROP
@{fault_9255}     Minor    9255    9255    9255    Alarm Database upload Failure    9255 Alarm Database upload Failure
${Command_Recovery}    iptables -D INPUT -s 10.41.0.0/16 -j DROP    # iptables -D INPUT -s 10.41.0.0/16 -j DROP
@{fault 6203}     Major    Transport layer connection failure in X2 interface    6203    7107    BASE STATION CONNECTIVITY PROBLEM
...  7107 BASE STATION CONNECTIVITY PROBLEM    6203
@{fault 0049}     Critical    Cell blocked    49    7102    BASE STATION RESOURCE BLOCKED BY USER    7102 BASE STATION RESOURCE BLOCKED BY USER    49
@{fault 0050}     Critical    BTS blocked    50    7102    BASE STATION RESOURCE BLOCKED BY USER    7102 BASE STATION RESOURCE BLOCKED BY USER    50
@{fault 0010}     Critical    No connection to unit    10    7116    BASE STATION SERVICE PROBLEM    7116 BASE STATION SERVICE PROBLEM    10
@{LOS_ON_SMOD_Alarm_info}    Critical    Missing or non-compliant SFP module on SMOD-1, EIF2    61050    7100    BASE STATION HARDWARE PROBLEM
...  7100 BASE STATION HARDWARE PROBLEM


*** Keywords ***
TC_CB006147_05_01_Lock_Unlock_of_SFP
    [Documentation]    Short description.
    CB006147_05_01 Test Setup
    LOCK_SFP
    Check SFP status
    UNLOCK_SFP
    Verify BTS states

CB006147_05_01 Test Setup
    [Documentation]    Short description.
    Run Keyword And Ignore Error    Delete SFP object

LOCK_SFP
    [Documentation]    Short description.
    Log Step Header    LOCK_SFP
    ${v1}    set variable    RF1
    ${v2}    set variable    Locked
    create file    ${Test Results Dir}${/}plan${/}6147_05_01_P01.json
    file_operation.Update Json File    target_json_file=${Test Results Dir}${/}plan${/}6147_05_01_P01.json    dist_operation=create
    ...  dist_name=MRBTS-${BTS_INFO.ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1    parameter_operation=update    hwPortId=${v1}
    Run keyword and ignore error    _Perform Delta Commission By Admin    ${Test Results Dir}${/}plan${/}6147_05_01_P01.json
    create file    ${Test Results Dir}${/}plan${/}6147_05_01_P01.json
    file_operation.Update Json File    target_json_file=${Test Results Dir}${/}plan${/}6147_05_01_P01.json    dist_operation=create
    ...  dist_name=MRBTS-${BTS_INFO.ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1    parameter_operation=update    administrativeState=${v2}
    Run keyword and ignore error    _Perform Delta Commission By Admin    ${Test Results Dir}${/}plan${/}6147_05_01_P01.json

UNLOCK_SFP
    [Documentation]    Short description.
    Log Step Header    UNLOCK_SFP

    create file    ${Test Results Dir}${/}plan${/}6147_05_01_P03.json
    file_operation.Update Json File    target_json_file=${Test Results Dir}${/}plan${/}6147_05_01_P03.json    dist_operation=update
    ...  dist_name=${BTS_INFO.MRBTS}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1    parameter_operation=update    administrativeState=Unlocked
    _Perform Delta Commission By Admin    ${Test Results Dir}${/}plan${/}6147_05_01_P03.json

Delete SFP object
    [Documentation]    Short description.
    Log Step Header     Delete SFP object

    create file    ${Test Results Dir}${/}plan${/}6147_05_01_P04.json
    file_operation.Update Json File    target_json_file=${Test Results Dir}${/}plan${/}6147_05_01_P04.json    dist_operation=delete
    ...  dist_name=${BTS_INFO.MRBTS}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1
    _Perform Delta Commission By Admin    ${Test Results Dir}${/}plan${/}6147_05_01_P04.json

Check SFP status
    [Documentation]    Short description.
    Log Step Header      Check SFP status
    ${name}    set variable  6147_scf.xml

    ${scf_result}=    taf.sbts.oam.coam.admin.collect_scf    ${Test Results Dir}${/}${name}    export_type=runtimeObjects     timeout=120
    ${root} =	Parse XML	${Test Results Dir}${/}${name}
    ${eles}=    Get Elements    	${root}     cmData/managedObject/p[@name="configDN"]/..

    FOR     ${ele}  IN  @{eles}
       Log      ${ele.text}
     #\  ${ATT}=     XML.Get Element Attribute   ${ele}  distNametached merge request pip
     #\  Log      ${ATT}
     #\  ${STATUS}=     RUN KEYWORD AND RETURN STATUS      SHOULD CONTAIN      ${ATT}  LANEBTS_PC_CONNECTION
     #\  continue for loop if  ${STATUS}==${FALSE}
       ${MO}    Get Element    ${ele}    *[@name="configDN"]
       Log      ${MO}
       ${STATUS}=     RUN KEYWORD AND RETURN STATUS      SHOULD CONTAIN      ${MO.text}
        ...  MRBTS-${BTS_INFO.ID}/EQM-1/APEQM-1/CABINET-1/SMOD-1/SFP-1/LANE-1
       continue for loop if  ${STATUS}==${FALSE}
       ${MO}    Get Element    ${ele}    *[@name="operationalState"]
       Log      ${MO}
       Log      ${MO.text}
       SHOULD CONTAIN    ${MO.text}    disabled
       EXIT FOR LOOP
    END
