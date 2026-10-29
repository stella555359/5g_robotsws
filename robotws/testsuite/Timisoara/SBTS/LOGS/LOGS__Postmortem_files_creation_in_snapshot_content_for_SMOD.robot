*** Settings ***
Resource    ../resources/pm_logs_general.robot
Resource    ../resources/pm_logs_frame.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/infomodel.robot
Library    hran_file_operations
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${SNAPSHOT_FILE_PATH}       /tmp/uri/DIAGN_FILES/   # Path to snapshot file stored on SBTS
${STARTUP_TIMEOUT}          10                      # Timeout for BTS to startup after reset, default value 10 min
${SNAPSHOT_TIMEOUT}         2400                     # Timeout for collect snapshot via Admin (in sec)


*** Keywords ***
TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5970
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this TC is to verify presence of postmortem log files in case BTS reset occurred.
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  2017-09-27     TAT-7397  Snapshot file is no longer stored on BTS
    ...  2017-09-29     TAT-7838  Change postmortem files validation due to AirScale naming convention
    ...  2017-12-04     TAT-8483  LOGS__Postmortem_files_creation_in_snapshot_content - Timeout for rising cells after Site Reset is too short
    ...  2017-12-14     TAT-8402  TC: "LOGS__Postmortem_files_creation_in_snapshot_content" need to be changed
    ...  2018-01-09     TAT-7809  Replace references to LNBTS with MRBTS in SBTS17 TCs
    ...  2018-01-09     TAT-7596  Migration from ute_infomodel to ADMIN Abstraction Layer
    ...  2018-01-10     TAT-8837  Changes in TCs related to responsibilities handover
    ...  2018-06-06     TAT-10398 - Increase Timeout for ute_admin.Collect Snapshot to 600 sec
    ...  2018-07-17     TAT-10897 - Set test failed in step 2
    ...  2018-08-13     TAT-10655 - Added support for 2xFSMF and DualCore
    ...  2018-11-07     TAT-12753 - Symlink this TC to SBTS18/CI
    ...  2019-03-27     TAT-13783 - Support for rmod5.1
    ...  2019-03-27     TAT-15493 - Add input parameter ${SNAPSHOT_TIMEOUT}
    ...  2019-04-11     TAT-15746 - Support for SMOD ASIB
    ...  2019-05-22     TAT-16256 - Change MAINTAINER and GROUP_IN_CHARGE
    ...  2019-06-13     TAT-16497 - Moved .+_1011_pmGeneration\.log\.xz$ to not mandatory files section
    ...  2021-07-07     TAT-21540 - Test case modified to support new SMOD - ASIL
    ...  2021-12-22     TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  2022-07-19     https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Postmortem_files_creation_in_snapshot_content.png#


    Set Tags    CA-SWM    OWNER-lukasz.targonski@nokia.com    AUTHOR-joanna.bielawska@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    GROUP_IN_CHARGE-WRO_6_Vrf    PHASE-CIT    SW-SBTS17    SW-SBTS18
    ...    SW-SBTS19    FEATURE-RP001145_RP000933    FEATURE-RP001486_RP000933

    Step 1: Site reset
    Step 2: Snapshot collection
    Step 3: Verify snapshot content


Step 1: Site reset
    Log  Step 1: Site reset  console=yes
    coam.Reset Site  600
    Sleep  5s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  pm_logs_general.Check All Modules And All Cells Working States
    Log  All cells and modules reached working state  console=yes
    bts_states.Check Active Alarms

Step 2: Snapshot collection
    Log  Step 2: Start snapshot collection  console=yes
    ${timestamp}=  Get time
    ${timestamp}=  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}  ${_}=  Run Keyword And Ignore Error
    ...  coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${collect_snapshot_status}' == 'PASS'
    ...     Set global variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
    ...     ELSE  verdicts.Set Test Failed  Collecting snapshot via Admin failed.  ${TRUE}

Step 3: Verify snapshot content
    Log  Step 3: Verify snapshot content  console=yes
    Log  Get number of commissioned System modules and Radio modules serial number list  console=yes
    ${smod}=  Get SMOD count
    ${rmod_serial}  ${rmod_5_1_serial}=  Get RMOD serial number list

    ${sm_variant}=  Get SMOD variant
    ${sm_variant}=  Set variable  ${sm_variant[0]}
    ${mandatory_files_patterns}=  Run keyword if  '${sm_variant}'=='FSMF'  Create pm files dict rel3  ${smod}  ${rmod_serial}
    ...     ELSE IF  '${sm_variant}'=='ASIA' or '${sm_variant}'=='ASIB' or '${sm_variant}'=='ASIL' or '${sm_variant}'=='ASIM'
    ...     Differentiate rel4 configuration  ${smod}  ${rmod_serial}  ${rmod_5_1_serial}
    ...     ELSE  verdicts.Set Test Failed  Unexpected variant of SM found!  ${TRUE}

    ${found_file_dict}  snapshot.Get Data From Snapshot  ${path_to_snapshot}
    snapshot.Validate snapshot using custom data  ${found_file_dict}  ${mandatory_files_patterns}

Get SMOD variant
 	[Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave.
    ...  KW moved from hran_infomodel.robot and modified to support newer SMOD types(ASIL)
    ...
	${sm_variant}=  Create list
	${sm_variant_list}=  infomodel.Get SM variant with full name
	FOR  ${sm}  IN  @{sm_variant_list}
	    ${match}  ${group}=  Should match regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB|ASIL|ASIM)
	    Append To List  ${sm_variant}  ${match}
	END
	[Return]  ${sm_variant}

Get SMOD count
    [Documentation]
    ...     This keyword uses Admin API to check how many System Modules are
    ...     commissioned on SBTS and returns that value.

    ${smod_objects}=  coam.Get parameters for all  SMOD
    ${nr_of_smod_objects}=  Get length  ${smod_objects}
    [Return]  ${nr_of_smod_objects}

Get RMOD serial number list
    [Documentation]
    ...     This keyword uses Admin API to check what are serial numbers of
    ...     commissioned Radio Modules and returns list of those numbers

    ${rmod_5_1_serial_num_list}=  Create List
    ${rmod_serial_num_list}=  Create List
    ${rmod_objects}=  coam.Get parameters for all  RMOD
    FOR    ${rmod_object}    IN    @{rmod_objects}
        ${serialNum_of_rmod_object}=  Get From Dictionary  ${rmod_object}  serialNumber
        ${product_name}=  set variable  ${rmod_object['productName']}
        ${status}=        evaluate      '${product_name}'.startswith('A')
        Run Keyword If  ${status}  Append To List  ${rmod_5_1_serial_num_list}  ${serialNum_of_rmod_object}
        ...  ELSE  Append To List  ${rmod_serial_num_list}  ${serialNum_of_rmod_object}
    END
    [Return]  ${rmod_serial_num_list}  ${rmod_5_1_serial_num_list}

Create pm files dict rel3
    [Documentation]
    ...     Gets number of configured system and radio modules serial numbers and creates two dictionaries:
    ...     first contains regex patterns for mandatory files checking;
    ...     second - for additional files.
    ...     KW is applicable for SM rel3 (FSMF).

    [Arguments]  ${smod_counter}  ${rmod_serial}

    ${mandatory_patterns}=  Create list
    ${additional_patterns}=  Create list  .+_1011_pmGeneration\.log\.xz$

    # add SMOD related postmortem files to pm_patterns list
    ${smod_nr}=  Convert to integer  ${smod_counter}
    ${max}=  Evaluate  ${smod_nr} + 1
    FOR  ${item}  IN RANGE  1  ${max}
        ${temp}=  Catenate  SEPARATOR=  .+_  ${item}  011_pm_1_syslog\.zip$
        Append to list  ${mandatory_patterns}  ${temp}
    END

    FOR  ${item}  IN RANGE  1  ${max}
        ${temp}=  Catenate  SEPARATOR=  .+_  ${item}  011_pm_2_syslog\.zip$
        Append to list  ${additional_patterns}  ${temp}
    END

    # add RF related postmortem files to pm_patterns list
    FOR  ${item}  IN  @{rmod_serial}
        ${temp}=  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}    .+_ram_pm_1_system\.log\.gz$
        Append to list  ${mandatory_patterns}  ${temp}
    END

    &{pm_files_dict}=  Create dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${additional_patterns}

    [Return]  &{pm_files_dict}

Differentiate rel4 configuration
    [Arguments]  ${smod_counter}  ${rmod_serial}  ${rmod_5_1_serial}

    ${files_patterns}=  Run keyword if  '${smod_counter}'=='1'
    ...  Create pm files for single AirScale  ${smod_counter}  ${rmod_serial}  ${rmod_5_1_serial}
    ...  ELSE IF  '${smod_counter}'=='2'  Create pm files for AirScale dualcore  ${smod_counter}  ${rmod_serial}
    ...  ELSE  verdicts.Set Test Restriction  Unsupported number of modules.

    [Return]  ${files_patterns}

Create pm files for single AirScale
    [Documentation]
    ...     Gets number of configured ASIA or ASIB and RMOD modules serial numbers and creates two dictionaries:
    ...     first contains regex patterns for mandatory files checking;
    ...     second - for additional files.
    ...     KW is applicable for single SM rel4 (ASIA, ASIB).

    [Arguments]  ${smod_counter}  ${rmod_serial}  ${rmod_5_1_serial}

    ${sm_position}=  coam.Get SMOD position
    ${sm_position}=  Run keyword if  '${sm_position}'=='left'  Set variable  1
    ...     ELSE IF  '${sm_position}'=='right'  Set variable  2

    # ASIA (ASIB) SMOD 1 contains 4 node IDs:
    # 1011 - MCU
    # 1015, 1016 - CP Node - CellC/UeC
    # 1018 - ETH Node

    ${smod_node_ids}=  Create list  15  16  18
    ${mandatory_patterns}=  Create list
    ${non_mandatory_patterns}=  Create list

    # add ASIA (ASIB) related postmortem files
    ${temp}=  Catenate  SEPARATOR=  .+_  ${sm_position}  011_pm_1_syslog\.zip$
    Append to list  ${mandatory_patterns}  ${temp}

    FOR  ${item}  IN  @{smod_node_ids}
        ${temp1}=  Catenate  SEPARATOR=  .+_  ${sm_position}  0  ${item}  _pmGeneration\.log\.xz$
        ${temp2}=  Catenate  SEPARATOR=  .+_  ${sm_position}  0  ${item}  _pm_2_syslog\.zip$
        ${temp3}=  Catenate  SEPARATOR=  .+_  ${sm_position}  0  ${item}  _pm_1_syslog\.zip$
        Append to list  ${non_mandatory_patterns}  ${temp1}  ${temp2}  ${temp3}
    END

    ${temp1}=  Catenate  SEPARATOR=  .+_  ${sm_position}  011_pmGeneration\.log\.xz$
    ${temp2}=  Catenate  SEPARATOR=  .+_  ${sm_position}  011_pm_2_syslog\.zip$
    Append to list  ${non_mandatory_patterns}  ${temp1}  ${temp2}

    # add RF related postmortem files to pm_patterns list
    FOR  ${item}  IN  @{rmod_serial}
        ${temp}=  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}    .+_ram_pm_1_system\.log\.gz$
        Append to list  ${mandatory_patterns}  ${temp}
    END
    FOR  ${item}  IN  @{rmod_5_1_serial}
        ${temp}=  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}    .+_pm_1_syslog\.zip$
        Append to list  ${non_mandatory_patterns}  ${temp}
    END

    &{pm_files_dict}=  Create dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${non_mandatory_patterns}

    [Return]  &{pm_files_dict}

Create pm files for AirScale dualcore
    [Documentation]
    ...     Gets number of configured ASIA (ASIB) and RMOD modules serial numbers and creates two dictionaries:
    ...     first contains regex patterns for mandatory files checking;
    ...     second - for additional files.
    ...     KW is applicable for rel4 dualcore (4+4).

    [Arguments]  ${smod_counter}  ${rmod_serial}

    # ASIA (ASIB) SMOD contains 4 node IDs:
    # 1011 - MCU
    # 1015, 1016 - CP Node - CellC/UeC
    # 1018 - ETH Node

    ${smod_node_id_suffixes}=  Create list  15  16  18
    ${mandatory_patterns}=  Create list
    ${non_mandatory_patterns}=  Create list

    # add ASIA (ASIB) related postmortem files
    ${smod_nr}=  convert to string  ${smod_counter}
    ${max_sm_nr}=  Evaluate  ${smod_nr}
    FOR  ${nr}  IN RANGE  1  ${max_sm_nr}
        ${temp1}=  Catenate  SEPARATOR=  .+_  ${nr}  011_pm_1_syslog\.zip$
        Append to list  ${mandatory_patterns}  ${temp1}
        ${temp2}=  Catenate  SEPARATOR=  .+_  ${nr}  011_pmGeneration\.log\.xz$
        ${temp3}=  Catenate  SEPARATOR=  .+_  ${nr}  011_pm_2_syslog\.zip$
        Append to list  ${non_mandatory_patterns}  ${temp2}  ${temp3}
    END

    FOR  ${item}  IN  @{smod_node_id_suffixes}
        ${temp1}=  Catenate  SEPARATOR=  .+_1  0  ${item}  _pmGeneration\.log\.xz$
        ${temp2}=  Catenate  SEPARATOR=  .+_1  0  ${item}  _pm_2_syslog\.zip$
        ${temp3}=  Catenate  SEPARATOR=  .+_1  0  ${item}  _pm_1_syslog\.zip$
        Append to list  ${non_mandatory_patterns}  ${temp1}  ${temp2}  ${temp3}
    END

    # add RF related postmortem files to pm_patterns list
    FOR  ${item}  IN  @{rmod_serial}
        ${temp}=  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}    .+_ram_pm_1_system\.log\.gz$
        Append to list  ${mandatory_patterns}  ${temp}
    END

    &{pm_files_dict}=  Create dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${non_mandatory_patterns}

    [Return]  &{pm_files_dict}


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown  collect_snapshot=never


