import os
from typing import Dict, Union

from robot.libraries.BuiltIn import BuiltIn

tl = BuiltIn().get_variable_value("${tl}")
CFG_DIR = os.path.dirname(os.path.abspath(__file__))
_gnb1_id = str(tl.gnbs[0].cu.instance_id)
_gnb2_id = str(tl.gnbs[1].cu.instance_id)
_MRBTSname = 'MRBTS-'+_gnb1_id
_MRBTSname2 = 'MRBTS-'+_gnb2_id
_NRBTSname = _MRBTSname+'/NRBTS-'+_gnb1_id
_NRBTSname2 = _MRBTSname2+'/NRBTS-'+_gnb2_id
_SERVEDAMFname = _NRBTSname+'/SERVEDAMF-1'
_SERVEDAMF2name = _NRBTSname2+'/SERVEDAMF-1'
_mcc = str(tl.core.mcc)
_mnc = str(tl.core.mnc)
_NRCELL1 = _NRBTSname+'/NRCELL-1'
_NRCELL2 = _NRBTSname+'/NRCELL-2'
_NRCELL3 = _NRBTSname+'/NRCELL-3'
_NRCELL4 = _NRBTSname2+'/NRCELL-4'
_ho_path1 = _NRBTSname+'/NRCELL-1/MCC-'+_mcc+'/MNC-'+_mnc
_ho_path2 = _NRBTSname+'/NRCELL-2/MCC-'+_mcc+'/MNC-'+_mnc
_ho_path3 = _NRBTSname+'/NRCELL-3/MCC-'+_mcc+'/MNC-'+_mnc
_ho_path4 = _NRBTSname2+'/NRCELL-4/MCC-'+_mcc+'/MNC-'+_mnc

SA_KPI_ID = ['NR_5175b', 'NR_5176b', 'NR_5177b', 'NR_5376a', 'NR_5377a', 'NR_5204a', 'NR_5206a',
             'NR_5380a', 'NR_5381a', 'NR_5202a', 'NR_5410a', 'NR_5412a', 'NR_5413a', 'NR_5195a',
             'NR_5197a', 'NR_5198a', 'NR_5671a', 'NR_5672a']

NSA_KPI_ID = ['NR_5047b', 'NR_5048b', 'NR_5049b', 'NR_5038b', 'NR_5041b', 'NR_5042b', 'NR_5189b',
              'NR_5190b', 'NR_5191b', 'NR_5034a', 'NR_5730a', 'NR_5731a', 'NR_5185b', 'NR_5186b',
              'NR_5187b', 'NR_5071a', 'NR_5074a', 'NR_5732a', 'NR_5750a', 'NR_574', 'NR_575']

SA_HO_SCE1_counter00 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00301', 'meas_id': '55145'}
SA_HO_SCE1_counter01 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00302', 'meas_id': '55145'}
SA_HO_SCE1_counter02 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00303', 'meas_id': '55145'}
SA_HO_SCE1_counter03 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00304', 'meas_id': '55145'}
SA_HO_SCE1_counter04 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00301', 'meas_id': '55145'}
SA_HO_SCE1_counter05 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00302', 'meas_id': '55145'}
SA_HO_SCE1_counter06 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00303', 'meas_id': '55145'}
SA_HO_SCE1_counter07 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00304', 'meas_id': '55145'}
SA_HO_SCE1 = [
    SA_HO_SCE1_counter00, SA_HO_SCE1_counter01, SA_HO_SCE1_counter02, SA_HO_SCE1_counter03,
    SA_HO_SCE1_counter04, SA_HO_SCE1_counter05, SA_HO_SCE1_counter06, SA_HO_SCE1_counter07,
]

SA_HO_SCE2_counter00 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C03501', 'meas_id': '55145'}
SA_HO_SCE2_counter01 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C03502', 'meas_id': '55145'}
SA_HO_SCE2_counter02 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C03503', 'meas_id': '55145'}
SA_HO_SCE2_counter03 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C03504', 'meas_id': '55145'}
SA_HO_SCE2_counter04 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03501', 'meas_id': '55145'}
SA_HO_SCE2_counter05 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03502', 'meas_id': '55145'}
SA_HO_SCE2_counter06 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03503', 'meas_id': '55145'}
SA_HO_SCE2_counter07 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03504', 'meas_id': '55145'}
SA_HO_SCE2 = [
    SA_HO_SCE2_counter00, SA_HO_SCE2_counter01, SA_HO_SCE2_counter02, SA_HO_SCE2_counter03,
    SA_HO_SCE2_counter04, SA_HO_SCE2_counter05, SA_HO_SCE2_counter06, SA_HO_SCE2_counter07,
]

SA_HO_SCE3_counter00 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00341', 'meas_id': '55145'}
SA_HO_SCE3_counter01 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00342', 'meas_id': '55145'}
SA_HO_SCE3_counter02 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00341', 'meas_id': '55145'}
SA_HO_SCE3_counter03 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00342', 'meas_id': '55145'}
SA_HO_SCE3 = [
    SA_HO_SCE3_counter00, SA_HO_SCE3_counter01, SA_HO_SCE3_counter02, SA_HO_SCE3_counter03,
]

SA_HO_SCE4_counter00 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00351', 'meas_id': '55145'}
SA_HO_SCE4_counter01 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00352', 'meas_id': '55145'}
SA_HO_SCE4_counter02 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00351', 'meas_id': '55145'}
SA_HO_SCE4_counter03 = {'gnb_id': 1, 'dic_path': _ho_path4, 'counter_id': 'M55145C00352', 'meas_id': '55145'}
SA_HO_SCE4 = [
    SA_HO_SCE4_counter00, SA_HO_SCE4_counter01, SA_HO_SCE4_counter02, SA_HO_SCE4_counter03,
]

SA_HO_SCE5_counter00 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C03505', 'meas_id': '55145'}
SA_HO_SCE5_counter01 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C03506', 'meas_id': '55145'}
SA_HO_SCE5_counter02 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C03507', 'meas_id': '55145'}
SA_HO_SCE5_counter03 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C03508', 'meas_id': '55145'}
SA_HO_SCE5_counter04 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03505', 'meas_id': '55145'}
SA_HO_SCE5_counter05 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03506', 'meas_id': '55145'}
SA_HO_SCE5_counter06 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03507', 'meas_id': '55145'}
SA_HO_SCE5_counter07 = {'gnb_id': 0, 'dic_path': _ho_path3, 'counter_id': 'M55145C03508', 'meas_id': '55145'}
SA_HO_SCE5 = [
    SA_HO_SCE5_counter00, SA_HO_SCE5_counter01, SA_HO_SCE5_counter02, SA_HO_SCE5_counter03,
    SA_HO_SCE5_counter04, SA_HO_SCE5_counter05, SA_HO_SCE5_counter06, SA_HO_SCE5_counter07,
]

SA_HO_SCE6_counter00 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00321', 'meas_id': '55145'}
SA_HO_SCE6_counter01 = {'gnb_id': 0, 'dic_path': _ho_path1, 'counter_id': 'M55145C00322', 'meas_id': '55145'}
SA_HO_SCE6_counter02 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00321', 'meas_id': '55145'}
SA_HO_SCE6_counter03 = {'gnb_id': 0, 'dic_path': _ho_path2, 'counter_id': 'M55145C00322', 'meas_id': '55145'}
SA_HO_SCE6 = [
    SA_HO_SCE6_counter00, SA_HO_SCE6_counter01, SA_HO_SCE6_counter02, SA_HO_SCE6_counter03,
]

SA_HO_SCE7_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55125C07503', 'meas_id': '55125'}
SA_HO_SCE7_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55125C07504', 'meas_id': '55125'}
SA_HO_SCE7_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55125C07520', 'meas_id': '55125'}
SA_HO_SCE7_counter03 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55125C07503', 'meas_id': '55125'}
SA_HO_SCE7_counter04 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55125C07504', 'meas_id': '55125'}
SA_HO_SCE7_counter05 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55125C07520', 'meas_id': '55125'}
SA_HO_SCE7 = [
    SA_HO_SCE7_counter00, SA_HO_SCE7_counter01, SA_HO_SCE7_counter02,
    SA_HO_SCE7_counter03, SA_HO_SCE7_counter04, SA_HO_SCE7_counter05,
]

SA_HO_SCE8_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55125C02001', 'meas_id': '55125'}
SA_HO_SCE8_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55125C02002', 'meas_id': '55125'}
SA_HO_SCE8_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55125C02006', 'meas_id': '55125'}
SA_HO_SCE8_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55142C00501', 'meas_id': '55142'}
SA_HO_SCE8_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55142C00502', 'meas_id': '55142'}
SA_HO_SCE8_counter05 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55142C00508', 'meas_id': '55142'}
SA_HO_SCE8 = [
    SA_HO_SCE8_counter00, SA_HO_SCE8_counter01, SA_HO_SCE8_counter02,
    SA_HO_SCE8_counter03, SA_HO_SCE8_counter04, SA_HO_SCE8_counter05,
]

NSA_HO_SCE1_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01001', 'meas_id': '55120'}
NSA_HO_SCE1_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01002', 'meas_id': '55120'}
NSA_HO_SCE1_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01003', 'meas_id': '55120'}
NSA_HO_SCE1_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01004', 'meas_id': '55120'}
NSA_HO_SCE1_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01005', 'meas_id': '55120'}
NSA_HO_SCE1_counter05 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01006', 'meas_id': '55120'}
NSA_HO_SCE1_counter06 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01007', 'meas_id': '55120'}
NSA_HO_SCE1_counter07 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C01008', 'meas_id': '55120'}
NSA_HO_SCE1_counter10 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01001', 'meas_id': '55120'}
NSA_HO_SCE1_counter11 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01002', 'meas_id': '55120'}
NSA_HO_SCE1_counter12 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01003', 'meas_id': '55120'}
NSA_HO_SCE1_counter13 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01004', 'meas_id': '55120'}
NSA_HO_SCE1_counter14 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01005', 'meas_id': '55120'}
NSA_HO_SCE1_counter15 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01006', 'meas_id': '55120'}
NSA_HO_SCE1_counter16 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01007', 'meas_id': '55120'}
NSA_HO_SCE1_counter17 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55120C01008', 'meas_id': '55120'}
NSA_HO_SCE1 = [
    NSA_HO_SCE1_counter00, NSA_HO_SCE1_counter01, NSA_HO_SCE1_counter02, NSA_HO_SCE1_counter03, NSA_HO_SCE1_counter04,
    NSA_HO_SCE1_counter05, NSA_HO_SCE1_counter06, NSA_HO_SCE1_counter07, NSA_HO_SCE1_counter10, NSA_HO_SCE1_counter11,
    NSA_HO_SCE1_counter12, NSA_HO_SCE1_counter13, NSA_HO_SCE1_counter14, NSA_HO_SCE1_counter15, NSA_HO_SCE1_counter16,
    NSA_HO_SCE1_counter17,
]

NSA_HO_SCE2_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C00001', 'meas_id': '55120'}
NSA_HO_SCE2_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C00501', 'meas_id': '55120'}
NSA_HO_SCE2_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C00002', 'meas_id': '55120'}
NSA_HO_SCE2_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C00003', 'meas_id': '55120'}
NSA_HO_SCE2_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C00004', 'meas_id': '55120'}
NSA_HO_SCE2_counter05 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55120C00007', 'meas_id': '55120'}
NSA_HO_SCE2_counter10 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55120C00001', 'meas_id': '55120'}
NSA_HO_SCE2_counter11 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55120C00501', 'meas_id': '55120'}
NSA_HO_SCE2_counter12 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55120C00002', 'meas_id': '55120'}
NSA_HO_SCE2_counter13 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55120C00003', 'meas_id': '55120'}
NSA_HO_SCE2_counter14 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55120C00004', 'meas_id': '55120'}
NSA_HO_SCE2_counter15 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55120C00007', 'meas_id': '55120'}
NSA_HO_SCE2 = [
    NSA_HO_SCE2_counter00, NSA_HO_SCE2_counter01, NSA_HO_SCE2_counter02, NSA_HO_SCE2_counter03, NSA_HO_SCE2_counter04,
    NSA_HO_SCE2_counter05, NSA_HO_SCE2_counter10, NSA_HO_SCE2_counter11, NSA_HO_SCE2_counter12, NSA_HO_SCE2_counter13,
    NSA_HO_SCE2_counter14, NSA_HO_SCE2_counter15,
]

NSA_HO_SCE3_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00013', 'meas_id': '55151'}
NSA_HO_SCE3_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00014', 'meas_id': '55151'}
NSA_HO_SCE3_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00015', 'meas_id': '55151'}
NSA_HO_SCE3_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00016', 'meas_id': '55151'}
NSA_HO_SCE3_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00017', 'meas_id': '55151'}
NSA_HO_SCE3_counter05 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00018', 'meas_id': '55151'}
NSA_HO_SCE3_counter06 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00019', 'meas_id': '55151'}
NSA_HO_SCE3_counter07 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00020', 'meas_id': '55151'}
NSA_HO_SCE3_counter10 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00013', 'meas_id': '55151'}
NSA_HO_SCE3_counter11 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00014', 'meas_id': '55151'}
NSA_HO_SCE3_counter12 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00015', 'meas_id': '55151'}
NSA_HO_SCE3_counter13 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00016', 'meas_id': '55151'}
NSA_HO_SCE3_counter14 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00017', 'meas_id': '55151'}
NSA_HO_SCE3_counter15 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00018', 'meas_id': '55151'}
NSA_HO_SCE3_counter16 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00019', 'meas_id': '55151'}
NSA_HO_SCE3_counter17 = {'gnb_id': 0, 'dic_path': _NRCELL3, 'counter_id': 'M55151C00020', 'meas_id': '55151'}
NSA_HO_SCE3 = [
    NSA_HO_SCE3_counter00, NSA_HO_SCE3_counter01, NSA_HO_SCE3_counter02, NSA_HO_SCE3_counter03, NSA_HO_SCE3_counter04,
    NSA_HO_SCE3_counter05, NSA_HO_SCE3_counter06, NSA_HO_SCE3_counter07, NSA_HO_SCE3_counter10, NSA_HO_SCE3_counter11,
    NSA_HO_SCE3_counter12, NSA_HO_SCE3_counter13, NSA_HO_SCE3_counter14, NSA_HO_SCE3_counter15, NSA_HO_SCE3_counter16,
    NSA_HO_SCE3_counter17,
]

NSA_HO_SCE4_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55112C02501', 'meas_id': '55112'}
NSA_HO_SCE4_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55112C02502', 'meas_id': '55112'}
NSA_HO_SCE4_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55176C00001', 'meas_id': '55176'}
NSA_HO_SCE4_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55176C00002', 'meas_id': '55176'}
NSA_HO_SCE4_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55176C00005', 'meas_id': '55176'}
NSA_HO_SCE4_counter10 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02501', 'meas_id': '55112'}
NSA_HO_SCE4_counter11 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02502', 'meas_id': '55112'}
NSA_HO_SCE4_counter12 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55176C00001', 'meas_id': '55176'}
NSA_HO_SCE4_counter13 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55176C00002', 'meas_id': '55176'}
NSA_HO_SCE4_counter14 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55176C00005', 'meas_id': '55176'}
NSA_HO_SCE4 = [
    NSA_HO_SCE4_counter00, NSA_HO_SCE4_counter01, NSA_HO_SCE4_counter02, NSA_HO_SCE4_counter03, NSA_HO_SCE4_counter04,
    NSA_HO_SCE4_counter10, NSA_HO_SCE4_counter11, NSA_HO_SCE4_counter12, NSA_HO_SCE4_counter13, NSA_HO_SCE4_counter14,
]

NSA_HO_SCE5_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00001', 'meas_id': '55151'}
NSA_HO_SCE5_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00002', 'meas_id': '55151'}
NSA_HO_SCE5_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00003', 'meas_id': '55151'}
NSA_HO_SCE5_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00004', 'meas_id': '55151'}
NSA_HO_SCE5_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00005', 'meas_id': '55151'}
NSA_HO_SCE5_counter05 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00006', 'meas_id': '55151'}
NSA_HO_SCE5_counter06 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00007', 'meas_id': '55151'}
NSA_HO_SCE5_counter07 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55151C00008', 'meas_id': '55151'}
NSA_HO_SCE5_counter10 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00001', 'meas_id': '55151'}
NSA_HO_SCE5_counter11 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00002', 'meas_id': '55151'}
NSA_HO_SCE5_counter12 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00003', 'meas_id': '55151'}
NSA_HO_SCE5_counter13 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00004', 'meas_id': '55151'}
NSA_HO_SCE5_counter14 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00005', 'meas_id': '55151'}
NSA_HO_SCE5_counter15 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00006', 'meas_id': '55151'}
NSA_HO_SCE5_counter16 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00007', 'meas_id': '55151'}
NSA_HO_SCE5_counter17 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55151C00008', 'meas_id': '55151'}
NSA_HO_SCE5 = [
    NSA_HO_SCE5_counter00, NSA_HO_SCE5_counter01, NSA_HO_SCE5_counter02, NSA_HO_SCE5_counter03, NSA_HO_SCE5_counter04,
    NSA_HO_SCE5_counter05, NSA_HO_SCE5_counter06, NSA_HO_SCE5_counter07, NSA_HO_SCE5_counter10, NSA_HO_SCE5_counter11,
    NSA_HO_SCE5_counter12, NSA_HO_SCE5_counter13, NSA_HO_SCE5_counter14, NSA_HO_SCE5_counter15, NSA_HO_SCE5_counter16,
    NSA_HO_SCE5_counter17,
]

NSA_HO_SCE6_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55112C02501', 'meas_id': '55112'}
NSA_HO_SCE6_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55112C02502', 'meas_id': '55112'}
NSA_HO_SCE6_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55112C02503', 'meas_id': '55112'}
NSA_HO_SCE6_counter03 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55112C02504', 'meas_id': '55112'}
NSA_HO_SCE6_counter04 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55112C02506', 'meas_id': '55112'}
NSA_HO_SCE6_counter05 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55112C08001', 'meas_id': '55112'}
NSA_HO_SCE6_counter06 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55176C00001', 'meas_id': '55176'}
NSA_HO_SCE6_counter07 = {'gnb_id': 0, 'dic_path': _NRCELL2, 'counter_id': 'M55176C00002', 'meas_id': '55176'}
NSA_HO_SCE6_counter10 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02501', 'meas_id': '55112'}
NSA_HO_SCE6_counter11 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02502', 'meas_id': '55112'}
NSA_HO_SCE6_counter12 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02503', 'meas_id': '55112'}
NSA_HO_SCE6_counter13 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02504', 'meas_id': '55112'}
NSA_HO_SCE6_counter14 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C02506', 'meas_id': '55112'}
NSA_HO_SCE6_counter15 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55112C08001', 'meas_id': '55112'}
NSA_HO_SCE6_counter16 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55176C00001', 'meas_id': '55176'}
NSA_HO_SCE6_counter17 = {'gnb_id': 1, 'dic_path': _NRCELL4, 'counter_id': 'M55176C00002', 'meas_id': '55176'}
NSA_HO_SCE6 = [
    NSA_HO_SCE6_counter00, NSA_HO_SCE6_counter01, NSA_HO_SCE6_counter02, NSA_HO_SCE6_counter03, NSA_HO_SCE6_counter04,
    NSA_HO_SCE6_counter05, NSA_HO_SCE6_counter06, NSA_HO_SCE6_counter07, NSA_HO_SCE6_counter10, NSA_HO_SCE6_counter11,
    NSA_HO_SCE6_counter12, NSA_HO_SCE6_counter13, NSA_HO_SCE6_counter14, NSA_HO_SCE6_counter15, NSA_HO_SCE6_counter16,
    NSA_HO_SCE6_counter17,
]

NSA_HO_SCE7_counter00 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55112C03501', 'meas_id': '55112'}
NSA_HO_SCE7_counter01 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55112C03502', 'meas_id': '55112'}
NSA_HO_SCE7_counter02 = {'gnb_id': 0, 'dic_path': _NRCELL1, 'counter_id': 'M55112C03503', 'meas_id': '55112'}
NSA_HO_SCE7_counter03 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00501', 'meas_id': '55128'}
NSA_HO_SCE7_counter04 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00502', 'meas_id': '55128'}
NSA_HO_SCE7_counter05 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00503', 'meas_id': '55128'}
NSA_HO_SCE7_counter06 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00504', 'meas_id': '55128'}
NSA_HO_SCE7_counter07 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00505', 'meas_id': '55128'}
NSA_HO_SCE7 = [
    NSA_HO_SCE7_counter00, NSA_HO_SCE7_counter01, NSA_HO_SCE7_counter02, NSA_HO_SCE7_counter03, NSA_HO_SCE7_counter04,
    NSA_HO_SCE7_counter05, NSA_HO_SCE7_counter06, NSA_HO_SCE7_counter07
]

NSA_HO_SCE8_counter00 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00001', 'meas_id': '55118'}
NSA_HO_SCE8_counter01 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00002', 'meas_id': '55118'}
NSA_HO_SCE8_counter02 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00003', 'meas_id': '55118'}
NSA_HO_SCE8_counter03 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00004', 'meas_id': '55128'}
NSA_HO_SCE8_counter04 = {'gnb_id': 0, 'dic_path': _NRBTSname, 'counter_id': 'M55128C00005', 'meas_id': '55128'}
NSA_HO_SCE8 = [
    NSA_HO_SCE8_counter00, NSA_HO_SCE8_counter01, NSA_HO_SCE8_counter02, NSA_HO_SCE8_counter03, NSA_HO_SCE8_counter04,
]
