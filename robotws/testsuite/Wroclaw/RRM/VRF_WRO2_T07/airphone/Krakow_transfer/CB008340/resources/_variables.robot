*** Settings ***
Documentation
...    :copyright: Nokia
...    :contact: I_EXT_MN_RAN_VRF_WRO2_7_T03@internal.nsn.com

*** Variables ***
@{handover_request_fields_list_to_sim_gNB}
...    NG-RANnodeUEXnAPID:ng-RANnodeUEXnAP-id    plmn-id:tgt_plmn        nr-CI:nrcell-id

@{handover_request_fields_list_to_real_gNB}
...    NG-RANnodeUEXnAPID:ng-RANnodeUEXnAP-id    ng-c-UE-reference:ng-c-ue-reference

@{initial_context_setup_request_fields}
...    RAN-UE-NGAP-ID:ran-ue-ngap-Id    AMF-UE-NGAP-ID:amf-ue-ngap-Id    pLMNIdentity:plmn-id
...    aMFRegionID:amf-region-id        aMFSetID:amf-set-id	             aMFPointer:amf-pointer

