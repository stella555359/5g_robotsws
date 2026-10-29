*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Resource    ../Resources/Setup/setup_and_teardown.robot
Resource  ./common_setup.robot
Resource  ./site_operations.robot
Resource  ./site_verifications.robot
Resource  ./variables.robot


Library  BuiltIn
Library  Collections
Library  String
Library  robot.libraries.DateTime
Library  taf.sbts.oam.coam.admin    WITH NAME    admin
Library  ute_admin_infomodel    WITH NAME    admin_im

*** Keywords ***
################################################ Pmax ######################################################

Perform Pmax Verification On Every Node
  ${rf_list}=  Get Dictionary Keys  ${cfg.RF_INFO}
  ${RF_status}=  Run Keyword And Return Status  Variable Should Exist  ${CUSTOM_RADIO_UNIT_LIST}
  ${rf_list}=  Set Variable If  ${RF_status}  ${CUSTOM_RADIO_UNIT_LIST}  ${rf_list}
  FOR  ${ru_sn}  IN  @{rf_list}
    ${RF_type}=  Set Variable  ${cfg.RF_INFO['${ru_sn}'].scf_variant}
    Pmax Verification
    ...  ${ru_sn}
    ...  ${cfg}
    ...  ${RF_POWER_LEVEL_CONVERSIONS['${RF_type}']['MAX']}
    ...  ${RF_POWER_LEVEL_CONVERSIONS['${RF_type}']['MIN']}
  END

Pmax Verification
  [Documentation]
  ...  pMax parameter value change main keyword with steps from QC.
  ...  In order to run this test, you have to set up RF_POWER_LEVEL_CONVERSIONS variables
  ...  for tested RMOD with values from a proper documentation.
  [Arguments]  ${ru_sn}  ${cfg}  ${max_pipe_power}  ${min_pipe_power}  ${alias}=${cfg.RF_INFO['${ru_sn}'].scf_btsid_primary}
  ${bts_id}=  Set Variable  ${cfg.RF_INFO['${ru_sn}'].scf_btsid_primary}
  ${pmax_backup}=  Backup recommissioned parameters  ${ru_sn}  ${bts_id}
  Perform pMax Recommissioning With Highest Possible Values
  ...  ${ru_sn}
  ...  ${bts_id}
  ...  ${max_pipe_power}
  ...  ${min_pipe_power}
  ...  alias=${alias}
  Perform pMax Recommissioning With Incorrect Values  ${ru_sn}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}
  ...  ${cfg.RF_INFO['${ru_sn}'].scf_release_code}  alias=${alias}
  Perfom pMax Recommissioning With Minimum Values  ${ru_sn}  ${bts_id}  ${min_pipe_power}  alias=${alias}
  ${RF_type}=  Set Variable  ${cfg.RF_INFO['${ru_sn}'].scf_variant}
  ${tx_gain_support}=  Set Variable  ${RF_POWER_LEVEL_CONVERSIONS['${RF_type}']['TxGainSupport']}
  Run keyword if
  ...  ${tx_gain_support}
  ...  Check additionalTxGain and additionalTxAttenuation
  ...  ${ru_sn}
  ...  ${bts_id}
  ...  ${max_pipe_power}
  ...  ${min_pipe_power}
  ...  alias=${alias}
  [Teardown]  Restore recommissioned parameters  ${bts_id}  ${pmax_backup}  alias=${alias}

Backup recommissioned parameters
  [Arguments]  ${rm_serial}  ${bts_id}
  Log To Console  Backup recommissioned parameters
  @{lcr_id_list}=  SCFC Create LcrId List For FR Serial Number  ${cfg.NODES['${bts_id}'].parsed_scf}  ${rm_serial}
  @{cells_for_radio}=  SCFC Create LncelId List For LcrdId List  ${cfg.NODES['${bts_id}'].parsed_scf}  ${lcr_id_list}
  ${pmax_dict}=  Create Dictionary
  FOR  ${cell}  IN  @{cells_for_radio}
    ${pmax}=  SCFC Get Attribute Value For LncelId  ${cfg.NODES['${bts_id}'].parsed_scf}  ${cell}  pMax
    Set To Dictionary  ${pmax_dict}  ${cell}  ${pmax}
  END
  [Return]  ${pmax_dict}

Restore recommissioned parameters
  [Arguments]  ${bts_id}  ${pmax_dict}  ${alias}=default
  Log To Console  Restore recommissioned parameters
  ${cells_id}=  Get Dictionary Keys  ${pmax_dict}
  Create Delta
  FOR  ${cell_id}  IN  @{cells_id}
  Append Parameter Update To Delta
  ...  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell_id}
  ...  pMax
  ...  ${pmax_dict["${cell_id}"]}
  END
  ${objects_added}=  Run Keyword And Return Status  Variable Should Exist  ${CREATED_OBJECT_LIST}
  Run Keyword If  ${objects_added}  _add objects to removing to delta
  Save Delta  ${TEST_LOGS_PATH}/PMAX/buckup.json
  Perform Delta Recommissioning  ${TEST_LOGS_PATH}/PMAX/buckup.json  connection=${alias}

_add objects to removing to delta
  FOR  ${object}  IN  @{CREATED_OBJECT_LIST}
    Append Managed Object To Delta  ${object}  delete
  END

Convert dBm To Watt
  [Documentation]
  ...  This keyword converts dBm value given in the arguments to Watt and returns it.
  [Arguments]  ${dbm}
  ${dbm_decimal_places}=  Convert To Number  ${dbm}  3
  ${ten_decimal_places}=  Convert to Number  10  3
  ${watt_tmp1}=  Evaluate  float(${dbm_decimal_places}/${ten_decimal_places})
  ${watt_tmp}=  Evaluate  float(10**${watt_tmp1}/1000)
  ${watt}=  Convert To Number  ${watt_tmp}  3
  [Return]  ${watt}

Check additionalTxGain and additionalTxAttenuation
  [Arguments]  ${rm_serial}  ${bts_id}  ${$max_pipe_power}  ${min_pipe_power}  ${alias}=default
  Log To Console  Check additionalTxGain and additionalTxAttenuation.
  Check additional TxGain  ${rm_serial}  ${bts_id}  ${$max_pipe_power}  ${min_pipe_power}  ${alias}
  Check additional TxAttenuation  ${rm_serial}  ${bts_id}  ${$max_pipe_power}  ${min_pipe_power}  ${alias}

Check additional TxGain
  [Arguments]  ${rm_serial}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}  ${alias}=default
  Log To Console  Check additional TxGain.
  ${max_per_pipe_dbm}  @{cells_for_radio}=  Calculate Max PMax Value For Cells On Radio
  ...  ${rm_serial}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}
  ${max_per_pipe_dbm}=  Evaluate  ${max_per_pipe_dbm}+10
  ${max_per_pipe_for_recommissioning}=  Evaluate  ${max_per_pipe_dbm}*10
  @{lcr_id_list}=  SCFC Create LcrId List For FR Serial Number  ${cfg.NODES['${bts_id}'].parsed_scf}  ${rm_serial}
  ${rmod_id}=  SCFC Get RmodId For FR Serial Number  ${cfg.NODES['${bts_id}'].parsed_scf}  ${rm_serial}
  @{antl_dn_list}=  SCFC Create Antl List For LcrId List  ${cfg.NODES['${bts_id}'].parsed_scf}  ${lcr_id_list}
  ${objects_added}=  Run Keyword And Return Status  Variable Should Exist  ${CREATED_OBJECT_LIST}
  Run keyword if
  ...  not ${objects_added}
  ...  Add PASSDEV and LOGLINK objects
  ...  ${bts_id}
  ...  ${antl_dn_list}
  ...  ${alias}
  Create Delta
  FOR  ${object}  IN  @{CREATED_OBJECT_LIST}
    ${is_passdev}=  Run Keyword And Return Status  Should Contain  ${object}  PASSDEV
    Run Keyword If  ${is_passdev}  Append Parameter Update To Delta  ${object}  additionalTxGain  10
    Run Keyword If  ${is_passdev}  Append Parameter Update To Delta  ${object}  additionalTxAttenuation  0
  END
  FOR  ${cell}  IN  @{cells_for_radio}
    Append Parameter Update To Delta
    ...  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}
    ...  pMax
    ...  ${max_per_pipe_for_recommissioning}
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/txGain.json
  Perform Delta Recommissioning  ${TEST_LOGS_PATH}/PMAX/txGain.json  connection=${alias}
  FOR  ${cell}  IN  @{cells_for_radio}
    Check If pMax Value Is Correct  ${max_per_pipe_dbm}  ${cell}  ${bts_id}  ${alias}
  END

Check additional TxAttenuation
  [Arguments]  ${rm_serial}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}  ${alias}=default
  Log To Console  Check additional TxAttenuation.
  @{lcr_id_list}=  SCFC Create LcrId List For FR Serial Number  ${cfg.NODES['${bts_id}'].parsed_scf}  ${rm_serial}
  ${max_per_pipe_dbm}  @{cells_for_radio}=  Calculate Max PMax Value For Cells On Radio
  ...  ${rm_serial}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}
  ${max_per_pipe_dbm}=  Evaluate  ${max_per_pipe_dbm}-10
  ${max_per_pipe_for_recommissioning}=  Evaluate  ${max_per_pipe_dbm}*10
  ${rmod_id}=  SCFC Get RmodId For FR Serial Number  ${cfg.NODES['${bts_id}'].parsed_scf}  ${rm_serial}
  @{antl_dn_list}=  SCFC Create Antl List For LcrId List  ${cfg.NODES['${bts_id}'].parsed_scf}  ${lcr_id_list}
  ${objects_added}=  Run Keyword And Return Status  Variable Should Exist  ${CREATED_OBJECT_LIST}
  Run keyword if
  ...  not ${objects_added}
  ...  Add PASSDEV and LOGLINK objects
  ...  ${bts_id}
  ...  ${antl_dn_list}
  ...  ${alias}
  Create Delta
  FOR  ${object}  IN  @{CREATED_OBJECT_LIST}
    ${is_passdev}=  Run Keyword And Return Status  Should Contain  ${object}  PASSDEV
    Run Keyword If  ${is_passdev}  Append Parameter Update To Delta  ${object}  additionalTxAttenuation  10
    Run Keyword If  ${is_passdev}  Append Parameter Update To Delta  ${object}  additionalTxGain  0
  END
  FOR  ${cell}  IN  @{cells_for_radio}
    Append Parameter Update To Delta
    ...  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}
    ...  pMax
    ...  ${max_per_pipe_for_recommissioning}
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/txAttenuation.json
  Perform Delta Recommissioning  ${TEST_LOGS_PATH}/PMAX/txAttenuation.json  connection=${alias}
  FOR  ${cell}  IN  @{cells_for_radio}
    Check If pMax Value Is Correct  ${max_per_pipe_dbm}  ${cell}  ${bts_id}  ${alias}
  END

Add PASSDEV and LOGLINK objects
  [Arguments]  ${bts_id}  ${antl_dn_list}  ${alias}=default
  ${created_object_list}=  Create List
  Create Delta
  Append Managed Object To Delta  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111  create
  Append To List  ${created_object_list}  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111
  Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111  additionalTxAttenuation  0
  Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111  additionalTxGain  0
  Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111  inventoryUnitType  Not available
  Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111  vendorName  Not available
  ${antl_dn_list_len}=  Get Length  ${antl_dn_list}
  FOR  ${i}  IN RANGE  ${antl_dn_list_len}
    Append Managed Object To Delta  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}  create
    Append To List  ${created_object_list}  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}
    Append Parameter Update To Delta
    ...  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}
    ...  firstEndpointDN
    ...  ${antl_dn_list}[${i}]
    Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}  linkModeConfiguration  false
    Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}  linkModeDC  false
    Append Parameter Update To Delta  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}  linkModeData  true
    Append Parameter Update To Delta
    ...  MRBTS-${bts_id}/EQM-1/HWTOP-1/LOGLINK-11${i}
    ...  secondEndpointDN
    ...  MRBTS-${bts_id}/EQM-1/APEQM-1/PASSDEV-111
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/passdev_loglink.json
  Perform Delta Recommissioning  ${TEST_LOGS_PATH}/PMAX/passdev_loglink.json  connection=${alias}
  Set Test Variable  ${CREATED_OBJECT_LIST}  ${created_object_list}

Convert Watt To dBm
  [Documentation]
  ...  This keyword converts Watt value given in the arguments to dBm and returns it.
  [Arguments]  ${watt}
  ${dbm}=  Evaluate  10*math.log10(1000*${watt})  modules=math
  ${dbm}=  Convert To Number  ${dbm}  1
  [Return]  ${dbm}

Perform pMax Recommissioning With Highest Possible Values
  [Documentation]
  ...  This keyword recommissions pMax parameters with maximum correct pMax value on a pipe.
  [Arguments]  ${rm_serial}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}  ${alias}=default
  Log To Console  Perform pMax recommissioning with maximum correct values.
  ${max_per_pipe_dbm}  @{cells_for_radio}=  Calculate Max PMax Value For Cells On Radio
  ...  ${rm_serial}  ${bts_id}  ${max_pipe_power}  ${min_pipe_power}
  ${max_per_pipe_for_recommissioning}=  Evaluate  ${max_per_pipe_dbm}*10
  Create Delta
  FOR  ${cell}  IN  @{cells_for_radio}
    Append Parameter Update To Delta
    ...  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}
    ...  pMax
    ...  ${max_per_pipe_for_recommissioning}
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/pmax_hi.json
  Perform Delta Recommissioning  ${TEST_LOGS_PATH}/PMAX/pmax_hi.json  connection=${alias}
  FOR  ${cell}  IN  @{cells_for_radio}
    Check If pMax Value Is Correct  ${max_per_pipe_dbm}  ${cell}  ${bts_id}  ${alias}
  END

Perfom pMax Recommissioning With Minimum Values
  [Documentation]
  ...  This keyword recommissions pMax parameters with minimum pMax on all cells.
  [Arguments]  ${rm_serial}  ${bts_id}  ${min_pipe_power}  ${alias}=default
  Log To Console  Perfom pMax recommissioning with minimum values.
  @{lcr_id_list}=  SCFC Create LcrId List For FR Serial Number  ${cfg.NODES['${bts_id}'].parsed_scf}  ${rm_serial}
  @{cells_for_radio}=  SCFC Create LncelId List For LcrdId List  ${cfg.NODES['${bts_id}'].parsed_scf}  ${lcr_id_list}
  ${pMax_value_per_cell}=  Evaluate  ${min_pipe_power}*10
  Create Delta
  FOR  ${cell}  IN  @{cells_for_radio}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}  pMax  ${pMax_value_per_cell}
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/pmax_lo.json
  Perform Delta Recommissioning  ${TEST_LOGS_PATH}/PMAX/pmax_lo.json  connection=${alias}
  FOR  ${cell}  IN  @{cells_for_radio}
    Check If pMax Value Is Correct  ${min_pipe_power}  ${cell}  ${bts_id}  ${alias}
  END

Calculate Max PMax Value For Cells On Radio
  [Documentation]
  ...  This keyword calculates maximum pmax value for cells on a given radio. It returns the pMax value, as well
  ...  as the list of cells on the radio.
  [Arguments]  ${rm_serial}  ${node}  ${$max_pipe_power}  ${min_pipe_power}
  @{lcr_id_list}=  SCFC Create LcrId List For FR Serial Number  ${cfg.NODES['${node}'].parsed_scf}  ${rm_serial}
  @{cells_for_radio}=  SCFC Create LncelId List For LcrdId List  ${cfg.NODES['${node}'].parsed_scf}  ${lcr_id_list}
  ${number_of_cells_on_radio}=  Get Length  ${cells_for_radio}
  ${max_pipe_pow_in_watt}=  Convert dBm To Watt  ${$max_pipe_power}
  ${min_pipe_pow_in_watt}=  Convert dBm To Watt  ${min_pipe_power}
  ${max_per_pipe}=  Evaluate  ${max_pipe_pow_in_watt}/${number_of_cells_on_radio}
  ${max_per_pipe_dbm}=  Evaluate  math.floor(10*math.log10(1000*${max_per_pipe})*10)/10  modules=math
  [Return]  ${max_per_pipe_dbm}  @{cells_for_radio}

Perform pMax Recommissioning With Incorrect Values
  [Documentation]
  ...  This keyword recommissions pMax parameters with incorrect values - pMax too small and too large.
  [Arguments]  ${rm_serial}  ${bts_id}  ${$max_pipe_power}  ${min_pipe_power}  ${rm_release}  ${alias}=default
  Log To Console  Perform pMax recommissioning with incorrect values.
  ${max_per_pipe}  @{cells_for_radio}=  Calculate Max PMax Value For Cells On Radio
  ...  ${rm_serial}  ${bts_id}  ${$max_pipe_power}  ${min_pipe_power}
  ${pmax_below_min}=  Evaluate  ${MIN_PIPE_POWER}*10-5
  Create Delta
  FOR  ${cell}  IN  @{cells_for_radio}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}  pMax  ${pmax_below_min}
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/pmax_incorect_lo.json
  Run keyword if
  ...  '${rm_release}' != 'AR0' and '${rm_release}' != 'FJ0'
  ...  Run keyword and expect error
  ...  *
  ...  Perform Delta Recommissioning
  ...  ${TEST_LOGS_PATH}/PMAX/pmax_incorect_lo.json
  ...  connection=${alias}
  ${max_per_pipe_for_recommissioning}=  Evaluate  ${max_per_pipe}*10
  ${pmax_above_max}=  Evaluate  ${max_per_pipe_for_recommissioning}+5
  Create Delta
  FOR  ${cell}  IN  @{cells_for_radio}
    Append Parameter Update To Delta  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}  pMax  ${pmax_above_max}
  END
  Save Delta  ${TEST_LOGS_PATH}/PMAX/pmax_incorect_hi.json
  Run Keyword and expect error
  ...  *
  ...  Perform Delta Recommissioning
  ...  ${TEST_LOGS_PATH}/PMAX/pmax_incorect_hi.json
  ...  connection=${alias}

Perform pMax Recommissioning
  [Documentation]
  ...  This keyword performs pMax parameter recommissioning with the given value in the arguments on cells.
  [Arguments]  ${pmax_value}  ${cell}  ${bts_id}  ${alias}=default
  Perform Parameter Recommissioning
  ...  MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell}
  ...  pMax
  ...  update
  ...  ${pmax_value}
  ...  alias=${alias}

Check If pMax Value Is Correct
  [Documentation]
  ...  This keyword checks if pMax value is correct by checking if IM value is the same as the one given in the
  ...  arguments.
  [Arguments]  ${pmax}  ${cell}  ${bts_id}  ${alias}=default
  ${lncel_a_dn}=  Get Parameters
  ...  /MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-${bts_id}/LNCEL_R-${cell}/CONF_REF-1
  ...  distName
  ...  connection=${alias}
  ${cell_pmax}=  Get Parameters  ${lncel_a_dn["distName"]}  pMax  connection=${alias}
  Should Be Equal  ${cell_pmax["pMax"]}  ${pmax}
