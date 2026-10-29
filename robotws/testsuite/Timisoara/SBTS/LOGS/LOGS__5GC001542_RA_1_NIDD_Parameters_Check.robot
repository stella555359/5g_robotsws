*** Settings ***
Resource    ../resources/pm_logs_frame.robot
Resource    ../resources/pm_logs_general.robot
Resource    taf/rfrl/common_resources/common_step/interface.robot
Resource    ../resources/bts_states.robot
Library     taf.sbts.oam.coam.admin  WITH NAME  coam
Library     ../resources/PythonKW_for_LOGS__5GC001542_RA_1_NIDD_Parameters_Check.py
Library     ../resources/ValuesGenerator.py

*** Variables ***


*** Keywords ***
TC__LOGS__5GC001542_RA_1_NIDD_Parameters_Check

    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-24353
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...   The purpose of this test is to verify ability to configure BTS Fault Id in configuration plan
    ...  ******************
    ...  History of changes
    ...  ******************

    ...  - 27.12.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-24353 - Test rewritten based on BOAM ET test -
    ...  [1]5GC001542_RA_1_NIDD_Parameters_Check
    ...  - 10.03.2023 - TAT-24917 - Hran_frame resource name change to ca_pm_logs_frame


    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/LOGS__5GC001542_RA_1_NIDD_Parameters_Check.png
    ...

    Set Tags      CA-PM  OWNER-iuliia.taupeka@nokia.com  AUTHOR-Irina.Tanasoiu@nokia.com  MAINTAINER-jakub.kokoszka@nokia.com
    ...           GROUP_IN_CHARGE-WRO_6_Vrf  PHASE-CRT  SW-SBTS23R1  FEATURE-5GC001542

    Step 0: Preconditions
    Step 1: Verify ability to configure BTS Fault Id in configuration plan


Step 0: Preconditions
    [Documentation]
    ...  In this step test prepare path variable and create taf.sbts.oam.coam.admin connection

    Log  \nStep 0: Preconditions  console=${True}

    ${bts_connection}=  coam.connect_to
    Set Test Variable  ${BTS_CONNECTION}  ${bts_connection}
    ${bts_id}  bts_states.Get BTS ID
    Set Test Variable  ${BTS_ID}  ${bts_id}


Step 1: Verify ability to configure BTS Fault Id in configuration plan
    [Documentation]
    ...  In this step test check max number od fault triggers

    Log  \nStep 1: Verify ability to configure BTS Fault Id in configuration plan  console=${True}
    NIDD Parameters Check



NIDD Parameters Check
    Log    Add 37 Fault Triggers    console=${True}
    Add 37 Fault Triggers
    Log    Check There Are 37 Fault Triggers    console=${True}
    Check There Are 37 Fault Triggers
    Log    Adding 38 Fault Triggers Should Fail    console=${True}
    Adding next Fault Triggers Should Fail



Add 37 Fault Triggers
	[Documentation]
	...  this KW add 37 faults for snapshot trigger

    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${33}

    coam.Perform Parameter Recommissioning
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip



Check There Are 37 Fault Triggers
	[Documentation]
	...  this KW Check There Are 37 Fault Triggers

    coam.get_current_scf_file      ${BTS_Files}    scf.xml
    ${faults}=    Grep File   ${BTS_Files}/scf.xml     faultNumber
    ${result}=    is_faults_list_complete    ${faults}    expected_size=${37}
    should be true    ${result}


Adding next Fault Triggers Should Fail
	[Documentation]
	...  this KW add next fault trigger for snapshot trigger and expected failed.
	...  Operation not allowed. Maximum BTS Fault Id’s configured.

     set test variable    ${error}
        ...    *ErrorCode: 23*
     Run Keyword And Expect Error    ${error}    Adding next Fault Triggers



Adding next Fault Triggers
	[Documentation]
	...  this KW add next. fault trigger for snapshot trigger

    ${fault_38}=    Create Dictionary
        ...     faultNumber=59
        ...     triggerType=onFaultDetection

    @{list}=    get_fault_triggers_list    reals=${4}    fakes=${39}
    Append To List    ${list}    ${fault_38}

    coam.Perform Parameter Recommissioning
        ...    dist_name=MRBTS-${BTS_ID}/MNL-1/MNLENT-1/TRBLCADM-1
        ...    parameter=faultSnapshotTriggers
        ...    operation=update
        ...    value=@{list}
        ...    skip_parameter_relation_errors=skip



TC Setup
    Common Test Setup

TC Teardown
    Run Keywords
    ...    interface.Common step trigger
    ...    AND    Setup Scout And Send Configuration
    ...    AND    Common Test Teardown
