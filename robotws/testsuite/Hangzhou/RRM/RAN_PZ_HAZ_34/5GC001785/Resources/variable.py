import os
from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_gnb1_id = str(tl.gnbs[0].instance_id)
_gnb2_id = str(tl.gnbs[1].instance_id)
_MRBTSname = 'MRBTS-'+_gnb1_id
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb1_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_SERVEDAMFname = _NRBTSname+'/SERVEDAMF-1'
_SERVEDAMF2name = _NRBTSname2+'/SERVEDAMF-1'
_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_ho_path1 = 'BTS/CELLS/NRCELL-1/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
_ho_path2 = 'BTS/CELLS/NRCELL-2/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
_ho_path3 = 'BTS/CELLS/NRCELL-3/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
_ho_path4 = 'BTS/CELLS/NRCELL-301/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
_ho_path5 = 'BTS/CELLS/NRCELL-302/MCC-'+_mcc+'_MNC-'+_mnc+'/NRANS'
SA_HO_SCE1_counter00 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00301'}
SA_HO_SCE1_counter01 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00302'}
SA_HO_SCE1_counter03 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00303'}
SA_HO_SCE1_counter04 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00304'}
SA_HO_SCE1_counter05 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00301'}
SA_HO_SCE1_counter06 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00302'}
SA_HO_SCE1_counter07 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00303'}
SA_HO_SCE1_counter08 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00304'}
SA_HO_SCE1 = [
    SA_HO_SCE1_counter00, SA_HO_SCE1_counter01, SA_HO_SCE1_counter03, SA_HO_SCE1_counter04,
    SA_HO_SCE1_counter05, SA_HO_SCE1_counter06, SA_HO_SCE1_counter07, SA_HO_SCE1_counter08
]
SA_HO_SCE2_counter00 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00351'}
SA_HO_SCE2_counter01 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00352'}
SA_HO_SCE2_counter02 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00351'}
SA_HO_SCE2_counter03 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00352'}
SA_HO_SCE2 = [SA_HO_SCE2_counter00, SA_HO_SCE2_counter01, SA_HO_SCE2_counter02, SA_HO_SCE2_counter03]

SA_HO_SCE3_counter00 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00321'}
SA_HO_SCE3_counter01 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00322'}
SA_HO_SCE3_counter02 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00321'}
SA_HO_SCE3_counter03 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00322'}
SA_HO_SCE3 = [SA_HO_SCE3_counter00, SA_HO_SCE3_counter01, SA_HO_SCE3_counter02, SA_HO_SCE3_counter03]

SA_HO_SCE4_counter00 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00341'}
SA_HO_SCE4_counter01 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00342'}
SA_HO_SCE4_counter02 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00341'}
SA_HO_SCE4_counter03 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00342'}
SA_HO_SCE4 = [SA_HO_SCE4_counter00, SA_HO_SCE4_counter01, SA_HO_SCE4_counter02, SA_HO_SCE4_counter03]

SA_HO_SCE5_counter00 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00351'}
SA_HO_SCE5_counter01 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00352'}
SA_HO_SCE5_counter02 = {'gnb_id': 2, 'dic_path': _ho_path5, 'counter_id': 'M55145C00351'}
SA_HO_SCE5_counter03 = {'gnb_id': 2, 'dic_path': _ho_path5, 'counter_id': 'M55145C00352'}
SA_HO_SCE5 = [SA_HO_SCE5_counter00, SA_HO_SCE5_counter01, SA_HO_SCE5_counter02, SA_HO_SCE5_counter03]

SA_HO_SCE6_counter00 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00321'}
SA_HO_SCE6_counter01 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00322'}
SA_HO_SCE6_counter02 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00321'}
SA_HO_SCE6_counter03 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00322'}
SA_HO_SCE6 = [SA_HO_SCE6_counter00, SA_HO_SCE6_counter01, SA_HO_SCE6_counter02, SA_HO_SCE6_counter03]

NSA_HO_SCE1_counter00 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01001'}
NSA_HO_SCE1_counter01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01002'}
NSA_HO_SCE1_counter02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01003'}
NSA_HO_SCE1_counter03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01004'}
NSA_HO_SCE1_counter04 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01005'}
NSA_HO_SCE1_counter05 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01006'}
NSA_HO_SCE1_counter06 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01007'}
NSA_HO_SCE1_counter07 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NINFC', 'counter_id': 'M55120C01008'}
NSA_HO_SCE1_counter08 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01001'}
NSA_HO_SCE1_counter09 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01002'}
NSA_HO_SCE1_counter10 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01003'}
NSA_HO_SCE1_counter11 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01004'}
NSA_HO_SCE1_counter12 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01005'}
NSA_HO_SCE1_counter13 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01006'}
NSA_HO_SCE1_counter14 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01007'}
NSA_HO_SCE1_counter15 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NINFC', 'counter_id': 'M55120C01008'}
NSA_HO_SCE1 = [
    NSA_HO_SCE1_counter00, NSA_HO_SCE1_counter01, NSA_HO_SCE1_counter02, NSA_HO_SCE1_counter03,
    NSA_HO_SCE1_counter04, NSA_HO_SCE1_counter05, NSA_HO_SCE1_counter06, NSA_HO_SCE1_counter07,
    NSA_HO_SCE1_counter08, NSA_HO_SCE1_counter09, NSA_HO_SCE1_counter10, NSA_HO_SCE1_counter11,
    NSA_HO_SCE1_counter12, NSA_HO_SCE1_counter13, NSA_HO_SCE1_counter14, NSA_HO_SCE1_counter15
]
NSA_HO_SCE2_counter00 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NX2CC', 'counter_id': 'M55112C02501'}
NSA_HO_SCE2_counter01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NX2CC', 'counter_id': 'M55112C02502'}
NSA_HO_SCE2_counter02 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C02501'}
NSA_HO_SCE2_counter03 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C02502'}
NSA_HO_SCE2 = [NSA_HO_SCE2_counter00, NSA_HO_SCE2_counter01, NSA_HO_SCE2_counter02, NSA_HO_SCE2_counter03]
NSA_HO_SCE3_counter00 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00001'}
NSA_HO_SCE3_counter01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00002'}
NSA_HO_SCE3_counter02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00003'}
NSA_HO_SCE3_counter03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00004'}
NSA_HO_SCE3_counter04 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00005'}
NSA_HO_SCE3_counter05 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00006'}
NSA_HO_SCE3_counter06 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00007'}
NSA_HO_SCE3_counter07 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NIFC', 'counter_id': 'M55151C00008'}
NSA_HO_SCE3_counter08 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00001'}
NSA_HO_SCE3_counter09 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00002'}
NSA_HO_SCE3_counter10 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00003'}
NSA_HO_SCE3_counter11 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00004'}
NSA_HO_SCE3_counter12 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00005'}
NSA_HO_SCE3_counter13 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00006'}
NSA_HO_SCE3_counter14 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00007'}
NSA_HO_SCE3_counter15 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NIFC', 'counter_id': 'M55151C00008'}
NSA_HO_SCE3 = [
    NSA_HO_SCE3_counter00, NSA_HO_SCE3_counter01, NSA_HO_SCE3_counter02, NSA_HO_SCE3_counter03,
    NSA_HO_SCE3_counter04, NSA_HO_SCE3_counter05, NSA_HO_SCE3_counter06, NSA_HO_SCE3_counter07,
    NSA_HO_SCE3_counter08, NSA_HO_SCE3_counter09, NSA_HO_SCE3_counter10, NSA_HO_SCE3_counter11,
    NSA_HO_SCE3_counter12, NSA_HO_SCE3_counter13, NSA_HO_SCE3_counter14, NSA_HO_SCE3_counter15
]
NSA_HO_SCE4_counter00 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C02503'}
NSA_HO_SCE4_counter01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C02504'}
NSA_HO_SCE4_counter02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C02506'}
NSA_HO_SCE4_counter03 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C02503'}
NSA_HO_SCE4_counter04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C02504'}
NSA_HO_SCE4_counter05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C02506'}
NSA_HO_SCE4 = [
    NSA_HO_SCE4_counter00, NSA_HO_SCE4_counter01, NSA_HO_SCE4_counter02, NSA_HO_SCE4_counter03,
    NSA_HO_SCE4_counter04, NSA_HO_SCE4_counter05
]
NSA_HO_SCE5_counter00 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C02501'}
NSA_HO_SCE5_counter01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C02502'}
NSA_HO_SCE5_counter02 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C02501'}
NSA_HO_SCE5_counter03 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C02502'}
NSA_HO_SCE5 = [NSA_HO_SCE5_counter00, NSA_HO_SCE5_counter01, NSA_HO_SCE5_counter02, NSA_HO_SCE5_counter03]
NSA_HO_SCE6_counter00 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00001'}
NSA_HO_SCE6_counter01 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00002'}
NSA_HO_SCE6_counter02 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00003'}
NSA_HO_SCE6_counter03 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00004'}
NSA_HO_SCE6_counter04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00005'}
NSA_HO_SCE6_counter05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00006'}
NSA_HO_SCE6_counter06 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00007'}
NSA_HO_SCE6_counter07 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NIFC', 'counter_id': 'M55151C00008'}
NSA_HO_SCE6_counter08 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00001'}
NSA_HO_SCE6_counter09 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00002'}
NSA_HO_SCE6_counter10 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00003'}
NSA_HO_SCE6_counter11 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00004'}
NSA_HO_SCE6_counter12 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00005'}
NSA_HO_SCE6_counter13 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00006'}
NSA_HO_SCE6_counter14 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00007'}
NSA_HO_SCE6_counter15 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NIFC', 'counter_id': 'M55151C00008'}
NSA_HO_SCE6 = [
    NSA_HO_SCE6_counter00, NSA_HO_SCE6_counter01, NSA_HO_SCE6_counter02, NSA_HO_SCE6_counter03,
    NSA_HO_SCE6_counter04, NSA_HO_SCE6_counter05, NSA_HO_SCE6_counter06, NSA_HO_SCE6_counter07,
    NSA_HO_SCE6_counter08, NSA_HO_SCE6_counter09, NSA_HO_SCE6_counter10, NSA_HO_SCE6_counter11,
    NSA_HO_SCE6_counter12, NSA_HO_SCE6_counter13, NSA_HO_SCE6_counter14, NSA_HO_SCE6_counter15
]
NSA_HO_SCE7_counter00 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C03501'}
NSA_HO_SCE7_counter01 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C03502'}
NSA_HO_SCE7_counter02 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C03503'}
NSA_HO_SCE7_counter03 = {'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb2_id + '/LTEMO', 'counter_id': 'M55128C00501'}
NSA_HO_SCE7_counter04 = {'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb2_id + '/LTEMO', 'counter_id': 'M55128C00502'}
NSA_HO_SCE7_counter05 = {'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb2_id + '/LTEMO', 'counter_id': 'M55128C00503'}
NSA_HO_SCE7_counter06 = {'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb2_id + '/LTEMO', 'counter_id': 'M55128C00504'}
NSA_HO_SCE7_counter07 = {'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb2_id + '/LTEMO', 'counter_id': 'M55128C00505'}
NSA_HO_SCE7 = [
    NSA_HO_SCE7_counter00, NSA_HO_SCE7_counter01, NSA_HO_SCE7_counter02, NSA_HO_SCE7_counter03,
    NSA_HO_SCE7_counter04, NSA_HO_SCE7_counter05, NSA_HO_SCE7_counter06, NSA_HO_SCE7_counter07,
]
NSA_HO_SCE8_counter00 = {'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/LTEMO', 'counter_id': 'M55128C00001'}
NSA_HO_SCE8_counter01 = {'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/LTEMO', 'counter_id': 'M55128C00002'}
NSA_HO_SCE8_counter02 = {'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/LTEMO', 'counter_id': 'M55128C00003'}
NSA_HO_SCE8_counter03 = {'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/LTEMO', 'counter_id': 'M55128C00004'}
NSA_HO_SCE8_counter04 = {'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/LTEMO', 'counter_id': 'M55128C00005'}
NSA_HO_SCE8 = [
    NSA_HO_SCE8_counter00, NSA_HO_SCE8_counter01, NSA_HO_SCE8_counter02,
    NSA_HO_SCE8_counter03, NSA_HO_SCE8_counter04
]
Counter_M55309C01001_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NMSDU', 'counter_id': 'M55309C01001'}
Counter_M55309C01001_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NMSDU', 'counter_id': 'M55309C01001'}
Counter_M55309C01001_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NMSDU', 'counter_id': 'M55309C01001'}
Counter_M55309C01001_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NMSDU', 'counter_id': 'M55309C01001'}
Counter_M55309C01001_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NMSDU', 'counter_id': 'M55309C01001'}
SA_DL_MAC_SDU_VOL_DTCH_check = [
    Counter_M55309C01001_01, Counter_M55309C01001_02, Counter_M55309C01001_03, Counter_M55309C01001_04,
    Counter_M55309C01001_05
]
Counter_M55308C02002_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NCELA', 'counter_id': 'M55308C02002'}
Counter_M55308C02002_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NCELA', 'counter_id': 'M55308C02002'}
Counter_M55308C02002_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NCELA', 'counter_id': 'M55308C02002'}
Counter_M55308C02002_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NCELA', 'counter_id': 'M55308C02002'}
Counter_M55308C02002_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NCELA', 'counter_id': 'M55308C02002'}
SA_ACC_UE_UL_DRB_DATA_check = [
    Counter_M55308C02002_01, Counter_M55308C02002_02, Counter_M55308C02002_03, Counter_M55308C02002_04,
    Counter_M55308C02002_05
]
Counter_M55125C01501_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C01501'}
Counter_M55125C01502_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C01502'}
Counter_M55125C01501_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NNGCC', 'counter_id': 'M55125C01501'}
Counter_M55125C01502_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NNGCC', 'counter_id': 'M55125C01502'}
Counter_M55125C01501_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C01501'}
Counter_M55125C01502_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C01502'}
Counter_M55125C01501_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NNGCC', 'counter_id': 'M55125C01501'}
Counter_M55125C01502_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NNGCC', 'counter_id': 'M55125C01502'}
Counter_M55125C01501_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NNGCC', 'counter_id': 'M55125C01501'}
Counter_M55125C01502_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NNGCC', 'counter_id': 'M55125C01502'}
SA_NG_PATH_SWITCH_RATE = [
    Counter_M55125C01501_01, Counter_M55125C01502_01, Counter_M55125C01501_02, Counter_M55125C01502_02,
    Counter_M55125C01501_03, Counter_M55125C01502_03, Counter_M55125C01501_04, Counter_M55125C01502_04,
    Counter_M55125C01501_05, Counter_M55125C01502_05
]


Counter_M55145C01501_01 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C01501'}
Counter_M55138C01001_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/RSACU', 'counter_id': 'M55138C01001'}
Counter_M55145C01501_02 = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C01501'}
Counter_M55138C01001_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/RSACU', 'counter_id': 'M55138C01001'}
Counter_M55145C01501_03 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C01501'}
Counter_M55138C01001_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/RSACU', 'counter_id': 'M55138C01001'}
Counter_M55145C01501_04 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C01501'}
Counter_M55138C01001_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/RSACU', 'counter_id': 'M55138C01001'}
Counter_M55145C01501_05 = {'gnb_id': 2, 'dic_path': _ho_path5, 'counter_id': 'M55145C01501'}
Counter_M55138C01001_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/RSACU', 'counter_id': 'M55138C01001'}
SA_NR_5238_GRB_DRB_SETUP_SUCESS_RATE = [
    Counter_M55145C01501_01, Counter_M55138C01001_01, Counter_M55145C01501_02, Counter_M55138C01001_02,
    Counter_M55145C01501_03, Counter_M55138C01001_03, Counter_M55145C01501_04, Counter_M55138C01001_04,
    Counter_M55145C01501_05, Counter_M55138C01001_05
]

Counter_M55129C00003_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00003'}
Counter_M55129C00004_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00004'}
Counter_M55129C00005_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00005'}
Counter_M55129C00003_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00003'}
Counter_M55129C00004_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00004'}
Counter_M55129C00005_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00005'}
Counter_M55129C00003_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00003'}
Counter_M55129C00004_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00004'}
Counter_M55129C00005_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00005'}
Counter_M55129C00003_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00003'}
Counter_M55129C00004_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00004'}
Counter_M55129C00005_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00005'}
Counter_M55129C00003_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00003'}
Counter_M55129C00004_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00004'}
Counter_M55129C00005_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRLFC', 'counter_id': 'M55129C00005'}
SA_NR_RLF_COUNTERS = [
    Counter_M55129C00003_01, Counter_M55129C00004_01, Counter_M55129C00005_01, Counter_M55129C00003_02,
    Counter_M55129C00004_02, Counter_M55129C00005_02, Counter_M55129C00003_03, Counter_M55129C00004_03,
    Counter_M55129C00005_03, Counter_M55129C00003_04, Counter_M55129C00004_04, Counter_M55129C00005_04,
    Counter_M55129C00003_05, Counter_M55129C00004_05, Counter_M55129C00005_05
]

Counter_M55124C00502_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00502'}
Counter_M55124C00503_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00503'}
Counter_M55124C00504_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00504'}
Counter_M55124C00505_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00505'}
Counter_M55124C00502_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00502'}
Counter_M55124C00503_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00503'}
Counter_M55124C00504_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00504'}
Counter_M55124C00505_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00505'}
Counter_M55124C00502_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00502'}
Counter_M55124C00503_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00503'}
Counter_M55124C00504_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00504'}
Counter_M55124C00505_03 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00505'}
Counter_M55124C00502_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00502'}
Counter_M55124C00503_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00503'}
Counter_M55124C00504_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00504'}
Counter_M55124C00505_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00505'}
Counter_M55124C00502_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00502'}
Counter_M55124C00503_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00503'}
Counter_M55124C00504_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00504'}
Counter_M55124C00505_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NRRCC', 'counter_id': 'M55124C00505'}
SA_NR_REESTAB_COUNTERS = [
    Counter_M55124C00502_01, Counter_M55124C00503_01, Counter_M55124C00504_01, Counter_M55124C00505_01,
    Counter_M55124C00502_02, Counter_M55124C00503_02, Counter_M55124C00504_02, Counter_M55124C00505_02,
    Counter_M55124C00502_03, Counter_M55124C00503_03, Counter_M55124C00504_03, Counter_M55124C00505_03,
    Counter_M55124C00502_04, Counter_M55124C00503_04, Counter_M55124C00504_04, Counter_M55124C00505_04,
    Counter_M55124C00502_05, Counter_M55124C00503_05, Counter_M55124C00504_05, Counter_M55124C00505_05
]

Counter_NGU_QOS_GRP_00 = {
    'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C02007'}
Counter_NGU_QOS_GRP_01 = {
    'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C02008'}
Counter_NGU_QOS_GRP_02 = {
    'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C04007'}
Counter_NGU_QOS_GRP_03 = {
    'gnb_id': 1, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C04008'}
Counter_NGU_QOS_GRP_04 = {
    'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C02007'}
Counter_NGU_QOS_GRP_05 = {
    'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C02008'}
Counter_NGU_QOS_GRP_06 = {
    'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C04007'}
Counter_NGU_QOS_GRP_07 = {
    'gnb_id': 2, 'dic_path': 'BTS/BTS/NRBTS-' + _gnb1_id + '/NRNGU', 'counter_id': 'M55327C04008'}
SA_NGU_QOS_GRP_07_08_check = [
    Counter_NGU_QOS_GRP_00, Counter_NGU_QOS_GRP_01, Counter_NGU_QOS_GRP_02,
    Counter_NGU_QOS_GRP_03, Counter_NGU_QOS_GRP_04, Counter_NGU_QOS_GRP_05,
    Counter_NGU_QOS_GRP_06, Counter_NGU_QOS_GRP_07
]

Counter_M55112C00008_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NX2CC', 'counter_id': 'M55112C00008'}
Counter_M55112C00007_01 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NX2CC', 'counter_id': 'M55112C00007'}
Counter_M55112C00008_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C00008'}
Counter_M55112C00007_02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-2/NX2CC', 'counter_id': 'M55112C00007'}
Counter_M55112C00008_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NX2CC', 'counter_id': 'M55112C00008'}
Counter_M55112C00007_03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NX2CC', 'counter_id': 'M55112C00007'}
Counter_M55112C00008_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C00008'}
Counter_M55112C00007_04 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NX2CC', 'counter_id': 'M55112C00007'}
Counter_M55112C00008_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C00008'}
Counter_M55112C00007_05 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-302/NX2CC', 'counter_id': 'M55112C00007'}
NSA_SGNB_RELEASE_CONFIRM_RATE = [
    Counter_M55112C00008_01, Counter_M55112C00007_01, Counter_M55112C00008_02, Counter_M55112C00007_02,
    Counter_M55112C00008_03, Counter_M55112C00007_03, Counter_M55112C00008_04, Counter_M55112C00007_04,
    Counter_M55112C00008_05, Counter_M55112C00007_05
]

SA_HO_SCE4_counter00_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00301'}
SA_HO_SCE4_counter01_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00302'}
SA_HO_SCE4_counter03_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00303'}
SA_HO_SCE4_counter04_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00304'}
SA_HO_SCE4_counter05_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00301'}
SA_HO_SCE4_counter06_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00302'}
SA_HO_SCE4_counter07_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00303'}
SA_HO_SCE4_counter08_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00304'}
SA_HO_SCE4_DUAL_CALL = [
    SA_HO_SCE4_counter00_DUAL_CALL, SA_HO_SCE4_counter01_DUAL_CALL, SA_HO_SCE4_counter03_DUAL_CALL,
    SA_HO_SCE4_counter04_DUAL_CALL, SA_HO_SCE4_counter05_DUAL_CALL, SA_HO_SCE4_counter06_DUAL_CALL,
    SA_HO_SCE4_counter07_DUAL_CALL, SA_HO_SCE4_counter08_DUAL_CALL
]

SA_HO_SCE5_counter00_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00321'}
SA_HO_SCE5_counter01_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path2, 'counter_id': 'M55145C00322'}
SA_HO_SCE5_counter02_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55145C00321'}
SA_HO_SCE5_counter03_DUAL_CALL = {'gnb_id': 1, 'dic_path': _ho_path5, 'counter_id': 'M55145C00322'}
SA_HO_SCE5_DUAL_CALL = [
    SA_HO_SCE5_counter00_DUAL_CALL, SA_HO_SCE5_counter01_DUAL_CALL,
    SA_HO_SCE5_counter02_DUAL_CALL, SA_HO_SCE5_counter03_DUAL_CALL
]

VONR_IAHO_counter_001 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09524'}
VONR_IAHO_counter_002 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09525'}
VONR_IAHO_counter_003 = {'gnb_id': 1, 'dic_path':  _ho_path1, 'counter_id': 'M55145C00301'}
VONR_IAHO_counter_004 = {'gnb_id': 1, 'dic_path':  _ho_path1, 'counter_id': 'M55145C00302'}
VONR_IAHO_counter_005 = {'gnb_id': 1, 'dic_path':  _ho_path1, 'counter_id': 'M55145C00303'}
VONR_IAHO_counter_006 = {'gnb_id': 1, 'dic_path':  _ho_path1, 'counter_id': 'M55145C00304'}
VONR_IAHO_counter_007 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09517'}
VONR_IAHO_counter_008 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09518'}
VONR_IAHO_counter_009 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09515'}
VONR_IAHO_counter_010 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C09524'}
VONR_IAHO_counter_011 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C09525'}
VONR_IAHO_counter_012 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00301'}
VONR_IAHO_counter_013 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00302'}
VONR_IAHO_counter_014 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00303'}
VONR_IAHO_counter_015 = {'gnb_id': 1, 'dic_path': _ho_path3, 'counter_id': 'M55145C00304'}
VONR_IAHO_counter_016 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C09517'}
VONR_IAHO_counter_017 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C09518'}
VONR_IAHO_counter_018 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-3/NNGCC', 'counter_id': 'M55125C09515'}
VONR_INTRA_F_INTRA_GNB_HO = [
    VONR_IAHO_counter_001, VONR_IAHO_counter_002, VONR_IAHO_counter_003, VONR_IAHO_counter_004,
    VONR_IAHO_counter_005, VONR_IAHO_counter_006, VONR_IAHO_counter_007, VONR_IAHO_counter_008,
    VONR_IAHO_counter_009, VONR_IAHO_counter_010, VONR_IAHO_counter_011, VONR_IAHO_counter_012,
    VONR_IAHO_counter_013, VONR_IAHO_counter_014, VONR_IAHO_counter_015, VONR_IAHO_counter_016,
    VONR_IAHO_counter_017, VONR_IAHO_counter_018
]

VONR_IFHO_counter_001 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09524'}
VONR_IFHO_counter_002 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09525'}
VONR_IFHO_counter_003 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00351'}
VONR_IFHO_counter_004 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00352'}
VONR_IFHO_counter_005 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09517'}
VONR_IFHO_counter_006 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09518'}
VONR_IFHO_counter_007 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09515'}
VONR_IFHO_counter_008 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NNGCC', 'counter_id': 'M55125C09524'}
VONR_IFHO_counter_009 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NNGCC', 'counter_id': 'M55125C09525'}
VONR_IFHO_counter_010 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00351'}
VONR_IFHO_counter_011 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00352'}
VONR_IFHO_counter_012 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09517'}
VONR_IFHO_counter_013 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-1/NNGCC', 'counter_id': 'M55125C09518'}
VONR_IFHO_counter_014 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NNGCC', 'counter_id': 'M55125C09515'}
VONR_INTER_F_INTER_GNB_HO = [
    VONR_IFHO_counter_001, VONR_IFHO_counter_002, VONR_IFHO_counter_003, VONR_IFHO_counter_004,
    VONR_IFHO_counter_005, VONR_IFHO_counter_006, VONR_IFHO_counter_007, VONR_IFHO_counter_008,
    VONR_IFHO_counter_009, VONR_IFHO_counter_010, VONR_IFHO_counter_011, VONR_IFHO_counter_012,
    VONR_IFHO_counter_013, VONR_IFHO_counter_014
]

EMC_IFHO_counter_001 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NMOCU', 'counter_id': 'M55147C00501'}
EMC_IFHO_counter_002 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NMOCU', 'counter_id': 'M55147C00502'}
EMC_IFHO_counter_003 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NMOCU', 'counter_id': 'M55147C00503'}
EMC_IFHO_counter_004 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NMOCU', 'counter_id': 'M55147C00504'}
EMC_IFHO_counter_005 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00351'}
EMC_IFHO_counter_006 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00352'}
EMC_IFHO_counter_007 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NMOCU', 'counter_id': 'M55147C00501'}
EMC_IFHO_counter_008 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NMOCU', 'counter_id': 'M55147C00502'}
EMC_IFHO_counter_009 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NMOCU', 'counter_id': 'M55147C00503'}
EMC_IFHO_counter_010 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NMOCU', 'counter_id': 'M55147C00504'}
EMC_IFHO_counter_011 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00351'}
EMC_IFHO_counter_012 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00352'}

EMC_INTER_F_INTER_GNB_HO = [
    EMC_IFHO_counter_001, EMC_IFHO_counter_002, EMC_IFHO_counter_003, EMC_IFHO_counter_004,
    EMC_IFHO_counter_005, EMC_IFHO_counter_006, EMC_IFHO_counter_007, EMC_IFHO_counter_008,
    EMC_IFHO_counter_009, EMC_IFHO_counter_010, EMC_IFHO_counter_011, EMC_IFHO_counter_012
]

SA_PGHO_counter00 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00351'}
SA_PGHO_counter01 = {'gnb_id': 1, 'dic_path': _ho_path1, 'counter_id': 'M55145C00352'}
SA_PGHO_counter02 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NXNCC', 'counter_id': 'M55143C00003'}
SA_PGHO_counter03 = {'gnb_id': 1, 'dic_path': 'BTS/CELLS/NRCELL-1/NXNCC', 'counter_id': 'M55143C00007'}
SA_PGHO_counter04 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00351'}
SA_PGHO_counter05 = {'gnb_id': 2, 'dic_path': _ho_path4, 'counter_id': 'M55145C00352'}
SA_PGHO_counter06 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NXNCC', 'counter_id': 'M55143C00003'}
SA_PGHO_counter07 = {'gnb_id': 2, 'dic_path': 'BTS/CELLS/NRCELL-301/NXNCC', 'counter_id': 'M55143C00007'}
SA_IF_PGHO = [
    SA_PGHO_counter00, SA_PGHO_counter01, SA_PGHO_counter02, SA_PGHO_counter03,
    SA_PGHO_counter04, SA_PGHO_counter05, SA_PGHO_counter06, SA_PGHO_counter07
]

AMF_STATUS_UNLOCKED = [
    dict(value='Unlocked', dist_name=_SERVEDAMFname, parameter='administrativeState')
]

AMF_STATUS_LOCKED = [
    dict(value='Locked', dist_name=_SERVEDAMFname, parameter='administrativeState')
]

AMF_STATUS_UNLOCKED_GNB2 = [
    dict(value='Unlocked', dist_name=_SERVEDAMF2name, parameter='administrativeState')
]

AMF_STATUS_LOCKED_GNB2 = [
    dict(value='Locked', dist_name=_SERVEDAMF2name, parameter='administrativeState')
]
