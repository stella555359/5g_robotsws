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

*** Keywords ***
##### SNodeReconfigurationComplete keywords #####
Verify in SNodeReconfigurationComplete that configuration-successfully-applied, m-NG-RANNode-to-S-NG-RANNode-Container is present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNGRANnodeReconfigurationCompletion
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     ResponseInfo-ReconfCompl contains (responseType-ReconfComplete contains (configuration-successfully-applied is present and
    ...     configuration-successfully-applied contains (m-NG-RANNode-to-S-NG-RANNode-Container is present)))
    ...     message_alias=SNodeReconfigurationComplete
    ...     flow_alias=${flow_alias}
