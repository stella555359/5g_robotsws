# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
:maintainer: Tingting Zhong
:contact: tingting.zhong@nokia-sbell.com
"""

import csv
import hashlib
import os
import re
import requests
import zipfile
from collections import namedtuple
from testsuite.Hangzhou.resources.RAN_PZ_HAZ_34.python.scf.scf_analysis import ScfAnalysis

__all__ = ['generate_modify_parameters_delta_file_new']

base_url = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn5gran_hzlog-local/tools/Pz4SG04/"
# API Key for username "ca_5Gauto"
api_key = "AKCp5bBh9XG9iCkcCJLwt6CHuVdgHPyJVAuB7V6vSHfet7X6ZXfjZRqEMLxn36rfqRfhoQzKc"
zip_name = "dynamic_pdcch.zip"
sha256_name = "dynamic_pdcch.zip.sha256"


class DownloadCsv(object):
    def download(self, save_path, file_name,  timeout=600):
        url = base_url + file_name
        headers = {'Authorization': f'Bearer {api_key}'}
        r = requests.get(url, headers=headers, stream=True, timeout=timeout)
        if r.status_code == 200:
            print("request package successful!: {}".format(url))
        else:
            print("request package failed!: {}".format(url))
            return False
        file_path = os.path.join(save_path, file_name)
        with open(file_path, 'wb') as f:
            for chunk in r.iter_content(1024):
                if chunk:
                    f.write(chunk)
        os.path.exists(save_path)
        return True

    def verifyCheckSum(self, file_path, checksum):
        with open(file_path, "rb") as f:
            sha256_hash = hashlib.sha256()
            # Read and update hash string value in blocks of 4K
            for byte_block in iter(lambda: f.read(4096), b""):
                sha256_hash.update(byte_block)
            print(sha256_hash.hexdigest(), checksum)
            if sha256_hash.hexdigest() == checksum:
                return True
            else:
                return False

    def download_package_and_check_sha256(self, save_path):
        check_flag = False
        file_path = os.path.join(save_path, zip_name)
        if not os.path.exists(file_path):
            zip_flag = self.download(save_path=save_path, file_name=zip_name)
        else:
            zip_flag = True
        sha256_flag = self.download(save_path=save_path, file_name=sha256_name)
        if zip_flag and sha256_flag:
            sha256_file = os.path.join(save_path, sha256_name)
            with open(sha256_file, "rb") as f:
                content = f.read()
                checksum = content.decode().strip()
                check_flag = self.verifyCheckSum(file_path=file_path, checksum=checksum)
        return check_flag


class GetParams(object):
    def __init__(self, pdcch_file_save_path, scf_path, cell_id, cell_band, cell_frame_structure, release='master'):
        self.pdcch_file_save_path = pdcch_file_save_path
        self.scf_path = scf_path
        self.scf_analysis = ScfAnalysis()
        self.scf_analysis.setup(self.scf_path)
        self.cell_id = cell_id
        self.release = release
        self.cell_band = cell_band
        self.cell_frame_structure = cell_frame_structure
        self.csv_path = self.generate_csv_path()

    def generate_csv_path(self):
        cell_network_type = self.scf_analysis.get_cell_network_type_from_scf(cell_id=self.cell_id)
        cellTechnology = 'tdd'
        if cell_network_type == 'NSA':
            cell_network_type = 'nsa'
        else:
            cell_network_type = 'sa_or_both'
        for item in ['22R4', '23R3', '23R4']:
            if item in self.release:
                release_floder = item
                break
            else:
                release_floder = '23R4'
        file_name = 'dynamic_pdcch_' + cell_network_type + '_' + cellTechnology + '.csv'
        csv_path = os.path.join(self.pdcch_file_save_path, 'dynamic_pdcch', release_floder, file_name)
        return csv_path

    def generate_type(self):
        cell_network_type = self.scf_analysis.get_cell_network_type_from_scf(cell_id=self.cell_id)
        if cell_network_type != 'NSA':
            cell_network_type = 'SA_or_both'
        cellTechnology = 'TDD'
        if '1116_0ms' in self.cell_frame_structure:
            frame = 'tdLte_0ms'
        elif '1116_3ms' in self.cell_frame_structure:
            frame = 'tdLte_3ms'
        elif '1208' in self.cell_frame_structure:
            frame = 'semiStatic_1/4'
        else:
            frame = 'semiStatic_3/7'
        chbw = str(self.cell_band) + 'MHz'
        type = '{}_{}_{}_{}'.format(cell_network_type, cellTechnology, frame, chbw)
        print(type)
        return type

    def read_csv(self):
        get_params = []
        with open(self.csv_path, 'r') as f:
            f_csv = csv.reader(f)
            headings = next(f_csv)
            Row = namedtuple('Row', headings)
            type = self.generate_type()
            for r in f_csv:
                row = Row(*r)
                if row.type == type and self.filter_param_for_row(row=row):
                    dist_name = row.dist_name
                    structure_name = row.structure_name
                    parameter_name = row.parameter_name
                    parameter_value = row.parameter_value
                    instance = row.instance
                    initial_bwp = self.scf_analysis.get_bwpDN_from_scf(cell_id=self.cell_id, index=0)
                    dedicated_bwp = self.scf_analysis.get_bwpDN_from_scf(cell_id=self.cell_id, index=1)
                    dist_name = dist_name.format(initial_bwp=initial_bwp, dedicated_bwp=dedicated_bwp)
                    info = {'dist_name': dist_name, 'structure_name': structure_name, 'parameter_name': parameter_name,
                            'parameter_value': parameter_value, 'instance': instance}
                    get_params.append(info)
        return get_params

    def filter_param_for_row(self, row):
        flag = True
        if '23R3' in self.release:
            actDynPdcchTd = row.actDynPdcchTd
            real_actDynPdcchTd = self.scf_analysis.get_actDynPdcchTd_from_scf(cell_id=self.cell_id)
            if actDynPdcchTd.lower() != real_actDynPdcchTd.lower():
                flag = False
        else:
            actDynPdcchTdMode = row.actDynPdcchTdMode
            real_actDynPdcchTdMode = self.scf_analysis.get_actDynPdcchTdMode_from_scf(cell_id=self.cell_id)
            if actDynPdcchTdMode.lower() != real_actDynPdcchTdMode.lower():
                flag = False
        actBbPoolTddFr1 = row.actBbPoolTddFr1
        real_actBbPoolTddFr1 = self.scf_analysis.get_actBbPoolTddFr1_from_scf()
        if actBbPoolTddFr1.lower() != real_actBbPoolTddFr1.lower():
            flag = False
        return flag

    def generate_modify_dict_by_structure_name(self, get_params, dist_name, structure_name):
        new_params = []
        modify_params = []
        for param in get_params:
            if param['dist_name'] == dist_name and param['structure_name'] == structure_name:
                new_params.append(param)
        for param in new_params:
            parameter_name = param['parameter_name']
            parameter_value = param['parameter_value']
            parameter_value = parameter_value.split(':')[-1]
            parameter_value = re.sub(r'\*', '', parameter_value)
            instance = param['instance']
            if parameter_value.lower() == 'true' or parameter_value.lower() == 'false':
                value = parameter_value.lower()
            else:
                value = parameter_value
            instance = int(instance)-1 if instance else 0
            modify_params.append(dict(dist_name=dist_name, list_name=structure_name, parameter=parameter_name,
                                      value=value, index=instance))
        return modify_params

    def get_diff_list(self):
        with_structure_name = []
        without_structure_name = []
        get_params = self.read_csv()
        for param in get_params:
            if param['parameter_value'] and param['parameter_name'] != 'bwpProfileId':
                if param['structure_name']:
                    with_structure_name.append(param)
                else:
                    without_structure_name.append(param)
        all_type = []
        for param in with_structure_name:
            if param['structure_name'] and (param['dist_name'], param['structure_name']) not in all_type:
                all_type.append((param['dist_name'], param['structure_name']))
        print(all_type)
        return without_structure_name, with_structure_name, all_type

    def generate_params(self):
        without_structure_name, with_structure_name, all_type = self.get_diff_list()
        modify_params = []
        for param in without_structure_name:
            parameter_value = param['parameter_value'].split(':')[-1]
            parameter_value = re.sub(r'\*', '', parameter_value)
            if parameter_value.lower() == 'true' or parameter_value.lower() == 'false':
                value = parameter_value.lower()
            else:
                value = parameter_value
            modify_params.append(
                dict(dist_name=param['dist_name'], parameter=param['parameter_name'], value=value))
        for type in all_type:
            dist_name = type[0]
            structure_name = type[1]
            generate_params = self.generate_modify_dict_by_structure_name(
                with_structure_name, dist_name, structure_name)
            modify_params = modify_params + generate_params
        return modify_params


def generate_modify_parameters_delta_file_new(scf_path, cell_id, cell_band, cell_frame_structure,
                                              release='master', pdcch_file_path='/home/ute/'):
    pdcch_file_save_path = os.path.dirname(scf_path)
    modify_params = []
    download = DownloadCsv()
    check_flag = download.download_package_and_check_sha256(save_path=pdcch_file_save_path)
    if not check_flag:
        check_flag = download.download_package_and_check_sha256(save_path=pdcch_file_save_path)
    if not check_flag:
        print('download dynamic pdcch zip failed!, use local path {}'.format(pdcch_file_path))
        pdcch_file_save_path = pdcch_file_path
    zip_file = os.path.join(pdcch_file_save_path, zip_name)
    zip_file = zipfile.ZipFile(zip_file)
    zip_file.extractall(pdcch_file_save_path)
    zip_file.close()
    get_params = GetParams(
        pdcch_file_save_path=pdcch_file_save_path,
        scf_path=scf_path, cell_id=cell_id, release=release,
        cell_band=cell_band, cell_frame_structure=cell_frame_structure)
    modify_params = modify_params + get_params.generate_params()
    return modify_params

#
# if __name__ == '__main__':
#     generate_modify_parameters_delta_file_new(
#         scf_path='/home/ute/ztt/robotws/commissionings/HGZ/7_5_UTE5G402T316/SCF_SBTS23R4.xml',
#         cell_id=1,
#         cell_band='100',
#         cell_frame_structure='1208_GP1_A1',
#         release='SBTS23R4')
