*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
Library    OperatingSystem
#Library    ta_ssh_telnet
Library    taf.sbts.oam.coam.admin


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW
# Directory in which TC should look for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${PRECHECK_OBJECT_LIST}             ACTIVE_CRITICAL_ALARMS_REPORT-1,CONFIGURATION_REPORT-1,CPU_USAGE_REPORT-*,DISK_SPACE_REPORT-1,
...  FLASH_DISK_HEALTH_REPORT-*,RAM_USAGE_REPORT-*,RATS_STATE_REPORT-1,RESET_COVERAGE_REPORT-1,ROLLBACK_READINESS_REPORT-1,SW_DOWNLOAD_REPORT-1
# list of objects that should be created after software precheck procedure
${DC_PRECHECK_OBJECT_LIST}    CPU_USAGE_REPORT-*,DISK_SPACE_REPORT-2,FLASH_DISK_HEALTH_REPORT-*,RAM_USAGE_REPORT-*,ROLLBACK_READINESS_REPORT-2
# list of additional objects that should be created after software precheck procedure in case of Dual Core
${POSTCHECK_OBJECT_LIST}            CONFIGURATION_REPORT-1,CPU_USAGE_REPORT-*,RAM_USAGE_REPORT-*,RATS_STATE_REPORT-1,ROLLBACK_READINESS_REPORT-1
${DC_POSTCHECK_OBJECT_LIST}    CPU_USAGE_REPORT-*,RAM_USAGE_REPORT-*,RATS_STATE_REPORT-1,ROLLBACK_READINESS_REPORT-1
# list of additional objects that should be created after software precheck procedure in case of Dual Core
${SW Update Timeout}    3000    # Given in seconds; That is a timeout for SW download and activation (without reset)
${Ping loss timeout}    240    # Timeout for ping loss during reset
${Ping regain timeout}    600    # Timeout for ping regain during reset
${onAir Check Number}    60    # Number of checks for proceduralStatus: onAir (probably since the reset beginning); check interval = 10s
${First Cell On Air Timeout}     15    Time to wait for first cell on Air (in minutes)
${Test Timeout}    30    # Test timeout (in minutes)


*** Keywords ***
TC__SWM__SW_post_check_RAT_status_fail
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...  **Request ID:** TAT-19830
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...  This Tc verifies, that each step of the SW precheck operation is executed
    ...  and reported according to specification on I&V level.
    ...  Single Core and Dual Core is supported.
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...  - 03.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-19830 - initial creation
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************

    Set Tags    CA-SWM    PHASE-CRT    OWNER-dominik.jesariew@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS20    FEATURE-RP002315
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    SWM__SW_post_check_RAT_status_fail.Step 0: Precondition
    Step 1: Check the BTS states and active SW
    Step 2: SW precheck execution
    Step 3: Precheck results validation
    Step 4: ReportFilePrecheck validation
    Step 5: SW Download and Activation
    Step 6: RAT Critical Alarm are triggered
    Step 7: SW postcheck execution
    Step 8: Postcheck results validation
    Step 9: ReportFilePostcheck.xml file creation check

Step 0: Precondition
    [Documentation]    Short description.
    Log Step Header  Step 0: Precondition
    @{crt_alarms}    create list    49
    set test variable    ${crt_alarms}
    Add CRT Alarms And Initial WatchAlarm    ${crt_alarms}
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    # Verify SSH connection and enable if necessary
    Remove and send new SSH key
    #add dualcore judgement
    ${SMOD2_exists}     run keyword if  ${SCF_COUNT_SMOD}==2     set variable  True   ELSE     set variable  False
    Set test variable  ${DUALCORE}  ${SMOD2_exists}
    ${software_info}  taf.sbts.oam.coam.admin.Get Software Info
    Set test variable  ${ACTIVE_SW_BEFORE}  ${software_info['Active SW version']}
    Set test variable  ${PASSIVE_SW_BEFORE}  ${software_info['Passive SW version']}
    ${swbuild}    ${SWpath}    Choose Target SW build version from list  ${release_list}
    #${Target SW path}    _Download_Specify_Build_By_Aria  ${swbuild}  Basic  ${Target SW dir}${/}
    ${Target SW path}  set variable    ${SWpath}${swbuild}_release_BTSSM_downloadable_A54.zip
    Run Keyword If  '${Target_SW_path}'== ${None}   Fail   msg=No SW package found!
    Set test variable  ${TARGET_SW_PATH}  ${Target_SW_path}
    Log  Chosen software package is: ${Target_SW_path}  console=${TRUE}

Step 1: Check the BTS states and active SW
    [Documentation]    Short description.
    Log Step Header  Step 1: Check the BTS states and active SW
    Log  Check SW versions  console=${TRUE}
    ${sw_versions}  Create List
    ${sw_dict}  Get SW info  MSM
    Append To List  ${sw_versions}  ${sw_dict}
    ${sw_dict}  Run keyword if  ${DUALCORE}  Get SW info  ESM
    Run keyword if  ${DUALCORE}  Append To List  ${sw_versions}  ${sw_dict}
    Set test variable  ${SW_VERSIONS}  ${sw_versions}
    Print SW versions  ${sw_versions}
    Log  ${\n}Check alarms  console=${TRUE}
    ${alarms_status}  Run keyword and return status  Check SOAM Active Alarms
    Run keyword if  not ${alarms_status}  Log Important Message  Some critical alarms are active!  level=WARN
    ...  ELSE  Log  No critical alarms are active  console=${TRUE}
    Log  ${\n}Check if all cells are onAir  console=${TRUE}
    ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
    Run keyword if  ${all_cell_status}  Log  All cells are onAir  console=${TRUE}
    ...  ELSE  Run keywords  Log Important Message  Not all cells are onAir  level=WARN
    ...  AND    Log    Nothing    ##Log table  ${cell_state_table}

Step 2: SW precheck execution
    [Documentation]    Short description.
    Log Step Header  Step 2: SW precheck execution
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFile is present
    Run keyword if  ${ReportFilePrecheck_found}  Delete ReportFilePrecheck file  ${ReportFilePrecheck_path}
    Log  Start software precheck procedure  console=${TRUE}
    ${precheck_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Software Precheck Local  sw_package=${TARGET_SW_PATH}
    ...  precheck_type=FullCheck
    Run keyword if  ${precheck_status}  Log  Software Precheck done successfully  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Software Precheck failed!
    ...  AND
    ...  Log  Software Precheck failed!  console=${TRUE}

Step 3: Precheck results validation
    [Documentation]    Short description.
    Log Step Header  Step 3: Precheck results validation
    Log  Check if object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*_is created  console=${TRUE}
    ${object_exist}  Run keyword and return status
    ...  Query Infomodel  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*
    Run keyword if  ${object_exist}
    ...  Log  Object //MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*_exists  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*_doesn't exist
    ...  AND
    ...  Log  Object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*_doesn't exist  console=${TRUE}
    Log  Check if all object under .../PRECHECK_PROCEDURE_R are created  console=${TRUE}
    ${not_created_objects}  Create List
    Set test variable  ${ALL_OBJECT_EXIST}  ${TRUE}
    Set test variable  ${NOT_CREATED_OBJECTS}  ${not_created_objects}
    ${PRECHECK_OBJECT_LIST}  Replace String Using Regexp  ${PRECHECK_OBJECT_LIST}  pattern=,\\s  replace_with=,
    ${PRECHECK_OBJECT_LIST}  Split String  ${PRECHECK_OBJECT_LIST}  separator=,  max_split=-1
    Check if all object exist  ${PRECHECK_OBJECT_LIST}
    ${DC_PRECHECK_OBJECT_LIST}  Split String  ${DC_PRECHECK_OBJECT_LIST}  separator=,  max_split=-1
    Run keyword if  ${DUALCORE}  Check if all object exist  ${DC_PRECHECK_OBJECT_LIST}
    Run keyword if  not ${ALL_OBJECT_EXIST}  Run keywords
    ...  Log  Not all object was created! List of non created objects: ${not_created_objects}  console=${TRUE}
    ...  AND
    ...  Fail  Not all object was created! List of non created objects: ${not_created_objects}
    ...  ELSE  Log  All needed objects exist  console=${TRUE}
    Log  Check if all object under .../PRECHECK_PROCEDURE_R have proper value  console=${TRUE}
    Log  Check //ACTIVE_CRITICAL_ALARMS_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ACTIVE_CRITICAL_ALARMS_REPORT-1
    Run keyword if  '${object['status']}'=='Ok'
    ...  Log  Object //ACTIVE_CRITICAL_ALARMS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message
    ...  There should be some critical alarms active! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //CONFIGURATION_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CONFIGURATION_REPORT-1
    Run keyword if  '${object['actSwRollbackReject']}'=='False'
    ...  Log  Object //CONFIGURATION_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message
    ...  Rollback operation is permitted! Parameter 'actSwRollbackReject' has value ${object['actSwRollbackReject']}.
    ...  level=WARN
    Log  Check //CPU_USAGE_REPORT-1  console=${TRUE}
    ${object_1}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...    is [role="Primary"]
    ${object}   run keyword if  ${DUALCORE}==False    Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...  ELSE     Query Infomodel  get object ${object_1}
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //CPU_USAGE_REPORT-* has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.
    ...  level=WARN  level=WARN
    ${object_2}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...    is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Log  Check //CPU_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${object_2}
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'
    ...  Log  Object //CPU_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //DISK_SPACE_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/DISK_SPACE_REPORT-1
    ${Text_1}=    Catenate    Enough space on active partition
    ${Text_2}=    Catenate    Enough space on passive partition
    ${feedback_status}  Set variable if
    ...    '${object['feedback']}'=='${Text_1}' or '${object['feedback']}'=='${Text_2}'  ${TRUE}  ${FALSE}
    Run keyword if  '${object['status']}'=='Ok' and ${feedback_status}
    ...  Log  Object //DISK_SPACE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message
    ...  Not enough space disc! 'status' has value ${object['status']} and 'feedback' has value ${object['feedback']}.
    ...  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //DISK_SPACE_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/DISK_SPACE_REPORT-2
    ${feedback_status}  Run keyword if  ${DUALCORE}  Set variable if
    ...  '${object['feedback']}'=='${Text_1}' or '${object['feedback']}'=='${Text_2}'  ${TRUE}  ${FALSE}
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok' and ${feedback_status}
    ...  Log  Object //DISK_SPACE_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message
    ...  Not enough space disc! 'status' has value ${object['status']} and 'feedback' has value ${object['feedback']}.
    ...  level=WARN
    Log  Check //FLASH_DISK_HEALTH_REPORT-1  console=${TRUE}
    ${object_3}=    Catenate  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-*
    ...  is [role="Primary"]
    ${object}   run keyword if  ${DUALCORE}==False   Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-*
    ...  ELSE     Query Infomodel  get object ${object_3}
    Run keyword if  '${object['status']}'=='Ok' or '${object['status']}'=='Unknown'
    ...  Log  Object //FLASH_DISK_HEALTH_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  Not health disc! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //FLASH_DISK_HEALTH_REPORT-4  console=${TRUE}
    ${object_4}=    Catenate  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-*
    ...  is [role="Secondary"]
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${object_4}
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok' or '${object['status']}'=='Unknown'
    ...  Log  Object //FLASH_DISK_HEALTH_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message  Not health disc! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RAM_USAGE_REPORT-1  console=${TRUE}
    ${object_5}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ${object_6}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ...    is [role="Primary"]
    ${object}   run keyword if  ${DUALCORE}==False    Query Infomodel  get object ${object_5}
    ...  ELSE   Query Infomodel  get object ${object_6}
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //RAM_USAGE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    ${object_7}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ...  is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Log  Check //RAM_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${object_7}
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'
    ...  Log  Object //RAM_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RATS_STATE_REPORT-1  console=${TRUE}
    ${object_8}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RATS_STATE_REPORT-1
    ${object}  Query Infomodel  get object ${object_8}
    ${log_1}=    Catenate    Not all cells are onAir! Parameter 'noOfCellsInConfiguration'
    ...    (value: ${object['noOfCellsInConfiguration']}) is not equal to parameter
    ...    'noOfCellsOnAir' (value: ${object['noOfCellsOnAir']}).
    Run keyword if
    ...  '${object['status']}'=='Ok' and '${object['noOfCellsInConfiguration']}'=='${object['noOfCellsOnAir']}'
    ...  Log  Object //RATS_STATE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['status']}'!='Ok'
    ...  Log Important Message  Not all cells are onAir! Parameter 'status' has value ${object['status']}.  level=WARN
    ...  ELSE IF  '${object['noOfCellsInConfiguration']}'!='${object['noOfCellsOnAir']}'
    ...  Log Important Message    ${log_1}    level=WARN
    Log  Check //ROLLBACK_READINESS_REPORT-1  console=${TRUE}
    ${obj_9}=     Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-1
    ${object}  Query Infomodel  get object ${obj_9}
    ${log_2}=    Catenate    Discrepancy in rollback_readiness_check! Parameter 'allConnectedHwCompatible'
    ...    has value ${object['allConnectedHwCompatible']}.
    ${log_3}=    Catenate   Discrepancy in rollback_readiness_check! Parameter 'activeVersion' or
    ...    'passiveVersion' are different than SW versions on BTS.
    ${text_3}=    Catenate  '${object['allConnectedHwCompatible']}'=='True'
    ...  and '${object['activeVersion']}'=='${SW_VERSIONS[0].activeSoftwareVersion}'
    ...   and '${object['passiveVersion']}'=='${SW_VERSIONS[0].passiveSoftwareVersion}'
    Run keyword if  ${text_3}
    ...  Log  Object //ROLLBACK_READINESS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['allConnectedHwCompatible']}'=='False'
    ...  Log Important Message  ${log_2}  level=WARN
    ...  ELSE  Log Important Message  ${log_3}  level=WARN
    ${obj_10}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-2
    Run keyword if  ${DUALCORE}  Log  Check //ROLLBACK_READINESS_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${obj_10}
    Run keyword if  ${DUALCORE}  Run keyword if  ${text_3}
    ...  Log  Object //ROLLBACK_READINESS_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Run keyword if  '${object['allConnectedHwCompatible']}'=='False'
    ...  Log Important Message
    ...  Discrepancy in rollback_readiness! 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.
    ...  level=WARN
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message
    ...  Discrepancy in rollback_readiness! 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.
    ...  level=WARN

Step 4: ReportFilePrecheck validation
    [Documentation]    Short description.
    Log Step Header  Step 4: ReportFilePrecheck validation
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFile is present
    ${ReportFilePrecheck_path}  Get line  ${ReportFilePrecheck_path}  0
    Run keyword if  ${ReportFilePrecheck_found}==${FALSE}  Run keywords
    ...  Log  File ReportFilePrecheck.xml not created!  console=${TRUE}
    ...  AND  Fail  File ReportFilePrecheck.xml not created!
    ...  ELSE  Copy ReportFilePrecheck file  ${ReportFilePrecheck_path}  ${BTSFiles}/ReportFilePrecheck.xml
    ${xml_file}  Set variable  ${BTSFiles}/ReportFilePrecheck.xml
    Log  Validate ReportFilePrecheck.xml file  console=${TRUE}
    Run keyword if  ${DUALCORE}  Validate xml objects for DualCore  ${xml_file}
    ...  ELSE  Validate xml objects for SingleCore  ${xml_file}

Step 5: SW Download and Activation
    [Documentation]    Short description.
    Log Step Header  Step 5: SW Download and Activation
    Log  Will now perform software update  console=${TRUE}
    ${software_update_start}=  Get current date
    ${sw_update_result}  ${sw_update_msg}=  Run keyword and ignore error
    ...  taf.sbts.oam.coam.admin.Update Software  ${TARGET_SW_PATH}  True  ${SW Update Timeout}
    ${software_update_end}=  Get current date
    Run keyword if  '${sw_update_result}'=='FAIL'  Set Test Failed  Software update failed: ${sw_update_msg}
    ${ping loss status}  Run keyword and return status
    ...  Wait For Target To Be Not Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping loss timeout}
    Run keyword if  ${ping loss status}==${FALSE}
    ...  Log    BTS RESET after successful sw update DID NOT OCCUR   console=${TRUE}
    ...       ELSE
    ...  Log    BTS is resetting after successful sw update          console=${TRUE}
    ${ping_loss}=  Get current date
    ${ping regain status}  Run keyword and return status
    ...  Wait For Target To Be Reachable  hostname=${SMOD1['TRS_IP']}  timeout=${Ping regain timeout}
    Run keyword if  ${ping regain status}==${False}  Set Test Failed  Ping has not been regained within timeout
    ${ping_regain}=  Get current date
    ${ping stable status}  Run keyword and return status
    ...  Check If Target Is Stable  ${SMOD1['TRS_IP']}  min_uptime=60  max_downtime=0  timeout=61
    Run keyword if  ${ping stable status}==${False}  Set Test Failed  Ping has not been available for 60 seconds
    Set test variable  ${software_update_start}
    Set test variable  ${software_update_end}
    Set test variable  ${ping_loss}
    Set test variable  ${ping_regain}
    Wait Until Keyword Succeeds  10 min  10 sec  Fail if connection with admin is not available
    Wait until keyword succeeds  15 min  10 sec    Admin Check BTS Procedural and Blocking states    OnAir
    Log Important Message  BTS is OnAir, all cells and modules are in expected states

Step 6: RAT Critical Alarm are triggered
    [Documentation]    Short description.
    Log Step Header  Step 6: RAT Critical Alarm are triggered
    Log  start to get cell ID list
    #start admin  alias=default
    #start infomodel    bts_host=192.168.255.129
    ${Cell_para_List}   Admin Get LTE CELL parameters list_exclude_LNCEL-A  alias=default
    Log  start to block cell ${Cell_para_List[0]} to trigger critical alrm
    set test variable  ${lncell_ID}  ${Cell_para_List[0][0]}
    ${block cell result}  run keyword and return status  taf.sbts.oam.coam.admin.block  ${lncell_ID}
    Run keyword if  ${block cell result}   Log   block cell successfully   console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Block cell${Cell_Id_List[0]} failed!
    ...  AND
    ...  Log  Block cell${Cell_Id_List[0]}  failed!  console=${TRUE}
    Log  Start to Check critcal alarm 49
    ${Check alarm result}  run keyword and return status
    ...    taf.sbts.oam.coam.admin.Assert alarm active  faultId=49, severity=Critical
    Run keyword if  ${Check alarm result}    Log   critical alarm for fault 49 is triggered  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  critical alarm for fault 49 checking failed!
    ...  AND
    ...  Log  critical alarm for fault 49 checking failed!  console=${TRUE}

Step 7: SW postcheck execution
    [Documentation]    Short description.
    Log Step Header  Step 6: SW postcheck execution
    Log  Start software postcheck procedure  console=${TRUE}
    ${postcheck_status}    Run keyword and return status  taf.sbts.oam.coam.admin.Software Postcheck
    Run keyword if  '${postcheck_status}'=='False'  Log  Software Postcheck failed!  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Software Postcheck SUCCESSFULLY!
    ...  AND
    ...  Log  Software Postcheck SUCCESSFULLY!  console=${TRUE}

Step 8: Postcheck results validation
    [Documentation]    Short description.
    Log Step Header  Step 3: Precheck results validation
    Log  Check if object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*_is created  console=${TRUE}
    ${object_exist}  Run keyword and return status
    ...  Query Infomodel  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*
    Run keyword if  ${object_exist}
    ...  Log  Object //MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*_exists  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*_doesn't exist
    ...  AND
    ...  Log  Object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*_doesn't exist  console=${TRUE}
    Log  Check if all object under .../POSTCHECK_PROCEDURE_R are created  console=${TRUE}
    ${not_created_objects}  Create List
    Set test variable  ${ALL_OBJECT_EXIST}  ${TRUE}
    Set test variable  ${NOT_CREATED_OBJECTS}  ${not_created_objects}
    ${POSTCHECK_OBJECT_LIST}  Replace String Using Regexp  ${POSTCHECK_OBJECT_LIST}  pattern=,\\s  replace_with=,
    ${POSTCHECK_OBJECT_LIST}  Split String  ${POSTCHECK_OBJECT_LIST}  separator=,  max_split=-1
    Check if all object exist  ${POSTCHECK_OBJECT_LIST}  POSTCHECK
    ${DC_POSTCHECK_OBJECT_LIST}  Split String  ${DC_POSTCHECK_OBJECT_LIST}  separator=,  max_split=-1
    Run keyword if  ${DUALCORE}  Check if all object exist  ${DC_POSTCHECK_OBJECT_LIST}  POSTCHECK
    Run keyword if  not ${ALL_OBJECT_EXIST}  Run keywords
    ...  Log  Not all object was created! List of non created objects: ${not_created_objects}  console=${TRUE}
    ...  AND
    ...  Fail  Not all object was created! List of non created objects: ${not_created_objects}
    ...  ELSE  Log  All needed objects exist  console=${TRUE}
    Log  Check if all object under .../POSTCHECK_PROCEDURE_R have proper value  console=${TRUE}
    Log  Check //CONFIGURATION_REPORT-1  console=${TRUE}
    ${object_11}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/CONFIGURATION_REPORT-1
    ${object}  Query Infomodel  get object ${object_11}
    Run keyword if  '${object['actSwRollbackReject']}'=='False'
    ...  Log  Object //CONFIGURATION_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message
    ...  Rollback operation is permitted! Parameter 'actSwRollbackReject' has value ${object['actSwRollbackReject']}.
    ...  level=WARN
    Log  Check //CPU_USAGE_REPORT-1  console=${TRUE}
    ${object_12}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ${object_13}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...  is [role="Primary"]
    ${object}   run keyword if  ${DUALCORE}==False    Query Infomodel  get object ${object_12}
    ...  ELSE     Query Infomodel  get object ${object_13}
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //CPU_USAGE_REPORT-* has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //CPU_USAGE_REPORT-4  console=${TRUE}
    ${object_14}=    Catenate    /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...  is [role="Secondary"]
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${object_14}
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'
    ...  Log  Object //CPU_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RAM_USAGE_REPORT-1  console=${TRUE}
    ${object_15}=    Catenate   /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ${object_16}=    Catenate   /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ...  is [role="Primary"]
    ${object}   run keyword if  ${DUALCORE}==False    Query Infomodel  get object ${object_15}
    ...  ELSE   Query Infomodel  get object ${object_16}
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //RAM_USAGE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    ${object_17}=    Catenate   /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ...    is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Log  Check //RAM_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${object_17}
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'
    ...  Log  Object //RAM_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RATS_STATE_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/RATS_STATE_REPORT-1
    ${log_4}=    Catenate    Not all cells are onAir! Parameter 'noOfCellsInConfiguration'
    ...    (value: ${object['noOfCellsInConfiguration']}) is not equal to parameter 'noOfCellsOnAir'
    ...    (value: ${object['noOfCellsOnAir']}).
    Run keyword if
    ...  '${object['status']}'=='Ok' and '${object['noOfCellsInConfiguration']}'=='${object['noOfCellsOnAir']}'
    ...  Log  Object //RATS_STATE_REPORT-1 has correct value  console=${TRUE}    level=WARN
    ...  ELSE IF  '${object['status']}'!='Ok'
    ...  Log Important Message  Not all cells are onAir! Parameter 'status' has value ${object['status']}.
    ...  ELSE IF  '${object['noOfCellsInConfiguration']}'!='${object['noOfCellsOnAir']}'
    ...  Log Important Message  ${log_4}
    Log  Check //ROLLBACK_READINESS_REPORT-1  console=${TRUE}
    ${obj_18}=    Catenate  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-1
    ${object}  Query Infomodel  get object ${obj_18}
    ${text_4}=    Catenate  '${object['allConnectedHwCompatible']}'=='True'
    ${text_5}=    Catenate  '${object['activeVersion']}'=='${SW_VERSIONS[0].activeSoftwareVersion}'
    ${text_6}=    Catenate  '${object['passiveVersion']}'=='${SW_VERSIONS[0].passiveSoftwareVersion}'
    Run keyword if  ${text_4} and ${text_5} and ${text_6}
    ...  Log  Object //ROLLBACK_READINESS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['allConnectedHwCompatible']}'=='False'
    ...  Log Important Message
    ...  Discrepancy in rollback_readiness! 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.
    ...  level=WARN
    ...  ELSE  Log Important Message
    ...  Discrepancy in rollback_readiness! 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.
    ...  level=WARN
    ${obj_19}=    Catenate  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/POSTCHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-2
    Run keyword if  ${DUALCORE}  Log  Check //ROLLBACK_READINESS_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel  get object ${obj_19}
    Run keyword if  ${DUALCORE}  Run keyword if  ${text_4} and ${text_5} and ${text_6}
    ...  Log  Object //ROLLBACK_READINESS_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Run keyword if  '${object['allConnectedHwCompatible']}'=='False'
    ...  Log Important Message
    ...  Discrepancy in rollback_readiness! 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.
    ...  level=WARN
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message
    ...  Discrepancy in rollback_readiness! 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.
    ...  level=WARN

Step 9: ReportFilePostcheck.xml file creation check
    [Documentation]    Short description.
    Log Step Header  Step 4: ReportFilePrecheck validation
    ${ReportFilePostcheck_found}  ${ReportFilePostcheck_path}  Check if ReportFile is present  ReportFilePostcheck
    ${ReportFilePostcheck_path}  Get line  ${ReportFilePostcheck_path}  0
    Run keyword if  ${ReportFilePostcheck_found}==${TRUE}  Run keywords
    ...  Log  File ReportFilePostcheck.xml is created successfully!  console=${TRUE}
    ...  AND  Copy ReportFilePostcheck file  ${ReportFilePostcheck_path}  ${BTSFiles}/ReportFilePostcheck.xml
    ...  ELSE  Fail  File ReportFilePostcheck.xml is not created!

Step 10: recovery blocked cell
    [Documentation]    Short description.
    ${block cell result}  run keyword and return status  taf.sbts.oam.coam.admin.unblock  ${lncell_ID}
    Run keyword if  ${block cell result}   Log   unblock cell successfully  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  UnBlock cell${lncell_ID} failed!
    ...  AND
    ...  Log  UnBlock cell${lncell_ID}  failed!  console=${TRUE}

Validate xml objects for SingleCore
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${xml_file}: <description>
    [Arguments]  ${xml_file}
    Set test variable  ${WARNINGS}  ${FALSE}
    ${cpuUsage_present}  Run keyword and return status  XML.Element Should Exist  ${xml_file}  .//cpuUsage
    ${cpuUsage_quantity}  XML.Get Element Count  ${xml_file}  .//cpuUsage
    ${ramUsage_present}  Run keyword and return status  XML.Element Should Exist  ${xml_file}  .//ramUsage
    ${ramUsage_quantity}  XML.Get Element Count  ${xml_file}  .//ramUsage
    ${ratsStatus_present}  Run keyword and return status  XML.Element Should Exist  ${xml_file}  .//ratsStatus
    ${ratsStatus_quantity}  XML.Get Element Count  ${xml_file}  .//ratsStatus
    Run keyword if  not ${cpuUsage_present} or not ${ramUsage_present} or not ${ratsStatus_present}
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek has been created incorrectly! Not all objects are created!
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  ${cpuUsage_quantity}!=1 or ${ramUsage_quantity}!=1 or ${ratsStatus_quantity}!=1
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek has been created incorrectly! The quantity of one of the objects is greater than 1!
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${role_value}  XML.Get Element Attribute  ${xml_file}  role  .//cpuUsage
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//cpuUsage
    Run keyword if  '${role_value}'!='Single' or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek is created wrongly! <cpuUsage status="${status_value}" role="${role_value}"></cpuUsage>
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${role_value}  XML.Get Element Attribute  ${xml_file}  role  .//ramUsage
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ramUsage
    Run keyword if  '${role_value}'!='Single' or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek is created wrongly! <ramUsage status="${status_value}" role="${role_value}"></ramUsage>
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${noOfCellsInConfiguration_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsInConfiguration  .//ratsStatus
    ${noOfCellsOnAir_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsOnAir  .//ratsStatus
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ratsStatus
    ${log_5}=    Catenate    ReportFilePrechek is created wrongly!
    ...    <ratsStatus noOfCellsInConfiguration="${noOfCellsInConfiguration_value}"
    ...    noOfCellsOnAir="${noOfCellsOnAir_value}" status="${status_value}" reasoningStatus=""></ratsStatus>
    Run keyword if  ${noOfCellsInConfiguration_value}!=${noOfCellsOnAir_value} or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message    ${log_5}    level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  not ${WARNINGS}  Log  ReportFilePrechek was created properly.  console=${TRUE}

Validate xml objects for DualCore
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${xml_file}: <description>
    [Arguments]  ${xml_file}
    Set test variable  ${WARNINGS}  ${FALSE}
    ${cpuUsage_present}  Run keyword and return status  XML.Element Should Exist  ${xml_file}  .//cpuUsage
    ${cpuUsage_quantity}  XML.Get Element Count  ${xml_file}  .//cpuUsage
    ${ramUsage_present}  Run keyword and return status  XML.Element Should Exist  ${xml_file}  .//ramUsage
    ${ramUsage_quantity}  XML.Get Element Count  ${xml_file}  .//ramUsage
    ${ratsStatus_present}  Run keyword and return status  XML.Element Should Exist  ${xml_file}  .//ratsStatus
    ${ratsStatus_quantity}  XML.Get Element Count  ${xml_file}  .//ratsStatus
    Run keyword if  not ${cpuUsage_present} or not ${ramUsage_present} or not ${ratsStatus_present}
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek has been created incorrectly! Not all objects are created!
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  ${cpuUsage_quantity}!=2 or ${ramUsage_quantity}!=2 or ${ratsStatus_quantity}!=1
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek has been created incorrectly! The quantity of one of the objects is different than should be!
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${cpuUsage_objects}  XML.Get Elements  ${xml_file}  .//cpuUsage
    ${role1_value}  XML.Get Element Attribute  ${cpuUsage_objects[0]}  role
    ${role2_value}  XML.Get Element Attribute  ${cpuUsage_objects[1]}  role
    ${status1_value}  XML.Get Element Attribute  ${cpuUsage_objects[0]}  status
    ${status2_value}  XML.Get Element Attribute  ${cpuUsage_objects[1]}  status
    ${text_4}=    Catenate    '${role1_value}'=='Primary' and '${role2_value}'=='Secondary'
    ${role_status}  Evaluate  (${text_4}) or ('${role1_value}'=='Secondary' and '${role2_value}'=='Primary')
    ${status_status}  Set variable if  '${status1_value}'=='OK' and '${status2_value}'=='OK'  ${TRUE}  ${FALSE}
    ${log_1}=    Catenate    ReportFilePrechek is created wrongly!${\n}<cpuUsage status="${status1_value}"
    ...    role="${role1_value}"></cpuUsage>${\n}<cpuUsage status="${status2_value}" role="${role2_value}"></cpuUsage>
    Run keyword if  not ${role_status} or not ${status_status}
    ...  Run keywords
    ...  Log Important Message    ${log_1}    level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${ramUsage_objects}  XML.Get Elements  ${xml_file}  .//ramUsage
    ${role1_value}  XML.Get Element Attribute  ${ramUsage_objects[0]}  role
    ${role2_value}  XML.Get Element Attribute  ${ramUsage_objects[1]}  role
    ${status1_value}  XML.Get Element Attribute  ${ramUsage_objects[0]}  status
    ${status2_value}  XML.Get Element Attribute  ${ramUsage_objects[1]}  status
    ${role_status}  Evaluate  (${text_4}) or ('${role1_value}'=='Secondary' and '${role2_value}'=='Primary')
    ${status_status}  Set variable if  '${status1_value}'=='OK' and '${status2_value}'=='OK'  ${TRUE}  ${FALSE}
    ${log_2}=    Catenate    ReportFilePrechek is created wrongly!${\n}<ramUsage status="${status1_value}"
    ...    role="${role1_value}"></ramUsage>${\n}<ramUsage status="${status2_value}" role="${role2_value}"></ramUsage>
    Run keyword if  not ${role_status} or not ${status_status}
    ...  Run keywords
    ...  Log Important Message    ${log_2}    level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${noOfCellsInConfiguration_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsInConfiguration  .//ratsStatus
    ${noOfCellsOnAir_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsOnAir  .//ratsStatus
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ratsStatus
    ${log_3}=    Catenate    ReportFilePrechek is created wrongly!
    ...    <ratsStatus noOfCellsInConfiguration="${noOfCellsInConfiguration_value}"
    ...    noOfCellsOnAir="${noOfCellsOnAir_value}" status="${status_value}" reasoningStatus=""></ratsStatus>
    Run keyword if  ${noOfCellsInConfiguration_value}!=${noOfCellsOnAir_value} or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message    ${log_3}    level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  not ${WARNINGS}  Log  ReportFilePrechek was created properly.  console=${TRUE}

Get SW info
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${module}: <description>
    ...        ${alias}: <description>
    ...
    ...    Returns:
    ...        ${sw_dict}: <description>
    [Arguments]  ${module}=MSM  ${alias}=default
    ${sw_dict}  Create Dictionary
    ${sw_parameter_value}  Infomodel Get Active SW Version
    ...  module=${module}  im_param=activeSoftwareVersion  alias=${alias}
    Set to dictionary  ${sw_dict}  activeSoftwareVersion  ${sw_parameter_value}
    ${sw_parameter_value}  Infomodel Get Active SW Version
    ...  module=${module}  im_param=activeBuildDescriptorId  alias=${alias}
    Set to dictionary  ${sw_dict}  activeBuildDescriptorId  ${sw_parameter_value}
    ${sw_parameter_value}  Infomodel Get Passive SW Version
    ...  module=${module}  im_param=passiveSoftwareVersion  alias=${alias}
    Set to dictionary  ${sw_dict}  passiveSoftwareVersion  ${sw_parameter_value}
    ${sw_parameter_value}  Infomodel Get Passive SW Version
    ...  module=${module}  im_param=passiveBuildDescriptorId  alias=${alias}
    Set to dictionary  ${sw_dict}  passiveBuildDescriptorId  ${sw_parameter_value}
    [Return]  ${sw_dict}

Print SW versions
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${sw_versions}: <description>
    [Arguments]  ${sw_versions}
    ${list_lenght}  Get length  ${sw_versions}
    Log  SW versions:  console=${TRUE}
    Log  MSM:  console=${TRUE}
    Log  activeSoftwareVersion: ${sw_versions[0].activeSoftwareVersion}  console=${TRUE}
    Log  activeBuildDescriptorId: ${sw_versions[0].activeBuildDescriptorId}  console=${TRUE}
    Log  passiveSoftwareVersion: ${sw_versions[0].passiveSoftwareVersion}  console=${TRUE}
    Log  passiveBuildDescriptorId: ${sw_versions[0].passiveBuildDescriptorId}  console=${TRUE}
    Run keyword if  ${list_lenght}>1  Run keywords
    ...  Log  ESM:  console=${TRUE}
    ...  AND
    ...  Log  activeSoftwareVersion: ${sw_versions[1].activeSoftwareVersion}  console=${TRUE}
    ...  AND
    ...  Log  activeBuildDescriptorId: ${sw_versions[1].activeBuildDescriptorId}  console=${TRUE}
    ...  AND
    ...  Log  passiveSoftwareVersion: ${sw_versions[1].passiveSoftwareVersion}  console=${TRUE}
    ...  AND
    ...  Log  passiveBuildDescriptorId: ${sw_versions[1].passiveBuildDescriptorId}  console=${TRUE}

Check if ReportFile is present
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${Reportfile}: <description>
    ...
    ...    Returns:
    ...        ${is_found}: <description>
    ...        ${ReportFilePrecheck_path}: <description>
    [Arguments]    ${Reportfile}=ReportFilePrecheck
    Log  Check if ${Reportfile}.xml file is present in /ffs/run/config and delete if present  console=${TRUE}
    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${status}  ${ReportFilePrecheck_path}  Run keyword and ignore error
    ...  Run Remote Linux Command  find /ffs/run/config/${Reportfile}.xml
    ${is_found}  Set variable if  '${status}'=='FAIL'  ${FALSE}  ${TRUE}
    Run keyword if  '${status}'=='FAIL'  Log  ${Reportfile}.xml not found in /ffs/run/config/  console=${TRUE}
    ...  ELSE  Log  ${Reportfile}.xml found in /ffs/run/config/  console=${TRUE}
    [Return]  ${is_found}  ${ReportFilePrecheck_path}

Delete ReportFilePrecheck file
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ReportFilePrecheck_path}: <description>
    [Arguments]  ${ReportFilePrecheck_path}
    ${delete_status}  Run keyword and return status  Run Remote Linux Command  rm -f ${ReportFilePrecheck_path}
    Run keyword if  ${delete_status}  Log  ReportFilePrecheck.xml file successfully deleted  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  ReportFilePrecheck.xml file not deleted  level=WARN

Copy ReportFilePrecheck file
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ReportFilePrecheck_path}: <description>
    ...        ${destination_path}: <description>
    [Arguments]  ${ReportFilePrecheck_path}  ${destination_path}
    ${Command}=
    ...  Catenate    sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'${ReportFilePrecheck_path}' '${destination_path}'
    ${copy_status}  Run keyword and return status
    ...  Run  ${Command}
    Run keyword if  ${copy_status}  Log  ReportFilePrecheck.xml file successfully copied  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  ReportFilePrecheck.xml file not copied  level=WARN

Copy ReportFilePostcheck file
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${ReportFilePrecheck_path}: <description>
    ...        ${destination_path}: <description>
    [Arguments]  ${ReportFilePrecheck_path}  ${destination_path}
    ${Command}=
    ...  Catenate    sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'${ReportFilePrecheck_path}' '${destination_path}'
    ${copy_status}  Run keyword and return status
    ...  Run   ${Command}
    Run keyword if  ${copy_status}  Log  ReportFilePostcheck.xml file successfully copied  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  ReportFilePostcheck.xml file not copied  level=WARN

Check if all object exist
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PRECHECK_OBJECT_LIST}: <description>
    ...        ${CHECKTYPE}: <description>
    [Arguments]  ${PRECHECK_OBJECT_LIST}    ${CHECKTYPE}=PRECHECK
    FOR  ${object}  IN  @{PRECHECK_OBJECT_LIST}
        ${object_exist}  Run keyword and return status  Query Infomodel
        ...  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/${CHECKTYPE}_PROCEDURE_R-*/${object}
        Run keyword if  ${object_exist}
        ...  Log  Object /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/${CHECKTYPE}_PROCEDURE_R-*/${object}_exists
        ...  console=${TRUE}
        ...  ELSE  Run keywords
        ...  Append To List  ${NOT_CREATED_OBJECTS}
        ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/${CHECKTYPE}_PROCEDURE_R-*/${object}
        ...  AND
        ...  Set test variable  ${ALL_OBJECT_EXIST}  ${FALSE}
    END

Fail if connection with admin is not available
    [Documentation]    Short description.
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    ${admin_reset_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Reset admin
    ${status}=  Run keyword and return status   taf.sbts.oam.coam.admin.Get mrbts state
    Run keyword if  ${status}  Return from keyword
    Fail  ${admin_reset_status}

Custom Test Teardown
    [Documentation]    Short description.
   Step 10: recovery blocked cell
   Common Test Teardown
