*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/robot

Library    OperatingSystem
Library    taf.sbts.oam.coam.admin


*** Variables ***
${TARGET_SW_NAME}    ${None}    # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}    /home/ute/btsauto/TARGET_SW    # Directory for sw package. If not given, '/home/ute/btsauto/TARGET_SW' shall be used
${PRECHECK_OBJECT_LIST}    ACTIVE_CRITICAL_ALARMS_REPORT-1,CONFIGURATION_REPORT-1,CPU_USAGE_REPORT-*,DISK_SPACE_REPORT-1,FLASH_DISK_HEALTH_REPORT-*,
...    RAM_USAGE_REPORT-*,RATS_STATE_REPORT-1,RESET_COVERAGE_REPORT-1,ROLLBACK_READINESS_REPORT-1,SW_DOWNLOAD_REPORT-1
...    # list of objects that should be created after software precheck procedure
${DC_PRECHECK_OBJECT_LIST}    CPU_USAGE_REPORT-*,DISK_SPACE_REPORT-2,FLASH_DISK_HEALTH_REPORT-*,RAM_USAGE_REPORT-*,ROLLBACK_READINESS_REPORT-2
...    # list of additional objects that should be created after software precheck procedure in case of Dual Core


*** Keywords ***
TC__SWM__SW_pre_check_critical_alarm_active
    [Documentation]
    ...  ********************
    ...  1. Basic information
    ...  ********************
    ...
    ...  **Request ID:** TAT-19830
    ...
    ...  ***********************************************************
    ...  2. Description in reStructuredText format on what is tested
    ...  ***********************************************************
    ...
    ...  This Tc verifies, that each step of the SW precheck operation is executed and reported according to specification on I&V level.
    ...  Single Core and Dual Core is supported.
    ...
    ...  *********************
    ...  3. History of changes
    ...  *********************
    ...
    ...  - 03.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-19830 - initial creation
    ...
    ...  **********************
    ...  4. Test case flowchart
    ...  **********************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/SWM__SW_pre_check_successful.png

    Set Tags    CA-SWM    PHASE-CRT    OWNER-dominik.jesariew@nokia.com    AUTHOR-tomasz.zadworny@nokia.com
    ...    MAINTAINER-tomasz.zadworny@nokia.com    SW-SBTS20    FEATURE-RP002315
    ...    GROUP_IN_CHARGE-WRO_7_Vrf

    Step 0: Precondition
    Step 1: Check the BTS states and active SW
    Step 2: Critical Alarm are triggered
    Step 3: SW precheck execution
    Step 4: Precheck results validation
    Step 5: ReportFilePrecheck.xml file creation check

Step 0: Precondition
    [Documentation]    Short description.
    Log Step Header  Step 0: Precondition
    Setup hran compa  ssh_user=${SMOD1['USERNAME']}  ssh_password=${SMOD1['PASSWORD']}
    # Verify SSH connection and enable if necessary
    Remove and send new SSH key
    #add dualcore judgement
    ${SMOD2_exists}     run keyword if  ${SCF_COUNT_SMOD}==2     set variable   True   ELSE     set variable  False
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

Step 2: Critical Alarm are triggered
    [Documentation]    Short description.
    Log Step Header  Step 2: Critical Alarm are triggered
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

Step 3: SW precheck execution
    [Documentation]    Short description.
    Log Step Header  Step 3: SW precheck execution
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFilePrecheck is present
    Run keyword if  ${ReportFilePrecheck_found}  Delete ReportFilePrecheck file  ${ReportFilePrecheck_path}
    Log  Start software precheck procedure  console=${TRUE}
    ${precheck_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Software Precheck Local  sw_package=${TARGET_SW_PATH}
    ...    precheck_type=FullCheck
    Run keyword if  '${precheck_status}'=='False'  Log  Software Precheck failed!   console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Software Precheck SUCCESSFULLY!
    ...  AND
    ...  Log  Software Precheck SUCCESSFULLY!  console=${TRUE}

Step 4: Precheck results validation
    [Documentation]    Short description.
    Log Step Header  Step 4: Precheck results validation
    Log  Check if object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-* is created  console=${TRUE}
    ${object_exist}  Run keyword and return status  Query Infomodel  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*
    Run keyword if  ${object_exist}  Log  Object //MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-* exists  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-* doesn't exist
    ...  AND
    ...  Log  Object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-* doesn't exist  console=${TRUE}
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
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ACTIVE_CRITICAL_ALARMS_REPORT-1
    Run keyword if  '${object['status']}'=='NotOk'  Log  Object //ACTIVE_CRITICAL_ALARMS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  There should be some critical alarms active! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //CONFIGURATION_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CONFIGURATION_REPORT-1
    Run keyword if  '${object['actSwRollbackReject']}'=='False'  Log  Object //CONFIGURATION_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  Rollback operation is permitted! Parameter 'actSwRollbackReject' has value ${object['actSwRollbackReject']}.
    ...  level=WARN
    Log  Check //CPU_USAGE_REPORT-1  console=${TRUE}
    ${object}   run keyword if  ${DUALCORE}==False
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...    ELSE     Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-* is [role="Primary"]
#    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //CPU_USAGE_REPORT-* has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //CPU_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-* is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'  Log  Object //CPU_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //DISK_SPACE_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/DISK_SPACE_REPORT-1
    ${feedback_status}  Set variable if
    ...  '${object['feedback']}'=='Enough space on active partition' or '${object['feedback']}'=='Enough space on passive partition'
    ...  ${TRUE}  ${FALSE}
    Run keyword if  '${object['status']}'=='Ok' and ${feedback_status}  Log  Object //DISK_SPACE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message
    ...  Not enough space to download a new build! Parameter 'status' has value ${object['status']} and 'feedback' has value ${object['feedback']}.
    ...  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //DISK_SPACE_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/DISK_SPACE_REPORT-2
    ${feedback_status}  Run keyword if  ${DUALCORE}  Set variable if
    ...  '${object['feedback']}'=='Enough space on active partition' or '${object['feedback']}'=='Enough space on passive partition'
    ...  ${TRUE}  ${FALSE}
    Run keyword if  ${DUALCORE}  Run keyword if
    ...  '${object['status']}'=='Ok' and ${feedback_status}  Log  Object //DISK_SPACE_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Log Important Message
    ...  Not enough space to download a new build! Parameter 'status' has value ${object['status']} and 'feedback' has value ${object['feedback']}.
    ...  level=WARN
    Log  Check //FLASH_DISK_HEALTH_REPORT-1  console=${TRUE}
    ${object}   run keyword if  ${DUALCORE}==False   Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-*
    ...  ELSE     Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-* is [role="Primary"]
    Run keyword if  '${object['status']}'=='Ok' or '${object['status']}'=='Unknown'  Log  Object //FLASH_DISK_HEALTH_REPORT-1 has correct value
    ...  console=${TRUE}
    ...  ELSE  Log Important Message  Not health disc! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //FLASH_DISK_HEALTH_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-* is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok' or '${object['status']}'=='Unknown'
    ...  Log  Object //FLASH_DISK_HEALTH_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Log Important Message  Not health disc! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RAM_USAGE_REPORT-1  console=${TRUE}
    ${object}   run keyword if  ${DUALCORE}==False    Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ...    ELSE   Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-* is [role="Primary"]
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //RAM_USAGE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //RAM_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-* is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'  Log  Object //RAM_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RATS_STATE_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RATS_STATE_REPORT-1
    Run keyword if  '${object['status']}'=='Ok' and '${object['noOfCellsInConfiguration']}'=='${object['noOfCellsOnAir']}'
    ...  Log  Object //RATS_STATE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['status']}'!='Ok'  Log Important Message  Not all cells are onAir! Parameter 'status' has value ${object['status']}.
    ...  level=WARN
    ...  ELSE IF  '${object['noOfCellsInConfiguration']}'!='${object['noOfCellsOnAir']}'
    ...  Log Important Message  Not all cells are onAir! Parameter 'noOfCellsInConfiguration' is not equal to parameter 'noOfCellsOnAir'.  level=WARN
    Log  Check //ROLLBACK_READINESS_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-1
    ${Conbinecondit}=    Catenate    SEPARATOR=${SPACE}
    ...    '${object['allConnectedHwCompatible']}'=='True'
    ...    and '${object['activeVersion']}'=='${SW_VERSIONS[0].activeSoftwareVersion}'
    ...    '${object['passiveVersion']}'=='${SW_VERSIONS[0].passiveSoftwareVersion}'
    log  ${Conbinecondit}
    Run keyword if  ${Conbinecondit}  Log  Object //ROLLBACK_READINESS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['allConnectedHwCompatible']}'=='False'  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.  level=WARN
    ...  ELSE  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //ROLLBACK_READINESS_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}  Query Infomodel
    ...  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-2
    Run keyword if  ${DUALCORE}  Run keyword if  ${Conbinecondit}  Log  Object //ROLLBACK_READINESS_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Run keyword if  '${object['allConnectedHwCompatible']}'=='False'  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.  level=WARN
    ...  ELSE IF  ${DUALCORE}  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.  level=WARN

Step 5: ReportFilePrecheck.xml file creation check
    [Documentation]    Short description.
    Log Step Header  Step 4: ReportFilePrecheck validation
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFilePrecheck is present
    ${ReportFilePrecheck_path}  Get line  ${ReportFilePrecheck_path}  0
    Run keyword if  ${ReportFilePrecheck_found}==${TRUE}  Run keywords
    ...  Log  File ReportFilePrecheck.xml is created successfully!  console=${TRUE}
    ...  AND  Copy ReportFilePrecheck file  ${ReportFilePrecheck_path}  ${BTSFiles}/ReportFilePrecheck.xml
    ...  ELSE  Fail  File ReportFilePrecheck.xml is not created!

Step6: recovery blocked cell
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
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! Not all objects are created!  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  ${cpuUsage_quantity}!=1 or ${ramUsage_quantity}!=1 or ${ratsStatus_quantity}!=1
    ...  Run keywords
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! The quantity of one of the objects is greater than 1!  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${role_value}  XML.Get Element Attribute  ${xml_file}  role  .//cpuUsage
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//cpuUsage
    Run keyword if  '${role_value}'!='Single' or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message  ReportFilePrechek is created wrongly! <cpuUsage status="${status_value}" role="${role_value}"></cpuUsage>  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${role_value}  XML.Get Element Attribute  ${xml_file}  role  .//ramUsage
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ramUsage
    Run keyword if  '${role_value}'!='Single' or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message  ReportFilePrechek is created wrongly! <ramUsage status="${status_value}" role="${role_value}"></ramUsage>  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${noOfCellsInConfiguration_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsInConfiguration  .//ratsStatus
    ${noOfCellsOnAir_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsOnAir  .//ratsStatus
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ratsStatus
    Run keyword if  ${noOfCellsInConfiguration_value}!=${noOfCellsOnAir_value} or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message  ReportFilePrecheck is wrongly! <ratsStatus noOfCellsInConfiguration="${noOfCellsInConfiguration_value}"  level=WARN
    ...  AND  Log Important Message    noOfCellsOnAir="${noOfCellsOnAir_value}" status="${status_value}" reasoningStatus=""></ratsStatus>  level=WARN
    ...  AND  Set test variable  ${WARNINGS}  ${TRUE}
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
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! Not all objects are created!  level=WARN
    ...  AND  Set test variable  ${WARNINGS}  ${TRUE}
     Run keyword if  ${cpuUsage_quantity}!=2 or ${ramUsage_quantity}!=2 or ${ratsStatus_quantity}!=1
    ...  Run keywords
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! The quantity of one of the objects is different than should be!
    ...  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${cpuUsage_objects}  XML.Get Elements  ${xml_file}  .//cpuUsage
    ${role1_value}  XML.Get Element Attribute  ${cpuUsage_objects[0]}  role
    ${role2_value}  XML.Get Element Attribute  ${cpuUsage_objects[1]}  role
    ${status1_value}  XML.Get Element Attribute  ${cpuUsage_objects[0]}  status
    ${status2_value}  XML.Get Element Attribute  ${cpuUsage_objects[1]}  status
    ${role_status}  Evaluate
    ...    ('${role1_value}'=='Primary' and '${role2_value}'=='Secondary') or ('${role1_value}'=='Secondary' and '${role2_value}'=='Primary')
    ${status_status}  Set variable if  '${status1_value}'=='OK' and '${status2_value}'=='OK'  ${TRUE}  ${FALSE}
    Run keyword if  not ${role_status} or not ${status_status}
    ...  Run keywords
    ...  Log Important Message  ReportFilePrechek is created wrongly!${\n}<cpuUsage status="${status1_value}" role="${role1_value}">  level=WARN
    ...  AND    Log Important Message  </cpuUsage>${\n}<cpuUsage status="${status2_value}" role="${role2_value}"></cpuUsage>  level=WARN
    ...  AND    Set test variable  ${WARNINGS}  ${TRUE}
    ${ramUsage_objects}  XML.Get Elements  ${xml_file}  .//ramUsage
    ${role1_value}  XML.Get Element Attribute  ${ramUsage_objects[0]}  role
    ${role2_value}  XML.Get Element Attribute  ${ramUsage_objects[1]}  role
    ${status1_value}  XML.Get Element Attribute  ${ramUsage_objects[0]}  status
    ${status2_value}  XML.Get Element Attribute  ${ramUsage_objects[1]}  status
    ${role_status}  Evaluate
    ...  ('${role1_value}'=='Primary' and '${role2_value}'=='Secondary') or ('${role1_value}'=='Secondary' and '${role2_value}'=='Primary')
    ${status_status}  Set variable if  '${status1_value}'=='OK' and '${status2_value}'=='OK'  ${TRUE}  ${FALSE}
    Run keyword if  not ${role_status} or not ${status_status}
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek is created wrongly!${\n}<ramUsage status="${status1_value}" role="${role1_value}">  level=WARN
    ...  AND
    ...  Log Important Message  </ramUsage>${\n}<ramUsage status="${status2_value}" role="${role2_value}"></ramUsage>  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${noOfCellsInConfiguration_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsInConfiguration  .//ratsStatus
    ${noOfCellsOnAir_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsOnAir  .//ratsStatus
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ratsStatus
    Run keyword if  ${noOfCellsInConfiguration_value}!=${noOfCellsOnAir_value} or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message
    ...  ReportFilePrechek is created wrongly! <ratsStatus noOfCellsInConfiguration="${noOfCellsInConfiguration_value}"  level=WARN
    ...  Log Important Message  noOfCellsOnAir="${noOfCellsOnAir_value}" status="${status_value}" reasoningStatus=""></ratsStatus>  level=WARN
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
    ${sw_parameter_value}  Infomodel Get Active SW Version  module=${module}  im_param=activeSoftwareVersion  alias=${alias}
    Set to dictionary  ${sw_dict}  activeSoftwareVersion  ${sw_parameter_value}
    ${sw_parameter_value}  Infomodel Get Active SW Version  module=${module}  im_param=activeBuildDescriptorId  alias=${alias}
    Set to dictionary  ${sw_dict}  activeBuildDescriptorId  ${sw_parameter_value}
    ${sw_parameter_value}  Infomodel Get Passive SW Version  module=${module}  im_param=passiveSoftwareVersion  alias=${alias}
    Set to dictionary  ${sw_dict}  passiveSoftwareVersion  ${sw_parameter_value}
    ${sw_parameter_value}  Infomodel Get Passive SW Version  module=${module}  im_param=passiveBuildDescriptorId  alias=${alias}
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

Check if ReportFilePrecheck is present
    [Documentation]    Short description.
    ...
    ...    Returns:
    ...        ${is_found}: <description>
    ...        ${ReportFilePrecheck_path}: <description>
    Log  Check if ReportFilePrecheck.xml file is present in /ffs/run/config and delete if present  console=${TRUE}
    Set Connection Parameters  ${SMOD1['TRS_IP']}  user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${status}  ${ReportFilePrecheck_path}  Run keyword and ignore error  Run Remote Linux Command  find /ffs/run/config/ReportFilePrecheck.xml
    ${is_found}  Set variable if  '${status}'=='FAIL'  ${FALSE}  ${TRUE}
    Run keyword if  '${status}'=='FAIL'  Log  ReportFilePrecheck.xml not found in /ffs/run/config/  console=${TRUE}
    ...  ELSE  Log  ReportFilePrecheck.xml found in /ffs/run/config/  console=${TRUE}
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
    ${copy_status}  Run keyword and return status  Run
    ...  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'${ReportFilePrecheck_path}' '${destination_path}'
    Run keyword if  ${copy_status}  Log  ReportFilePrecheck.xml file successfully copied  console=${TRUE}
    ...  ELSE
    ...  Log Important Message  ReportFilePrecheck.xml file not copied  level=WARN

Check if all object exist
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${PRECHECK_OBJECT_LIST}: <description>
    [Arguments]  ${PRECHECK_OBJECT_LIST}
    FOR  ${object}  IN  @{PRECHECK_OBJECT_LIST}
        ${object_exist}  Run keyword and return status  Query Infomodel  /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/${object}
        Run keyword if  ${object_exist}  Log  Object /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/PRECHECK_PROCEDURE_R-*/${object} exists  console=${TRUE}
        ...  ELSE  Run keywords
        ...  Append To List  ${NOT_CREATED_OBJECTS}  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/PRECHECK_PROCEDURE_R-*/${object}
        ...  AND
        ...  Set test variable  ${ALL_OBJECT_EXIST}  ${FALSE}
    END

Custom Test Teardown
    [Documentation]    Short description.
    Step6: recovery blocked cell
    Common Test Teardown
