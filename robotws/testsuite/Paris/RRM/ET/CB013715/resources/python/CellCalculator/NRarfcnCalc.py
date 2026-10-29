
class FRefParams:
    def __init__(self, deltaFGlobal, fRefOffs, nRefOffs):
        self.deltaFGlobal = deltaFGlobal
        self.fRefOffs = fRefOffs
        self.nRefOffs = nRefOffs


def arfcnToFRefParams(arfcn):
    if arfcn < 600000:
        return FRefParams(5, 0, 0)
    elif arfcn < 2016667:
        return FRefParams(15, 3000, 600000)
    else:
        return FRefParams(60, 24250080, 2016667)


def convert(nrarfcn):
    params = arfcnToFRefParams(nrarfcn)
    assert nrarfcn >= params.nRefOffs
    return params.fRefOffs + params.deltaFGlobal * (nrarfcn - params.nRefOffs)


def getPneCarrierFrequencyThresholdInMHz(pneCarrierFrequencyThreshold):
    return 100 * pneCarrierFrequencyThreshold


def decideFrequencyRange(fRef):
    if fRef <= 6000:
        return "fR1"
    return "fR2"


def isFR2(nrarfcn):
    return decideFrequencyRange(convert(nrarfcn)) == "fR2"


def isFR2_from_nrModeInfo(nrModeInfo):
    if isinstance(nrModeInfo, dict) and 'nrFreqInfo' in nrModeInfo and 'narfcn' in nrModeInfo['nrFreqInfo']:
        return isFR2(nrModeInfo['nrFreqInfo']['narfcn'])
    return False


def isCarrierFrequencyLessOrEqualPneThreshold(nrarfcn, pneCarrierFrequencyThreshold):
    return convert(nrarfcn) <= getPneCarrierFrequencyThresholdInMHz(pneCarrierFrequencyThreshold)


# Example usage
nrarfcn = 700000
pneCarrierFrequencyThreshold = 50

frequency = convert(nrarfcn)
is_fr2 = isFR2(nrarfcn)
is_below_threshold = isCarrierFrequencyLessOrEqualPneThreshold(nrarfcn, pneCarrierFrequencyThreshold)

print(f"Frequency: {frequency}")
print(f"Is FR2: {is_fr2}")
print(f"Is Below Threshold: {is_below_threshold}")
