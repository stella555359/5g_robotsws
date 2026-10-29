*** Settings ***
Documentation
  ...  The purpose of this test case is check impact of feature microDTX on LTE cells.
  ...  [CASE LINK]: https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-32473
  ...
  ...  *****************
  ...  Basic information
  ...  *****************
  ...  The purpose of this test case is to check impact of the feature microDTX on LTE cells.
  ...  The test is related to the project: energy efficiency and was created as a refactoring of existing tests using
  ...  microDTX: Micro discontinuous transmission - Power saving.
  ...  Test case involves activating and deactivating feature, checks RM with HW release 5.1 and 6.2.
  ...  Feature is activated when R&D flag 0x480081 is set to 1 or parameter 'actMicroDtx' and 'allowTrafficConcentrarion' are set on 'true'.
  ...  Parameters of 5G microDTX need to be deactivated - 'actMicroDTX' and 'actMicroDTXAdvanced'
  ...  are disabled during the test.
  ...  Test case checks if RMOD's power is lower, when feature is activated.
  ...  TC also checks whether the feature operation is independent of the SCF configuration when the R&D flag is active.
  ...  IMPORTANT:
  ...  The user must set the correct parameter values in SCF to activate the feature without relations error - e.g. 'siWindowLen'.
  ...
  ...  ******************
  ...  History of changes
  ...  ******************
  ...  - 08.10.2025 - https://jiradc.ext.net.nokia.com/browse/FCA_VRF_SISO-32473 - Initial creation
  ...  - 04.12.2025 - add change for ORAN RMOD

Resource  ./../../Resources/Setup/setup_and_teardown.robot

*** Variables ***
${RMOD_SN}                                 # RU serial number where LTE cells for activated MicroDtx are deployed.
${RECOMMISSIONING_TIMEOUT}     600         # Timeout for recommissioning procedure

*** Keywords ***
TC__PM_LTE_uDTX

    Set Tags
    ...    OWNER-lukasz.wystup@nokia.com
    ...    AUTHOR-lukasz.wystup@nokia.com
    ...    MAINTAINER-lukasz.wystup@nokia.com
    ...    FEATURE-CB013962

    Common Test Setup
    Step1: Preconditions For LTE mDTX
    Step2: Activate MicroDTX - SBTS Recommissioning
    Step3: Activate MicroDTX via R&D Flag
    Step4: Check RMOD Power Consumption When MicroDTX Is Activated
    Step5: Deactivate MicroDTX - SBTS Recommissioning
    Step6: Check RMOD Power Consumption When MicroDTX SCF Is Deactivated And Compare
    Step7: Deactivate MicroDTX via R&D Flag
    Step8: Check RMOD Power Consumption When MicroDTX Is Deactivated Via R&D Flag And Compare
    [Teardown]  Teardown_PM_LTE_uDTX

Step1: Preconditions For LTE mDTX
    Logging With Timestamp
    ...  message=Step1: Preconditions For LTE mDTX
    ...  style=STEP
    ...  frame=${TRUE}

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}
    Set Test Variable  ${BTS_ID}  ${CFG['primary_node_bts_id']}
    Set Test Variable  ${FEATCADM_OBJECT}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1
    ${ru_params}  RM Verify Serial Number  serial_number=${RMOD_SN}  connection=${BTS_ID}
    Logging With Timestamp  RMOD with SN -> ${RMOD_SN} found in HW Configuration
    Set Test Variable  ${RMOD_DISTNAME_ID}  ${ru_params['id']}

    Logging With Timestamp  message=Getting information about RMOD release.
    IF  '${cfg.RF_INFO['${RMOD_SN}']['scf_release_code']}'=='RRH-ORAN'
      Logging With Timestamp  message=HW release is RRH-ORAN.
    ELSE
      Check RMOD HW Release
    END
    ${par_actPowerMeter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  connection=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${par_actPowerMeter}
    ${apm_status}  Evaluate Xpath  ${scfc_xml}
    ...     string(.//managedObject[@distName="MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1"]/p[@name='actPowerMeter']/text())
    Set Test Variable  ${ACTPOWERM_STATUS}  ${apm_status}

    IF  '${ACTPOWERM_STATUS}'=='false'
      Logging With Timestamp  actPowerMeter is set to false, recommissioning to true...
      admin.Perform Parameter Recommissioning
      ...  dist_name=${FEATCADM_OBJECT}
      ...  parameter=actPowerMeter
      ...  operation=update
      ...  value=true
      ...  connection=${BTS_ID}
    ELSE
      Logging With Timestamp  actPowerMeter already set to true, recommissioning not needed.
    END

    ${cells_status}  Run Keyword And Return Status  STATE Verify States For All  class=LNCEL  node_id=${BTS_ID}  scf_check=${FALSE}  timeout=120
    IF  '${cells_status}'=='True'
      Logging With Timestamp  All cells are onAir!  style=DONE
    ELSE
      Logging With Timestamp  message=Cells are not onAir!  style=ERROR
      Fail  Cells are not onAir!
    END

    Logging With Timestamp  message=Getting information about cells.
    ${lte_cells_distnames}  RM Get Cells Mapping By RMOD Id  LTE  ${RMOD_DISTNAME_ID}  connection=${BTS_ID}
    @{CELLS_ID}  Create List  @{EMPTY}
    FOR  ${lncel}  IN  @{lte_cells_distnames}
      ${lncel}  Fetch From Right  ${lncel}  -
      Append To List  ${CELLS_ID}  ${lncel}
    END
    Should Not Be Empty  ${CELLS_ID}  msg=No LTE cells found on RMOD with SN ${RMOD_SN}!
    Set Test Variable  ${CELLS_ID}

    Logging With Timestamp  Checking if 5G MicroDtx needs to be disabled
    ${5G_info}  admin.Get parameters for all  class_name=NRCEL  connection=${BTS_ID}
    ${5G_availability}  Run Keyword And Return Status  Should Contain  ${5G_info[0].id}  NRBTS
    IF  '${5G_availability}'=='True'
      Logging With Timestamp  There are NRCEL(s) on BTS, disabling MicroDtx for 5G will be performed
      Deactivate 5G MicroDtx By SCF
    ELSE
      Logging With Timestamp  There is no need to disable 5G MicroDtx.
    END
    Set Test Variable  ${5G_AVAILABILITY}

Step2: Activate MicroDTX - SBTS Recommissioning
    Logging With Timestamp
    ...  message=Step2: Activate MicroDTX - SBTS Recommissioning
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Updating parameters actMicroDtx=true and allowTrafficConcentration=true for LNCEL(s).
    admin.Create Delta  delta_id=${BTS_ID}
    FOR  ${test_cell}  IN  @{CELLS_ID}
      Logging With Timestamp  MicroDTX of ${test_cell} is going to be activated.
      admin.Append Parameter Update To Delta
      ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}
      ...  parameter=actMicroDtx
      ...  value=true
      ...  delta_id=${BTS_ID}
      admin.Append Parameter Update To Delta
      ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}
      ...  parameter=allowTrafficConcentration
      ...  value=true
      ...  delta_id=${BTS_ID}
    END
    PM_LTE_uDTX.Perform recommissioning
    admin.Remove Delta  delta_id=${BTS_ID}

    Logging With Timestamp  Checking if MicroDTX is activated for tested cells.
    ${dict_status_dtx}  Check Status Of LTE microDTX
    ${dict_status_aTC}  Check Status Of allowTrafficConcentration
    ${dtx_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_dtx}  false
    ${aTC_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_aTC}  false
    IF  '${dtx_status}'=='True' and '${aTC_status}'=='True'
      Logging With Timestamp  MicroDTX is activated properly!
    ELSE
      Logging With Timestamp  message=MicroDTX is not activated properly!  style=ERROR
      Fail  MicroDTX is not activated properly!
    END

Step3: Activate MicroDTX via R&D Flag
    Logging With Timestamp
    ...  message=Step3: Activate MicroDTX via R&D Flag
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Change value R&D flag to 0x480081 = 1 #rdActMicroDtxLTE
    admin.Change Bts Rad Parameters With Overreset  component=72  params=129:1  connection=${BTS_ID}
    Perform Site Reset

Step4: Check RMOD Power Consumption When MicroDTX Is Activated
    Logging With Timestamp
    ...  message=Step4: Check RMOD Power Consumption When MicroDTX Is Activated
    ...  style=STEP
    ...  frame=${TRUE}

    ${CELL_RMOD_POWER}  Create List  @{EMPTY}
    Set Test Variable  ${CELL_RMOD_POWER}
    ${measurements}  admin.Get Measurements  measurement_type=realTime  connection=${BTS_ID}
    FOR  ${cell_id}  IN  @{CELLS_ID}
      ${rmod_number}  Fetch From Right  ${RMOD_DISTNAME_ID}  /
      ${power_DTX_activated}  PM Rmod Get Measurement  measurements=${measurements}  rmod_number=${rmod_number}
      ${dict}  Create Dictionary  LNCEL=${cell_id}  RMOD=${RMOD_DISTNAME_ID}  P_mdtx[W]=${power_DTX_activated}
      Logging With Timestamp  ${dict}
      Append To List  ${CELL_RMOD_POWER}  ${dict}
    END

Step5: Deactivate MicroDTX - SBTS Recommissioning
    Logging With Timestamp
    ...  message=Step5: Deactivate MicroDTX - SBTS Recommissioning
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Updating parameters actMicroDtx=false and allowTrafficConcentration=false for LNCEL(s).
    admin.Create Delta  delta_id=${BTS_ID}
    FOR  ${test_cell}  IN  @{CELLS_ID}
      Logging With Timestamp  MicroDTX of ${test_cell} is going to be deactivated
      admin.Append Parameter Update To Delta
      ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}
      ...  parameter=actMicroDtx
      ...  value=false
      ...  delta_id=${BTS_ID}
      admin.Append Parameter Update To Delta
      ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}
      ...  parameter=allowTrafficConcentration
      ...  value=false
      ...  delta_id=${BTS_ID}
    END
    PM_LTE_uDTX.Perform recommissioning
    admin.Remove Delta  delta_id=${BTS_ID}

    Logging With Timestamp  Checking if MicroDTX is deactivated for tested cells.
    ${dict_status_dtx}  Check Status Of LTE microDTX
    ${dict_status_aTC}  Check Status Of allowTrafficConcentration
    ${dtx_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_dtx}  true
    ${aTC_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_aTC}  true
    IF  '${dtx_status}'=='True' and '${aTC_status}'=='True'
      Logging With Timestamp  MicroDTX is deactivated properly!
    ELSE
      Logging With Timestamp  message=MicroDTX for is not deactivated properly!  style=ERROR
      Fail  MicroDTX for is not deactivated properly!
    END

Step6: Check RMOD Power Consumption When MicroDTX SCF Is Deactivated And Compare
    Logging With Timestamp
    ...  message=Step6: Check RMOD Power Consumption When MicroDTX SCF Is Deactivated And Compare
    ...  style=STEP
    ...  frame=${TRUE}

    ${measurements}  admin.Get Measurements  measurement_type=realTime  connection=${BTS_ID}
    FOR  ${items}  IN  @{CELL_RMOD_POWER}
      ${rmod}  Get From Dictionary  ${items}  RMOD
      ${rmod_number}  Fetch From Right  ${rmod}  /
      ${power_DTX_SCF_deactivated}  PM Rmod Get Measurement  measurements=${measurements}  rmod_number=${rmod_number}
      ${power_DTX_activated}  Get From Dictionary  ${items}  P_mdtx[W]
      Set To Dictionary  ${items}  P[W]=${power_DTX_SCF_deactivated}
      Logging With Timestamp  ${items}
      ${power_diff_status}  Evaluate  ${power_DTX_activated}+2 > ${power_DTX_SCF_deactivated}
      IF  ${power_diff_status}
        Logging With Timestamp  Power is correct - simillar value regardless of SCF parameter setting MicroDTX.
      ELSE
        Logging With Timestamp  message=Power change value after deactivation of MicroDTX in SCF.  style=ERROR
        Fail  Power change value after deactivation of MicroDTX in SCF.
      END
    END

Step7: Deactivate MicroDTX via R&D Flag
    Logging With Timestamp
    ...  message=Step7: Deactivate MicroDTX via R&D Flag
    ...  style=STEP
    ...  frame=${TRUE}

    Logging With Timestamp  Change value R&D flag to 0x480081 = 0 #rdActMicroDtxLTE
    admin.Change Bts Rad Parameters With Overreset  component=72  params=129:0  connection=${BTS_ID}
    Perform Site Reset

Step8: Check RMOD Power Consumption When MicroDTX Is Deactivated Via R&D Flag And Compare
    Logging With Timestamp
    ...  message=Step8: Check RMOD Power Consumption When MicroDTX Is Deactivated Via R&D Flag And Compare
    ...  style=STEP
    ...  frame=${TRUE}

    ${measurements}  admin.Get Measurements  measurement_type=realTime  connection=${BTS_ID}
    FOR  ${items}  IN  @{CELL_RMOD_POWER}
      ${rmod}  Get From Dictionary  ${items}  RMOD
      ${rmod_number}  Fetch From Right  ${rmod}  /
      ${power_DTX_deactivated}  PM Rmod Get Measurement  measurements=${measurements}  rmod_number=${rmod_number}
      ${power_DTX_activated}  Get From Dictionary  ${items}  P_mdtx[W]
      Set To Dictionary  ${items}  P[W]=${power_DTX_deactivated}
      Logging With Timestamp  ${items}
      ${power_diff_status}  Evaluate  ${power_DTX_activated}+5 < ${power_DTX_deactivated}
      IF  ${power_diff_status}
        Logging With Timestamp  Power is correct - higher after dectivating MicroDTX.
      ELSE
        Logging With Timestamp  message=Power did not increase enough after deactivation of MicroDTX.  style=ERROR
        Fail  Power did not increase enough after deactivation of MicroDTX.
      END
    END

Check RMOD HW Release
    ${hw_release}  Evaluate  re.search(r'\\d+\\.\\d+\|d+', '${cfg.RF_INFO['${RMOD_SN}']['scf_release_code']}').group(0)  re
    ${status_hw_release}  Run Keyword And Return Status  Should Be True  '${hw_release}'>='5.1'
    IF  '${status_hw_release}'=='True'
      Logging With Timestamp  HW release is equal or higher than 5.1.
    ELSE
      Logging With Timestamp  message=HW release is less than 5.1.  style=ERROR
      Fail  TC works for HW release is equal or higher than 5.1!
    END

Deactivate 5G MicroDtx By SCF
    Logging With Timestamp  Checking and updating values of parameters actMicroDTX and actMicroDTXAdvanced.
    Check Status Of Default Parameters From SCF

    IF  '${ACTMICRODTX_DEFAULT_STATUS}'=='true'
      Logging With Timestamp  5G MicroDTX is activated!
      5G MicroDTX - SBTS recommissioning  scf_dtx_value=false
    ELSE
      Logging With Timestamp  5G MicroDTX is deactivated!
    END

Check Status Of Default Parameters From SCF
    Logging With Timestamp  Checking status of 5G MicroDTX.
    ${actMicroDTX_default_status}  Check Status Of 5G actMicroDTX
    ${actMicroDTXadvanced_default_status}  Check Status Of 5G actMicroDTXAdvanced
    Set Test Variable  ${ACTMICRODTX_DEFAULT_STATUS}
    Set Test Variable  ${ACTMICRODTXADVANCED_DEFAULT_STATUS}
    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

Check Status Of 5G actMicroDTX
    ${parameter_dtx}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  connection=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${parameter_dtx}
    ${managedObject}  Set Variable  .//managedObject[@class='com.nokia.srbts.nrbts:NRBTS'
    ${actMicroDTX}  Evaluate Xpath  ${scfc_xml}
    ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/NRBTS-${BTS_ID}']/p[@name='actMicroDTX']/text())
    [Return]   ${actMicroDTX}

Check Status Of 5G actMicroDTXAdvanced
    ${parameter_dtx_adv}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  connection=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${parameter_dtx_adv}
    ${managedObject}  Set Variable  .//managedObject[@class='com.nokia.srbts.nrbts:NRBTS'
    ${actMicroDTXadvanced}  Evaluate Xpath  ${scfc_xml}
    ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/NRBTS-${BTS_ID}']/p[@name='actMicroDTXAdvanced']/text())
    [Return]   ${actMicroDTXAdvanced}

Perform Site Reset
    Logging With Timestamp  Reset site will be performed!
    admin.Reset Site  timeout=600  connection=${BTS_ID}

    ${cells_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${BTS_ID}  timeout=360
    IF  '${cells_status}'=='True'
      Logging With Timestamp  All cells are onAir!
    ELSE
      Logging With Timestamp  message=Cells are not onAir!  style=ERROR
      Fail  Cells are not onAir!
    END
    Logging With Timestamp  Waiting 5 minutes for measurements stabilize after site reset.
    Sleep  5 min  #Waiting for measurements stabilize after site reset.

Check Status Of allowTrafficConcentration
    &{status_atc_dict}  Create Dictionary
    ${parameter_aTC}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  connection=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${parameter_aTC}
    ${managedObject}  Set Variable  .//managedObject[@class='NOKLTE:LNCEL'
    FOR  ${test_cell}  IN  @{CELLS_ID}
       ${allowTrafficConcentration}  Evaluate Xpath  ${scfc_xml}
       ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}']/p[@name='allowTrafficConcentration']/text())
       Set To Dictionary    ${status_atc_dict}   ${test_cell}   ${allowTrafficConcentration.lower()}
    END
    [Return]  ${status_atc_dict}

Check Status Of LTE microDTX
    &{dict_status_dtx}  Create Dictionary
    ${parameter_dtx}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  connection=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${parameter_dtx}
    ${managedObject}  Set Variable  .//managedObject[@class='NOKLTE:LNCEL'
    FOR  ${test_cell}  IN  @{CELLS_ID}
       ${actMicroDtx}  Evaluate Xpath  ${scfc_xml}
       ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}']/p[@name='actMicroDtx']/text())
       Set To Dictionary    ${dict_status_dtx}   ${test_cell}   ${actMicroDtx.lower()}
    END
    [Return]   ${dict_status_dtx}


5G MicroDTX - SBTS recommissioning
    [Arguments]  ${scf_dtx_value}
    Logging With Timestamp  Updating values of parameters actMicroDTX and actMicroDTXAdvanced.
    admin.Create Delta  delta_id=${BTS_ID}
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...  parameter=actMicroDTX
    ...  value=${scf_dtx_value}
    ...  delta_id=${BTS_ID}
    admin.Append Parameter Update To Delta
    ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
    ...  parameter=actMicroDTXAdvanced
    ...  value=${scf_dtx_value}
    ...  delta_id=${BTS_ID}
    PM_LTE_uDTX.Perform recommissioning
    admin.Remove Delta  delta_id=${BTS_ID}

    Logging With Timestamp  Checking if MicroDTX is modified!
    ${check_dtx_status}  Check Status Of 5G actMicroDTX
    ${check_dtx_advanced_status}  Check Status Of 5G actMicroDTXAdvanced
    IF  '${check_dtx_status}'=='${scf_dtx_value}' and '${check_dtx_advanced_status}'=='${scf_dtx_value}'
      Logging With Timestamp  5G MicroDTX is modified properly! Values set -> ${scf_dtx_value}${\n}
    ELSE
      Fail  5G MicroDTX is not modified properly! Values should be set -> ${scf_dtx_value}
      Logging With Timestamp  message=5G MicroDTX is not modified properly! Values should be set -> ${scf_dtx_value} ${\n}  style=ERROR
    END

Perform recommissioning
    Logging With Timestamp  Performing recommissioning, please wait!
    ${delta}  admin.Get Delta  delta_id=${BTS_ID}
    ${delta_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  30 s  admin.Perform Delta Recommissioning  delta_file=${delta}  connection=${BTS_ID}
    ...  timeout=${RECOMMISSIONING_TIMEOUT}
    IF  '${delta_status}'=='True'
      Logging With Timestamp  Recommissioning is done successfully!
    ELSE
      Fail  Recommissioning is not done successfully!
      Logging With Timestamp  message=Recommissioning is not done successfully!  style=ERROR
    END

    Logging With Timestamp  Checking cells status...
    ${cells_status}  Run Keyword And Return Status  STATE Check If All Cells Are onAir  bts_id=${BTS_ID}  timeout=120
    IF  '${cells_status}'=='True'
      Logging With Timestamp  All cells are onAir!
    ELSE
      Fail  Cells are not onAir!
      Logging With Timestamp  message=Cells are not onAir!  style=ERROR
    END

Teardown_PM_LTE_uDTX
    IF  '${ACTPOWERM_STATUS}'=='false' or ${RESTORE_CONFIG}  Run Keyword And Continue On Failure  PM_LTE_uDTX.Restore Reference Configuration
    Run Keyword And Continue On Failure  admin.Change Bts Rad Parameters Permanently  component=72  params=129:1  connection=${BTS_ID}
    Common Test Teardown

Restore Reference Configuration
    Logging With Timestamp  Restoring actPowerMeter to initial status.
    IF  '${ACTPOWERM_STATUS}'=='false'
      Logging With Timestamp  Parameter 'actPowerMeter' back to initial status.
      admin.Perform Parameter Recommissioning
      ...  dist_name=${FEATCADM_OBJECT}
      ...  parameter=actPowerMeter
      ...  operation=update
      ...  value=false
      ...  connection=${BTS_ID}
    END
    IF  ${RESTORE_CONFIG}  Restore 5G MicroDTX

Restore 5G MicroDTX
    [Documentation]
    ...  Description:
    ...  Keyword restores the 5G MicroDTX parameters (`actMicroDTX` and `actMicroDTXAdvanced`) to their initial status.
    ...
    ...  Author: lukasz.wystup@nokia.com
    ...  Maintainer: lukasz.wystup@nokia.com

    Logging With Timestamp  Restoring 5G MicroDTX parameters to initial status.
    admin.Create Delta  delta_id=${BTS_ID}
    IF  '${ACTMICRODTX_DEFAULT_STATUS}'=='false'
      Logging With Timestamp  Deactivation of parameter actMicroDTX for 5G is not needed
    ELSE
      Logging With Timestamp  Parameter actMicroDTX for 5G is going to be activated.
      admin.Append Parameter Update To Delta
      ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
      ...  parameter=actMicroDTX
      ...  value=true
      ...  delta_id=${BTS_ID}
    END
    IF  '${ACTMICRODTXADVANCED_DEFAULT_STATUS}'=='false'
      Logging With Timestamp  Deactivation of parameter actMicroDTXAdvanced for 5G is not needed.
    ELSE
      Logging With Timestamp  Parameter actMicroDTXAdvanced for 5G is going to be activated.
      admin.Append Parameter Update To Delta
      ...  dist_name=MRBTS-${BTS_ID}/NRBTS-${BTS_ID}
      ...  parameter=actMicroDTXAdvanced
      ...  value=true
      ...  delta_id=${BTS_ID}
    END
    IF  '${ACTMICRODTX_DEFAULT_STATUS}'=='true' or '${ACTMICRODTXADVANCED_DEFAULT_STATUS}'=='true'
      PM_LTE_uDTX.Perform recommissioning
    END
    admin.Remove Delta  delta_id=${BTS_ID}
