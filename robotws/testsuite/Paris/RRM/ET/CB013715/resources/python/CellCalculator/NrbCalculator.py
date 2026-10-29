class ConfigurationError(Exception):
    pass


class FrequencyRange:
    FR1 = "fR1"
    FR2 = "fR2"


class NRSCS:
    pass


class ChannelBandwidth:
    pass


class NRB:
    def __init__(self, value):
        self.value = value


def convertToNrNrbForFr1(channelBandwidth, scsCommon):
    # Placeholder for actual conversion logic
    return 100


def convertToNrNrbForFr2(channelBandwidth, scsCommon):
    # Placeholder for actual conversion logic
    return 200


def convertToChBwForFr1(nrb, scsCommon):
    # Placeholder for actual conversion logic
    return 50


def convertToChBwForFr2(nrb, scsCommon):
    # Placeholder for actual conversion logic
    return 100


def lookup(scsCommon, channelBandwidth, frequencyRange):
    if frequencyRange == FrequencyRange.FR1:
        nrb = convertToNrNrbForFr1(channelBandwidth, scsCommon)
        return nrb
    nrb = convertToNrNrbForFr2(channelBandwidth, scsCommon)
    return nrb


def calculateNRB(scsCommon, channelBandwidth, frequencyRange):
    result = lookup(scsCommon, channelBandwidth, frequencyRange)
    if result is None:
        text = "Invalid channel setting. Please see 3GPP tables for number of Resource blocks 'NRB' "
        text = text + "for channel bandwidth. Please change ARFCN, ChBw or SCS"
        raise ConfigurationError(text)
    return NRB(result)


def calculateBwpSizeInMHz(scsCommon, cRbSizeDl, frequencyRange):
    try:
        nrb = cRbSizeDl.value
        if frequencyRange == FrequencyRange.FR1:
            return convertToChBwForFr1(nrb, scsCommon)
        return convertToChBwForFr2(nrb, scsCommon)
    except Exception as e:
        print(f"Exception caught: {e}")
        return None


class ICellForUeThread:
    def isSupportedMultiDedicatedBwps(self):
        # Placeholder for actual implementation
        return False

    def getChBwDl(self):
        # Placeholder for actual implementation
        return ChannelBandwidth()

    def getChBwUl(self):
        # Placeholder for actual implementation
        return ChannelBandwidth()

    def getBwpProfiles(self):
        # Placeholder for actual implementation
        return []

    def getNrCellIdentity(self):
        # Placeholder for actual implementation
        return 0

    def isFR1(self):
        # Placeholder for actual implementation
        return True

    def getDlBandwidth(self):
        # Placeholder for actual implementation
        return 0

    def getCoresetSize(self):
        # Placeholder for actual implementation
        return 0

    def getScs(self):
        # Placeholder for actual implementation
        return NRSCS()


def getCellChBwDl(cell, pCellId, bwpProfileId):
    if not cell.isSupportedMultiDedicatedBwps():
        return cell.getChBwDl()
    bwpProfiles = cell.getBwpProfiles()
    bwpProfile = bwpProfiles[0] if cell.getNrCellIdentity() != pCellId else bwpProfiles[1]
    frequencyRange = FrequencyRange.FR1 if cell.isFR1() else FrequencyRange.FR2
    cRbSizeDl = bwpProfile.getDlPrbSize(cell.getDlBandwidth(), cell.getCoresetSize())
    optChBw = calculateBwpSizeInMHz(cell.getScs(), cRbSizeDl, frequencyRange)
    return optChBw if optChBw is not None else cell.getChBwDl()


def getCellChBwUl(cell, pCellId, bwpProfileId):
    if not cell.isSupportedMultiDedicatedBwps():
        return cell.getChBwUl()
    bwpProfiles = cell.getBwpProfiles()
    bwpProfile = bwpProfiles[0] if cell.getNrCellIdentity() != pCellId else bwpProfiles[1]
    frequencyRange = FrequencyRange.FR1 if cell.isFR1() else FrequencyRange.FR2
    cRbSizeUl = bwpProfile.getUlPrbSize(cell.getUlBandwidth(), cell.getCoresetSize())
    optChBwUl = calculateBwpSizeInMHz(cell.getScs(), cRbSizeUl, frequencyRange)
    return optChBwUl if optChBwUl is not None else cell.getChBwUl()
