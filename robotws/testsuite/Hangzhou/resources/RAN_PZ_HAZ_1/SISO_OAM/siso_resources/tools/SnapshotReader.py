import zipfile
import re
import os
import shutil


class SnapshotReader(object):

    def __init__(self, snapshot_file):
        self.snapshot_file = snapshot_file
        self._get_file_list()

    def _get_file_list(self):
        self.snapshot_file_list = {}
        snapshot_file_content = None

        with zipfile.ZipFile(self.snapshot_file) as snapshot_zip:
            with snapshot_zip.open("snapshot_file_list.txt") as file_list:
                snapshot_file_content = file_list.read().decode().split("\n")
        if not snapshot_file_content:
            return self.snapshot_file_list
        current_parent_container = []
        for file_name in snapshot_file_content:
            if not file_name:
                continue
            elif file_name.endswith(":"):
                current_parent_container = []
                self.snapshot_file_list[file_name[:-1]] = current_parent_container
            elif not file_name.startswith(" "):
                current_parent_container = []
                self.snapshot_file_list[file_name] = current_parent_container
            else:
                current_parent_container.append(file_name.strip(" "))

        print(self.snapshot_file_list)

    def get_snapshot_file_list(self, filter, parent_filter=None):
        file_list = {}
        if not filter:
            return file_list
        parent_filter_reg = None
        if parent_filter:
            parent_filter_reg = re.compile(parent_filter)
        file_name_filter_reg = re.compile(filter)

        for parent_file_name in self.snapshot_file_list.keys():
            if parent_filter_reg and not parent_filter_reg.search(parent_file_name):
                continue
            sub_file_list = []
            if file_name_filter_reg.search(parent_file_name):
                sub_file_list.append(".")

            for sub_file_name in self.snapshot_file_list[parent_file_name]:
                # print(sub_file_name)
                if file_name_filter_reg.search(sub_file_name):
                    sub_file_list.append(sub_file_name)
                    break
            if len(sub_file_list):
                file_list[parent_file_name] = sub_file_list

        return file_list

    def extract_snapshot_files(self, dst_dir, filter, parent_filter=None, combined=True):
        file_list = self.get_snapshot_file_list(filter=filter, parent_filter=parent_filter)
        snapshot_file_list = []
        for parent_file_name in file_list.keys():
            with zipfile.ZipFile(self.snapshot_file) as snapshot_zip:
                snapshot_zip.extract(parent_file_name, dst_dir)
            root_dir = os.path.join(dst_dir, parent_file_name)
            root_dir_in_list = False
            for sub_file_name in file_list[parent_file_name]:
                if sub_file_name == '.':
                    snapshot_file_list.append(parent_file_name)
                    root_dir_in_list = True
                    continue
                with zipfile.ZipFile(root_dir) as snapshot_zip:
                    if not combined:
                        snapshot_zip.extract(sub_file_name, root_dir[:-4])
                        snapshot_file_list.append(parent_file_name + "/" + sub_file_name)
                    else:
                        snapshot_zip.extract(sub_file_name, dst_dir)
                        snapshot_file_list.append(sub_file_name)
            if not root_dir_in_list:
                os.remove(root_dir)

        return snapshot_file_list

    @staticmethod
    def extract_specified_file(dst_dir, file_name):
        shutil.unpack_archive(file_name, dst_dir)
        return os.listdir(dst_dir)


if __name__ == "__main__":
    SR = SnapshotReader("/home/ute/Downloads/"
                        "Snapshot_MRBTS-10424_LTE10845_cb006849_dod_SBTS23R4_ENB_9999_230530_000010_20230531-0216.zip")
    print("--------------------------------------------")
    print(SR.get_snapshot_file_list(filter="L1201407449"))
    print(SR.extract_snapshot_files(dst_dir="/home/ute/tmp", filter="BTS_L1201407449_RMOD_L_1_UnitOAM_SOAP_Log"))
    print("--------------------------------------------")
    print(SR.extract_specified_file("/home/ute/tmp/BTS_L1201407449_RMOD_L_1_UnitOAM_SOAP_Log",
                                    "/home/ute/tmp/BTS_L1201407449_RMOD_L_1_UnitOAM_SOAP_Log.zip"))
