*** Settings ***
Documentation

Resource   resources/ca_BSRF_general.robot

*** Variables ***
${RMOD_SN}
${node}  default

*** Keywords ***
TC__SiSo_FM_NR_PIMC_Faults_Triggering
    [Documentation]
    ...  [CASE LINK]: https://jira3.int.net.nokia.com/browse/TAT-21420
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  TC for feature: 5GC001240-A-SyVe- PIM Cancellation - Faults Triggering
    ...  This functionality is provided with feature LTE2863.
    ...  The passive intermodulation (PIM) is a phenomenon that can disturb carrier signal.
    ...  It can be especially harmful for uplink transmission.
    ...  It happens when at least two carriers with different (but close) frequencies are passing through a non-ideal RF cable.
    ...  It can be caused by contaminations, uneven junctions, bad attenuators.
    ...  The algorithm is cancelling only the first two orders of the effect - PIM3 and PIM5.
    ...  Once the algorithm sensitivity is manipulated to catch even thermal noise as PIM,
    ...  one can trigger PIMc alarm (even in a perfect RF environment) and perform this test correctly
    ...
    ...  ***  VARIABLES ***
    ...  RMOD_SN  - RU serial number
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 02.06.2021 - https://jira3.int.net.nokia.com/browse/TAT-21420 - Initial creation

    Set Tags    OWNER-mateusz.kawka@nokia.com
    ...         AUTHOR-mateusz.kawka@nokia.com
    ...         MAINTAINER-mateusz.kawka@nokia.com
    ...         PHASE-CRT
  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_FM_NR_PIMC_Faults_Triggering will be executed
  ...  style=ONGOING

    SiSo_FM_NR_PIMC_Faults_Triggering.step1: Preconditions
    step2: Generate Minor PIMc Alarm
    step3: Reset RFM While Minor PIMc Alarm Is Active
    step4: Generate Minor And Major PIMc Alarm
    step5: Cancel PIMc Alarms
  [Teardown]    Common Test Teardown


step1: Preconditions

    Log to console  ---------------------
    Log to console  Step1: Preconditions
    Log to console  ---------------------${\n}

    ${start_alarms_nr}  admin.Get active alarms number  60  ${node}
    Set Test Variable  ${START_ALARMS_NR}

    ${bts_params} =  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    ${rmods}=  admin.Get Parameters For All  RMOD  alias=${node}

    FOR  ${rmod}  IN  @{rmods}
        Continue For Loop If  '${rmod.serialNumber}'!='${RMOD_SN}'
        ${rmod_name}  Set Variable  ${rmod.productName}
        ${rmod_distname}  Set Variable  ${rmod.id}
    END

    Set Test Variable  ${RMOD_DISTNAME}

    Run Keyword If  '${rmod_distname}'=='${NONE}'
    ...  Fail  Serial Number ${serial_number} not found in HW Configuration ! Test set to Fail !

    ${ru_hw_family}  radio.Get Radio Module Hardware Family  ru_name=${rmod_name}
    ${fid_timeout}  Run Keyword If  '${ru_hw_family}'=='5.1'
    ...  Set Variable  600
    ...  ELSE IF  '${ru_hw_family}'=='6.2'
    ...  Set Variable  3600
    ...  ELSE IF  '${ru_hw_family}'=='8'
    ...  Set Variable  3600
    ...  ELSE  Fail  Test can be run only for RU 5.1 or 6.2 or 8!

    Set Test Variable  ${FID_TIMEOUT}

    ${rmods_info}  admin.Get FRM  60  ${node}
    FOR  ${rmod}  IN  @{rmods_info}
        Continue For Loop If  '${rmod['serialNumber']}'!='${RMOD_SN}'
        ${rmod_config_id}  Set Variable  ${rmod['id']['configuration']}
        ${txrx_ants}  Set Variable  ${rmod['antenaUsageInfo']}
        ${carrier_list}  Set Variable  ${rmod['carrierList']}
    END

    ${TXRX_ANTS_LIST}  Create List
    FOR  ${ants}  IN  @{txrx_ants}
        Run Keyword If  '${ants['direction']}'=='TX/RX'  Append To List  ${TXRX_ANTS_LIST}  ${ants['id']['runtime']}
    END
    Set Test Variable  ${TXRX_ANTS_LIST}

    ${TXRX_ANTS_NR}  Get Length  ${TXRX_ANTS_LIST}
    Set Test Variable  ${PIMC_ALARMS_NR}  ${TXRX_ANTS_NR}
    ${retry_interval}  Evaluate  60-(${PIMC_ALARMS_NR}*5)
    Set Test Variable  ${RETRY_INTERVAL}

    ${CELLS_LIST}  Create List
    FOR  ${cell}  IN  @{carrier_list}
        ${config_cell}  Set Variable  ${cell['id']['configuration']}
        ${cell}  Evaluate  '${config_cell}'.split('/')[2].split('-')[1]
        Run Keyword If  '${cell}' not in @{CELLS_LIST}  Append To List  ${CELLS_LIST}  ${cell}
    END

    ${nr_ids}  Get Cells Mapping By RMOD Id    rat=NR    radio_id=${RMOD_DISTNAME}    alias=${node}
    ${lte_ids}  Get Cells Mapping By RMOD Id    rat=LTE    radio_id=${RMOD_DISTNAME}    alias=${node}

    Run Keyword If  len(${lte_ids})!=0 and len(${nr_ids})==0
    ...  Set Test Variable  ${RAT}  LTE
    ...  ELSE IF
    ...  len(${lte_ids})==0 and len(${nr_ids})!=0
    ...  Set Test Variable  ${RAT}  NR
    ...  ELSE
    ...  Set Test Variable  ${RAT}  NR
#    ...  Fail  LTE and NR cannot be mixed in the same BTS configuration for PIM cancelling test !

#Change above IF to allowed run test when NR and LTE is on the radio, NR will be choosen.


    ${all_cells_dn}  Run Keyword If  '${RAT}'=='NR'
    ...  Set Variable  ${nr_ids}
    ...  ELSE
    ...  Set Variable  ${lte_ids}

    ${CELLS_LIST_DN}  Create List
    FOR  ${cell_dn}  IN  @{all_cells_dn}
        ${cell_number}  Evaluate  '${cell_dn}'.rsplit('-',1)[1]
        Continue For Loop If  '${cell_number}' not in ${CELLS_LIST}
        Append To List  ${CELLS_LIST_DN}  ${cell_dn}
    END

    Set Test Variable  ${CELLS_LIST}
    Set Test Variable  ${CELLS_LIST_DN}

    ${rmod_number}  Evaluate  '${rmod_config_id}'.rsplit('-',1)[1]
    ${query_path}  Set Variable  /MRBTS-*/RAT-*/BTS_L-*/BTS_CONF-*/NP-*/SCF-*/MRBTS_A-*/EQM_A-*/APEQM_A-*/RMOD_A-${rmod_number}
    Set Test Variable  ${PIMC_OBJECT}  MRBTS-${BTS_ID}/EQM-1/APEQM-1/RMOD-${rmod_number}

    ${rmod_object}  admin_im.Query Infomodel  get object ${query_path}   allow_negative_result=True  alias=${node}
    ${act_pim_can}  Set Variable  ${rmod_object.actPimCancellation}
    ${pim_can_ena}  Set Variable  ${rmod_object.pimCancellingEnabled}

    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${act_pim_can}  True
    ...  actPimCancellation must be set to False before TC run !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Log to console  actPimCancellation now is set to False, recommissioning to True !${\n}
    ...  AND  Perform Parameter Recommissioning  ${PIMC_OBJECT}  actPimCancellation  update  true  alias=${node}

    Sleep  3s
    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${pim_can_ena}  True
    ...  pimCancellingEnabled must be set to False before TC run !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Log to console  pimCancellingEnabled now is set to False, recommissioning to True !${\n}
    ...  AND  Perform Parameter Recommissioning  ${PIMC_OBJECT}  pimCancellingEnabled  update  true  alias=${node}

    ${rmod_object}  admin_im.Query Infomodel  get object ${query_path}   allow_negative_result=True  alias=${node}
    ${pim_can_ena}  Set Variable  ${rmod_object.pimCancellingEnabled}

    ${status}  Run Keyword And Return Status  Should Be Equal As Strings  ${pim_can_ena}  True
    ...  pimCancellingEnabled cannot be set to True via API !  values=False
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Perform Parameter Recommissioning  ${PIMC_OBJECT}  actPimCancellation  update  false  alias=${node}
    ...  AND  Fail  Cannot set pimCancellingEnabled to true via API ! Set TC fail !

    Log to console  All preconditions met, going to next step!${\n}

step2: Generate Minor PIMc Alarm

    Log to console  -----------------------------------------------
    Log to console  Step2: Generate Minor PIMc Alarm
    Log to console  -----------------------------------------------${\n}

    Log to console  Setting PIMC Alarm Thresholds: minor=-180 and major=-30 ...${\n}
    SiSo_FM_NR_PIMC_Faults_Triggering.Set PIMC Alarm Thresholds  minor=-180  major=-30

    Log To Console  Waiting ${FID_TIMEOUT}s for active alarm 1999 in a minute intervals, please wait!
    ${alarm_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FID_TIMEOUT}s  ${RETRY_INTERVAL}s
    ...  Wait For Alarm And Check  Active  ${TXRX_ANTS_LIST}  1999  Minor
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log to console  Minor alarm 1999 is active for TX antenna lines !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Minor alarm 1999 is NOT active for TX antenna line(s)

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log to console  All cells are onAir !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Cell(s) are not onAir during fault 1999

    Log to console  Checking unexpected alarms... !${\n}
    ${alarms_nr}  admin.Get active alarms number  60  ${node}
    ${expected_alarms_status}  Evaluate  ${alarms_nr}==${START_ALARMS_NR}+${PIMC_ALARMS_NR}
    Run Keyword If  '${expected_alarms_status}'=='True'
    ...  Log to console  No other unexpected alarms !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Probably unexpected alarm(s) appeared ! Check logs !


step3: Reset RFM While Minor PIMc Alarm Is Active
    Log to console  --------------------------------------------------
    Log to console  step3: Reset RFM While Minor PIMc Alarm Is Active
    Log to console  --------------------------------------------------${\n}

    Log to console  Performing RMOD ${RMOD_SN} hard reset, please wait !${\n}
    ${reset_status}  Run Keyword And Return Status
    ...  admin.Reset Unit  dist_name=${RMOD_DISTNAME}  timeout=300  alias=${node}
    Run Keyword If  '${reset_status}'=='True'
    ...  Log to console  Hard Unit ${RMOD_SN} reset successfully!${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Unit hard reset unsuccessfuly

    Log To Console  Waiting ${FID_TIMEOUT}s for active alarm 1999 in a minute intervals, please wait!
    ${alarm_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FID_TIMEOUT}s  ${RETRY_INTERVAL}s
    ...  Wait For Alarm And Check  Active  ${TXRX_ANTS_LIST}  1999  Minor
    Run Keyword If  '${alarm_status}'=='True'
    ...  Log to console  Minor alarm 1999 is active for TX antenna lines !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Minor alarm 1999 is NOT active for TX antenna line(s)

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log to console  All cells are onAir !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Cell(s) are not onAir after hard unit reset!

    Log to console  Checking unexpected alarms... !${\n}
    ${alarms_nr}  admin.Get active alarms number  60  ${node}
    ${expected_alarms_status}  Evaluate  ${alarms_nr}==${START_ALARMS_NR}+${PIMC_ALARMS_NR}
    Run Keyword If  '${expected_alarms_status}'=='True'
    ...  Log to console  No other unexpected alarms !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Probably unexpected alarm(s) appeared ! Check logs !

step4: Generate Minor And Major PIMc Alarm

    Log to console  -------------------------------------------
    Log to console  step4: Generate Minor And Major PIMc Alarm
    Log to console  -------------------------------------------${\n}

    Log to console  Setting PIMC Alarm Thresholds: minor=-180 and major=-179 ...${\n}
    SiSo_FM_NR_PIMC_Faults_Triggering.Set PIMC Alarm Thresholds  minor=-180  major=-179

    Log To Console  Waiting ${FID_TIMEOUT}s for active alarm 1999 in a minute intervals, please wait!
    ${alarm1_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FID_TIMEOUT}s  ${RETRY_INTERVAL}s
    ...  Wait For Alarm And Check  Active  ${TXRX_ANTS_LIST}  1999  Minor
    Run Keyword If  '${alarm1_status}'=='True'
    ...  Log to console  Minor alarm 1999 is active for TX antenna lines !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Minor alarm 1999 is NOT active for TX antenna line(s)

    Log To Console  Waiting ${FID_TIMEOUT}s for active alarm 2900 in a minute intervals, please wait!
    ${alarm2_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FID_TIMEOUT}s  ${RETRY_INTERVAL}s
    ...  Wait For Alarm And Check  Active  ${TXRX_ANTS_LIST}  2900  Major
    Run Keyword If  '${alarm2_status}'=='True'
    ...  Log to console  Minor alarm 2900 is active for TX antenna lines !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Minor alarm 2900 is NOT active for TX antenna line(s)

    ${cell_status_list}  Create List
    FOR  ${cell}  IN  @{CELLS_LIST_DN}
        ${cell_status}=  Run Keyword And Return Status
        ...  Run Keyword If  '${RAT}' == 'NR'
        ...  admin.Assert  NRCEL  ${cell}  availabilityStatus=regex"(?i)Degraded"   timeout=60s  alias=${node}
        ...  ELSE
        ...  admin.Assert  LNCEL  ${cell}  availabilityStatus=regex"(?i)Degraded"   timeout=60s  alias=${node}
        Run Keyword If  '${cell_status}'=='False'  Run Keywords  Log to console  ${cell} doesn't meet the conditions!
        ...  AND  Append To List  ${cell_status_list}  False
        ...  ELSE  Log To Console  ${cell} is Degraded
    END

    ${degraded_status}  Run Keyword And Return Status  Should be empty  ${cell_status_list}
    Run Keyword If  '${degraded_status}'=='True'
    ...  Log to console  All impacted cells are Degraded !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Impacted cell(s) are not Degraded during 2900 fault!

    Log to console  Checking unexpected alarms... !${\n}
    ${alarms_nr}  admin.Get active alarms number  60  ${node}
    ${expected_alarms_status}  Evaluate  ${alarms_nr}==${START_ALARMS_NR}+(${PIMC_ALARMS_NR}*2)
    Run Keyword If  '${expected_alarms_status}'=='True'
    ...  Log to console  No other unexpected alarms !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Probably unexpected alarm(s) appeared ! Check logs !

step5: Cancel PIMc Alarms
    Log to console  -------------------------------------------
    Log to console  step5: Cancel PIMc Alarms
    Log to console  -------------------------------------------${\n}

    Log to console  Setting PIMC Alarm Thresholds: minor=-31 and major=-30 ...${\n}
    SiSo_FM_NR_PIMC_Faults_Triggering.Set PIMC Alarm Thresholds  minor=-31  major=-30

    Log To Console  Waiting ${FID_TIMEOUT}s for inactive alarm 1999 in ${RETRY_INTERVAL}s intervals, please wait!
    ${alarm1_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FID_TIMEOUT}s  ${RETRY_INTERVAL}s
    ...  Wait For Alarm And Check  Inactive  ${TXRX_ANTS_LIST}  1999  Minor
    Run Keyword If  '${alarm1_status}'=='True'
    ...  Log to console  Minor alarm 1999 is inactive for TX antenna lines !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Minor alarm 1999 is still active for TX antenna line(s)

    Log To Console  Waiting ${FID_TIMEOUT}s for inactive alarm 2900 in ${RETRY_INTERVAL}s intervals, please wait!
    ${alarm2_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  ${FID_TIMEOUT}s  ${RETRY_INTERVAL}s
    ...  Wait For Alarm And Check  Inactive  ${TXRX_ANTS_LIST}  2900  Major
    Run Keyword If  '${alarm2_status}'=='True'
    ...  Log to console  Minor alarm 2900 is inactive for TX antenna lines !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Minor alarm 2900 is still active for TX antenna line(s)

    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log to console  All cells are onAir !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Cell(s) are not onAir after hard unit reset!

    ${rmod_status}  Run Keyword And Return Status
    ...  admin.Assert  RMOD  ${RMOD_DISTNAME}  operationalState=regex"(?i)enabled"  alias=${node}
    Run Keyword If  '${rmod_status}'=='True'
    ...  Log to console  RMOD ${RMOD_SN} is Enabled !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=RMOD ${RMOD_SN} is not Online after alarms cancelling!

    Log to console  Checking unexpected alarms... !${\n}
    ${alarms_nr}  admin.Get active alarms number  60  ${node}
    ${expected_alarms_status}  Evaluate  ${alarms_nr}==${START_ALARMS_NR}
    Run Keyword If  '${expected_alarms_status}'=='True'
    ...  Log to console  No other unexpected alarms !${\n}
    ...  ELSE  Disable PIMC When TC Fail
    ...  fail_msg=Probably unexpected alarm(s) appeared ! Check logs !

    Log to console  TC passed, deactivation PIMC feature...!${\n}
    SiSo_FM_NR_PIMC_Faults_Triggering.Perform Recommissioning FOR PIMC  false


Perform Recommissioning For PIMC
    [Arguments]  ${activate_flag}

    admin.Perform Parameter Recommissioning  ${PIMC_OBJECT}  actPimCancellation  update   ${activate_flag}  alias=${node}
    admin.Perform Parameter Recommissioning  ${PIMC_OBJECT}  pimCancellingEnabled  update  ${activate_flag}  alias=${node}

Disable PIMC When TC Fail
    [Arguments]  ${fail_msg}

    Log to console  ${fail_msg}, disabling PIMC feature, please wait !
    SiSo_FM_NR_PIMC_Faults_Triggering.Perform Recommissioning For PIMC  false
    SiSo_FM_NR_PIMC_Faults_Triggering.Set PIMC Alarm Thresholds  minor=-31  major=-30
    Fail  ${fail_msg}, set test fail !${\n}

Wait For Alarm And Check
    [Arguments]  ${active_state}  ${NOTIFIER_LIST}  ${faultId}  ${severity}

    ${status_list}  Create List
    admin.Add Allowed Alarm  faultId=${faultId}  connection=${node}
    FOR  ${ant}  IN  @{NOTIFIER_LIST}
        ${status}  Run Keyword And Return Status  admin.Assert alarm ${active_state}
        ...  faultId=${faultId}, severity=${severity}, notifier=regex".*${ant}.*"  timeout=5  alias=${node}
        Run Keyword If  '${status}'=='False'
        ...  Append To List  ${status_list}  ${status}
    END

    Log To Console  Still waiting for ${active_state.lower()} alarm ${faultId}...

    Should be empty  ${status_list}


Set PIMC Alarm Thresholds
    [Arguments]  ${minor}  ${major}

    admin.Create Delta
    admin.Append Parameter Update To Delta  ${PIMC_OBJECT}  intPIMLevelMeasurementMajorThreshold  ${major}
    admin.Append Parameter Update To Delta  ${PIMC_OBJECT}  intPIMLevelMeasurementMinorThreshold  ${minor}
    ${delta}  admin.Get Delta
    admin.Perform Delta Recommissioning     ${delta}
    ...                               alias=${node}
    admin.Remove Delta

