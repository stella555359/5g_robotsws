*** Settings ***
Library  taf.hw.pdu

Documentation  This suite contains KWs used by some TCs and resources.


*** Variables ***
@{SUPPORTED_PDU}  APC  ATEN  BBOX  DCS  EPC  MOXA  PKC  SWH  FAC  BBOXPSE  FPFH


*** Keywords ***
Pdu BTS Interface Off
    [Documentation]  Turn off selected interface.
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...  |  timeout     | No   |  Maximum number of seconds to wait for pdu response.  |
    ...
    ...  *EXAMPLE*
    ...  |  Pdu BTS Interface Off  |  SMOD_1234567  |
    [Arguments]  ${if_name}  ${timeout}=10

    ${pdu_device}  _Init Pdu  ${if_name}  ${timeout}
    ${outlet}  _Pdu Get Outlet  ${if_name}
    ${contactor}  _Pdu Get Contactor Type  ${if_name}
    Run Keyword If  '${contactor}' == 'NORMALLY_OPEN'
    ...  Power Off  ${outlet}  pdu_device=${pdu_device}
    ...  ELSE IF  '${contactor}' == 'NORMALLY_OPENED'
    ...  Power Off  ${outlet}  pdu_device=${pdu_device}
    ...  ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'
    ...  Power On  ${outlet}  pdu_device=${pdu_device}

    [Teardown]  Run Keyword And Ignore Error
    ...  Teardown Pdu  pdu_device=${pdu_device}


Pdu BTS Interface On
    [Documentation]  Turn on selected interface.
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...  |  timeout     | No   |  Maximum number of seconds to wait for pdu response.  |
    ...
    ...  *EXAMPLE*
    ...  |  Pdu BTS Interface On  |  SMOD_1234567  |
    [Arguments]  ${if_name}  ${timeout}=10

    ${pdu_device}  _Init Pdu  ${if_name}  ${timeout}
    ${outlet}  _Pdu Get Outlet  ${if_name}
    ${contactor}  _Pdu Get Contactor Type  ${if_name}
    Run Keyword If  '${contactor}' == 'NORMALLY_OPEN'
    ...  Power On  ${outlet}  pdu_device=${pdu_device}
    ...  ELSE IF  '${contactor}' == 'NORMALLY_OPENED'
    ...  Power On  ${outlet}  pdu_device=${pdu_device}
    ...  ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'
    ...  Power Off  ${outlet}  pdu_device=${pdu_device}

    [Teardown]  Run Keyword And Ignore Error
    ...  Teardown Pdu  pdu_device=${pdu_device}


Pdu BTS Interface Get Status
    [Documentation]  Get status of selected interface.
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...  |  timeout     | No   |  Maximum number of seconds to wait for expected pdu status.  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description  |
    ...  |  status      |  Pdu output state (on/off).  |
    ...
    ...  *EXAMPLE*
    ...  |  ${smod_status}  |  Pdu BTS Interface Get Status  |  SMOD_1234567  |
    [Arguments]  ${if_name}  ${timeout}=10

    ${pdu_device}  _Init Pdu  ${if_name}  ${timeout}
    ${outlet}  _Pdu Get Outlet  ${if_name}
    ${contactor}  _Pdu Get Contactor Type  ${if_name}
    ${status}  Get Port Status  port=${outlet}  pdu_device=${pdu_device}
    Run Keyword If  '${contactor}' == 'NORMALLY_OPEN'
    ...  Return From Keyword  ${status}
    ...  ELSE IF  '${contactor}' == 'NORMALLY_OPENED'
    ...  Return From Keyword  ${status}
    ...  ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'
    ...  Run Keyword And Return
    ...  _Invert Status  ${status}

    [Teardown]  Run Keyword And Ignore Error
    ...  Teardown Pdu  pdu_device=${pdu_device}


Change Power Outlets State
    [Documentation]
    ...  Turn chosen outlet(s) on or off.
    ...  |  Parameters  | Man. |  Description  |
    ...  |  Unit IDs     | Yes  |  A list with module names as defined in interfaces.yaml
    ...   without any spaces  |
    ...  |  Desired state     | Yes   |  ${True} for On, ${False} for Off  |
    ...
    ...  TC will fail if given module is not found in interfaces.yaml
    ...
    ...  *EXAMPLE*
    ...  Change power outlets state  |   ${SMOD_L1234567890, RMOD_L1163607864}  |  ${True}
    [Arguments]  ${unit_ids}  ${desired_state}

    ${unit_list_not_empty_status}  Run Keyword And Return Status
    ...  Should Not Be Empty  ${unit_ids}
    Run Keyword If  ${unit_list_not_empty_status} == ${FALSE}
    ...  Run Keywords
    ...  Log To Console  Nothing to turn on/off
    ...  AND
    ...  Return From Keyword
    ${outlet_state_change_keyword}  Set Variable If  ${desired_state} == ${True}  Pdu BTS Interface On  ${desired_state} == ${False}
    ...  Pdu BTS Interface Off

    FOR  ${unit}  IN  @{unit_ids}
        Log To Console  Will now change state of ${unit}
        Run Keyword
        ...  ${outlet_state_change_keyword}  ${unit}
    END


Get Turned ON RMODs
    [Documentation]  Returns RMODS from INTERFACES that are turned on.

    Log  Get Turned ON RMODs  console=true
    @{rmods}  Create List
    FOR  ${hw}  IN ZIP  ${INTERFACES}
        ${rmod_status}  Run Keyword If  'RMOD' in '${hw}'
        ...  Pdu BTS Interface Get Status  ${hw}
        Run Keyword If  '${rmod_status}'=='on'
        ...  Append To List  ${rmods}  ${hw}
    END

    [Return]  ${rmods}


Disable RMODS
    [Documentation]  Gets Turned ON RMODs creates Test variable and disables them

    Log  ${\n} Disable RMODS  console=true
    ${rmods}  Get Turned ON RMODs
    Set Test Variable  ${RMODS}
    Log  RMODs to be disabled: ${RMODS}  console=true
    Change Power Outlets State  ${RMODS}  ${False}


_Init Pdu
    [Documentation]  This keyword is used to init pdu
    [Arguments]  ${if_name}  ${timeout}

    Variable Should Exist  ${INTERFACES['${if_name}']}  Interface not defined in interfaces.yaml
    ${host}  _Pdu Get IP  ${if_name}
    ${pdu_type}  Pdu Get Type  ${if_name}
    ${number_timeout}  Convert To Number  ${timeout}
    ${version}  Pdu Get Version  ${if_name}
    ${pdu_device}  Setup Pdu  ${pdu_type}  ${host}  timeout=${number_timeout}  version=${version}

    [Return]  ${pdu_device}


_Invert Status
    [Documentation]  This keyword is used to invert Status
    [Arguments]  ${status}

    Run Keyword If  '${status}' == 'off'
    ...  Return From Keyword  on
    ...  ELSE IF  '${status}' == 'on'
    ...  Return From Keyword  off


_Pdu Get IP
    [Documentation]  This keyword is used to get IP from PDU
    [Arguments]  ${if_name}

    [Return]  ${INTERFACES['${if_name}']['IP']}


Pdu Get Type
    [Documentation]  This keyword is used to get pdu type
    [Arguments]  ${if_name}

    ${type}  Set Variable  ${INTERFACES['${if_name}']['TYPE']}
    Should Contain  ${SUPPORTED_PDU}  ${type}  Unsupported type of PDU. PDU type should be included inside ${SUPPORTED_PDU}

    [Return]  ${type}


Pdu Get Version
    [Documentation]  This keyword is used to get pdu version
    [Arguments]  ${if_name}

    ${pdu_defined}  Run Keyword And Return Status
    ...  Variable Should Exist  ${INTERFACES['${if_name}']['PDU_VERSION']}
    ${pdu_version}  Set Variable If  ${pdu_defined}  ${INTERFACES['${if_name}']['PDU_VERSION']}  default
    ${status_version_none}  Run Keyword And Return Status
    ...  Should Be Equal As Strings  ${pdu_version}  None  ignore_case=true
    ${version}  Set Variable If  ${status_version_none}  default  ${pdu_version}

    [Return]  ${version}


_Pdu Get Outlet
    [Documentation]  This keyword is used to get pdu outlet
    [Arguments]  ${if_name}

    [Return]  ${INTERFACES['${if_name}']['OUTLET']}


_Pdu Get Contactor Type
    [Documentation]  This keyword is used to get pdu contactor type
    [Arguments]  ${if_name}

    ${contactor}  Get Variable Value  ${INTERFACES['${if_name}']['CONTACTOR']}  NORMALLY_OPEN

    [Return]  ${contactor}
