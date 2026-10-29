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
##### SNStatusTransfer keywords #####
Verify in SNStatusTransfer that DRBsSubjectToStatusTransfer-List has 1 element and contains pdcpStatusTransfer UL and DL for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNStatusTransfer
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    Verify That Message Fulfills Query
    ...     length(DRBsSubjectToStatusTransfer-List) eq 1 and DRBsSubjectToStatusTransfer-List contains (drbID eq 4 and
    ...     pdcpStatusTransfer-UL contains (pdcp-sn-18bits is present and pdcp-sn-18bits contains (cOUNTValue is present)) and
    ...     pdcpStatusTransfer-DL contains (pdcp-sn-18bits is present and pdcp-sn-18bits contains (cOUNTValue is present)))
    ...     message_alias=SNStatusTransfer
    ...     flow_alias=${flow_alias}

Verify in SNStatusTransfer in DRBsSubjectToStatusTransfer-List drbID eq [${drb_ids}] and contains pdcpStatusTransfer UL and DL for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=sNStatusTransfer
    ...     device=gNB${gnb}
    ...     protocol=XNAP

    verify_drbs_in_SNStatusTransfer    ${flow_alias}    SNStatusTransfer    ${drb_ids}
