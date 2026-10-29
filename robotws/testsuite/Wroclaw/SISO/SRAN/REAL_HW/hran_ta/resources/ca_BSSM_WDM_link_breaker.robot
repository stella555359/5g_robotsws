*** Settings ***

Documentation  Maintainer: mateusz.kawka@nokia.com

Library         Telnet
Library         taf.hw.optical_switch    WITH NAME    optical_switch

*** Keywords ***

Setup LinkBreaker
    [Documentation]
    ...  Prepare Telnet connection to LinkBreaker Server and check server status
    ...
    ...  **Input Parameters:**
    ...
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Input Parameters        | Man.   | Description                               |
    ...    +====================+========+================================================+
    ...    | link_breaker_ip_address | Yes    |  LinkBreaker server IP address            |
    ...    +------------------+--------+--------------------------------------------------+
    ...    | link_breaker_ip_port    | Yes    |  LinkBreaker server IP port               |
    ...    +-------------------------+--------+-------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Setup LinkBreaker  10.44.131.183  8888

    [Arguments]  ${link_breaker_ip_address}  ${link_breaker_ip_port}
    Log To Console  Setup LinkBreaker
    Telnet.Open Connection  ${link_breaker_ip_address}  port=${link_breaker_ip_port}
    Telnet.Set Timeout  10 seconds
    Telnet.Read Until  ready
    Telnet.Write  ready?
    Telnet.Read Until  ready
    Log To Console  Linkbreaker ready.  console=${True}

Break Optical Link
    [Documentation]
    ...  Prepare break of optical link
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Break Optical Link

    Log To Console  Perform link break
    Telnet.Write  disconnect
    Telnet.Read Until  disconnected
    Log To Console  Link break performed.  console=${True}

Restore Optical Link
    [Documentation]
    ...  Connect optical link
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...      Restore Optical Link
    Log To Console  Connect link
    Telnet.Write  connect
    Telnet.Read Until  connected
    Log To Console  Link connected.  console=${True}

Perform Optical Link Break For ${break_time} s
    [Documentation]
    ...  Prepare optical link break for defined time
    ...
    ...  **Input Parameters:**
    ...
    ...    +-------------------------+--------+-------------------------------------------+
    ...    | Input Parameters        | Man.   | Description                               |
    ...    +=========================+========+===========================================+
    ...    | break_time              | Yes    |  link break time                          |
    ...    +-------------------------+--------+-------------------------------------------+
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...     Perform Optical Link Break For 10 s

    Log To Console  Perform link break for ${break_time}s
    Telnet.Write  reconnect=${break_time}
    Telnet.Read Until  disconnected
    Sleep  ${break_time}
    Telnet.Write  status
    Telnet.Read Until  connected
    Log To Console  Link break for ${break_time}s performed.  console=${True}

Teardown LinkBreaker
    [Documentation]
    ...   Connect disconnected link
    ...   Close telnet connection.
    ...
    ...   **Example of simple usage:**
    ...
    ...      .. code-block:: robotframework
    ...     Teardown LinkBreaker
    Telnet.Write  connect
    Telnet.Read Until  connected
    Telnet.Write  bye

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
    [Arguments]  ${switch_ip}  ${switch_username}=tl1user  ${port}=80  ${switch_vendor}=Calient  ${switch_model}=S320
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
    ...  | alias                | No    | default   | alias of configured optical switch    |
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
    ...  | flap_ports        | Yes   |           | port e.g. 4.4.3 or 4.4.1&4.4.3              |
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

    [Arguments]  ${connection}=alias_${BTS_ID}
    ${devices_list}  admin.Get Managed Objects  DEVICES_LIST  connection=${connection}
    ${affected_cablink_dict}  Create Dictionary
    FOR  ${distname}  IN  @{devices_list}
      ${cell_distname}  Get From Dictionary  ${distname}  distName
      ${cell_distname}  Fetch From Left  ${cell_distname}  /CHANNEL_GROUP
      ${deviceDN_list}  Get From Dictionary  ${distname['parameters']}  deviceDNs
      ${cablinkdn_list}  _Create Affected Cablink  ${deviceDN_list}
      _Adding to Dictionary  ${affected_cablink_dict}  ${cablinkdn_list}  ${cell_distname}
    END
    ${cells_distnames_dict}  Create Dictionary With All Cells Distnames CELL_M And Runtime  connection=${connection}
    ${cablink_dn_list}  Get Dictionary Keys  ${affected_cablink_dict}
    FOR  ${item}  IN  @{cablink_dn_list}
         ${cells_list}  Get From Dictionary  ${affected_cablink_dict}  ${item}
         ${cells_list}  Remove Duplicates  ${cells_list}
         ${cells_distnames_dict}  Create Dictionary With All Cells Distnames CELL_M And Runtime  connection=${connection}
         ${cells_runtime_list}  _Change CELL_M Distname To Runtime  ${cells_list}  ${cells_distnames_dict}
         ${cells_runtime_list}  Remove Duplicates  ${cells_runtime_list}
         Remove From Dictionary  ${affected_cablink_dict}  ${item}
         Log Dictionary  ${affected_cablink_dict}
         Set To Dictionary  ${affected_cablink_dict}  ${item}=@{cells_runtime_list}
         Log Dictionary  ${affected_cablink_dict}
      END
    Log List  ${cablink_dn_list}
    Log Dictionary  ${affected_cablink_dict}
    [Return]  &{affected_cablink_dict}

Create Dictionary With All Cells Distnames CELL_M And Runtime
    [Documentation]
    ...  *AUTHOR*
    ...  przemyslaw.kempa@nokia.com

    [Arguments]  ${connection}=alias_${BTS_ID}
    ${all_cells_dict}  admin.Get Cell List  connection=${connection}
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

_Change CELL_M Distname To Runtime
    [Arguments]  ${cells_list_arg}  ${cellm_runtime_dict}
    @{cell_runtime_list}  Create List
    FOR  ${cell_m}  IN  @{cells_list_arg}
       ${cell_runtime}  Get From Dictionary  ${cellm_runtime_dict}  ${cell_m}
       Append To List  ${cell_runtime_list}  ${cell_runtime}
    END
    [Return]  @{cell_runtime_list}

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

_Create GSM TRXes
    [Arguments]  ${gsm_cell_carrier}  ${gsm_cell_dn}  ${cells_distnames}
    FOR  ${carrier}  IN  @{gsm_cell_carrier}
      ${gsm_cellm_dn}  Get From Dictionary  ${carrier['id']}  internal
      ${gsm_cellm_dn}  Fetch From Left  ${gsm_cellm_dn}  /CHANNEL_GROUP
      Set To Dictionary  ${cells_distnames}  ${gsm_cellm_dn}=${gsm_cell_dn}
    END
