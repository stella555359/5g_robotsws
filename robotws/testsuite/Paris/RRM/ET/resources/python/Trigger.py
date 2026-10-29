import re
from robot.api import logger
import logging


def console(str):
    logger.console(str)
    logging.info(str)


def getFirstPathFromField(packet, fieldName):
    for path in packet.fields.keys():
        if path.endswith(fieldName):
            return path
    return None


def getFieldValue(packet, fieldName):
    return packet.fields['{}'.format(getFirstPathFromField(packet, fieldName))].show


def getRangeFromPath(path):
    match = re.match(r"^(.*)\[(\d)\](.*)$", path)
    if not match:
        return 1
    return int(match.group(2))


def getFieldFromPath(path):
    match = re.match(r"^(.*)\.(\w*)$", path)
    if not match:
        raise Exception("Path:no field:{}".format(path))
    return match.group(2)


# =======================================================================================
class Record:
    def __init__(self, packet, range):
        self.rnti = 0
        self.packet = packet
        self.range = range
        self.fields = {}

    def __str__(self):
        return "PACKET:{} RANGE:{} RNTI:{}".format(self.packet.namedPacket, self.range, self.rnti)

    def display(self):
        console("    RECORD:RNTI={} PACKET:{} RANGE={}".format(self.rnti, self.packet.namedPacket, self.range))
        for key in self.fields.keys():
            console("      {}={}".format(key, self.fields[key]))


# =======================================================================================
class Resp:
    def __init__(self, msgName):
        self.msgName = msgName
        self.listRec = []
        self.nbPacket = 0
        self.listRnti = []

    def __str__(self):
        return self.msgName

    def getRec(self, packet, range):
        for rec in self.listRec:
            if (packet.namedPacket == rec.packet.namedPacket) and (range == rec.range):
                return rec
        rec = Record(packet, range)
        self.listRec.append(rec)
        return rec

    def display(self):
        console("  RESPONSE:{} NBPACKET={} RECORD={}".
                format(self.msgName, self.nbPacket, len(self.listRec)))
        for rec in self.listRec:
            rec.display()


# =======================================================================================
class TriggerMsg:
    def __init__(self, packet):
        self.packet = packet
        self.slot = getFieldValue(packet, "slot")
        self.sfn = getFieldValue(packet, "sfn")
        self.dictResp = {}

    def initDictResp(self, listMsgResp):
        for msg in listMsgResp:
            self.dictResp['{}'.format(msg)] = Resp(msg)

    def getRespFromName(self, respName):
        return self.dictResp['{}'.format(respName)]

    def __str__(self):
        return "{}:SLOT={} SFN={}".format(self.packet.namedPacket, self.slot, self.sfn)

    def display(self):
        console("TRIGGER:{} SLOT={} SFN={}".format(self.packet.namedPacket, self.slot, self.sfn))
        for key in self.dictResp.keys():
            self.dictResp[key].display()


# =======================================================================================
def NewTriggerMsgList(packetList, respNameList, excludeExtrema=True):
    listTriggerMsg = []
    for packet in packetList:
        triggerMsg = TriggerMsg(packet)
        triggerMsg.initDictResp(respNameList)
        listTriggerMsg.append(triggerMsg)
    # We remove from list first and last elements as pcap has randomly cut a trigger a trigger/responses sequence
    if excludeExtrema:
        listTriggerMsg.pop(0)
        listTriggerMsg.pop(-1)
    return listTriggerMsg


def addListRespToTrigger(triggerMsg, respName, listPacket):
    # console("BHO:ADD:RESPNAME=[{}] NbPACKET={}".format(respName,len(listPacket)))
    resp = triggerMsg.getRespFromName(respName)
    resp.nbPacket = len(listPacket)
    for packet in listPacket:
        # console("BHO:Trigger:{} PACKET:{}".format(triggerMsg.packet.namedPacket,packet.namedPacket))
        for path in packet.fields.keys():
            range = getRangeFromPath(path)
            field = getFieldFromPath(path)
            if "eCpriPucchResourceAllocation" in path or range == 0:
                continue
            rec = resp.getRec(packet, range)
            value = packet.fields['{}'.format(path)].show
            # console("BHO:  PATH={} range={} field={} value={}".format(path,range,field,value))
            rec.fields['{}'.format(field)] = value
            if field == "rnti":
                rec.rnti = value
                resp.listRnti.append(value)


def TriggerMsgPrint(triggerMsg):
    triggerMsg.display()
