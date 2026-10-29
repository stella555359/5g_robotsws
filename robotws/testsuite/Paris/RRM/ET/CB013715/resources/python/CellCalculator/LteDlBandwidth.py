from enum import Enum


class LteDlBandwidth(Enum):
    LTEDLBANDWIDTH25 = 25
    LTEDLBANDWIDTH50 = 50
    LTEDLBANDWIDTH75 = 75
    LTEDLBANDWIDTH100 = 100


def to_string(v):
    if v == LteDlBandwidth.LTEDLBANDWIDTH25:
        return "LTEDLBANDWIDTH25"
    elif v == LteDlBandwidth.LTEDLBANDWIDTH50:
        return "LTEDLBANDWIDTH50"
    elif v == LteDlBandwidth.LTEDLBANDWIDTH75:
        return "LTEDLBANDWIDTH75"
    elif v == LteDlBandwidth.LTEDLBANDWIDTH100:
        return "LTEDLBANDWIDTH100"
    else:
        return f"Unknown value: {v.value}"


# Example usage
bandwidth = LteDlBandwidth.LTEDLBANDWIDTH75
print(to_string(bandwidth))
