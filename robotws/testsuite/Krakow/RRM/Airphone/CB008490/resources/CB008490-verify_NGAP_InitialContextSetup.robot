*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...       - Konrad Krzyzak <konrad.krzyzak@nokia.com>
...       - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...       - Michal Szymakowski 	<michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Library     CB008490.py

*** Keywords ***
Verify in NGAP:InitialContextSetupRequest that SecurityIndication is set to ${option:required|preferred|not-needed}
    ${flow_alias}=     Get flow name
    ...     procedure=initialContextSetup
    ...     device=AMF1
    ...     protocol=NGAP

    Verify That Message Fulfills Query
    ...     SecurityIndication contains ((integrityProtectionIndication eq '${option}')
    ...     and
    ...     (confidentialityProtectionIndication eq 'required'))
    ...     message_alias=InitialContextSetupRequest
    ...     flow_alias=${flow_alias}
