*** Settings ***
Documentation
...  The purpose of this test case is check impact of feature microDTX on 5G cells.

Resource    ../../../../resources/ca_siso_hran.robot
Resource    ../../../../resources/ca_BSRF_general.robot
Resource    ../../../../resources/hran_frame_sbts_siso.robot
Library     taf.selenium.sbts  WITH NAME  selenium_coam
Library    taf.ul.energy_efficiency_monitoring  WITH NAME  ee_monitoring

*** Variables ***
${RMOD_SN}                                   # serial numbers of tested RMOD(s) with 5G cell(s) separated by comma
${RECOMMISSIONING_TIMEOUT}     600           # Timeout for recommissioning procedure
${node}  default
${WEBUI_URL}     https://192.168.255.129/    # ADMIN url
${WEBUI_NAME}    Nemuadmin                   # ADMIN login
${WEBUI_PWD}     nemuuser                    # ADMIN password
${EE_INTERVAL}  15min                        # time interval of getting counters for EEM - Energy Efficiency Monitoring

*** Keywords ***
TC__SiSo_5G_uDTX
    [Documentation]
    ...  *****************
    ...  Basic information
    ...  *****************
    ...  The purpose of this test case is check impact of feature microDTX on 5G cells.
    ...  The test is related to the project: energy efficiency and was created using
    ...  microDTX: Micro discontinuous transmission - Power saving.
    ...  Test case involves activate and deactivate feature, works on RMODs supported by this feature,
    ...  so far has been tested on RU families 5.1 (AHEB, AHPE, AHPMDD, AHEGB, AHPMDA), 6.2 (AHFII).
    ...  Test case checks if RMOD's power is lower, when feature is activated -
    ...  parameter 'actPowerMeter' and 'actMicroDTXAdvanced' need to be previously set on 'True'.
    ...  From 25R1 release modyfication is done via Vendor File and checking statuses of parameters is done by Info Model Viewer.
    ...  Parameters of LTE microDTX need to be deactivated - 'actMicroDtx' and 'allowTrafficConcentration'
    ...  are disabled during the test.
    ...  ******************
    ...  History of changes
    ...  ******************
    ...  - 12.02.2024 - https://jiradc.ext.net.nokia.com/browse/FCA_ST_SISO-39283 - Initial creation
    ...  - 13.05.2024 - adding parameter 'actMicroDTXAdvanced' to fully enable feature microDTX
    ...  - 24.06.2024 - implementing LTE microDTX deactivation: parameters 'actMicroDtx' and 'allowTrafficConcentration'
    ...  - 30.07.2024 - implementing a new way to modification of parameters 'actMicroDTX' and 'actMicroDTXAdvanced' -
    ...    from 25R1 release is done via vendor file (CB0013258)
    ...  - 06.08.2024 - expanding TC with taf.ul.energy_efficiency_monitoring for monitoring of power consumpstion savings
    ...    according to BitStream 4.3

    Set Tags    CA-5G_RRM    OWNER-malgorzata.piecyk-celuch@nokia.com    AUTHOR-malgorzata.piecyk-celuch@nokia.com
    ...    MAINTAINER-malgorzata.piecyk-celuch@nokia.com    PHASE-CRT    SW-SBTS24
    ...    FEATURE-CNI-110111  CB0013258

    Automated__SiSo_5G_uDTX.Step 1: Test Case Preconditions
    Step 2: Check 5G MicroDTX status and activate MicroDTX
    Step 3: Check RMOD power consumption when 5G MicroDTX is activated
    Step 4: Deactivate 5G MicroDTX - SBTS recommissioning
    Step 5: Check RMOD power consumption when 5G MicroDTX is deactivated and compare
    Restore parameters to initial status


Step 1: Test Case Preconditions
    Log  ${\n}Step 1: Test Case Preconditions  console=True
    Log  ------------------------------------  console=True

    Log  Enabling Energy Efficiency Monitoring (EEM)${\n}  console=True
    ee_monitoring.configure_bts_connection
    ee_monitoring.enable_energy_efficiency_monitoring

    Set Test Variable  ${RESTORE_CONFIG}  ${FALSE}

    ${bts_params}  admin.Get parameters for all  BTS  alias=${node}
    Set Test Variable  ${BTS_ID}  ${bts_params[0].btsId}
    Set Test Variable  ${FEATCADM_OBJECT}  MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1

    ${param_actPowerMeter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${param_actPowerMeter}
    ${apm_status}  Evaluate Xpath  ${scfc_xml}
    ...     string(.//managedObject[@distName='MRBTS-${BTS_ID}/MNL-1/MNLENT-1/FEATCADM-1']/p[@name='actPowerMeter']/text())
    Set Test Variable  ${ACTPOWERM_STATUS}  ${apm_status}

    Run Keyword If  '${ACTPOWERM_STATUS}'=='false'  Run Keywords
    ...  Log  actPowerMeter is set to False, recommissioning to True...  console=True
    ...  AND  admin.Perform Parameter Recommissioning  ${FEATCADM_OBJECT}  actPowerMeter  update  true  alias=${node}
    ...  ELSE  Log  actPowerMeter already set to True, recommissioning not needed  console=True

    Log  ${\n}Getting information about tested RMODs  console=True

    ${radios_sn}  Split String  ${RMOD_SN}  ,
    &{rmods_info}  Create Dictionary
    FOR  ${test_radio}  IN  @{RADIOS_SN}
        ${rmod_distname}  ${rmod_name}  Get RU DistName And RU Name  ${test_radio}  alias=${node}
        Set To Dictionary  ${rmods_info}  ${rmod_name}  ${rmod_distname}
    END
    Set Test Variable  ${RMODS_INFO}

    ${dtx_modification_new_way}  Check If Current Build Is Newer Than  SBTS25R1_ENB_9999_240718_000010  alias=${node}
    Set Test Variable  ${DTX_MODIFICATION_NEW_WAY}

    Log  ${\n}Checking if LTE MicroDtx needs to be disabled  console=True
    ${lte_info}  admin.Get parameters for all  LNCEL  alias=${node}
    ${lte_availability}  Run Keyword And Return Status  Should Contain  ${lte_info[0].id}  LNBTS
    Run Keyword If  '${lte_availability}'=='True'  Run Keywords
    ...  Log  There are LNCEL(s) on BTS, disabling MicroDtx for LTE will be performed${\n}  console=True
    ...  AND  Deactivate LTE MicroDtx
    ...  ELSE  Log  There is no need to disable LTE MicroDtx${\n}  console=True
    Set Test Variable  ${LTE_AVAILABILITY}

Deactivate LTE MicroDtx
    ${cells_id}  Automated__SiSo_5G_uDTX.Create LNCEL List
    Set Test Variable  ${CELLS_ID}

    ${initial_dict_aTC_status}  Automated__SiSo_5G_uDTX.Check Status Of allowTrafficConcentration
    Set Test Variable  ${INITIAL_DICT_ATC_STATUS}
    ${initial_dict_status_lte_dtx}  Automated__SiSo_5G_uDTX.Check Status Of LTE microDTX
    Set Test Variable  ${INITIAL_DICT_STATUS_LTE_DTX}

    admin.Create Delta
    @{cellListWithParamToModify}  Create List
    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_ATC_STATUS.keys()}  ${INITIAL_DICT_ATC_STATUS.values()}
        ${status_aTC}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  true
        Run Keyword If  '${status_aTC}'=='True'  Run Keywords
        ...  Append To List  ${cellListWithParamToModify}  ${test_cell_keys}
        ...  AND  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  allowTrafficConcentration  false
    END

    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_STATUS_LTE_DTX.keys()}  ${INITIAL_DICT_STATUS_LTE_DTX.values()}
        ${status_lte_dtx}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  true
        Run Keyword If  '${status_lte_dtx}'=='True'  Run Keywords
        ...  Append To List  ${cellListWithParamToModify}  ${test_cell_keys}
        ...  AND  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  actMicroDtx  false
    END
    ${lteDTX_recomm}  Run Keyword And Return Status  Should Not Be Empty  ${cellListWithParamToModify}
    Run Keyword If  '${lteDTX_recomm}'=='True'
    ...  Automated__SiSo_5G_uDTX.Perform recommissioning
    ...  ELSE  Log  ${\n}Recommissioning is not needed  console=True
    Set Test Variable  ${LTEDTX_RECOMM}
    admin.Remove Delta
    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}
    Log  Checking if LTE MicroDtx is deactivated for tested cells  console=True
    ${dict_status_lte_dtx}  Automated__SiSo_5G_uDTX.Check Status Of LTE microDtx
    ${initial_dict_aTC_status}  Automated__SiSo_5G_uDTX.Check Status Of allowTrafficConcentration
    ${dtx_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${dict_status_lte_dtx}  true
    ${aTC_status}  Run Keyword And Return Status  Dictionary Should Not Contain Value  ${initial_dict_aTC_status}  true
    Run Keyword If  '${dtx_status}'=='True' and '${aTC_status}'=='True'
    ...  Log  LTE MicroDtx is deactivated properly!  console=True
    ...  ELSE  Run Keywords
    ...  Log  LTE MicroDtx is not deactivated properly!  console=True
    ...  AND  Fail  LTE MicroDtx is not deactivated properly!

Step 2: Check 5G MicroDTX status and activate MicroDTX
    Log  ${\n}Step 2: Check 5G MicroDTX status and activate MicroDTX  console=True
    Log  -----------------------------------------------------------${\n}  console=True

    Run Keyword If  ${DTX_MODIFICATION_NEW_WAY}  5G DTX Parameters Modification By Vendor File  vf_dtx_value=true
    ...  ELSE  5G DTX Parameters Modification By SCF  scf_dtx_value=true

    Log  ${\n}Getting counters for EEM when MicroDTX is activated  console=True
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.start_measurement_period  ee_features_status=enabled  interval=${EE_INTERVAL}

Step 3: Check RMOD power consumption when 5G MicroDTX is activated
    Log  ${\n}Step 3: Check RMOD power consumption when MicroDTX is activated  console=True
    Log  ---------------------------------------------------------------${\n}  console=True

    Sleep  5 min
    ${RMOD_POWER}  Create List
    Set Test Variable  ${RMOD_POWER}
    ${measurements}  admin.Get Measurements
    FOR  ${rmods_name}  ${rmods_distname}  IN ZIP  ${RMODS_INFO.keys()}  ${RMODS_INFO.values()}
       ${rmod_number}  Fetch From Right  ${rmods_distname}  /
       ${power_DTX_activated}  Rmod Get Power Measurement  ${measurements}  ${rmod_number}
       ${dict}  Create Dictionary  rmod=${rmods_name}  rm_dist=${rmods_distname}  power_mdtx_ON[W]=${power_DTX_activated}
       Log  ${dict}  console=True
       Append To List  ${RMOD_POWER}  ${dict}
    END

    Log  ${\n}Saving counters EEM - MicroDTX enabled   console=True
    ee_monitoring.stop_measurement_period  ee_features_status=enabled
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.save_energy_consumption_counters_values  ee_features_status=enabled  filepath=${OUTPUT DIR}/enabled_features_log.json

Step 4: Deactivate 5G MicroDTX - SBTS recommissioning
    Log  ${\n}Step 4: Deactivation 5G MicroDTX is going  console=True
    Log  ----------------------------------------------${\n}  console=True

    Run Keyword If  ${DTX_MODIFICATION_NEW_WAY}  5G DTX Parameters Modification By Vendor File  vf_dtx_value=false
    ...  ELSE  5G MicroDTX - SBTS recommissioning  scf_dtx_value=false

    Log  ${\n}Getting counters for EEM when MicroDTX is deactivated  console=True
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.start_measurement_period  ee_features_status=disabled  interval=${EE_INTERVAL}

Step 5: Check RMOD power consumption when 5G MicroDTX is deactivated and compare
    Log  ${\n}Step 5: Check RMOD power consumption when MicroDTX is deactivated and compare  console=True
    Log  ----------------------------------------------------------------------------------${\n}  console=True

    Sleep  5 min
    ${measurements}  admin.Get Measurements
    FOR  ${items}  IN  @{RMOD_POWER}
        ${rmod}  Get From Dictionary  ${items}  rm_dist
        ${rmod_number}  Fetch From Right  ${rmod}  /
        ${power_DTX_deactivated}  Rmod Get Power Measurement  ${measurements}  ${rmod_number}
        ${power_DTX_activated}  Get From Dictionary  ${items}  power_mdtx_ON[W]
        Set To Dictionary  ${items}  power_mdtx_OFF[W]=${power_DTX_deactivated}
        Log  ${items}  console=True
        ${power_diff_status}  Evaluate  ${power_DTX_activated}+5 < ${power_DTX_deactivated}
        Run Keyword If  ${power_diff_status}
        ...  Log  Power is correct - higher after dectivating MicroDTX${\n}  console=True
        ...  ELSE  Run Keywords
        ...  Log  Power did not increase enough after deactivation of MicroDTX  console=True
        ...  AND  Fail  Power did not increase enough after deactivation of MicroDTX
    END

    Log  ${\n}Saving counters for EEM (MicroDTX disabled) and getting the difference  console=True
    ee_monitoring.stop_measurement_period  ee_features_status=disabled
    ee_monitoring.wait_for_next_pm_period  interval=${EE_INTERVAL}
    ee_monitoring.save_energy_consumption_counters_values  ee_features_status=disabled  filepath=${OUTPUT DIR}/disabled_features_log.json
    ee_monitoring.get_counters_difference_for_enabled_disabled_features

Restore parameters to initial status
    Log  ${\n}Restoring MicroDTX to initial status  console=True
    Log  -----------------------------------------${\n}  console=True

    Restore 5G MicroDTX
    Run Keyword If  '${LTE_AVAILABILITY}'=='True'  Restore LTE MicroDTX

    Run Keyword If  'False' in '${ACTPOWERM_STATUS}'  Run Keywords
    ...  admin.Perform Parameter Recommissioning  ${FEATCADM_OBJECT}  actPowerMeter  update  false  alias=${node}
    ...  AND  Log  Parameter  'actPowerMeter'  back to initial status  console=True

Restore 5G MicroDTX
    ${actMicroDTX_current}  ${actMicroDTXAdvanced_current}  Run Keyword If  ${DTX_MODIFICATION_NEW_WAY}  Restoring Parameters By Vendor File
    ...  ELSE  Restoring Parameters By SCF

    Log  ===Checking if 5G MicroDTX is restored===  console=True
    Run Keyword If
    ...  '${actMicroDTX_current}'=='${ACTMICRODTX_DEFAULT_STATUS}' and '${actMicroDTXAdvanced_current}'=='${ACTMICRODTXADVANCED_DEFAULT_STATUS}'
    ...  Log  Initial and current parameters of 5G MicroDTX have the same status${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Initial and current parameters of 5G MicroDTX have different status!${\n}  console=True
    ...  AND  Fail  Initial and current parameters of 5G MicroDTX have different status!

Restoring Parameters By Vendor File
    Log  ---Checking if 5G MicroDTX parameters need to be restore to initial status---  console=True
    Run Keyword If  '${ACTMICRODTX_DEFAULT_STATUS}'=='false'
    ...  Log  Deactivation of parameter actMicroDTX for 5G is not needed${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actMicroDTX for 5G is going to be activated  console=True
    ...  AND  Set Element Text  ${V_F_TO_MODIFY_XML}  true  xpath=.//managedObject[@distName="MRBTS-*/NRBTS-*"]/p[@name='actMicroDTX']
    ...  AND  Save XML  ${V_F_TO_MODIFY_XML}  ${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_Restore.xml

    Run Keyword If  '${ACTMICRODTXADVANCED_DEFAULT_STATUS}'=='false'
    ...  Log  Deactivation of parameter actMicroDTX for 5G is not needed${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actMicroDTXAdvanced for 5G is going to be activated  console=True
    ...  AND  Set Element Text  ${V_F_TO_MODIFY_XML}  true  xpath=.//managedObject[@distName="MRBTS-*/NRBTS-*"]/p[@name='actMicroDTXAdvanced']
    ...  AND  Save XML  ${V_F_TO_MODIFY_XML}  ${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_Restore.xml

    Run Keyword If  '${ACTMICRODTX_DEFAULT_STATUS}'=='true' or '${ACTMICRODTXADVANCED_DEFAULT_STATUS}'=='true'  Run Keywords
    ...  Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/selenium/Vendor_File_Catalog
    ...  AND  selenium_coam.Load Vendor File And Validate  file_path=${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_Restore.xml
    ...  AND  Perform Commissioning Via Selenium  file_path=${TestFiles}/selenium/Vendor_File_Catalog/SCF_conf.xml
    ...  AND  Selenium Logout And Close Browser

    ${actMicroDTX_current}  ${actMicroDTXAdvanced_current}  Check DTX Parameters In Info Model Viewer
    [Return]  ${actMicroDTX_current}  ${actMicroDTXAdvanced_current}

Restoring Parameters By SCF
    Log  ---Checking if 5G MicroDTX parameters need to be restore to initial status---  console=True
    admin.Create Delta
    Run Keyword If  '${ACTMICRODTX_DEFAULT_STATUS}'=='false'
    ...  Log  Deactivation of parameter actMicroDTX for 5G is not needed  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actMicroDTX for 5G is going to be activated  console=True
    ...  AND  admin.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}  actMicroDTX  true

    Run Keyword If  '${ACTMICRODTXADVANCED_DEFAULT_STATUS}'=='false'
    ...  Log  Deactivation of parameter actMicroDTXAdvanced for 5G is not needed${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Log  Parameter actMicroDTXAdvanced for 5G is going to be activated  console=True
    ...  AND  admin.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}  actMicroDTXAdvanced  true
    Run Keyword If  '${ACTMICRODTX_DEFAULT_STATUS}'=='true' or '${ACTMICRODTXADVANCED_DEFAULT_STATUS}'=='true'
    ...  Automated__SiSo_5G_uDTX.Perform recommissioning
    admin.Remove Delta

    ${actMicroDTX_current}  Automated__SiSo_5G_uDTX.Check Status Of 5G actMicroDTX
    ${actMicroDTXAdvanced_current}  Automated__SiSo_5G_uDTX.Check Status Of 5G actMicroDTXAdvanced
    [Return]  ${actMicroDTX_current}  ${actMicroDTXAdvanced_current}

Restore LTE MicroDTX
    Log  ---Checking if LTE MicroDTX parameters need to be restore to initial status---  console=True
    admin.Create Delta
    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_ATC_STATUS.keys()}  ${INITIAL_DICT_ATC_STATUS.values()}
        ${status_aTC}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  true
        Run Keyword If  '${status_aTC}'=='True'
        ...  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  allowTrafficConcentration  true
    END

    FOR  ${test_cell_keys}  ${test_cell_values}  IN ZIP  ${INITIAL_DICT_STATUS_LTE_DTX.keys()}  ${INITIAL_DICT_STATUS_LTE_DTX.values()}
        ${status_dtx}  Run Keyword And Return Status  Should Be Equal  ${test_cell_values}  true
        Run Keyword If  '${status_dtx}'=='True'
        ...  admin.Append Parameter Update To Delta
        ...  MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell_keys}  actMicroDtx  true
    END
    Run Keyword If  ${LTEDTX_RECOMM}  Automated__SiSo_5G_uDTX.Perform recommissioning
    ...  ELSE  Log  LTE MicroDTX parameters does not need to be restore, recommissioning will not be performed${\n}  console=True
    admin.Remove Delta

Get RU DistName And RU Name
    [Arguments]  ${rmod_sn}  ${alias}=default
    ${all_ru_params}  admin.Get Parameters For All  RMOD  alias=${alias}
    FOR  ${rmod}  IN  @{all_ru_params}
        Continue For Loop If  '${rmod_sn}'!='${rmod['serialNumber']}'
        ${rmod_distname}  Set Variable  ${rmod['id']}
        ${rmod_name}  Set Variable  ${rmod['productName']}
    END
    [Return]  ${rmod_distname}  ${rmod_name}

Rmod Get Power Measurement
    [Arguments]  ${measurements}  ${rmod_number}
    FOR  ${measurement}  IN  @{measurements}
        ${rmod}=  Get Dictionary Keys  ${measurement}
        ${rmod}=  Get From List    ${rmod}    0
        ${rmod_r}=   Fetch From Right  ${rmod}  /
        ${rmod_power}  Run Keyword If  '${rmod_r}'=='${rmod_number}'  Get From Dictionary  ${measurement}  ${rmod}
        ${power}  Run Keyword If  '${rmod_r}'=='${rmod_number}'  Get From Dictionary  ${rmod_power}  power
        Exit For Loop If  '${rmod_r}'=='${rmod_number}'
     END
    [Return]  ${power}

Check Status Of 5G actMicroDTX
    ${parameter_dtx}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${parameter_dtx}
    ${managedObject}  Set Variable  .//managedObject[@class='com.nokia.srbts.nrbts:NRBTS'
    ${actMicroDTX}  Evaluate Xpath  ${scfc_xml}
    ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/NRBTS-${BTS_ID}']/p[@name='actMicroDTX']/text())
    [Return]   ${actMicroDTX}

Check Status Of 5G actMicroDTXAdvanced
    ${parameter_dtx_adv}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${parameter_dtx_adv}
    ${managedObject}  Set Variable  .//managedObject[@class='com.nokia.srbts.nrbts:NRBTS'
    ${actMicroDTXadvanced}  Evaluate Xpath  ${scfc_xml}
    ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/NRBTS-${BTS_ID}']/p[@name='actMicroDTXAdvanced']/text())
    [Return]   ${actMicroDTXAdvanced}

5G MicroDTX - SBTS recommissioning
    [Arguments]  ${scf_dtx_value}
    Log  Updating values of parameters actMicroDTX and actMicroDTXAdvanced  console=True
    admin.Create Delta
    admin.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}  actMicroDTX  ${scf_dtx_value}
    admin.Append Parameter Update To Delta  MRBTS-${BTS_ID}/NRBTS-${BTS_ID}  actMicroDTXAdvanced  ${scf_dtx_value}
    Automated__SiSo_5G_uDTX.Perform recommissioning
    admin.Remove Delta

    Log  Checking if MicroDTX is modified!  console=True
    ${check_dtx_status}  Automated__SiSo_5G_uDTX.Check Status Of 5G actMicroDTX
    ${check_dtx_advanced_status}  Automated__SiSo_5G_uDTX.Check Status Of 5G actMicroDTXAdvanced
    Run Keyword If  '${check_dtx_status}'=='${scf_dtx_value}' and '${check_dtx_advanced_status}'=='${scf_dtx_value}'
    ...  Log  5G MicroDTX is modified properly! Values set -> ${scf_dtx_value}${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Fail  5G MicroDTX is not modified properly! Values should be set -> ${scf_dtx_value}
    ...  AND  Log  5G MicroDTX is not modified properly! Values should be set -> ${scf_dtx_value} ${\n}  console=True

Check Status Of allowTrafficConcentration
    &{status_atc_dict}  Create Dictionary
    ${parameter_aTC}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
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
    ${parameter_dtx}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${node}
    ${scfc_xml}  Parse XML  source=${parameter_dtx}
    ${managedObject}  Set Variable  .//managedObject[@class='NOKLTE:LNCEL'
    FOR  ${test_cell}  IN  @{CELLS_ID}
       ${actMicroDtx}  Evaluate Xpath  ${scfc_xml}
       ...  string(${managedObject} and @distName='MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${test_cell}']/p[@name='actMicroDtx']/text())
       Set To Dictionary    ${dict_status_dtx}   ${test_cell}   ${actMicroDtx.lower()}
    END
    [Return]   ${dict_status_dtx}

Perform Commissioning Via Selenium
    [Arguments]  ${file_path}
    Log  Performing recommissioning, please wait!  console=True
    selenium_coam.Load Commissioning File And Check Load Status  ${file_path}
    selenium_coam.Activate Plan  timeout=400
    Log  ${\n}Check if BTS and cells are onAir  console=True
    ${BTS_status}  Run Keyword And Return Status  Wait Until Keyword Succeeds  8 min  60 s
    ...  Check If All Cells And Modules Are OnAir  timeout=60  alias=${node}
    Run Keyword If  '${BTS_status}'=='True'
    ...  Log  BTS is onAir${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Selenium Logout And Close Browser
    ...  AND  Fail  BTS is not onAir

Perform recommissioning
    Log  Performing recommissioning, please wait!  console=True
    ${delta}  admin.Get Delta
    ${delta_status}  Run Keyword And Return Status
    ...  Wait Until Keyword Succeeds  5 min  30 s  admin.Perform Delta Recommissioning  ${delta}
    ...  timeout=${RECOMMISSIONING_TIMEOUT}
    Run Keyword If  '${delta_status}'=='True'
    ...  Log  Recommissioning is done successfully!${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Fail  Recommissioning is not done successfully!
    ...  AND  Log  Recommissioning is not done successfully!  console=True

    Log  Checking cells status...  console=True
    ${cells_status}  Run Keyword And Return Status  Check If All Cells Are onAir  timeout=180  alias=${node}
    Run Keyword If  '${cells_status}'=='True'
    ...  Log  All cells are onAir!${\n}  console=True
    ...  ELSE  Run Keywords
    ...  Fail  Cells are not onAir!
    ...  AND  Log  Cells are not onAir!  console=True

Create LNCEL List
    @{CELLS_ID}=  Create List  @{EMPTY}
    ${lncels}=  admin.Get Ids For All  LNCEL  search_for_iot_cells=${True}
    FOR  ${lncel}  IN  @{lncels}
        ${lncel}=  Fetch From Right  ${lncel}  -
        Append To List  ${CELLS_ID}  ${lncel}
    END
    [Return]  ${cells_id}

5G DTX Parameters Modification By SCF
    [Arguments]  ${scf_dtx_value}
    Log  Checking and updating values of parameters actMicroDTX and actMicroDTXAdvanced  console=True
    Run Keyword If  'true' in '${scf_dtx_value}'  Check Status Of Default Parameters From SCF

    Run Keyword If  '${ACTMICRODTX_DEFAULT_STATUS}'=='false'  Run Keywords
    ...  Log  5G MicroDTX is deactivated! Values set -> ${scf_dtx_value}  console=True
    ...  AND  5G MicroDTX - SBTS recommissioning  ${scf_dtx_value}
    ...  ELSE
    ...  Log  5G MicroDTX is activated! Values set ${scf_dtx_value}  console=True

Check Status Of Default Parameters From SCF
    Log  Checking status of 5G MicroDTX  console=True
    ${actMicroDTX_default_status}  Automated__SiSo_5G_uDTX.Check Status Of 5G actMicroDTX
    ${actMicroDTXadvanced_default_status}  Automated__SiSo_5G_uDTX.Check Status Of 5G actMicroDTXAdvanced
    Set Test Variable  ${ACTMICRODTX_DEFAULT_STATUS}
    Set Test Variable  ${ACTMICRODTXADVANCED_DEFAULT_STATUS}
    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

5G DTX Parameters Modification By Vendor File
    [Arguments]  ${vf_dtx_value}
    Log  Updating values of parameters actMicroDTX and actMicroDTXAdvanced${\n}  console=True

    Run Keyword If  'true' in '${vf_dtx_value}'  Check Status Of Default Parameters From Vendor File
    ...  ELSE  Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/selenium/Vendor_File_Catalog

    Set Element Text  ${V_F_TO_MODIFY_XML}  ${vf_dtx_value}  xpath=.//managedObject[@distName="MRBTS-*/NRBTS-*"]/p[@name='actMicroDTX']
    Set Element Text  ${V_F_TO_MODIFY_XML}  ${vf_dtx_value}  xpath=.//managedObject[@distName="MRBTS-*/NRBTS-*"]/p[@name='actMicroDTXAdvanced']

    Run Keyword If  'true' in '${vf_dtx_value}'  Run Keywords
    ...  Save XML  ${V_F_TO_MODIFY_XML}  ${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_DTX_Activated.xml
    ...  AND  selenium_coam.Load Vendor File And Validate  file_path=${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_DTX_Activated.xml
    ...  AND  admin.Get Current Scf File  local_dir_path=${TestFiles}/selenium/Vendor_File_Catalog  file_name=SCF_conf.xml  export_type=configuration
    ...  ELSE  Run Keywords  Save XML  ${V_F_TO_MODIFY_XML}  ${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_DTX_Deactivated.xml
    ...  AND  selenium_coam.Load Vendor File And Validate  file_path=${TestFiles}/selenium/Vendor_File_Catalog/VendorFile_DTX_Deactivated.xml

    Perform Commissioning Via Selenium  file_path=${TestFiles}/selenium/Vendor_File_Catalog/SCF_conf.xml
    Selenium Logout And Close Browser

    Log  Checking if 5G MicroDTX is modified properly  console=True
    ${actMicroDTX_modified}  ${actMicroDTXAdvanced_modified}  Check DTX Parameters In Info Model Viewer
    Run Keyword If  '${actMicroDTX_modified}'=='${vf_dtx_value}' and '${actMicroDTXAdvanced_modified}'=='${vf_dtx_value}'
    ...  Log  5G MicroDTX is modified properly! Values set -> ${vf_dtx_value}  console=True
    ...  ELSE  Run Keywords
    ...  Log  5G MicroDTX is not modified properly! Values should be set -> ${vf_dtx_value}  console=True
    ...  AND  Selenium Logout And Close Browser
    ...  AND  Fail  5G MicroDTX is not modified properly! Values should be set -> ${vf_dtx_value}  console=True

Check Status Of Default Parameters From Vendor File
    Log  Checking status of 5G MicroDTX${\n}  console=True
    Selenium Login And Disable Screen Lock  download_dir=${TestFiles}/selenium/Vendor_File_Catalog
    ${vendor_file_to_modify}  selenium_coam.Download Default File  timeout=60
    ${v_f_to_modify_xml}  Parse XML  source=${vendor_file_to_modify}
    Save XML  ${v_f_to_modify_xml}  ${TestFiles}/selenium/Vendor_File_Catalog/VendorFileDefault.xml
    Set Test Variable  ${V_F_TO_MODIFY_XML}
    ${actMicroDTX_path}  Set Variable  .//managedObject[@distName="MRBTS-*/NRBTS-*"]/p[@name='actMicroDTX']/text()
    ${actMicroDTXAdvanced_path}  Set Variable  .//managedObject[@distName="MRBTS-*/NRBTS-*"]/p[@name='actMicroDTXAdvanced']/text()
    ${actMicroDTX_default_status}  Get Elements  ${V_F_TO_MODIFY_XML}  string(${actMicroDTX_path})
    ${actMicroDTXAdvanced_default_status}  Get Elements  ${V_F_TO_MODIFY_XML}  string(${actMicroDTXAdvanced_path})
    Set Test Variable  ${ACTMICRODTX_DEFAULT_STATUS}
    Set Test Variable  ${ACTMICRODTXADVANCED_DEFAULT_STATUS}
    Set Test Variable  ${RESTORE_CONFIG}  ${TRUE}

Check DTX Parameters In Info Model Viewer
    ${nr_info}  admin.Get parameters for all  NRCEL  alias=${node}
    ${nrcel_runtime_id}  Set Variable  ${nr_info[0].id}
    ${nrbts_object}  ${nrcell_object}  Split String From Right  ${nrcel_runtime_id}  /  1
    ${CONF_REF_obj}  Query Infomodel  get object ${nrbts_object}/CONF_REF-1  alias=${node}
    ${NR_distName}  Query Infomodel  query=get object ${CONF_REF_obj.distName}  alias=${node}
    ${actMicroDTX_status}  Set Variable  ${NR_distName.actMicroDTX}
    ${actMicroDTX_status}  Evaluate    str(${actMicroDTX_status}).lower()
    ${actMicroDTXAdvanced_status}  Set Variable  ${NR_distName.actMicroDTXAdvanced}
    ${actMicroDTXAdvanced_status}  Evaluate    str(${actMicroDTXAdvanced_status}).lower()
    [Return]  ${actMicroDTX_status}  ${actMicroDTXAdvanced_status}

Selenium Login And Disable Screen Lock
    [Arguments]  ${download_dir}=${TestFiles}/selenium
    ${browser}  selenium_coam.Create Firefox Browser  download_dir=${download_dir}  screenshot_dir=${download_dir}  name=firefox_browser
    ${sw_release}  admin.Get Sw Release Name
    selenium_coam.Login  ${WEBUI_URL}  ${WEBUI_NAME}  ${WEBUI_PWD}  download_dir=${download_dir}
    ...  screenshot_dir=${download_dir}  version=${sw_release}  browser=${browser}
    ${view_exists}  selenium_coam.Start Up View Window Exists
    Run Keyword If  ${view_exists}  selenium_coam.Close Start Up View Window
    selenium_coam.disable_message_box
    selenium_coam.disable_screen_lock

Selenium Logout And Close Browser
    Run Keyword And Ignore Error  selenium_coam.logout
    Run Keyword And Ignore Error  selenium_coam.close_browser


TC Setup
    Common Test Setup

TC Teardown
    Run Keyword If Test Failed  Run Keyword If  ${RESTORE_CONFIG}  Restore parameters to initial status
    Common Test Teardown

