*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Dawid Krawczuk <dawid.krawczuk@nokia.com>
...      - Tomasz Pyrek <tomasz.pyrek@nokia.com>
...      - Michał Szymakowski <michal.szymakowski@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

Resource    ./5GC001756-common_keywords.robot

*** Keywords ***
Verify that AMF${amf_id:\d+} PDU session was rejected with cause radioNetwork: radio-resources-not-available
    ${flow}=        Get Flow Name
    ...     procedure=pDUSessionResourceSetup
    ...     device=AMF${amf_id}

    Verify That Message Fulfills Query
    ...     ((length(PDUSessionResourceFailedToSetupListSURes) eq 1)
    ...     and
    ...     (PDUSessionResourceFailedToSetupListSURes contains (radioNetwork eq "radio-resources-not-available")))
    ...     message_alias=PDUSessionResourceSetupResponse
    ...     flow_alias=${flow}
