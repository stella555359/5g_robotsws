*** Settings ***
Documentation
    ...  Verification of operability function for BCF reset operation

Resource  ../../common_resources/ca_CIT_general.robot


*** Keywords ***
TC__STATE__GSM_BCF_reset_from_BSC
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-6809
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 22.06.2017 - initial creation
    ...  - 03.07.2017 - TC delivery
    ...  - 07.08.2020 - https://jira3.int.net.nokia.com/browse/TAT-20050 - Add TL recovery action
    ...
    ...  *******************
    ...  Test case flowchart
    ...  *******************
    ...
    ...  https://tatools.emea.nsn-net.net/static/hran_doc/testsuite/SBTS/TAT-6809_STATE__GSM_BCF_reset_from_BSC.png#

    Set Tags  CA-STATE  OWNER-robert.susz@nokia.com  AUTHOR-agnieszka.malek@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CIT  SW-SBTS17  SW-SBTS18  SW-SBTS19  FEATURE-RP001498_RP000923  FEATURE-RP001621_RP000923
    ...  FEATURE-RP001486_RP000923  FEATURE-RP001307_RP000923  FEATURE-RP0001145_RP000923

    Step1: States Verification Before BCF Reset
    Step2: BCF Reset
    Step3: States Verification After BCF Reset


Step1: States Verification Before BCF Reset
    [Tags]  Step

    Log  Step1: States Verification before BCF reset.  console=true
    Cells States Verification
    BCF Resources States Verification


Step2: BCF Reset
    [Tags]  Step

    Log  Step2: BCF reset.  console=true
    Get Alarms Before Reset
    Reset BCF From BSC
    Verify Alarms After Reset


Step3: States Verification After BCF Reset
    [Tags]  Step
    [Timeout]  10 minutes

    Log  Step3: States Verification after BCF reset. Max waiting time for all states to reach expected values 10min.  console=true
    ${cells_verification_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  10 minutes  5s
    ...  _Cells States Check
    ${bcf_resources_verification_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  10 minutes  5s
    ...  _BCF Resources States Check
    Run Keyword If  ${cells_verification_status} or ${bcf_resources_verification_status}
    ...  Log  All states have expected values after reset!  console=true
    ...  ELSE
    ...  Set Test Failed  message=Not all states have expected values after reset in 10minutes timeout.  fail_fast=${True}


Specific Test Setup
    [Tags]  Flatten

    STATE__GSM_BCF_reset_from_BSC.Open BSC Session
    STATE__GSM_BCF_reset_from_BSC.Get BCF ID


Open BSC Session
    [Tags]  Flatten

    hran_bsc.Bsc SSH Connection  host=${BSC['ip']}  username=${BSC['user']}  password=${BSC['password']}
    hran_bsc.Set Timeout  240s


Cells States Verification
    [Tags]  Flatten

    Log  Cells states Verification started.  console=true
    ${cells_states}  Run Keyword And Return Status
    ...  _Cells States Check
    Run Keyword If  ${cells_states}
    ...  Log  All Cells have expected values.  console=true
    ...  ELSE
    ...  Set Test Failed  message=Not all cells states have expected values.  fail_fast=${True}


_Cells States Check
    [Tags]  Flatten

    Assert All Cells Are In Expected State


BCF Resources States Verification
    [Tags]  Flatten

    Verify BCF States
    Verify Sectors States
    Verify Trxs States
    Verify OM Link State


_BCF Resources States Check
    [Tags]  Flatten

    _Check BCF States
    _Check Sectors States
    _Check Trxs States
    _Check OM Link State


Get Alarms Before Reset
    [Tags]  Flatten

    Log  Collecting alarms before reset operation.  console=true
    @{active_alarms_before_reset}  coam.Get Active Alarms  timeout=60
    Set Test Variable  ${ACTIVE_ALARMS_BEFORE_RESET}


Reset BCF From BSC
    [Tags]  Flatten

    Log  Starting reset operation. Max waiting time for reset operation start 10min.  console=true
    ${status}  hran_bsc.Reset  bcf_id=${BCF_ID}  no_of_tries=2  timeout=5min  allow_negative_result=${True}
    Run Keyword If  ${status}
    ...  Log  Reset sucessfully started.  console=true
    ...  ELSE
    ...  Set Test Failed  message=Reset operation failed in 10min.  fail_fast=${True}


Verify Alarms After Reset
    [Tags]  Flatten

    Log  Alarms verification after reset started.  console=true
    ${active_alarms_after_reset}  coam.Get Active Alarms  timeout=60
    ${active_present}  Remove Values From List  ${active_alarms_after_reset}  @{ACTIVE_ALARMS_BEFORE_RESET}
    Run Keyword If  ${active_present}
    ...  Set Test Restriction  msg=Unexpected alarms are present
    ...  ELSE
    ...  Log  There is no newly rised alarms after BCF reset.


Get BCF ID
    [Tags]  Flatten

    Log  Getting BCF id from infomodel.  console=true
    ${bcf_id}  sbts_infomodel.Infomodel Get BcfId
    Set Test Variable  ${BCF_ID}
    Log  BCF ID: ${BCF_ID}  console=true


Verify BCF States
    [Tags]  Flatten

    Log  BCF states Verification started.  console=true
    ${bcf_states}  Run Keyword And Return Status
    ...  _Check BCF States
    Run Keyword If  ${bcf_states}
    ...  Log  BCF states have expected values. Administrative State: U, Operational State: WO.  console=true
    ...  ELSE
    ...  Set Test Failed  message=Invalid BCF state.  fail_fast=${True}


_Check BCF States
    [Tags]  Flatten

    ${bcf_administrative_state}  ${bcf_operational_state}  hran_bsc.Get BCF Status  ${BCF_ID}
    Should Be Equal As Strings  ${bcf_administrative_state}  U
    Should Be Equal As Strings  ${bcf_operational_state}  WO


Verify Sectors States
    [Tags]  Flatten

    Log  Sectors states Verification started.  console=true
    ${status}  Run Keyword And Return Status
    ...  _Check Sectors States
    Run Keyword If  ${status}
    ...  Log  All Sectors have expected values. Administrative State: U, Operational State: WO  console=true
    ...  ELSE
    ...  Set Test Failed  message=Some sectors states are different than expected.  fail_fast=${True}


_Check Sectors States
    [Tags]  Flatten

    hran_bsc.Parse BCF Sectors Status  bcf_id=${BCF_ID}  expected_operational_state=WO  expected_administrative_state=U


Verify Trxs States
    [Tags]  Flatten

    Log  TRXs states Verification started.  console=true
    ${status}  Run Keyword And Return Status
    ...  _Check Trxs States
    Run Keyword If  ${status}
    ...  Log  All TRXs have expected values. Administrative State: U, Operational State: WO  console=true
    ...  ELSE
    ...  Set Test Failed  message=Some TRXs states are different than expected.  fail_fast=${True}


_Check Trxs States
    [Tags]  Flatten

    hran_bsc.Parse BCF Trxs Status  bcf_id=${BCF_ID}  expected_operational_state=WO  expected_administrative_state=U


Verify OM Link State
    [Tags]  Flatten

    Log  OM link state Verification started.  console=true
    ${status}  Run Keyword And Return Status
    ...  _Check OM Link State
    Run Keyword If  ${status}
    ...  Log  OM link state has expected value: WO.  console=true
    ...  ELSE
    ...  Set Test Failed  message=Invalid OM link state.  fail_fast=${True}


_Check OM Link State
    ${om_link_state}  hran_bsc.Get OM Link State  bcf_id=${BCF_ID}
    Should Be Equal As Strings  ${om_link_state}  WO


TC Setup
    Run Keywords
    ...  Common Test Setup  modules_check=${False}
    ...  AND
    ...  STATE__GSM_BCF_reset_from_BSC.Specific Test Setup


TC Teardown
    Run Keywords
    ...  Close All BSC Sessions
    ...  AND
    ...  Common Test Teardown
    ...  AND
    ...  Recover Test Line By Power Reset
