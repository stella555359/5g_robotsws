"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
# Current HWs:
#  BBMOD hw type: ABIA, Primary Soc: K2A, Secondary SOCs: K2B, K2C, K2D
#  BBMOD hw type: ABIO, Primary Soc: SNF, Secondary SOCs: LOKI#A, LOKI#B
#  BBMOD hw type: ABIN, Primary Soc: SNF, Secondary SOCs: LOKI#A
#  BBMOD hw type: ABIC, Primary Soc: LFA, Secondary SOCs: LFB, LUNUM
#  BBMOD hw type: ABIP, Primary Soc: Marlin, Secondary SOCs: Thor
#  BBMOD hw type: ABIQ, Primary Soc: Marlin, Secondary SOCs: Magni
#  BBMOD hw type: ABIL, Primary Soc: XEONA, Secondary SOCs: XEONB, LONER

bbmods_socs_dict = {
    "ABIA": {
        "primary_soc": "K2A",
        "secondary_socs": ["K2B", "K2C", "K2D"]
        },
    "ABIO": {
        "primary_soc": "SNF",
        "secondary_socs": ["LOKI#A", "LOKI#B"]
    },
    "ABIN": {
        "primary_soc": "SNF",
        "secondary_socs": ["LOKI#A"]
    },
    "ABIC": {
        "primary_soc": "LFA",
        "secondary_socs": ["LFB", "LUNUM"]
    },
    "ABIP": {
        "primary_soc": "Marlin",
        "secondary_socs": ["Thor"]
    },
    "ABIQ": {
        "primary_soc": "Marlin",
        "secondary_socs": ["Magni"]
    },
    "ABIL": {
        "primary_soc": "XEONA",
        "secondary_socs": ["XEONB", "LONER"]
    }
}


def get_secondary_socs(bbmod_name):
    print("Get secondary socs of {}".format(bbmod_name))
    for bbmod in bbmods_socs_dict:
        if bbmod in bbmod_name:
            print("Secondary socs of {} are {}".format(bbmod_name, bbmods_socs_dict[bbmod]["secondary_socs"]))
            return bbmods_socs_dict[bbmod]["secondary_socs"]
    print("Secondary socs of {} not found.".format(bbmod_name))
    return None


def get_primary_soc(bbmod_name):
    print("Get primary socs of {}".format(bbmod_name))
    for bbmod in bbmods_socs_dict:
        if bbmod in bbmod_name:
            print("Primary soc of {} is {}".format(bbmod_name, bbmods_socs_dict[bbmod]["primary_soc"]))
            return bbmods_socs_dict[bbmod]["primary_soc"]
    print("Primary soc of {} not found.".format(bbmod_name))
    return None


def get_bbmod_hex_position(bbmod_name, side, soc=None):
    soc_number = ""
    if soc:
        print("Get hexadecimal value of the position of {} of {} ({})".format(soc, bbmod_name, side))
        if soc in ("K2A", "SNF", "LFA", "Marlin", "XEONA"):
            soc_number = "3"
        if soc in ("K2B", "LOKI#A", "LFB", "Thor", "Magni", "XEONB"):
            soc_number = "4"
        elif soc in ("K2C", "LOKI#B", "LUNUM", "LONER"):
            soc_number = "5"
        elif soc == "K2D":
            soc_number = "6"
    else:
        print("Get hexadecimal value of the position of {} ({})".format(bbmod_name, side))
    side_hex = "1"  # This is if bbmod is connected to smod on left side of amia
    bbmod_port = "2"  # Position of the bottom BBMOD
    if "." in bbmod_name or "right" in side or "4" in side:  # Fullrack 0x22==ABIA2.1 or ABIA1 and SMOD on right side
        side_hex = "2"
    if bbmod_name[-1] == "1":
        bbmod_port = "2"  # bottom BBMOD
    elif bbmod_name[-1] == '2':
        bbmod_port = "3"  # middle BBMOD
    elif bbmod_name[-1] == "3":
        bbmod_port = "4"  # top BBMOD
    else:
        print("Numbering in BBMOD object name is expected to be 1-3, {} is not valid BBMOD name!".format(bbmod_name))
    print("Returning position: {}{}{}".format(side_hex, bbmod_port, soc_number))
    return "{}{}{}".format(side_hex, bbmod_port, soc_number)


def get_kepler_hex(kepler):
    if "A" in kepler:
        return '0x31'
    elif "B" in kepler:
        return '0x41'
    elif "C" in kepler:
        return '0x51'
    else:  # K2D
        return '0x61'
