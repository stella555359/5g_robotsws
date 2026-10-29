*** Keywords ***
Check Precondition Parameters For PSGRP Tests
    [Arguments]  ${bts_id}  ${bbmod_dns}  ${bbmod_internal_dns}  ${node_cells_dict}  ${bbmod_cell_mapping}
    [Documentation]
    ...  Description:
    ...  Check initial parameters required for the CB013164 PSGRP tests.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_dns              | Yes  | List of baseband module distNames                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_internal_dns     | Yes  | List of internal baseband module distNames                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | node_cells_dict        | Yes  | Dictionary of cells grouped by node                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_cell_mapping     | Yes  | Dictionary mapping baseband modules to their cells                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    FOR  ${bbmod_dn}  IN  @{bbmod_dns}
      &{bbmod_dict}=  Create Dictionary
      #01
      Get Dictionary From Distname And Compare Value
      ...  dist_name=${bbmod_dn}
      ...  key=useFullCapacity
      ...  value=True
      ...  bts_id=${bts_id}
      #02
      Get Dictionary From Distname And Compare Value
      ...  dist_name=${bbmod_dn}
      ...  key=bbCardUsage
      ...  value=2
      ...  bts_id=${bts_id}
    END

    FOR  ${abia_internal_dn}  IN  @{bbmod_internal_dns}
      FOR  ${lte_cell}  IN  @{bbmod_cell_mapping['${abia_internal_dn}']}
        ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name
        ...  ${lte_cell}  ${node_cells_dict}   #from variables_preparation.robot
        #03
        Get Dictionary From Distname And Compare Value
        ...  dist_name=MRBTS-${BTS_ID}/LNBTS-${BTS_ID}/LNCEL-${global_cell_id}/BBPOOLALLOC-0
        ...  key=bbPoolAllocMode
        ...  value=automatic
        ...  bts_id=${bts_id}
        #05
        Get Dictionary From Distname And Compare Value
        ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${global_cell_id}
        ...  key=actOtdoa
        ...  value=False
        ...  bts_id=${bts_id}
      END
    END
    #04
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  key=actCoMp
    ...  value=disabled
    ...  bts_id=${bts_id}
    #06
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  key=actMBMSPS
    ...  value=False
    ...  bts_id=${bts_id}
    #07
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/LNBTS_FDD-0
    ...  key=actPubSafetyBearers
    ...  value=False
    ...  bts_id=${bts_id}
    #08
    ${lnbts_parameters}=  Get Parameter By Distname
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  connection=${bts_id}
    ${bbPoolAllocPrioList}  Run Keyword And Return Status  Get From Dictionary  ${lnbts_parameters[0]['parameters']}  bbPoolAllocPrioList
    IF  '${bbPoolAllocPrioList}' != 'False'
        Fail  msg=bbPoolAllocPrioList is not empty
    END
    #09
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  key=actLBPowerSaving
    ...  value=True
    ...  bts_id=${bts_id}
    #11
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1
    ...  key=actLBBbPowerSaving
    ...  value=True
    ...  bts_id=${bts_id}

Get Dictionary From Distname And Compare Value
    [Arguments]  ${dist_name}  ${key}  ${value}  ${bts_id}
    [Documentation]  Get parameters from distname and compare value from key with expected value.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | dist_name              | Yes  | Dist_name from which to take the parameters                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | key                    | Yes  | Key which value is going to be compared                                    |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | value                  | Yes  | Expected value of the key                                                  |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${parameters}  admin.Get Parameter By Distname
    ...  dist_name=${dist_name}
    ...  connection=${bts_id}
    ${result}  Get From Dictionary  ${parameters[0]['parameters']}  ${key}
    IF  '${result}' != '${value}'
        Fail  msg=Expected value: ${value} but got: ${result}
    ELSE
        Log  Expected value: ${value} is equal to: ${result}
    END

Check Number Of Power Groups
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  Check how many power groups are in testline.
    ...  Keyword returns number of power groups.
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${number_of_pg}  Set Variable  0
    FOR  ${index}  IN RANGE  20
        TRY
             ${valid}  admin.Get Parameter By Distname
            ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/PSGRP-${index}
            ...  connection=${bts_id}
            IF  ${valid} == []  Break
            ${number_of_pg}  Evaluate  ${number_of_pg}+1
        EXCEPT
            Exit For Loop
        END
    END
    [Return]  ${number_of_pg}

Create PSC And NPSC lists Based On lbpsCellSOOrder
    [Arguments]  ${number_of_pg}  ${bts_id}
    [Documentation]
    ...  Description:
    ...  Create PSC and NPSC lists based on lbpsCellSOOrder (if value 100, then cell is NPSC, otherwise PSC).
    ...  Keyword return ${psc_cells_list}  ${npsc_cells_list}
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | number_of_pg           | Yes  | Number of Power Groups on testline                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${npsc_cells_list}  Create List
    ${psc_cells_list}  Create List
    FOR  ${index}  IN RANGE  ${number_of_pg}
        ${psgrp_parameters}  admin.Get Parameter By Distname
        ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/PSGRP-${index}
        ...  connection=${bts_id}
        ${lnCelId_list}  Get From Dictionary  ${psgrp_parameters[0]['parameters']}  lbpsCellList
        FOR  ${list}  IN  @{lnCelId_list}
            IF  ${list['lbpsCellSOOrder']} == 100
                Append To List  ${npsc_cells_list}  ${list['lnCelId']}
            ELSE
                Append To List  ${psc_cells_list}  ${list['lnCelId']}
            END
        END
    END
    [Return]  ${psc_cells_list}  ${npsc_cells_list}

Recovery Recommissioning For PSC And NPSC Cells
    [Arguments]  ${bts_id}
    [Documentation]
    ...  Description:
    ...  KW for recovery recommissioning for PSC and NPSC cells tests
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${delta_part1}=  Set Variable  [{"distName":"MRBTS-${bts_id}/LNBTS-${bts_id}","operation":"update","parameters":[{"parameterName":
    ${delta_part2}=  Set Variable  "bbPoolAllocPrioList","value":"","operation":"delete"}]}]
    ${delta_json}=  Set Variable  ${delta_part1}${delta_part2}
    ${delta_recomm_status}=  Run Keyword And Return Status
    ...  admin.Perform Delta Recommissioning  ${delta_json}  skip_parameter_relation_errors=True  should_activate=True  connection=${bts_id}

Get Variables For Tested BBMODs
    [Arguments]  ${bts_id}  ${bts_info}  ${abia_serial_numbers}
    [Documentation]
    ...  Description:
    ...  Get variables for tested BBMODs.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | bts_id                                                                     |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_info               | Yes  | The result of admin.Get BTS Info KW                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | abia_serial_numbers    | Yes  | List of tested ABIA serial numbers                                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Returns:
    ...  +========================+============================================================================+
    ...  | Return Value           | Description                                                                |
    ...  +========================+============================================================================+
    ...  | bbmod_dns              | List of baseband module configuration distNames                            |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...  | bbmod_internal_dns     | List of baseband module internal distNames                                 |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...  | bbmod_ids              | List of baseband module IDs                                                |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...  | bbmod_cell_mapping     | Dictionary mapping baseband modules to their cells                         |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...  | bbmod_conf_int_dict    | Dictionary mapping configuration distNames to internal distNames           |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${bbmod_ids}=  admin.Get Ids For All  BBMOD  connection=${bts_id}
    @{bbmod_dns}=  Create List
    @{bbmod_internal_dns}=  Create List
    &{bbmod_cell_mapping}=  Create Dictionary
    &{bbmod_conf_int_dict}=  Create Dictionary
    FOR  ${abia_bbmod}  IN  @{abia_serial_numbers}
      FOR  ${bts_info_item}  IN  @{bts_info['basebandModules']}
        Run Keyword If
        ...  '${bts_info_item['serialNumber']}'=='${abia_bbmod}'
        ...  Run Keywords
        ...  Append To List  ${bbmod_dns}  ${bts_info_item['id']['configuration']}
        ...  AND  Append To List  ${bbmod_internal_dns}  ${bts_info_item['id']['internal']}
        ...  AND  Set To Dictionary  ${bbmod_conf_int_dict}  ${bts_info_item['id']['configuration']}=${bts_info_item['id']['internal']}
      END
    END
    FOR  ${tested_bbmod}  IN  @{bbmod_internal_dns}
      ${cells_on_bbmod}=  admin.Get Cell Mapping By Module ID  ${tested_bbmod}  connection=${bts_id}
      Set To Dictionary  ${bbmod_cell_mapping}  ${tested_bbmod}=${cells_on_bbmod}
    END
    [Return]  ${bbmod_dns}  ${bbmod_internal_dns}  ${bbmod_ids}  ${bbmod_cell_mapping}  ${bbmod_conf_int_dict}

Check Parameters From SCF For LTE Too Many PSC And NPSC Cells
    [Arguments]  ${bts_id}  ${bbmod_dns}  ${bbmod_internal_dns}  ${node_cells_dict}  ${bbmod_cell_mapping}
    [Documentation]
    ...  Description:
    ...  Check parameters from SCF for LTE Too Many PSC and NPSC cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_dns              | Yes  | List of baseband module distNames                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_internal_dns     | Yes  | List of internal baseband module distNames                                 |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | node_cells_dict        | Yes  | Dictionary of cells grouped by node                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_cell_mapping     | Yes  | Dictionary mapping baseband modules to their cells                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    &{control_dictionary}=  Create Dictionary
    &{control_statuses}=  Create Dictionary

    ${scf_file_path}=  admin.Get Current Scf File
    ...  local_dir_path=${SUITE_LOGS_DIR_PATH}/SCFs
    ...  file_name=test_current_scf_01
    ...  export_type=configurationAndRuntimeObjects
    ...  connection=${bts_id}

    #10
    ${psgrp_list}=  Evaluate Xpath
    ...  ${scf_file_path}  .//managedObject[@class='PSGRP' or @class='NOKLTE:PSGRP']/@distName
    FOR  ${psgrp_dn}  IN  @{psgrp_list}
      Get Dictionary From Distname And Compare Value
      ...  dist_name=${psgrp_dn}
      ...  key=lbpsLastCellSOEnabled
      ...  value=False
      ...  bts_id=${bts_id}
    END

    &{bbmod_npsc_psc_mapping}=  Create Dictionary
    FOR  ${abia_internal_dn}  IN  @{bbmod_internal_dns}
      ${cells}=  Get From Dictionary  ${bbmod_cell_mapping}  ${abia_internal_dn}
      @{all_cells}=   Create List
      &{npsc_dict}=  Create Dictionary
      @{npsc_cells}=  Create List
      @{psc_cells}=  Create List
      &{psc_dict}=  Create Dictionary
      FOR  ${cell}  IN  @{cells}
        ${cell_no}=  Fetch From Right  ${cell}  -
        FOR  ${psgrp_dn}  IN  @{psgrp_list}
          &{psgrp_dict}=  Create Dictionary
          Log  ${npsc_cells} ${psc_cells}
          ${psgrp_parameters}=  admin.Get Parameter By Distname
          ...  dist_name=${psgrp_dn}
          ...  connection=${BTS_ID}
          ${lbps_cell_list}=  Get From Dictionary  ${psgrp_parameters[0]['parameters']}  lbpsCellList
          ${length}=  Get Length  ${lbps_cell_list}
          ${empty}=  Run Keyword And Return Status  Should Not Be Empty  ${lbps_cell_list}
          Run Keyword If  ${empty}==False  Log  lbpsCellList is empty  level=WARN
          ...  ELSE  Log  lbpsCellList is not empty  level=WARN
          Log  ${npsc_cells} ${psc_cells}

          FOR  ${index}  IN RANGE  0  ${length}
            Log  ${npsc_cells} ${psc_cells}
            ${ln_cell_id}=  Get From Dictionary  ${psgrp_parameters[0]['parameters']['lbpsCellList'][${index}]}  lnCelId
            Continue For Loop If  ${cell_no}!=${ln_cell_id}
            ${lbps_cell_so_order_int}=  Get From Dictionary  ${psgrp_parameters[0]['parameters']['lbpsCellList'][${index}]}  lbpsCellSOOrder
            ${lbps_cell_so_order}=  Convert To String  ${lbps_cell_so_order_int}
            ${npsc_status}=  Run Keyword And Return Status  Should Be Equal  ${lbps_cell_so_order}  100
            Run Keyword If  ${npsc_status}==True and ${cell_no}==${ln_cell_id}  Append To List  ${npsc_cells}  ${ln_cell_id}
            Run Keyword If  ${npsc_status}==False and ${cell_no}==${ln_cell_id}  Append To List  ${psc_cells}  ${ln_cell_id}

            ${index}=  Evaluate  ${length}-1
            Log  ${npsc_cells} ${psc_cells}
          END
          Log  ${npsc_cells} ${psc_cells}
        END
        Log  ${npsc_cells} ${psc_cells}
      END
      Set To Dictionary  ${npsc_dict}  npsc_cells=${npsc_cells}
      Set To Dictionary  ${psc_dict}  psc_cells=${psc_cells}
      Append To List  ${all_cells}  ${npsc_dict}  ${psc_dict}
      Log  ${npsc_cells} ${psc_cells}
      Set To Dictionary  ${bbmod_npsc_psc_mapping}  ${abia_internal_dn}=${all_cells}
      Log  ${npsc_cells} ${psc_cells}
    END
    Log  ${npsc_cells} ${psc_cells}
    Set Test Variable  ${NPSC_CELLS}  ${npsc_cells}
    Set Test Variable  ${PSC_CELLS}  ${psc_cells}
    Set Test Variable  ${BBMOD_NPSC_PSC_MAPPING}  ${bbmod_npsc_psc_mapping}
    Log Dictionary  ${bbmod_npsc_psc_mapping}

Get ABIA BBPOOLS For Tested Cells
    [Arguments]  ${bbmod_cell_mapping}  ${node_cells_dict}  ${bts_id}
    [Documentation]
    ...  Description:
    ...  Get ABIA BBPOOLS for tested cells.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bbmod_cell_mapping     | Yes  | Dictionary mapping baseband modules to their cells                         |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | node_cells_dict        | Yes  | Dictionary of cells grouped by node                                        |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Returns:
    ...  +========================+============================================================================+
    ...  | Return Value           | Description                                                                |
    ...  +========================+============================================================================+
    ...  | cells_in_bbpool        | Dictionary mapping cells to their BBPOOL                                   |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    ${reference_dict}=  Create Dictionary
    @{powergroup_list}=  Create List
    ${parameter}=  admin.Get Scf
    ...  export_type=configurationAndRuntimeObjects
    ...  parameters_save_variant=actualValues
    ...  alias=${bts_id}
    ${scfc_xml}=  Parse XML  source=${parameter}
    ${tested_bbmods}=  Get Dictionary Keys  ${bbmod_cell_mapping}
    ${cells_in_bbpool}=    Create Dictionary
    FOR  ${bbmod}  IN  @{tested_bbmods}
      FOR    ${cell}    IN    @{bbmod_cell_mapping['${bbmod}']}
        ${bts_id}  ${bts_name}  ${class}  ${global_cell_id}  ${cell_r_number}=  Extract Variables From Cell Dist Name  ${cell}  ${node_cells_dict}
        ${distName}=  Get From Dictionary    ${cfg.NODES['${bts_id}']['LNCEL']['${global_cell_id}']}    scf_dist_name
        ${bbpool}=  Run Keyword And Continue On Failure
        ...  Evaluate Xpath  ${scfc_xml}
        ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="hostingBbPoolId"])
        Run Keyword And Continue On Failure  Run Keyword If  '${bbpool}'!='[]'  Set To Dictionary  ${cells_in_bbpool}  ${distName}=${bbpool}
        ${bbpool_tech}=  Run Keyword And Continue On Failure
        ...  Evaluate Xpath  ${scfc_xml}
        ...  string(.//managedObject[@class='com.nokia.srbts.mnl:BBPOOL' and contains (@distName, "MRBTS-${bts_id}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-${bbpool}")]/p[@name="bbPoolTech"])
        Should Be Equal  ${bbpool_tech}  LTE
        ${bbpool_pg}=  Run Keyword And Continue On Failure
        ...  Evaluate Xpath  ${scfc_xml}
        ...  string(.//managedObject[@class='com.nokia.srbts.mnl:BBPOOL' and contains (@distName, "MRBTS-${bts_id}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-${bbpool}")]/list[@name="bbPwrGroupDNList"])
        Run Keyword And Ignore Error  Append To List  ${powergroup_list}  ${bbpool_pg}
        @{bbpool_character_list}=  Split String To Characters  ${bbpool}
        ${powergroup_no}=  Fetch From Right  ${bbpool_pg}  -
        ${powergroup_number}=  Split String  ${powergroup_no}  max_split=1
        Should Be Equal  '${bbpool_character_list[-1]}'  '${powergroup_number[0]}'
      END
    END
    [Return]   ${cells_in_bbpool}

Sort Cells According To First And Second BBPOOL
    [Arguments]  ${cells_in_bbpool}  ${bbmod_dns}
    [Documentation]
    ...  Description:
    ...  Sort cells according to first and second BBPOOL.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | cells_in_bbpool        | Yes  | Dictionary mapping cells to their BBPOOL                                   |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bbmod_dns              | Yes  | List of baseband module distNames                                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Returns:
    ...  +========================+============================================================================+
    ...  | Return Value           | Description                                                                |
    ...  +========================+============================================================================+
    ...  | cells_in_first_pool    | List of cells in the first BBPOOL                                          |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...  | cells_in_second_pool   | List of cells in the second BBPOOL                                         |
    ...  +------------------------+----------------------------------------------------------------------------+
    ...
    ...  Author: izabela.wencel@nokia.com
    ...  Maintainer: izabela.wencel@nokia.com

    @{cells_in_first_pool}=  Create List
    @{cells_in_second_pool}=  Create List
    FOR  ${bbmod_dn}  IN  @{bbmod_dns}
      ${abia_no}=  Fetch From Right  ${bbmod_dn}  -
      FOR  ${cell_in_bbpool}  IN  @{cells_in_bbpool}
        @{character_list}=  Create List
        ${bbpool}=  Get From Dictionary  ${cells_in_bbpool}  ${cell_in_bbpool}
        ${pool_number}=  Fetch From Right  ${bbpool}  -
        @{character_list}=  Split String To Characters  ${pool_number}
        Run Keyword If  '${character_list[-1]}'=='1' and '${character_list[0]}'=='${abia_no}'
        ...  Append To List  ${cells_in_first_pool}  ${cell_in_bbpool}
        Run Keyword If  '${character_list[-1]}'=='2' and '${character_list[0]}'=='${abia_no}'
        ...  Append To List  ${cells_in_second_pool}  ${cell_in_bbpool}
        Run Keyword And Ignore Error  Log To Console  ${cells_in_first_pool}
        Run Keyword And Ignore Error  Log To Console  ${cells_in_second_pool}
      END
    END
    [Return]  ${cells_in_first_pool}  ${cells_in_second_pool}

Preconditions For Power Group
    [Documentation]
    ...  Description:
    ...  Preconditions necessary for Power Group test case. KW also prepares neccesary lists and dicts
    ...  for later to be used in test cases.
    ...  Keyword returns ${npsc_cells_list} and ${psc_cells_list}
    ...  EQM/APEQM/CABINET/BBMOD/useFullCapacity shall be set to 'true' for baseband boards.
    ...  EQM/APEQM/CABINET/BBMOD/bbCardUsage shall be set to '2' for both baseband boards.
    ...  Manual allocation of cells to pools and/or baseband boards shall not be used (bbPoolAllocMode = automatic)
    ...  None of the cells shall be within an UL CoMP cell set list and UL CoMP shall not be activated (actCoMp = 'disabled')
    ...  For all the cells actOtdoa shall be set to 'false'.
    ...  eMBMS services including public safety bearers shall be neither configured nor activated
    ...  (actMBMSPS = 'false' & actPubSafetyBearers = 'false').
    ...  bbPoolAllocPrioList shall be empty
    ...  actLBPowerSaving shall be set to 'true'
    ...  lbpsLastCellSOEnabled for all power saving groups shall be set to 'false'
    ...  actLBBbPowerSaving shall be set to 'true'
    ...  Power Saving Group is created: MRBTS-x/LNBTS-x/PSGRP-x as defined in test plan
    ...  under PSGRP structure lbpsCellList is created
    ...  under lbpsCellList: lbpsCellSOOrder, lnCelId are set as defined in the test plan
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Checking if parameters are correct before exucution of test. Please wait...
    ...  style=ONGOING
    Log  ${CFG}
    ${bbmod_id_config_dn}  Create List
    ${bbmod_internal_dn}  Create List
    ${bbmod_dn}  Create List
    ${lncel_dn_list}  Create List
    ${cells_not_in_pg}  Create List
    ${npsc_cells_list}  Create List
    ${psc_cells_list}  Create List
    ${cells_dict}  Create Dictionary
    ${bbmod_sn_to_product_name_dict}  Create Dictionary
    ${random_allocPriority}   Evaluate  random.randint(1, 9)
    ${restore_conf}  Set Variable  ${False}
    ${bts_id}  Get From Dictionary  ${CFG}  primary_node_bts_id
    Set Test Variable  ${BTS_ID}  ${bts_id}
    ${restore_part1}  Set Variable  [{"distName":"MRBTS-${bts_id}/LNBTS-${bts_id}","operation":"update","parameters":
    ${restore_part2}  Set Variable    [{"parameterName":"bbPoolAllocPrioList","value":"","operation":"delete"}]}]
    ${restore_delta}  Set Variable    ${restore_part1}${restore_part2}
    Set Test Variable  ${RANDOM_ALLOCPRIORITY}  ${random_allocPriority}
    Set Test Variable  ${BBMOD_DN}  ${bbmod_dn}
    Set Test Variable  ${BBMOD_INTERNAL_DN}  ${bbmod_internal_dn}
    ${all_cells_list}  Get Cell List  connection=${bts_id}  timeout=60  detailed_output=False
    Set Test Variable  ${LNCEL_DN_LIST}  ${lncel_dn_list}
    FOR  ${lte_cell}  IN  @{all_cells_list['cells']['lte']}
      Log  ${lte_cell}
      Append To List  ${lncel_dn_list}  ${lte_cell['id']['configuration']}
      Append To List  ${cells_not_in_pg}  ${lte_cell['globalCellId']}
    END

#    Creating WCDMA cells distnames if WCDMA exists
    ${wcdma_configured}=  SCF Check WCDMA Existence  ${CFG.NODES['${bts_id}']['parsed_scf']}
    IF  ${wcdma_configured}
      ${WCDMA_DN_LIST}  Create List
      ${wcdma_cells_list}  Create List
      Set Test Variable  ${WCDMA_CELLS_LIST}  ${wcdma_cells_list}
      FOR  ${wcdma_cell}  IN  @{all_cells_list['cells']['wcdma']}
        Log  ${wcdma_cell}
        Append To List  ${WCDMA_DN_LIST}  ${wcdma_cell['id']['configuration']}
        Append To List  ${WCDMA_CELLS_LIST}  ${wcdma_cell['cellId']}
      END
    END
    ${fbb_info}  Get Fbb Info  connection=${bts_id}
    FOR  ${fbb}  IN  @{fbb_info}
      FOR  ${bbmod_sn}  IN  @{BBMOD_SERIAL_NUMBERS}
        IF  '${bbmod_sn}' == '${fbb['serialNumber']}'
          Append To List  ${bbmod_id_config_dn}  ${fbb['id']['configuration']}
          Append To List  ${bbmod_internal_dn}    ${fbb['id']['internal']}
          Append To List  ${BBMOD_DN}  ${fbb['id']['runtime']}
          Set To Dictionary  ${bbmod_sn_to_product_name_dict}  ${bbmod_sn}  ${fbb['productName']}
        ELSE
          Set To Dictionary  ${bbmod_sn_to_product_name_dict}  ${bbmod_sn}  ${fbb['productName']}
        END
      END
    END
    Evaluate  len(${bbmod_id_config_dn}) == len(${BBMOD_SERIAL_NUMBERS})

#   Check useFullCapacity and bbCardUsage Parameters
    FOR  ${config_dn}  IN  @{bbmod_id_config_dn}
      Get Dictionary From Distname And Compare Value
      ...  dist_name=${config_dn}
      ...  key=useFullCapacity
      ...  value=True
      ...  bts_id=${bts_id}
      Get Dictionary From Distname And Compare Value
      ...  dist_name=${config_dn}
      ...  key=bbCardUsage
      ...  value=2
      ...  bts_id=${bts_id}
    END
    # Check actOtdoa, BBPOOLALLOC and set dictionary lcrId to lncelId
    ${lcr_id_to_cel_id_dict}  Create Dictionary
    Set Test Variable  ${LCR_ID_TO_CELID_DICT}  ${lcr_id_to_cel_id_dict}
    FOR  ${lncel_dn}  IN  @{lncel_dn_list}
      Get Dictionary From Distname And Compare Value
      ...  dist_name=${lncel_dn}
      ...  key=actOtdoa
      ...  value=False
      ...  bts_id=${bts_id}
      ${cell_num}  Fetch From Right  ${lncel_dn}  LNCEL-
      Get Dictionary From Distname And Compare Value
      ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/LNCEL-${cell_num}/BBPOOLALLOC-0
      ...  key=bbPoolAllocMode
      ...  value=automatic
      ...  bts_id=${bts_id}
      ${lncel_parameters}  admin.Get Parameter By Distname
      ...  dist_name=${lncel_dn}
      ...  connection=${bts_id}
      ${lnCelId}  Get From Dictionary  ${lncel_parameters[0]['parameters']}  lnCelId
      ${lcrId}  Get From Dictionary  ${lncel_parameters[0]['parameters']}  lcrId
      Set To Dictionary  ${LCR_ID_TO_CELID_DICT}  ${lcrId}  ${lnCelId}
    END
    ${number_of_pg}  Check Number Of Power Groups  bts_id=${bts_id}
    ${psc_cells_list}  ${npsc_cells_list}  Create PSC And NPSC lists based on lbpsCellSOOrder
    ...  number_of_pg=${number_of_pg}
    ...  bts_id=${bts_id}
    # Checking if there are LTE cells that are not in PG to add them to NPSC cells list
    FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
      ${index}  Get Index From List  ${cells_not_in_pg}  ${value}
      IF  ${value} in ${psc_cells_list}  Remove From List  ${cells_not_in_pg}  ${index}
      IF  ${value} in ${npsc_cells_list}  Remove From List  ${cells_not_in_pg}  ${index}
    END
    ${npsc_cells_list}  Evaluate  ${npsc_cells_list} + ${cells_not_in_pg}
    # Checking if parameters have correct value before test execution
    FOR  ${index}  IN RANGE  ${number_of_pg}
      Get Dictionary From Distname And Compare Value
      ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/PSGRP-${index}
      ...  key=lbpsLastCellSOEnabled
      ...  value=False
      ...  bts_id=${bts_id}
    END
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  key=actCoMp
    ...  value=disabled
    ...  bts_id=${bts_id}
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  key=actMBMSPS
    ...  value=False
    ...  bts_id=${bts_id}
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}/LNBTS_FDD-0
    ...  key=actPubSafetyBearers
    ...  value=False
    ...  bts_id=${bts_id}
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  key=actLBPowerSaving
    ...  value=True
    ...  bts_id=${bts_id}
    Get Dictionary From Distname And Compare Value
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1/FEATLADM-1
    ...  key=actLBBbPowerSaving
    ...  value=True
    ...  bts_id=${bts_id}
    ${mrbts_parameters}  admin.Get Parameter By Distname
    ...  dist_name=MRBTS-${bts_id}/LNBTS-${bts_id}
    ...  connection=${bts_id}
    ${bbPoolAllocPrioList}  Run Keyword And Return Status  Get From Dictionary  ${mrbts_parameters[0]['parameters']}  bbPoolAllocPrioList
    IF  '${bbPoolAllocPrioList}' != 'False'
      Fail  msg=bbPoolAllocPrioList is not empty
    END
    Logging With Timestamp
    ...  message=Checking if parameters are correct before exucution of test. Please wait...
    ...  style=DONE
    [Return]  ${npsc_cells_list}  ${psc_cells_list}  ${restore_delta}

Perform Recommissioning With Delta String
    [Arguments]    ${bts_id}  ${delta_string}
    [Documentation]
    ...  Description:
    ...  Perform recommissioning with additional parameters added as stated in ${delta_string} variable
    ...  Keyword returns ${restore_config} to be used if restoring configuration will be necessary later on.
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | delta_string           | Yes  | json string with parameters for recommisioning                             |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    Logging With Timestamp
    ...  message=Perform Delta recommissioning with given json string.
    ...  style=ONGOING
    ${result}  Perform Delta Recommissioning
    ...  delta_file=${delta_string}
    ...  skip_parameter_relation_errors=True
    ...  should_activate=True
    ...  timeout=360
    ...  connection=${bts_id}
    Should Match  '${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}'  'Success'
    Logging With Timestamp
    ...  message=Perform Delta recommissioning with given json string.
    ...  style=DONE
    ${restore_conf}  Set Variable  ${True}
    [Return]  ${restore_conf}

Check NPSC and PSC cells
    [Arguments]  ${bts_id}  ${npsc_cells_list}  ${psc_cells_list}
    [Documentation]
    ...  Description:
    ...  Keyword that checks if all cells are properly allocated to bbpoolx1 and bbpoolx2 and
    ...  if bbPwrGroupDNList has proper value.  If not, it will fail the test.
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | npsc_cells_list        | Yes  | list with cells that belong to non power saving group                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | psc_cells_list         | Yes  | list with cells that belong to power saving group                          |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Check NPSC and PSC cells proper allocation
    ...  style=ONGOING
    ${wcdma_configured}=  SCF Check WCDMA Existence  ${CFG.NODES['${bts_id}']['parsed_scf']}
    ${npsc_cells_list_check}  Create List
    ${psc_cells_list_check}  Create List
    ${npsc_cells_list_check}  Set Variable  ${npsc_cells_list}
    ${psc_cells_list_check}  Set Variable  ${psc_cells_list}
    IF  ${wcdma_configured}
      ${wcdma_cells_list_check}  Set Variable  ${WCDMA_CELLS_LIST}
    ELSE
      ${wcdma_cells_list_check}  Set Variable  ${EMPTY}
    END
    FOR  ${value}  IN  @{BBMOD_DN}
      ${last_character} =  Get Substring  ${value}  -1
      ${bbmod_value}  Get Substring  ${value}  -10
      ${bbpool_x1}  ${bbpool_x2}  Get Parameters From x1 and x2 Bbmod Bbpool  bts_id=${bts_id}  bbpool=${last_character}
      ${bbpoolcellslistx1}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolCellsList']}
      ${bbpoolcellslistx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
      ${techx1}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolTech']}
      ${techx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolTech']}
      ${bbPwrGroupDNList_bbpool_x1_value}  Get From Dictionary  ${bbpool_x1[0]['parameters']}  bbPwrGroupDNList
      ${bbPwrGroupDNList_bbpool_x2_value}  Get From Dictionary  ${bbpool_x2[0]['parameters']}  bbPwrGroupDNList
      IF  "['${value}/POWERGROUP_R-1']" != "${bbPwrGroupDNList_bbpool_x1_value}"  Fail
      ...  msg=['${value}/POWERGROUP_R-1'] is different than ${bbPwrGroupDNList_bbpool_x1_value}
      IF  "['${value}/POWERGROUP_R-2']" != "${bbPwrGroupDNList_bbpool_x2_value}"  Fail
      ...  msg=['${value}/POWERGROUP_R-2'] is different than ${bbPwrGroupDNList_bbpool_x2_value}
      FOR  ${bbmod_int_dn}  IN  @{BBMOD_INTERNAL_DN}
        Log  ${bbmod_value} ${bbmod_int_dn}
        IF  '${bbmod_value}' in '${bbmod_int_dn}'
          ${bbmod_cells}  Get Cell Mapping By Module Id
          ...  module_id=${bbmod_int_dn}
          ...  timeout=60
          ...  connection=${bts_id}
        ELSE
          Continue For Loop
        END
      END
      Log  ${bbpool_x1[0]['parameters']['bbPoolTech']}
      FOR  ${cell}  IN  @{npsc_cells_list}
        FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
          Log  ${cell} ${key} ${value}
          ${index}  Get Index From List  ${npsc_cells_list_check}  ${cell}
          IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx1}' and '${techx1}' == 'LTE'
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
            END
          ELSE IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${techx1}' == 'WCDMA'
            Log  ${bbpoolcellslistx2}
            ${contains}  Run Keyword And Return Status  Should Contain  ${bbpoolcellslistx2}  ${key}  values=True
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
            END
          ELSE
            Continue For Loop
          END
        END
      END
      Log  ${npsc_cells_list_check}
#     Checking if WCDMA cells are properly allocated on bbpools
      IF  '${techx1}' == 'WCDMA'
        FOR  ${cell}  IN  @{WCDMA_CELLS_LIST}
          FOR  ${key}  ${value}  IN ZIP  ${WCDMA_DICT.keys()}  ${WCDMA_DICT.values()}
            Log  ${cell} ${key} ${value}
            IF  ${value} == ${cell} and '${key}' in '${bbpool_x1[0]['parameters']['bbPoolCellsList']}'
                ${index}  Get Index From List  ${wcdma_cells_list_check}  ${cell}
              IF  ${index} == -1
                Log  Cell ${cell} not found in list.
              ELSE
                Remove From List  ${wcdma_cells_list_check}  ${index}
                Exit For Loop
              END
            ELSE
              Continue For Loop
            END
          END
        END
      END

      FOR  ${cell}  IN  @{psc_cells_list}
        FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
          Log  ${cell} ${key} ${value}
          ${bbpoolcellslistx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
          ${tech}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolTech']}
          IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${tech}' == 'LTE'
            Log  ${bbmod_cells} ${cell}
            ${cell_from_correct_bbpool}  Evaluate  any(str(${cell}) in element for element in ${bbmod_cells})
            IF  ${cell_from_correct_bbpool}
              ${index}  Get Index From List  ${psc_cells_list_check}  ${cell}
              Remove From List  ${psc_cells_list_check}  ${index}
              Exit For Loop
            ELSE
              Continue For Loop
            END
          ELSE IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${techx1}' == 'WCDMA'
            Log  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
            ${contains}  Run Keyword And Return Status  Should Contain  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}  ${key}  values=True
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE IF  ${contains} == True
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
             ELSE
               Continue For Loop
             END
          ELSE
            Continue For Loop
          END
        END
      END
        Log  ${psc_cells_list_check}
    END
    ${npsc_cells_list_length}  Get Length  ${npsc_cells_list_check}
    ${psc_cells_list_length}  Get Length  ${psc_cells_list_check}
    ${wcdma_cells_list_length}  Get Length  ${wcdma_cells_list_check}
    IF  ${npsc_cells_list_length} > 0  Fail
    ...  msg=Not all NPSC cells are properly allocated in bbppoolx1. Check configuration to find out where cells from ${npsc_cells_list_check} are.
    IF  ${psc_cells_list_length} > 0  Fail
    ...  msg=Not all PSC cells are properly allocated in bbppoolx2. Check configuration to find out where cells from ${psc_cells_list_check} are.
    IF  ${wcdma_cells_list_length} > 0  Fail
    ...  msg=Not all WCDMA cells are properly allocated in bbppool7x. Check configuration to find out where cells from ${wcdma_cells_list_check} are.
    Logging With Timestamp
    ...  message=Check NPSC and PSC cells proper allocation
    ...  style=DONE

Get Parameters From x1 and x2 Bbmod Bbpool
    [Arguments]  ${bts_id}  ${bbpool}
    [Documentation]
    ...  Description:
    ...  Get parameters from bbpoolx1 and bbpoolx2 where 'x' is given in ${bbpool} variable. Works for LTE and WCDMA.
    ...  Keyword returns parameters of bbpools. Keyword fails if given bbpool number is not in configuration.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bbpool                 | Yes  | First digit of bbpool which will be checked                                |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    ${wcdma_configured}=  SCF Check WCDMA Existence  ${CFG.NODES['${bts_id}']['parsed_scf']}
    ${bbpool_parameters1}  admin.Get Parameter By Distname
     ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-${bbpool}1
     ...  connection=${bts_id}
     IF  ${bbpool_parameters1} == [] and ${wcdma_configured}
       ${bbpool_parameters1}  admin.Get Parameter By Distname
       ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-70
       ...  connection=${bts_id}
     ELSE IF  ${bbpool_parameters1} == [] and ${wcdma_configured}=='False'
       Fail  msg=There is missing BBPOOL-${bbpool}1
     END
    ${bbpool_parameters2}  admin.Get Parameter By Distname
    ...  dist_name=MRBTS-${bts_id}/MNL-1/MNLENT-1/BBADM-1/BBPOOL-${bbpool}2
    ...  connection=${bts_id}
    [Return]  ${bbpool_parameters1}  ${bbpool_parameters2}

Restore config
    [Arguments]  ${bts_id}  ${restore_conf}  ${restore_delta}  ${graceful}=False
    [Documentation]
    ...  Description:
    ...  Restores configuration and wait for BTS on air. Uses json.delta in string format.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | restore_conf           | Yes  | True if restore should happen.                                             |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...  | restore_delta          | Yes  | json delta string                                                          |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com
    IF  ${restore_conf}
      Logging With Timestamp
      ...  message=Restore Config.
      ...  style=STEP
      ...  frame=${TRUE}
      ${result}  Perform Delta Recommissioning
      ...  delta_file=${restore_delta}
      ...  skip_parameter_relation_errors=True
      ...  should_activate=True
      ...  timeout=360
      ...  connection=${bts_id}
      Should Match  '${result['commissioningResult']['activationResult']['resultNode']['parameters']['result']}'  'Success'
      ${reset_response}=  Run Keyword And Continue On Failure    admin.Reset Site
      ...  connection=${bts_id}
      ...  wait_for_reconnection=True
      ...  detailed_output=True
      ...  graceful_cell_shutdown=${graceful}
      ...  timeout=${CONFIGURATION_STARTUP_TIMEOUT}
      Logging With Timestamp
      ...  message=Restore Config.
      ...  style=DONE
    ELSE
      Logging With Timestamp
      ...  message=Restore Config not necessary.
      ...  style=DONE
      ...  frame=${TRUE}
    END
    Wait Until Keyword Succeeds  10x  60  STATE Verify BTS states  node_id=${bts_id}

Check NPSC and PSC cells For PG WCDMA
    [Arguments]  ${bts_id}  ${npsc_cells_list}  ${psc_cells_list}  ${single_abia}=False
    [Documentation]
    ...  Description:
    ...  Keyword that checks if all cells are properly allocated to bbpoolx1 and bbpoolx2 and
    ...  if bbPwrGroupDNList has proper value.  If not, it will fail the test.
    ...
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | npsc_cells_list        | Yes  | List of cells which are NPSC cells                                         |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...  | psc_cells_list         | Yes  | List of cells which are PSC cells                                          |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...  | single_abia            |  No  | Used in case of testing single ABIA PG. Default value set to False         |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Check NPSC and PSC cells proper allocation
    ...  style=ONGOING
    ${wcdma_configured}=  SCF Check WCDMA Existence  ${CFG.NODES['${bts_id}']['parsed_scf']}
    ${npsc_cells_list_check}  Create List
    ${psc_cells_list_check}  Create List
    ${npsc_cells_list_check}  Set Variable  ${npsc_cells_list}
    ${psc_cells_list_check}  Set Variable  ${psc_cells_list}
    IF  ${wcdma_configured}
      ${wcdma_cells_list_check}  Set Variable  ${WCDMA_CELLS_LIST}
    ELSE
      ${wcdma_cells_list_check}  Set Variable  ${EMPTY}
    END
    FOR  ${value}  IN  @{BBMOD_DN}
      ${last_character} =  Get Substring  ${value}  -1
      ${bbmod_value}  Get Substring  ${value}  -10
      ${bbpool_x1}  ${bbpool_x2}  Get Parameters From x1 and x2 Bbmod Bbpool  bts_id=${bts_id}  bbpool=${last_character}
      ${bbpoolcellslistx1}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolCellsList']}
      ${bbpoolcellslistx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
      ${techx1}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolTech']}
      ${techx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolTech']}
      ${bbPwrGroupDNList_bbpool_x1_value}  Get From Dictionary  ${bbpool_x1[0]['parameters']}  bbPwrGroupDNList
      ${bbPwrGroupDNList_bbpool_x2_value}  Get From Dictionary  ${bbpool_x2[0]['parameters']}  bbPwrGroupDNList
      IF  "['${value}/POWERGROUP_R-1']" != "${bbPwrGroupDNList_bbpool_x1_value}"  Fail
      ...  msg=['${value}/POWERGROUP_R-1'] is different than ${bbPwrGroupDNList_bbpool_x1_value}
      IF  "['${value}/POWERGROUP_R-2']" != "${bbPwrGroupDNList_bbpool_x2_value}"  Fail
      ...  msg=['${value}/POWERGROUP_R-2'] is different than ${bbPwrGroupDNList_bbpool_x2_value}
      FOR  ${bbmod_int_dn}  IN  @{BBMOD_INTERNAL_DN}
        Log  ${bbmod_value} ${bbmod_int_dn}
        IF  '${bbmod_value}' in '${bbmod_int_dn}'
          ${bbmod_cells}  Get Cell Mapping By Module Id
          ...  module_id=${bbmod_int_dn}
          ...  timeout=60
          ...  connection=${bts_id}
        ELSE
          Continue For Loop
        END
      END
      Log  ${bbpool_x1[0]['parameters']['bbPoolTech']}
      FOR  ${cell}  IN  @{npsc_cells_list}
        FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
          Log  ${cell} ${key} ${value}
          ${index}  Get Index From List  ${npsc_cells_list_check}  ${cell}
          IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx1}' and '${techx1}' == 'LTE'
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
            END
          ELSE IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${techx1}' == 'WCDMA'
            Log  ${bbpoolcellslistx2}
            ${contains}  Run Keyword And Return Status  Should Contain  ${bbpoolcellslistx2}  ${key}  values=True
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
            END
          ELSE
            Continue For Loop
          END
        END
      END
      Log  ${npsc_cells_list_check}
#     Checking if WCDMA cells are properly allocated on bbpools
      IF  '${techx1}' == 'WCDMA'
        FOR  ${cell}  IN  @{WCDMA_CELLS_LIST}
          FOR  ${key}  ${value}  IN ZIP  ${WCDMA_DICT.keys()}  ${WCDMA_DICT.values()}
            Log  ${cell} ${key} ${value}
            IF  ${value} == ${cell} and '${key}' in '${bbpool_x1[0]['parameters']['bbPoolCellsList']}'
                ${index}  Get Index From List  ${wcdma_cells_list_check}  ${cell}
              IF  ${index} == -1
                Log  Cell ${cell} not found in list.
              ELSE
                Remove From List  ${wcdma_cells_list_check}  ${index}
                Exit For Loop
              END
            ELSE
              Continue For Loop
            END
          END
        END
      END

      FOR  ${cell}  IN  @{psc_cells_list}
        FOR  ${key}  ${value}  IN ZIP  ${LCR_ID_TO_CELID_DICT.keys()}  ${LCR_ID_TO_CELID_DICT.values()}
          Log  ${cell} ${key} ${value}
          ${bbpoolcellslistx2}  Set Variable  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
          ${tech}  Set Variable  ${bbpool_x1[0]['parameters']['bbPoolTech']}
          IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${tech}' == 'LTE'
            Log  ${bbmod_cells} ${cell}
            ${cell_from_correct_bbpool}  Evaluate  any(str(${cell}) in element for element in ${bbmod_cells})
            IF  ${cell_from_correct_bbpool}
              ${index}  Get Index From List  ${psc_cells_list_check}  ${cell}
              Remove From List  ${psc_cells_list_check}  ${index}
              Exit For Loop
            ELSE
              Continue For Loop
            END
          ELSE IF  ${value} == ${cell} and '${key}' in '${bbpoolcellslistx2}' and '${techx1}' == 'WCDMA'
            Log  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}
            ${contains}  Run Keyword And Return Status  Should Contain  ${bbpool_x2[0]['parameters']['bbPoolCellsList']}  ${key}  values=True
            IF  ${index} == -1
              Log  Cell ${cell} not found in list.
            ELSE IF  ${contains} == True
              Remove From List  ${npsc_cells_list_check}  ${index}
              Exit For Loop
             ELSE
               Continue For Loop
             END
          ELSE
            Continue For Loop
          END
        END
      END
        Log  ${psc_cells_list_check}
    END
    IF  ${single_abia}
        ${wcdma_cells_list_check}  Check FID:1868 On WCMDA Single Abia  ${bts_id}  ${wcdma_cells_list_check}
    END
    ${npsc_cells_list_length}  Get Length  ${npsc_cells_list_check}
    ${psc_cells_list_length}  Get Length  ${psc_cells_list_check}
    ${wcdma_cells_list_length}  Get Length  ${wcdma_cells_list_check}
    IF  ${npsc_cells_list_length} > 0  Fail
    ...  msg=Not all NPSC cells are properly allocated in bbppoolx1. Check configuration to find out where cells from ${npsc_cells_list_check} are.
    IF  ${psc_cells_list_length} > 0  Fail
    ...  msg=Not all PSC cells are properly allocated in bbppoolx2. Check configuration to find out where cells from ${psc_cells_list_check} are.
    IF  ${wcdma_cells_list_length} > 0  Fail
    ...  msg=Not all WCDMA cells are properly allocated in bbppool7x. Check configuration to find out where cells from ${wcdma_cells_list_check} are.
    Logging With Timestamp
    ...  message=Check NPSC and PSC cells proper allocation
    ...  style=DONE

Check FID:1868 On WCMDA Single Abia
    [Arguments]  ${bts_id}  ${wcdma_cells_list}
    [Documentation]
    ...  Description:
    ...  KW that checks if FID:1868 appeared on WCDMA cells in PG TC if only 1 ABIA is used.
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | bts_id                 | Yes  | BTSid                                                                      |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...  | wcdma_cells_list       | Yes  | List of WCDMA cells which are allocated on tested ABIA                     |
    ...  +------------------------+-----------------------------------------------------------------------------------+
    ...
    ...  Author: szymon.przybylak@nokia.com
    ...  Maintainer: szymon.przybylak@nokia.com

    Logging With Timestamp
    ...  message=Check If FID:1868 appeared on WCDMA cells
    ...  style=ONGOING
    ${fault1868_status}=  Run Keyword And Return Status  admin.Assert Alarm Active
    ...  parameters=faultId=1868, severity=Critical, alarmId=7114
    ...  timeout=60
    ...  connection=${bts_id}
    IF  ${fault1868_status}
        ${active_alarms}  Get Active Alarms  connection=${bts_id}
        FOR  ${alarm}  IN  @{active_alarms}
            IF  ${alarm['faultId']} == 1868
                Log  ${alarm}
                FOR  ${wcdma}  IN  @{wcdma_cells_list}
                    ${cell_in_alarm}  Evaluate  any(str(${wcdma}) in element for element in ${alarm['impactedCellsList']})
                    IF  ${cell_in_alarm}
                        ${index}  Get Index From List  ${wcdma_cells_list}  ${wcdma}
                        Remove From List  ${wcdma_cells_list}  ${index}
                        Exit For Loop
                    END
                END
            END
        END
    END
    Logging With Timestamp
    ...  message=Check If FID:1868 appeared on WCDMA cells
    ...  style=DONE
    [Return]  ${wcdma_cells_list}
