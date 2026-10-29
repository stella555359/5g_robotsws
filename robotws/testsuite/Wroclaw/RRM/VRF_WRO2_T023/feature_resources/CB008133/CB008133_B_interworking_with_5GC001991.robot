*** Settings ***
Documentation
...   contact: Szymon Startek

Library    DateTime
Library    ute_ue
Library    taf.config.scf
Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Resource    ../../resources/ca_IWK.robot

*** Variables ***
${NR_CELL_ID}                           # ID of tested NR cell
${VALUE_INSIDE_32TRX}   0               # Value of tiltOffset in range 32TRX
${VALUE_INSIDE_64TRX}   4               # Value of tiltOffset in range 64TRX
${VALUE_OUTSIDE_64TRX}  7               # Value of tiltOffset outside the range 64TRX
@{IGNORED_ALARMS}       faultId=4598    # Alarms ignored while verifying BTS state in step 2 and 3


*** Keywords ***
TC__CB008133_B_interworking_with_5GC001991
    Set Tags    CA-INTER_RAT    AUTHOR-michal.hadrysiak@nokia.com    OWNER-piotr.1.maj@nokia.com
    ...         MAINTAINER-michal.hadrysiak@nokia.com    PHASE-CRT   SW-SBTS23R2    FEATURE-CB008133   GROUP_IN_CHARGE-Pz_2_WRO_3

    Preconditions
    Step 1: Changing TiltOffset To Value Inside 32TRX
    Step 2: Changing TiltOffset To Value Outside 64TRX
    Step 3: Changing TiltOffset To Value Inside 64TRX
    Step 4: Changing TiltOffset To Value Inside 32TRX


Preconditions
    Log  \n=== Preconditions ===  console=True
    Set Global Variables
    Check Element In SCF  ${PARSED_SCF_GNB}  NRBTS  NRBTS-${NRBTS_ID}  /p[@name='actNrLBmMimoRTXPowerSaving']
    ...  <p name="actNrLBmMimoRTXPowerSaving">true</p>  dist_name_substring=True


Set Global Variables
    ${nrbts_id} =  Get BTS ID From ADMIN  alias=gNB
    Set Test Variable  ${NRBTS_ID}  ${nrbts_id}

    ${scf_path_gnb}  ${parsed_scf_gnb}=  Save And Parse SCF  SCF  alias=gNB
    Set Test Variable  ${SCF_PATH_GNB}  ${scf_path_gnb}
    Set Test Variable  ${PARSED_SCF_GNB}  ${parsed_scf_gnb}


Step 1: Changing TiltOffset To Value Inside 32TRX
    Log  \n=== Step 1: Changing TiltOffset To Value Inside 32TRX ===  console=True
    Changing TiltOffset To Value  ${VALUE_INSIDE_32TRX}
    Wait Until Keyword Succeeds  2min  10s  _verify bts states for iwk test helper  alias=gNB


Step 2: Changing TiltOffset To Value Outside 64TRX
    Log  \n=== Step 2: Changing TiltOffset To Value Outside 64TRX ===  console=True
    Changing TiltOffset To Value  ${VALUE_OUTSIDE_64TRX}
    Wait Until Keyword Succeeds  2min  10s  _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    ${status}=  Run Keyword And Return Status  Assert Alarm Active  faultId=4598  timeout=60  alias=gNB
    Should Be True  ${status}  msg=Alarm 4598 not appear


Step 3: Changing TiltOffset To Value Inside 64TRX
    Log  \n=== Step 3: Changing TiltOffset To Value Inside 64TRX ===  console=True
    Changing TiltOffset To Value  ${VALUE_INSIDE_64TRX}
    Wait Until Keyword Succeeds  2min  10s  _verify bts states for iwk test helper  ignored_alarms=${IGNORED_ALARMS}  alias=gNB
    ${status}=  Run Keyword And Return Status  Assert Alarm Active  faultId=4598  timeout=60  alias=gNB
    Should Be True  ${status}  msg=Alarm 4598 not appear


Step 4: Changing TiltOffset To Value Inside 32TRX
    Log  \n=== Step 4: Changing TiltOffset To Value Inside 32TRX ===  console=True
    Changing TiltOffset To Value  ${VALUE_INSIDE_32TRX}
    Wait Until Keyword Succeeds  2min  10s  _verify bts states for iwk test helper  alias=gNB


Changing TiltOffset To Value
    [Arguments]  ${value}
    Create Delta  delta_id=delta_CB008133_B
    Append Complex Item To Delta  MRBTS-${NRBTS_ID}/NRBTS-${NRBTS_ID}/NRCELL-${NR_CELL_ID}  beamSet
    ...  basicBeamSet=beamSet_5_1  leftEdgeAngle=60  lowerEdgeAngle=120  nrBtsBeamRefinementP2=False
    ...  rightEdgeAngle=60  tiltOffset=${value}  upperEdgeAngle=80  delta_id=delta_CB008133_B
    ${delta}  Get Delta  delta_id=delta_CB008133_B
    Log To Console  ${delta}
    Perform Delta Recommissioning  ${delta}  alias=gNB
    [Teardown]  Remove Delta  delta_id=delta_CB008133_B


TC Setup
    IWK Test Setup  local_enb_connection=False  single_bts=True


TC Teardown
    Log  \n=== Test Specific Teardown ===  console=True
    Run Keyword If Test Failed  Changing TiltOffset To Value  ${VALUE_INSIDE_32TRX}
    IWK Test Teardown  delta_exists=False  collect_snapshot_on_test_fail=False  local_enb_connection=False  single_bts=True

