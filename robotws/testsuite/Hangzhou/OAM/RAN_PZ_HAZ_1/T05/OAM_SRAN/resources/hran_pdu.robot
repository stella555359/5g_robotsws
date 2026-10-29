*** Settings ***
Documentation     [PURPOSE] pdu General keywords
...               pdu API
Library    taf.hw.pdu


*** Variables ***
@{SUPPORTED_PDU}  APC  ATEN  BBOX  DCS  EPC  MOXA  PKC  SWH  FAC  FACOM  HBTE  TOPYOUNG   TopYoung    FPFH


*** Keywords ***
Pdu BTS Interface Off
    [Arguments]  ${if_name}  ${timeout}=10
    [Documentation]
    ...
    ...  Turn off selected interface.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  *MAINTAINER*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...  |  timeout     | No   |  Maximum number of seconds to wait for pdu response.  |
    ...
    ...  *EXAMPLE*
    ...  |  Pdu BTS Interface Off  |  SMOD_1234567  |
    ...
    _Init Pdu  ${if_name}  ${timeout}
    ${outlet} =  _Pdu Get Outlet  ${if_name}
    ${contactor} =  _Pdu Get Contactor Type  ${if_name}
    Run Keyword If  '${contactor}' == 'NORMALLY_OPENED'    taf.hw.pdu.Power Off  ${outlet}   ${pdu_type}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'  taf.hw.pdu.Power On   ${outlet}  ${pdu_type}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu    ${pdu_type}

Pdu BTS Interface On
    [Arguments]  ${if_name}  ${timeout}=10
    [Documentation]
    ...
    ...  Turn on selected interface.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  *MAINTAINER*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...  |  timeout     | No   |  Maximum number of seconds to wait for pdu response.  |
    ...
    ...  *EXAMPLE*
    ...  |  Pdu BTS Interface On  |  SMOD_1234567  |
    ...
    _Init Pdu  ${if_name}  ${timeout}
    ${outlet} =  _Pdu Get Outlet  ${if_name}
    ${contactor} =  _Pdu Get Contactor Type  ${if_name}
    Run Keyword If  '${contactor}' == 'NORMALLY_OPENED'    taf.hw.pdu.Power On   ${outlet}   ${pdu_type}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'  taf.hw.pdu.Power Off  ${outlet}   ${pdu_type}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu    ${pdu_type}

Pdu BTS Interface Get Status
    [Arguments]  ${if_name}  ${timeout}=10
    [Documentation]
    ...
    ...  Get status of selected interface.
    ...
    ...  *AUTHOR*
    ...  milosz.nowak@nokia.com
    ...
    ...  *MAINTAINER*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  if_name     | Yes  |  Name defined in interfaces.yaml  |
    ...  |  timeout     | No   |  Maximum number of seconds to wait for expected pdu status.  |
    ...
    ...  *RETURN*
    ...  |  Parameters  |  Description  |
    ...  |  status      |  Pdu output state (on/off).  |
    ...
    ...  *EXAMPLE*
    ...  |  ${smod_status} =  |  Pdu BTS Interface Get Status  |  SMOD_1234567  |
    ...
    _Init Pdu  ${if_name}  ${timeout}
    ${outlet} =   _Pdu Get Outlet  ${if_name}
    ${contactor} =  _Pdu Get Contactor Type  ${if_name}
    ${status} =  taf.hw.pdu.Get Port Status  ${outlet}     ${pdu_type}
    Run Keyword If  '${contactor}' == 'NORMALLY_OPENED'    Return From Keyword  ${status}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'  Run Keyword And Return  _Invert Status  ${status}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu     ${pdu_type}

Change power outlets state
    [Arguments]  ${Unit IDs}  ${Desired state}
    [Documentation]
    ...
    ...  Turn chosen outlet(s) on or off.
    ...
    ...  *AUTHOR*
    ...  agata.maslowska@nokia.com
    ...
    ...  *MAINTAINER*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  |  Parameters  | Man. |  Description  |
    ...  |  Unit IDs     | Yes  |  A list with module names as defined in interfaces.yaml
    ...     without any spaces  |
    ...  |  Desired state     | Yes   |  ${True} for On, ${False} for Off  |
    ...
    ...  TC will fail if given module is not found in interfaces.yaml
    ...
    ...  *EXAMPLE*
    ...  Change power outlets state  |   ${SMOD_L1234567890, RMOD_L1163607864}  |  ${True}

    ${unit list not empty status}  Run keyword and return status  Should not be empty  ${Unit IDs}
    Run keyword if    not ${unit list not empty status}
    ...  Run keywords  Log to console  Nothing to turn on/off  AND  Return from keyword
    ${outlet state change keyword}  Set variable if  ${Desired state} == ${True}  Pdu BTS Interface On
    ...  ${Desired state} == ${False}  Pdu BTS Interface Off

    FOR  ${Unit}  IN  @{Unit IDs}
        Log to console  Will now change state of ${Unit}
        Run keyword  ${outlet state change keyword}  ${Unit}
    END

Turn outlets ${desired_state}
    [Documentation]
    ...
    ...  Turn outlet(s) from global variable  ${UNIT_ID_LIST}  on or off.
    ...
    ...  *AUTHOR*
    ...  agata.maslowska@nokia.com
    ...
    ...  *MAINTAINER*
    ...  michal.kwasniewicz@nokia.com
    ...
    ...  |  Parameters    | Man. |  Description  |
    ...  |  Desired state | Yes  |  On, or Off   |
    ...
    ...
    ...  *EXAMPLE*
    ...  Set global variable |  ${UNIT_ID_LIST}  |  SMOD_L1234567890,RMOD_L1163607864
    ...  Turn outlets off    |
    ...  Turn outlets on     |

    Log  Will now check if there are any outlets to be turned ${desired_state}  console=${True}
    ${unit list empty status}  Run keyword and return status  should be empty  ${UNIT_ID_LIST}
    Run Keyword And Return If  ${unit list empty status}  Log  No outlet state shall be changed  console=${True}
    @{Unit ID List Split}  Split String  ${UNIT_ID_LIST}  ,
    Log  Units to be turned ${desired_state}: @{Unit ID List Split}  console=${True}
    ${outlet desired state}  Set variable if  '${desired_state}'=='on'  ${True}  ${False}
    ${outlet state change status}
    ...  Run keyword and return status  Change power outlets state  ${Unit ID List Split}  ${outlet desired state}
    Run keyword if
    ...  not ${outlet state change status}  Set test restriction  Problems occured while turning outlets ${desired_state}

Get Turned ON RMODs
    [Documentation]
    ...
    ...  Returns RMODS from INTERFACES that are turned on.
    ...
    ...  *AUTHOR*
    ...  jacek.mnich@nokia.com
    ...
    ...  *MAINTAINER*
    ...  jacek.mnich@nokia.com

    Log  Get Turned ON RMODs  console=${TRUE}
    @{RMODS}  Create List
    log    ${INTERFACES}
    FOR  ${hw}  IN ZIP  ${INTERFACES}
      ${rmod_status}  Run Keyword If  'RMOD' in '${hw}'  Pdu BTS Interface Get Status  ${hw}
      Run Keyword If  '${rmod_status}'=='on'  Append To List  ${RMODS}  ${hw}
    END
    [Return]  ${RMODS}

Disable RMODS
    [Documentation]
    ...
    ...  Gets Turned ON RMODs creates Test variable and disables them
    ...
    ...  *AUTHOR*
    ...  jacek.mnich@nokia.com
    ...
    ...  *MAINTAINER*
    ...  jacek.mnich@nokia.com

    Log  ${\n} Disable RMODS  console=${True}
    ${RMODS}  Get Turned ON RMODs
    Set Test Variable  ${RMODS}
    Log  RMODs to be disabled: ${RMODS}  console=${True}
    Change power outlets state  ${RMODS}  ${False}

_Init Pdu
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${if_name}: <description>
    ...        ${timeout}: <description>
    [Arguments]  ${if_name}  ${timeout}
    Variable Should Exist  ${INTERFACES['${if_name}']}  Interface not defined in interfaces.yaml
    ${host} =  _Pdu Get IP  ${if_name}
    ${pdu_type} =  Pdu Get Type  ${if_name}
    set test variable    ${pdu_type}
    ${udp_timeout} =  Evaluate  ${timeout}-1
    taf.hw.pdu.Setup Pdu  ${pdu_type}    ${host}  timeout=${timeout}   alias=${pdu_type}

_Invert Status
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${status}: <description>
    [Arguments]  ${status}
    Run Keyword If  '${status}' == 'off'  Return From Keyword  on
    ...    ELSE IF  '${status}' == 'on'   Return From Keyword  off

_Pdu Get IP
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${if_name}: <description>
    ...
    ...    Returns:
    ...        ${INTERFACES['${if_name}']['PB_IP']}: <description>
    [Arguments]  ${if_name}
    [Return]  ${INTERFACES['${if_name}']['PB_IP']}

Pdu Get Type
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${if_name}: <description>
    ...
    ...    Returns:
    ...        ${type}: <description>
    [Arguments]  ${if_name}
    ${type} =  Set Variable  ${INTERFACES['${if_name}']['PB_TYPE']}
    Should Contain
    ...  ${SUPPORTED_PDU}  ${type}  Unsupported type of PDU. PDU type should be included inside ${SUPPORTED_PDU}
    [Return]  ${type}

_Pdu Get Outlet
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${if_name}: <description>
    ...
    ...    Returns:
    ...        ${INTERFACES['${if_name}']['PB_PORT']}: <description>
    [Arguments]  ${if_name}
    [Return]  ${INTERFACES['${if_name}']['PB_PORT']}

_Pdu Get Contactor Type
    [Documentation]    Short description.
    ...
    ...    Args:
    ...        ${if_name}: <description>
    ...
    ...    Returns:
    ...        ${contactor}: <description>
    [Arguments]  ${if_name}
    ${contactor} =  Get Variable Value  ${INTERFACES['${if_name}']['CONTACTOR']}  NORMALLY_OPEN
    [Return]  ${contactor}
