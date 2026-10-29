X2AP_ENDCX2SetupRequest_template = """
InitiatingNodeType-EndcX2Setup contains
(
    init-eNB is present
    and length(init-eNB) eq {init_eNB_length}
    and init-eNB contains
    (
        GlobalENB-ID is present
    )
    and init-eNB contains
    (
        ServedEUTRAcellsENDCX2ManagementList is present
    )
    and {NokiaENDCChallenge_validator}
)
"""

X2AP_ENDCX2SetupResponse_template = """
RespondingNodeType-EndcX2Setup contains
(
    respond-en-gNB is present
    and length(respond-en-gNB) eq {respond_en_gNB_length}
    and respond-en-gNB contains
    (
        GlobalGNB-ID is present
    )
    and respond-en-gNB contains
    (
        ServedNRcellsENDCX2ManagementList is present
    )
    and {NokiaENDCChallengeResponse_validator}
)
"""

X2AP_ENDCX2SetupRequest_wo_NokiaENDCChallenge = X2AP_ENDCX2SetupRequest_template.format(
    init_eNB_length=2,
    NokiaENDCChallenge_validator="NokiaENDCChallenge is not present")


X2AP_ENDCX2SetupRequest_with_NokiaENDCChallenge = X2AP_ENDCX2SetupRequest_template.format(
    init_eNB_length=3,
    NokiaENDCChallenge_validator="""
        NokiaENDCChallenge is present
        and length(NokiaENDCChallenge) eq 258
        """)

X2AP_ENDCX2SetupResponse_wo_NokiaENDCChallengeResponse = X2AP_ENDCX2SetupResponse_template.format(
    respond_en_gNB_length=2,
    NokiaENDCChallengeResponse_validator="NokiaENDCChallengeResponse is not present")


X2AP_ENDCX2SetupResponse_with_NokiaENDCChallengeResponse = X2AP_ENDCX2SetupResponse_template.format(
    respond_en_gNB_length=3,
    NokiaENDCChallengeResponse_validator="""
        NokiaENDCChallengeResponse is present
        and length(NokiaENDCChallengeResponse) eq 258
        """)
