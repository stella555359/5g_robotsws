# only keep mandantory parameters/list for new MO
# reduce optional param in list from MO
STRUCT_REDUCED_FOR_MO = [
    # CU,
    "delete:NRHOIF-.*:a3MeasSsbRsrp",
    "delete:NRHOIF-.*:a3MeasSsbRsrq",
    "delete:NRHOIF-.*:a5MeasSsbRsrp",
    "delete:NRHOIF-.*:a5MeasSsbRsrq",
    "delete:NRHOIR-.*:eutraB2MeashoRsrp",
    "delete:NRHOIR-.*:eutraB2MeashoRsrq",
    "delete:SNSSAI-.*:ngUplane",
    # DU,
    "delete:NRCELL-.*:srsForBeamMgmt:srsPowerThresholdForDlBm",
]
# only keep mandatory paramters for new list
STRUCT_REDUCED_FOR_LIST = [
]

if __name__ == "__main__":
    print(STRUCT_REDUCED_FOR_MO)
    print(STRUCT_REDUCED_FOR_LIST)
