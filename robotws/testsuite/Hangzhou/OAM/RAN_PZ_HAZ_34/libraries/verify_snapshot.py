import zipfile
import os
import re


class VerifySnapshot(object):
    def __init__(self):
        self.path_list = []
        self.err_list = []
        self.ab_file_path = []
        self.profile2_metadata_error_list = []
        self.profile3_metadata_error_list = []

    def un_zip(self, path_name, file_name):
        # this KW is to uncompression the zip file,
        # path_name is the the zipfile path
        # file_name is the zipfile name
        # the return value is the path with the uncompression file
        file_path = path_name + os.sep + file_name
        str1 = '.xz'
        if zipfile.is_zipfile(file_path) and str1 not in file_path:
            zip_file = zipfile.ZipFile(file_path)
            path_name = os.path.splitext(file_path)[0]
            try:
                print('The path name of the file to be unzip')
                print(path_name)
                zip_file.extractall(path_name)
            except zipfile.BadZipfile:
                pass
            for files in zip_file.namelist():
                self.un_zip(path_name, files)
        return path_name

    def list_file(self, path_name, folder):
        # this KW is to list the file in folder
        # path_name is the file folder
        # folder is the the absolute path of the folder
        # return value is the file list with relative path
        fp = os.listdir(path_name)
        for file_name in fp:
            tmp = os.path.join(path_name, file_name)
            if not os.path.isdir(tmp):
                tmp_path = tmp.replace(folder + '/', '')
                self.path_list.append(tmp_path)
            else:
                self.list_file(tmp, folder)
        if len(self.path_list) != 0:
            return self.path_list
        else:
            return 'Error'

    def _list_full_path(self, path_name):
        # path_name is the folder path which from unzip KW
        # the return value is the file list with full path
        fp = os.listdir(path_name)
        for file_name in fp:
            tmp = os.path.join(path_name, file_name)
            if not os.path.isdir(tmp):
                self.ab_file_path.append(tmp)
            else:
                self._list_full_path(tmp)
        if len(self.ab_file_path) != 0:
            return self.ab_file_path
        else:
            return 'Error'

    def _read_metadata(self, path_name):
        # path_name is the folder path which from unzip KW
        # the return value is the metadata file
        full_path_list = self._list_full_path(path_name)
        # print full_path_list
        rule = re.compile('.*metadata.txt')
        for fp in full_path_list:
            metadata = re.findall(rule, fp)
            if len(metadata) != 0:
                break
        metadata_path = metadata[0]
        with open(metadata_path, 'r')as f1:
            metadata_file = f1.read()
        return metadata_file

    def _verify_profile2_metadata(self, path_name):
        # path_name is the folder path which from unzip KW
        # the return value is the file list which not contained in metadata
        metadata_file = self._read_metadata(path_name)
        profile2_metadata_rule = ['.*1011_startup.*', '.*1011_runtime.zip', '.*1011.*.syslog.*', '.*L2TraceHi_DU.*',
                                  '.*L2TraceHi_CU.*', '.*E000.*pm.*', '.*E000_runtime.zip', '.*E000_startup.*',
                                  '.*E002.*pm.*', '.*E002_runtime.zip', '.*E002_startup.*', '.*E003.*pm.*',
                                  '.*E003_runtime.zip', '.*E003_startup.*', '.*E004.*pm.*', '.*E004_runtime.zip',
                                  '.*E004_startup.*', '.*E00A_runtime.zip', '.*E00A_startup.*', '.*1021_runtime.zip',
                                  '.*1021_startup.*', '.*102A_runtime.zip', '.*102A_startup.*', '.*E005_runtime.zip',
                                  '.*E005_startup.*', '.*E007_runtime.zip', '.*E007_startup.*', '.*E008_runtime.zip',
                                  '.*E008_startup.*', '.*123D_runtime.zip', '.*123D_startup.*', '.*123A_runtime.zip',
                                  '.*123A_startup.*', '.*123A_L2TtiTrace_EventsSnapshot.bin', '.*123A_L2TraceLo.*']
        for elem in profile2_metadata_rule:
            rule = re.compile(elem)
            files = re.findall(rule, metadata_file)
            if len(files) != 0:
                continue
            else:
                self.profile2_metadata_error_list.append(elem)
        return self.profile2_metadata_error_list

    def verify_profile2_content(self, path_name, folder):
        # path_name is the file folder
        # folder is the the absolute path of the folder
        # the return value is the file list which not contained as profile2 defined if it has
        path_list = self.list_file(path_name, folder)
        profile2 = ['collectionMeta.json', 'SITE/siteReport.html', 'SITE/siteoam_runtime_bim.json',
                    'OAMLogs/config/SBTS_SCF.xml', 'OAMLogs/config/plan', 'OAMLogs/config/profiles/',
                    'OAMLogs/siteConfiguration/', 'OAMLogs/noma/', 'OAMLogs/logs/RacOAM/',
                    'OAMLogs/logs/SiteOAM/', 'OAMLogs/logs/SLOADER/', 'OAMLogs/logs/NLOADER/', 'OAMLogs/PM/',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/BIM/RacOAM/racoam_runtime_bim.json',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/Configuration/RacOAM/',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/RawFaults/rawFaults/rawFaultHistory',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/rcpAlarms/rcpAlarms/rcpAlarmsHistory.log',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/rcpAlarms/rcpAlarms/rcpAlarmsActive.log',
                    'RAP-1/nodeoam_snapshot_FSM1/snapshotDesc.xml',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/SBTS_',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/BIM/NodeOAM/nodeoam_runtime_bim.json',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/NodeOAM/startup_NODEOAM.log',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/RawFaults/rawFaults/rawFaultHistory',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/OamAgent/',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/TRS/ExtendedNeLogs',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/SW/sw_update_history.txt',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/PlatformCommonRP/']
        for ele in profile2:
            for elem in path_list:
                if ele not in elem and path_list.index(elem) != len(path_list) - 1:
                    continue
                elif ele not in elem and path_list.index(elem) == len(path_list) - 1:
                    self.err_list.append(ele)
                    break
                else:
                    break
        result_in_metadata = self._verify_profile2_metadata(path_name)
        if len(self.err_list) == 0 and len(result_in_metadata) == 0:
            return 'PASS'
        else:
            for ele in result_in_metadata:
                self.err_list.append(ele)
            return self.err_list

    def _verify_profile3_metadata(self, path_name):
        # path_name is the folder path which from unzip KW
        # the return value is the file list which not contained in metadata
        metadata_file = self._read_metadata(path_name)
        profile3_metadata_rule = ['.*1011_startup.*', '.*1011_runtime.zip', '.*E000_runtime.zip', '.*E000_startup.*',
                                  '.*E002_runtime.zip', '.*E002_startup.*', '.*E004_runtime.zip',
                                  '.*E004_startup.*', '.*E00A_runtime.zip', '.*E00A_startup.*', '.*1021_runtime.zip',
                                  '.*1021_startup.*', '.*102A_runtime.zip', '.*102A_startup.*', '.*E005_runtime.zip',
                                  '.*E005_startup.*', '.*E007_runtime.zip', '.*E007_startup.*', '.*E008_runtime.zip',
                                  '.*E008_startup.*', '.*123D_runtime.zip', '.*123D_startup.*', '.*123A_runtime.zip',
                                  '.*123A_startup.*']
        for elem in profile3_metadata_rule:
            rule = re.compile(elem)
            files = re.findall(rule, metadata_file)
            if len(files) != 0:
                continue
            else:
                self.profile3_metadata_error_list.append(elem)
        return self.profile3_metadata_error_list

    def verify_profile3_content(self, path_name, folder):
        # path_name is the file folder
        # folder is the the absolute path of the folder
        # the return value is the file list which not contained as profile3 defined if it has
        path_list = self.list_file(path_name, folder)
        profile3 = ['collectionMeta.json', 'SITE/siteReport.html', 'SITE/siteoam_runtime_bim.json',
                    'OAMLogs/config/SBTS_SCF.xml', 'OAMLogs/config/plan', 'OAMLogs/config/profiles/',
                    'OAMLogs/siteConfiguration/', 'OAMLogs/noma/', 'OAMLogs/logs/RacOAM/',
                    'OAMLogs/logs/SiteOAM/', 'OAMLogs/logs/SLOADER/', 'OAMLogs/logs/NLOADER/', 'OAMLogs/PM/',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/BIM/RacOAM/racoam_runtime_bim.json',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/Configuration/RacOAM/',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/RawFaults/rawFaults/rawFaultHistory',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/rcpAlarms/rcpAlarms/rcpAlarmsHistory.log',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/rcpAlarms/rcpAlarms/rcpAlarmsActive.log',
                    'RAP-1/nodeoam_snapshot_FSM1/snapshotDesc.xml',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/SBTS_',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/BIM/NodeOAM/nodeoam_runtime_bim.json',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/NodeOAM/startup_NODEOAM.log',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/RawFaults/rawFaults/rawFaultHistory',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/OamAgent/',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/TRS/ExtendedNeLogs',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/SW/sw_update_history.txt',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/PlatformCommonRP/']
        for ele in profile3:
            for elem in path_list:
                if ele not in elem and path_list.index(elem) != len(path_list) - 1:
                    continue
                elif ele not in elem and path_list.index(elem) == len(path_list) - 1:
                    self.err_list.append(ele)
                    break
                else:
                    break
        result_in_metadata = self._verify_profile3_metadata(path_name)
        if len(self.err_list) == 0 and len(result_in_metadata) == 0:
            return 'PASS'
        else:
            for ele in result_in_metadata:
                self.err_list.append(ele)
            return self.err_list

    def verify_profile4_content(self, path_list):
        # path list is the file list with relative path from KW list_file
        # the return value is the file list which not contained as profile4 defined if it has
        profile4 = ['collectionMeta.json', 'SITE/siteReport.html', 'SITE/siteoam_runtime_bim.json',
                    'OAMLogs/config/SBTS_SCF.xml', 'OAMLogs/config/plan', 'OAMLogs/config/profiles/',
                    'OAMLogs/siteConfiguration/', 'OAMLogs/noma/', 'OAMLogs/logs/RacOAM/',
                    'OAMLogs/logs/SiteOAM/',
                    # 'OAMLogs/logs/SLOADER/', 'OAMLogs/logs/NLOADER/',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/BIM/RacOAM/racoam_runtime_bim.json',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/Configuration/RacOAM/',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/RawFaults/rawFaults/rawFaultHistory',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/rcpAlarms/rcpAlarms/rcpAlarmsHistory.log',
                    'RAC/racoam_snapshot/RAC/RACLogFiles/rcpAlarms/rcpAlarms/rcpAlarmsActive.log',
                    'RAP-1/nodeoam_snapshot_FSM1/snapshotDesc.xml',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/BIM/NodeOAM/nodeoam_runtime_bim.json',
                    'RAP-1/nodeoam_snapshot_FSM1/BTS/BTSLogFiles/OamAgent/']
        for ele in profile4:
            for elem in path_list:
                if ele not in elem and path_list.index(elem) != len(path_list) - 1:
                    continue
                elif ele not in elem and path_list.index(elem) == len(path_list) - 1:
                    self.err_list.append(ele)
                    break
                else:
                    break
        if len(self.err_list) == 0:
            return 'PASS'
        else:
            return self.err_list

    def verify_profile5_content(self, path_list):
        # path list is the file list with relative path from KW list_file
        # the return value is the file list which not contained as profile5 defined if it has
        profile5 = ['collectionMeta.json', 'RAP-1/nodeoam_snapshot_FSM1/BTS/RFM_1/']
        for ele in profile5:
            for elem in path_list:
                if ele not in elem and path_list.index(elem) != len(path_list) - 1:
                    continue
                elif ele not in elem and path_list.index(elem) == len(path_list) - 1:
                    self.err_list.append(ele)
                    break
                else:
                    break
        if len(self.err_list) == 0:
            return 'PASS'
        else:
            return self.err_list
