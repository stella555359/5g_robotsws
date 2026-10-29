*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS

Library           taf.sbts.oam.coam.admin  WITH NAME  admin

*** Keywords ***
Create List From All Get Cells Info                #01
    ${all_cells_info}=  Create List
    @{rat_list}=  Create List  gsm  wcdma  lte  nr
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      FOR  ${rat}  IN  @{rat_list}
        ${cells_info}=  admin.Get Cells Info  cell_type=${rat}  timeout=60  connection=${bts_id}
        ${all_cells_info}=  Combine Lists  ${all_cells_info}  ${cells_info}
      END
    END
    [Return]  ${all_cells_info}

Create All Cells DNs List                          #02
    @{all_cells_on_tl}=  Create List
    @{cells_on_nr}=  Create List
    @{cells_on_lte}=  Create List
    @{cells_on_wcdma}=  Create List
    @{cells_on_gsm}=  Create List
    &{node_cells_dict}=  Create Dictionary
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      @{all_cells_on_bts}=  Create List
      ${cells_nr}=  admin.Get IDs For All  NRCEL  connection=${bts_id}
      ${cells_lte}=  admin.Get IDs For All  LNCEL  connection=${bts_id}  search_for_iot_cells=${True}
      ${cells_wcdma}=  admin.Get IDs For All  WNCEL  connection=${bts_id}
      ${cells_gsm}=  admin.Get IDs For All  GNCEL  connection=${bts_id}
      ${cells_on_nr}=  Combine Lists  ${cells_on_nr}  ${cells_nr}
      ${cells_on_lte}=  Combine Lists  ${cells_on_lte}  ${cells_lte}
      ${cells_on_wcdma}=  Combine Lists  ${cells_on_wcdma}  ${cells_wcdma}
      ${cells_on_gsm}=  Combine Lists  ${cells_on_gsm}  ${cells_gsm}
      ${all_cells_on_bts}=  Combine Lists  ${all_cells_on_bts}  ${cells_nr}  ${cells_lte}  ${cells_wcdma}  ${cells_gsm}
      ${all_cells_on_tl}=  Combine Lists  ${all_cells_on_tl}  ${all_cells_on_bts}
      Set To Dictionary  ${node_cells_dict}  ${bts_id}=${all_cells_on_bts}
    END
    ${all_cells_on_tl}  Remove Duplicates  ${all_cells_on_tl}
    Log List  ${all_cells_on_tl}
    Log Dictionary  ${node_cells_dict}
    [Return]  ${all_cells_on_tl}  ${node_cells_dict}  ${cells_on_nr}  ${cells_on_lte}  ${cells_on_wcdma}  ${cells_on_gsm}

Create Cells By Rat And Rats To Test
    [Arguments]  ${guardband_cells}  ${cells_on_nr}  ${cells_on_lte}  ${cells_on_wcdma}  ${cells_on_gsm}
    @{rats_upper_case}=  Create List  NR  LTE  WCDMA  GSM
    ${cells_on_nr}=  Remove Guardband Cells From All Cells List  ${cells_on_nr}  ${guardband_cells}
    ${cells_on_lte}=  Remove Guardband Cells From All Cells List  ${cells_on_lte}  ${guardband_cells}
    ${cells_on_wcdma}=  Remove Guardband Cells From All Cells List  ${cells_on_wcdma}  ${guardband_cells}
    ${cells_on_gsm}=  Remove Guardband Cells From All Cells List  ${cells_on_gsm}  ${guardband_cells}
    ${nr_cells_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${cells_on_nr}
    ${lte_cells_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${cells_on_lte}
    ${wcdma_cells_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${cells_on_wcdma}
    ${gsm_cells_exist}=  Run Keyword And Return Status  Should Not Be Empty  ${cells_on_gsm}
    Run Keyword If  '${nr_cells_exist}'=='False'
    ...  Remove Values From List  ${rats_upper_case}  NR
    Run Keyword If  '${lte_cells_exist}'=='False'
    ...  Remove Values From List  ${rats_upper_case}  LTE
    Run Keyword If  '${wcdma_cells_exist}'=='False'
    ...  Remove Values From List  ${rats_upper_case}  WCDMA
    Run Keyword If  '${gsm_cells_exist}'=='False'
    ...  Remove Values From List  ${rats_upper_case}  GSM
    [Return]  ${rats_upper_case}  ${cells_on_nr}  ${cells_on_lte}  ${cells_on_wcdma}  ${cells_on_gsm}

Remove Guardband Cells From All Cells List
    [Arguments]  ${all_cells_on_rat}  ${guardband_cells}
    @{all_cells_on_rat_copy}=  Copy List  ${all_cells_on_rat}
    FOR  ${cell}  IN  @{guardband_cells}
      Remove Values From List  ${all_cells_on_rat_copy}  ${cell}
    END
    [Return]  ${all_cells_on_rat_copy}

Select Rats To Be Tested
    [Arguments]  ${rats_upper_case}  ${rats_chosen_by_tester}

    ${chosen_rats_exists}=  Run Keyword And Return Status  Variable Should Exist  ${rats_chosen_by_tester}
    ${chosen_rats_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${rats_chosen_by_tester}
    ${chosen_rats_in_tl}=  Run Keyword And Return Status  Run Keyword If  ${chosen_rats_not_empty}
    ...  List Should Contain Sub List  ${rats_upper_case}  ${rats_chosen_by_tester}
    ...  msg=The rat from the list is not found in the test line. Check variable CHOSEN_RATS.
    ${rats_to_be_tested}=  Run Keyword If  ${chosen_rats_exists}==True and ${chosen_rats_in_tl}==True  Set Variable  ${rats_chosen_by_tester}
    ...  ELSE  Set Variable  ${rats_upper_case}
    [Return]  ${rats_to_be_tested}

Create RMOD Serial Number Dist Name Dictionary
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${bts_info}=  admin.Get Bts Info  connection=${bts_id}
      &{rmod_sn_dn_dict}=  Create Dictionary
      FOR  ${rmod}  IN  @{bts_info['radioModules']['rmod']}
        Set To Dictionary  ${rmod_sn_dn_dict}  ${rmod['serialNumber']}=${rmod['id']['internal']}
      END
    END
    [Return]  ${rmod_sn_dn_dict}

Create List Of RMODs For Power Verification
    [Arguments]  ${rmod_sn_dn_dict}  ${rmods_chosen_for_power}
    @{all_rmods_on_tl_sn}=  Get Dictionary Keys  ${rmod_sn_dn_dict}
    ${chosen_rmods_exist}=  Run Keyword And Return Status  Variable Should Exist  ${rmods_chosen_for_power}
    ${chosen_rmods_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${rmods_chosen_for_power}
    ${no_rmods_to_test}=  Run Keyword And Return Status  Run Keyword If  ${chosen_rmods_not_empty}
    ...  List Should Contain Value  ${rmods_chosen_for_power}  no_power_check
    ...  msg=Variable RMODS_CHOSEN_FOR_POWER set to 'no_power_check' so power of none of the rmods will be verified.
    ${chosen_rmods_in_tl}=  Run Keyword And Return Status  Run Keyword If  ${chosen_rmods_not_empty}
    ...  List Should Contain Sub List  ${all_rmods_on_tl_sn}  ${rmods_chosen_for_power}
    ...  msg=The rmod from the list is not found in the test line. Check variable RMODS_CHOSEN_FOR_POWER.
    ${rmods_to_be_tested}=  Run Keyword If  ${chosen_rmods_exist}==True and ${chosen_rmods_in_tl}==True
    ...  Set Variable  ${rmods_chosen_for_power}
    ...  ELSE  Run Keyword If  ${chosen_rmods_exist}==True and ${no_rmods_to_test}==True
    ...  Set Variable  ${EMPTY}
    ...  ELSE  Set Variable  ${all_rmods_on_tl_sn}
    [Return]  ${rmods_to_be_tested}





Check If L3 Call Should Be Performed
    [Arguments]  ${perform_call}
    ${chosen_call_not_empty}=  Run Keyword And Return Status  Should Not Be Empty  ${perform_call}
    ${no_call_to_test_status}=  Run Keyword And Return Status  Run Keyword If  ${chosen_call_not_empty}
    ...  List Should Contain Value  ${perform_call}  no_call
    ${should_perform_call}=  Run Keyword If  ${no_call_to_test_status}==True  Set Variable  False
    ...  ELSE  Set Variable  True
    [Return]  ${should_perform_call}

Get MCC And MNC From SCF
    [Arguments]  ${current_block_lock_scf_path}  ${cells}
    &{cell_mcc_mnc_dict}=  Create Dictionary
    FOR  ${cell}  IN  @{cells}
      @{mcc_mnc}=  Create List
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${NODE_CELLS_DICT}
      ${mcc}=  Evaluate Xpath  ${current_block_lock_scf_path}
      ...  string(.//managedObject[@class="NOKLTE:${bts_name}" and @distName="MRBTS-${bts_id}/${bts_name}-${bts_id}"]/p[@name="mcc"])
      ${mnc}=  Evaluate Xpath  ${current_block_lock_scf_path}
      ...  string(.//managedObject[@class="NOKLTE:${bts_name}" and @distName="MRBTS-${bts_id}/${bts_name}-${bts_id}"]/p[@name="mnc"])
      Append To List   ${mcc_mnc}  ${mcc}  ${mnc}
      Set To Dictionary  ${cell_mcc_mnc_dict}  ${cell}=${mcc_mnc}
    END
    [Return]  ${cell_mcc_mnc_dict}

# TODO: Podmienic zmienne w testach na sciezki ze slownika celek node-rat-cell-band
Create Cells Dictionary Grouped By Node Rat Band               #03
    [Arguments]  ${RNC_DICT}=${EMPTY}  ${BSC_DICT}=${EMPTY}
    &{node_rat_cells_dict}=  Create Dictionary
    @{rat_list}=  Create List  gsm  wcdma  lte  nr
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      &{rat_cells_dict}=  Create Dictionary
      FOR  ${rat}  IN  @{rat_list}
        ${cells_info}=  admin.Get Cells Info  cell_type=${rat}  timeout=60  connection=${bts_id}
        &{cells_dict}=  Create Dictionary
        FOR  ${cell}  IN  @{cells_info}
          &{one_cell_details}=  Create Dictionary
          ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=
          ...  Extract Variables From Cell Dist Name  ${cell['id']['internal']}  ${NODE_CELLS_DICT}

          Run Keyword If  '${rat}'=='lte'  Set To Dictionary  ${one_cell_details}
          ...  bandNumber=lte_${cell['bandNumber']}
          ...  globalCellId=${cell['globalCellId']}
          ...  narrowbandIotMode=${cell['narrowbandIotMode']}
          ...  technology=${cell['technology']}
          ...  class=${class}
          ...  cell_node_id=${bts_id}
          ...  cell_config_dn=${cell['id']['configuration']}

          Run Keyword If  '${rat}'=='nr'  Set To Dictionary  ${one_cell_details}
          ...  bandNumber=nr_${cell['band']}
          ...  globalCellId=${cell['globalCellId']}
          ...  technology=${cell['technology']}
          ...  class=${class}
          ...  cell_node_id=${bts_id}
          ...  cell_config_dn=${cell['id']['configuration']}

          ${band_number}  ${global_cell_id}  ${class}=  Run Keyword If  '${rat}'=='wcdma'
          ...  Extract Details For WCDMA Cell From SCF  ${cell['id']['internal']}
          ${rnc_dict_exist}=  Run Keyword If  '${rat}'=='wcdma'
          ...  Run Keyword And Return Status  Should Not Be Empty  ${RNC_DICT}
          Run Keyword If  '${rat}'=='wcdma' and ${rnc_dict_exist}==True  Set To Dictionary  ${one_cell_details}
          ...  bandNumber=wcdma_${band_number}
          ...  globalCellId=${global_cell_id}
          ...  class=${class}
          ...  cell_node_id=${bts_id}
          ...  rnc_id=${RNC_DICT['rnc_id']}
          ...  oms_ip=${RNC_DICT['oms_ip']}
          ...  rnc_user=${RNC_DICT['rnc_user']}
          ...  rnc_password=${RNC_DICT['rnc_password']}
          ...  cell_config_dn=${cell['id']['configuration']}

          ${bcf_id}  ${bsc_id}  ${gsm_bts_id}  ${band_number}  ${global_cell_id}  ${class}=  Run Keyword If  '${rat}'=='gsm'
          ...  Extract Details For GSM Cell From SCF  ${cell['id']['internal']}
          ${exist}=  Run Keyword If  '${rat}'=='gsm'
          ...  Run Keyword And Return Status
          ...  Should Not Be Empty  ${BSC_DICT}
          ${equal}=  Run Keyword If  '${rat}'=='gsm' and ${exist}==True
          ...  Run Keyword And Return Status
          ...  Should Be Equal  ${BSC_DICT['bsc_id']}  ${bsc_id}
          Run Keyword If  ${exist}==False
          ...  Log  Variable for GSM testing not provided. Check test suit if you test GSM.  console=True  level=WARN
          Run Keyword If  ${equal}==False  Fail  Check why bsc provided in the test suite differs from SCF. Check bsc_ip!
          Run Keyword If  '${rat}'=='gsm' and ${equal}==True  Set To Dictionary  ${one_cell_details}
#          ...  bandNumber=gsm_${band_number}
          ...  bandNumber=gsm_${cell['gsmBand']}
          ...  globalCellId=${global_cell_id}
          ...  class=${class}
          ...  cell_node_id=${bts_id}
          ...  bcf_id=${bcf_id}
          ...  bsc_id=${bsc_id}
          ...  bsc_ip=${BSC_DICT['bsc_ip']}
          ...  gsm_bts_id=${gsm_bts_id}
          ...  bsc_user=${BSC_DICT['bsc_user']}
          ...  bsc_password=${BSC_DICT['bsc_password']}
          ...  cell_config_dn=${cell['id']['configuration']}

          # Initialize nested dictionaries if they do not exist
#          Run Keyword If  '${band}' not in ${cells_dict[${node}][${rat}]}  Set To Dictionary  ${cells_dict[${node}][${rat}]}  ${band}=[]

          Set To Dictionary  ${cells_dict}  ${cell['id']['internal']}=${one_cell_details}
#          ${all_cells_info}=  Combine Lists  ${all_cells_info}  ${cells_info}
        END
        Set To Dictionary  ${rat_cells_dict}  ${rat}=${cells_dict}
      END
      Set To Dictionary  ${node_rat_cells_dict}  ${bts_id}=${rat_cells_dict}
    END
    Log Dictionary  ${node_rat_cells_dict}
    [Return]  ${node_rat_cells_dict}

Extract Details For GSM Cell From SCF
    [Arguments]  ${cell_dn}
    @{bcf_ids}=  Create List
    @{bsc_ids}=  Create List
    @{gsm_bts_ids}=  Create List
    @{band_numbers}=  Create List
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${current_block_lock_scf_path}=  admin.Get Current Scf File
      ...  local_dir_path=${TEST_LOGS_PATH}Setup/BTSFiles/${bts_id}/
      ...  file_name=scf_${bts_id}_scf_block_wcdma.xml
      ...  timeout=30
      ...  export_type=configurationAndRuntimeObjects
      ...  connection=${bts_id}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=
      ...  Extract Variables From Cell Dist Name  ${cell_dn}  ${NODE_CELLS_DICT}
      ${bcf_id}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/GNBTS-1/GNBCF-1
      ...  bcfId
      ${bsc_id}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/GNBTS-1/GNBCF-1
      ...  bscId
      ${gsm_bts_id}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/GNBTS-1/GNBCF-1/GNCEL-${global_cell_id}/${cell_r_number}
      ...  gsmBtsId
      ${band_number}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELC-${global_cell_id}
      ...  bandNumber
      Append To List  ${bcf_ids}  ${bcf_id}
      Append To List  ${bsc_ids}  ${bsc_id}
      Append To List  ${gsm_bts_ids}  ${gsm_bts_id}
      Append To List  ${band_numbers}  ${band_number}
    END
    ${bcf_ids}=  Remove Duplicates  ${bcf_ids}
    ${bsc_ids}=  Remove Duplicates  ${bsc_ids}
    ${gsm_bts_ids}=  Remove Duplicates  ${gsm_bts_ids}
    ${band_numbers}=  Remove Duplicates  ${band_numbers}
    ${bands_on_tl_list_strings}=  Convert Band Numbers To Strings  ${band_numbers}
    [Return]  ${bcf_ids[0]}  ${bsc_ids[0]}  ${gsm_bts_ids[0]}  ${bands_on_tl_list_strings[0]}  ${global_cell_id}  ${class}

Extract Details For WCDMA Cell From SCF
    [Arguments]  ${cell_dn}
    @{band_numbers}=  Create List
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${current_block_lock_scf_path}=  admin.Get Current Scf File
      ...  local_dir_path=${TEST_LOGS_PATH}Setup/BTSFiles/${bts_id}/
      ...  file_name=scf_${bts_id}_scf_block_wcdma.xml
      ...  timeout=30
      ...  export_type=configurationAndRuntimeObjects
      ...  connection=${bts_id}
      ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=
      ...  Extract Variables From Cell Dist Name  ${cell_dn}  ${NODE_CELLS_DICT}
      ${band_number}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELC-1
      ...  bandNumber
      ${cell_number}=  Fetch From Right  ${cell_dn}  marker=-
      ${l_cel_w_dn}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/WNBTS-1/WNCEL-${cell_number}
      ...  lCelwDN
      ${lcelwdn_name}=  Fetch From Right  ${lcelwdn}  marker=/
      ${band_number}=  SCFC Get Attribute Value
      ...  ${current_block_lock_scf_path}
      ...  MRBTS-${bts_id}/MNL-1/MNLENT-1/CELLMAPPING-1/${lcelwdn_name}
      ...  bandNumber
#      ${band_wcdma_modified}=  Catenate  SEPARATOR=_  wcdma  ${band_number}
      Append To List  ${band_numbers}  ${band_number}  #${band_wcdma_modified}
    END
    ${band_numbers}=  Remove Duplicates  ${band_numbers}
    [Return]  ${band_numbers[0]}  ${global_cell_id}  ${class}

# TODO: instead of this one use the node rat cell dictionary
Extract Variables From Cell Dist Name
    [Arguments]   ${cell}  ${node_cells_dict}
    ${path}  ${bts_r_number}  ${cell_r_number}=   Split String From Right  ${cell}  separator=/  max_split=2
    ${class}=  Fetch From Left  ${cell_r_number}  marker=_
    ${global_cell_id}=  Fetch From Right  ${cell_r_number}  marker=-
    ${bts_id}=   Fetch From Right  ${bts_r_number}  marker=-
    ${bts_name}=   Fetch From Left  ${bts_r_number}  marker=_
    ${class}=  Set Variable If  '${class}'=='NRCELL'  NRCEL  ${class}
    ${gsm_cell_node_id}=  Run Keyword If  '${class}'=='GNCEL'  Find Bts Id For Cell  ${node_cells_dict}  ${cell}
    ${wcdma_cell_node_id}=  Run Keyword If  '${class}'=='WNCEL'  Find Bts Id For Cell  ${node_cells_dict}  ${cell}
    ${bts_id}=  Set Variable If  '${class}'=='GNCEL'  ${gsm_cell_node_id}  ${bts_id}
    ${bts_id}=  Set Variable If  '${class}'=='WNCEL'  ${wcdma_cell_node_id}  ${bts_id}
    [Return]  ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}

Create Bands On Tl List                             #04
    [Arguments]  ${node_rat_cells_dict}
    @{bands_on_tl_list}=  Create List
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${status}  ${rats}=  Run Keyword And Ignore Error  Get Dictionary Keys  ${node_rat_cells_dict['${bts_id}']}
      FOR  ${rat}  IN  @{rats}
        ${status}  ${cells}=  Run Keyword And Ignore Error  Get Dictionary Keys  ${node_rat_cells_dict['${bts_id}']['${rat}']}
        FOR  ${cell}  IN  @{cells}
          ${status}  ${band}=  Run Keyword And Ignore Error  Get From Dictionary  ${node_rat_cells_dict['${bts_id}']['${rat}']['${cell}']}  bandNumber
          Append To List  ${bands_on_tl_list}  ${band}
          # TODO: Think if this wouldn't be clearer to read:  Append To List  ${bands_on_tl_list}  ${rat}_${band}
        END
        ${bands_on_tl_list}=  Remove Duplicates  ${bands_on_tl_list}
        ${bands_on_tl_list_strings}=  Convert Band Numbers To Strings  ${bands_on_tl_list}
      END
    END
    [Return]  ${bands_on_tl_list_strings}     #${bands_on_tl_list}

Create All Available On TL Cells Class Names            #05
    [Arguments]  ${all_cells_on_tl}
    ${all_cells_class_on_tl} =  Create List
    FOR  ${cell}  IN  @{all_cells_on_tl}
      ${cell_no}=  Fetch From Right  ${cell}  marker=/
      ${cell_name}=  Fetch From Left  ${cell_no}  marker=_
      ${cell_name}=  Set Variable If  '${cell_name}'=='NRCELL'  NRCEL  ${cell_name}
      Append To List  ${all_cells_class_on_tl}  ${cell_name}
    END
    ${all_cells_class_on_tl}=  Remove Duplicates  ${all_cells_class_on_tl}
    [Return]  ${all_cells_class_on_tl}

Get Guardband Cells From Cells Info Dictionary           #06
    [Arguments]  ${node_rat_cells_dict}
    @{guardband_cells}=  Create List
    @{guardband_bands}=  Create List
    FOR  ${bts_id}  IN  @{CFG.active_bts_list}
      ${status}  ${rats}=  Run Keyword And Ignore Error  Get Dictionary Keys  ${node_rat_cells_dict['${bts_id}']}
      FOR  ${rat}  IN  @{rats}
        ${status}  ${cells}=  Run Keyword And Ignore Error  Get Dictionary Keys  ${node_rat_cells_dict['${bts_id}']['${rat}']}
        FOR  ${cell}  IN  @{cells}
          ${tech_status}=  Run Keyword And Return Status
          ...  Should Match Regexp  ${node_rat_cells_dict['${bts_id}']['${rat}']['${cell}']['technology']}  [Nn][Bb]-IoT.*
          Run Keyword If  '${tech_status}'=='True'
          ...  Append To List  ${guardband_cells}  ${cell}
          ${iot_band_string}=  Run Keyword If  '${tech_status}'=='True'
          ...  Convert To String  ${node_rat_cells_dict['${bts_id}']['${rat}']['${cell}']['bandNumber']}
          Run Keyword If  '${tech_status}'=='True'  Append To List  ${guardband_bands}  ${iot_band_string}
          # TODO: Think if this wouldn't be clearer to read:  Append To List  ${bands_on_tl_list}  ${rat}_${band}
        END
      ${guardband_bands}=  Remove Duplicates  ${guardband_bands}
      END
    END
    [Return]  ${guardband_cells}  ${guardband_bands}

Convert Band Numbers To Strings
    [Arguments]  ${bands}
    @{bands_strings}=  Create List
    FOR  ${int}  IN  @{bands}
      ${string}=  Convert To String  ${int}
      Append To List  ${bands_strings}  ${string}
    END
    [Return]  ${bands_strings}
