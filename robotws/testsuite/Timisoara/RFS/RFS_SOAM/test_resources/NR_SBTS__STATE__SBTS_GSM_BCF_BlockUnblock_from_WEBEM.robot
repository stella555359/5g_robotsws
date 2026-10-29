*** Settings ***
Documentation    TC__NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM
Variables    tc_variables/nr_sbts__state__sbts_gsm_bcf_block_unblock_from_webem_alarms_definitions.py
Resource    ../../resources/rfs_frame_rfs_soam_taf.robot

*** Variables ***
${REPEAT_COUNTER}        3      # Number of SBTS block/unblock SBTS GSM BCF operations, default value 3

*** Keywords ***
TC__NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/TAT-19187
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  NR-SBTS test case for SBTS Block/Unblock SBTS GSM BCF from WEBEM, - x times sequence.
    ...  x - value of REPEAT_COUNTER parameter (default: 3)
    ...  The main steps performed for the test are:
    ...  - check initial state and alarms for both NR and SBTS technologies
    ...  - perform Block/Unblock BCF from WEBEM operation on SBTS GSM Slave
    ...  - check final state and alarms for both NR and SBTS technologies
    ...  Pass criteria: SBTS Block/Unblock BCF operation works as expected, states and alarms are as expected
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 18.03.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19187 -
    ...  [NR][P16]Create new automated test NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM
    ...  - 14.04.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-19341 -
    ...  Increase timeout for block BCF 90 -> 180 secs and for GSM cells after unblock 5 -> 60 secs
    ...  - 14.10.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20319 - [Refactoring] Optimize Repeat_Counter loop in test cases - NR-SBTS
    ...  - 25.11.2020 - https://jiradc.ext.net.nokia.com/browse/TAT-20492 - [5G] Add guard time after performing OAM operations
    ...  - 23.03.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-20865 - [Legacy] Pipeline: Clean up robot TC in RFS_SOAM folder - NR_SBTS
    ...  - 12.05.2021 - https://jiradc.ext.net.nokia.com/browse/TAT-21303 - [Legacy][taf.sbts.oam.coam.admin] Udate & test TC NR_SBTS
    ...  - 14.01.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-21776 - [5G][Legacy][RFSplit] Test NRSBTS Common Part (hran_ta)
    ...  - 22.02.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-22646 - [Cloud] [RFSplit] [Legacy] Particular teardown refactoring - NR-SBTS part
    ...  - 04.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23925 - [5G][TC review][NR-SBTS] Remove Cells "AdministrativeState" check in
    ...  all NR-SBTS robots
    ...  - 07.11.2022 - https://jiradc.ext.net.nokia.com/browse/TAT-23926 - [5G][CNI-82119] Implement new RAT check in RAT Block Unblock tests
    ...  - 24.10.2025 - https://jiradc.ext.net.nokia.com/browse/TAT-29823 -
    ...  Unify alarm list names in order alarm list to begin with upper case Alias - NR_SBTS
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...  image:: https://gitlabe1.ext.net.nokia.com/panda-docs/hran_doc/-/blob/master/testsuite/RFS_SOAM/
    ...  TAT-19187_NR_SBTS__STATE__SBTS_GSM_BCF_BlockUnblock_from_WEBEM.png

    Set Tags    CA-STATE    OWNER-geraldina.isfan@nokia.com    AUTHOR-gabriel.stanculescu@nokia.com    PHASE-QT    SW-5G19,SBTS19

    Get SBTS GSM BCF Distname
    Step 1: Check initial all BTS state
    Step 2: Check initial all BTS alarms
    Step 3: Get all SBTS GSM cells
    FOR  ${INDEX}  IN RANGE  1  ${REPEAT_COUNTER}+1
        Log  ==============================================================================  console=True
        Log  Start Cycle ${INDEX} of ${REPEAT_COUNTER}  console=True
        Log  ==============================================================================  console=True
        Step 4: Block Unblock SBTS GSM BCF
        Step 5: Check final number and state of Cells and RMs
    END
    Step 6: Check final all BTS state
    Step 7: Check final all BTS alarms

    [Teardown]  Particular Teardown

Step ${index}: Check ${when} all BTS state
    [Documentation]
    ...  SBTS state is checked according to Admin for BTS and each configured RAT

    Log  Step ${index}: Check ${when} all BTS state  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} state *****  console=True
        Admin Check BTS RAT Procedural State  alias=${alias}  timeout=600
        Admin Check BTS Procedural and Blocking states  ${OnAir_}  ${Unblocked_}  alias=${alias}
        Log  BTS ${alias} site - proceduralState: OnAir, blockingState: Unblocked  console=True
    END

Step ${index}: Check ${when} all BTS alarms
    [Documentation]
    ...  SBTS alarms are compared with values from expected, ignored and critical alarms lists. SBTS alarms are get
    ...  from Admin

    Log  Step ${index}: Check ${when} all BTS alarms  console=True
    FOR  ${alias}  IN  @{alias_list}
        Log  ***** Check ${when} BTS ${alias} alarms *****  console=True
        ${wait_for_alarm_clear}=  Set Variable If  '${when}' == 'final'  15 min  5 min
        Get and Check Alarms SOAM  alias=${alias}  expected_alarms=@{EMPTY}  ignored_alarms=${${alias.upper()}_IGNORED_ALARMS}
        ...  critical_alarms=${${alias.upper()}_CRITICAL_ALARMS}  wait_for_alarm_clear=${wait_for_alarm_clear}
        Log  BTS ${alias} site - expected, ignored and critical alarms checked  console=True
    END

Step ${index}: Get all SBTS GSM cells
    Log  Step ${index}: Get all SBTS GSM cells  console=True
    ${SBTS_GSM_CELL_list}=  Get Ids For All  GNCEL  alias=Slave
    Sort List  ${SBTS_GSM_CELL_list}
    ${SBTS_GSM_CELL_count}=  Get Length  ${SBTS_GSM_CELL_list}
    Run Keyword If  ${SBTS_GSM_CELL_count} > 0
    ...  Log  SBTS GSM cells found: ${SBTS_GSM_CELL_list}  console=True
    ...  ELSE
    ...  Fail  No SBTS GSM cells are present in runtime view configuration!
    Set Test Variable  ${SBTS_GSM_CELL_list}
    Set Test Variable  ${SBTS_GSM_CELL_count}

Step ${index}: Block Unblock SBTS GSM BCF
    Log  Step ${index}: Block Unblock SBTS GSM BCF  console=True
    Block SBTS GSM BCF from WEBEM
    Run Keyword If  ${SBTS_LTE_cell_ids}
    ...  Assert Every  LNCEL  availabilityStatus=Online, operationalState=Enabled  timeout=5  alias=Slave
    Run Keyword If  ${SBTS_WCDMA_cell_ids}
    ...  Assert Every  WNCEL  availabilityStatus=Online, operationalState=Enabled  timeout=5  alias=Slave
    Assert Every  GNCEL  availabilityStatus=Offline, operationalState=Disabled  timeout=60  alias=Slave
    ${SBTS_EXPECTED_ALARMS_multiplied}=  Prepare expected alarms list  ${SBTS_EXPECTED_ALARMS}  ${SBTS_GSM_CELL_count}
    Log  Checking alarm status on Master NR!  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${NR_IGNORED_ALARMS}  critical_alarms=${NR_CRITICAL_ALARMS}
    Log  Checking alarm status on Slave SBTS!  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=${SBTS_EXPECTED_ALARMS_multiplied}  ignored_alarms=${SBTS_IGNORED_ALARMS}
    ...  critical_alarms=${SBTS_CRITICAL_ALARMS}
    Unblock SBTS GSM BCF from WEBEM
    Run Keyword If  ${SBTS_LTE_cell_ids}
    ...  Assert Every  LNCEL  availabilityStatus=Online, operationalState=Enabled  timeout=5  alias=Slave
    Run Keyword If  ${SBTS_WCDMA_cell_ids}
    ...  Assert Every  WNCEL  availabilityStatus=Online, operationalState=Enabled  timeout=5  alias=Slave
    Assert Every  GNCEL  availabilityStatus=Online, operationalState=Enabled  timeout=60  alias=Slave
    Log  Checking alarm status on Master NR!  console=True
    Get and Check Alarms SOAM  alias=Master  expected_alarms=@{EMPTY}  ignored_alarms=${NR_IGNORED_ALARMS}  critical_alarms=${NR_CRITICAL_ALARMS}
    Log  Checking alarm status on Slave SBTS!  console=True
    Get and Check Alarms SOAM  alias=Slave  expected_alarms=@{EMPTY}  ignored_alarms=${SBTS_IGNORED_ALARMS}  critical_alarms=${SBTS_CRITICAL_ALARMS}

Step ${index}: Check final number and state of Cells and RMs
    [Documentation]
    ...  Following checks are performed:
    ...  - number of configured cells and radio modules in SCF are properly mapped on BTS running view ADMIN
    ...  - check cells states
    ...  - check radio modules states

    Log  Step ${index}: Check final number and state of Cells and RMs  console=True
    RFS Test Case Final Checks

Get SBTS GSM BCF Distname
    ${objects}=  Query Infomodel  get list //GNBCF_R-*  alias=Slave  allow_negative_result=True
    ${parameter_values}=  Create List
    FOR  ${object}  IN  @{objects}
        Append To List  ${parameter_values}  ${object['dist_name']}
    END
    ${bcf_distname}=  Get From List    ${parameter_values}    0
    Set Test Variable  ${bcf_distname}

Block SBTS GSM BCF from WEBEM
    Log  Blocking SBTS GSM BCF from WEBEM  console=True
    ${status}    ${msg}=    Run Keyword And Ignore Error    coam.Block    ${bcf_distname}    timeout=180s  alias=Slave
    Run Keyword If  '${status}'!='PASS'  Fail  Blocking SBTS GSM BCF ${bcf_distname} from WEBEM failed!
    Log  SBTS GSM BCF ${bcf_distname} blocked!  console=True
    Sleep  10s

Unblock SBTS GSM BCF from WEBEM
    Log  Unblocking SBTS GSM BCF from WEBEM  console=True
    ${status}    ${msg}=    Run Keyword And Ignore Error    coam.Unblock    ${bcf_distname}    timeout=60s  alias=Slave
    Run Keyword If  '${status}'!='PASS'  Fail  Unblocking SBTS GSM BCF ${bcf_distname} from WEBEM failed!
    Log  SBTS GSM BCF ${bcf_distname} unblocked!  console=True
    Sleep  10s

Particular Teardown
    Run Keyword And Continue On Failure  Check if RAT is unblocked  Slave

TC Setup
    ${tech_preset_list}=  Create List  SBTS  SBTS
    Common Test Setup  preset_techs=${tech_preset_list}  common_sbts=${TRUE}

TC Teardown
    Common Test Teardown
