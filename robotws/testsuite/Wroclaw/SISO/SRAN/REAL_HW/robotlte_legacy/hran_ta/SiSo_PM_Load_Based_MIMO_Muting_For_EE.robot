*** Settings ***
Documentation
...  TC is checking if CB008392 which provides the RAN level requirements of half of DL TX paths can be dynamically muted / unmuted
...  to save energy in low load conditions is working corretly

Resource    resources/ca_BSRF_general.robot

Library    taf.sbts.oam.coam.admin  WITH NAME  admin
Library    taf.ul.energy_efficiency_monitoring    WITH NAME    ee_monitoring

*** Variables ***

${CELL_ID}
${node}  default
${EE_INTERVAL}  15min

*** Keywords ***
TC__SiSo_PM_Load_Based_MIMO_Muting_For_EE
    [Documentation]
    ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12272
    ...
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  CB008392 provide the RAN level requirements of half of DL TX paths can be dynamically muted / unmuted
    ...  to save energy in low load conditions.
    ...  This feature is applied to non-beamforming MIMO configurations with 4T4R, 6T6R or 8T8R radio unit
    ...  and beamforming MIMO configurations with 8T8R radio unit.
    ...  Preconditions for TC execution is prepare scf file with configured NRPGRP with lbpsPeriodList
    ...  TC activates feature by set actNrLBRTXPowerSaving to true
    ...  and checks if energySavingState is changing to reducedEnergySaving
    ...  *In next step carriers power is checked.
    ...  *It's expected that some of carriers will have power value equal to "OFF" which means that it's muted.
    ...
    ...  *Applicable only to RU release >= 5.1
    ...
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 20.08.2022 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-12272 - Initial creation

    Set Tags    OWNER-mateusz.kawka@nokia.com
    ...         AUTHOR-mateusz.kawka@nokia.com
    ...         MAINTAINER-mateusz.kawka@nokia.com
    ...         PHASE-CRT

  Common Test Setup
  Logging With Timestamp
  ...  message=TC__SiSo_PM_Load_Based_MIMO_Muting_For_EE will be executed
  ...  style=ONGOING

    step1: Preconditions
    step2: Enable MIMO Muting Feature
    step3: Disable MIMO Muting Feature
  [Teardown]    Common Test Teardown


step1: Preconditions
    Logging With Timestamp
    ...  message=step1: Preconditions
    ...  style=STEP
    ...  frame=${TRUE}

    ee_monitoring.configure_bts_connection
    ee_monitoring.enable_energy_efficiency_monitoring

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}

    Set Test Variable  ${object_variable_actNrLBRTXPowerSaving}  MRBTS-${bts_id}/NRBTS-${bts_id}

    ${nr_cells}  admin.Get Cells Info  nr  connection=${node}
    FOR  ${cell}  IN  @{nr_cells}
        Run Keyword If  '${cell['globalCellId']}'=='${CELL_ID}'  Run Keywords
        ...  Set Test Variable  ${DISABLED_EST}  ${cell['energySavingState']}
        ...  AND  Set Test Variable  ${CELL_DISTNAME}  ${cell['id']['internal']}
        ...  AND  Set Test Variable  ${RMOD_ID}  ${cell['carrierList'][0]['antennaLineId']['internal']}
        ...  AND  Exit For Loop
    END

    Run Keyword If  '${RMOD_ID}'=='${EMPTY}'
    ...  Fail  NR Cell ID ${CELL_ID} cannot be found in configuration !

    Run Keyword If  '${DISABLED_EST}'!='notEnergySaving'
    ...  Fail  Features for energy saving have to be disabled before TC execution !
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=Feature for Reduce Energy Saving on NR cell ${CELL_ID} is disabled

    ${RMOD_ID}  Evaluate  '${RMOD_ID}'.rsplit('/', 1)[0]
    ${rmod_sn}  Get RU Serial Number For DistName  ${RMOD_ID}  alias=${node}
    Set Test Variable  ${RMOD_SERIAL_NUMBER}  ${rmod_sn}

    ${hw_release}=  IF  '${CFG['RF_INFO']['${rmod_sn}']['scf_release_code']}'=='RRH-ORAN'
    ...  radio.Get Radio Module Hardware Family  ru_name=${CFG['RF_INFO']['${rmod_sn}']['scf_variant']}
    ...  ELSE
    ...  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${CFG['RF_INFO']['${rmod_sn}']['scf_release_code']}').group(0)  re
    Set Test Variable  ${HW_RELEASE}  ${hw_release}

    Return From Keyword If  ${HW_RELEASE}<5.1

    Logging With Timestamp
    ...  message=TX power measurement in progress ...
    ${carriers_power_prec_disabled}  radio.Get Carriers Power
    ...    ru_serial_number=${rmod_sn}
    ...    direction=TX

    Set Test Variable  ${CARRIERS_POWER_PREC_DISABLED}

    ${ref_nr_carriers_power}  Get NR Carriers Power List  ${carriers_power_prec_disabled}
    Set Test Variable  ${REF_NR_CARRIERS_POWER_LIST}  ${ref_nr_carriers_power}


step2: Enable MIMO Muting Feature
    Logging With Timestamp
    ...  message=step2: Enable MIMO Muting Feature
    ...  style=STEP
    ...  frame=${TRUE}
    Parameters Recommissioning For MIMO Muting  true

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'  Run Keywords
    ...  Parameters Recommissioning For MIMO Muting  false
    ...  AND  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=All cells are onAir

    Sleep  60s
    ${cell_info}  admin.Get Cell Specific Info  ${CELL_DISTNAME}  connection=${node}

    Run Keyword If  '${cell_info['energySavingState']}'!='reducedEnergySaving'  Run Keywords
    ...  Logging With Timestamp
    ...  message=Feature activated but energySavingState is still other than reducedEnergySaving
    ...  AND  Parameters Recommissioning For MIMO Muting  false
    ...  AND  Fail  Feature activated but energySavingState is still other than reducedEnergySaving !
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=Feature activated properly, cell ${CELL_ID} energySavingState = reducedEnergySaving

    Return From Keyword If  ${hw_release}<5.1

    Logging With Timestamp
    ...  message=TX power measurement after feature activation in progress ...
    ${carriers_power_enabled}  radio.Get Carriers Power
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    direction=TX

    ${reduced_carriers_power_list}  Get NR Carriers Power List  ${carriers_power_enabled}

    FOR  ${ref_power}  ${reduced_power}  IN ZIP  ${REF_NR_CARRIERS_POWER_LIST}  ${reduced_carriers_power_list}
        Logging With Timestamp
        ...  message=Muting disabled: ${ref_power} -> after muting enabled: ${reduced_power}
    END

    ${off_carriers_in_reduced}  Evaluate  ${reduced_carriers_power_list}.count('OFF')
    ${off_carriers_in_reference}  Evaluate  ${REF_NR_CARRIERS_POWER_LIST}.count('OFF')

    Run Keyword If  ${off_carriers_in_reduced}>${off_carriers_in_reference}
    ...  Logging With Timestamp
    ...  message=TX Muting done OK, going to deactivation step
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=reducedEnergySaving on cell, but no TX muting on RMOD
    ...  AND  Parameters Recommissioning For MIMO Muting  false
    ...  AND  Fail  reducedEnergySaving on cell, but no TX muting on RMOD !

    Logging With Timestamp
    ...  message=Getting counters for EEM when MIMO Muting is activated
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.start_measurement_period  ee_features_status=enabled  interval=${EE_INTERVAL}

    Sleep    5min

    ee_monitoring.stop_measurement_period    ee_features_status=enabled
    ee_monitoring.wait_for_next_pm_period    interval=${EE_INTERVAL}
    ee_monitoring.save_energy_consumption_counters_values    ee_features_status=enabled
    ...  filepath=${OUTPUT DIR}/enabled_features_log.json

step3: Disable MIMO Muting Feature

    Logging With Timestamp
    ...  message=step3: Disable MIMO Muting Feature
    ...  style=STEP
    ...  frame=${TRUE}
    Parameters Recommissioning For MIMO Muting  false

    ${status}  Run Keyword And Return Status  Check If All Cells Are onAir  alias=${node}
    Run Keyword If  '${status}'=='False'
    ...  Fail  Cells are not onAir after recommissioning! Feature deactivated and set test failed !
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=All cells are onAir

    Sleep  60s
    ${cell_info}  admin.Get Cell Specific Info  ${CELL_DISTNAME}  connection=${node}

    Run Keyword If  '${cell_info['energySavingState']}'!='notEnergySaving'  Run Keywords
    ...  Logging With Timestamp
    ...  message=Feature deactivated but energySavingState is still other than notEnergySaving
    ...  AND  Parameters Recommissioning For MIMO Muting  false
    ...  AND  Fail  Feature deactivated but energySavingState is still other than notEnergySaving !
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=Feature deactivated properly, cell ${CELL_ID} energySavingState = notEnergySaving

    Return From Keyword If  ${hw_release}<5.1

    Logging With Timestamp
    ...  message=TX power measurement after feature deactivation in progress ...
    ${carriers_power_disabled}  radio.Get Carriers Power
    ...    ru_serial_number=${RMOD_SERIAL_NUMBER}
    ...    direction=TX

    ${not_reduced_carriers_power_list}  Get NR Carriers Power List  ${carriers_power_disabled}

    FOR  ${ref_power}  ${reduced_power}  IN ZIP  ${REF_NR_CARRIERS_POWER_LIST}  ${not_reduced_carriers_power_list}
        Logging With Timestamp
        ...  message=Muting disabled: ${ref_power} -> after muting enabled: ${reduced_power}
    END

    ${off_carriers_in_not_reduced}  Evaluate  ${not_reduced_carriers_power_list}.count('OFF')
    ${off_carriers_in_reference}  Evaluate  ${REF_NR_CARRIERS_POWER_LIST}.count('OFF')

    Run Keyword If  ${off_carriers_in_not_reduced}==${off_carriers_in_reference}
    ...  Logging With Timestamp
    ...  message=TX Unmuting done OK, TC passed
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=notEnergySaving on cell, but no TX unmuting on RMOD
    ...  AND  Fail  notEnergySaving on cell, but no TX unmuting on RMOD !

    Logging With Timestamp
    ...  message=Getting counters for EEM when MIMO Muting is deactivated
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.start_measurement_period  ee_features_status=disabled  interval=${EE_INTERVAL}

    Sleep    5min
    Logging With Timestamp
    ...  message=Saving counters for EEM (MIMO Muting disabled) and getting the difference
    ee_monitoring.stop_measurement_period  ee_features_status=disabled
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.save_energy_consumption_counters_values  ee_features_status=disabled
    ...    filepath=${OUTPUT DIR}/disabled_features_log.json
    ee_monitoring.get_counters_difference_for_enabled_disabled_features

Get NR Carriers Power List
    [Arguments]  ${power_dict}
    [Documentation]
    ...  KW for extract list of NR carriers power from carrier power dictionary
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    ${nr_power_list}  Create List
    FOR  ${ant}  ${carriers}  IN ZIP  ${power_dict.keys()}  ${power_dict.values()}
        ${nr_power}  Evaluate  [ str(v) for k,v in ${carriers}.items() if k.startswith('N')]
        Append To List  ${nr_power_list}  ${nr_power}
    END

    ${nr_power_list}  Evaluate  [i for sublist in ${nr_power_list} for i in sublist]

    [Return]  ${nr_power_list}

Parameters Recommissioning For MIMO Muting
    [Arguments]  ${param_actNrLBRTXPowerSaving}
    [Documentation]
    ...  KW for recommissioning CB008392
    ...
    ...  | **Author:** mateusz.kawka@nokia.com
    ...  | **Maintainer:** mateusz.kawka@nokia.com

    Logging With Timestamp
    ...  message=Updating actNrLBRTXPowerSaving parameter to -> ${param_actNrLBRTXPowerSaving}, please wait ...

    Perform Parameter Recommissioning
    ...  dist_name=${object_variable_actNrLBRTXPowerSaving}
    ...  parameter=actNrLBRTXPowerSaving
    ...  operation=update
    ...  value=${param_actNrLBRTXPowerSaving}
    ...  skip_parameter_relation_errors=True
    ...  alias=${node}


