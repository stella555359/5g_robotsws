# -*- coding:utf-8 -*-

import re
import sys
from time import gmtime, strftime

if not sys.version < "3":
    def ord(para):
        return para


class Uri(object):
    def __init__(self, uri):
        self._uri = uri

    def __str__(self):
        return _ParseUri(self._uri)


def _readPLMN_ID(uri):
    mcc = '{:03x}'.format(ord(uri[0]) << 4 | ord(uri[1]) >> 4)
    mnc = ''
    if ord(uri[1]) & 0x0F == 0x0F:
        mnc = '{:02x}'.format(ord(uri[2]))
    else:
        mnc = '{:03x}'.format((ord(uri[1]) & 0x0F) << 8 | ord(uri[2]))
    return mcc, mnc, uri[3:]


def _readENB_ID(uri):
    enb_id = str(ord(uri[0]) << 12 | ord(uri[1]) << 4 | ord(uri[2]) >> 4)
    return enb_id, uri[2:]


def _readCGI(uri):
    mcc, mnc, uri = _readPLMN_ID(uri)
    lac = str(ord(uri[0]) << 8 | ord(uri[1]))
    c_id = str(ord(uri[2]) << 8 | ord(uri[3]))
    return mcc, mnc, lac, c_id, uri[4:]


def _readUTRAN_CGI(uri):
    mcc, mnc, uri = _readPLMN_ID(uri)
    rnc_id = str(ord(uri[0]) << 8 | ord(uri[1]))
    c_id = str(ord(uri[2]) << 8 | ord(uri[3]))
    return mcc, mnc, rnc_id, c_id, uri[4:]


def _readEUTRAN_CGI(uri):
    mcc, mnc, uri = _readPLMN_ID(uri)
    enb_id, uri = _readENB_ID(uri)
    lcr_id = str((ord(uri[0]) & 0x0F) << 4 | (ord(uri[1]) & 0xF0) >> 4)
    return mcc, mnc, enb_id, lcr_id, uri[2:]


def _readBC(uri):
    return str(ord(uri[0])), uri[1:]


def _readMBSFNA_ID(uri):
    return str(ord(uri[0])), uri[1:]


def _readARFCN(uri):
    return str(ord(uri[0]) << 8 | ord(uri[1])), uri[2:]


def _readGENERIC_ID(uri):
    return str(ord(uri[0]) << 8 | ord(uri[1])), uri[2:]


# printers

def _PLMN_ID(name, uri):
    mcc, mnc, uri = _readPLMN_ID(uri)
    return name + '(MCC=' + mcc + ',MNC=' + mnc + ')', uri


def _ENB_ID(name, uri):
    enb_id, uri = _readENB_ID(uri)
    return name + '-' + enb_id, uri[1:]


def _CGI(name, uri):
    mcc, mnc, lac, cid, uri = _readCGI(uri)
    return name + '(MCC=' + mcc + ',MNC=' + mnc + ',LAC=' + lac + ',CID=' + cid + ')', uri


def _UTRAN_CGI(name, uri):
    mcc, mnc, rnc_id, c_id, uri = _readUTRAN_CGI(uri)
    return name + '(MCC=' + mcc + ',MNC=' + mnc + ',ERNCID=' + rnc_id + ',CID=' + c_id + ')', uri


def _EUTRAN_CGI(name, uri):
    mcc, mnc, enb_id, lcr_id, uri = _readEUTRAN_CGI(uri)
    return name + '(MCC=' + mcc + ',MNC=' + mnc + ',ENBID=' + enb_id + ',LCRID=' + lcr_id + ')', uri


def _BC(name, uri):
    band_class, uri = _readBC(uri)
    return name + '-' + band_class, uri


def _MBSFNA_ID(name, uri):
    area_id, uri = _readMBSFNA_ID(uri)
    return name + '-' + area_id, uri


def _ARFCN(name, uri):
    arfcn, uri = _readARFCN(uri)
    return name + '-' + arfcn, uri


def _GENERIC_ID(name, uri):
    object_id, uri = _readGENERIC_ID(uri)
    return name + '-' + object_id, uri


def _ParseUri(uri):
    decoder = {
        0x01: ("PLMN", _PLMN_ID),
        0x02: ("MRBTS", _ENB_ID),
        0x03: ("HOME_CELL_GSM", _CGI),
        0x04: ("TARGET_CELL_GSM", _CGI),
        0x05: ("HOME_CELL_WCDMA", _UTRAN_CGI),
        0x06: ("TARGET_CELL_WCDMA", _UTRAN_CGI),
        0x07: ("HOME_CELL_LTE", _EUTRAN_CGI),
        0x08: ("TARGET_CELL_LTE", _EUTRAN_CGI),
        0x09: ("HBC", _BC),
        0x0A: ("RNC", _GENERIC_ID),
        0x0B: ("WBTS", _GENERIC_ID),
        0x0C: ("LNBTS", _ENB_ID),
        0x0D: ("LNCEL", _GENERIC_ID),
        0x0E: ("ARFCN", _ARFCN),
        0x0F: ("UARFCN", _ARFCN),
        0x10: ("EARFCN", _ARFCN),
        0x11: ("LNADJ", _GENERIC_ID),
        0x12: ("LNMME", _GENERIC_ID),
        0x13: ("LNMCE", _GENERIC_ID),
        0x14: ("LNM3", _GENERIC_ID),
        0x15: ("SMOD", _GENERIC_ID),
        0x16: ("BBMOD", _GENERIC_ID),
        0x17: ("RMOD", _GENERIC_ID),
        0x18: ("SFP", _GENERIC_ID),
        0x19: ("APMOD", _GENERIC_ID),
        0x1A: ("PMQAP", _GENERIC_ID),
        0x1B: ("BBPOOL", _GENERIC_ID),
        0x1C: ("LAA", _GENERIC_ID),
        0x1D: ("MNLENT", _GENERIC_ID),
        0x1E: ("SYNC", _GENERIC_ID),
        0x1F: ("CLOCK", _GENERIC_ID),
        0x20: ("TOP", _GENERIC_ID),
        0x21: ("TOPF", _GENERIC_ID),
        0x22: ("TOPP", _GENERIC_ID),
        0x23: ("TAC", _GENERIC_ID),
        0x24: ("LTAC", _GENERIC_ID),
        0x25: ("TNLSVC", _GENERIC_ID),
        0x26: ("TNL", _GENERIC_ID),
        0x27: ("ETHSVC", _GENERIC_ID),
        0x28: ("ETHIF", _GENERIC_ID),
        0x29: ("VLANIF", _GENERIC_ID),
        0x2A: ("ETHLK", _GENERIC_ID),
        0x2B: ("L2SWI", _GENERIC_ID),
        0x2C: ("BRGPRT", _GENERIC_ID),
        0x2D: ("IPAPP", _GENERIC_ID),
        0x2E: ("IPSECC", _GENERIC_ID),
        0x2F: ("SECPOL", _GENERIC_ID),
        0x30: ("TWAMP", _GENERIC_ID),
        0x31: ("IPNO", _GENERIC_ID),
        0x32: ("IPIF", _GENERIC_ID),
        0x33: ("IPADDRESSV4", _GENERIC_ID),
        0x34: ("IPADDRESSV6", _GENERIC_ID),
        0x35: ("IPVOL", _GENERIC_ID),
        0x36: ("QOS", _GENERIC_ID),
        0x37: ("FSTSCH", _GENERIC_ID),
        0x38: ("P3LP", _GENERIC_ID),
        0x39: ("P3ML", _GENERIC_ID),
        0x3A: ("PPTT", _GENERIC_ID),
        0x3B: ("WCEL", _GENERIC_ID),
        0x3C: ("OperID", _GENERIC_ID),
        0x3D: ("LCG", _GENERIC_ID),
        0x3E: ("HWUnit", _GENERIC_ID),
        0x3F: ("SCHED-HSDPA", _GENERIC_ID),
        0x40: ("SCHED-HSUPA", _GENERIC_ID),
        0x41: ("FSM", _GENERIC_ID),
        0x42: ("P3SL", _GENERIC_ID),
        0x43: ("PIC_pool", _GENERIC_ID),
        0x44: ("MBSFN", _MBSFNA_ID),
        0x45: ("EQM", _GENERIC_ID),
        0x46: ("APEQM", _GENERIC_ID),
        0x47: ("ANTL", _GENERIC_ID),
        0x48: ("MNL", _GENERIC_ID),
        0x49: ("CABINET", _GENERIC_ID),
        0x4A: ("FHS", _GENERIC_ID)
    }
    uriString = ''
    while len(uri) > 0:
        if len(uriString) > 0:
            uriString += '/'
        objectId = ord(uri[0])  # ord(uri[0])==objectID
        uri = uri[1:]
        if objectId in decoder:
            parsed, uri = decoder[objectId][1](decoder[objectId][0], uri)
            uriString += parsed
        else:
            if type(uri) is bytes:
                sys.stderr.write('unknown uri part: objtype=' + hex(objectId) + ' ' + uri.hex() + '\n')
            else:
                sys.stderr.write('unknown uri part: objtype=' + hex(objectId) + ' ' + uri.encode('hex') + '\n')
            uri = ''
    return convert_mo(uriString)


def convert_mo(string):
    match = re.search(
        r"^PLMN\(MCC=(\d+),MNC=(\d+)\)/MRBTS-(\d+)/(LNBTS|BCF|WBTS)-(\d+)$",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-%s-%d</localMoid>") % (
                   int(match.group(3)),
                   match.group(4),
                   int(match.group(5)))
    match = re.search(
        r"^HOME_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)/"
        r"LNCEL-(\d+)$", string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNCEL-%d/MCC-%d/MNC-%s</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(3)),
                   int(match.group(5)),
                   int(match.group(1)),
                   match.group(2))
    match = re.search(
        r"^HOME_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)/"
        r"LNCEL-(\d+)/"
        r"HOTARGET_CELL_GSM\(MCC=(\d+),MNC=(\d+),LAC=(\d+),CID=(\d+)\)$",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNCEL-%d/MCC-%d/MNC-%s/"
                   "LAC-%d/TCID-%d/MCC-%d/MNC-%s</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(3)),
                   int(match.group(5)),
                   int(match.group(1)),
                   match.group(2),
                   int(match.group(8)),
                   int(match.group(9)),
                   int(match.group(6)),
                   match.group(7))
    match = re.search(
        r"^HOME_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)/"
        r"LNCEL-(\d+)/"
        r"HOTARGET_CELL_WCDMA\(MCC=(\d+),MNC=(\d+),ERNCID=(\d+),CID=(\d+)\)$",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNCEL-%d/MCC-%s/MNC-%s/"
                   "HOT-%d/TCID-%d/MCC-%d/MNC-%s</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(3)),
                   int(match.group(5)),
                   int(match.group(1)),
                   match.group(2),
                   int(match.group(8)),
                   int(match.group(9)),
                   int(match.group(6)),
                   match.group(7))
    match = re.search(
        r"^HOME_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)/"
        r"LNCEL-(\d+)/"
        r"HOTARGET_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)$",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNCEL-%d/MCC-%d/MNC-%s/"
                   "ECI-%d/MCC-%d/MNC-%s</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(3)),
                   int(match.group(5)),
                   int(match.group(1)),
                   match.group(2),
                   eci(
                       int(match.group(8)),
                       int(match.group(9))),
                   int(match.group(6)),
                   match.group(7))
    match = re.search(
        r"^HOME_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)/"
        r"LNCEL-(\d+)/((?:[EU])?ARFCN|HBC)-(\d+)", string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNCEL-%d/MCC-%d/MNC-%s/"
                   "%s-%d</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(3)),
                   int(match.group(5)),
                   int(match.group(1)),
                   match.group(2),
                   match.group(6),
                   int(match.group(7)))
    match = re.search(
        r"^PLMN\(MCC=(\d+),MNC=(\d+)\)/MRBTS-(\d+)/LNBTS-(\d+)/"
        r"(LNADJ|LNMME)-(\d+)$",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/%s-%d</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(4)),
                   match.group(5),
                   int(match.group(6)))
    match = re.search(
        r"^PLMN\(MCC=(\d+),MNC=(\d+)\)/MRBTS-(\d+)/LNBTS-(\d+)/"
        r"LNMCE-(\d+)/LNM3-(\d+)$",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNMCE-%d/LNM3-%d</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(4)),
                   int(match.group(5)),
                   int(match.group(6)))
    match = re.search(
        r"^HOME_CELL_LTE\(MCC=(\d+),MNC=(\d+),ENBID=(\d+),LCRID=(\d+)\)/"
        r"LNCEL-(\d+)/"
        r"PLMN\(MCC=(\d+),MNC=(\d+)\)",
        string)
    if match:
        return (
                   "<baseId>NE-MRBTS-%d</baseId>"
                   "<localMoid>DN:NE-LNBTS-%d/LNCEL-%d/MCC-%d/MNC-%s/PLMN(MCC=%d,MNC=%s)</localMoid>") % (
                   int(match.group(3)),
                   int(match.group(3)),
                   int(match.group(5)),
                   int(match.group(1)),
                   match.group(2),
                   int(match.group(6)),
                   match.group(7))
    return string


def eci(enb_id, cell_id):
    return (enb_id << 8) + cell_id


if __name__ == "__main__":
    pass
