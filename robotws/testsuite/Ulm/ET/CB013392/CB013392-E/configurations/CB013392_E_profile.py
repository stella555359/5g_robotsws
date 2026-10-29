E1_IAF_3 = {
           "a2MeashoSsbRsrp": {
                "a2HysteresishoSsbRsrp": "6",
                "a2ThresholdhoSsbRsrp": "15",
                "a2TimeToTriggerhoSsbRsrp": "ms320"
           },
           "a3MeasSsbRsrp": {
                "a3HysteresisSsbRsrp": "9",
                "a3OffsetSsbRsrp": "11",
                "a3TimeToTriggerSsbRsrp": "ms40"
            },
           "a5MeasSsbRsrp": {
                "a5HysteresisSsbRsrp": "20",
                "a5Threshold1SsbRsrp": "4",
                "a5Threshold2SsbRsrp": "8",
                "a5TimeToTriggerSsbRsrp": "ms0"
            }
}


# Categorize UE count into 3 groups.
# The first group UE#1 till PC2_UE_COUNT shall have PC2 and RFSP 5
# The second+third group shall have PC3 (as per json)
# The second group has RFSP=10 and is handed over
# The third group has RFSP=20
# IMPORTANT: The UE count below shall respect the values in .json.
# number of ues in "ue_group_MUE_SA_tc1_pc2" = PC2_UE_COUNT
# number of ues in "ue_group_MUE_SA_tc1_pc3" = PC3_UE_HO_COUNT + PC3_UE_COUNT
PC2_UE_COUNT = 30
PC3_UE_HO_COUNT = 30
PC3_UE_COUNT = 30
LOOP_COUNT = 1

UE1_START_COUNT = 1
UE1_END_COUNT = PC2_UE_COUNT
UE2_START_COUNT = PC2_UE_COUNT + 1
UE2_END_COUNT = PC2_UE_COUNT + PC3_UE_HO_COUNT
UE3_START_COUNT = UE2_END_COUNT + 1
UE3_END_COUNT = UE2_END_COUNT + PC3_UE_COUNT


def get_value(key):
    if UE2_START_COUNT <= key <= UE2_END_COUNT:
        return 10
    elif UE3_START_COUNT <= key <= UE3_END_COUNT:
        return 20
    else:
        return 5


def get_ue_to_be_ho():
    return list(range(UE2_START_COUNT, UE3_START_COUNT))


def get_non_ho_ue():
    return list(range(UE1_START_COUNT, UE2_START_COUNT)) + list(range(UE3_START_COUNT, UE3_END_COUNT+1))


def get_pc1_ue():
    return list(range(UE1_START_COUNT, UE2_START_COUNT))


def get_pc3_ue():
    return list(range(UE3_START_COUNT, UE3_END_COUNT+1))


def get_tc_loop_count():
    return LOOP_COUNT+1


# First UE group (with pc2) uses IAF-1
# Second UE group (with pc3 and handed over) uses IAF-2 (RFSP=10)
# Third UE group (with pc3) uses IAF-3 (RFSP=20)
RFSP_UE_MEASPR = {key: get_value(key) for key in range(UE1_START_COUNT, UE3_END_COUNT+1)}

RFSP_PRIO_GNB_MEASPR = {1: 5,
                        2: 10,
                        3: 20}
