KPIs = {
    "NR_59b": {
        "name": "SCOUT_NR_59b",
        "kpi_id": "NR_59b",
        "level": "bts",
        "unit": "us",
        "target": "500",
        "description": "5G Average delay UL RLC data PDU in High RLC",
        "type": "Latency",
    },
    "NR_973a": {
        "name": "SCOUT_NR_9073a",
        "kpi_id": "NR_973a",
        "level": "NRCELL-700",
        "unit": "us",
        "target": "50000",
        "description": "5G Average downlink RLC delay in gNB-DU",
        "type": "Latency",
    },
}

SPLITMODE_COUNTERS_GROUP = [
    "M55323C010",
    "M55323C070",
    "M55323C030",
    "M55323C090",
    "M55313C080",
    "M55313C170",
    "M55313C110",
    "M55313C190",
]

LATENCY_COUNTERS_GROUP = [
    "M55311C100",
    "M55311C130",
    "M55310C050",
    "M55310C170",
]

ue_config = {
    "SAMSUNG_1": {
        "QCI": "7",
        "NRDRB": 4,
        "split_mode_dl": "F1UX2U",
        "split_mode_ul": "F1UX2U",
        "ues_no": 2,
    },
    "SAMSUNG_2": {
        "QCI": "7",
        "NRDRB": 4,
        "split_mode_dl": "F1UX2U",
        "split_mode_ul": "F1UX2U",
        "ues_no": 2,
    },
    "SAMSUNG_3": {
        "QCI": "9",
        "NRDRB": 6,
        "split_mode_dl": "X2U",
        "split_mode_ul": "F1U",
        "ues_no": 1,
    },
    "SAMSUNG_4": {
        "QCI": "6",
        "NRDRB": 3,
        "split_mode_dl": "F1U",
        "split_mode_ul": "F1UX2U",
        "ues_no": 1,
    },
}
