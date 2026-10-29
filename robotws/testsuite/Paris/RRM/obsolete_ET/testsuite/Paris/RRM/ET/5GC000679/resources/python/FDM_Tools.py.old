import luashark_tools as analyzer
import StringTool


def verifyAckNack(reqPacket, respPacketList):
    if len(respPacketList) != 1:
        return "None"
    respPacket = respPacketList[0]
    # ackNack = dtx = nANPucch = numOfBitsOfUciInformation = "NA"
    ackNack = dtx = nANPucch = "NA"
    for path in reqPacket.fields:
        if path.endswith("nANPucch"):
            nANPucch = reqPacket.fields['{}'.format(path)].show
        # if path.endswith("numOfBitsOfUciInformation"):
        #    numOfBitsOfUciInformation = reqPacket.fields['{}'.format(path)].show
    for path in respPacket.fields:
        # if path.endswith("ackNack"):
        if path.endswith("ackNack_item_0"):
            ackNack = respPacket.fields['{}'.format(path)].value
        if path.endswith("dtx"):
            dtx = respPacket.fields['{}'.format(path)].value
    # resStr = "nANPucch={} numOfBitsOfUciInformation={} ackNack={} dtx={}"
    # .format(nANPucch,numOfBitsOfUciInformation,ackNack,dtx)
    resStr = "nANPucch={} ackNack={} dtx={}".format(nANPucch, ackNack, dtx)
    # if (nANPucch == "0x00000001" and ackNack == "80000000000000") or \
    #    (nANPucch == "0x00000002" and ackNack == "c0000000000000"):
    if (nANPucch == "0x00000001" and ackNack == "80") or (nANPucch == "0x00000002" and ackNack == "c0"):
        # if (numOfBitsOfUciInformation == "0x00000001" and ackNack == "80000000000000") or \
        #    (numOfBitsOfUciInformation == "0x00000002" and ackNack == "c0000000000000"):
        diag = "OK"
    else:
        diag = "ERROR"
    return "{}:{}".format(resStr, diag)


def checkNumberOfPrb(numberOfPrb, maximumNumOfPrb, flagOK):
    result = int(flagOK)
    if (int(numberOfPrb, 16) <= int(maximumNumOfPrb)):
        result += 1
    return result


class checkingDtxCrc(object):
    def __init__(self):
        self._counterNonDtx = 0
        self._counterDtx = 0
        self._counterNonCrc = 0
        self._counterCrc = 0

    def checkNonDTX(self, dtx, format2):
        _dtx = int(dtx)
        if (len(format2) == 0):
            _format2 = 2
        else:
            _format2 = int(format2)
        if (_dtx == 0) and (_format2 == 2):
            self._counterNonDtx += 1
        elif (_dtx == 0) and (_format2 == 2):
            self._counterDtx += 1

    def resultNonDTX(self):
        return self._counterNonDtx

    def resultDTX(self):
        return self._counterDtx

    def checkNonCRC(self, crc, format2):
        _crc = int(crc)
        if (len(format2) == 0):
            _format2 = 2
        else:
            _format2 = int(format2)

        if (_crc == 0) and (_format2 == 2):
            self._counterNonCrc += 1
        elif (_crc == 0) and (_format2 == 2):
            self._counterCrc += 1

    def resultNonCRC(self):
        return self._counterNonCrc

    def resultCRC(self):
        return self._counterCrc
