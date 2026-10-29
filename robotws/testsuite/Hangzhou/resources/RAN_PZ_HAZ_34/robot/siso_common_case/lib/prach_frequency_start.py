"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_calculater import *
from dynamic_pdcch import *

__all__ = ['calculate_msg1frequencystart']


class GenerateParams(object):
    def __init__(self, scf_path, cell_id, cell_band, cell_frame_structure, nband='n78',
                 productName='ABIO AirScale Capacity', release='master'):
        self.scf_path = scf_path
        self.scf_analysis = ScfAnalysis()
        self.scf_analysis.setup(self.scf_path)
        self.cell_id = cell_id
        self.cell_band = cell_band
        self.cell_frame_structure = cell_frame_structure
        self.nband = nband
        self.productName = productName
        self.release = release

    def calculate_pucchprb(self):
        pucchprb, _ = calculate_pucchprb_tdd(
            scf_path=self.scf_path, cell_id=self.cell_id, nband=self.nband, productName=self.productName,
            release=self.release)
        return pucchprb

    def get_cRbSizeDll(self):
        modify_params = generate_modify_parameters_delta_file_new(
            scf_path=self.scf_path, cell_id=self.cell_id, release=self.release, cell_band=self.cell_band,
            cell_frame_structure=self.cell_frame_structure)
        initial_bwp = self.scf_analysis.get_bwpDN_from_scf(cell_id=self.cell_id, index=0)
        modify_flag = False
        for param in modify_params:
            if param['dist_name'] == initial_bwp and param['parameter'] == 'cRbSizeDl' and param['value'] == 'allRb':
                modify_flag = True
        return modify_flag


def calculate_msg1frequencystart(scf_path, cell_id, cell_band, cell_frame_structure, nband='n78',
                                 productName='ABIO AirScale Capacity', release='master'):
    object = GenerateParams(scf_path=scf_path,
                            cell_id=cell_id,
                            cell_band=cell_band,
                            cell_frame_structure=cell_frame_structure,
                            nband=nband,
                            productName=productName,
                            release=release)
    pucchprb = object.calculate_pucchprb()
    msg1frequencystart = pucchprb/2 + 3
    return msg1frequencystart


# if __name__ == "__main__":
#     msg1frequencystart = calculate_msg1frequencystart(
#         scf_path='/home/ute/ztt/scf_backup_from_cluster20220519103031.xml',
#         cell_id=1,
#         cell_band=20,
#         cell_frame_structure='1208_GP1_A1',
#         nband='n78',
#         productName='ABIO AirScale Capacity',
#         release='master')
#     print(msg1frequencystart)
