*** Settings ***
Documentation     [PURPOSE]
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/ca_swm_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_infomodel.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_general.robot
Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/hran_frame_sbts.robot
#Resource    ../../../../../../resources/RAN_PZ_HAZ_1/SISO_OAM/oam_sth_resources/robot

Library    OperatingSystem

#Library    hran_ims
Library     taf.internal.managed.telnet
Library     taf.internal.portforwarding
#Library    hran_tools

Library    taf.sbts.oam.coam.admin
#Library    hran_compa


*** Variables ***
${TARGET_SW_NAME}                   ${None}                        # SW package name. If not given, TC will choose newest package in a directory.
${TARGET_SW_DIR}                    /home/ute/btsauto/TARGET_SW    # Directory in which TC should look for sw package. If not given,
#                                                                   '/home/ute/btsauto/TARGET_SW' shall be used
${PRECHECK_OBJECT_LIST}
...    ACTIVE_CRITICAL_ALARMS_REPORT-1,CONFIGURATION_REPORT-1,CPU_USAGE_REPORT-*,DISK_SPACE_REPORT-1,FLASH_DISK_HEALTH_REPORT-*,RAM_USAGE_REPORT-*,
...     RATS_STATE_REPORT-1,RESET_COVERAGE_REPORT-1,ROLLBACK_READINESS_REPORT-1,SW_DOWNLOAD_REPORT-1
...                  # list of objects that should be created after software precheck procedure
${DC_PRECHECK_OBJECT_LIST}          CPU_USAGE_REPORT-*,DISK_SPACE_REPORT-2,FLASH_DISK_HEALTH_REPORT-*,RAM_USAGE_REPORT-*,ROLLBACK_READINESS_REPORT-2
...                  # list of additional objects that should be created after software precheck procedure in case of Dual Core


*** Keywords ***
TC__SWM__SW_pre_check_successful
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
    Step 2: SW precheck execution
    Step 3: Precheck results validation
    Step 4: ReportFilePrecheck validation

Step 0: Precondition
    [Documentation]    Short description.
    Log Step Header  Step 0: Precondition
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
    ${sw_precheck_start}=  Get current date
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFilePrecheck is present
    Run keyword if  ${ReportFilePrecheck_found}  Delete ReportFilePrecheck file  ${ReportFilePrecheck_path}
    Log  Start software precheck procedure  console=${TRUE}
    ${precheck_status}  Run keyword and return status  taf.sbts.oam.coam.admin.Software Precheck Local
    ...    sw_package=${TARGET_SW_PATH}  precheck_type=FullCheck    timeout=180
    Run keyword if  ${precheck_status}  Log  Software Precheck done successfully  console=${TRUE}
    ...  ELSE  Run keywords
    ...  Fail  Software Precheck failed!
    ...  AND
    ...  Log  Software Precheck failed!  console=${TRUE}
    ${sw_precheck_end}=  Get current date
    set test variable    ${precheck_expected_time}   45
    Operation_KPI_Check    ${sw_precheck_end}    ${sw_precheck_start}    ${precheck_expected_time}    SW_PRECHECK_BTS_KPI

Step 3: Precheck results validation
    [Documentation]    Short description.
    Log Step Header  Step 3: Precheck results validation
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
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //ACTIVE_CRITICAL_ALARMS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  There should be some critical alarms active! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //CONFIGURATION_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CONFIGURATION_REPORT-1
    Run keyword if  '${object['actSwRollbackReject']}'=='False'  Log  Object //CONFIGURATION_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  Rollback operation is permitted! Parameter 'actSwRollbackReject' has value ${object['actSwRollbackReject']}.
    ...    level=WARN
    Log  Check //CPU_USAGE_REPORT-1  console=${TRUE}
    ${object}   run keyword if  ${DUALCORE}==False
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    ...    ELSE     Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-* is [role="Primary"]
#    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-*
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //CPU_USAGE_REPORT-* has correct value  console=${TRUE}
    ...  ELSE  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //CPU_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/CPU_USAGE_REPORT-* is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'  Log  Object //CPU_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Log Important Message  High CPU usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //DISK_SPACE_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/DISK_SPACE_REPORT-1
    ${feedback_status}  Set variable if
    ...    '${object['feedback']}'=='Enough space on active partition' or '${object['feedback']}'=='Enough space on passive partition'
    ...    ${TRUE}  ${FALSE}
    Run keyword if  '${object['status']}'=='Ok' and ${feedback_status}  Log  Object //DISK_SPACE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE  Log Important Message
    ...  No enough space download build! Parameter 'status' has ${object['status']} and 'feedback' value ${object['feedback']}.
    ...  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //DISK_SPACE_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/DISK_SPACE_REPORT-2
    ${feedback_status}  Run keyword if  ${DUALCORE}  Set variable if
    ...    '${object['feedback']}'=='Enough space on active partition' or '${object['feedback']}'=='Enough space on passive partition'
    ...    ${TRUE}  ${FALSE}
    Run keyword if  ${DUALCORE}  Run keyword if
    ...  '${object['status']}'=='Ok' and ${feedback_status}  Log  Object //DISK_SPACE_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...  Log Important Message
    ...  No enough space to download! Parameter 'status' has ${object['status']} and 'feedback' has ${object['feedback']}.     level=WARN
    Log  Check //FLASH_DISK_HEALTH_REPORT-1  console=${TRUE}
    ${object}   run keyword if  ${DUALCORE}==False
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-*
    ...    ELSE
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-* is [role="Primary"]
#    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-*
    Run keyword if  '${object['status']}'=='Ok' or '${object['status']}'=='Unknown'  Log  Object //FLASH_DISK_HEALTH_REPORT-1 has correct value
    ...    console=${TRUE}
    ...  ELSE  Log Important Message  Not health disc! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //FLASH_DISK_HEALTH_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/FLASH_DISK_HEALTH_REPORT-* is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Run keyword if
    ...    '${object['status']}'=='Ok' or '${object['status']}'=='Unknown'  Log  Object //FLASH_DISK_HEALTH_REPORT-4 has correct value
    ...    console=${TRUE}
    ...  ELSE IF  ${DUALCORE}     Log Important Message  Not health disc! Parameter 'status' has value ${object['status']}.  level=WARN
    Log  Check //RAM_USAGE_REPORT-1  console=${TRUE}
    ${object}   run keyword if  ${DUALCORE}==False
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    ...    ELSE   Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-* is [role="Primary"]
#    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-*
    Run keyword if  '${object['status']}'=='Ok'  Log  Object //RAM_USAGE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE     Log Important Message  High RAM usage! Parameter 'status' has value ${object['status']}.  level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //RAM_USAGE_REPORT-4  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RAM_USAGE_REPORT-* is [role="Secondary"]
    Run keyword if  ${DUALCORE}  Run keyword if  '${object['status']}'=='Ok'  Log  Object //RAM_USAGE_REPORT-4 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}
    ...    Log Important Message
    ...    High RAM usage! Parameter 'status' has value ${object['status']}.     level=WARN
    Log  Check //RATS_STATE_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/RATS_STATE_REPORT-1
    set test variable     ${warning1}   Not all cells are onAir! Parameter 'noOfCellsInConfiguration' (value:${object['noOfCellsInConfiguration']})
    set test variable     ${warning2}    is not equal to parameter 'noOfCellsOnAir' (value: ${object['noOfCellsOnAir']}).
    ${warining3}     Catenate      ${warning1}     ${warning2}
    Run keyword if  '${object['status']}'=='Ok' and '${object['noOfCellsInConfiguration']}'=='${object['noOfCellsOnAir']}'
    ...    Log  Object //RATS_STATE_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['status']}'!='Ok'  Log Important Message  Not all cells are onAir! Parameter 'status' has value ${object['status']}.
    ...    level=WARN
    ...  ELSE IF  '${object['noOfCellsInConfiguration']}'!='${object['noOfCellsOnAir']}'
    ...  Log Important Message     ${warining3}      level=WARN
    Log  Check //ROLLBACK_READINESS_REPORT-1  console=${TRUE}
    ${object}  Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-1
    ${boolean_1}=    Evaluate
    ...    '${object['allConnectedHwCompatible']}'=='True'
    ${boolean_2}=    Evaluate  '${object['activeVersion']}'=='${SW_VERSIONS[0].activeSoftwareVersion}'
    Run keyword if
    ...   ${boolean_1} and ${boolean_2} and '${object['passiveVersion']}'=='${SW_VERSIONS[0].passiveSoftwareVersion}'
    ...  Log  Object //ROLLBACK_READINESS_REPORT-1 has correct value  console=${TRUE}
    ...  ELSE IF  '${object['allConnectedHwCompatible']}'=='False'  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.    level=WARN
    ...  ELSE  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.    level=WARN
    Run keyword if  ${DUALCORE}  Log  Check //ROLLBACK_READINESS_REPORT-2  console=${TRUE}
    ${object}  Run keyword if  ${DUALCORE}
    ...    Query Infomodel  get object /MRBTS-*/RAT-*/RUNTIME_VIEW-*/MRBTS_R-*/PRECHECK_PROCEDURE_R-*/ROLLBACK_READINESS_REPORT-2
    ${boolean_1}=    Run keyword if  ${DUALCORE}    Evaluate
    ...    '${object['allConnectedHwCompatible']}'=='True' and '${object['activeVersion']}'=='${SW_VERSIONS[0].activeSoftwareVersion}'
    ${boolean_2}=    Run keyword if  ${DUALCORE}    Evaluate  '${object['passiveVersion']}'=='${SW_VERSIONS[0].passiveSoftwareVersion}'
    Run keyword if  ${DUALCORE}  Run keyword if
    ...   ${boolean_1} and ${boolean_2}
    ...  Log  Object //ROLLBACK_READINESS_REPORT-2 has correct value  console=${TRUE}
    ...  ELSE IF  ${DUALCORE}  Run keyword if  '${object['allConnectedHwCompatible']}'=='False'  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'allConnectedHwCompatible' has value ${object['allConnectedHwCompatible']}.     level=WARN
    ...  ELSE IF  ${DUALCORE}  Log Important Message
    ...  Discrepancy in rollback_readiness_check! Parameter 'activeVersion' or 'passiveVersion' are different than SW versions on BTS.     level=WARN

Step 4: ReportFilePrecheck validation
    [Documentation]    Short description.
    Log Step Header  Step 4: ReportFilePrecheck validation
    ${ReportFilePrecheck_found}  ${ReportFilePrecheck_path}  Check if ReportFilePrecheck is present
    ${ReportFilePrecheck_path}  Get line  ${ReportFilePrecheck_path}  0
    Run keyword if  ${ReportFilePrecheck_found}==${FALSE}  Run keywords  Log  File ReportFilePrecheck.xml not created!  console=${TRUE}
    ...  AND  Fail  File ReportFilePrecheck.xml not created!
    ...  ELSE  Copy ReportFilePrecheck file  ${ReportFilePrecheck_path}  ${BTSFiles}/ReportFilePrecheck.xml
    ${xml_file}  Set variable  ${BTSFiles}/ReportFilePrecheck.xml
    Log  Validate ReportFilePrecheck.xml file  console=${TRUE}
    Run keyword if  ${DUALCORE}  Validate xml objects for DualCore  ${xml_file}
    ...  ELSE  Validate xml objects for SingleCore  ${xml_file}

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
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! Not all objects are created!     level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  ${cpuUsage_quantity}!=1 or ${ramUsage_quantity}!=1 or ${ratsStatus_quantity}!=1
    ...  Run keywords
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! The quantity of one of the objects is greater than 1!    level=WARN
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
    set test variable    ${log_maeesae_1}
    ...    ReportFilePrechek is created wrongly! <ratsStatus noOfCellsInConfiguration="${noOfCellsInConfiguration_value}"
    set test variable      ${log_maeesae_2}
    ...    noOfCellsOnAir="${noOfCellsOnAir_value}" status="${status_value}" reasoningStatus=""></ratsStatus>
    ${log_maeesae_3}=     Catenate     SEPARATOR=      ${log_maeesae_1}      ${log_maeesae_2}
    Run keyword if  ${noOfCellsInConfiguration_value}!=${noOfCellsOnAir_value} or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message     ${log_maeesae_3}      level=WARN
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
    ...  Log Important Message  ReportFilePrechek has been created incorrectly! Not all objects are created!  level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    Run keyword if  ${cpuUsage_quantity}!=2 or ${ramUsage_quantity}!=2 or ${ratsStatus_quantity}!=1
    ...  Run keywords
    ...  Log Important Message
    ...    ReportFilePrechek has been created incorrectly! The quantity of one of the objects is different than should be!  level=WARN
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
    set test variable      ${log_maeesae_1}     ReportFilePrechek is created wrongly!${\n}<cpuUsage status="${status1_value}"role="${role1_value}">
    set test variable      ${log_maeesae_2}     </cpuUsage>${\n}<cpuUsage status="${status2_value}" role="${role2_value}"></cpuUsage>
    ${log_maeesae_3}=     Catenate     SEPARATOR=      ${log_maeesae_1}      ${log_maeesae_2}
    Run keyword if  not ${role_status} or not ${status_status}
    ...  Run keywords
    ...  Log Important Message     ${log_maeesae_3}     level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${ramUsage_objects}  XML.Get Elements  ${xml_file}  .//ramUsage
    ${role1_value}  XML.Get Element Attribute  ${ramUsage_objects[0]}  role
    ${role2_value}  XML.Get Element Attribute  ${ramUsage_objects[1]}  role
    ${status1_value}  XML.Get Element Attribute  ${ramUsage_objects[0]}  status
    ${status2_value}  XML.Get Element Attribute  ${ramUsage_objects[1]}  status
    ${boolean_1}=    Evaluate  '${role1_value}'=='Primary' and '${role2_value}'=='Secondary'
    ${boolean_2}=    Evaluate  '${role1_value}'=='Secondary' and '${role2_value}'=='Primary'
    ${role_status}  Evaluate   ${boolean_1} or ${boolean_2}
    ${status_status}  Set variable if  '${status1_value}'=='OK' and '${status2_value}'=='OK'  ${TRUE}  ${FALSE}
    set test variable      ${log_maeesae_1}     ReportFilePrechek is created wrongly!${\n}<ramUsage status="${status1_value}"
    set test variable      ${log_maeesae_2}
    ...    role="${role1_value}"></ramUsage>${\n}<ramUsage status="${status2_value}" role="${role2_value}"></ramUsage>
    ${log_maeesae_3}=     Catenate     SEPARATOR=      ${log_maeesae_1}      ${log_maeesae_2}
    Run keyword if  not ${role_status} or not ${status_status}
    ...  Run keywords
    ...  Log Important Message   ${log_maeesae_3}     level=WARN
    ...  AND
    ...  Set test variable  ${WARNINGS}  ${TRUE}
    ${noOfCellsInConfiguration_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsInConfiguration  .//ratsStatus
    ${noOfCellsOnAir_value}  XML.Get Element Attribute  ${xml_file}  noOfCellsOnAir  .//ratsStatus
    ${status_value}  XML.Get Element Attribute  ${xml_file}  status  .//ratsStatus
    set test variable    ${log_maeesae_1}
    ...    ReportFilePrechek is created wrongly! <ratsStatus noOfCellsInConfiguration="${noOfCellsInConfiguration_value}"
    set test variable    ${log_maeesae_2}
    ...    noOfCellsOnAir="${noOfCellsOnAir_value}" status="${status_value}" reasoningStatus=""></ratsStatus>
    ${log_maeesae_3}=     Catenate     SEPARATOR=      ${log_maeesae_1}      ${log_maeesae_2}
    Run keyword if  ${noOfCellsInConfiguration_value}!=${noOfCellsOnAir_value} or '${status_value}'!='OK'
    ...  Run keywords
    ...  Log Important Message     ${log_maeesae_3}      level=WARN
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
    ${copy_status}  Run keyword and return status
    ...    Run  sshpass -p ${SMOD1['PASSWORD']} scp ${SMOD1['USERNAME']}@${SMOD1['TRS_IP']}:'${ReportFilePrecheck_path}' '${destination_path}'
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

Check if all cells onAir
    [Documentation]    Short description.
    Log Step Header  Check if all cells onAir
    Log  Will now wait for all cells to be online. Will check every 10 seconds.  level=INFO  console=${TRUE}
    FOR  ${run}  IN RANGE  1  420
        ${all_cell_status}  ${cell_state_table}  Infomodel Check If All Objects From Path Are Online  ${dist_cells}
        Run keyword if  ${all_cell_status} == ${True}  Run Keywords
        ...  Log  All cells online! Check attempt: ${run}  console=${TRUE}
        ...  AND  Exit For Loop
        Sleep  10
    END
    ${all_cells_onair}=  Get current date
    Run keyword if    ${Make Additional Checks}    Ensure that BTS remains OnAir
    Set test variable  ${all_cells_onair}
    #Log table  ${cell_state_table}
    ${MPLANE_IP}=  Admin Get MPLANE IP
    ${status}=  Run keyword and return status  Admin Check mplane connection  ${MPLANE_IP}
    Run keyword if    not ${status}  Set Test Restriction  Check mplane connection to admin failed!

Ensure that BTS remains OnAir
    [Documentation]    Short description.
    Log   BTS will be checked ${Additional Checks Number} times with interval ${Sleep interval} if it remains onAir
    ...   console=${TRUE}
    FOR  ${i}  IN RANGE  ${Additional Checks Number}
        ${is_onAir}=    Verify states
        Log    BTS is onAir    console=${TRUE}
        Sleep   ${Sleep interval}
    END

Verify states
    [Documentation]    Short description.
    ${status}  ${system_modules_working}=   Run Keyword And Ignore Error    Verify system modules states
    ${status}  ${radio_modules_working}=    Run Keyword And Ignore Error    Verify radio modules states
    Run keyword if    not ${system_modules_working} and ${radio_modules_working}    Fail
    ...    msg=At least one module has state other than expected

    ${status}  ${cells_GSM_onair}=          Run Keyword And Ignore Error    Verify GSM cells states
    ${status}  ${cells_WCDMA_onair}=        Run Keyword And Ignore Error    Verify WCDMA cells states
    ${status}  ${cells_LTE_onair}=          Run Keyword And Ignore Error    Verify LTE cells states
    Run keyword if    not ${cells_GSM_onair} and ${cells_WCDMA_onair} and ${cells_LTE_onair}    Fail
    ...    msg=At least one cell has state other than expected

    ${IGNORED_ALARMS}=      Create Dictionary  severity=Minor
    ${CRITICAL_ALARMS1}=    Create Dictionary  severity=Major
    ${CRITICAL_ALARMS2}=    Create Dictionary  severity=Critical
    ${IGNORED_PATTERNS}=    Create List  ${IGNORED_ALARMS}
    ${CRITICAL_PATTERNS}=   Create List  ${CRITICAL_ALARMS1}   ${CRITICAL_ALARMS2}
    ${alarms_status}  ${alarms_msg}=    Run Keyword And Ignore Error    Admin Check Active Alarms
    ...  ignored_patterns=${IGNORED_PATTERNS}  critical_patterns=${CRITICAL_PATTERNS}
    Run keyword if    not '${alarms_status}'=='PASS'    Fail    msg=Major alarm found.
