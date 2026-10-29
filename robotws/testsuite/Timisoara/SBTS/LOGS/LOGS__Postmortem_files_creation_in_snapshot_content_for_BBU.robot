*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/verdicts.robot
Resource    ../resources/bts_states.robot
Resource    ../resources/infomodel.robot
Library    hran_file_operations
Library    taf.sbts.oam.coam.admin  WITH NAME  coam
Library    taf.ul.verify_snapshot   WITH NAME  snapshot

*** Variables ***
${SITE_RESET}               True
${STARTUP_TIMEOUT}          10
${SNAPSHOT_FILE_PATH}       /tmp/uri/DIAGN_FILES/   # Path to snapshot file stored on SBTS


*** Keywords ***
TC__LOGS__Postmortem_files_creation_in_snapshot_content_for_BBU
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-8401
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  Purpose of this TC is to verify presence of postmortem log files in case BTS reset occurred.
    ...  NOTE! TC is designed only for release 3 configuration
    ...
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  8.05.2018 - initial creation
    ...  - 2021-12-22 - TAT-22173 - Changes done due to CNI-61110 - move to hran_frame_sbts_siso
    ...  - 2022-07-19 - https://jiradc.ext.net.nokia.com/browse/TAT-23414 - KW(placeholder) Common step trigger for
    ...                 checking sleeping cells added in TC Teardown due to BIT CS4.3 Enable Sleeping Cell
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame
    ...  - 29.05.2023 - TAT-25470 - Changed to new FOR loop syntax
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-8401_LOGS__Postmortem_files_creation_in_snapshot_content_for_BBU.png#


    Set Tags    CA-SWM    OWNER-katarzyna.stefaniszyn@nokia.com    AUTHOR-lukasz.targonski@nokia.com
    ...    MAINTAINER-iuliia.taupeka@nokia.com    PHASE-CRT    SW-SBTS17    SW-SBTS18

    Run keyword if  ${SITE_RESET}  BTS site reset
    Step 0: TC preconditions
    Step 1: Trigger DSP crash
    Step 2: Snapshot collection
    Step 3: Verify snapshot content


BTS site reset
    [Documentation]
    ...     BTS site reset is performed if user had set site_reset variable to True.

    Log  Perform BTS site reset  console=yes
    coam.Reset Site  600
    Sleep  10s
    Wait Until Keyword Succeeds  ${STARTUP_TIMEOUT}m  1m  Check All Modules And Cells State
    Log  All cells and modules reached working state  console=yes
    bts_states.Check Active Alarms

Step 0: TC preconditions
    Log  TC preconditions: Check SM variant  console=yes
    ${sm_variant}=  infomodel.Get SM variant
    Run Keyword If  '${sm_variant[0]}'=='ASIA'  verdicts.Set Test Norun  TC supports only rel3 configuration
    Log  Checking BBU amount
    ${nr_of_bbu}=  Get BBU count
    Set test variable  ${nr_of_bbu}

Step 1: Trigger DSP crash
    Log  Step 1: Trigger DSP crash  console=yes
    ${dsp_id}=  Select DSP to be crashed
    Trigger DSP crash for given DSP_ID  ${dsp_id}
    bts_states.Check Active Alarms

Select DSP to be crashed
    Log  Sellecting DSP to be crashed
    # SMOD
    ${smod}=  Set variable  1

    # BBU
    ${bbu}=  Evaluate  random.randint(1, ${nr_of_bbu})  modules=random
    ${bbu}=  Evaluate  ${bbu} + 1

    # DSP
    ${dsp}=  Evaluate  random.randint(3, 8)  modules=random

    # core
    ${core}=  Evaluate  random.randint(1, 4)  modules=random

    ${dsp_id}=  Catenate  SEPARATOR=  0x  ${smod}  ${bbu}  ${dsp}  ${core}
    [Return]  ${dsp_id}

Trigger DSP crash for given DSP_ID
    [Arguments]  ${dsp_id}
    Log  Trigger crash of DSP ${dsp_id}  console=yes
    SSHLibrary.open connection  ${SMOD1['IP']}  encoding=unicode_escape
    SSHLibrary.login  ${SMOD1['USERNAME']}  ${SMOD1['PASSWORD']}
    Log  Run 'rioboot -c read -a 0x10800000 -n 0x1000000'  console=yes
    Run keyword and ignore error
    ...  SSHLibrary.execute command  rioboot -c read -a 0x10800000 -n 0x1000000 ${dsp_id}  return_stdout=False    return_rc=True
    Log  Wait 3 min to check if alarm 6450 raised.  console=yes
    Sleep  3m
    ${expected_fault}=  Create Dictionary  faultId=6450
    ${expected_fault}=  Create List  ${expected_fault}
    ${ignored_fault}=  Create Dictionary  faultId=6707
    ${ignored_fault}=  Create List  ${ignored_fault}
    ${status}=  Run keyword and return status  bts_states.Check Active Alarms  expected_patterns=${expected_fault}  ignored_patterns=${ignored_fault}
    Run keyword unless  ${status}  Fail  Fault 6450 was not received.
    Log  Fault 6450 is reported  console=yes

Step 2: Snapshot collection
    Log  Step 2: Start snapshot collection  console=yes
    ${timestamp}=  Get time
    ${timestamp}=  Replace string using regexp  ${timestamp}  (${SPACE}|:|-)  _
    ${collect_snapshot_status}=  Run Keyword And Ignore Error  coam.Collect Snapshot  ${BTS_Files}/snapshot_${timestamp}.zip
    Run Keyword If  '${collect_snapshot_status[0]}' == 'PASS'
    ...     Set global variable  ${path_to_snapshot}  ${BTS_Files}/snapshot_${timestamp}.zip
    ...     ELSE  Log  Collecting snapshot via Admin failed  console=yes

Step 3: Verify snapshot content
    Log  Step 3: Verify snapshot content  console=yes
    ${mandatory_files_patterns}=  Create pm files dict for FSP  ${nr_of_bbu}

    ${snapshot_data_dict}=  snapshot.Get data from snapshot  ${path_to_snapshot}
    snapshot.Validate snapshot using custom data  ${snapshot_data_dict}  ${mandatory_files_patterns}


Get BBU count
    [Documentation]
    ...     This keyword uses infomodel query to check how many BB units are
    ...     commissioned on SBTS and returns that value.

    ${bbu_objects}=  coam.Get parameters for all  BBU
    ${nr_of_bbu_objects}=  Get length  ${bbu_objects}
    [Return]  ${nr_of_bbu_objects}


Create pm files dict for FSP
    [Documentation]  Create dictionary of pm patterns for FSP

    [Arguments]  ${fsp_counter}

    ${mandatory_patterns}=  Create list
    ${additional_patterns}=  Create list

    # add FSP related postmortem files to pm_patterns list
    ${fsp_nr}=  Convert to integer  ${fsp_counter}
    ${max}=  Evaluate  ${fsp_nr} + 2
    FOR  ${item}  IN RANGE  2  ${max}
        ${temp}=  Catenate  SEPARATOR=  .+_1  ${item}  0D_pm_1_syslog\.zip$
        Append to list  ${mandatory_patterns}  ${temp}
    END

    # create list of additional files related to FSPs
    FOR  ${item}  IN RANGE  2  ${max}
        ${temp}=  Catenate  SEPARATOR=  .+_1  ${item}  0D_pm_2_syslog\.zip$
        Append to list  ${additional_patterns}  ${temp}
    END

    &{pm_files_dict}=  Create dictionary  mandatory_file=${mandatory_patterns}  not_mandatory_file=${additional_patterns}

    [Return]  &{pm_files_dict}


Check All Modules And Cells State
    Verify system modules states
    Verify radio modules states
    Verify LTE cells states
    Verify WCDMA cells states
    Verify GSM cells states


TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown


