NEW_MEAS_CONF_5GC001296 = [
    {
        "name": "Modification Require",
        "filter": (
            "x2ap.SgNBModificationRequired_element"
            " && nr-rrc.cellForWhichToReportCGI == 49"
            " && nr-rrc.rrcReconfiguration_element"
        ),
        "amount": 1,
    },
    {
        "name": "Modification Confirm",
        "filter": "x2ap.SgNBModificationConfirm_element && nr-rrc.rrcReconfigurationComplete_element",
        "amount": 1,
    },
]


INTER_GNB_HO_5GC001296 = [
    {
        "name": "SgNB Change Required",
        "filter": "x2ap.SgNBChangeRequired_element",
        "amount": 1,
    },
    {
        "name": "SgNB Change Confirm",
        "filter": "x2ap.SgNBChangeConfirm_element",
        "amount": 1,
    },
    {
        "name": "SN Status Transfer",
        "filter": "x2ap.procedureCode == 4 && ip.src == 10.0.1.2",
        "amount": 1,
    },
    {
        "name": "SgNB Addition Request",
        "filter": "x2ap.SgNBAdditionRequest_element",
        "amount": 1,
    },
    {
        "name": "gNB Addition Request Acknowledge",
        "filter": "x2ap.SgNBAdditionRequestAcknowledge_element && nr-rrc.physCellId == 49",
        "amount": 1,
    },
    {
        "name": "SgNB Reconfiguration Complete",
        "filter": "x2ap.SgNBReconfigurationComplete_element",
        "amount": 1,
    },
    {
        "name": "SN Status Transfer",
        "filter": "x2ap.procedureCode == 4 && ip.src == 10.0.1.137",
        "amount": 1,
    },
    {
        "name": "UE Context Release",
        "filter": "x2ap.UEContextRelease_element",
        "amount": 1,
    },
]

INTRA_GNB_HO_CB006030 = [
    {
        'name': 'Measurement Report',
        'filter': 'nr-rrc.measurementReport_element',
        'amount': 1
    },
    {
        'name': 'RRC Reconfiguration',
        'filter': 'nr-rrc.rrcReconfiguration_element',
        'amount': 1
    },
    {
        'name': 'RRC Reconfiguration Complete',
        'filter': 'nr-rrc.rrcReconfigurationComplete_element',
        'amount': 1
    },
]

INTER_GNB_HO_CB006030 = [
    {
        'name': 'Measurement Report',
        'filter': 'nr-rrc.measurementReport_element',
        'amount': 1
    },
    {
        'name': 'SgNB Change Required',
        'filter': 'x2ap.SgNBChangeRequired_element',
        'amount': 1
    },
    {
        'name': 'SgNB Addition Request',
        'filter': 'x2ap.SgNBAdditionRequest_element',
        'amount': 1
    },
    {
        'name': 'SgNB Addition Request Acknowledge',
        'filter': 'x2ap.SgNBAdditionRequestAcknowledge_element',
        'amount': 1
    },
    {
        'name': 'NR RRC Connection Reconfiguration',
        'filter': 'lte-rrc.rrcConnectionReconfiguration_element',
        'amount': 1
    },
    {
        'name': 'NR RRC Connection Reconfiguration Complete',
        'filter': 'lte-rrc.rrcConnectionReconfigurationComplete_element',
        'amount': 1
    },
    {
        'name': 'SgNB Reconfiguration Complete',
        'filter': 'x2ap.SgNBReconfigurationComplete_element',
        'amount': 1
    },
    {
        'name': 'SgNB Change Confirm',
        'filter': 'x2ap.SgNBChangeConfirm_element',
        'amount': 1
    },
    {
        'name': 'SN Status Transfer',
        'filter': 'x2ap.SNStatusTransfer_element',
        'amount': 2
    }
]
