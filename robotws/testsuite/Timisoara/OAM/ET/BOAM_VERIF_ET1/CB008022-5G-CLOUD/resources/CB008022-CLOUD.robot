*** Settings ***
Documentation
...    Author: Radu Turcu (radu.turcu@nokia.com)
...    Maintainer: Radu Turcu (radu.turcu@nokia.com)

Resource  ../../vduResourcesAIC/aic_common_resources.robot
#Resource  ../../../../../../Hangzhou/AIC/RAN_PZ_HAZ_2/resources/aic_common_resources.robot

*** Variables ***
${NEW_PLAN_NAME}=  XXX
${NEW_SCF}=  /home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008022-5G-CLOUD/resources/scf2RUs.xml
${Rmod_Id}      2

#vdu26
${VDUHTTP}      https://10.15.255.154
${VDUSSH}       10.15.255.244
${VDUFHGW}      10.5.50.168

#vdu13
#${VDUHTTP}      https://10.15.254.202
#${VDUSSH}       10.15.254.38
#${VDUFHGW}      10.5.50.230
${FHGWuser}     root
${FHGWpass}     root

*** Keywords ***

vDU_WebEM_User_Access_Control_Permission_Radio_module_Remove_Allowed
    Log To Console   Step1:Login to vDU WebEM with BTS System Administrator
    VDU Rest Login
    @{fault_id_list}  create list   7505  23  1931  10
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    ${scf_path}  Get A Directory  Get A Directory  /home/ute/robotws/results/
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    Delete Plan  plan_name=${NEW_PLAN_NAME}

    Log To Console   Step2: REMOVE SECOND RU FROM CONFIGURATION
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=/home/ute/robotws/results
    ...  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/NRBTS-1/NRCELL-32
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/NRBTS-1/NRCELLGRP-1
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}
    ...  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-32
    ${delta_dict}=   create dictionary	  refNrCellGroup/1='1'
    vdu.update_vdu_parameter_of_delta_plan  plan_id=${plan_id}   mo_dn=MRBTS-${MRBTS_ID}/NRBTS-1/NRDU-1
    ...  updated_paras_dict=${delta_dict}   operation=remove
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}

    Log To Console  Step3: ACTIVATE NEW DELTA PLAN
    Activate Delta Plan By REST   plan_id=${plan_id}  force_reset=False  wait_vdu_up=True

    Log To Console   Step4: CHECK NO ALARMS PRESENT AFTER RU REDUCTION
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    SLEEP  20s
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}

4vDU_WebEM_status_Radio_Module_Status_widget_Radio_module_Remove_Operation

    Log To Console   Step0:Login to vDU WebEM with BTS System Administrator
    VDU Rest Login
    @{fault_id_list}  create list   7505  23  1931  10
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    ${scf_path}  Get A Directory  Get A Directory  /home/ute/robotws/results/
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    Delete Plan  plan_name=${NEW_PLAN_NAME}
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=/home/ute/robotws/results/
    ...  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}

    Log To Console   \nStep1: RMOD Disconnection
    Execute FHGW command  command=sudo config interface shutdown Ethernet3
#    sleep  60s
    Wait until keyword succeeds  3 min  30 sec  Check RMODx Status On Vdu Side During Disconnection Unlock RU  1
    @{fault_id_list}  create list   10
    Wait until keyword succeeds  5 min  30 sec  VDU Active Alarm Should Contain Fault ID  @{fault_id_list}

    Log To Console   \nStep2: RMOD Lock
    VDU Rest Login
    @{RU_list}   Create List   ${Rmod_Id}
    Set test Variable    ${RU_list}
    vdu.Lock Rmods   ${RU_list}
    @{fault_id_list}  create list   10
    sleep  60s
    VDU Active Alarm Should Contain Fault ID  @{fault_id_list}
    Wait until keyword succeeds  3 min  30 sec  Check RMODx Status On Vdu Side During Disconnection Lock RU   1

    Log To Console   Step3: REMOVE SECOND RU FROM CONFIGURATION
    VDU Rest Login
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/NRBTS-1/NRCELL-32
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/NRBTS-1/NRCELLGRP-1
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}
    ...  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-32
    ${delta_dict}=   create dictionary	  refNrCellGroup/1='1'
    vdu.update_vdu_parameter_of_delta_plan  plan_id=${plan_id}   mo_dn=MRBTS-${MRBTS_ID}/NRBTS-1/NRDU-1
    ...  updated_paras_dict=${delta_dict}   operation=remove
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}

    Log To Console  Step4:ACTIVATE NEW DELTA PLAN
    Activate Delta Plan By REST   plan_id=${plan_id}  force_reset=False  wait_vdu_up=True

    Log To Console   Step5: CHECK NO ALARMS PRESENT AFTER RU REDUCTION
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    SLEEP  20s
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}

    Log To Console  Step6:Restore configuration
    Execute FHGW command  command=sudo config interface startup Ethernet3


eCPRI RMOD Reduction Without Service Impact Lock Disconnect

    Log To Console   Step0:Login to vDU WebEM with BTS System Administrator
    VDU Rest Login
    @{fault_id_list}  create list   7505  23  1931  10
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    ${scf_path}  Get A Directory  Get A Directory  /home/ute/robotws/results/
    Check Maximum Delta Plan Number And Delete One If Reach Maximum Number
    Delete Plan  plan_name=${NEW_PLAN_NAME}
    ${scf_file_with_fullpath}   vdu.Get_Current_Plan_File  local_dir_path=/home/ute/robotws/results
    ...  filename=scf.xml  include_runtime_data=${False}
    scf.Load_Scf  file_path=${scf_file_with_fullpath}
    ${VDU_CONF}  Get VDU Conf From SCF   scf_path=${scf_file_with_fullpath}
    ${all_BTS_ID}    Get BTS ID From vDU SCF    scf_path=${scf_file_with_fullpath}
    set test variable    ${MRBTS_ID}    ${all_BTS_ID[0]}

    Log To Console   \nStep1: RMOD Lock
    VDU Rest Login
    @{RU_list}   Create List   ${Rmod_Id}
    Set test Variable    ${RU_list}
    vdu.Lock Rmods   ${RU_list}
    @{fault_id_list}  create list   1931
    sleep  60s
    VDU Active Alarm Should Contain Fault ID  @{fault_id_list}
    Wait until keyword succeeds  3 min  30 sec  Check RMODx Status On Vdu Side During Lock RU   1

    Log To Console   \nStep2: RMOD Disconnection
    Execute FHGW command  command=sudo config interface shutdown Ethernet3
    sleep  60s
    Wait until keyword succeeds  3 min  30 sec  Check RMODx Status On Vdu Side During Disconnection RU  1

    Log To Console   Step3: REMOVE SECOND RU FROM CONFIGURATION
    VDU Rest Login
    ${delta_plan_name}   get unique id  prefix=TA_delta_plan   precise=LOW
    ${plan_id}   ${action_id}   Generate Delta Plan   plan_name=${delta_plan_name}  plan_description=TA
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/NRBTS-1/NRCELL-32
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/NRBTS-1/NRCELLGRP-1
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}   MRBTS-${MRBTS_ID}/EQM-1/APEQM-1/RMOD-2
    Run Keyword And Ignore Error     Delete Delta Plan MO   ${plan_id}
    ...  MRBTS-${MRBTS_ID}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-32
    ${delta_dict}=   create dictionary	  refNrCellGroup/1='1'
    vdu.update_vdu_parameter_of_delta_plan  plan_id=${plan_id}   mo_dn=MRBTS-${MRBTS_ID}/NRBTS-1/NRDU-1
    ...  updated_paras_dict=${delta_dict}   operation=remove
    ${validation_id}  Validate Delta Plan By REST  plan_id=${plan_id}

    Log To Console  Step4:ACTIVATE NEW DELTA PLAN
    Activate Delta Plan By REST   plan_id=${plan_id}  force_reset=False  wait_vdu_up=True

    Log To Console   Step5: CHECK NO ALARMS PRESENT AFTER RU REDUCTION
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}
    SLEEP  20s
    VDU Active Alarm Should Not Contain Fault ID  @{fault_id_list}

    Log To Console  Step6:Restore configuration
    Execute FHGW command  command=sudo config interface startup Ethernet3



Case Precondition
    ${START_TIME}=    Get time    exclude_millis=yes
    Set Suite Variable    ${START_TIME}
    ${SUITE_LOG_DIRECTORY}=    Get A Directory
    Set Suite Variable    ${SUITE_LOG_DIRECTORY}
    Log To Console   \nStep0: PRECONDITIONS AND Download SCF
    ${rmod_id_list}=    Get RMOD ID List
    ${rmod_number}=    get length    ${rmod_id_list}
    LOG TO CONSOLE   \nRUs installed = ${rmod_number}
    VDU Rest Login
#    Run Keyword If  ${rmod_number} != 2  Upload Plan And Validate And Activate
#    ...   plan_file=/home/ute/robotws/testsuite/Timisoara/OAM/ET/BOAM_VERIF_ET1/CB008022-5G-CLOUD/resources/scf2RUs.xml
#    ...   plan_name=${NEW_PLAN_NAME}  wait_vdu_up=True
    Wait until keyword succeeds  40 min  90 sec  vDU Verify All Cells Status Should Be Onair

Get RMOD ID List
    ${rmod_id_list}=  create list
    vdu rest login
    ${rmods_info}=   vdu.get_rmods_status
    FOR  ${rmod}  IN  @{rmods_info}
        append to list   ${rmod_id_list}   ${rmod["id"]}
    END
    [Return]   ${rmod_id_list}
    [Teardown]  VDU Rest Logout


Case Postcondition
    Log To Console   RESTORE INITIAL CONFIGURATION
    Delete Plan  plan_name=${NEW_PLAN_NAME}
    ${PLAN_ID}    ${ACTION_ID}   ${VALIDATION_ID}   Upload Plan And Validate And Activate
    ...   plan_file=/home/ute/robotws/results/scf.xml
    ...   plan_name=${NEW_PLAN_NAME}  wait_vdu_up=True
    Run Keyword And Ignore Error  VDU Rest Logout

Check RMODx Status On Vdu Side During Disconnection Lock RU
    [Arguments]  ${rux}
    [Teardown]  VDU Rest Logout
    Log To Console  Check RMODx Status On Vdu Side During Disconnection Lock RU
    VDU Rest Login
    ${RU_info}=  vdu.Get_Rmods_Status
    Log To Console    ${RU_info}
    Should Be Equal   ${RU_info[${rux}]["operational_state"]}   disabled
    Should Be Equal   ${RU_info[${rux}]["administrative_state"]}   Locked
    Should Be Equal   ${RU_info[${rux}]["procedural_status"]}    not initialized
    Should Be Equal   ${RU_info[${rux}]["availability_status"]}   not installed


Check RMODx Status On Vdu Side During Disconnection Unlock RU
    [Arguments]  ${rux}
    [Teardown]  VDU Rest Logout
    Log To Console  Check RMOD status On Vdu Side During Disconnection RU
    VDU Rest Login
    ${RU_info}=  vdu.Get_Rmods_Status
    Log To Console    ${RU_info}
    Should Be Equal   ${RU_info[${rux}]["operational_state"]}   disabled
    Should Be Equal   ${RU_info[${rux}]["administrative_state"]}   Unlocked
    Should Be Equal   ${RU_info[${rux}]["procedural_status"]}    not initialized
    Should Be Equal   ${RU_info[${rux}]["availability_status"]}   not installed

Check RMODx Status On Vdu Side During Disconnection RU
    [Arguments]  ${rux}
    [Teardown]  VDU Rest Logout
    Log To Console  Check RMOD status On Vdu Side During Disconnection RU
    VDU Rest Login
    ${RU_info}=  vdu.Get_Rmods_Status
    Log To Console    ${RU_info}
    Should Be Equal   ${RU_info[${rux}]["operational_state"]}   disabled
    Should Be Equal   ${RU_info[${rux}]["administrative_state"]}   Locked
    Should Be Equal   ${RU_info[${rux}]["procedural_status"]}    not initialized
    Should Be Equal   ${RU_info[${rux}]["availability_status"]}   not installed

Check RMODx Status On Vdu Side During Lock RU
    [Arguments]  ${rux}
    [Teardown]  VDU Rest Logout
    Log To Console  Check RMOD status On Vdu Side During Lock RU
    VDU Rest Login
    ${RU_info}=  vdu.Get_Rmods_Status
    Log To Console    ${RU_info}
    Should Be Equal   ${RU_info[${rux}]["operational_state"]}   enabled
    Should Be Equal   ${RU_info[${rux}]["administrative_state"]}   Locked
    Should Be Equal   ${RU_info[${rux}]["procedural_status"]}    configured
    Should Be Equal   ${RU_info[${rux}]["availability_status"]}   on line


Check RMODx Status On Vdu Side During UnLock RU
    [Arguments]  ${rux}
    [Teardown]  VDU Rest Logout
    Log To Console  Check RMOD status On Vdu Side During Lock RU
    VDU Rest Login
    ${RU_info}=  vdu.Get_Rmods_Status
    Log To Console    ${RU_info}
    Should Be Equal   ${RU_info[${rux}]["operational_state"]}   enabled
    Should Be Equal   ${RU_info[${rux}]["administrative_state"]}   Unlocked
    Should Be Equal   ${RU_info[${rux}]["procedural_status"]}    configured
    Should Be Equal   ${RU_info[${rux}]["availability_status"]}   on line

Execute FHGW command
    [Arguments]  ${command}
    ${fhgw_alias}=   get unique id
     ${alias}   issh.connect_to    ip=${VDUFHGW}   port=22    username=${FHGWuser}   password=${FHGWpass}    prompt=#
    ...   timeout=30  alias=${fhgw_alias}   width=200
    issh.set_prompt     _nokfhgwsyssonic@sonic:/$   alias=${alias}
    ${res}    issh.Execute    sudo sonic-cli     alias=${alias}
    ${res}    issh.Execute    ${command}     alias=${alias}
#    ${res}    issh.Execute    sudo show int sta     alias=${alias}
    issh.disconnect  alias=${alias}















