"""
Variables for the feature CB008242.

:copyright: Nokia Networks
:author: Sara Nowak
:contact: sara.nowak@nokia.com
"""

from dataclasses import dataclass


@dataclass
class Counter:
    id: str
    label: str
    localmoid: str


cu_overload_pcap_filename = 'CU_OVL_F1AP.pcap'

RAD_HEXs = {
    "rdOverloadHighThreshold": "0x89006f"
}

static_uac_message = f"""
    systemInformationBlockType1(
        contains(uac-BarringForCommon: 1 item),
        contains(UAC-BarringPerCat),
        contains(accessCategory=11),
        contains(uac-BarringInfoSetList: 1 item),
        contains(UAC-BarringInfoSet),
        contains(uac-BarringFactor=p00 (0)),
        contains(uac-BarringTime=s64 (4))
    )
"""

th4_auto_uac_message_G_100 = f"""
    systemInformationBlockType1(
        contains(uac-BarringForCommon: 4 items),
        contains(UAC-BarringPerCat),
        contains(accessCategory=2),
        contains(accessCategory=3),
        contains(accessCategory=11),
        contains(accessCategory=12),
        contains(uac-BarringInfoSetList: 1 item),
        contains(UAC-BarringInfoSet),
        contains(uac-BarringFactor=p00 (0)),
        contains(uac-BarringTime=s512 (7)),
        contains(uac-BarringForAccessIdentity=*1100 000*)
    )
"""

th4_auto_uac_message = f"""
    systemInformationBlockType1(
        contains(uac-BarringForCommon: 3 items),
        contains(UAC-BarringPerCat),
        contains(accessCategory=2),
        contains(accessCategory=13),
        contains(accessCategory=14),
        contains(uac-BarringInfoSetList: 1 item),
        contains(UAC-BarringInfoSet),
        contains(uac-BarringFactor=p00 (0)),
        contains(uac-BarringTime=s512 (7)),
        contains(uac-BarringForAccessIdentity=*1100 000*)
    )
"""

th3_auto_uac_message = f"""
    systemInformationBlockType1(
        contains(uac-BarringForCommon: 2 items),
        contains(UAC-BarringPerCat),
        contains(accessCategory=13),
        contains(accessCategory=14),
        contains(uac-BarringInfoSetList: 1 item),
        contains(UAC-BarringInfoSet),
        contains(uac-BarringFactor=p25 (5)),
        contains(uac-BarringTime=s128 (5)),
        contains(uac-BarringForAccessIdentity=*0000 000*)
    )
"""

th2_auto_uac_message = f"""
    systemInformationBlockType1(
        contains(uac-BarringForCommon: 2 items),
        contains(UAC-BarringPerCat),
        contains(accessCategory=13),
        contains(accessCategory=14),
        contains(uac-BarringInfoSetList: 1 item),
        contains(UAC-BarringInfoSet),
        contains(uac-BarringFactor=p70 (10)),
        contains(uac-BarringTime=s16 (2)),
        contains(uac-BarringForAccessIdentity=*0000 000*)
    )
"""

th1_auto_uac_message = f"""
    systemInformationBlockType1(
        contains(uac-BarringForCommon: 2 items),
        contains(UAC-BarringPerCat),
        contains(accessCategory=13),
        contains(accessCategory=14),
        contains(uac-BarringInfoSetList: 1 item),
        contains(UAC-BarringInfoSet),
        contains(uac-BarringFactor=p95 (15)),
        contains(uac-BarringTime=s4 (0)),
        contains(uac-BarringForAccessIdentity=*0000 000*)
    )
"""

network_access_rate_reduction_message = f"""
    NetworkAccessRateReduction
"""

time_auto_uac_ovl_counters = [
    Counter(
        id='M55164C00001',
        label='TIME_AUTO_UAC_OVL',
        localmoid=f'PLMN-PLMN/MRBTS-77060/NRBTS-77060/NRCELL-250'
    )
]
