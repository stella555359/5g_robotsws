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
&{FeatureSetEntryIndex}=              '1'="0x00"    '2'="0x02"
&{BandCombinationIndex}=               '1'="0x0000"  '2'="0x0001"  '3'="0x0002"  '4'="0x0003"

*** Keywords ***
##### BearerContextSetupRequest keywords #####
Verify in BearerContextSetupRequest that it has 8 required protocolIE items for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (GNB-CU-CP-UE-E1AP-ID is present) and (SecurityInformation is present) and (BitRate is present) and
    ...     (PLMN-Identity is present) and (ActivityNotificationLevel is present) and (Inactivity-Timer is present) and
    ...     (System-BearerContextSetupRequest is present) and (GNB-DU-ID is present)
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that it has 7 required protocolIE items for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (GNB-CU-CP-UE-E1AP-ID is present) and (SecurityInformation is present) and (BitRate is present) and
    ...     (PLMN-Identity is present) and (ActivityNotificationLevel is present) and (Inactivity-Timer is not present) and
    ...     (System-BearerContextSetupRequest is present) and (GNB-DU-ID is present)
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that id-UEDLMaximumIntegrityProtectedDataRate ${option:(is|is not)} present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    # id: id-UEDLMaximumIntegrityProtectedDataRate (66)
    Run keyword if    '${option}'=='is'
    ...     Verify That Message Fulfills Query
    ...     protocolIEs contains (id eq 66) and length(protocolIEs) eq 9
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

    Run keyword if    '${option}'=='is not'
    ...     Verify That Message Fulfills Query
    ...     length(protocolIEs) eq 8
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that cipheringAlgorithm is set to ${cipAlg:\S+} and encryptionKey is present for ${node} gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     SecurityInformation contains (securityAlgorithm contains (cipheringAlgorithm eq "${cipAlg}") and (encryptionKey is present))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that integrityProtectionAlgorithm is set to ${intAlg} and integrityProtectionKey is present for ${node} gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     SecurityInformation contains (securityAlgorithm contains (integrityProtectionAlgorithm eq "${intAlg}") and
    ...     (integrityProtectionKey is present))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that SecurityIndication is set to ${option:required|preferred|not-needed} for SN gNB${gnb}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     securityIndication contains ((integrityProtectionIndication eq '${option}')
    ...     and
    ...     (confidentialityProtectionIndication eq 'required'))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that ActivityNotificationLevel is set to ${actNotLvl:\S+} for ${opt:MN|SN} gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     ActivityNotificationLevel eq "${actNotLvl}"
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that Inactivity-Timer is set to ${inactTim:\d+} for ${opt:MN|SN} gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     Inactivity-Timer eq ${inactTim}
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that pDU-Session-ID is set to 1 and pDU-Session-Type is set to ipv4 for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (length(PDU-Session-Resource-To-Setup-List) eq 1) and (PDU-Session-Resource-To-Setup-List contains
    ...     (pDU-Session-ID eq 1) and (pDU-Session-Type eq "ipv4"))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that securityIndication is present and integrityProtectionIndication set not-needed SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     PDU-Session-Resource-To-Setup-List contains ((securityIndication is present) and
    ...     (securityIndication contains (integrityProtectionIndication eq "not-needed")))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that nG-UL-UP-TNL-Information is present and gTPTunnel is configured for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     PDU-Session-Resource-To-Setup-List contains (nG-UL-UP-TNL-Information contains
    ...     ((gTP-TEID is present) and (transportLayerAddress is present)))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that defaultDRB is set and pDCP-Reestablishment is set for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     PDU-Session-Resource-To-Setup-List contains (dRB-To-Setup-List-NG-RAN contains
    ...     ((sDAP-Configuration contains (defaultDRB eq "true")) and (pDCP-Reestablishment eq "true")))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that in cellGroupID: ${cid:\d+} uL-Configuration is ${ulc:\S+} and dL-TXStop is not present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-To-Setup-List-NG-RAN contains (cell-Group-Information contains
    ...     (cell-Group-ID eq ${cid} and uL-Configuration eq ${ulc} and dL-TX-Stop is not present))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that in cellGroupID: ${cid:\d+} uL-Configuration is ${ulc:\S+} and dL-TXStop set to 'stop' for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     dRB-To-Setup-List-NG-RAN contains (cell-Group-Information contains
    ...     (cell-Group-ID eq ${cid} and uL-Configuration eq ${ulc} and dL-TX-Stop eq 'stop'))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that qos-flow-Information-To-Be-Setup has 1 element for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     PDU-Session-Resource-To-Setup-List contains (dRB-To-Setup-List-NG-RAN contains ((length(qos-flow-Information-To-Be-Setup) eq 1)))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest that data-Forwarding-Request is dL, qoS-Flows-Forwarded-On-Fwd-Tunnels is not present for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     PDU-Session-Resource-To-Setup-List contains (dRB-Data-Forwarding-Information-Request contains
    ...     (data-Forwarding-Request eq "dL" and qoS-Flows-Forwarded-On-Fwd-Tunnels is not present))
    ...     message_alias=BearerContextSetupRequest
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupRequest ${drbs:\d+} DRBs in dRB-To-Setup-List-NG-RAN for SN gNB${gnb:\d+}
    [Documentation]    Keywords verifies number od DRBs in dRB-To-Setup-List-NG-RAN and for each DRB:
    ...                  - sDAP-Configuration -> defaultDRB = false, except for DRB with dRB-ID = 4
    ...                  - pDCP-Reestablishment = true
    ...                  - cell-Group-Information has 2 elements (one for MCG and one for SCG) correctly filled
    ...                  - Qos-flow-Information-ToBe-Setup has single element
    ...                  - dRB-DataForwarding-Information-Request -> data-Forwarding0Request = dL
    ...                  - dRB-DataForwarding-Information-Request -> qoS-Flows-Forwarded-On-Fwd-Tunnels is not present

    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_drbs_in_BearerContextSetupRequest    ${flow_alias}    BearerContextSetupRequest    ${drbs}

Verify in BearerContextSetupRequest that all DRBs has dRB-Inactivity-Timer set to ${timer} for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_dRB_Inactivity_Timer    ${flow_alias}    BearerContextSetupRequest    ${timer}

Verify in BearerContextSetupRequest that DRBs [${drbs}] has dRB-Inactivity-Timer set to [${timers}] for ${opt:SN|MN} gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_multi_dRB_Inactivity_Timer    ${flow_alias}    BearerContextSetupRequest    ${drbs}    ${timers}

Verify in BearerContextSetupRequest sdap-Config for all DRBs
    [Arguments]    ${gnb}=3    ${rdDisableSDAPheaderSa}=${False}

    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_sdap_config_in_bearer_ctx_setup_request    ${flow_alias}    BearerContextSetupRequest    ${rdDisableSDAPheaderSa}

##### BearerContextSetupResponse keywords #####
Verify in BearerContextSetupResponse that nG-DL-UP-TNL-Information is present and gTPTunnel is configured for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     nG-DL-UP-TNL-Information contains ((gTP-TEID is present) and (transportLayerAddress is present))
    ...     message_alias=BearerContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupResponse that dRB-data-Forwarding-Info-Resp is present, uL-UP-Transport-Param has 2 elements for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    Verify That Message Fulfills Query
    ...     (dRB-data-Forwarding-Information-Response is present) and (length(uL-UP-Transport-Parameters) eq 2)
    ...     message_alias=BearerContextSetupResponse
    ...     flow_alias=${flow_alias}

Verify in BearerContextSetupResponse ${drbs:\d+} DRBs in dRB-Setup-List-NG-RAN for SN gNB${gnb:\d+}
    ${flow_alias}=     Get flow name
    ...     procedure=bearerContextSetup
    ...     device=gNB${gnb}
    ...     protocol=E1AP

    verify_drbs_in_BearerContextSetupResponse    ${flow_alias}    BearerContextSetupResponse    ${drbs}
