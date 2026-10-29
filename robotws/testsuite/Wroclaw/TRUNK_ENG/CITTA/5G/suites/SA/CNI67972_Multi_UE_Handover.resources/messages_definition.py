# for each ue_{ue_id}.pcap
INTRA_DU_INTER_CELL_HO = [
    {
        "name": "Bearer Context Modification Request",
        "filter": "e1ap.BearerContextModificationRequest_element",
    },
    {
        "name": "Bearer Context Modification Response",
        "filter": "e1ap.BearerContextModificationResponse_element",
    },
    {
        "name": "UE Context Modification Request",
        "filter": "f1ap.UEContextModificationRequest_element",
    },
    {
        "name": "UE Context Modification Response",
        "filter": "f1ap.UEContextModificationResponse_element",
    },
    {
        "name": "DL RRC Message Transfer",
        "filter": "f1ap.DLRRCMessageTransfer_element",
    },
    {
        "name": "UL RRC Message Transfer",
        "filter": "f1ap.ULRRCMessageTransfer_element",
    },
]
