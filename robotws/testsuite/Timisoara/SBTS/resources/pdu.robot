*** Settings ***
Documentation  PDU resources
Library  taf.hw.pdu


*** Variables ***
@{SUPPORTED_PDU}  APC  ATEN  BBOX  DCS  EPC  MOXA  PKC  SWH  FAC  BBOXPSE  FPFH

*** Keywords ***
Pdu BTS Interface Off
    [Arguments]  ${if_name}  ${timeout}=10
    [Documentation]
    ...
    ...  Turn off selected interface.
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com
    ...
    ...  *MAINTAINER*
    ...  jakub.kokoszka@nokia.com
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
    Run Keyword If  '${contactor}' == 'NORMALLY_OPEN'    taf.hw.pdu.Power Off  ${outlet}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_OPENED'  taf.hw.pdu.Power Off  ${outlet}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'  taf.hw.pdu.Power ON   ${outlet}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu

Pdu BTS Interface On
    [Arguments]  ${if_name}  ${timeout}=10
    [Documentation]
    ...
    ...  Turn on selected interface.
    ...
    ...  *AUTHOR*
    ...  jakub.kokoszka@nokia.com
    ...
    ...  *MAINTAINER*
    ...  jakub.kokoszka@nokia.com
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
    Run Keyword If  '${contactor}' == 'NORMALLY_OPEN'    taf.hw.pdu.Power ON   ${outlet}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_OPENED'  taf.hw.pdu.Power ON  ${outlet}
    ...    ELSE IF  '${contactor}' == 'NORMALLY_CLOSED'  taf.hw.pdu.Power Off  ${outlet}
    [Teardown]  Run Keyword And Ignore Error  taf.hw.pdu.Teardown Pdu

_Pdu Get Outlet
    [Arguments]  ${if_name}
    [Return]  ${INTERFACES['${if_name}']['OUTLET']}

_Init Pdu
    [Arguments]  ${if_name}  ${timeout}
    Variable Should Exist  ${INTERFACES['${if_name}']}  Interface not defined in interfaces.yaml
    ${host} =  _Pdu Get IP  ${if_name}
    ${pdu_type} =  Pdu Get Type  ${if_name}
    ${pdu_version} =  Pdu Get Version    ${if_name}
    ${udp_timeout} =  Evaluate  ${timeout}-1
    taf.hw.pdu.setup_pdu       model=${pdu_type}   host=${host}    version=${pdu_version}

_Pdu Get IP
    [Arguments]  ${if_name}
    [Return]  ${INTERFACES['${if_name}']['IP']}

_Pdu Get Contactor Type
    [Arguments]  ${if_name}
    ${contactor} =  Get Variable Value  ${INTERFACES['${if_name}']['CONTACTOR']}  NORMALLY_OPEN
    [Return]  ${contactor}

Pdu Get Type
    [Arguments]  ${if_name}
    ${type} =  Set Variable  ${INTERFACES['${if_name}']['TYPE']}
    Should Contain  ${SUPPORTED_PDU}  ${type}  Unsupported type of PDU. PDU type should be included inside ${SUPPORTED_PDU}
    [Return]  ${type}

Pdu Get Version
    [Arguments]  ${if_name}
    ${type} =  Set Variable  ${INTERFACES['${if_name}']['PDU_VERSION']}
    [Return]  ${type}
