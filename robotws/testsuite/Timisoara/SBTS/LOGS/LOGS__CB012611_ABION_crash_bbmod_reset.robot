*** Settings ***
Documentation  Test Suite for TL10835_ARO
Library    OperatingSystem
Library    SSHLibrary
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/ssh_utils.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/pdu.robot
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/verdicts.robot



*** Variables ***
${SNAPSHOT_COLLECTION_TIMEOUT}  1200
${RESET_TYPE}    site_reset
${STARTUP_TIMEOUT}    8
${RECOVERY_TIMEOUT}  300
${DISABLED}  regex"Disabled|disabled"
${FAILED}  regex"Failed|failed"
${ENABLED}    regex"Enabled|enabled"
${UNBLOCKED}    Unblocked
${UNLOCKED}  regex"Unlocked|unlocked"
${TIME_BBMOD_STATE}  300
${DEGRADED}  regex"Degraded|degraded"
${BBMOD_TYPE}=    ABIO
${SNAPSHOT_TIMEOUT}    1200
${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}  ${True}
${BBMOD_SERIAL_NUMBER}=    L1214208620  # Mandatory, serial number for BBMOD must be given
${RESET_TIMEOUT}  180  # Timeout in seconds for waitting for positive procedure (reset unit) result

${bbmodDn}=    //MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-* is [availabilityStatus=degraded]
${bbmod-path}=    /MRBTS-10835/EQM_R-1/APEQM_R-1/CABINET_R-1/BBMOD_R-1

*** Keywords ***
TC__LOGS__CB012611_ABION_crash_site_reset
    [Documentation]
    ...  [CASE LINK]:
    ...  ******************
    ...  Author: Denisa Gogu, Maria Toma
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 2024-10-07 - TC created. version 1.0
    ...  ******************
    ...  Basic information
    ...  *****************
    ...  The purpose of this Test Case is to check if ABION crash with FID 252 is still seen after site reset
    ...  This case is running when one RMOD(AZHN) is dedicated: is mapped only on LokiA and one RMOD(AEHC) has shared resources between Lokis.
    ...  CLOUD_SRAN_NLWG_10835_2ASIL_2ABIA_2ABIL_1ABIO_1ABIN_FXED_AHGB_AHBCC_3AHIB_AHIB_AEHC_AZHN
    ...  *******************

    Step 0: Preconditions
    Step 1: Trigger bbmod crash
    Step 2: Check FID252 in WebEM
    Step 3: Waiting for FID10 on RMOD from failed Loki
    Step 4: Perform BBMOD reset and check status
    Step 5: Collect Snapshot and Check Snapshot content with FID252
    Step 6: Clear FID252


Step 0: Preconditions
    [Documentation]
    ...    in this step we are verifying if BTS is up and running

       Log  \nPreconditions  console=${True}

    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}

#check bbmod position. Will be used for crash bbmod
    ${bbmod_r_object}  Get Random Module Based On Its Type  ${BBMOD_TYPE}  BBMOD
    ${bbmod_r_dn}  Set Variable  ${bbmod_r_object}[id]
    ${bbmod_position}  Get Module Vertical Position  ${bbmod_r_dn}
    Set Test Variable  ${BBMOD_POSITION}
    ${bbmod_l_dn}  Get Module L Dist Name  ${bbmod_r_object}[serialNumber]  BBMOD
    Set Test Variable  ${BBMOD_L_DN}
    ${cells_list_on_fsp}  Get Cell Mapping By Module Id  ${bbmod_r_dn}
    Set Test Variable  ${CELLS_LIST_ON_FSP}

    ${num_of_BBMODs_failed}=
    ...    Query Infomodel  get count ${bbmodDn}
    Set Test Variable     ${num_of_BBMODs_failed}

Step 1: Trigger bbmod crash
    [Documentation]
    ...    in this step crash on BBMOD is perfomed. FID252 is raised
    ssh.Connect To    hostname=10.5.20.186   username=ute    password=ute    alias=slave_vm
    ssh.Connect To    hostname=192.168.255.119    username=toor4nsn    password=oZPS0POrRieRtu    proxy=slave_vm

  #LokiA is killed, for LokiB command to be used: bmutool -s <slot> -r 0x11 0xA0 (where <slot> means BBMOD position)
    ssh.Execute    command=bmutool -s ${BBMOD_POSITION} -r 0x10 0xA0

Step 2: Check FID252 in WebEM
    [Documentation]
    ...    Check if fault 252 is available in WebEm

    Log    \nStep 2: Check FID252 in WebEM   console=${True}
    Log  Wait up to 1 min in order to check if alarm 252 raised.  console=${True}
     ${fault_status}  Run Keyword And Return Status  Wait until keyword succeeds  600  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7100, faultId=252, faultName="Baseband Module Hardware Failure", severity=Critical
    ...  timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 252 "Baseband Module Hardware Failure" - severity=Critical - appeared  console=${True}
    ...  ELSE  Set Test Failed  Fault 252 "Baseband Module Hardware Failure" - did not not appear    ${True}

    Wait Until Keyword Succeeds  7m  30s    Check BBMOD is degraded  ${num_of_BBMODs_failed}

Check BBMOD is degraded
    [Arguments]  ${num_BBMODS_expected}
    ${num_of_BBMODs_crashed}=
    ...    Query Infomodel  get count ${bbmodDn}
    Log  Checking if Online BBMODs num (${num_of_BBMODs_crashed}) is = to expected ${num_of_BBMODs_crashed}  console=${True}
    Should Not Be Equal    ${num_BBMODS_expected}  ${num_of_BBMODs_crashed}
    Should Be Equal As Integers    ${num_of_BBMODs_crashed}    1


Step 3: Waiting for FID10 on RMOD from failed Loki
    [Documentation]
    ...    RMOD from failed Loki is checked if raised FID10; affected cells are also check to be failed and disabled

    Log    \nStep 3: Waiting for FID10 on RMOD from failed Loki   console=${True}
    ${rmod_param}    coam.Get Parameters For All    RMOD
    @{rmod_serial_number_list}=    Create List

    FOR  ${mod}  IN  @{rmod_param}
        Append To List  ${rmod_serial_number_list}  RMOD_${mod.serialNumber}
    END

    ${fault_status}  Run Keyword And Return Status  Wait until keyword succeeds  600  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7116, faultId=10, \
    ...    faultName="No connection to unit", severity=Critical    timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 10 "No connection to unit" - severity=Critical - appeared  console=${True}
    ...  ELSE  Set Test Failed  Fault 10 "No connection to unit" - did not not appear    ${True}

# check if connected cells on failed Loki are affected. Expect availabilitystatus failed and operationalstatus disabled
    Log  Check if connected cells on failed Loki are affected. console=true
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${CELLS_LIST_ON_FSP}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Run Keyword If  ${affected_cells_status}
    ...  Log  Affected cells are failed. [OK]  console=true
    ...  ELSE
    ...  Fail  Affected cells are not failed. [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10   Admin Check All Required State

Step 4: Perform BBMOD reset and check status
    [Documentation]
    ...     BBMOD reset is trigger after first bbmod crash and following checks are done

#Perform BBMOD Power Reset
    Log  \nStep4.1: Perform BBMOD power reset  console=True
    coam.Reset Unit  dist_name=${bbmod-path}  reset_type=PowerReset  timeout=${RESET_TIMEOUT}
    ...  graceful_cell_shutdown=${ACTIVATE_GRACEFUL_CELL_SHUTDOWN}

#Check FID252 after BBMOD reset
      Log    \nStep 4.2: Check FID252 in WebEM   console=${True}
    Log  Wait up to 1 min in order to check if alarm 252 raised.  console=${True}
     ${fault_status}  Run Keyword And Return Status  Wait until keyword succeeds  600  10
    ...  coam.Assert Alarm Active  parameters=alarmId=7100, faultId=252, faultName="Baseband Module Hardware Failure", severity=Critical
    ...  timeout=120
    Run keyword if  ${fault_status}
    ...  Log  Fault 252 "Baseband Module Hardware Failure" - severity=Critical - appeared  console=${True}
    ...  ELSE  Set Test Failed  Fault 252 "Baseband Module Hardware Failure" - did not not appear    ${True}

    Wait Until Keyword Succeeds  7m  30s    Check BBMOD is degraded  ${num_of_BBMODs_failed}

#Check Cells On BBMOD To Be Failed
   Log  Check if connected cells on failed Loki are affected. console=true
    ${affected_cells_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  180  10
    ...  Check Parameters Status For Cells  ${CELLS_LIST_ON_FSP}  operationalState=${DISABLED}, availabilityStatus=${FAILED}
    Run Keyword If  ${affected_cells_status}
    ...  Log  Affected cells are failed. [OK]  console=true
    ...  ELSE
    ...  Fail  Affected cells are not failed. [NOK]
    Wait Until Keyword Succeeds  ${RECOVERY_TIMEOUT}  10   Admin Check All Required State

Step 5: Collect Snapshot and Check Snapshot content with FID252
    [Documentation]
    ...    This step check if Snapshot collected successfully
    ...    In this step check if file RawAlarmHistory.txt is available in Snapshot
    ...    File RawAlarmHistory.txt should include FID:252

    Log    \Step 5: Collect Snapshot and Check Snapshot content with FID252   console=${True}
    @{time}=    Get Time    year month day hour min
    ${snapshot_status}    Run Keyword And Return Status
    ...    coam.Collect Snapshot    ${BTS Files}/Snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If    ${snapshot_status}
    ...    Collecting Snapshot Succeeded  ${time}
    ...    ELSE
    ...    verdicts.Set Test Failed  TC failed - Collecting snapshot using admin has failed.  ${TRUE}

    Log    \Check Snapshot Content   console=${True}
    Set Test Variable    ${SNAPSHOT_LOCATION}    ${BTS_Files}
    Set Test Variable    ${raw_file_name}   BTS${BTS_ID}_1011_RawAlarmHistory.txt.xz

    ${zip_part}    ${raw_file_name_list}  PartCheck

    ${zip_part_number}  Fetch From Left  ${zip_part}  /
    ${raw_archive_xz}  Fetch From Right  ${zip_part}  /
    ${filename_row}  Fetch From Left  ${raw_archive_xz}   .xz
    Log    File ${filename_row} is available in ${zip_part_number}  console=${True}

    unpacking.Unpack Archive Content To Directory  ${snapshot_path}   ${SNAPSHOT_LOCATION}/Unpack
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/Unpack/${zip_part_number}  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz
    unpacking.Unpack Archive Content To Directory  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/${raw_archive_xz}  ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/Raw_txt

    ${file_content}    OperatingSystem.Get File    ${SNAPSHOT_LOCATION}/Unpack/Raw_xz/Raw_txt/${filename_row}
    ${active_faults}    Fetch from left  ${file_content}    Inactive faults
    Should Contain    ${active_faults}    252
    Log    File contain FID:252    console=${True}
#    Run    rm -rf ${SNAPSHOT_LOCATION}/Unpack



Step 6: Clear FID252
    [Documentation]
    ...    FID252 is clear, BBMOD gets back on-air. Testline ready to be used
    Power Reset
PartCheck
    ${found_file_dict}    snapshot.Get Data From Snapshot    ${snapshot_path}
    ${temp}   Create List
    FOR  ${log_file}  IN  @{found_file_dict.keys()}
        Append to List   ${temp}    ${log_file}
        ${raw_zip_file}  Get Matches  ${temp}  ${raw_file_name}
        Remove From List   ${temp}   0
        ${raw_zip_file_len}   Get Length   ${raw_zip_file}
        Exit For Loop If  ${raw_zip_file_len}>0

    END
    [Return]  ${found_file_dict["${log_file}"][0]}    ${raw_zip_file}

Check If Snapshot Is Collected
    [Documentation]
    ...  In this KW it is checked if snapshot is triggered by syslog substring and collection is finished.

    Log  Check If Snapshot Is Collected  console=${True}
    ${snapshot_triggering_status}  Query Infomodel
    ...  check //TECHREP_L-*/SNAPSHOT-* is [originator=Internal,stateInfo.usageState=Active]  timeout=900  allow_negative_result=True
    Run Keyword If  ${snapshot_triggering_status}
    ...  Log  Snapshot was triggered by syslog substring.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot was not triggered by syslog substring.  ${TRUE}
    Log  Wait max ${SNAPSHOT_COLLECTION_TIMEOUT} seconds for snapshot to collect.  console=${True}
    ${snapshot_collection_status}  Query Infomodel
    ...  none //TECHREP_L-*/SNAPSHOT-* is [originator=Internal]  timeout=${SNAPSHOT_COLLECTION_TIMEOUT}  allow_negative_result=True
    Run Keyword If  ${snapshot_collection_status}
    ...  Log  Snapshot collection finished.  console=${True}
    ...  ELSE  verdicts.Set Test Failed  Snapshot collection not finished in ${SNAPSHOT_COLLECTION_TIMEOUT} seconds.  ${TRUE}


Unpack Archive Content To Directory
    [Documentation]
    ...  Unpacks the given file to the specified destination directory, based on its file extension.
    ...  example of simple use:  Unpack Archive Content To Directory   ${file}  ${destination_directory}
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com

    [Arguments]    ${file}    ${destination}
    ${extension}=    Get File Extension    ${file}
    Run Keyword If    '${extension}' == 'zip'    _Unzip To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'tar'    _Untar To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'tgz'    _Untgz To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'gz'    _Ungz To Directory    ${file}    ${destination}
    Run Keyword If    '${extension}' == 'xz'    _Unxz To Directory    ${file}    ${destination}

Collecting Snapshot Succeeded
    [Arguments]    ${time}
    Log    Collecting snapshot via admin succeeded    console=yes
    Set Test Variable    ${snapshot_path}    ${BTS Files}/Snapshot_${time[0]}_${time[1]}_${time[2]}_${time[3]}_${time[4]}.zip

Collect Snapshot
    [Documentation]
    ...  This keyword collects snapshot (full coverage), monitors collection status and sets path to snapshot as variable.
    Log   \nCollecting Snapshot   console=${True}
    ${timestamp}   Get time
    ${timestamp}   Replace String Using Regexp   ${timestamp}   (${SPACE}|:|-)  _
    Set Test Variable   ${timestamp}
    ${log_status}   Run Keyword And Ignore Error   coam.Collect snapshot   ${BTS_Files}/snapshot_${timestamp}.zip   timeout=1800
    Run Keyword If   '${log_status[0]}'=='FAIL'
    ...    Fail   Collecting snapshot failed
    ...    ELSE
    ...    Log   Full snapshot is successfully collected   console=${True}
    Set Test Variable   ${path_to_snapshot}   ${BTS_Files}/snapshot_${timestamp}.zip



Get BBMOD with given serial number
    [Arguments]  ${serial_number}
    ${bbmods}=    Get Parameters For All    BBMOD
    FOR  ${bbmod}  IN  @{bbmods}
        Run Keyword If    '${serial_number}'=='${bbmod.serialNumber}'  Return from keyword  ${bbmod}
    END
    Fail  ${serial_number} is wrong, please set correct BBMOD_SERIAL_NUMBER

Get Random Module Based On Its Type
    [Documentation]
    ...  This keyword returns a random module object based on module type.
    ...  Ex: Get random module based on its type  ABIO  BBMOD
    ...  *AUTHOR* andrada.baleti@nokia.com
    [Arguments]  ${module_type}  ${smod_bbmod_type}

    ${module_objects}  coam.Get Parameters For All  ${smod_bbmod_type}
    ${module_list}  Create List
    FOR  ${module_object}  IN  @{module_objects}
        ${status}  Run Keyword And Return Status
        ...  Should Contain  ${module_object}[productName]  ${module_type}
        Run Keyword If  ${status}
        ...  Append To List  ${module_list}  ${module_object}
    END
    ${module_list_length}  Get Length  ${module_list}
    ${random_module_object}  Run Keyword If  ${module_list_length}==1
    ...  Set Variable  ${module_list}[0]
    ...  ELSE
    ...  Evaluate  random.choice(${module_list})  random

    [Return]  ${random_module_object}

Get Module L Dist Name
    [Documentation]
    ...  This kewyord returns module L dist name by serial number.
    ...  Ex: ${module_l_dn}  Get module L dist name  EA192171673  BBMOD
    ...  *AUTHOR* andrada.baleti@nokia.com
    [Arguments]  ${module_sn}  ${module_type}

    ${bts_info}  coam.Get Bts Info
    ${modules}  Set Variable If  '${module_type}'=='SMOD'  systemModules  basebandModules
    ${modules_info}  Set Variable  ${bts_info}[${modules}]
    FOR  ${module_info}  IN  @{modules_info}
        Run Keyword If  '${module_sn}'=='${module_info}[serialNumber]'
        ...  Exit For Loop
    END
    ${ports}  Set Variable  ${module_info}[ports]
    FOR  ${port}  IN  @{ports}
        Exit For Loop If  "${module_type}_L" in "${port}[id][internal]"
    END
    ${module_l_dn}  Fetch From Left  ${port}[id][internal]  /CONNECTOR_L

    [Return]  ${module_l_dn}
Get Module Vertical Position
    [Documentation]
    ...  This keyword returns module vertical position from runtime object dist_name (SMOD_R or BBMOD_R).
    ...  In case of ASOE/ASOF/ASOG/ASOH core unit keyword will return 0.
    ...  *AUTHOR* laura.craciunel@nokia.com
    [Arguments]  ${module_r_dn}

    ${module_parameters}  coam.Get Parameters  ${module_r_dn}
    ${module_vertical_position}  Run Keyword If  '${module_parameters}[verticalPosition]' != '${None}'
    ...  Evaluate  ${module_parameters}[verticalPosition]-1
    ...  ELSE
    ...  Set Variable  0

    [Return]  ${module_vertical_position}

Check Parameters Status For Cells
    [Documentation]
    ...  This keyword checks parameters for cells with Assert keyword.
    ...  The cells list must be a list of cell dist names(Get cell mapping by module id is recommended to be used).
    ...  E.g. Check parameters status for cells  ${LTE_CELLS}  operationalState=${DISABLED_}, availabilityStatus=${FAILED_}
    ...  *AUTHOR* anna.benzar@nokia.com
    [Arguments]  ${cells_list}  ${parameters}

    FOR  ${cell_id}  IN  @{cells_list}
        ${cell_class_name}  Get Regexp Matches  ${cell_id}  [A-Z]{2}CEL
        Assert  ${cell_class_name}[0]  id=${cell_id}  parameters=${parameters}  timeout=60s
    END

Admin Check All Required State
    [Documentation]  This keyword check all required state for cells and modules.

    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Run Keywords
    ...  coam.Assert Every  LNCEL  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  LNCEL  ${SCF_COUNT_LTE}
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Run Keywords
    ...  coam.Assert Every  GNCEL  administrativeState=${UNLOCKED}, blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  GNCEL  ${SCF_COUNT_GSM}
    Run Keyword If  ${SCF_COUNT_WCDMA}
    ...  Run Keywords
    ...  coam.Assert Every  WNCEL  blockingState=${UNBLOCKED}, operationalState=${ENABLED}
    ...  AND
    ...  Admin Check Cells Number  WNCEL  ${SCF_COUNT_WCDMA}
    ${cell_types}  Create List  GNCEL  WNCEL  LNCEL  NRCEL
    FOR  ${cell_type}  IN  @{cell_types}
        Check If Cells Are Not Degraded  ${cell_type}
    END
    coam.Assert Every  SMOD  operationalState=${ENABLED}

Admin Check Cells Number
    [Documentation]  Check if number cells detected by admin is as expected
    ...  | Parameter              | Mandatory     | Description                           |
    ...  | technology             | Yes           | Cell ID e.g: LNCEL, GNCEL or WNCEL    |
    ...  | expectted_cells_number | Yes           | Expected cells number                 |
    [Arguments]  ${technology}  ${expected_cells_number}

    Run Keyword If  ${expected_cells_number}==-1
    ...  Run Keywords
    ...  Log  ${technology} will be ignored for active software  console=true
    ...  AND
    ...  Return From Keyword  ${True}
    ${id_list}  Get Ids For All  ${technology}
    ${admin_cells_num}  Evaluate  len(${id_list})
    Should Be Equal As Integers  ${expected_cells_number}  ${admin_cells_num}
    ...  Admin see different cells number than expected! Expected: ${expected_cells_number} is not equal admin cells num: ${admin_cells_num}.

Check If Cells Are Not Degraded
    [Documentation]  This KW check if all cells from a specific technology are not degraded.
    [Arguments]  ${cell_type}

    ${status}  Run Keyword And Return Status
    ...  coam.Assert Any  ${cell_type}  availabilityStatus=${DEGRADED}
    Run Keyword If  ${status}
    ...  Fail
Check Mapped Cells And Bbmod Status
    [Arguments]  ${availability_status}  ${operational_state}

    ${bbmod_status}  Run Keyword And Return Status
    ...  Check Bbmod  ${availability_status}  ${operational_state}
    Wait Until Keyword Succeeds  120  10
    ...  Checking Cells On The Given FSP  ${availability_status}  ${operational_state}
    Run Keyword If  ${bbmod_status}
    ...  Log  BBMOD was failed. [OK]  console=true
    ...  ELSE
    ...  Set Test Restriction  msg=BBMOD was not failed.

Set Variables For Cells
    ${affected_cells}  Get Cell Mapping By Module Id  ${BBMOD_PARAMETERS}[id]
    ${unaffected_cells}  Get Ids For All Cells
    Remove Values From List  ${unaffected_cells}  @{affected_cells}
    Set Test Variable  ${AFFECTED_CELLS}
    Set Test Variable  ${UNAFFECTED_CELLS}

Get Ids For All Cells
    ${list_all_rat}  Create List  NRCEL  LNCEL  WNCEL  GNCEL
    ${cells_list}  Create List
    FOR  ${cell_class_name}  IN  @{list_all_rat}
        ${cell_on_rat}  Get Ids For All  ${cell_class_name}
        Append To List  ${cells_list}  @{cell_on_rat}
    END

    [Return]  ${cells_list}


Checking Cells On The Given FSP
    [Arguments]  ${cell_availability_status}  ${cell_operational_state}

    Log  Cells on FSP will be checked.  console=true
    FOR  ${cell}  IN  @{CELLS_LIST_ON_FSP}
        Wait Until Keyword Succeeds  300s  10s
        ...  Get And Check Cell Status  ${cell}  ${cell_availability_status}  ${cell_operational_state}
    END

Get And Check Cell Status
    [Arguments]  ${cell}  ${cell_availability_status}  ${cell_operational_state}

    ${cell_obj}  Query Infomodel  get object ${cell}
    ${availability}  Run Keyword And Return Status
    ...  Should Contain  ${cell_availability_status}  ${cell_obj.availabilityStatus}
    ${operational}  Run Keyword And Return Status
    ...  Should Contain  ${cell_operational_state}  ${cell_obj.operationalState}
    Run Keyword If  ${availability} and ${operational}
    ...  Log  Cell ${cell_obj.dist_name} is in expected state [OK]  console=true
    ...  ELSE
    ...  Fail  Cell ${cell_obj.dist_name} is in unexpected state: availability_status=${availability} and operational_status=${operational}.

TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown

