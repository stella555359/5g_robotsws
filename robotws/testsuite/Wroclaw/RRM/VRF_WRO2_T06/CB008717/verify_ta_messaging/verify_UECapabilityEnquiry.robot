*** Settings ***
Documentation    :copyright: Nokia
...             :authors: I_MN_RAN_RD_VRF_WRO2_6
...             :contact: I_MN_RAN_RD_VRF_WRO2_6

*** Keywords ***
Verify that UECapabilityEnquiry was completed successfully for UE${ue_id:\d+} and band:n${fr1:\d+}, band:n${fr2:\d+}
    Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE${ue_id}
    Verify in UECapabilityEnquiry that rat-Type eq 'nr' for UE${ue_id}
    Verify in UECapabilityEnquiry that message includes request for band:n${fr1} and band:n${fr2} for UE${ue_id}

Verify in UECapabilityEnquiry that includeNR-DC IE is set for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

   Verify That Message Fulfills Query
    ...     includeNR-DC eq 'true'
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that rat-Type eq ${rat_type} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     rat-Type eq ${rat_type}
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

Verify in UECapabilityEnquiry that message includes request for band:n${fr1:\d+} and band:n${fr2:\d+} for UE${ue_id:\d+}
    ${flow_alias}=     Get flow name
    ...     UECapabilityEnquiry
    ...     device=UE_${ue_id}
    ...     protocol=NR-RRC

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter is present
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}

    Verify That Message Fulfills Query
    ...     capabilityRequestFilter eq ${capabilityRequestFilter_hex_n${fr1}_n${fr2}}
    ...     message_alias=UECapabilityEnquiry
    ...     flow_alias=${flow_alias}
