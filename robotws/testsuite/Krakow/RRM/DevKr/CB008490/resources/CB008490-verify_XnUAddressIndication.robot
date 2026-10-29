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

*** Variables ***

*** Keywords ***
##### XnUAddressIndication keywords #####
Verify in XnUAddressIndication that dRBsToBeSetupList has 1 element and contains gtpTunnel tnl-address and gtp-teid for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=xnUAddressIndication
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     XnUAddressInfoperPDUSession-List contains (pduSessionResourceSetupCompleteInfo-SNterm contains
    ...     (length(dRBsToBeSetupList) eq 1) and dRBsToBeSetupList contains (dRB-ID eq 4) and
    ...     gtpTunnel contains (tnl-address is present and gtp-teid is present))
    ...     message_alias=XnUAddressIndication
    ...     flow_alias=${flow_alias}

Verify in XnUAddressIndication in dRBsToBeSetupList dRB-ID eq [${drb_ids}] and contains gtpTunnel tnl-address and gtp-teid for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=xnUAddressIndication
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_drbs_in_XnUAddressIndication    ${flow_alias}    XnUAddressIndication    ${drb_ids}
