*** Settings ***
Documentation
    ...  Purpose of this TC is to verify presence of postmortem log files in case BTS reset occurred.

Resource  ../../common_resources/ca_CIT_general.robot


*** Variables ***
${SNAPSHOT_FILE_PATH}  /tmp/uri/DIAGN_FILES/  # Path to snapshot file stored on SBTS
${STARTUP_TIMEOUT}  10  # Timeout for BTS to startup after reset, default value 10 min
${SNAPSHOT_TIMEOUT}  600  # Timeout for collect snapshot via Admin (in sec)


*** Keywords ***
TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_SMOD
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-5970
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
    ...  2024-01-19     TAT-26771 - Add watchdog alarm monitoring
    ...  2024-05-15     TAT-27193 - Test was modified to search for all files with *011_pm
    ...  2024-09-19     TAT-27904 - Test was modified to run with ASOG AirScale config
    ...  2024-04-10     TAT-28043 - Test was modified to run with ASIK AirScale config
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  http://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/LOGS__Postmortem_files_creation_in_snapshot_content.png#

    Set Tags  CA-SWM  OWNER-lukasz.targonski@nokia.com  AUTHOR-joanna.bielawska@nokia.com  MAINTAINER-iasmin.tomici@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001145_RP000933  FEATURE-RP001486_RP000933

    Step 1: Site Reset
    Step 2: Snapshot Collection
    Step 3: Verify Snapshot Content


Step 1: Site Reset
    Log  Step 1: Site reset  console=true
    Reset Site  600
    Sleep  5s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  2m
    ...  Admin Check All Required State
    Log  All cells and modules reached working state  console=true
    Admin Check Active Alarms TAF


Step 2: Snapshot Collection
    Log  Step 2: Start snapshot collection  console=true
    ${timestamp}  Get Time
    ${timestamp}  Replace String Using Regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}  ${_}  Run Keyword And Ignore Error
    ...  Collect Snapshot  ${BTS_FILES}/snapshot_${timestamp}.zip  timeout=${SNAPSHOT_TIMEOUT}
    Run Keyword If  '${collect_snapshot_status}' == 'PASS'
    ...  Set Global Variable  ${PATH_TO_SNAPSHOT}  ${BTS_FILES}/snapshot_${timestamp}.zip
    ...  ELSE
    ...  Set Test Failed  Collecting snapshot via Admin failed  fail_fast=True


Step 3: Verify Snapshot Content
    Log  Step 3: Verify snapshot content  console=true
    Log  Get number of commissioned System modules and Radio modules serial number list  console=true
    ${smod}  Get SMOD Count
    ${rmod_serial}  ${rmod_5_1_serial}  Get RMOD Serial Number List

    ${sm_variant}  Get SMOD Variant
    ${sm_variant}  Set Variable  ${sm_variant[0]}
    ${mandatory_files_patterns}  Run Keyword If  '${sm_variant}'=='FSMF'
    ...  Create Pm Files Dict Rel3  ${smod}  ${rmod_serial}
    ...  ELSE IF  '${sm_variant}'=='ASIA' or '${sm_variant}'=='ASIB' or '${sm_variant}'=='ASIL' or '${sm_variant}'=='ASOG' or '${sm_variant}'=='ASIK'
    ...  Differentiate Rel4 Configuration  ${smod}  ${rmod_serial}  ${rmod_5_1_serial}
    ...  ELSE
    ...  Set Test Restriction  Unexpected variant of SM found!

    ${found_file_dict}  Get Data From Snapshot  ${PATH_TO_SNAPSHOT}
    snapshot.Validate Snapshot Using Custom Data  ${found_file_dict}  ${mandatory_files_patterns}


Get SMOD Variant
    [Documentation]
    ...  Return list of System Module variants in use. First is master second (if exist) slave.
    ...  KW moved from hran_infomodel.robot and modified to support newer SMOD types(ASIL)

    ${sm_variant}  Create List
    ${sm_variant_list}  Get SM Variant With Full Name
    FOR  ${sm}  IN  @{sm_variant_list}
        ${match}  ${group}  Should Match Regexp  ${sm}  (FSMF|FSIH|ASIA|ASIB|ASIAB|ASIL|ASOG|ASIK)
        Append To List  ${sm_variant}  ${match}
    END

    [Return]  ${sm_variant}


Get SMOD Count
    [Documentation]
    ...   This keyword uses Admin API to check how many System Modules are
    ...   commissioned on SBTS and returns that value.

    ${smod_objects}  Get Parameters For All  SMOD
    ${nr_of_smod_objects}  Get Length  ${smod_objects}

    [Return]  ${nr_of_smod_objects}


Get RMOD Serial Number List
    [Documentation]
    ...   This keyword uses Admin API to check what are serial numbers of
    ...   commissioned Radio Modules and returns list of those numbers

    ${rmod_5_1_serial_num_list}  Create List
    ${rmod_serial_num_list}  Create List
    ${rmod_objects}  Get Parameters For All  RMOD
    FOR  ${rmod_object}  IN  @{rmod_objects}
        ${serial_num_of_rmod_object}  Get From Dictionary  ${rmod_object}  serialNumber
        ${product_name}  Set Variable  ${rmod_object['productName']}
        ${status}  Evaluate  '${product_name}'.startswith('A')
        Run Keyword If  ${status}
        ...  Append To List  ${rmod_5_1_serial_num_list}  ${serial_num_of_rmod_object}
        ...  ELSE
        ...  Append To List  ${rmod_serial_num_list}  ${serial_num_of_rmod_object}
    END

    [Return]  ${rmod_serial_num_list}  ${rmod_5_1_serial_num_list}


Create Pm Files Dict Rel3
    [Documentation]
    ...   Gets number of configured system and radio modules serial numbers and creates two dictionaries:
    ...   first contains regex patterns for mandatory files checking;
    ...   second - for additional files.
    ...   KW is applicable for SM rel3 (FSMF).
    [Arguments]  ${smod_counter}  ${rmod_serial}

    ${mandatory_patterns}  Create List
    ${additional_patterns}  Create List  .+_1011_pmGeneration\.log\.xz$
    ${temp}  Catenate  SEPARATOR=  .+_  *011_pm_1_syslog\.zip$
    Append To List  ${mandatory_patterns}  ${temp}
    ${smod_nr}  Convert To Integer  ${smod_counter}
    ${max}  Evaluate  ${smod_nr} + 1
    FOR  ${item}  IN RANGE  1  ${max}
        ${temp}  Catenate  SEPARATOR=  .+_  ${item}  011_pm_2_syslog\.zip$
        Append To List  ${additional_patterns}  ${temp}
    END

    # add RF related postmortem files to pm_patterns list
    FOR  ${item}  IN  @{rmod_serial}
        ${temp}  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}  .+_ram_pm_1_system\.log\.gz$
        Append To List  ${mandatory_patterns}  ${temp}
    END

    &{pm_files_dict}  Create Dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${additional_patterns}

    [Return]  &{pm_files_dict}


Differentiate Rel4 Configuration
    [Arguments]  ${smod_counter}  ${rmod_serial}  ${rmod_5_1_serial}

    ${files_patterns}  Run Keyword If  '${smod_counter}'=='1'
    ...  Create Pm Files For Single AirScale  ${rmod_serial}  ${rmod_5_1_serial}
    ...  ELSE IF  '${smod_counter}'=='2'
    ...  Create Pm Files For AirScale Dualcore  ${smod_counter}  ${rmod_serial}
    ...  ELSE
    ...  Set Test Restriction  Unsupported number of modules.

    [Return]  ${files_patterns}


Create Pm Files For Single AirScale
    [Documentation]
    ...   Gets number of configured ASIA or ASIB and RMOD modules serial numbers and creates two dictionaries:
    ...   first contains regex patterns for mandatory files checking;
    ...   second - for additional files.
    ...   KW is applicable for single SM rel4 (ASIA, ASIB).
    [Arguments]  ${rmod_serial}  ${rmod_5_1_serial}

    ${sm_position}  Get SMOD Position
    ${sm_position}  Run Keyword If  '${sm_position}'=='left'
    ...  Set Variable  1
    ...  ELSE IF  '${sm_position}'=='right'
    ...  Set Variable  2

    # ASIA (ASIB) SMOD 1 contains 4 node IDs:
    # 1011 - MCU
    # 1015, 1016 - CP Node - CellC/UeC
    # 1018 - ETH Node

    ${smod_node_ids}  Create List  15  16  18
    ${mandatory_patterns}  Create List
    ${non_mandatory_patterns}  Create List

    # add ASIA (ASIB) related postmortem files
    ${temp}  Catenate  SEPARATOR=  .+_  *011_pm_1_syslog\.zip$
    Append To List  ${mandatory_patterns}  ${temp}

    FOR  ${item}  IN  @{smod_node_ids}
        ${temp1}  Catenate  SEPARATOR=  .+_  *0  ${item}  _pmGeneration\.log\.xz$
        ${temp2}  Catenate  SEPARATOR=  .+_  *0  ${item}  _pm_2_syslog\.zip$
        ${temp3}  Catenate  SEPARATOR=  .+_  *0  ${item}  _pm_1_syslog\.zip$
        Append To List  ${non_mandatory_patterns}  ${temp1}  ${temp2}  ${temp3}
    END

    ${temp1}  Catenate  SEPARATOR=  .+_  *011_pmGeneration\.log\.xz$
    ${temp2}  Catenate  SEPARATOR=  .+_  *011_pm_2_syslog\.zip$
    Append To List  ${non_mandatory_patterns}  ${temp1}  ${temp2}

    # add RF related postmortem files to pm_patterns list
    FOR  ${item}  IN  @{rmod_serial}
        ${temp}  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}  .+_ram_pm_1_system\.log\.gz$
        Append To List  ${mandatory_patterns}  ${temp}
    END
    FOR  ${item}  IN  @{rmod_5_1_serial}
        ${temp}  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}  .+_pm_1_syslog\.zip$
        Append To List  ${non_mandatory_patterns}  ${temp}
    END

    &{pm_files_dict}  Create Dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${non_mandatory_patterns}

    [Return]  &{pm_files_dict}


Create Pm Files For AirScale Dualcore
    [Documentation]
    ...   Gets number of configured ASIA (ASIB) and RMOD modules serial numbers and creates two dictionaries:
    ...   first contains regex patterns for mandatory files checking;
    ...   second - for additional files.
    ...   KW is applicable for rel4 dualcore (4+4).
    [Arguments]  ${smod_counter}  ${rmod_serial}

    # ASIA (ASIB) SMOD contains 4 node IDs:
    # 1011 - MCU
    # 1015, 1016 - CP Node - CellC/UeC
    # 1018 - ETH Node

    ${smod_node_id_suffixes}  Create List  15  16  18
    ${mandatory_patterns}  Create List
    ${non_mandatory_patterns}  Create List

    # add ASIA (ASIB) related postmortem files
    ${smod_nr}  Convert To String  ${smod_counter}
    ${max_sm_nr}  Evaluate  ${smod_nr}
    ${temp1}  Catenate  SEPARATOR=  .+_  *011_pm_1_syslog\.zip$
    Append To List  ${mandatory_patterns}  ${temp1}
    FOR  ${nr}  IN RANGE  1  ${max_sm_nr}
        ${temp2}  Catenate  SEPARATOR=  .+_  ${nr}  011_pmGeneration\.log\.xz$
        ${temp3}  Catenate  SEPARATOR=  .+_  ${nr}  011_pm_2_syslog\.zip$
        Append To List  ${non_mandatory_patterns}  ${temp2}  ${temp3}
    END

    FOR  ${item}  IN  @{smod_node_id_suffixes}
        ${temp1}  Catenate  SEPARATOR=  .+_1  0  ${item}  _pmGeneration\.log\.xz$
        ${temp2}  Catenate  SEPARATOR=  .+_1  0  ${item}  _pm_2_syslog\.zip$
        ${temp3}  Catenate  SEPARATOR=  .+_1  0  ${item}  _pm_1_syslog\.zip$
        Append To List  ${non_mandatory_patterns}  ${temp1}  ${temp2}  ${temp3}
    END

    # add RF related postmortem files to pm_patterns list
    FOR  ${item}  IN  @{rmod_serial}
        ${temp}  Catenate  SEPARATOR=  .+${item}  _RMOD.{3}  .+_ram_pm_1_system\.log\.gz$
        Append To List  ${mandatory_patterns}  ${temp}
    END

    &{pm_files_dict}  Create Dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${non_mandatory_patterns}

    [Return]  &{pm_files_dict}


TC Setup
    Common Test Setup  tc_name=LOGS__Postmortem_files_creation_in_snapshot_content


TC Teardown
    Common Test Teardown
