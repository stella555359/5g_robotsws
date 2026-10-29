*** Settings ***
Documentation  Maintainers: @I_SRAN_PROD_SISO_WRO_CRTDEV_GMS
...  Library with keywords responsible for control devices via PDU

Library  Collections
Library  String
Library  taf.hw.pdu  WITH NAME  pdu
Library  ./../Python/helpers.py
Library  ./../../../resources/siso_logger.py


*** Variables ***
&{CUSTOM_PDU_CONFIG}


*** Keywords ***
PDU Check Port State By Serial Number
  [Arguments]  ${serial_number}
  [Documentation]
  ...  Description:
  ...  Check state port on PDU with provided serial number
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number          | yes  | serial number of object                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${port}=  Prepare Setup PDU
  ...  serial_number=${serial_number}
  IF  not ${port}
    Logging With Timestamp  message=There is no PDU information for ${serial_number} device!  style=ERROR
    Fail
  END
  ${pdu_port_state}=  pdu.Get Port Status
  ...  port=${port}
  ...  pdu_device=pdu
  Logging With Timestamp  ${\n} PDU Port number ${port} for ${serial_number} state is: ${pdu_port_state}
  [Return]  ${pdu_port_state}
  [Teardown]  Run Keyword If    ${port}
  ...  pdu.Teardown Pdu  pdu_device=pdu

PDU Power ON Port By Serial Number
  [Arguments]  ${serial_number}
  [Documentation]
  ...  Description:
  ...  Switch On port on PDU with provided serial number
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number          | yes  | serial number of object                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${port}=  Prepare Setup PDU
  ...  serial_number=${serial_number}
  IF  not ${port}
    Logging With Timestamp  message=There is no PDU information for ${serial_number} device!  style=ERROR
    Fail
  END
  ${pdu_port_state_pre}=  pdu.Get Port Status
  ...  port=${port}
  ...  pdu_device=pdu
  IF  "${pdu_port_state_pre}"=="on"
    Logging With Timestamp  message=PDU Port no:${port} for ${serial_number} is already ON, skipping power on operation.
    Return From Keyword
  ELSE
    Logging With Timestamp  message=PDU Port no:${port} for ${serial_number} will be switched ON.
    pdu.Power On
    ...  port=${port}
    ...  pdu_device=pdu
  END
  Logging With Timestamp  ${\n} PDU Port no:${port}  for ${serial_number} was switched ON.
  [Teardown]  Run Keyword If    ${port}
  ...  pdu.Teardown Pdu  pdu_device=pdu

PDU Power Off Port By Serial Number
  [Arguments]  ${serial_number}
  [Documentation]
  ...  Description:
  ...  Switch OFF port on PDU with provided serial number
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number          | yes  | serial number of object                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${port}=  Prepare Setup PDU
  ...  serial_number=${serial_number}
  IF  not ${port}
    Logging With Timestamp  message=There is no PDU information for ${serial_number} device!  style=ERROR
    Fail
  END
  ${pdu_port_state_pre}=  pdu.Get Port Status
  ...  port=${port}
  ...  pdu_device=pdu
  IF  "${pdu_port_state_pre}"=="off"
    Logging With Timestamp  message=PDU Port no:${port} for ${serial_number} is already OFF, skipping power off operation.
    Return From Keyword
  ELSE
    Logging With Timestamp  message=PDU Port no:${port} for ${serial_number} will be switched OFF.
    pdu.Power Off
    ...  port=${port}
    ...  pdu_device=pdu
  END
  Logging With Timestamp  ${\n} PDU Port no:${port} for ${serial_number} was switched OFF.
  [Teardown]  Run Keyword If    ${port}
  ...  pdu.Teardown Pdu  pdu_device=pdu

PDU Reset Port By Serial Number
  [Arguments]  ${serial_number}  ${time_interval}=20
  [Documentation]
  ...  Description:
  ...  Reset port on PDU with provided serial number
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number          | yes  | serial number of object                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...  | time_interval          | no   | time between power off and power on                                        |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${port}=  Prepare Setup PDU
  ...  serial_number=${serial_number}
  IF  not ${port}
    Logging With Timestamp  message=There is no PDU information for ${serial_number} device!  style=ERROR
    Fail
  END
  ${ports}=  Create List  ${${port}}
  ${pdu_port_state}=  pdu.Reset Ports
  ...  ports=${ports}
  ...  time_interval=${time_interval}
  ...  pdu_device=pdu
  ${pdu_port_state}=  pdu.Get Port Status
  ...  port=${port}
  ...  pdu_device=pdu
  Logging With Timestamp  ${\n} PDU Port no:${port} for ${serial_number} state is: ${pdu_port_state}, was reset with time interval: ${time_interval}.
  [Teardown]  Run Keyword If    ${port}  pdu.Teardown Pdu  pdu_device=pdu

PDU Start Power Reset On Node
  [Arguments]  ${bts_id}
  [Documentation]  KW performs power reset on BTS. SMODs, RMODs, ASIRMODs, FHSes are resetted
  ...  +====================+=======+================================================================================+
  ...  | Argument           | Man.  | Description                                                                    |
  ...  +====================+=======+================================================================================+
  ...  | bts_id             | Yes   | current bts id                                                                 |
  ...  +--------------------+-------+--------------------------------------------------------------------------------+

  Logging With Timestamp
  ...  message=Power Reset on bts=${bts_id} started
  PDU Reset Device Lists  ${cfg.NODES['${bts_id}']['scf_hw_sm_list']}
  PDU Reset Device Lists  ${cfg.NODES['${bts_id}']['scf_hw_fr_list']}
  PDU Reset Device Lists  ${cfg.NODES['${bts_id}']['scf_hw_asir_list']}
  PDU Reset Device Lists  ${cfg.NODES['${bts_id}']['scf_hw_fhs_list']}
  Logging With Timestamp
  ...  message=Power Reset on bts ${bts_id} finished

PDU Switch ON Device Lists
  [Arguments]  ${serial_number_list}
  [Documentation]
  ...  Description:
  ...  Switch on list of devices on PDU with provided serial numbers
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number_list     | yes  | serial numbers of object                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Device list will be switch on: ${serial_number_list}
  FOR  ${device}  IN  @{serial_number_list}
    PDU Power ON Port By Serial Number  ${device}
  END

PDU Switch OFF Device Lists
  [Arguments]  ${serial_number_list}
  [Documentation]
  ...  Description:
  ...  Switch off list of devices on PDU with provided serial numbers
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number_list     | yes  | serial numbers of object                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Device list will be switch off: ${serial_number_list}
  FOR  ${device}  IN  @{serial_number_list}
    PDU Power Off Port By Serial Number  ${device}
  END

PDU Reset Device Lists
  [Arguments]  ${serial_number_list}
  [Documentation]
  ...  Description:
  ...  Reset list of devices on PDU with provided serial numbers
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number_list     | yes  | serial numbers of object                                                   |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  Logging With Timestamp
  ...  message=Device list will be reset: ${serial_number_list}
  FOR  ${device}  IN  @{serial_number_list}
    PDU Reset Port By Serial Number  ${device}
  END

Prepare Setup PDU
  [Arguments]  ${serial_number}
  [Documentation]
  ...  Description:
  ...  Setup of PDU device library instance.
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number          | yes  | serial number of object                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com
  ${tl_status}=  Run Keyword And Return Status
  ...  Variable Should Exist  ${TL}
  IF  ${tl_status}
    ${object}=  Find Init Object Using Attribute Value  ${TL}  ${serial_number}
  ELSE
    ${object}=  Set Variable  ${None}
  END
  ${object_status}=  Run Keyword And Return Status
  ...  Should Be True  ${object}
  IF  not ${object_status}
    ${model}  ${version}  ${addr}  ${port}=  Create PDU Description  ${serial_number}
  ELSE
    ${model}  ${version}  ${addr}  ${port}=  Set Variable  ${None}  ${None}  ${None}  ${None}
  END
  ${pdu_port_status}=  Run Keyword And Ignore Error    Should Be True    ${object.pdu_port}
  ${port}=  Set Variable If  not ${object_status}  ${port}
  ...  '${pdu_port_status[0]}'=='FAIL'  ${None}
  ...  ${object.pdu_port.port_no}
  IF  not ${object_status}
    IF  "${version}"=="${EMPTY}"
    ${version}=  Set Variable    default
    ELSE
    ${version}=  Set Variable    ${version}
    END
  END
  Return From Keyword If  not ${port}  ${None}
  IF  not ${object_status}
    pdu.Setup Pdu  model=${model}  version=${version}  host=${addr}  alias=pdu
  ELSE
    pdu.Setup Pdu  model=${object.pdu_port.pdu}  alias=pdu
  END
  [Return]  ${port}

Create PDU Description
  [Arguments]  ${serial_number}
  [Documentation]
  ...  Description:
  ...  Create description used by PDU library in case there is manual information provided.
  ...  Standard approach is to place PDU description in init file, in case there is no such description special SUITE level parameter is provided
  ...  Example of such parameter - dictionary type :
  ...  &{CUSTOM_PDU_CONFIG}=
  ...  L123456=Gude,8220-1,10.44.11.11,1
  ...  L123456=ATEN,,10.44.11.11,1
  ...  there should be serial number of device as a key and four arguments provided as tuple - model, version, IP address, port number
  ...  in case version is not needed, empty value must be put, eg:  ,,
  ...
  ...  Arguments:
  ...  +========================+======+============================================================================+
  ...  | Argument               | Man. | Description                                                                |
  ...  +========================+======+============================================================================+
  ...  | serial_number          | yes  | serial number of object                                                    |
  ...  +------------------------+------+----------------------------------------------------------------------------+
  ...
  ...  Author: piotr.korczynski@nokia.com
  ...  Maintainer: piotr.korczynski@nokia.com

  ${status}=  Run Keyword And Return Status
  ...  Dictionary Should Contain Key  ${CUSTOM_PDU_CONFIG}  ${serial_number}
  IF  not ${status}
    Return From Keyword
  END
  ${object_pdu}=  Get From Dictionary  ${CUSTOM_PDU_CONFIG}  ${serial_number}
  ${model}  ${version}  ${addr}  ${port}=  Split String  ${object_pdu}  ,
  [Return]  ${model}  ${version}  ${addr}  ${port}
