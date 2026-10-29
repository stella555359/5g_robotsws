*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource containing KWs for Site Operations


Library    taf.sbts.oam.coam.admin      WITH NAME    admin

*** Keywords ***
SITE Check If DyingGaspAlarm
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword checks if DyingGaspAlarm is going to be sent when power off on RU. ${TRUE}/${FALSE} is returned.
    ...  DyingGaspAlarm (CB005763) message results with fault 4774 only as R&D and additional info under fault 10 "RU power loss"
    ...  If DyingGaspAlarm (CB005763) message not sent, standard fault 1972 appears and default fault 10 without additional info.
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${bts_id}  ${ru_runtime_distname}=  SITE Get RU Node Data  ${ru_sn}
    ${is_feature_dyingGaspAlarm}=  Run Keyword And Return Status  SWM Check If Current SW Build Is Newer Than
    ...  SBTS25R3_ENB_9999_250410_000011
    ...  bts_id=${bts_id}
    Return From Keyword If  not ${is_feature_dyingGaspAlarm}  ${FALSE}
    ${is_asirmod}=  Run Keyword And Return Status  Dictionary Should Contain Key  ${CFG['ASIR_INFO']}  ${ru_sn}
    Return From Keyword If  ${is_asirmod}  ${TRUE}
    ${ru_parameters}=  admin.Get Parameters  dist_name=${ru_runtime_distname}  connection=${bts_id}
    ${is_CPRI}=  Set Variable If  '${ru_parameters['l3Protocol']}'=='CPRI_RP1'  ${TRUE}  ${FALSE}
    ${is_eCPRI}=  Set Variable If  'ECPRI' in '${ru_parameters['l3Protocol']}'  ${TRUE}  ${FALSE}
    ${is_fhs}=  SITE Check If RU Connected To FHS  ${ru_sn}
    ${is_ABIL_limitation}=  IF  ${is_eCPRI}  SITE Check ABIL Limitation  ${ru_sn}  ELSE  Set Variable  ${FALSE}
    Return From Keyword If  (${is_CPRI} or ${is_eCPRI}) and not ${is_fhs} and not ${is_ABIL_limitation}  ${TRUE}
    [Return]  ${FALSE}

SITE Check ABIL Limitation
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword checks if tested radio connected to ABIL has eCPRI-TDD. Return TRUE or FALSE
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${bts_id}  ${ru_runtime_distname}=  SITE Get RU Node Data  ${ru_sn}
    ${bbs}=  admin.Get Ids For All  BBMOD  connection=${bts_id}
    FOR  ${bb}  IN  @{bbs}
      ${bb_parameters}=  admin.Get Parameters  dist_name=${bb}  connection=${bts_id}
      Continue For Loop If  'ABIL' not in '${bb_parameters['productName']}'
      ${bb_r}=  Fetch From Right  ${bb}  /
      ${ru_r}=  Fetch From Right  ${ru_runtime_distname}  /
      ${condition_1}=  Set Variable  contains(p[@name='firstEndpointDN'], '${bb_r}') and contains(p[@name='secondEndpointDN'], '${ru_r}')
      ${is_ru_in_abil}=  Evaluate Xpath  ${CFG['NODES']['${bts_id_for_ru}']['scf_file_path']}
      ...  boolean(.//managedObject[contains(@class, ':CABLINK_R') and ${condition_1}])
      Continue For Loop If  not ${is_ru_in_abil}
      ${cells_on_ru}=  admin. Get Cell Mapping By Module Id  ${ru_runtime_distname}  connection=${bts_id}
      Return From Keyword If  '${cells_on_ru[0]['technology']}'=='TDD'  ${TRUE}
    END
    [Return]  ${FALSE}

SITE Check If Fault 1972 Expected
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword checks if fault 1972 should be expected. DyingGaspAlarm (CB005763) message not sent,
    ...  standard fault 1972 appears and default fault 10 without additional info. Return TRUE/FALSE
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${is_ru_FZ}=  Run Keyword And Return Status  Should Match  ${CFG['RF_INFO']['${ru_sn}']['scf_variant']}  FZ*
    [Return]  ${is_ru_FZ}

SITE Get RU Node Data
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword finds BTS_ID that RU belongs to and runtime distname for further usage.
    ...  KW supports ASIRMODS as well as RMOD.
    ...  KW moved from robotlte_legacy: "Get RU Node Data"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...  | Return Value             | Description                                                             |
    ...  +==========================+=========================================================================+
    ...  | bts_id                   | bts_id belongs to ru                                                    |
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...  | ru_dist_name             | runtime ru distname                                                     |
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${bts_id}=  Set Variable  ${CFG['RF_INFO']['${ru_sn}']['scf_btsid_primary']}
    ${ru_conf_dist_name}=  Get From Dictionary  ${cfg['RF_INFO']['${ru_sn}']}  scf_dist_name_primary
    ${bts_info}=  admin.Get Bts Info  connection=${bts_id}
    ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${ru_conf_dist_name}  ASIRMOD
    ${class}=  Set Variable If  ${asirmod_status}  asirmod  rmod
    ${ru_info}=  Get From Dictionary  ${bts_info['radioModules']}  ${class}
    FOR  ${ru}  IN  @{ru_info}
      ${ru_dist_name}=  Set Variable If  "${ru['serialNumber']}" == "${ru_sn}"  ${ru['id']['internal']}
      Exit For Loop If  "${ru['serialNumber']}" == "${ru_sn}"
    END
    [Return]  ${bts_id}  ${ru_dist_name}

SITE Check If RU Connected To FHS
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword checks two possibilities. Firstly returns ${TRUE} if 'ru_sn' is connected directly to fhs.
    ...  Secondly returns ${TRUE} if 'ru_sn' is connected indirectly to fhs (ex. in chain). If 'ru_sn' is not connected
    ...  to fhs at all then keyword returns ${FALSE}
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${bts_id_for_ru}=  Set Variable  ${CFG['RF_INFO']['${ru_sn}']['scf_btsid_primary']}
    ${ru_conf_dist_name}=  Get From Dictionary  ${cfg['RF_INFO']['${ru_sn}']}  scf_dist_name_primary
    ${condition_1}=  Set Variable  contains(@class, ':CABLINK') and not(contains(@class, '_R'))
    ${condition_2}=  Set Variable  contains(p[@name='firstEndpointDN'], 'FHS') and (p[@name='secondEndpointDN']='${ru_conf_dist_name}')
    ${ru_directly_in_fhs}=  Evaluate Xpath  ${CFG['NODES']['${bts_id_for_ru}']['scf_file_path']}
    ...  boolean(.//managedObject[${condition_1} and ${condition_2}])
    Return From Keyword If  ${ru_directly_in_fhs}  ${TRUE}
    ${all_ru_confdn_conn_to_fhs}=  Evaluate Xpath  ${CFG['NODES']['${bts_id_for_ru}']['scf_file_path']}
    ...  .//managedObject[${condition_1} and contains(p[@name='firstEndpointDN'], 'FHS')]/p[@name='secondEndpointDN']/text()
    FOR  ${cfg_ru_sn}  IN  @{CFG['RF_INFO']}
      Continue For Loop If  '${CFG['RF_INFO']['${cfg_ru_sn}']['scf_dist_name_primary']}' not in ${all_ru_confdn_conn_to_fhs}
      Return From Keyword If  '${ru_sn}' in ${CFG['RF_INFO']['${cfg_ru_sn}']['scf_chain_fr_affected_list']}  ${TRUE}
    END
    [Return]  ${FALSE}

SITE Perform RU Power Remove
    [Arguments]  ${ru_sn}  ${gasp_alarm_user_switch}=${FALSE}
    [Documentation]  Keyword performs power off on PDU and prepares 'EXPECTED_LINK_BREAK_LIST' for eventual FID 1815 verification.
    ...  KW moved from robotlte_legacy: "Perform RU Power Remove"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | gasp_alarm_user_switch | No   | user switch for global activate/deactivate FID 10 additional check |
    ...  |                        |      | default value is False                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Radio ${ru_sn} power remove procedure started
    ${is_dyingGaspAlarm_tmp}=  SITE Check If DyingGaspAlarm  ${ru_sn}
    ${is_dyingGaspAlarm}=  Set Variable If  ${gasp_alarm_user_switch}  ${is_dyingGaspAlarm_tmp}  ${gasp_alarm_user_switch}
    Set Test Variable  ${IS_DYINGGASPALARM}  ${is_dyingGaspAlarm}
    Sleep  10  Wait for R&D fault timestamp
    IF  ${IS_DYINGGASPALARM}  FM Set Start Timestamp In IMS For RD Fault  find_rd_fault=${TRUE}
    ${ru_sn_list}=  Create List  ${ru_sn}
    ${timestamp}=  Get Current Date  UTC
    ${status}=  Run Keyword And Return Status  PDU Switch OFF Device Lists  ${ru_sn_list}
    ${ru_bts_id}  ${ru_dist_name}=  SITE Get RU Node Data  ${ru_sn}
    ${timestamp_in_epoch}=  Convert Date
    ...  date=${timestamp}
    ...  date_format=%Y-%m-%d %H:%M:%S.%f
    ...  result_format=epoch
    ${link_break_event_dict}=  Create Dictionary
    ...  ru_sn=${ru_sn}
    ...  ru_dist_name=${ru_dist_name}
    ...  timestamp=${timestamp_in_epoch}
    Append To List  ${EXPECTED_LINK_BREAK_LIST}  ${link_break_event_dict}
    [Teardown]  Logging With Timestamp
    ...  message=Radio ${ru_sn} power remove procedure finished. Status = ${status}

SITE Perform RU Power Insert
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword performs power on using PDU and prepares 'RU_STARTUP_START_DATE' for startup time validation.
    ...  KW moved from robotlte_legacy: "Perform RU Power Insert"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...  | Return Value             | Description                                                             |
    ...  +==========================+=========================================================================+
    ...  | ru_startup_start_date    | time when radio startap begins                                          |
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Radio ${ru_sn} power insert procedure started
    ${ru_sn_list}=  Create List  ${ru_sn}
    ${status}=  Run Keyword And Return Status  PDU Switch On Device Lists  ${ru_sn_list}
    ${ru_startup_start_date}=  Run Keyword If  ${status}
    ...  Get Current Date  UTC
    ...  ELSE  Set Variable  ${0}
    [Teardown]  Logging With Timestamp
    ...  message=Radio ${ru_sn} power insert procedure finished. Status = ${status}
    [Return]  ${ru_startup_start_date}

SITE Verify RU Power Remove Insert State
    [Arguments]  ${bts_id}  ${dist_name}  ${state}  ${timeout}
    [Documentation]  Keyword verifies if tested radio has correct states depending on 'state'. Returns data stamp after states check.
    ...  KW moved from robotlte_legacy: "Verify RU Power Remove Insert State"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id belongs to ru                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | dist_name              | Yes  | radio runtime distname                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | state                  | Yes  | possible: Remove / Insert                                          |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | verification timeout                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...  | Return Value             | Description                                                             |
    ...  +==========================+=========================================================================+
    ...  | time_stamp               | time stamp after KW finished                                            |
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Radio state check admin procedure started
    ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${dist_name}  ASIRMOD
    ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
    ${status_1}=  Run Keyword If  "${state}" == "Remove"
    ...  Run Keyword And Return Status  admin.Assert
    ...  ${class}
    ...  ${dist_name}
    ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed"
    ...  timeout=${timeout}
    ...  connection=${bts_id}
    ...  ELSE  Run Keyword And Return Status  admin.Assert
    ...  ${class}
    ...  ${dist_name}
    ...  operationalState=regex"(?i)Enabled"
    ...  timeout=${timeout}
    ...  connection=${bts_id}
    Sleep  5  Wait for state stabilization
    ${ru_info}=  admin.Get Parameters For  class_name=${class}  id_num=${dist_name}  timeout=${timeout}  connection=${bts_id}
    ${ru_availability_status}=  IF  '${state}'=='Insert'
    ...  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${ru_info}  availabilityStatus
    ...  ELSE
    ...  Set Variable  ${TRUE}
    IF  ${status_1} and ${ru_availability_status}
    ...  Logging With Timestamp
    ...  message=Radio ${dist_name} state check after power ${state} succeeded.
    ...  style=DONE
    ...  ELSE
    ...  Run Keyword And Continue on Failure  Fail  Radio ${dist_name} state check after power ${state} failed
    ${time_stamp}=  IF  ${status_1} and ${ru_availability_status}
    ...  Get Current Date  UTC
    ...  ELSE  Set Variable  {0}
    [Return]  ${time_stamp}

SITE Verify RU Power Remove Insert State For Chain RUs
    [Arguments]  ${bts_id}  ${ru_sn}  ${state}  ${timeout}
    [Documentation]  Keyword verifies affected radios in chain that are placed behind tested one.
    ...  KW moved from robotlte_legacy: "Verify RU Power Remove Insert State For Affected RUs"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id belongs to ru                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                  | Yes  | radio serial number                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | state                  | Yes  | possible: Remove / Insert                                          |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | verification timeout                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    FOR  ${chain_ru_sn}  IN  @{CFG['RF_INFO']['${ru_sn}']['scf_chain_fr_affected_list']}
      ${ru_id_dist_name}=  Get From Dictionary  ${CFG['RF_INFO']['${ru_sn}']}  scf_dist_name_primary
      ${asirmod_status}=  Run Keyword And Return Status  Should Match Regexp  ${ru_id_dist_name}  ASIRMOD
      ${class}=  Set Variable If  ${asirmod_status}  ASIRMOD  RMOD
      ${bts_id}  ${ru_id_dist_name}=  SITE Get RU Node Data  ${chain_ru_sn}
      ${status_1}=  IF  "${state}" == "Remove"
      ...  Run Keyword And Return Status  admin.Assert
      ...  ${class}
      ...  ${ru_id_dist_name}
      ...  operationalState=regex"(?i)Disabled", availabilityStatus=regex"(?i)off\\s?line|not\\s?installed"
      ...  timeout=${timeout}
      ...  connection=${bts_id}
      ...  ELSE  Run Keyword And Return Status  admin.Assert
      ...  ${class}
      ...  ${ru_id_dist_name}
      ...  operationalState=regex"(?i)Enabled"
      ...  timeout=${timeout}
      ...  connection=${bts_id}
      Sleep  5  Wait for state stabilization
      ${ru_info}=  admin.Get Parameters For  class_name=${class}  id_num=${ru_id_dist_name}  timeout=${timeout}  connection=${bts_id}
      ${ru_availability_status}=  IF  '${state}'=='Insert'
      ...  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${ru_info}  availabilityStatus
      ...  ELSE
      ...  Set Variable  ${TRUE}
      IF  ${status_1} and ${ru_availability_status}
      ...  Logging With Timestamp
      ...  message=Chain radio ${ru_sn} state check after power ${state} succeeded.
      ...  style=DONE
      ...  ELSE
      ...  Run Keyword And Continue On Failure  Fail  Chain radio ${ru_sn} has wrong states when power ${state}
    END

SITE Verify RU Power Remove Insert Cells State
    [Arguments]  ${bts_id}  ${ru_sn}  ${state}  ${timeout}
    [Documentation]  Keyword verifies affected / not affected cells while power on/off radio.
    ...  KW moved from robotlte_legacy: "Verify RU Power Remove Insert Cells State"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id belongs to ru                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                  | Yes  | radio serial number                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | state                  | Yes  | possible: Remove / Insert                                          |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | verification timeout                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    Logging With Timestamp
    ...  message=Radio ${ru_sn} related cells state check admin procedure started
    ${ru_cell_dict}=  SITE Create Affected Cells List RF Hot Remove Insert  ${ru_sn}
    SITE Verify RU Affected Cells  ${bts_id}  ${ru_cell_dict}  ${state}  ${timeout}
    SITE Verify RU Not Affected Cells  ${bts_id}  ${ru_cell_dict}  ${timeout}

SITE Create Affected Cells List RF Hot Remove Insert
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword prepares affected cells list for radio.
    ...  KW moved from robotlte_legacy: "Create Affected Cell List RF Hot Remove Insert"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | Serial number of RU                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Return:
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...  | Return Value             | Description                                                             |
    ...  +==========================+=========================================================================+
    ...  | ru_cell_affected_dict    | cells sorted in dictionary by technology                                |
    ...  +--------------------------+-------------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${gncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  scf_cellid_primary
    ${wncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  scf_cellid_primary
    ${lncell_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  scf_cellid_primary
    ${nrcelid_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  scf_cellid_primary
    ${ru_cell_list}=  Create List
    IF  "${gncell_list}" != "None"  Append To List  ${ru_cell_list}  @{gncell_list}
    IF  "${wncell_list}" != "None"  Append To List  ${ru_cell_list}  @{wncell_list}
    IF  "${lncell_list}" != "None"  Append To List  ${ru_cell_list}  @{lncell_list}
    IF  "${nrcelid_list}" != "None"  Append To List  ${ru_cell_list}  @{nrcelid_list}
    ${fr_affected_list}=  Create List  @{cfg.RF_INFO['${ru_sn}']['scf_chain_fr_affected_list']}
    FOR  ${ru_id}  IN  @{fr_affected_list}
      ${gncell_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['GNCEL']}  scf_cellid_primary
      ${wncell_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['WNCEL']}  scf_cellid_primary
      ${lncell_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['LNCEL']}  scf_cellid_primary
      ${nrcelid_list_id}=  Get From Dictionary  ${cfg.RF_INFO['${ru_id}']['NRCEL']}  scf_cellid_primary
      ${ru_cell_list_id}=  Create List
      IF  "${gncell_list_id}" != "None"  Append To List  ${gncell_list}  @{gncell_list_id}
      IF  "${wncell_list_id}" != "None"  Append To List  ${wncell_list}  @{wncell_list_id}
      IF  "${lncell_list_id}" != "None"  Append To List  ${lncell_list}  @{lncell_list_id}
      IF  "${nrcelid_list_id}" != "None"  Append To List  ${nrcelid_list}  @{nrcelid_list_id}
    END
    ${gncell_list}=  Run Keyword If  "${gncell_list}" != "None"  Remove Duplicates  ${gncell_list}
    ${wncell_list}=  Run Keyword If  "${wncell_list}" != "None"  Remove Duplicates  ${wncell_list}
    ${lncell_list}=  Run Keyword If  "${lncell_list}" != "None"  Remove Duplicates  ${lncell_list}
    ${nrcelid_list}=  Run Keyword If  "${nrcelid_list}" != "None"  Remove Duplicates  ${nrcelid_list}
    ${ru_cell_affected_dict}=  Create Dictionary  gncelid=${gncell_list}
    ...  wncelid=${wncell_list}
    ...  lncelid=${lncell_list}
    ...  nrcelid=${nrcelid_list}
    [Return]  ${ru_cell_affected_dict}

SITE Verify RU Affected Cells
    [Arguments]  ${bts_id}  ${ru_cell_affected_dict}  ${state}  ${timeout}
    [Documentation]  Keyword verifies affected cells while power on/off radio.
    ...  KW moved from robotlte_legacy: "Verify RU Affected Cells"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id belongs to ru                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ru_cell_affected_dict  | Yes  | dict from KW 'Create Affected Cell List RF Hot Remove Insert'      |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | state                  | Yes  | possible: Remove / Insert /Block / Unblocked / Locked / Unlocked   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | verification timeout                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${gncell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  gncelid
    ${wncell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  wncelid
    ${lncell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  lncelid
    ${nrcell_list_ru_affected}=  Get From Dictionary  ${ru_cell_affected_dict}  nrcelid
    ${gncell_list_ru_affected}=  IF  ${gncell_list_ru_affected}==None
    ...  Create List  @{EMPTY}
    ...  ELSE  Set Variable  ${gncell_list_ru_affected}
    ${wncell_list_ru_affected}=  IF  ${wncell_list_ru_affected}==None
    ...  Create List  @{EMPTY}
    ...  ELSE  Set Variable  ${wncell_list_ru_affected}
    ${lncell_list_ru_affected}=  IF  ${lncell_list_ru_affected}==None
    ...  Create List  @{EMPTY}
    ...  ELSE  Set Variable  ${lncell_list_ru_affected}
    ${nrcell_list_ru_affected}=  IF  ${nrcell_list_ru_affected}==None
    ...  Create List  @{EMPTY}
    ...  ELSE  Set Variable  ${nrcell_list_ru_affected}
    FOR  ${cell_id}  IN  @{gncell_list_ru_affected}
      SITE Verify RU Cell  ${bts_id}  ${cell_id}  ${state}  GNCEL  ${timeout}
    END
    FOR  ${cell_id}  IN  @{wncell_list_ru_affected}
      SITE Verify RU Cell  ${bts_id}  ${cell_id}  ${state}  WNCEL  ${timeout}
    END
    FOR  ${cell_id}  IN  @{lncell_list_ru_affected}
      SITE Verify RU Cell  ${bts_id}  ${cell_id}  ${state}  LNCEL  ${timeout}
    END
    FOR  ${cell_id}  IN  @{nrcell_list_ru_affected}
      SITE Verify RU Cell  ${bts_id}  ${cell_id}  ${state}  NRCEL  ${timeout}
    END

SITE Verify RU Cell
    [Arguments]  ${bts_id}  ${cell}  ${state}  ${technology}  ${timeout}
    [Documentation]  Keyword verifies directly particular cells' states while power on/off radio.
    ...  KW moved from robotlte_legacy: "Verify RU Cell"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id belongs to ru                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | cell                   | Yes  | dict from KW 'Create Affected Cell List RF Hot Remove Insert'      |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | state                  | Yes  | possible: Remove / Insert /Block / Unblocked / Locked / Unlocked   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | technology             | Yes  | NRCEL/LNCEL/WNCEL/GNCEL                                            |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | verification timeout                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${rat_type}=  Set Variable If  '${technology}' == 'LNCEL'  LTE
    ...  '${technology}' == 'GNCEL'  GSM
    ...  '${technology}' == 'WNCEL'  WCDMA
    ...  '${technology}' == 'NRCEL'  NR
    ${cell_id}=  admin.Get Cell Id By Configuration Id  ${rat_type}  ${cell}  ${timeout}  connection=${bts_id}
    ${cell_is_shared}=  Get From Dictionary  ${CFG['NODES']['${bts_id}']['${technology}']['${cell}']}  scf_cell_2T2R_shared
    ${action_state}=  Set Variable If
    ...  ("${state}" == "Blocked" or "${state}" == "Locked" or "${state}" == "Remove")
    ...  Disable
    ...  Enable
    ${operational_state}=  Set Variable If  "${action_state}" == "Disable" and not ${cell_is_shared}
    ...  regex"(?i)Disabled"
    ...  regex"(?i)Enabled"
    ${availablity_status}=  Set Variable If  "${action_state}" == "Disable"
    ...  regex"(?i)degraded|dependency|failed|off\\s?line"
    ...  ${null}
    ${procedural_state}=  Set Variable If  "${state}" == "Blocked"  regex"(?i)Validated"  regex"(?i)OnAirDone"
    Logging With Timestamp
    ...  message=Cell "${cell}" State on node = "${bts_id}" Check Admin procedure started
    ${parameters}=  Set Variable If  ("${state}" == "Blocked" or "${state}" == "Locked" or "${state}" == "Remove")
    ...  availabilityStatus=${availablity_status}
    ...  operationalState=${operational_state}
    ${status_1}=  Run Keyword And Continue On Failure  Run Keyword And Continue On Failure  admin.Assert
    ...  ${technology}
    ...  ${cell_id}
    ...  parameters=${parameters}
    ...  timeout=${timeout}
    ...  connection=${bts_id}
    ${availabilityStatus}=  IF  "${action_state}" == "Enable"
    ...  Run Keyword And Continue On Failure  admin.Assert No
    ...  class_name=${technology}
    ...  parameters=availabilityStatus=regex"(?i)degraded|dependency|failed|off\\s?line|None", id=${cell_id}
    ...  search_for_iot_cells=${True}
    ...  timeout=${timeout}
    ...  connection=${bts_id}
    ...  ELSE
    ...  Set Variable  ${TRUE}
    IF  ${status_1} and ${availabilityStatus}
    ...  Logging With Timestamp
    ...  message=Cell "${cell}" state check on node = "${bts_id}" when power ${state} succeeded.
    ...  style=DONE
    ...  ELSE  Run Keywords
    ...  Logging With Timestamp
    ...  message=Cell "${cell}" state check on node = "${bts_id}" has wrong states when power ${state}
    ...  style=ERROR
    ...  AND
    ...  Run Keyword And Continue On Failure  Fail  Cell "${cell}" state check on node = "${bts_id}" has wrong states when power ${state}

SITE Verify RU Not Affected Cells
    [Arguments]  ${bts_id}  ${ru_cell_affected_dict}  ${timeout}
    [Documentation]  Keyword verifies not affected cells while power on/off radio.
    ...  KW moved from robotlte_legacy: "Verify RU Not Affected Cells"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id belongs to ru                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ru_cell_affected_dict  | Yes  | dict from KW 'Create Affected Cell List RF Hot Remove Insert'      |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | verification timeout                                               |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${not_affected_gncell_list}=  Create List
    ${not_affected_wncell_list}=  Create List
    ${not_affected_lncell_list}=  Create List
    ${not_affected_nrcell_list}=  Create List
    ${gncell_tmp_list}=  Get Dictionary Keys  ${CFG['NODES']['${bts_id}']['GNCEL']}
    ${wncell_tmp_list}=  Get Dictionary Keys  ${CFG['NODES']['${bts_id}']['WNCEL']}
    ${lncell_tmp_list}=  Get Dictionary Keys  ${CFG['NODES']['${bts_id}']['LNCEL']}
    ${nrcell_tmp_list}=  Get Dictionary Keys  ${CFG['NODES']['${bts_id}']['NRCEL']}
    Append To List  ${not_affected_gncell_list}  @{gncell_tmp_list}
    Append To List  ${not_affected_wncell_list}  @{wncell_tmp_list}
    Append To List  ${not_affected_lncell_list}  @{lncell_tmp_list}
    Append To List  ${not_affected_nrcell_list}  @{nrcell_tmp_list}
    Run Keyword If  ${ru_cell_affected_dict['gncelid']}!=None
    ...  Remove Values From List  ${not_affected_gncell_list}  @{ru_cell_affected_dict['gncelid']}
    Run Keyword If  ${ru_cell_affected_dict['wncelid']}!=None
    ...  Remove Values From List  ${not_affected_wncell_list}  @{ru_cell_affected_dict['wncelid']}
    Run Keyword If  ${ru_cell_affected_dict['lncelid']}!=None
    ...  Remove Values From List  ${not_affected_lncell_list}  @{ru_cell_affected_dict['lncelid']}
    Run Keyword If  ${ru_cell_affected_dict['nrcelid']}!=None
    ...  Remove Values From List  ${not_affected_nrcell_list}  @{ru_cell_affected_dict['nrcelid']}
    ${not_affected_ru_cell_dict}=  Create Dictionary
    ...  gncelid=${not_affected_gncell_list}
    ...  wncelid=${not_affected_wncell_list}
    ...  lncelid=${not_affected_lncell_list}
    ...  nrcelid=${not_affected_nrcell_list}
    SITE Verify RU Affected Cells  ${bts_id}  ${not_affected_ru_cell_dict}  Unblocked  ${timeout}

SITE Verify RU Power Remove Insert Alarms
    [Arguments]  ${bts_id}  ${ru_sn}  ${state}  ${timeout}  ${gasp_alarm}=${FALSE}
    [Timeout]  360 sec
    [Documentation]  Universal KW for checking faults when power on/off
    ...  KW moved from robotlte_legacy: "Verify RU Power Remove Insert Alarms"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | radio serial number                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn                  | Yes  | radio serial number                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | state                  | Yes  | possible: Remove / Insert /Block / Unblocked / Locked / Unlocked   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | timeout                | Yes  | timeout for procedure                                              |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | gasp_alarm             | No   | user switch to activate or not additional FID 10 attributes        |
    ...  |                        |      | default value ${FALSE}                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  | **Author:** piotr.korczynski@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    FM Preconditions For CNI-127210
    ${release}  admin.Get Sw Release Name  connection=${bts_id}
    ${proper_sw}  Run Keyword If  "${release}"=="SBTS24R3" and ${PRECOND_FOR_CNI}
    ...  SWM Check If Current SW Build Is Newer Than  SBTS24R3_ENB_0000_000602_000000  bts_id=${bts_id}
    ...  ELSE IF  ${PRECOND_FOR_CNI}
    ...  SWM Check If Current SW Build Is Newer Than  SBTS25R1_ENB_9999_240929_000023  bts_id=${bts_id}
    Run keyword If   ${proper_sw}  Set Test Variable  ${PRECOND_FOR_CNI}  False
    ${ru_cell_dict}=  SITE Create Affected Cells List RF Hot Remove Insert  ${ru_sn}
    ${gncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['GNCEL']}  scf_cellid_primary
    ${affected_gncell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  gncelid
    ${gncell_ru_sn_list}=  IF  "${affected_gncell_ru_sn_list}" != "None"
    ...  Combine Lists  ${gncell_ru_sn_list}  ${affected_gncell_ru_sn_list}
    Run Keyword And Ignore Error  Remove Duplicates  ${gncell_ru_sn_list}
    ${gncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${bts_id}']['GNCEL']}
    ${gncell_faulty_cell}=  Set Variable If  ${gncell_all_ru_list}==${gncell_ru_sn_list}  all
    ...  "None"=="${gncell_ru_sn_list}"  None
    ...  ${gncell_ru_sn_list}
    ${wncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['WNCEL']}  scf_cellid_primary
    ${affected_wncell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  wncelid
    ${wncell_ru_sn_list}=  IF  "${affected_wncell_ru_sn_list}" != "None"
    ...  Combine Lists  ${affected_wncell_ru_sn_list}  ${wncell_ru_sn_list}
    Run Keyword And Ignore Error  Remove Duplicates  ${wncell_ru_sn_list}
    ${wncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${bts_id}']['WNCEL']}
    ${wncell_faulty_cell}=  Set Variable If  ${wncell_all_ru_list}==${wncell_ru_sn_list}  all
    ...  "None"=="${wncell_ru_sn_list}"  None
    ...  ${wncell_ru_sn_list}
    ${lncell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['LNCEL']}  scf_cellid_primary
    ${affected_lncell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  lncelid
    ${lncell_ru_sn_list}=  IF  "${affected_lncell_ru_sn_list}" != "None"
    ...  Combine Lists  ${lncell_ru_sn_list}  ${affected_lncell_ru_sn_list}
    Run Keyword And Ignore Error  Remove Duplicates  ${lncell_ru_sn_list}
    ${lncell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${bts_id}']['LNCEL']}
    ${lncell_faulty_cell}=  Set Variable If  ${lncell_all_ru_list}==${lncell_ru_sn_list}  all
    ...  "None"=="${lncell_ru_sn_list}"  None
    ...  ${lncell_ru_sn_list}
    ${nrcell_ru_sn_list}=  Get From Dictionary  ${cfg.RF_INFO['${ru_sn}']['NRCEL']}  scf_cellid_primary
    ${affected_nrcell_ru_sn_list}=  Get From Dictionary  ${ru_cell_dict}  nrcelid
    ${nrcell_ru_sn_list}=  IF  "${affected_nrcell_ru_sn_list}" != "None"
    ...  Combine Lists  ${nrcell_ru_sn_list}  ${affected_nrcell_ru_sn_list}
    Run Keyword And Ignore Error  Remove Duplicates  ${nrcell_ru_sn_list}
    ${nrcell_all_ru_list}=  Get Dictionary Keys  ${cfg.NODES['${bts_id}']['NRCEL']}
    ${nrcell_faulty_cell}=  Set Variable If  ${nrcell_all_ru_list}==${nrcell_ru_sn_list}  all
    ...  "None"=="${nrcell_ru_sn_list}"  None
    ...  ${nrcell_ru_sn_list}
    ${alarm_attribute_value_gsm}=  IF  "${gncell_faulty_cell}" != "None"
    ...  Catenate  GSM:  ${gncell_faulty_cell}
    ${alarm_attribute_value_lte}=  IF  "${wncell_faulty_cell}" != "None"
    ...  Catenate  WCDMA:  ${wncell_faulty_cell}
    ${alarm_attribute_value_wcdma}=  IF  "${lncell_faulty_cell}" != "None"
    ...  Catenate  LTE:  ${lncell_faulty_cell}
    ${alarm_attribute_value_5G}=  IF  "${nrcell_faulty_cell}" != "None"
    ...  Catenate  NR:  ${nrcell_faulty_cell}
    ${alarm_attribute_value_all}=  Catenate
    ...  SEPARATOR=;
    ...  ${alarm_attribute_value_gsm}
    ...  ${alarm_attribute_value_lte}
    ...  ${alarm_attribute_value_wcdma}
    ...  ${alarm_attribute_value_5G}
    ${object_1}=  Evaluate  "${gncell_faulty_cell}" == "None" and "${wncell_faulty_cell}" == "None"
    ${object_2}=  Evaluate  "${lncell_faulty_cell}" == "None" and "${nrcell_faulty_cell}" == "None"
    ${alarm_severity}=  Evaluate  ${object_1} and ${object_2}
    ${lncell_is_shared}=  Run Keyword If  "${lncell_ru_sn_list}" != "None"  SITE Check Affected Cells Sharing Status
    ...  ${bts_id}
    ...  ${lncell_ru_sn_list}
    ...  LNCEL
    ${nrcell_is_shared}=  Run Keyword If  "${nrcell_ru_sn_list}" != "None"  SITE Check Affected Cells Sharing Status
    ...  ${bts_id}
    ...  ${nrcell_ru_sn_list}
    ...  NRCEL
    ${cell_is_shared}=  Set Variable If  ${lncell_is_shared}  True
    ...  ${nrcell_is_shared}  True
    ...  False
    ${alarm_severity}=  Set Variable If
    ...  ${alarm_severity}  Minor
    ...  ${cell_is_shared}  Major
    ...  Critical
    ${has_chain_rf_child}=  Evaluate  len(@{CFG["RF_INFO"]["${ru_sn}"]["scf_chain_fr_affected_list"]}) > 0
    ${4003_lte_alarm_list}=    Run Keyword If    ${lncell_is_shared} and not ${has_chain_rf_child} and not ${PRECOND_FOR_CNI}
    ...    SITE Create Alarm 4003 List    ${bts_id}    ${lncell_ru_sn_list}     LTE
    ${4003_nr_alarm_list}=    Run Keyword If    ${nrcell_is_shared} and not ${has_chain_rf_child} and not ${PRECOND_FOR_CNI}
    ...    SITE Create Alarm 4003 List    ${bts_id}    ${nrcell_ru_sn_list}     NR
    ${fault_10_dyingGaspAlarm}=    Create List
    ...  faultId=10, severity=${alarm_severity}, serialNo=${ru_sn}, supplAlarmInfo=regex"RU connection was lost.*RU power loss"
    ${fault_10_standard}=    Create List
    ...  faultId=10, severity=${alarm_severity}, serialNo=${ru_sn}
    ${fault_1972}=  Create List    faultId=1972, severity=Warning
    ${chain_alarm_list}=  IF  ${has_chain_rf_child}  SITE Prepare FID 10 List For Chaining  ${ru_sn}  ELSE  Create List
    ${is_1972_expected}=  SITE Check If Fault 1972 Expected  ${ru_sn}
    ${alarm_list}=  IF  ${gasp_alarm}
    ...  Combine Lists  ${fault_10_dyingGaspAlarm}  ${chain_alarm_list}
    ...  ELSE IF  ${is_1972_expected}
    ...  Combine Lists  ${fault_10_standard}  ${fault_1972}  ${chain_alarm_list}
    ...  ELSE
    ...  Combine Lists  ${fault_10_standard}  ${chain_alarm_list}
    ${alarm_list}=    IF   ${lncell_is_shared} and not ${PRECOND_FOR_CNI}
    ...  Collections.Combine Lists   ${4003_lte_alarm_list}  ${alarm_list}
    ...  ELSE  Set Variable  ${alarm_list}
    ${alarm_list}=  IF  ${nrcell_is_shared} and not ${has_chain_rf_child} and not ${PRECOND_FOR_CNI}
    ...  Collections.Combine Lists   ${4003_nr_alarm_list}  ${alarm_list}
    ...  ELSE    Set Variable    ${alarm_list}
    Sleep  30  Wait for R&D faults
    IF  ${gasp_alarm} and '${state}' == 'Remove'  FM Check Active Fault In IMS For RD Fault
    ...  bts_id=${bts_id}
    ...  fault_id=4774
    ...  severity=${NONE}
    ...  find_rd_fault=${TRUE}
    IF  ${gasp_alarm} and '${state}' == 'Insert'  FM Check Removed Active Fault In IMS For RD Fault
    ...  bts_id=${bts_id}
    ...  find_rd_fault=${TRUE}
    IF  '${state}'=='Remove' and not ${CFG['RF_INFO']['${ru_sn}']['scf_rfsharing']}
      Run Keyword And Continue On Failure  FM Check Mandatory Alarm Active List
      ...  prim_bts_id=${bts_id}
      ...  prim_fault_list=${alarm_list}
      ...  timeout=${timeout}
    ELSE IF  '${state}'=='Remove' and ${CFG['RF_INFO']['${ru_sn}']['scf_rfsharing']}
      Run Keyword And Continue On Failure  FM Check Mandatory Alarm Active List
      ...  prim_bts_id=${bts_id}
      ...  prim_fault_list=${alarm_list}
      ...  timeout=${timeout}
      ...  sec_bts_id=${CFG['RF_INFO']['${ru_sn}']['scf_btsid_secondary'][0]}
      ...  sec_fault_list=${fault_10_standard}
    ELSE IF  '${state}'=='Insert' and not ${CFG['RF_INFO']['${ru_sn}']['scf_rfsharing']}
      Run Keyword And Continue On Failure  FM Check Mandatory Alarm InActive List  prim_bts_id=${bts_id}  timeout=${timeout}
    ELSE IF  '${state}'=='Insert' and ${CFG['RF_INFO']['${ru_sn}']['scf_rfsharing']}
      Run Keyword And Continue On Failure  FM Check Mandatory Alarm InActive List
      ...  prim_bts_id=${bts_id}
      ...  timeout=${timeout}
      ...  sec_bts_id=${CFG['RF_INFO']['${ru_sn}']['scf_btsid_secondary'][0]}
    END
    ${alarm_unexpected_status}=  Run Keyword And Continue On Failure
    ...  Wait Until Keyword Succeeds  30 sec  5 sec  admin.Assert No Unexpected Active Alarms  connection=${bts_id}
    Run Keyword If  "${alarm_unexpected_status}" == "${EMPTY}"
    ...  Logging With Timestamp
    ...  message=List of unexpected faults detected:${\n}${alarm_unexpected_status}
    ...  style=FAIL
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=No unexpected faults detected
    FM Check For Alarm 4589 On All Nodes  ru_sn=${ru_sn}
    Run Keyword And Continue On Failure  FM Check For Fault 1815 On All Nodes  ru_sn=${ru_sn}
    ${fault_history_status}=  Run Keyword And Continue On Failure  admin.Assert No Unexpected Historical Alarms  connection=${bts_id}
    Run Keyword If  "${fault_history_status}" == "${EMPTY}"
    ...  Logging With Timestamp
    ...  message=List of historical faults detected:${\n}${fault_history_status}
    ...  style=FAIL
    ...  ELSE
    ...  Logging With Timestamp
    ...  message=No unexpected faults detected

SITE Prepare FID 10 List For Chaining
    [Arguments]  ${ru_sn}
    [Documentation]  Keyword prepares FID 10 attributes for affected radios in chain
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | ru_sn                  | Yes  | radio serial number                                                |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | chain_alarm_list   | list of fault attributes                                                      |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${chain_alarm_list}=  Create List
    FOR  ${chain_ru}  IN  @{CFG['RF_INFO']['${ru_sn}']['scf_chain_fr_affected_list']}
      Append To List  ${chain_alarm_list}  faultId=10, serialNo=${chain_ru}
    END
    [Return]  ${chain_alarm_list}

SITE Check If 24R3 Build Is Proper For CNI-127210
    [Arguments]    ${build}    ${bts_id}=default
    [Documentation]
    ...  KW checks if given 24R3 build is valid for CNI-127210
    ...  Builds SBTS24R3_ENB_0000_000425_0000XX are TMO branch
    ...  Starting from build SBTS24R3_ENB_0000_000425_0000XX CNI-127210 was reverted
    ...  Starting from build SBTS24R3_ENB_0000_000241_000000 CNI-127210 was implemented
    ...  KW moved from robotlte_legacy: "Check If 24R3 Build Is Proper For CNI-127210"
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | build                  | Yes  | package name                                                       |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | bts_id                 | No   | alias as bts_id                                                    |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | verdict            | verdict for CNI                                                               |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | **Author:** anna.maciejewska@nokia.com
    ...  | **Maintainer:** anna.maciejewska@nokia.com

    ${current_sw}  SWM Get SW Build Release  Active  only_release=False  bts_id=${bts_id}
    ${current_sw}  Get Regexp Matches  ${current_sw}  \\d+
    ${curr}    Evaluate    [int(number) for number in ${current_sw}]
    ${arg_sw_number}    Get Regexp Matches  ${build}  \\d+
    ${arg}    Evaluate    [int(number) for number in ${arg_sw_number}]
    Return From Keyword If  ${curr}[3]>=425 and ${curr}[4]>=74   ${FALSE}
    ${verdict}    Set Variable If
    ...    ${curr}[0]>=${arg}[0] and ${curr}[1]>=${arg}[1] and ${curr}[3]>=${arg}[3]
    ...    ${TRUE}
    ...    ${FALSE}
    IF  not ${verdict}
    ...  Return From Keyword  ${verdict}
    ...  ELSE
    ...  Return From Keyword If  ${curr}[3]!=${arg}[3]  ${verdict}
    ${verdict}  Set Variable If  ${curr}[4]>${arg}[4]  ${TRUE}  ${FALSE}
    [Return]    ${verdict}

SITE Check Affected Cells Sharing Status
    [Arguments]  ${bts_id}  ${cell_ru_sn_list}  ${cell_type}
    [Documentation]  Keyword verifies if radio has splitted cells
    ...  KW moved from robotlte_legacy: "Check Affected Cells Sharing Status"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts_id                                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | cell_ru_sn_list        | Yes  | cell ids on radio                                                  |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | cell_type              | Yes  | cell technology                                                    |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | cell_is_shared     | if radio has splitted cell output is TRUE                                     |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...
    ...  Author:      piotr.korczynski@nokia.com
    ...  Maintainer:  daniel.bartkowiak@nokia.com

    ${share_type}=  Set Variable If  '${cell_type}'=='LNCEL'  scf_cell_2T2R_shared  scf_cell_ru_shared
    ${cell_ru_sn_list}=  SITE Convert Item To Single Element List  ${cell_ru_sn_list}
    ${cell_ru_sn_list}=  Remove Duplicates  ${cell_ru_sn_list}
    FOR  ${cell_id}  IN  @{cell_ru_sn_list}
      ${cell_is_shared}=  Get From Dictionary  ${CFG['NODES']['${bts_id}']['${cell_type}']['${cell_id}']}  ${share_type}
      Exit For Loop If  ${cell_is_shared}
    END
    [Return]  ${cell_is_shared}

SITE Convert Item To Single Element List
    [Arguments]  ${item}
    [Documentation]  If input is a list, keyword will not do anything. If not a list, it returns list with one element.
    ...  KW moved from robotlte_legacy: "Convert Item To Single Element List"
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | item                   | Yes  | item to convert                                                    |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  Author:      michal.szajkowski@nokia.com
    ...  Maintainer:  daniel.bartkowiak@nokia.com

    ${input_type}=  Evaluate  type($item).__name__
    ${output}=  Run Keyword If  "${input_type}"!="list"  Create List  ${item}
    ...         ELSE  Set Variable  ${item}
    [Return]  ${output}

SITE Create Alarm 4003 List
    [Arguments]  ${bts_id}  ${ru_sn_list}  ${cell_type}
    [Documentation]
    ...  KW creates list with fault 4003 attributes for further usage
    ...  KW moved from robotlte_legacy: "Create Alarm 4003 List"
    ...
    ...  Arguments:
    ...  +========================+======+====================================================================+
    ...  | Argument               | Man. | Description                                                        |
    ...  +========================+======+====================================================================+
    ...  | bts_id                 | Yes  | bts id                                                             |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | ru_sn_list             | Yes  | list cells from radio                                              |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...  | cell_type              | Yes   | cell technology                                                   |
    ...  +------------------------+------+--------------------------------------------------------------------+
    ...
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...  | Return Value       | Description                                                                   |
    ...  +====================+===============================================================================+
    ...  | alarm_list         | list of fault attributes for further usage                                    |
    ...  +--------------------+-------------------------------------------------------------------------------+
    ...
    ...  | **Author:** daniel.bartkowiak@nokia.com
    ...  | **Maintainer:** daniel.bartkowiak@nokia.com

    ${ru_sn_list}=  SITE Convert Item To Single Element List  ${ru_sn_list}
    ${ru_sn_list}=  Remove Duplicates  ${ru_sn_list}
    ${alarm_list}=  Create List
    FOR  ${cell_id}  IN  @{ru_sn_list}
      ${cell_id}=  admin.Get Cell Id By Configuration Id  ${cell_type}  ${cell_id}  30  connection=${bts_id}
      Append To List  ${alarm_list}  faultId=4003, impactedCellsList[0]=${cell_id}
    END
    [Return]  ${alarm_list}

SITE Format Timestamp To Epoch
    [Arguments]  ${timestamp_to_format}
    [Documentation]
    ...  Converts timestamp in format as recived in historical alarm json list to epoch time adjusted to UTC
    ...
    ...  KW moved from robotlte_legacy: "Create Alarm 4003 List"
    ...  +----------------------+------+-------------------------------------+
    ...  | Parameter            | Man. | Description                         |
    ...  +======================+======+=====================================+
    ...  | timestamp_to_format  | Yes  | timestamp to be formated            |
    ...  +----------------------+------+-------------------------------------+
    ...
    ...  **Return parameters**
    ...
    ...  +---------------------+-------------------------------------------+
    ...  | Parameter           | Description                               |
    ...  +=====================+===========================================+
    ...  | timestamp_in_epoch  | input timestamp formated to epoch in UTC  |
    ...  +---------------------+-------------------------------------------+
    ...
    ...  |  **Author:**  dawid.bak@nokia.com
    ...  |  **Maintainer:**  dawid.bak@nokia.com

    ${timestamp}=  Get Substring  string=${timestamp_to_format}  start=0  end=-5
    ${timezone}=  Get Substring  string=${timestamp_to_format}  start=-5
    ${timezone_sign}=  Get Substring  string=${timezone}  start=0  end=1
    ${timezone_hours}=  Get Substring  string=${timezone}  start=1  end=3
    ${timezone_hours}=  Set Variable  ${timezone_sign}${timezone_hours}
    ${timezone_hours}=  Convert To Integer  item=${timezone_hours}  base=10
    ${timezone_minutes}=  Get Substring  string=${timezone}  start=-2
    ${timezone_minutes}=  Set Variable  ${timezone_sign}${timezone_minutes}
    ${timezone_minutes}=  Convert To Integer  item=${timezone_minutes}  base=10
    ${timestamp_in_epoch}=  Convert Date  date=${timestamp}  date_format=%Y%m%d%H%M%S.%f  result_format=epoch
    ${timestamp_in_epoch}=  Evaluate  ${timestamp_in_epoch}-(3600*${timezone_hours})-(60*${timezone_minutes})
    [Return]  ${timestamp_in_epoch}
