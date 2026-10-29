*** Settings ***
Documentation
...      == COPYRIGHT ==
...      Nokia Networks
...      == AUTHORS C-PLANE ==
...      - Malgorzata Konior     <malgorzata.konior@nokia.com>
...      - Tomasz Pyrek          <tomasz.pyrek@nokia.com>
...      - Maciej Madej          <maciej.madej@nokia.com>
...      == MAINTAINER ==
...      I_EXT_ETK4_GMS <I_EXT_ETK4@internal.nsn.com>

*** Keywords ***
Verify in XnAP ActivityNotification that UserPlaneTrafficActivityReport is set to ${state:inactive|re-activated} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=activityNotification
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     UserPlaneTrafficActivityReport eq '${state}'
    ...     message_alias=ActivityNotification
    ...     flow_alias=${flow_alias}

