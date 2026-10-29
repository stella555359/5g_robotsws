*** Settings ***

Documentation  Maintainers: przemyslaw.kempa@nokia.com

Library    taf.hw.optical_switch    WITH NAME    optical_switch
Library    taf.sbts.oam.coam.admin  WITH NAME    admin
Resource    ../../../Resources/SiSo_L3_call.robot


*** Variables ***
${CELL_ONAIR_REGEX}  operationalState=regex"(?i)Enabled", administrativeState=regex"(?i)Unlocked", proceduralState=regex"(?i)OnAirDone"
${RMOD_expected_states}   administrativeState=regex"(?i)Unlocked", operationalState=regex"(?i)Enabled"



*** Keywords ***
Optical Switch Setup
    [Documentation]
    ...  Establish the connection to Optical Switch
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                 |
    ...  | switch vendor    | No    | Calient | The vendor of Optical Switch                |
    ...  | switch model     | No    | S320    | The model of Optical Switch                 |
    ...  | switch ip        | Yes   |         | The IP of Optical Switch                    |
    ...  | switch username  | No    | admin   | The Username of Optical Switch              |
    ...  | switch password  | No    | pxc***  | The Password of Optical Switch              |
    ...  | alias            | No    | default | The alias of configured Optical Switch      |
    ...  | port             | No    | 80      | The port for connection to Optical Switch   |
    ...
    [Arguments]  ${switch_ip}  ${switch_username}=admin  ${switch_password}=pxc***  ${port}=80  ${switch_vendor}=Calient  ${switch_model}=S320
    ...          ${alias}=default
    setup_optical_switch                optical_switch=${switch_vendor}
    ...                                 model=${switch_model}
    ...                                 addr=${switch_ip}
    ...                                 user_name=${switch_username}
    ...                                 password=${switch_password}
    ...                                 alias=${alias}
    ...                                 port=${port}

Teardown Optical Switch
    [Documentation]
    ...  Close the connection to Optical Switch
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                           |
    ...  | alias                | No    | default   | alias of configured optical switch    |
    ...
    [Arguments]  ${alias}=default
    optical_switch.Teardown  optical_switch_device=${alias}

Optical Switch Setup TL1
    [Documentation]
    ...  Establish the connection to Optical Switch for TL1
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter        | Man.  | Default | Description                                 |
    ...  | switch vendor    | No    | Calient | The vendor of Optical Switch                |
    ...  | switch model     | No    | S320    | The model of Optical Switch                 |
    ...  | switch ip        | Yes   |         | The IP of Optical Switch                    |
    ...  | switch username  | No    | tl1user | The Username of Optical Switch              |
    ...  | protocol         | No    | tl1     | The Protocol of Optical Switch              |
    ...  | alias            | No    | default | The alias of configured Optical Switch      |
    ...
    [Arguments]  ${switch_ip}  ${switch_username}=tl1user  ${switch_vendor}=Calient  ${switch_model}=S320
    ...  ${switch_protocol}=tl1  ${alias}=tl1
    optical_switch.Setup Optical Switch  optical_switch=${switch_vendor}
    ...                                  model=${switch_model}
    ...                                  addr=${switch_ip}
    ...                                  user_name=${switch_username}
    ...                                  alias=${alias}
    ...                                  protocol=${switch_protocol}

Teardown Optical Switch TL1
    [Documentation]
    ...  Close the connection to Optical Switch TL1
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter            | Man.  | Default   | Description                           |
    ...  | alias                | No    | tl1       | alias of configured optical switch    |
    ...
    [Arguments]  ${alias}=tl1
    optical_switch.Teardown  optical_switch_device=${alias}

Link Flapping TL1
    [Documentation]
    ...  Link flaping for Calient S320 optical swich
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  | Parameter         | Man.  | Default   | Description                                 |
    ...  | flap_lowperiod    | Yes   |           | [milliseconds] : between 20ms and 30 min    |
    ...  | flap_highperiod   | No    | 40        | [milliseconds] : between 20ms and 30 min    |
    ...  | flap_repeat       | No    | 1         | [count] : between 1 and 30                  |
    ...  | flap_ports        | Yes   |           | port e.g. 4.4.3 or 4.4.1&4.43               |
    ...  | alias             | No    | tl1       | alias of configured optical switch          |
    ...
    [Arguments]  ${flap_lowperiod}  ${flap_ports}  ${flap_highperiod}=40  ${flap_repeat}=1  ${alias}=tl1
    optical_switch.Set Link Flapping  lowperiod=${flap_lowperiod}  highperiod=${flap_highperiod}  repeat=${flap_repeat}  ports=${flap_ports}
                                 ...  optical_switch_device=${alias}

Set Optical Switch And Perform Break Link
    [Documentation]
    ...  KW contains main procedures used to operate of Calient - Optical Switch TL1:
    ...  - establish the connection based on the provided IP number
    ...  - perform link flapping based on the provided number of ports
    ...  - close the connection
    ...
    ...  **Input Parameters:**
    ...  +----------------------------------+------+-------------------------------------------------------------------------------------------+
    ...  |        Input Parameters          | Man. |                                  Description                                              |
    ...  +==================================+======+===========================================================================================+
    ...  | switch ip address_number of port | Yes  |  The IP of Optical Switch_Number of its port e.g. 10.42.201.18_211 or 10.42.201.10_4.5.8  |
    ...  +----------------------------------+------+-------------------------------------------------------------------------------------------+
    [Arguments]  ${switch_ip_port}  ${switch_link_break_time}
    ${switch_port}  Split String  ${switch_ip_port}  _
    ${switch_ip}  Set Variable  ${switch_port[0]}
    ${port_number}  Set Variable  ${switch_port[1]}
    Optical Switch Setup TL1  switch_ip=${switch_ip}
    Link Flapping TL1  flap_lowperiod=${switch_link_break_time}  flap_ports=${port_number}
    [Teardown]  Teardown Optical Switch TL1

Checking Parameters For Link Break
    [Arguments]  ${CB007447_active}=${FALSE}  ${bts_id}=${BTS_ID}  ${connection}=${BTS_ID}
    ${featcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FEATCADM-1  connection=${connection}
    Run Keyword If  "${featcadm_parameter[0]['parameters']['actCpriLinkRecovery']}"=="True"  Log  Mandatory parameter actCpriLinkRecovery activated.
    ...  console=${TRUE}
    Run Keyword If  not "${featcadm_parameter[0]['parameters']['actCpriLinkRecovery']}"=="True"
    ...  Fail  Mandatory parameter actCpriLinkRecovery not activated, test failed.
    Run Keyword If  ${CB007447_active}  Checking Parameters For Link Break CB007447  ${featcadm_parameter}  ${bts_id}  connection=${connection}

Checking Parameters For Link Break CB007447
    [Arguments]  ${featcadm_parameter}  ${bts_id}=${BTS_ID}  ${connection}=${BTS_ID}
    Run Keyword If  "${featcadm_parameter[0]['parameters']['actFaultSignature']}"=="True"  Log  Mandatory parameter actFaultSignature activated.
    ...  console=${TRUE}
    Run Keyword If  not "${featcadm_parameter[0]['parameters']['actFaultSignature']}"=="True"
    ...  Fail  Mandatory parameter actFaultSignature not activated, test failed.
    ${fmcadm_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/FMCADM-1  connection=${connection}
    Run Keyword If  "${fmcadm_parameter[0]['parameters']['actForceUnitAutoReset']}"=="True"
    ...  Log  Mandatory parameter actForceUnitAutoReset activated.  console=${TRUE}
    Run Keyword If  not "${fmcadm_parameter[0]['parameters']['actForceUnitAutoReset']}"=="True"
    ...  Fail  Mandatory parameter actForceUnitAutoReset not activated, test failed.
    ${pmmnl_parameter}  admin.Get Parameter By Distname  MRBTS-${bts_id}/MNL-1/MNLENT-1/PMMNL-1  connection=${connection}
    ${fsm_info}  Get Fsm Info  connection=${connection}
    ${product_name}  Get From Dictionary  ${fsm_info[0]}  productName
    ${airscale_core}  Run Keyword And Return Status  Should Match Regexp  ${product_name}  AirScale Core
    ${mtSbtsSfp_hw_lane}  Set Variable If  ${airscale_core}  mtSbtsSfpSmodLane  mtSbtsSfpBbmodLane
    Run Keyword If  "${pmmnl_parameter[0]['parameters']['${mtSbtsSfp_hw_lane}']}"=="5min"  Log  Mandatory parameter ${mtSbtsSfp_hw_lane} set to 5min.
    ...  console=${TRUE}
    Run Keyword If  not "${pmmnl_parameter[0]['parameters']['${mtSbtsSfp_hw_lane}']}"=="5min"
    ...  Fail  Please set parameter ${mtSbtsSfp_hw_lane} to 5min, test failed.

Create Cablinks Dictionary With Distnames And LinkMode
    [Documentation]
    ...  Create List of Cablinks with details in dict:
    ...  - internal cablink distName
    ...  - runtime cablink distName
    ...  - cablink linkmode (primary/secondary)
    ...  - distname of connected rmod
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *OUTPUT*
    ...  {'CABLINK-4': {'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/HWTOP_R-1/CABLINK_R-1001',
    ...                 'linkmode': 'Primary',
    ...                 'rmod': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1',
    ...                 'runtime': 'MRBTS-1031/EQM_R-4/HWTOP_R-1/CABLINK_R-1001'},
    ...   'CABLINK-5': {'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/HWTOP_R-1/CABLINK_R-1002',
    ...                 'linkmode': 'Secondary',
    ...                 'rmod': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1',
    ...                 'runtime': 'MRBTS-1031/EQM_R-4/HWTOP_R-1/CABLINK_R-1002'}}
    ...
    [Arguments]  ${connection}=${BTS_ID}
    ${bts_info}=  Get Bts Info  connection=${connection}
    ${cablink_list}=  Set Variable  ${bts_info['cables']}
    ${cablink_dictionary}  Create Dictionary
    ${cablink_id_to_runtime}  Create Dictionary
    FOR  ${cablink}  IN  @{cablink_list}
      ${cablink_id}  Get From Dictionary  ${cablink['id']}  configuration
      ${cablink_id}  Fetch From Right  ${cablink_id}  HWTOP-1/
      ${cablink_runtime_id}  Get From Dictionary  ${cablink['id']}  runtime
      ${cablink_internal_id}  Get From Dictionary  ${cablink['id']}  internal
      ${rmod_dn}  Get From Dictionary  ${cablink['secondEndPointId']}  internal
      ${rmod_dn}  Fetch From Left  ${rmod_dn}  /OPT
      ${linkMode}  Get From Dictionary  ${cablink['linkMode']}  synchronization
      ${link}=  Run Keyword If  ${linkMode}  Set Variable  Primary
      ...  ELSE  Set Variable  Secondary
      ${linkSpeed}  Get From Dictionary  ${cablink}  linkSpeed
      Set To Dictionary  ${cablink_id_to_runtime}  linkmode=${link}  runtime=${cablink_runtime_id}  rmod=${rmod_dn}  internal=${cablink_internal_id}
      ...  linkSpeed=${linkSpeed}
      Set To Dictionary  ${cablink_dictionary}  ${cablink_id}=&{cablink_id_to_runtime}
    END
    Log Dictionary  ${cablink_dictionary}
    [Return]  ${cablink_dictionary}

Check Scf Parameter Value
    [Arguments]  ${class_name}  ${dist_name}  ${parameter_name}  ${scf_path}
    ${out_parameter_value}=  Evaluate Xpath  ${scf_path}
    ...  string(.//managedObject[@class="${class_name}" and @distName="${dist_name}"]/p[@name="${parameter_name}"])
    [Return]  ${out_parameter_value}

Create All Cells Distname
    [Arguments]  ${connection}=${BTS_ID}
    ${all_cells_dict}  admin.Get Cell List  connection=${connection}
    ${nr_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  nr
    ${lte_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  lte
    ${wcdma_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  wcdma
    ${gsm_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  gsm
    @{cells_distname}  Create List
    FOR  ${nr_cell}  IN  @{nr_cells_dict}
       ${nr_cell_dn}  Get From Dictionary  ${nr_cell['id']}  internal
       Append To List  ${cells_distname}  ${nr_cell_dn}
    END
    FOR  ${lte_cell}  IN  @{lte_cells_dict}
       ${lte_cell_dn}  Get From Dictionary  ${lte_cell['id']}  internal
       Append To List  ${cells_distname}  ${lte_cell_dn}
    END
    FOR  ${wcdma_cell}  IN  @{wcdma_cells_dict}
       ${wcdma_cell_dn}  Get From Dictionary  ${wcdma_cell['id']}  internal
       Append To List  ${cells_distname}  ${wcdma_cell_dn}
    END
    FOR  ${gsm_cell}  IN  @{gsm_cells_dict}
       ${gsm_cell_dn}  Get From Dictionary  ${gsm_cell['id']}  internal
       Append To List  ${cells_distname}  ${gsm_cell_dn}
    END
    Sort List  ${cells_distname}
    Log List  ${cells_distname}
    [Return]  ${cells_distname}

Create Dictionary With All Cells Distnames CELL_M And Runtime
    [Arguments]  ${connection}=${BTS_ID}
    ${all_cells_dict}  Get Cell List  connection=${connection}
    ${nr_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  nr
    ${lte_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  lte
    ${wcdma_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  wcdma
    ${gsm_cells_dict}  Get From Dictionary  ${all_cells_dict['cells']}  gsm
    ${cells_distnames}  Create Dictionary
    FOR  ${nr_cell}  IN  @{nr_cells_dict}
       ${nr_cell_dn}  Get From Dictionary  ${nr_cell['id']}  internal
       ${nr_cellm_dn}  Get From Dictionary  ${nr_cell['carrierList'][0]['id']}  internal
       ${nr_cellm_dn}  Fetch From Left  ${nr_cellm_dn}  /CHANNEL_GROUP
       Set To Dictionary  ${cells_distnames}  ${nr_cellm_dn}=${nr_cell_dn}
    END
    FOR  ${lte_cell}  IN  @{lte_cells_dict}
       ${lte_cell_dn}  Get From Dictionary  ${lte_cell['id']}  internal
       ${lte_cellm_dn}  Get From Dictionary  ${lte_cell['carrierList'][0]['id']}  internal
       ${lte_cellm_dn}  Fetch From Left  ${lte_cellm_dn}  /CHANNEL_GROUP
       Set To Dictionary  ${cells_distnames}  ${lte_cellm_dn}=${lte_cell_dn}
    END
    FOR  ${wcdma_cell}  IN  @{wcdma_cells_dict}
       ${wcdma_cell_dn}  Get From Dictionary  ${wcdma_cell['id']}  internal
       ${wcdma_cellm_dn}  Get From Dictionary  ${wcdma_cell['carrierList'][0]['id']}  internal
       ${wcdma_cellm_dn}  Fetch From Left  ${wcdma_cellm_dn}  /CHANNEL_GROUP
       Set To Dictionary  ${cells_distnames}  ${wcdma_cellm_dn}=${wcdma_cell_dn}
    END
    FOR  ${gsm_cell}  IN  @{gsm_cells_dict}
       ${gsm_cell_dn}  Get From Dictionary  ${gsm_cell['id']}  internal
       ${gsm_cell_carrier}  Get From Dictionary  ${gsm_cell}  carrierList
       _Create GSM TRXes  ${gsm_cell_carrier}  ${gsm_cell_dn}  ${cells_distnames}
    END
    Log Dictionary  ${cells_distnames}
    [Return]  ${cells_distnames}

_Create GSM TRXes
    [Arguments]  ${gsm_cell_carrier}  ${gsm_cell_dn}  ${cells_distnames}
    FOR  ${carrier}  IN  @{gsm_cell_carrier}
      ${gsm_cellm_dn}  Get From Dictionary  ${carrier['id']}  internal
      ${gsm_cellm_dn}  Fetch From Left  ${gsm_cellm_dn}  /CHANNEL_GROUP
      Set To Dictionary  ${cells_distnames}  ${gsm_cellm_dn}=${gsm_cell_dn}
    END

Check If Provided Cells Are onAir
    [Arguments]  ${cells}  ${connection}=${BTS_ID}
    FOR  ${cell}  IN  @{cells}
      ${class}=  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      ${onAir_st}=  Run Keyword And Return Status  admin.Assert  ${class[0]}  ${cell}  ${CELL_ONAIR_REGEX}  connection=${connection}
      Run Keyword If  not ${onAir_st}  Run Keyword And Continue On Failure  Fail  ${cell} is not onAir
    END

Check If Provided Cells Are Disable
    [Arguments]  ${cells}  ${connection}=${BTS_ID}
    FOR  ${cell}  IN  @{cells}
      ${class}=  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      admin.Assert  ${class[0]}  ${cell}  operationalState=regex"(?i)Disabled"  connection=${connection}
    END

Check If Provided Cells Are Degraded
    [Arguments]  ${cells}  ${connection}=${BTS_ID}
    FOR  ${cell}  IN  @{cells}
      ${class}=  Get Regexp Matches  ${cell}  (?i)LNCEL|NRCEL|WNCEL|GNCEL
      admin.Assert  ${class[0]}  ${cell}  availabilityStatus=regex"(?i)Degraded"  connection=${connection}
    END

Create Cablinks Dictionary With Affected Cells Lists
    [Documentation]
    ...  Create dict of Cablinks with cells lists:
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *OUTPUT*
    ...  {'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/HWTOP_R-1/CABLINK_R-1001':
    ...                                                     ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-1/GNCEL_R-1',
    ...                                                      '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1306/LNCEL_R-29601',
    ...                                                      '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-40801'],
    ...   '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/EQM_R-1/HWTOP_R-1/CABLINK_R-1002':
    ...                                                     ['/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/GNBTS_R-1/GNBCF_R-1/GNCEL_CONF_M-2/GNCEL_R-1',
    ...                                                      '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/LNBTS_R-1306/LNCEL_R-29604',
    ...                                                      '/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/WNBTS_R-1/WNCEL_R-40801']}
    [Arguments]  ${connection}=${BTS_ID}
    ${devices_list}=  Get Managed Objects  DEVICES_LIST  connection=${connection}
    ${affected_cablink_dict}  Create Dictionary
    FOR  ${distname}  IN  @{devices_list}
      ${cell_distname}  Get From Dictionary  ${distname}  distName
      ${cell_distname}  Fetch From Left  ${cell_distname}  /CHANNEL_GROUP
      ${deviceDN_list}  Get From Dictionary  ${distname['parameters']}  deviceDNs
      ${cablinkdns_list}  _Create Affected Cablink  ${deviceDN_list}
      _Adding to Dictionary  ${affected_cablink_dict}  ${cablinkdns_list}  ${cell_distname}
    END
    ${cells_distnames_dict}  Create Dictionary With All Cells Distnames CELL_M And Runtime  connection=${connection}
    ${cablink_dn_list}  Get Dictionary Keys  ${affected_cablink_dict}
    FOR  ${item}  IN  @{cablink_dn_list}
         ${cells_list}  Get From Dictionary  ${affected_cablink_dict}  ${item}
         ${cells_list}  Remove Duplicates  ${cells_list}
         ${cells_distnames_dict}  Create Dictionary With All Cells Distnames CELL_M And Runtime  connection=${connection}
         ${cells_runtime_list}  _Change CELL_M Distname To Runtime  ${cells_list}  ${cells_distnames_dict}  ${connection}
         ${cells_runtime_list}  Remove Duplicates  ${cells_runtime_list}
         Remove From Dictionary  ${affected_cablink_dict}  ${item}
         Log Dictionary  ${affected_cablink_dict}
         Set To Dictionary  ${affected_cablink_dict}  ${item}=@{cells_runtime_list}
         Log Dictionary  ${affected_cablink_dict}
      END
    Log List  ${cablink_dn_list}
    Log Dictionary  ${affected_cablink_dict}
    [Return]  &{affected_cablink_dict}

_Create Affected Cablink
    [Arguments]  ${deviceDN_list_arg}
    @{cablink_list}  Create List
    FOR  ${device}  IN  @{deviceDN_list_arg}
      ${cablink_dn}  Get From Dictionary  ${device}  deviceDN
      ${status}  Run Keyword And Return Status  Should Match Regexp  ${cablink_dn}  CABLINK
      Run Keyword If  ${status}  Append To List  ${cablink_list}  ${cablink_dn}
    END
    [Return]  @{cablink_list}

_Adding to Dictionary
      [Arguments]  ${affected_cablink_dict_arg}  ${cablinkdn_list_arg}  ${cell_distname_arg}
      @{list}  Create List
      FOR  ${item}  IN  @{cablinkdn_list_arg}
         ${status}  Run Keyword And Return Status  Dictionary Should Not Contain Key  ${affected_cablink_dict_arg}  ${item}
         Run Keyword If  ${status}  Run Keywords
         ...  Append To List  ${list}  ${cell_distname_arg}  AND
         ...  Set To Dictionary  ${affected_cablink_dict_arg}  ${item}=@{list}
         ...  ELSE  Append To List  ${affected_cablink_dict_arg['${item}']}  ${cell_distname_arg}
      END

_Change CELL_M Distname To Runtime
    [Arguments]  ${cells_list_arg}  ${cellm_runtime_dict}  ${connection}=${BTS_ID}
    @{cell_runtime_list}  Create List
    FOR  ${cell_m}  IN  @{cells_list_arg}
       ${cell_runtime}  Get From Dictionary  ${cellm_runtime_dict}  ${cell_m}
       Append To List  ${cell_runtime_list}  ${cell_runtime}
       ${inband_cell}  Check If Cell RuntimeDN Host Inband Cell  ${cell_runtime}  ${connection}
       Run Keyword If  '${inband_cell}'!='${EMPTY}'  Append To List  ${cell_runtime_list}  ${inband_cell}
    END
    [Return]  @{cell_runtime_list}

Check If Cell RuntimeDN Host Inband Cell
    [Arguments]  ${cell_dn}  ${connection}=${BTS_ID}
    ${lte_cell}  Run Keyword And Return Status  Should Match Regexp  ${cell_dn}  LNCEL
    Run Keyword If  not ${lte_cell}  Return From Keyword  ${EMPTY}
    ${cell_inf}  admin.Get Cell Specific Info  ${cell_dn}  connection=${connection}
    Run Keyword If  '${cell_inf['narrowbandIotMode']}'=='disabled' or '${cell_inf['narrowbandIotMode']}'=='standalone'
    ...  Return From Keyword  ${EMPTY}
    scf.Load Scf  file_path=${cfg['NODES']['${connection}']['scf_file_path']}
    ${lcrid}  scf.Get All Values From Scf By Pattern  p_name=nbIotLinkedCellId  dist_name=${cell_inf['id']['configuration']}
    ${bts_cells}  admin.Get Cell List  connection=${connection}
    FOR  ${lte_cell}  IN  @{bts_cells['cells']['lte']}
        ${linked_iot_lcrid}  scf.Get All Values From Scf By Pattern  p_name=lcrId  dist_name=${lte_cell['id']['configuration']}
        Exit For Loop If  '${linked_iot_lcrid[0]}'=='${lcrId[0]}'
    END
    [Return]  ${lte_cell['id']['internal']}

Get REF Object For Provided Distname
    [Arguments]  ${distname_object}  ${connection}=${BTS_ID}
    ${ref_objects}=  Get Managed Objects  REF  connection=${connection}
    FOR  ${ref_item}   IN  @{ref_objects}
      ${status}  Run Keyword And Return Status  Should Match Regexp  ${ref_item['distName']}  ${distname_object}
      Run Keyword If  ${status}  Set Test Variable  ${ref_object}  ${ref_item['parameters']['distName']}
    END
    [Return]  ${ref_object}

Get Port Primary Link Flapping
    [Arguments]  ${cablink_arg}   ${cablinks_os_port}
    ${port_primary}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${port_primary}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Primary"
      ...  Set Variable  ${cablinks_os_port['${cablink_item}']}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Primary"
    END
    [Return]  ${port_primary}

Get Port Secondary Link Flapping
    [Arguments]  ${cablink_arg}  ${cablinks_os_port}
    ${port_secondary}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${port_secondary}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
      ...  Set Variable  ${cablinks_os_port['${cablink_item}']}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
    END
    [Return]  ${port_secondary}

Get Primary Cablink Runtime Distname
    [Arguments]  ${cablink_arg}
    ${primary_cablink}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${primary_cablink}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Primary"
      ...  Set Variable  ${cablink_arg['${cablink_item}']['runtime']}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Primary"
    END
    [Return]  ${primary_cablink}

Get Secondary Cablink Runtime Distname
    [Arguments]  ${cablink_arg}
    ${secondary_cablink}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${secondary_cablink}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
      ...  Set Variable  ${cablink_arg['${cablink_item}']['runtime']}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
    END
    [Return]  ${secondary_cablink}

Get Primary Cablink Internal Distname
    [Arguments]  ${cablink_arg}
    ${primary_cablink}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${primary_cablink}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Primary"
      ...  Set Variable  ${cablink_arg['${cablink_item}']['internal']}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Primary"
    END
    [Return]  ${primary_cablink}

Get Secondary Cablink Internal Distname
    [Arguments]  ${cablink_arg}
    ${secondary_cablink}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${secondary_cablink}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
      ...  Set Variable  ${cablink_arg['${cablink_item}']['internal']}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
    END
    [Return]  ${secondary_cablink}

Get Secondary Cablink Config Object Name
    [Arguments]  ${cablink_arg}
    ${secondary_cablink}  Set Variable  ${EMPTY}
    FOR  ${cablink_item}  IN  @{cablink_arg}
      ${secondary_cablink}  Run Keyword If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
      ...  Set Variable  ${cablink_item}
      Exit For Loop If  "${cablink_arg['${cablink_item}']['linkmode']}"=="Secondary"
    END
    [Return]  ${secondary_cablink}

Checking Active Alarms
    [Arguments]    ${alias}=${BTS_ID}
    Clear Allowed Alarms List  connection=${alias}
    FOR    ${alarm}    IN    @{GLO_ADMIN_ALLOWED_ALARMS}
        Add Allowed Alarm     ${alarm}       connection=${alias}
    END
    ${alarm_unexpected_status}  Run Keyword And Return Status  Assert No Unexpected Active Alarms  connection=${alias}
    Run Keyword If  ${alarm_unexpected_status}  Log To Console  No Unexpected Active Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Log To Console  Unexpected Active Alarms Visible
    Run Keyword If  not ${alarm_unexpected_status}  Run Keyword And Continue On Failure  Fail  Unexpected Active Alarms Visible

Perform L3 Call For All Cells
    [Documentation]
    ...  Perform SiSo L3 Call for All Cells
    ...
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  *INPUT*
    ...  ${CELLS_YAML_PATH}  mandatory path for ue_config.yaml set as test variable in testsuite
    [Arguments]  ${logs_dir}=${cfg['test_logs_path']}  ${alias}=${cfg.primary_node_bts_id}
    Set Test Variable  ${LOGS_DIR}  ${logs_dir}/call
    ${nrcels}  admin.Get ids for all  NRCEL  connection=${alias}
    ${lncels}  admin.Get ids for all  LNCEL  search_for_iot_cells=${True}  connection=${alias}
    ${wncels}  admin.Get ids for all  WNCEL  connection=${alias}
    ${gncels}  admin.Get ids for all  GNCEL  connection=${alias}
    ${all_cells_dn_list}  Combine Lists  ${nrcels}  ${lncels}  ${wncels}  ${gncels}
    Log  \nL3 call started !!!  console=${TRUE}
    ${l3call_status}  Run Keyword And Return Status  SiSo L3 Call  ${all_cells_dn_list}
    Run Keyword If  ${l3call_status}  Log  L3 Call finish with success  console=${TRUE}
    Run Keyword If  not ${l3call_status}  Run Keyword And Continue On Failure  Fail  L3 Call finish with error !!!
    [Return]  ${l3call_status}

Perform L3 Call For Provided Cells
    [Arguments]  ${cells_dn_list}  ${logs_dir}=${cfg['test_logs_path']}
    [Documentation]
    ...    Description:
    ...    Perform SiSo L3 Call For Provided Cells
    ...
    ...    Input:
    ...    ${CELLS_YAML_PATH}  mandatory path for ue_config.yaml set as test variable in testsuite
    ...
    ...    Arguments:
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | Argument           | Man.  | Description                                                                                   |
    ...    +====================+=======+===============================================================================================+
    ...    | cells_dn_list      | Yes   | List of cells runtime distname                                                                |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...    | logs_dir           | No    | Log dir path e.g. ${cfg['test_logs_path']}                                                    |
    ...    +--------------------+-------+-----------------------------------------------------------------------------------------------+
    ...
    ...    Return:
    ...    +---------------------+------------------------------------------------------------------------------------------------------+
    ...    | Return Value        | Description                                                                                          |
    ...    +=====================+======================================================================================================+
    ...    | l3call_status       | True/False                                                                                           |
    ...    +---------------------+------------------------------------------------------------------------------------------------------+
    ...
    ...    Usage:
    ...    ${CELL_DN}  Create List  /MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/LNBTS_R-1031/LNCEL_R-2101
    ...    Perform L3 Call For Provided Cells  cells_dn_list=${CELL_DN}  logs_dir=${cfg['test_logs_path']}
    ...
    ...    Author: przemyslaw.kempa@nokia.com
    ...    Maintainer: przemyslaw.kempa@nokia.com
    Set Test Variable  ${LOGS_DIR}  ${logs_dir}/call
    Log  \nL3 call started !!!  console=${TRUE}
    ${l3call_status}  Run Keyword And Return Status  SiSo L3 Call  ${cells_dn_list}
    Run Keyword If  ${l3call_status}  Log To Console  L3 Call finish with success
    Run Keyword If  not ${l3call_status}  Run Keyword And Continue On Failure  Fail  L3 Call finish with error !!!
    [Return]  ${l3call_status}

Checking If availabilityStatus Change For Provided Cells In ims2
    [Arguments]  ${cells_distname_list}  ${ims2_log_path}
    &{status_cells_dict}  Create Dictionary
    Log  Checking If availabilityStatus Change For Provided Cells  console=${TRUE}
    FOR  ${cell}  IN  @{cells_distname_list}
        ${status}  ${msg}  Run Keyword And Ignore Error  Find Parameter Change  ${ims2_log_path}  ${cell}  availabilityStatus
        Run Keyword If  "${msg}"=="No change found in availabilityStatus"  Log  ${cell} remained unchanged  console=${TRUE}
        Run Keyword If  "${msg}"!="No change found in availabilityStatus"  Log  availabilityStatus of ${cell} changed  console=${TRUE}
        Set To Dictionary  ${status_cells_dict}  ${cell}=${status}
    END
    [Return]  ${status_cells_dict}

Find Velocity Hardware Name Using Serial Number
    [Arguments]  ${serial}  ${velocity_hw}
    FOR  ${hardware_item}  IN  @{velocity_hw}
      ${hardware_name}  Run Keyword If  "${velocity_hw['${hardware_item}']}"=="${serial}"  Set Variable  ${hardware_item}
      Exit For Loop If  "${velocity_hw['${hardware_item}']}"=="${serial}"
    END
    [Return]  ${hardware_name}

Find Velocity Connection
    [Arguments]  ${first_point}  ${second_point}  ${velocity_connection}
    FOR  ${connection}  IN  @{velocity_connection}
      ${connection_regex}  Remove String  ${connection}  _
      ${first_point_regex}  Remove String  ${first_point}  _
      ${second_point_regex}  Remove String  ${second_point}  _
      ${velocity_connection_regex}  Remove String  ${velocity_connection['${connection}']}  _
      ${status}  Evaluate  "${connection_regex}"=="${first_point_regex}" and "${velocity_connection_regex}"=="${second_point_regex}"
      ${status_inverted}  Evaluate  "${connection_regex}"=="${second_point_regex}" and "${velocity_connection_regex}"=="${first_point_regex}"
      ${connection_key}  ${connection_value}  Run Keyword If  ${status}  Set Variable  ${connection}  ${velocity_connection['${connection}']}
      ...  ELSE IF  ${status_inverted}  Set Variable  ${velocity_connection['${connection}']}  ${connection}
      Exit For Loop If  ${status} or ${status_inverted}
    END
    [Return]  ${connection_key}  ${connection_value}

Get PM Counter For Link Break
    [Arguments]  ${BTS_ID}  ${counter_id}  ${alias}=${cfg.primary_node_bts_id}
    [Documentation]
    ...  Description:
    ...  Return number of link break
    ...  M40015C10 - short link break
    ...  M40015C11 - long link break
    ...
    ...  AUTHOR:
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  OUTPUT:
    ...    {'CABINET-1': {'BBMOD-1': {'SFP-1': 0,
    ...                               'SFP-2': 0,
    ...                               'SFP-3': 0},
    ...                   'BBMOD-2': {'SFP-1': 0,
    ...                               'SFP-2': 0,
    ...                               'SFP-3': 0},
    ...                   'BBMOD-3': {'SFP-1': 4,
    ...                               'SFP-2': 3,
    ...                               'SFP-3': 0}}}
    ...
    ${api_short_counter}  Wait Until Keyword Succeeds  10min  30s  Get PM Counters  counter_ids=${counter_id}  connection=${alias}
    ${cabinet_list}  Get Dictionary Keys  ${api_short_counter['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']}
    &{cabinet_dict}  Create Dictionary
    FOR  ${cabinet}  IN  @{cabinet_list}
      ${hwmod_list}  Get Dictionary Keys  ${api_short_counter['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['${cabinet}']}
      ${hwmod_couter_dict}  _Get SFPs For PM Counter Link Break  ${cabinet}  ${hwmod_list}  ${api_short_counter}  ${counter_id}
      Set To Dictionary  ${cabinet_dict}  ${cabinet}=${hwmod_couter_dict}
    END
    Log    ${cabinet_dict}
    [Return]  ${cabinet_dict}

_Get SFPs For PM Counter Link Break
    [Arguments]  ${cabinet}  ${hwmod_list}  ${api_counter}  ${counter_id}
    &{hwmod_dict}  Create Dictionary
    FOR  ${hwmod}    IN    @{hwmod_list}
      ${sfp_list}  Get Dictionary Keys  ${api_counter['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['${cabinet}']['${hwmod}']}
      ${sfp_counter_dict}  _Get PM Counter Link Break For SFP  ${cabinet}  ${hwmod}  ${sfp_list}  ${api_counter}  ${counter_id}
      Set To Dictionary  ${hwmod_dict}  ${hwmod}=${sfp_counter_dict}
    END
    [Return]    ${hwmod_dict}

_Get PM Counter Link Break For SFP
  [Arguments]  ${cabinet}  ${hwmod}  ${sfp_list}  ${api_counter}  ${counter_id}
  &{sfp_dict}  Create Dictionary
  ${hwmod_counter}  Get From Dictionary  ${api_counter['BTS']['MRBTS-${BTS_ID}']['EQM-1']['APEQM-1']['${cabinet}']}  ${hwmod}
  FOR  ${sfp}    IN    @{sfp_list}
    ${hwmod_type}  Fetch From Left  ${hwmod}  -
    ${counter}  Get Dictionary Values   ${hwmod_counter['${sfp}']['LANE-1']['SBTS_SFP_${hwmod_type}_LANE']['${counter_id}']}
    ${linkbreak_number}  _Sum Linkbreak Counter  ${counter}
    Set To Dictionary  ${sfp_dict}  ${sfp}=${linkbreak_number}
  END
  [Return]  ${sfp_dict}

_Sum Linkbreak Counter
    [Arguments]  ${counter}
    ${linkbreak_number}  Set Variable  0
    FOR  ${item}  IN  @{counter}
      ${linkbreak_number}  Evaluate    ${linkbreak_number} + ${item}
    END
    [Return]  ${linkbreak_number}

Get Destination Sfp Distname For Cablink
    [Arguments]  ${cablink_dn}  ${connection}=${BTS_ID}
    ${sfp_links}  Get Sfp Links  connection=${connection}
    ${sfp_distname}  Set Variable  ${EMPTY}
    FOR  ${sfp}  IN  @{sfp_links['connected']}
      ${sfp_distname}  Run Keyword If  "${sfp['link']['distName']}"=="${cablink_dn}"  Set Variable  ${sfp['destination']}
      Exit For Loop If  "${sfp['link']['distName']}"=="${cablink_dn}"
    END
    [Return]  ${sfp_distname}

Checking Expected Alarms In Syslog After Link Break
    [Arguments]  ${tested_cablink_dict}  ${fault}  ${alias}=${BTS_ID}_primary
    [Documentation]
    ...  Description:
    ...  Checking if fault (e.g. 4721, 4760) in syslog is active and inactive
    ...
    ...
    ...  AUTHOR:
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  INPUT :
    ...  fault e.g. 4721, 4760
    ...  tested_cablink_dict
    ...  {'CABLINK-4': {'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/HWTOP_R-1/CABLINK_R-1001',
    ...                 'linkmode': 'Primary',
    ...                 'rmod': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1',
    ...                 'runtime': 'MRBTS-1031/EQM_R-4/HWTOP_R-1/CABLINK_R-1001'},
    ...   'CABLINK-5': {'internal': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/HWTOP_R-1/CABLINK_R-1002',
    ...                 'linkmode': 'Secondary',
    ...                 'rmod': '/MRBTS-1/RAT-1/RUNTIME_VIEW-4/MRBTS_R-4/EQM_R-4/APEQM_R-1/RMOD_R-1',
    ...                 'runtime': 'MRBTS-1031/EQM_R-4/HWTOP_R-1/CABLINK_R-1002'}}
    ${break_syslog_start}  Run Keyword And Return Status  taf_syslog.Message should exist in syslog file
    ...  regexp=frameSyncState: FALSE  alias=${alias}
    Run Keyword If  ${break_syslog_start}  Log  Link break started visible in syslog  console=${TRUE}
    ${break_syslog_stop}  Run Keyword And Return Status  taf_syslog.Message should exist in syslog file  regexp=frameSyncState: TRUE  alias=${alias}
    Run Keyword If  ${break_syslog_stop}  Log  Link break finished visible in syslog  console=${TRUE}
    ${break_abia_syslog_start}  Run Keyword And Return Status  taf_syslog.Message should exist in syslog file
    ...  regexp=ESfpStatusType_RxLos is now active  alias=${alias}
    Run Keyword If  ${break_abia_syslog_start}  Log  Link break started visible in syslog  console=${TRUE}
    ${break_abia_syslog_stop}  Run Keyword And Return Status  taf_syslog.Message should exist in syslog file
    ...  regexp=ESfpStatusType_RxLos is now inactive  alias=${alias}
    Run Keyword If  ${break_abia_syslog_stop}  Log  Link break finished visible in syslog  console=${TRUE}
    ${tested_cablink_list}  Get Dictionary Keys  ${tested_cablink_dict}
    ${cablinks_number}  Get Length  ${tested_cablink_list}
    FOR  ${cablink}  IN  @{tested_cablink_list}
      ${linkmode}  Get From Dictionary  ${tested_cablink_dict['${cablink}']}  linkmode
      ${cablink_internal_dn}  Get From Dictionary  ${tested_cablink_dict['${cablink}']}  internal
      ${ref_object_for_cablink}  Get REF Object For Provided Distname  ${cablink_internal_dn}
      ${expected_fault_syslog_active}  Run Keyword And Return Status
      ...  taf_syslog.Message should exist in syslog file  regexp=\\[Detector ${fault}/1 ${ref_object_for_cablink}\\] active  alias=${alias}
      Run Keyword If  ${expected_fault_syslog_active}
      ...  Log  Fault ${fault} for ${linkmode} link ${ref_object_for_cablink} active in syslog after break  console=${TRUE}
      Run Keyword If  not ${expected_fault_syslog_active}
      ...  Log  Fault ${fault} for ${linkmode} link ${ref_object_for_cablink} NOT appeared in syslog after break
      Run Keyword If  not ${expected_fault_syslog_active} and "${linkmode}"=="Primary"  Run Keyword And Continue On Failure  FAIL
      ...  Fault ${fault} for ${linkmode} link ${ref_object_for_cablink} NOT appeared in syslog after break
      ${expected_fault_syslog_inactive}  Run Keyword And Return Status
      ...  taf_syslog.Message should exist in syslog file  regexp=\\[Detector ${fault}/1 ${ref_object_for_cablink}\\] inactive  alias=${alias}
      Run Keyword If  ${expected_fault_syslog_inactive}  Run Keyword And Continue On Failure
      ...  Log  Fault ${fault} for ${linkmode} link ${ref_object_for_cablink} inactive in syslog after break  console=${TRUE}
      ${secondary_status}  Run Keyword And Return Status  Should Be True
      ...  not ${expected_fault_syslog_inactive} and "${linkmode}"=="Secondary" and ${cablinks_number}==1
      Run Keyword If  not ${expected_fault_syslog_inactive} and "${linkmode}"=="Primary" or ${secondary_status}  Run Keyword And Continue On Failure
      ...  FAIL  Fault ${fault} for primary link ${ref_object_for_cablink} NOT disappeared in syslog after break
    END

Get SFP Runtime Distname For Tested HW Port
    [Arguments]  ${hwmod_list}  ${firstpoint}
    [Documentation]
    ...  Description:
    ...  For provided firstEndPointId of cablink return runtime distname of sfp
    ...
    ...
    ...  AUTHOR:
    ...  przemyslaw.kempa@nokia.com
    ...
    ...  INPUT :
    ...  e.g.
    ...  firstpoint = MRBTS-1052/EQM-1/APEQM-1/CABINET-1/BBMOD-1/RF1
    ...  hwmod_list = basebandModules or systemModules from admin.Get Bts Info
    ...
    ...  OUTPUT :
    ...  sfp_runtime = MRBTS-1052/EQM_R-4/APEQM_R-1/CABINET_R-1/BBMOD_R-1/SFP_R-1
    ...  tested_hwmod = MRBTS-1052/EQM-1/APEQM-1/CABINET-1/BBMOD-1
    ${tested_hwmod}  ${tested_label}  Split String From Right  ${firstpoint}  /  1
    FOR  ${hwmod}  IN    @{hwmod_list}
      ${ports_list}  Run Keyword If  "${hwmod['id']['configuration']}"=="${tested_hwmod}"  Get From Dictionary	${hwmod}  ports
      ${sfp_runtime}  Run Keyword If  "${hwmod['id']['configuration']}"=="${tested_hwmod}"
      ...  _Find SFP Runtime Distname  ${ports_list}  ${tested_label}
      Exit For Loop If  "${hwmod['id']['configuration']}"=="${tested_hwmod}"
    END
    [Return]  ${sfp_runtime}  ${tested_hwmod}

_Find SFP Runtime Distname
    [Arguments]  ${ports_list}  ${label}
    FOR  ${port}  IN  @{ports_list}
      ${sfp_runtime}  Run Keyword If  "${port['label']}"=="${label}"  Get From Dictionary	${port['id']}  runtime
      Exit For Loop If  "${port['label']}"=="${label}"
    END
    [Return]  ${sfp_runtime}

Change Optical Connection To Longer For Link Break With Changed Link Length
    [Arguments]    ${link_port_in}  ${long_fiber}  ${switch_ip}=${cfg['IP_SWITCH']}
    [Documentation]
    ...  Description:
    ...  Change the optical connection to a longer link for link break with changed link length.
    ...  This keyword sets up the optical switch, retrieves the current optical switch channels,
    ...  and changes the optical connection to a longer one for the specified link port.
    ...  It removes the existing connections and sets new connections for the longer link.
    ...
    ...  Arguments:
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | Parameter                  | Man.  | Default               | Description                                                    |
    ...  +============================+=======+=======================+================================================================+
    ...  | link_port_in               | Yes   |                       | The input port for the link                                    |
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | switch_ip                  | No    | ${cfg['IP_SWITCH']}   | The IP of the optical switch must be provided in the Test Suite|
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...
    ...  Return:
    ...  +--------------------+---------------------------------------------+
    ...  | Parameter          | Description                                 |
    ...  +====================+=============================================+
    ...  | all_calient_ports  | All Calient ports configuration             |
    ...  +--------------------+---------------------------------------------+
    ...  | link_port_out      | The output port for the tested link         |
    ...  +--------------------+---------------------------------------------+
    ...  | long_port_in       | The input port for the long link            |
    ...  +--------------------+---------------------------------------------+
    ...  | long_port_out      | The output port for the long link           |
    ...  +--------------------+---------------------------------------------+
    ...
    ...  Usage:
    ...  Change Optical Connection To Longer For Link Break With Changed Link Length
    ...  ...  link_port_in=x.x.x  switch_ip=xxx.xxx.xxx.xxx
    ...
    ...  Author:  izabela.wencel@nokia.com
    ...  Maintainer:  izabela.wencel@nokia.com
    ...
    Optical Switch Setup  switch_ip=${switch_ip}
    ${all_calient_ports}  Get Optical Switch Channels
    ${link_port_out}  Get From Dictionary  ${all_calient_ports}  ${link_port_in}
    ${long_port_in}  ${long_port_out}  Split String  ${long_fiber}  -
    &{new_connections_long_BB}  Create Dictionary  in=${link_port_in}  out=${long_port_out}  dir=uni
    &{new_connections_long_RF}  Create Dictionary  in=${long_port_in}  out=${link_port_out}  dir=uni
    ${links_port_in_list}  Create List  ${link_port_in}
    Remove Optical Switch connections  in_ports=${links_port_in_list}
    Set Optical Switch Channel  settings=${new_connections_long_BB}
    Set Optical Switch Channel  settings=${new_connections_long_RF}
    [Return]  ${all_calient_ports}  ${link_port_out}  ${long_port_in}  ${long_port_out}
    [Teardown]  Teardown Optical Switch

Change Optical Connection To Shorter For Link Break With Changed Link Length
    [Arguments]  ${long_link_break_duration}  ${link_port_in}  ${long_port_in}  ${all_calient_ports}  ${switch_ip}=${cfg['IP_SWITCH']}
    [Documentation]
    ...  Description:
    ...  Change the optical connection to a shorter link for link break with changed link length.
    ...  This keyword sets up the optical switch, retrieves the current optical switch channels,
    ...  and changes the optical connection to a shorter one for the specified link port.
    ...  It removes the existing connections and sets new connections for the shorter link.
    ...
    ...  Arguments:
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | Parameter                  | Man.  | Default               | Description                                                    |
    ...  +============================+=======+=======================+================================================================+
    ...  | long_link_break_duration   | Yes   |                       | Duration of the long link break in milliseconds                |
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | link_port_in               | Yes   |                       | The input port for the link                                    |
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | long_port_in               | Yes   |                       | The input port for the long link                               |
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | all_calient_ports          | Yes   |                       | Initial setting of all calient ports configuration             |
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  | switch_ip                  | Yes   | ${cfg['IP_SWITCH']}   | The IP of the optical switch must be provided in the Test Suite|
    ...  +----------------------------+-------+-----------------------+----------------------------------------------------------------+
    ...  &\{all_calient_ports\} can't be dynamic from current connections dictionary, because at this stage long link is visible.
    ...  Channels must be taken from the first dictionary.
    ...
    ...  Return:
    ...  None
    ...
    ...  Usage:
    ...  Change Optical Connection To Shorter For Link Break With Changed Link Length
    ...  ...  long_link_break_duration=5000
    ...  ...  link_port_in=x.x.x
    ...  ...  long_port_in=y.y.y
    ...  ...  all_calient_ports=${all_calient_ports}
    ...  ...  switch_ip=xxx.xxx.xxx.xxx
    ...
    ...  Author:  izabela.wencel@nokia.com
    ...  Maintainer:  izabela.wencel@nokia.com
    ...
    Optical Switch Setup  switch_ip=${switch_ip}
    ${link_port_out}  Get From Dictionary  ${all_calient_ports}  ${link_port_in}
    &{new_connections_basic}  Create Dictionary  in=${link_port_in}  out=${link_port_out}  dir=uni
    ${in_port_list}  Create List  ${link_port_in}  ${long_port_in}
    Remove Optical Switch connections  in_ports=${in_port_list}
    Run Keyword If  ${long_link_break_duration}>0  Run Keyword And Continue On Failure
    ...  Checking Expected Alarms For Long Secondary Link Break With Changed Time Delay
    Sleep  ${long_link_break_duration}ms
    Set Optical Switch Channel  settings=${new_connections_basic}
    [Teardown]  Teardown Optical Switch
