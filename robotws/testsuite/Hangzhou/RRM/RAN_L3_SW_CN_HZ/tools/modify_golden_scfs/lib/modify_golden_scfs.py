# -*- coding:utf-8 -*-
# Author: Zhang Yin
import os
import sys
import traceback
from robot.libraries.OperatingSystem import OperatingSystem
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin as ute_admin

os_obj = OperatingSystem()
builtin_obj = BuiltIn()


class modify_golden_scfs(object):
    def __init__(self):
        self.bts_host = "192.168.255.129"
        self.bts_port = "443"
        self.use_ssl = True
        self.alias = "gnb"

    def setup(self):
        # cwd = os.path.split(os.path.abspath(__file__))[0]
        # sys.path.append("{}/../../../resources/DevHZ5_lib/src".format(cwd))
        sys.path.append("../../../resources/DevHZ5_lib/src")
        from cm import cm
        self.cm_obj = cm()
        self.admin_obj = ute_admin()
        self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                   bts_host=self.bts_host, admin_api_log_dir="/tmp")

    def teardown(self):
        try:
            self.admin_obj.teardown_admin(self.alias)
        except Exception:
            pass

    def find_golden_scf_files(self, golden_path):
        all_scf = []
        golden_path = golden_path.replace("~", "/home/ute")
        for root, dirs, files in os.walk(golden_path):
            for file in files:
                if file == "SCFC_1.xml" or file == "SCFC_2.xml":
                    all_scf.append(os.path.join(root, file))
        return all_scf

    def migrate_scf(self, source_scf):
        relation_error_flag = False
        migrated_scf = "/home/ute/migrated_scf.xml"
        os_obj.remove_file(migrated_scf)
        try:
            builtin_obj.log("migrating {}".format(source_scf), console=True)
            result = self.admin_obj.migrate_scf(source_scf, migrated_scf, alias=self.alias)
            if result['validationResult']['pdlValidationResult']['status'].lower() != 'ok':
                errors = result['validationResult']['pdlValidationResult']['logs']['relationErrors'] + \
                         result['validationResult']['pdlValidationResult']['logs']['hardwareErrors']
                if len(errors):
                    builtin_obj.log("there are {} relation errors in golden scf\n".format(len(errors)), level="WARN")
                    relation_error_flag = True

            if os_obj.get_file_size(migrated_scf) > 10000:
                # size > 10KB
                os_obj.copy_file(migrated_scf, source_scf)
            else:
                builtin_obj.log("fail to migrate %s" % source_scf, level="WARN")
        except Exception as _err:
            builtin_obj.log("fail to migrate %s because '%s'" % (source_scf, _err), level="WARN")
        return relation_error_flag

    def modify_golden_scf_files(self, golden_path, params):
        self.setup()
        scfs = self.find_golden_scf_files(golden_path)
        # migrate scf if no params need to change
        if params == ['']:
            scfs_error = []
            for scf in scfs:
                builtin_obj.log_to_console("######################################################################")
                relation_error_flag = self.migrate_scf(scf)
                if relation_error_flag:
                    scfs_error.append(scf)
            if len(scfs_error):
                builtin_obj.log("there are relation errors in {} SCF, ask TA core team to fix."
                                "\n{}".format(len(scfs_error),  "\n".join(scfs_error)), level="WARN")
            return

        # modify scf if params not empty
        try:
            scfs_failed = []
            scfs_no_change = []
            for scf in scfs:
                builtin_obj.log_to_console("######################################################################")
                result1 = self.admin_obj.validate_scf(scf,
                                                      skip_parameter_relation_errors=True, alias=self.alias)
                self.cm_obj.modify_scf(scf, params, "/home/ute/scf_modified.xml")
                result2 = self.admin_obj.validate_scf("/home/ute/scf_modified.xml",
                                                      skip_parameter_relation_errors=True, alias=self.alias)
                if len(result2) == 0 or result1 == result2:
                    os_obj.move_file("/home/ute/scf_modified.xml", scf)
                else:
                    scfs_no_change.append(scf)

                errors = result1['pdlValidationResult']['logs']['relationErrors']
                errors = errors + result1['pdlValidationResult']['logs']['hardwareErrors']
                if len(errors):
                    scfs_failed.append(scf)
                    builtin_obj.log("there are {} relation errors in golden scf".format(len(errors)),
                                    level="WARN")
        except Exception:
            traceback.print_exc()
        finally:
            self.teardown()
            if len(scfs_failed):
                builtin_obj.log("there are relation errors in {} SCF, ask TA core team to fix."
                                "\n{}".format(len(scfs_failed), "\n".join(scfs_failed)), level="WARN")
            if len(scfs_no_change):
                builtin_obj.log("{} SCF not changed successfully: \n{}".format(len(scfs_no_change),
                                                                               "\n".join(scfs_no_change)),
                                level="WARN")
