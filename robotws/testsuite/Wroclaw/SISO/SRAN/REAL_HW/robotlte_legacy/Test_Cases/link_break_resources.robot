*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Resource with keywords used in tests with link breaks

Library  String
Library  Collections
Library  taf.sbts.oam.coam.admin  WITH NAME  admin

*** Keywords ***
Get RMOD, BBMOD, FHS, CABLINKS distNames
    Log  --- Get RMOD_DN, BBMOD_DN, FHS_DN, CABLINK_PRIM_DN, CABLINK_SECOND_DN ---${\n}  console=True
    &{sfp_links}=  admin.Get Sfp Links  connection=${BTS_ID}
    Set Test Variable  ${SFP_LINKS}  ${sfp_links}
    ${rmod_under_test_dn}=  Get RMOD distName  ${sfp_links}
    Set Test Variable  ${RMOD_UNDER_TEST_DN}  ${rmod_under_test_dn}
    Get FHS BBMOD distNames  ${sfp_links}
    Log  BBMOD under test ${bbmod_smod_under_test} and${\n}FHS under test ${FHS_UNDER_TEST} ${\n}  console=True
    ${fhs_exists}=  Run Keyword And Return Status  Should Not Be Empty  ${FHS_UNDER_TEST}
    Run Keyword If  ${fhs_exists}  Run Keywords
    ...  Get BBMOD via FHS distName  ${sfp_links}
    ...  AND  Log  FHS connected to tested RMOD exists.  console=True
    ...  ELSE  Fail  No FHS connected to tested RMOD. Unexpected configuration.
    Get Cablink distName  ${BTS_ID}  ${RMOD_UNDER_TEST_DN}

Get RMOD distName
    [Arguments]  ${sfp_links}
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${RMOD_SN_LINK_DOWN}'!='${link['parent']['source']['parameters']['serialNumber']}'
      ${rmod_under_test_dn}=  Set Variable  ${link['parent']['source']['distName']}
      Exit For Loop
    END
    Variable Should Exist  ${rmod_under_test_dn}  msg=Please check SN!!!
    [Return]  ${rmod_under_test_dn}

Get FHS BBMOD distNames
    [Arguments]  ${sfp_links}
    @{fhs_bbmod_under_test}=  Create List
    @{bbmod_via_fhs_under_test}=  Create List
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${RMOD_SN_LINK_DOWN}'!='${link['parent']['source']['parameters']['serialNumber']}'
      Append To List  ${fhs_bbmod_under_test}  ${link['parent']['destination']['distName']}
      Find Affected Items  ${fhs_bbmod_under_test}
    END

Get Cells' distNames
    Log  --- Get Cells' distNames ---${\n}  console=True
    &{rmod_affected_dn_sn}=  Create Dictionary  ${rmod_under_test_dn}  ${RMOD_SN_LINK_DOWN}
    @{rmods_under_test_dn}=  Create List
    Append To List  ${rmods_under_test_dn}  ${RMOD_UNDER_TEST_DN}
    ${cells_affected_dn}=  Prepare Cells Connections List  ${BTS_ID}  ${rmods_under_test_dn}
    Set Test Variable  ${CELLS_AFFECTED_DN}  ${cells_affected_dn}
    ${all_cells_distname}=  Create All Cells Distname  ### od Przemka
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}

Get A List Of All Items
    [Arguments]  ${os_set_link_down}
    Log  --- Get a list of All Items ---${\n}  console=True
    @{all_fhs_list}=  Create List
    Set Test Variable  ${ALL_FHS_LIST}  ${all_fhs_list}
    &{all_items}=  Create Dictionary
    Set Test Variable  ${ALL_ITEMS}  ${all_items}
    @{all_rmods}=  Create List
    Set Test Variable  ${ALL_RMODS}  ${all_rmods}
    FOR  ${bts_node}  IN  @{cfg.NODES}
      ${node_items}=  Prepare All Items  ${bts_node}
      Set To Dictionary  ${ALL_ITEMS}  ${bts_node}=${node_items}
    END
    Log  --- Get Lists of Affected Items ---${\n}  console=True
    ${all_affected_items}  ${not_affected_items}=  Prepare Lists Not And Affected Items
    Set Test Variable  ${ALL_AFFECTED_ITEMS}  ${all_affected_items}
    Set Test Variable  ${NOT_AFFECTED_ITEMS}  ${not_affected_items}
    Log To Console  Precondition Finished. BTS_ID ${BTS_ID},
    ...  Tested RMOD sn ${RMOD_SN_LINK_DOWN} RMOD distName ${RMOD_UNDER_TEST_DN},
    ...  OS configuration to disconnect primary link ${os_set_link_down}
    ${cells_on_tested_rmod}=  admin.Get Cell Mapping By Module ID  ${RMOD_UNDER_TEST_DN}  connection=${bts_node}
    ${cells_on_tested_bbmod}=  admin.Get Cell Mapping By Module ID  ${bbmod_smod_under_test[0]}  connection=${bts_node}
    Set Test Variable  ${CELLS_ON_TESTED_BBMOD}  ${cells_on_tested_bbmod}
    ${cells_on_bbmod_via_fhs}=  admin.Get Cell Mapping By Module ID
    ...  ${bbmod_via_fhs_under_test[0]}
    ...  connection=${bts_node}
    ${cells_on_tested_fhs}=  Find Cells on BBMOD via FHS Which Are on Tested RMOD
    ...  ${cells_on_bbmod_via_fhs}
    ...  ${cells_on_tested_rmod}
    Set Test Variable  ${CELLS_ON_TESTED_FHS}  ${cells_on_tested_fhs}

Find Affected Items
    [Arguments]  ${fhs_bbmod_under_test}
    @{bbmod_smod_under_test}=  Create List
    Set Test Variable  ${BBMOD_SMOD_UNDER_TEST}  ${bbmod_smod_under_test}
    @{fhs_under_test}=  Create List
    Set Test Variable  ${FHS_UNDER_TEST}  ${fhs_under_test}
    FOR  ${item}  IN  @{fhs_bbmod_under_test}
      ${bbmod}=  Run Keyword And Return Status  Should Match Regexp  '${item}'  .*BBMOD_R-\\d+
      Run Keyword If  ${bbmod}==True
      ...  Append To List  ${bbmod_smod_under_test}  ${item}
      ${smod}=  Run Keyword And Return Status  Should Match Regexp  '${item}'  .*SMOD_R-\\d+
      Run Keyword If  ${smod}==True
      ...  Append To List  ${bbmod_smod_under_test}  ${item}
      ${fhs}=  Run Keyword And Return Status  Should Match Regexp  '${item}'  .*FHS_R-\\d+
      Run Keyword If  ${fhs}==True
      ...  Append To List  ${fhs_under_test}  ${item}
    END

Get BBMOD via FHS distName
    [Arguments]  ${sfp_links}
    @{bbmod_via_fhs_under_test}=  Create List
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${FHS_UNDER_TEST[0]}'!='${link['parent']['source']['distName']}'
      Append To List  ${bbmod_via_fhs_under_test}  ${link['parent']['destination']['distName']}
    END
    Log  BBMOD via FHS ${bbmod_via_fhs_under_test}  console=True
    Set Test Variable  ${BBMOD_VIA_FHS_UNDER_TEST}  ${bbmod_via_fhs_under_test}

Get Cablink distName
    [Arguments]  ${bts_id}  ${rmod_under_test_dn}
    @{cablink_prim_dist_name}=  Create List
    @{cablink_second_dist_name}=  Create List
    @{cablinks}=  admin.Get Parameters For All  CABLINK  alias=${bts_id}
    FOR  ${cablink}  IN  @{cablinks}
      ${rmod_match}=  Run Keyword and Return Status
      ...  Should Be Equal
      ...  '${rmod_under_test_dn}'
      ...  '${cablink['secondEndpointDN']}'
      ${fhs_match}=  Run Keyword and Return Status
      ...  Should Match Regexp
      ...  '${FHS_UNDER_TEST}'
      ...  '(?i)${cablink['firstEndpointDN']}'
      ${bbmod_smod_match}=  Run Keyword and Return Status  Should Match Regexp
      ...  '${bbmod_smod_under_test}'  '(?i)${cablink['firstEndpointDN']}'
      Run Keyword If  ${fhs_match}==True and ${rmod_match}==True  Append To List
      ...  ${cablink_second_dist_name}  ${cablink['id']}
      Run Keyword If  ${bbmod_smod_match}==True and ${rmod_match}==True  Append To List
      ...  ${cablink_prim_dist_name}  ${cablink['id']}
    END
    Log  primary ${cablink_prim_dist_name} and secondary ${cablink_second_dist_name} cablink  console=True
    Set Test Variable  ${CABLINK_PRIM_DN}  ${cablink_prim_dist_name}
    ${cablink_second_exists}=  Run Keyword And Return Status  Should Not Be Empty  ${cablink_second_dist_name}
    Run Keyword If  ${cablink_second_exists}  Set Test Variable  ${CABLINK_SECOND_DN}  ${cablink_second_dist_name}

Prepare Lists Not And Affected Items
    @{all_items_copy}=  Copy List  ${ALL_ITEMS['${BTS_ID}']}
    @{all_affected_items}=  Create List
    Append To List  ${all_affected_items}  ${RMOD_UNDER_TEST_DN}
    @{all_affected_items}=  Combine Lists  ${all_affected_items}  ${CELLS_AFFECTED_DN}
    FOR  ${affected_item}  IN  @{all_affected_items}
      Remove Values From List  ${all_items_copy}  ${affected_item}
    END
    [Return]    ${all_affected_items}  ${all_items_copy}

Find Cells on BBMOD via FHS Which Are on Tested RMOD
    [Arguments]  ${cells_on_tested_bbmod_via_fhs}  ${cells_on_tested_rmod}
    @{cells_on_tested_fhs}=  Create List
    FOR  ${cell_on_tested_bbmod_via_fhs}  IN  @{cells_on_tested_bbmod_via_fhs}
      ${status}=  Run Keyword And Return Status
      ...  List Should Contain Value
      ...  ${cells_on_tested_rmod}
      ...  ${cell_on_tested_bbmod_via_fhs}
      Run Keyword If  ${status}==True  Append To List  ${cells_on_tested_fhs}  ${cell_on_tested_bbmod_via_fhs}
    END
    Log  Tested cells on BBMOD via FHS ${cells_on_tested_fhs}  console=True
    [Return]  ${cells_on_tested_fhs}

Check Linkmode Of Chosen Cablink
    [Arguments]  ${all_cablinks_before_break}  ${cablink_dn}  ${linkmode}
    ${cablink_linkmode_expected}=  Set Variable  ${FALSE}
    FOR  ${cablink_before_break}  IN  @{all_cablinks_before_break}
      Continue For Loop If  '${cablink_dn[0]}'!='${all_cablinks_before_break['${cablink_before_break}']['internal']}'
      ${cablink_linkmode}=  Run Keyword and Return Status  Should Be Equal
      ...  '${linkmode}'  '${all_cablinks_before_break['${cablink_before_break}']['linkmode']}'
      ${cablink_linkmode_expected}=  Set Variable If  ${cablink_linkmode}==True  ${TRUE}
      Run Keyword If  ${cablink_linkmode}==True  Exit For Loop
    END
    Run Keyword If
    ...  ${cablink_linkmode_expected}
    ...  Log to Console
    ...  Cablink ${cablink_dn} with expected ${linkmode} linkmode
    ...  ELSE
    ...  Run Keywords
    ...  Log To Console
    ...  Cablink ${cablink_dn} with UNEXPECTED ${linkmode} linkmode. Check the BTS settings and state.
    ...  AND
    ...  Fail
    ...  Unexpected linkmode.

Check Cablink State
    [Arguments]  ${cablink}  ${oper_state}  ${avail_status}  ${alias}
    ${verified_link_present}=  Set Variable  False
    ${hw_states}=  admin.Get Detected HW Info  connection=${alias}
    FOR  ${hw_state}  IN  @{hw_states['cables']}
      Continue For Loop If  '${cablink[0]}'!='${hw_state['id']['internal']}'
      ${verified_link_present}=  Set Variable  True
      Should Match Regexp  '${hw_state['status']['operationalState']}'  ${oper_state}
      ${avail_status_exist}=  Run Keyword And Return Status
      ...  Should Not Be Empty
      ...  '${hw_state['status']['availabilityStatus']}'
      Run Keyword If
      ...  ${avail_status_exist}
      ...  Should Match Regexp
      ...  '${hw_state['status']['availabilityStatus']}'
      ...  ${avail_status}
      Run Keyword If  ${avail_status_exist}==False  Log To Console  availabilityStatus of the link On Air (-)
    END
    Run Keyword If  ${verified_link_present}==False  Fail  Link not found.

Verify Cell State For Link Break
    [Arguments]  ${cell_dn}  ${cell_type}  ${operational_state}  ${not_availability_status}
    ${cell_state}=  Run Keyword And Return Status  admin.Assert  ${cell_type}  ${cell_dn}
    ...  operationalState=regex"(?i)${operational_state}"  timeout=60  connection=${BTS_ID}
    Log  ${cell_type} ${operational_state} true  console=True
    ${cell_notdegraded}=  Run Keyword And Return Status  admin.Assert No  ${cell_type}  ${cell_dn}
    ...  availabilityStatus=regex"(?i)${not_availability_status}"  timeout=60  connection=${BTS_ID}
    Log  ${cell_type} ${not_availability_status} true  console=True

Create Cell Unit Dictionary
    [Arguments]  ${all_units_list}
    &{cell_unit_dictionary}=  Create Dictionary
    FOR  ${unit}  IN  @{all_units_list}
      ${cells}=  Get Cell Mapping By Module ID  ${unit}  connection=${BTS_ID}
      Set To Dictionary  ${cell_unit_dictionary}  ${unit}  ${cells}
    END
    [Return]  ${cell_unit_dictionary}

Get RMOD Links And Set Cablink Variables
    [Arguments]  ${rmod_under_test_dn}  ${sfp_links}
    &{rmod_links_in}=  Create Dictionary
    &{rmod_links_out}=  Create Dictionary
    &{rmod_cablinks_in_dns}=  Create Dictionary
    &{rmod_cablinks_out_dns}=  Create Dictionary
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${rmod_under_test_dn}'!='${link['parent']['source']['distName']}'
      Set To Dictionary  ${rmod_links_out}  ${link['parent']['source']['physicalPort']}=${link['parent']['destination']['distName']}
      Set To Dictionary  ${rmod_cablinks_out_dns}  ${link['parent']['source']['physicalPort']}=${link['link']['distName']}
      ${opt_if1_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['source']['physicalPort']}  .*OPT_IF1
      ${opt_if2_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['source']['physicalPort']}  .*OPT_IF2
      ${opt_if3_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['source']['physicalPort']}  .*OPT_IF3
      ${opt_if4_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['source']['physicalPort']}  .*OPT_IF4
      Run Keyword If  ${opt_if1_found}==True  Set Test Variable  ${OPT_IF1_DN}  ${link['link']['distName']}
      Run Keyword If  ${opt_if2_found}==True  Set Test Variable  ${OPT_IF2_DN}  ${link['link']['distName']}
      Run Keyword If  ${opt_if3_found}==True  Set Test Variable  ${OPT_IF3_DN}  ${link['link']['distName']}
      Run Keyword If  ${opt_if4_found}==True  Set Test Variable  ${OPT_IF4_DN}  ${link['link']['distName']}
    END
    FOR  ${link}  IN  @{sfp_links['connected']}
      Continue For Loop If  '${rmod_under_test_dn}'!='${link['parent']['destination']['distName']}'
      Set To Dictionary  ${rmod_links_in}  ${link['parent']['destination']['physicalPort']}=${link['parent']['source']['distName']}
      Set To Dictionary  ${rmod_cablinks_in_dns}  ${link['parent']['source']['physicalPort']}=${link['link']['distName']}
      ${opt_if1_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['destination']['physicalPort']}  .*OPT_IF1
      ${opt_if2_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['destination']['physicalPort']}  .*OPT_IF2
      ${opt_if3_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['destination']['physicalPort']}  .*OPT_IF3
      ${opt_if4_found}=  Run Keyword and Return Status  Should Match Regexp  ${link['parent']['destination']['physicalPort']}  .*OPT_IF4
      Run Keyword If  ${opt_if1_found}==True  Set Test Variable  ${OPT_IF1_DN}  ${link['link']['distName']}
      Run Keyword If  ${opt_if2_found}==True  Set Test Variable  ${OPT_IF2_DN}  ${link['link']['distName']}
      Run Keyword If  ${opt_if3_found}==True  Set Test Variable  ${OPT_IF3_DN}  ${link['link']['distName']}
      Run Keyword If  ${opt_if4_found}==True  Set Test Variable  ${OPT_IF4_DN}  ${link['link']['distName']}
    END
    Log  All connections to the tested RMOD: ${rmod_links_in}  console=True
    Log  All connections out of the tested RMOD: ${rmod_links_out}  console=True
    Log  All cablinks to the tested RMOD: ${rmod_cablinks_in_dns}  console=True
    Log  All cablinks out of the tested RMOD: ${rmod_cablinks_out_dns}  console=True
    [Return]  ${rmod_links_in}  ${rmod_links_out}  &{rmod_cablinks_in_dns}  ${rmod_cablinks_out_dns}

Recovery For Link Break With Changed Time Delay 7447 Not Supported
    [Arguments]  ${tested_cablinks_os_port}=${TESTED_CABLINKS_OS_PORT}  ${ip_switch}=${IP_SWITCH}
    Logging With Timestamp
    ...  message=Running recovery action for Link break - setting back Calient.
    ...  style=STEP
    ...  frame=${TRUE}
    Run Keyword And Ignore Error  Recover To Shorter Link For Link Break With Changed Link Length  ${tested_cablinks_os_port}  ${ip_switch}
    Run Keyword And Continue On Failure
    ...  admin.Assert Any  RMOD
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=180
    ...  connection=${cfg['active_bts_list'][0]}
    Logging With Timestamp
    ...  message=Waiting for allowed 1815 to appear
    ...  style=ONGOING

    # TODO: Figure out better way of adding 1815 for primary link break
    ${rmod_1815_status}  ${rmod_1815_unique_attr}=  Run Keyword And Ignore Error  Assert Alarm Active
    ...  faultId=1815, severity=Major  timeout=35s  connection=${BTS_ID}
    Run Keyword If  '${rmod_1815_status}'=='PASS'  admin.Add Allowed Alarm  faultId=1815, severity=Major  alias=${BTS_ID}

    ${rmod_fid10_status}  ${rmod_fid10_unique_attr}=  Run Keyword And Ignore Error  FM Await For Fault
    ...  faultId=10, alarmId=7116, severity=Critical, alarmingObjectIds[0].internal=${TESTED_RMOD_DN}
    ...  ${BTS_ID}
    ...  ${rmod_fid10_alarm_resource}
    ...  240
    Run Keyword And Continue On Failure
    ...  Assert No  RMOD
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=300
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  LNCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  search_for_iot_cells=${True}
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  NRCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  WNCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}
    Run Keyword And Continue On Failure
    ...  Assert No  GNCEL
    ...  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"
    ...  timeout=120
    ...  connection=${cfg['active_bts_list'][0]}

Recover To Shorter Link For Link Break With Changed Link Length
    [Arguments]  ${tested_cablinks}  ${switch_ip}=${cfg['IP_SWITCH']}
    Optical Switch Setup  switch_ip=${switch_ip}
    @{in_port_list}  Create List
    ${in_port_list}  Get Dictionary Values  ${tested_cablinks}
    ${link_port_out1}  Get From Dictionary  ${ALL_CALIENT_PORTS}  ${in_port_list[0]}
    ${link_port_out2}  Get From Dictionary  ${ALL_CALIENT_PORTS}  ${in_port_list[1]}
    ${long_port_in}  ${long_port_out}  Split String  ${LONG_FIBER}  -
    &{new_connections_basic1}  Create Dictionary  in=${in_port_list[0]}  out=${link_port_out1}  dir=uni
    &{new_connections_basic2}  Create Dictionary  in=${in_port_list[1]}  out=${link_port_out2}  dir=uni
    ${in_port_list1}  Create List  ${in_port_list[0]}
    ${in_port_list2}  Create List  ${in_port_list[1]}
    ${in_port_list3}  Create List  ${long_port_in}
    Run Keyword And Ignore Error  Remove Optical Switch connections  in_ports=${in_port_list1}
    Run Keyword And Ignore Error  Remove Optical Switch connections  in_ports=${in_port_list2}
    Run Keyword And Ignore Error  Remove Optical Switch connections  in_ports=${in_port_list3}
    Sleep  2s
    Run Keyword And Ignore Error  Set Optical Switch Channel  settings=${new_connections_basic1}
    Run Keyword And Ignore Error  Set Optical Switch Channel  settings=${new_connections_basic2}
    [Teardown]  Teardown Optical Switch

Preparing Variables To Test Link Break With Changed Time Delay CB007447 Not Supported
    Set Test Variable  ${BTS_ID}  ${cfg['active_bts_list'][0]}
    ${bts_parameter}  Get Parameter By Distname  MRBTS-${BTS_ID}  connection=${BTS_ID}
    Set Test Variable  ${BTS_NAME}  ${bts_parameter[0]['parameters']['btsName']}
#    ${tested_cablinks_os_port}  Get From Dictionary  ${cfg}  tested_cablinks
#    Set Test Variable  ${TESTED_CABLINKS_OS_PORT}  ${tested_cablinks_os_port}
#    Log Dictionary  ${TESTED_CABLINKS_OS_PORT}
    ${cablink_cfg_list}  Get Dictionary Keys  ${TESTED_CABLINKS_OS_PORT}
    Set Test Variable  ${CABLINK_CFG_LIST}  ${cablink_cfg_list}
    ${all_cells_distname}  Create List Of All Cells Distnames
    Set Test Variable  ${ALL_CELLS_DISTNAME}  ${all_cells_distname}
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    ${tested_rmod_dn}  Get From Dictionary  ${all_cablinks['${CABLINK_CFG_LIST[0]}']}  rmod
    Set Test Variable  ${TESTED_RMOD_DN}  ${tested_rmod_dn}
    ${tested_radio_parameters}  Get Parameters For  RMOD  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    ${tested_rmod_sn}  Get From Dictionary  ${tested_radio_parameters}  serialNumber
    Set Test Variable  ${TESTED_RMOD_SN}  ${tested_rmod_sn}
    ${cablinks_with_affected_cells_dict}  Create Cablinks Dictionary With Affected Cells Lists
    Set Test Variable  ${CABLINKS_WITH_AFFECTED_CELLS_DICT}  ${cablinks_with_affected_cells_dict}
    ${cells_on_tested_rmod}  Get Cell Mapping By Module ID  ${TESTED_RMOD_DN}  connection=${BTS_ID}
    Set Test Variable    ${CELLS_ON_TESTED_RMOD}  ${cells_on_tested_rmod}
    &{tested_cablink}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink}  ${cablink_cfg}=&{all_cablinks['${cablink_cfg}']}
    END
    Set Test Variable  ${TESTED_CABLINK}  ${tested_cablink}
    ${secondary_cablink_dn}  Get Secondary Cablink Internal Distname  ${TESTED_CABLINK}
    ${primary_cablink_dn}  Get Primary Cablink Internal Distname  ${TESTED_CABLINK}
    ${secondary_cablink_runtime_dn}  Get Secondary Cablink Runtime Distname  ${TESTED_CABLINK}
    Set Test Variable  ${PRIMARY_CABLINK_DN}  ${primary_cablink_dn}
    Set Test Variable  ${SECONDARY_CABLINK_DN}  ${secondary_cablink_dn}
    Set Test Variable  ${SECONDARY_CABLINK_RUNTIME_DN}  ${secondary_cablink_runtime_dn}
    ${cells_on_prim}  Get From Dictionary  ${cablinks_with_affected_cells_dict}  ${PRIMARY_CABLINK_DN}
    ${cells_on_second}  Get From Dictionary  ${cablinks_with_affected_cells_dict}  ${SECONDARY_CABLINK_DN}
    Set Test Variable  ${CELLS_ON_PRIM}  ${cells_on_prim}
    Set Test Variable  ${CELLS_ON_SECOND}  ${cells_on_second}
    @{not_affected_cells_dn}  Create List  @{ALL_CELLS_DISTNAME}
    @{affected_cells_dn}  Combine Lists  ${CELLS_ON_PRIM}  ${CELLS_ON_SECOND}
    FOR  ${cell}  IN  @{affected_cells_dn}
      Remove Values From List  ${not_affected_cells_dn}  ${cell[0]}
    END
    Log List  ${not_affected_cells_dn}
    ${sec_port_in}  Get Port Secondary Link Flapping  ${TESTED_CABLINK}  ${TESTED_CABLINKS_OS_PORT}
    ${prim_port_in}  Get Port Primary Link Flapping  ${TESTED_CABLINK}  ${TESTED_CABLINKS_OS_PORT}
    Set Test Variable  ${SEC_PORT_IN}  ${sec_port_in}
    Set Test Variable  ${PRIM_PORT_IN}  ${prim_port_in}
    ${all_rmods}  Get IDs For All  RMOD  connection=${BTS_ID}
    ${all_bbmods}  Get IDs For All  BBMOD  connection=${BTS_ID}
    &{cell_rmod_dictionary}  Create Cell Unit Dictionary  ${all_rmods}
    &{cell_bbmod_dictionary}  Create Cell Unit Dictionary  ${all_bbmods}
    ${dsp}=  Get All Items By Class Name  DSP  connection=${BTS_ID}
    &{sfp_links}=  Get SFP Links  connection=${BTS_ID}
    ${rmod_links_in}  ${rmod_links_out}  ${rmod_cablinks_in_dns}  ${rmod_cablinks_out_dns}=
    ...  Get RMOD Links And Set Cablink Variables  ${TESTED_RMOD_DN}  ${sfp_links}
    ${tested_abias}=  Check If Tested RMOD Connected To ABIA  ${rmod_links_out}
    ${cells_on_bbpool}=  Get ABIA BBPOOLS For Cells On Tested RMODs
    ${keys_no}=  Create List
    FOR  ${cell}  IN  @{cells_on_bbpool}
      ${cell_no}=  Fetch From Right  ${cell}  -
      Append To List  ${keys_no}  ${cell_no}
    END
    @{cells_drop_with_abias_dsp}=  Create List
    FOR  ${cell}  IN  @{affected_cells_dn}
      ${cell_no}=  Fetch From Right  ${cell}  -
      ${status}=  Run Keyword And Return Status  List Should Contain Value  ${keys_no}  ${cell_no}
      Continue For Loop If  ${status}==False
      Append To List  ${cells_drop_with_abias_dsp}  ${cell}
      ${cells_drop_with_abias_dsp}=  Find Other Cells On The Same BBPOOL  ${cells_on_bbpool}  ${cell}  ${cells_drop_with_abias_dsp}
    END
    ${cells_drop_with_abias_dsp}=  Remove Duplicates  ${cells_drop_with_abias_dsp}
    @{affected_cells_dn}=  Combine Lists  ${cells_drop_with_abias_dsp}  ${affected_cells_dn}
    Set Test Variable  ${AFFECTED_CELLS_DN}  ${affected_cells_dn}
    FOR  ${cell}  IN  @{AFFECTED_CELLS_DN}
      Remove Values From List  ${not_affected_cells_dn}  ${cell}
    END
    Log List  ${AFFECTED_CELLS_DN}
    Set Test Variable  ${NOT_AFFECTED_CELLS_DN}  ${not_affected_cells_dn}
    Log List  ${NOT_AFFECTED_CELLS_DN}
    @{affected_items}=  Combine Lists  ${tested_abias}  ${cells_drop_with_abias_dsp}  ${affected_cells_dn}
    Append To List  ${affected_items}  ${TESTED_RMOD_DN}
    Set Test Variable  ${AFFECTED_ITEMS}  ${affected_items}
    Log List  ${AFFECTED_ITEMS}

Find Other Cells On The Same BBPOOL
    [Arguments]  ${cells_on_bbpool}  ${cell}  ${cells_drop_with_abias_dsp}
    FOR  ${cell_bb}  IN  @{cells_on_bbpool}
      ${cell_path}  ${cell_no_bb}=  Split String From Right  ${cell_bb}  -  1
      ${cell_path_long}  ${cell_no}=  Split String From Right  ${cell}  -  1
      ${cell_cat}=  Catenate  SEPARATOR=-  ${cell_path}  ${cell_no}
      ${cell_bb_long}=  Catenate  SEPARATOR=-  ${cell_path_long}  ${cell_no_bb}
      Run Keyword If  '${cells_on_bbpool['${cell_bb}']}'=='${cells_on_bbpool['${cell_cat}']}'
      ...  Append To List  ${cells_drop_with_abias_dsp}  ${cell_bb_long}
    END
    [Return]  ${cells_drop_with_abias_dsp}

Checking Parameters For CB013082 Link Break
    [Arguments]  ${bts_id}=${BTS_ID}  ${connection}=${BTS_ID}
    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${connection}
    Run Keyword If  "${featcadm_parameter[0]['parameters']['actCpriLinkRecovery']}"=="False"
    ...  Log  Parameter actCpriLinkRecovery deactivated.  console=${TRUE}
    ...  ELSE  Log  Parameter actCpriLinkRecovery not activated, test failed.  level=warn
    Run Keyword If  "${featcadm_parameter[0]['parameters']['actRecovFromSecondaryController']}"=="False"
    ...  Log  Parameter actRecovFromSecondaryController deactivated.  console=${TRUE}
    ...  ELSE  Log  Parameter actRecovFromSecondaryController not activated, test failed.  level=warn
    ${fmcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FMCADM-1  connection=${connection}
    Run Keyword If  "${fmcadm_parameter[0]['parameters']['actForceUnitAutoReset']}"=="True"
    ...  Log  actForceUnitAutoReset activated.  console=${TRUE}
    ...  ELSE  Fail  Mandatory parameter actForceUnitAutoReset not activated, test failed.

Check If Tested RMOD Connected To ABIA
    [Arguments]  ${rmod_links_out}
    @{tested_abias}=  Create List
    FOR  ${link_out}  IN  @{rmod_links_out}
      ${bbmod_dn}=  Set Variable  ${rmod_links_out['${link_out}']}
      ${bbmod_parameters}=  Get Parameters For  BBMOD  ${bbmod_dn}  connection=${BTS_ID}
      ${abia_status}=  Run Keyword and Return Status  Should Match Regexp  ${bbmod_parameters['productName']}  .*ABIA
      Run Keyword If  ${abia_status}==True  Append To List  ${tested_abias}  ${bbmod_dn}
      ${tested_abias}  Remove Duplicates  ${tested_abias}
    END
    [Return]  ${tested_abias}

Get Cells On ABIA Affected By DSP Reset
    [Arguments]  ${tested_bbmods}
    @{abia_affected_cells}=  Create List
    FOR  ${bbmod}  IN  @{tested_bbmods}
      ${cells}=  Get Cell Mapping By Module ID  ${bbmod}  connection=${BTS_ID}
      ${abia_affected_cells}=  Combine Lists  ${abia_affected_cells}  ${cells}
    END
    [Return]  ${abia_affected_cells}

Verify Unit Cells States
    [Documentation]
    ...  ${availability_status} is not returned when it is OnAir (-) so we need to verify whether it is not opposite or not found
    [Arguments]  ${cells_on_tested_unit}  ${operational_state}  ${alias}=${BTS_ID}
    FOR  ${cell_on_tested_unit}   IN  ${cells_on_tested_unit}
      ${NRCEL_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_unit}'  .*/NRCELL_R-\\d+
      ${cell_type}=  Run Keyword If  ${NRCEL_type}==True  Set Variable  NRCEL
      Run Keyword If  ${NRCEL_type}==True  Assert  ${cell_type}  ${cell_on_tested_unit}  operationalState=regex"${operational_state}"
      ...  timeout=240  connection=${alias}
      ${LNCEL_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_unit}'  .*/LNCEL_R-\\d+
      ${cell_type}=  Run Keyword If  ${LNCEL_type}==True  Set Variable  LNCEL
      Run Keyword If  ${LNCEL_type}==True  Assert  ${cell_type}  ${cell_on_tested_unit}  operationalState=regex"${operational_state}"
      ...  timeout=240  connection=${alias}
      ${WNCEL_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_unit}'  .*/WNCEL_R-\\d+
      ${cell_type}=  Run Keyword If  ${WNCEL_type}==True  Set Variable  WNCEL
      Run Keyword If  ${WNCEL_type}==True  Assert  ${cell_type}  ${cell_on_tested_unit}  operationalState=regex"${operational_state}"
      ...  timeout=240  connection=${alias}
      ${GNCEL_type}=  Run Keyword And Return Status  Should Match Regexp  '${cell_on_tested_unit}'  .*/GNCEL_R-\\d+
      ${cell_type}=  Run Keyword If  ${GNCEL_type}==True  Set Variable  GNCEL
      Run Keyword If  ${GNCEL_type}==True  Assert  ${cell_type}  ${cell_on_tested_unit}  operationalState=regex"${operational_state}"
      ...  timeout=240  connection=${alias}
    END

Wait For Affected Cells To Change State
    [Arguments]   ${operational_state}  ${cells}
    FOR  ${cell_dn}  IN  @{cells}
      Verify Unit Cells States  ${cell_dn}  ${operational_state}
    END

Create List Of All Cells Distnames
    ${cells_nr}=  Get IDs For All  NRCEL  connection=${BTS_ID}
    ${cells_lte}=  Get IDs For All  LNCEL  connection=${BTS_ID}
    Set Test Variable  ${CELLS_LTE}  ${cells_lte}
    ${cells_wcdma}=  Get IDs For All  WNCEL  connection=${BTS_ID}
    ${cells_gsm}=  Get IDs For All  GNCEL  connection=${BTS_ID}
    ${all_cells_distnames}=  Combine Lists  ${cells_nr}  ${cells_lte}  ${cells_wcdma}  ${cells_gsm}
    Log List  ${all_cells_distnames}
    [Return]  ${all_cells_distnames}

Get ABIA BBPOOLS For Cells On Tested RMODs
    ${reference_dict}  Create Dictionary
    ${parameter}  admin.Get Scf  export_type=configurationAndRuntimeObjects  parameters_save_variant=actualValues  alias=${BTS_ID}
    ${scfc_xml}  Parse XML  source=${parameter}
    ${out_lcr_id_list}=  SCFC Create LcrId List  ${scfc_xml}
    ${scfc_all_lte_cells}=  SCFC Create LncelId List For LcrdId List  ${scfc_xml}  ${out_lcr_id_list}
    ${cells_on_bbpool}=    Create Dictionary
    FOR    ${cell}    IN    @{scfc_all_lte_cells}
      ${distName}=  Get From Dictionary    ${cfg.NODES['${bts_id}']['LNCEL']['${cell}']}    scf_dist_name
      ${bbpool}=  Run Keyword And Continue On Failure
      ...  Evaluate Xpath  ${scfc_xml}
      ...  string(.//managedObject[@class='NOKLTE:BBPOOLALLOC' and contains (@distName, "${distName}/")]/p[@name="hostingBbPoolId"])
        Run Keyword And Continue On Failure  Run Keyword If  '${bbpool}'!='[]'  Set To Dictionary  ${cells_on_bbpool}  ${distName}=${bbpool}
    END
    [Return]   ${cells_on_bbpool}

Proceed After FID 4685 Warning Appears
    [Arguments]  ${cells}
    Log  Expected fault 4685 for tested link appeared.  console=${TRUE}
#    admin.Add Allowed Alarm
#    ...  faultId=4685, severity=Warining, alarmingObjectIds[0].internal=${cells}
#    ...  connection=${BTS_ID}
    Sleep  5s  msg=Waiting for RMOD to start resetting.
    Log  --- Waiting for RMOD to get On Air again ---  console=True
    Wait Until Keyword Succeeds  10x  240s  Verify RU Power Remove Insert State  ${BTS_ID}  ${TESTED_RMOD_DN}  Insert  20 sec
    Log  --- Waiting for affected cells to get back On Air ---  console=True
    Wait For Affected Cells To Change State  (?i)Enabled  ${cells}
    Log  --- Checking cablinks states ---  console=True
    Check Cablink State  ${SECONDARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Check Cablink State  ${PRIMARY_CABLINK_DN_LIST}  (?i)Enabled  (?i)On Air  ${BTS_ID}
    Log  --- Collecting infomodel log from current session ---  console=True
    Collect Infomodel Log From Current Session  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2  connection=${BTS_ID}
    Check availabilityStatus For Affected And Not Affected Items  ${AFFECTED_ITEMS}  ${NOT_AFFECTED_CELLS_DN}
    ...  ${cfg.test_logs_path}/InfoModel_rmod_${BTS_ID}.ims2
    ${status_same}=  Check Whether Synchro Link Now The Same As Preconditions
    Run Keyword If  ${status_same}==True  Set Test Variable  ${RUN_STEP3}  True
    ...  ELSE  Set Test Variable  ${RUN_STEP3}  False

Recovery From 4685 Critical
    ${fault_4685_crit_link_status}=  Run Keyword And Return Status  Assert Alarm Active  timeout=10
    ...  faultId=4685, severity=Critical  connection=${BTS_ID}
    Run Keyword If  ${fault_4685_crit_link_status}  Proceed After FID 4685 Critical Appears

Proceed After FID 4685 Critical Appears
    Log  Critical fault 4685 for tested link appeared. ${\n}Default 3 recovery resets of the same radio module within 1 hour is allowed.
    Log  ${\n}Resetting the tested RMOD to clear the critical alarm.  console=${TRUE}
    Reset Unit  ${TESTED_RMOD_DN}  timeout=240  connection=${BTS_ID}
    Wait Until Keyword Succeeds  10x  240s  Verify RU Power Remove Insert State  ${BTS_ID}  ${TESTED_RMOD_DN}  Insert  20 sec
    Assert No  LNCEL  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"  search_for_iot_cells=${True}
    ...  timeout=120  connection=${BTS_ID}
    Assert No  NRCEL  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"  timeout=120  connection=${BTS_ID}
    Assert No  WNCEL  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"  timeout=120  connection=${BTS_ID}
    Assert No  GNCEL  availabilityStatus=regex"(?i)off\\s?line|not\\s?installed|failed|degraded"  timeout=120  connection=${BTS_ID}
    ${status_same}=  Check Whether Synchro Link Now The Same As Preconditions
    Run Keyword If  ${status_same}==True  Set Test Variable  ${RUN_STEP3}  True
    ...  ELSE  Set Test Variable  ${RUN_STEP3}  False

Check Whether Synchro Link Now The Same As Preconditions
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_compared}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink_compared}  ${cablink_cfg}=&{all_cablinks['${cablink_cfg}']}
    END
    ${primary_cablink_dn_compared}=  Get Primary Cablink Internal Distname  ${tested_cablink_compared}
    Run Keyword If  '${primary_cablink_dn_compared}'=='${PRIMARY_CABLINK_DN}'  Return From Keyword  True
    ...  ELSE  Return From Keyword  False

Check Whether Data Link Now The Same As Preconditions
    ${all_cablinks}  Create Cablinks Dictionary With Distnames And LinkMode
    &{tested_cablink_compared}  Create Dictionary
    FOR  ${cablink_cfg}  IN  @{CABLINK_CFG_LIST}
      Set To Dictionary  ${tested_cablink_compared}  ${cablink_cfg}=&{all_cablinks['${cablink_cfg}']}
    END
    ${secondary_cablink_dn_compared}=  Get Secondary Cablink Internal Distname  ${tested_cablink_compared}
    Run Keyword If  '${secondary_cablink_dn_compared}'=='${SECONDARY_CABLINK_DN}'  Return From Keyword  True
    ...  ELSE  Return From Keyword  False
=======
  Log  ${cell_type} ${not_availability_status} true  console=True
>>>>>>> master

Optical Switch Set Configuration Remove
    [Arguments]    ${current_os_config}=${fhs_alt_conf}
    [Documentation]
    ...  Description:
    ...  KW modifies optical switch conections
    ...  Arguments:
    ...  +========================+======+============================================================================+
    ...  | Argument               | Man. | Description                                                                |
    ...  +========================+======+============================================================================+
    ...  | current_os_config      | yes  | string descritpion for all section in switch                               |
    ...  +------------------------+------+----------------------------------------------------------------------------+
    ...
    ...  Author: piotr.korczynski@nokia.com
    ...  Maintainer: piotr.korczynski@nokia.com
    FOR   ${index}    IN   @{current_os_config}
      @{os_config_cmd_index}    Split String    ${index}    :
      set test variable    ${os_config_number}        ${os_config_cmd_index[0]}
      set test variable    ${os_config_cmd}        ${os_config_cmd_index[1]}
      ${optical_switch}=  Find Init Object Using Attribute Value  ${TL}  ${os_config_cmd_index[0]}
      Optical Switch Setup Configuration
      ...  optical_switch=${optical_switch}
      ...  os_config_cmd=${os_config_cmd_index[1]}
      ...  alias=opt_switch
    END

Check availabilityStatus For Affected And Not Affected Items
    [Arguments]  ${all_affected_items}  ${not_affected_items}  ${ims2_log_path}
    @{status_list_not_affected_items}  Create List
    Log  Checking availabilityStatus for not affected items  console=True
    FOR  ${item}  IN  @{not_affected_items}
      ${status}  ${msg}  Run Keyword And Ignore Error
      ...  Find Parameter Change
      ...  ${ims2_log_path}
      ...  ${item}
      ...  availabilityStatus
      Run Keyword If  "${msg}"=="No change found in availabilityStatus"  Log  ${item} remained unchanged  console=${TRUE}
      Run Keyword If
      ...  "${msg}"!="No change found in availabilityStatus"
      ...  Log
      ...  FAIL !!! availabilityStatus of ${item} changed
      ...  console=${TRUE}
      Append To List  ${status_list_not_affected_items}  ${status}
    END
    ${status_not_affected_items}  Run Keyword And Return Status
    ...  List Should Contain Value
    ...  ${status_list_not_affected_items}
    ...  PASS
    Run Keyword And Continue On Failure  Run Keyword If  ${status_not_affected_items}
    ...  Fail  FAIL!!! Not Affected Items changed availabilityStatus during the test.

    @{status_list_affected_items}  Create List
    Log  Checking availabilityStatus for affected items  console=True
    FOR  ${item}  IN  @{all_affected_items}
      ${status}  ${msg}  Run Keyword And Ignore Error
      ...  Find Parameter Change
      ...  ${cfg['test_logs_path']}/${rep_index}/short_break_log/${ITERATION}_alias_${BTS_ID}_infomodel.ims2
      ...  ${item}
      ...  availabilityStatus
      Run Keyword If  "${msg}"=="No change found in availabilityStatus"  Log  ${item} remained unchanged  console=${TRUE}
      Run Keyword If
      ...  "${msg}"!="No change found in availabilityStatus"
      ...  Log
      ...  availabilityStatus of ${item} changed
      ...  console=${TRUE}
      Append To List  ${status_list_affected_items}  ${status}
    END
    ${status_affected_items}  Run Keyword And Return Status
    ...  List Should Contain Value
    ...  ${status_list_affected_items}
    ...  PASS
    Run Keyword If  ${status_affected_items}  Log To Console  Affected Items changed availabilityStatus during the test.
