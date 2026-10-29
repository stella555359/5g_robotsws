SLOTS_PER_SFN = {
    "FDD": 10,
    "TDD FR1": 20,
    "TDD FR2": 80
}

SLOTS_TO_SUBTRACT = {
    "FDD": 4,
    "TDD FR1": 6,
    "TDD FR2": 7
}


def get_slots_per_sfn(variant):
    """
    Get SLOTS_PER_SFN value based on provided variant
    :param variant: one of supported configuration variants
    :return: number of slots per sfn
    """
    assert variant in SLOTS_PER_SFN, f"Wrong variant: {variant}, valid values: {list(SLOTS_PER_SFN.keys())}"
    return SLOTS_PER_SFN[variant]


def get_slots_to_subtract(variant):
    """
    Get SLOTS_TO_SUBTRACT value based on provided variant
    :param variant: one of supported configuration variants
    :return: number of slots to be subtracted from total slot time for UL Grant occurrence in TtiTraces
             to get proper estimate of time when UL Grant occurred
    """
    assert variant in SLOTS_TO_SUBTRACT, f"Wrong variant: {variant}, valid values: {list(SLOTS_TO_SUBTRACT.keys())}"
    return SLOTS_TO_SUBTRACT[variant]
