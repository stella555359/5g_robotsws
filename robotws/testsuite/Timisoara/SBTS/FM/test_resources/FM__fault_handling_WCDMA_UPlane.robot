*** Settings ***
Documentation
    ...  This TC tests WCDMA U-Plane fault 110 trigger.
    ...  The test generates fault 110 (fault triggering procedure is detailed in the TAT),
    ...  which should trigger a RAT recovery for WCDMA. In then checks that only WCDMA cells
    ...  are affected, and waits a given TIMEOUT for all cells to be up, and for the fault to be clear.
    ...  actForceAutoReset needs to be set to true because otherwise, the fault needs to
    ...  be triggered for all WCDMA DSPs in order for the RAT Recovery to happen.

Resource  ../../common_resources/ca_FM_general.robot


*** Variables ***
${TIMEOUT}  600s  # time required for SBTS to be up after WCDMA RAT Recovery


*** Keywords ***
TC__FM__fault_handling_WCDMA_UPlane
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21640
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 23.07.2021 - https://jira3.ext.net.nokia.com/browse/TAT-21640 - Initial TAT creation
    ...  - 10.11.2021 - https://jira3.ext.net.nokia.com/browse/TAT-22065 - Adapt FM TCs for CNI-61110
    ...  - 19.01.2024 - https://jiradc.ext.net.nokia.com/browse/TAT-26771 - Use faults defined in py file
    ...  *******************

    Set Tags  CA-FM  OWNER-bogdan.boldurean@nokia.com  AUTHOR-vlad.slivilescu@nokia.com  MAINTAINER-vlad.slivilescu@nokia.com
    ...  GROUP_IN_CHARGE-TIM_2_Vrf  PHASE-CRT  SW-SBTS21

    Step 1: Check All Required States
    Step 2: Trigger Fault 110
    Step 3: Assert DSP WCDMA Cells Are Down
    Step 4: Wait For Expected SBTS Recovery


Step 1: Check All Required States
    [Documentation]  actForceAutoReset should be set to true.
    ...  if it is not, it will be set and unset in TC Teardown.

    Log  Step 1: Check All Required States  console=True

    Log  Setting actForceAutoReset param to true  console=True
    ${fmcadm}  Query Infomodel  get object //FMCADM_A-*
    Run Keyword If  ${fmcadm}[actForceAutoReset] == False
    ...  Run Keywords
    ...  Enable Auto Reset
    ...  AND
    ...  Set Test Variable  ${DELTA_SET}  True
    ...  ELSE
    ...  Set Test Variable  ${DELTA_SET}  False


Step 2: Trigger Fault 110
    [Documentation]  Fault 110 is triggered as explained in the TAT
    ...  procedure.

    Log  Step 2: Trigger fault 110  console=True

    ${sender}  Get Fault Sender
    ${dsp}  Get WCDMA DSP
    ${affected_wcdma_cells}  Get Cells On DSP  ${dsp}
    Set Test Variable  ${AFFECTED_WCDMA_CELLS}  ${affected_wcdma_cells}

    ${dsp_fault_hex}  Convert To Hex  ${dsp}[nodeId]
    ${dsp_fault}  Convert To Integer  ${dsp_fault_hex}0000  16

    Log  Sender is ${sender}  console=True
    Log  The DSP ID is ${dsp_fault}  console=True

    Send Oam Fault Ind Msg  sender=${sender}  receiver=${sender}  fault_id=110  severity=1  state=1  info_type=0  specific_fault_info=${dsp_fault}

    ${fault_110_params}  Get String With Alarm Parameters  ${FAULT_110_RAT_AUTO_RST}
    Assert Alarm Active  parameters=${fault_110_params}  timeout=60
    Log  Fault 110 was succesfully raised.  console=True


Step 3: Assert DSP WCDMA Cells Are Down
    [Documentation]  All WCDMA cells should be down during RAT Recovery,
    ...  but all other cells should be up.

    Log  Step 3: Assert DSP WCDMA Cells Are Down  console=True

    Assert Every  WNCEL  operationalState=${DISABLED}  timeout=60

    Run Keyword If  ${SCF_COUNT_LTE}
    ...  Assert Every  LNCEL  operationalState=${ENABLED}  timeout=60
    Run Keyword If  ${SCF_COUNT_GSM}
    ...  Assert Every  GNCEL  operationalState=${ENABLED}  timeout=60
    Run Keyword If  ${SCF_COUNT_NR}
    ...  Assert Every  NRCEL  operationalState=${ENABLED}  timeout=60


Step 4: Wait For Expected SBTS Recovery
    [Documentation]  Recovery should happen in TIMEOUT. All cells should be up and the fault should
    ...  be cleared.

    Log  Step 4: Wait for Expected SBTS Recovery  console=True
    Wait Until Keyword Succeeds  ${TIMEOUT}  10s
    ...  Check All Cells
    Admin Check Active Alarms TAF

    ${fault_110_params}  Get String With Alarm Parameters  ${FAULT_110_RAT_AUTO_RST}
    Assert Alarm Inactive  faultId=110
    Log  Fault 110 is inactive.  console=True


Enable Auto Reset
    Create Delta
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  actForceAutoReset  true
    ${delta}  Get Delta
    Save Delta
    coam.Perform Delta Recommissioning  delta.json
    Remove Delta


Disable Auto Reset
    Create Delta
    Append Parameter Update To Delta  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FMCADM-1  actForceAutoReset  false
    ${delta}  Get Delta
    Save Delta
    coam.Perform Delta Recommissioning  delta.json
    Remove Delta


Get Fault Sender
    Log  Getting Fault Sender  console=True

    ${wts_process}  Get Wts Process
    ${wts_parent_cpu_dn}  Get Parent Distname  ${wts_process}[dist_name]
    ${wts_parent_cpu}  Query Infomodel  get object ${wts_parent_cpu_dn}

    ${task_id_hex}  Convert To Hex  ${wts_process}[servicesMap][0][taskId]
    ${node_id_hex}  Convert To Hex  ${wts_parent_cpu}[nodeId]

    ${sender}  Convert To Integer  ${node_id_hex}${task_id_hex}  16

    [Return]  ${sender}


Get Wts Process
    Log  Getting taskId from Wts process  console=True
    ${wts_process}  Query Infomodel  get object //PROCESS-* is [servicesMap[0].name=Wts]

    [Return]  ${wts_process}


Get Parent Distname
    [Arguments]  ${child_obj_distname}

    ${parent_matches}  Get Regexp Matches  ${child_obj_distname}  (.+)\/.+$  1
    ${parent_obj_distname}  Get From List  ${parent_matches}  0

    [Return]  ${parent_obj_distname}


Get WCDMA DSP
    Log  Getting WCDMA DSP  console=True
    ${wcdma_bbpools_l}  Query Infomodel  get list //BBPOOL_L-* is [assignedLCellsDNs[0]=regex".+WNBTS_M.+"]
    ${wcdma_bbpool}  Set Variable  ${wcdma_bbpools_l}[0]
    ${dsp_dn}  Set Variable  ${wcdma_bbpool}[dspsDNs][0]
    ${dsp}  Query Infomodel  get object ${dsp_dn}

    [Return]  ${dsp}


Get Cells On DSP
    [Arguments]  ${dsp}

    ${dsp_bbpool}  Query Infomodel  get object //BBPOOL_L-* is [dspsDNs[?]=${dsp}[dist_name]]

    [Return]  ${dsp_bbpool}[assignedLCellsDNs]


TC Setup
    Common Test Setup  tc_name=FM__fault_handling_WCDMA_UPlane


TC Teardown
    Run Keyword If  ${DELTA_SET}
    ...  Disable Auto Reset
    Common Test Teardown
