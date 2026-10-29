# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com
:contact: I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com
"""


import time
import os
import re
import json
import ast
from cm_aic_cluster.convert_delta_aic import convert_delta_xml_to_json
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import Vdu
from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from common_lib_aic import common_lib_aic
from ute_fsmaccess import ute_fsmaccess
from base_lib.ta_xml import ta_xml
from base_lib.ta_ssh_telnet import ta_ssh_telnet
from cm_aic_cluster import reduced_var_aic
from base_lib.ta_xml.common_xml import CommonXML
from robot.libraries.Collections import Collections
import traceback

import urllib3
# urllib3.disable_warnings()
from urllib3.exceptions import InsecureRequestWarning

urllib3.disable_warnings(InsecureRequestWarning)

xml_declare = "<?xml version='1.0' encoding='UTF-8'?>"

builtin_obj = BuiltIn()
os_obj = OperatingSystem()
xml_obj = ta_xml()
comm_obj = common_lib_aic()
ssh_obj = ta_ssh_telnet()


class aic_cm_base(object):
    def __init__(self, alias):
        self.alias = alias
        self.alias_cu = self.alias + "_cu"
        self.alias_du = self.alias + "_du"
        self._setup_comm_cu_flag = False
        self._setup_comm_du_flag = False
        self._setup_scf_control_flag_cu = False
        self._setup_scf_control_flag_du = False
        # self._setup_vendor_control_flag = False
        self.remote_host = None
        self.scf_template_full_cu = ""
        self.scf_template_full_du = ""
        self.scf_template_for_mo_cu = ""
        self.scf_template_for_mo_du = ""
        self.scf_template_for_list_cu = ""
        self.scf_template_for_list_du = ""
        self.scf_template_svn_cu = ""
        self.scf_template_svn_du = ""
        self.scf_for_startup_cu = ""
        self.scf_for_startup_du = ""

    def _setup_common_cu(self):
        """setup cu admin"""
        self.cu_host = builtin_obj.get_variable_value("${VCU_IP}")
        if self.alias == "gnb2":
            self.cu_host = builtin_obj.get_variable_value("${VCU2_IP}")
        if not self._setup_comm_cu_flag:
            self._setup_comm_cu_flag = True
            # self._setup_common_ssh()
            self.cu_obj = cu()
            bts_port, use_ssl = comm_obj.define_admin_port()
            save_log_dir = comm_obj._get_save_log_dir(self.alias)
            # # save_log_dir = "C:\\TA\\cu_admin_logs"
            builtin_obj.log("remote_host is %s" % self.remote_host)
            cu_ping_ok = self._ping_ok(self.cu_host)
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                return
            if cu_ping_ok:
                self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                       host=self.cu_host, username="Nemuadmin", password="Nokia@123")
            else:
                self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                       host="192.168.100.129", username="Nemuadmin", password="Nokia@123")
        if self._setup_comm_cu_flag:
            # self._setup_common_ssh()
            if not comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj = cu()
                bts_port, use_ssl = comm_obj.define_admin_port()
                save_log_dir = comm_obj._get_save_log_dir(self.alias)
                builtin_obj.log("remote_host is %s" % self.remote_host)
                cu_ping_ok = self._ping_ok(self.cu_host)
                if cu_ping_ok:
                    self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                           host=self.cu_host, username="Nemuadmin", password="Nokia@123")
                else:
                    self.cu_obj.connect_to(alias=self.alias_cu, port=bts_port, secure=use_ssl,
                                           host="192.168.100.129", username="Nemuadmin", password="Nokia@123")

    def _setup_common_du(self):
        """self.alias_du distinguish by different class instance with using different alias name
           self.du_host fetch from class instance.
        """
        if not self._setup_comm_du_flag:
            self._setup_comm_du_flag = True
            self.du_obj = Vdu()
            bts_port, use_ssl = comm_obj.define_admin_port()
            save_log_dir = comm_obj._get_save_log_dir(self.alias)
            builtin_obj.log("remote_host is %s" % self.remote_host)
            du_ping_ok = self._ping_ok(self.du_host)
            if comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                return
            if du_ping_ok:
                self.du_obj.connect_to(host=self.du_host, port=bts_port, username="Nemuadmin",
                                       password="Nokia@123", secure=use_ssl, connection_name=self.alias_du)
        if self._setup_comm_du_flag:
            if not comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du):
                self.du_obj = Vdu()
                bts_port, use_ssl = comm_obj.define_admin_port()
                save_log_dir = comm_obj._get_save_log_dir(self.alias)
                builtin_obj.log("remote_host is %s" % self.remote_host)
                du_ping_ok = self._ping_ok(self.du_host)
                if du_ping_ok:
                    self.du_obj.connect_to(host=self.du_host, port=bts_port, username="Nemuadmin",
                                           password="Nokia@123", secure=use_ssl, connection_name=self.alias_du)

    def _setup_scf_control_aic_cu(self):
        if not self._setup_scf_control_flag_cu:
            self._setup_scf_control_flag_cu = True
            self._setup_common_cu()
            if self.alias == "gnb1":
                self.full_commission_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
                self.scf_template_full_cu = os.path.join("/home/ute", "scf_template_full_cu.xml")
                self.scf_template_for_mo_cu = os.path.join("/home/ute", "scf_template_for_mo_cu.xml")
                self.scf_template_for_list_cu = os.path.join("/home/ute", "scf_template_for_list_cu.xml")
            else:
                self.full_commission_log_dir = os.path.join(builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"),
                                                            self.alias)
                self.scf_template_full_cu = os.path.join("/home/ute", self.alias, "scf_template_full_cu.xml")
                self.scf_template_for_mo_cu = os.path.join("/home/ute", self.alias, "scf_template_for_mo_cu.xml")
                self.scf_template_for_list_cu = os.path.join("/home/ute", self.alias, "scf_template_for_list_cu.xml")
                os_obj.create_directory(os.path.join("/home/ute", self.alias))
            self.scf_template_path = builtin_obj.get_variable_value("${SCF_TEMPLATE_PATH}")
            # below build may be need check cu and du, current check cu only.
            cu_build = builtin_obj.get_variable_value("${GNB_CU_VERSION}")
            if cu_build is None:
                cu_build = builtin_obj.get_variable_value("${CU_Build_Version}")
            if cu_build.count("_0.250."):
                # vCUCNF23R1_0.250.3478 #vRAN
                # vCUCNF00_0.250.3478 #vRAN new definition
                release_path = "trunk"
            else:
                # vCUCNF22R4_16.250.108
                release_path = cu_build.split("_")[0].replace("vCUCNF", "SBTS")
            self.scf_template_svn_cu = os.path.join(self.scf_template_path, release_path, "SCFC_template_cu.xml")
            self.scf_for_startup_cu = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                   "scf_for_startup_cu.xml")
            self.scf_for_startup_cu_fixing1 = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                           "scf_for_startup_cu_fixing_errors_1.xml")
            self.scf_for_startup_cu_fixing2 = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                           "scf_for_startup_cu_fixing_errors_2.xml")
            # cu du scf structure is a little different, currently treat them is not same.
            self.scf_supplement_cu = os.path.join(self.scf_template_path, release_path, "SCFC_1_supplement_cu.xml")
            # download nidd json from cu/du
            save_log_dir = builtin_obj.get_variable_value("${SUITE_LOG_DIRECTORY}")
            self.nidd_file_cu = os.path.join(save_log_dir, "nidd_cu.json")
            if os.path.exists(self.nidd_file_cu) is False:
                self._get_nidd_file(self.nidd_file_cu, productVariant="cu")

        if self._setup_scf_control_flag_cu:
            self._setup_common_cu()

    def _setup_scf_control_aic_du(self, du_identity="du"):
        """du_identity should be du/du2/du3/du4"""
        if not self._setup_scf_control_flag_du:
            self._setup_scf_control_flag_du = True
            self._setup_common_du()
            if self.alias == "gnb1":
                self.full_commission_log_dir = builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}")
                self.scf_template_full_du = os.path.join("/home/ute", "scf_template_full_%s.xml" % du_identity)
                self.scf_template_for_mo_du = os.path.join("/home/ute", "scf_template_for_mo_%s.xml" % du_identity)
                self.scf_template_for_list_du = os.path.join("/home/ute", "scf_template_for_list_%s.xml" % du_identity)
            else:
                self.full_commission_log_dir = os.path.join(builtin_obj.get_variable_value("${SAVE LOG DIRECTORY}"),
                                                            self.alias)
                self.scf_template_full_du = os.path.join("/home/ute", self.alias,
                                                         "scf_template_full_%s.xml" % du_identity)
                self.scf_template_for_mo_du = os.path.join("/home/ute", self.alias,
                                                           "scf_template_for_mo_%s.xml" % du_identity)
                self.scf_template_for_list_du = os.path.join("/home/ute", self.alias,
                                                             "scf_template_for_list_%s.xml" % du_identity)
                os_obj.create_directory(os.path.join("/home/ute", self.alias))
            self.scf_template_path = builtin_obj.get_variable_value("${SCF_TEMPLATE_PATH}")
            # below build may be need check cu and du, current check cu only.
            cu_build = builtin_obj.get_variable_value("${GNB_CU_VERSION}")
            if cu_build is None:
                cu_build = builtin_obj.get_variable_value("${CU_Build_Version}")
            if cu_build.count("_0.250."):
                # vCUCNF23R1_0.250.3478 #vRAN
                # vCUCNF00_0.250.3478 #vRAN new definition
                release_path = "trunk"
            else:
                # vCUCNF22R4_16.250.108
                release_path = cu_build.split("_")[0].replace("vCUCNF", "SBTS")
            self.scf_template_svn_du = os.path.join(self.scf_template_path, release_path, "SCFC_template_du.xml")
            self.scf_for_startup_du = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                   "scf_for_startup_%s.xml" % du_identity)
            self.scf_for_startup_du_fixing1 = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                           "scf_for_startup_%s_fixing_errors_1.xml" % du_identity)
            self.scf_for_startup_du_fixing2 = os.path.join(self.full_commission_log_dir + "/scfc_logs",
                                                           "scf_for_startup_%s_fixing_errors_2.xml" % du_identity)
            # cu du scf structure is a little different, currently treat them is not same.
            self.scf_supplement_du = os.path.join(self.scf_template_path, release_path, "SCFC_1_supplement_du.xml")
            # download nidd json from cu/du
            save_log_dir = builtin_obj.get_variable_value("${SUITE_LOG_DIRECTORY}")
            self.nidd_file_du = os.path.join(save_log_dir, "nidd_du.json")
            if os.path.exists(self.nidd_file_du) is False:
                self._get_nidd_file(self.nidd_file_du, productVariant="du")

        if self._setup_scf_control_flag_du:
            self._setup_common_du()

    def __del__(self):
        if self._setup_scf_control_flag_cu:
            try:
                self.cu_obj.disconnect(connection=self.alias_cu)
            except Exception as e:
                pass
        if self._setup_scf_control_flag_du:
            try:
                self.du_obj.disconnect(vdu_connection=self.alias_du)
            except Exception as e:
                pass

    def _download_scf_cu(self, scf_tar_path=""):
        time.sleep(1)  # sleep 1s to make sure parameter take effect than to download scf
        self._setup_scf_control_aic_cu()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        timestamp = comm_obj.get_timestamp()
        scf_with_timestamp = "scf_cu_%s.xml" % timestamp
        if not os.path.exists(save_log_dir + "/scfc_logs"):
            os.makedirs(save_log_dir + "/scfc_logs")
        scf_with_fullpath = os.path.join((save_log_dir + "/scfc_logs"), scf_with_timestamp)
        builtin_obj.log("step 1/2:def _download_scf():before get_current_scf_cu_file():[%s]" % scf_with_timestamp)
        try:
            if scf_tar_path == "":
                self.cu_obj.get_current_plan_file(path=scf_with_fullpath, include_runtime_data=True, timeout=100,
                                                  connection=self.alias_cu)
                if os.path.exists(scf_with_fullpath):
                    builtin_obj.log(
                        "step 2/2:def _download_scf():after get_current_scf_cu_file():scf will create in path=[%s]"
                        % scf_with_fullpath)
                    scf_download_path = scf_with_fullpath
                else:
                    raise Exception(
                        "step 2/2:def _download_scf():after get_current_scf_cu_file():find no scf in path=[%s]"
                        % scf_with_fullpath)
            else:
                self.cu_obj.get_current_plan_file(path=scf_tar_path, include_runtime_data=True, timeout=100,
                                                  connection=self.alias_cu)
                if os.path.exists(scf_tar_path):
                    builtin_obj.log(
                        "step 2/2:def _download_scf():after get_current_scf_cu_file():scf will create in path=[%s]"
                        % scf_tar_path)
                    scf_download_path = scf_tar_path
                else:
                    raise Exception(
                        "step 2/2:def _download_scf():after get_current_scf_cu_file():find no scf in path=[%s]"
                        % scf_tar_path)
        except Exception as e:
            raise Exception(str(e))
        finally:
            self._release_admin_conn_cu()
        return scf_download_path

    def _download_scf_du(self, scf_tar_path="", scf_file_name="", du_identity="du"):
        """du_identity should be du/du2/du3/du4"""
        time.sleep(1)  # sleep 1s to make sure parameter take effect than to download scf
        self._setup_scf_control_aic_du(du_identity)
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        if not os.path.exists(save_log_dir + "/scfc_logs"):
            os.makedirs(save_log_dir + "/scfc_logs")
        timestamp = comm_obj.get_timestamp()
        if scf_file_name != "":
            scf_with_timestamp = scf_file_name
        else:
            scf_with_timestamp = "scf_%s_%s.xml" % (du_identity, timestamp)
        scf_with_fullpath = os.path.join((save_log_dir + "/scfc_logs"), scf_with_timestamp)
        builtin_obj.log("step 1/2:def _download_scf():before get_current_scf_%s_file():[%s]" % (du_identity,
                                                                                                scf_with_timestamp))
        try:
            if scf_tar_path == "":
                self.du_obj.get_current_plan_file(local_dir_path=os.path.dirname(scf_with_fullpath),
                                                  filename=scf_with_timestamp,
                                                  timeout=100,
                                                  include_runtime_data=True,
                                                  vdu_connection=self.alias_du)
                if os.path.exists(scf_with_fullpath):
                    builtin_obj.log(
                        "step 2/2:def _download_scf():after get_current_scf_%s_file():scf will create in path=[%s]"
                        % (du_identity, scf_with_fullpath))
                    scf_download_path = scf_with_fullpath
                else:
                    raise Exception("step 2/2:def _download_scf():after get_current_scf_%s_file():"
                                    "find no scf in path=[%s]" % (du_identity, scf_with_fullpath))
            else:
                self.du_obj.get_current_plan_file(local_dir_path=os.path.dirname(scf_tar_path),
                                                  filename=os.path.basename(scf_with_timestamp),
                                                  timeout=100,
                                                  include_runtime_data=True,
                                                  vdu_connection=self.alias_du)
                if os.path.exists(scf_tar_path):
                    builtin_obj.log(
                        "step 2/2:def _download_scf():after get_current_scf_%s_file():scf will create in path=[%s]"
                        % (du_identity, scf_tar_path))
                    scf_download_path = scf_tar_path
                else:
                    raise Exception("step 2/2:def _download_scf():after get_current_scf_%s_file():"
                                    "find no scf in path=[%s]" % (du_identity, scf_tar_path))
        except Exception as e:
            raise Exception(str(e))
        finally:
            self._release_admin_conn_du()
        return scf_download_path

    def _modify_scf_cu(self, scf_base, parameters, scf_target):
        builtin_obj.log("====== step: _modify_scf_cu ======")
        builtin_obj.log("base scf_cu is %s" % scf_base, console=True)
        self._setup_scf_control_aic_cu()

        # get bts id
        mrbts_dn = xml_obj.read_xml(scf_base, "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        bts_id = mrbts_dn.split("-")[-1]

        # migrate scf_base
        os_obj.copy_file(scf_base, scf_target)
        migrated_scf = self._scf_migration_cu(scf_target)
        os_obj.move_file(migrated_scf, os.path.join(os.path.dirname(migrated_scf), "migrated_SCFC_1_cu.xml"))

        # create 3 scf template
        self._generate_three_templates_cu(bts_id)

        # update scf according to required parameters
        self._update_scf_aic(scf_target, parameters, productVariant="cu")

    def _scf_migration_cu(self, source_scf):
        builtin_obj.log("====== step: _scf_migration_cu ======")
        self._setup_scf_control_aic_cu()
        flag = False
        scf_name = source_scf.split("/")[-1]
        migrated_scf = os.path.join(self.full_commission_log_dir + "/scfc_logs", "migrated_%s" % scf_name)
        builtin_obj.log("src cu file is %s" % source_scf)
        builtin_obj.log("migrate cu file is %s" % migrated_scf)
        try:
            scf_plan_id = self._upload_plan_file_cu(source_scf, plan_name=scf_name, connection=self.alias_cu)
            scf_action_id = self._plan_validation_cu(plan_id=scf_plan_id, connection=self.alias_cu)
            scf_validation_id = self._get_operation_state_of_validating_plan_cu(plan_id=scf_plan_id,
                                                                                operation_id=scf_action_id,
                                                                                connection=self.alias_cu)
            result = self._get_staged_plan_validation_results_cu(plan_id=scf_plan_id, validation_id=scf_validation_id)
            result_err_wrn = int(result["totalError"]) + int(result["totalWarning"])
            if result_err_wrn > 0 and source_scf.count("scf_for_startup_cu.xml"):
                builtin_obj.log("xk:there are relation errors in initial startup scf_cu, try to migration")

            self._fix_error_cu(stage_plan_id=scf_plan_id)

            # revalidation after fix_error
            scf_act_id_fixerr = self._plan_validation_cu(plan_id=scf_plan_id, connection=self.alias_cu)
            scf_validation_id_fixerr = self._get_operation_state_of_validating_plan_cu(plan_id=scf_plan_id,
                                                                                       operation_id=scf_act_id_fixerr,
                                                                                       connection=self.alias_cu)
            result_fix_err = self._get_staged_plan_validation_results_cu(plan_id=scf_plan_id,
                                                                         validation_id=scf_validation_id_fixerr)
            if source_scf.count("scf_for_startup_cu.xml"):
                total_err_wrn_cu = int(result_fix_err["totalError"]) + int(result_fix_err["totalWarning"])
                if total_err_wrn_cu > 0:
                    self.init_relation_errors_num_cu = total_err_wrn_cu
                    comm_obj.log_to_console_with_time_prefix(
                        "there are relation errors in initial startup scf_cu after migration, "
                        "pls inform I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com to fix them", level="WARN")
                else:
                    builtin_obj.log("xk:no relation errors in initial startup scf_cu after migration")

            # fetch migrated scf
            self._get_plan_file_cu(plan_id=scf_plan_id, path=migrated_scf)

            # delete migrated scf from cu web admin for avoiding massive of redundant plan file
            self._delete_plan_file_cu(plan_id=scf_plan_id)

            if os_obj.get_file_size(migrated_scf) > 10000:
                # size > 10KB
                os_obj.copy_file(migrated_scf, source_scf)
                flag = True
            else:
                builtin_obj.log("fail to migrate %s" % source_scf, level="WARN")
                os_obj.copy_file(source_scf, migrated_scf)
        except Exception as _err:
            builtin_obj.log("fail to migrate %s because '%s'" % (source_scf, _err), level="WARN")
            os_obj.copy_file(source_scf, migrated_scf)
        # kw not support due to CB012840
        # finally:
        #     # search existed plan file in cu web admin and delete them for avoiding maximum number exceed
        #     plan_info_list = self._get_plan_info_cu()
        #     if len(plan_info_list) != 0:
        #         for plan_info in plan_info_list:
        #             self._delete_plan_file_cu(plan_info["plan_id"])
        return migrated_scf

    def _upload_plan_file_cu(self, source_scf, plan_name, connection):
        """:return    scf_plan_id"""
        builtin_obj.log("====== step: _upload_plan_file_cu ======")
        result = self.cu_obj.upload_plan_file(source_scf, plan_name, connection=connection)
        builtin_obj.log("step: get_plan_file_upload_action_cu_result: %s" % result)
        scf_plan_id = result["plan_id"]
        scf_upload_action_id = result["action_id"]
        self._get_operation_state_of_uploading_plan_cu(action_id=scf_upload_action_id, connection=connection)
        return scf_plan_id

    def _get_operation_state_of_uploading_plan_cu(self, action_id, connection):
        """:return    scf_uploading state (ongoing, success)
           10s timeout setting for get validation plan result with validation_id
           get cu plan file uploading state and check it is success but not ongoing
        """
        time_start = time.time()
        while True:
            result = self.cu_obj.get_operation_state_of_uploading_plan(operation_id=action_id, connection=connection)
            builtin_obj.log("step: get_uploading_plan_result_cu: %s" % result)
            if result["status"] != "success":
                time.sleep(2)
                if time.time() - time_start > 10:
                    builtin_obj.log("get_operation_state_of_uploading_plan_cu timeout", level="WARN")
                    break
            elif result["status"] == "success":
                break

    def _plan_validation_cu(self, plan_id, connection):
        """:return    scf_action_id"""
        builtin_obj.log("====== step: _plan_validation_cu ======")
        result = self.cu_obj.plan_validation(plan_id, connection=connection)
        builtin_obj.log("step: get_plan_file_validate_action_cu_result: %s" % result)
        scf_action_id = result["action_id"]
        return scf_action_id

    def _get_operation_state_of_validating_plan_cu(self, plan_id, operation_id, connection):
        """:return    scf_validation_id
           10s timeout setting for get validation plan result with validation_id
        """
        builtin_obj.log("====== step: _get_operation_state_of_validating_plan_cu ======")
        time_start = time.time()
        while True:
            result = self.cu_obj.get_operation_state_of_validating_plan(plan_id, operation_id, connection)
            builtin_obj.log("step: get_validate_result_cu: %s" % result)
            if result["validation_id"] is None:
                time.sleep(2)
                if time.time() - time_start > 20:
                    builtin_obj.log("get_operation_state_of_validating_plan_cu timeout", level="WARN")
                    break
            else:
                break
        scf_validation_id = result["validation_id"]
        return scf_validation_id

    def _get_staged_plan_validation_results_cu(self, plan_id, validation_id):
        """
        Parameters:
            plan_id – staged plan id
            validation_id – validation id returned from validation operation
            error_type – parameterRelationError, topologyDefinitionError, occurrenceDefinitionError,
                    parameterDefinitionError, topologyRelationError default is none meaning all of the error types
            connection – VcuConnection object or string name alias if used
        """
        builtin_obj.log("====== step: _get_staged_plan_validation_results_cu ======")
        result = self.cu_obj.get_validation_result_of_staged_plan(plan_id, validation_id, connection=self.alias_cu)
        return result

    def _validate_scf_and_get_validation_result_cu(self, source_scf, plan_name):
        """step1: upload plan file to cu admin
           step2: plan validation in cu admin
           step3: get operation state of scf validation sate with validation id
           step4: get plan validation results with error description
           step5: delte validated plan file
        """
        scf_plan_id = self._upload_plan_file_cu(source_scf, plan_name, connection=self.alias_cu)
        scf_action_id = self._plan_validation_cu(plan_id=scf_plan_id, connection=self.alias_cu)
        scf_validation_id = self._get_operation_state_of_validating_plan_cu(plan_id=scf_plan_id,
                                                                            operation_id=scf_action_id,
                                                                            connection=self.alias_cu)
        result = self._get_staged_plan_validation_results_cu(plan_id=scf_plan_id, validation_id=scf_validation_id)
        self._delete_plan_file_cu(plan_id=scf_plan_id)
        return result

    def _validate_scf_and_get_validation_result_du(self, source_scf, plan_name, vdu_conn):
        """step1: upload plan file to du admin
           step2: plan validation in du admin
           step3: get operation state of scf validation sate with validation id
           step4: get plan validation results with error description
           step5: delte validated plan file for avoiding massive redundancy plan file
        """
        scf_plan_id = self._upload_plan_file_du(source_scf, plan_name, connection=vdu_conn)
        scf_action_id = self._plan_validation_du(plan_id=scf_plan_id, connection=vdu_conn)
        scf_validation_id = self._get_operation_state_of_validating_plan_du(plan_id=scf_plan_id,
                                                                            operation_id=scf_action_id,
                                                                            connection=vdu_conn)
        result = self._get_staged_plan_validation_results_du(plan_id=scf_plan_id, validation_id=scf_validation_id,
                                                             vdu_conn=vdu_conn)
        self._delete_plan_file_du(plan_id=scf_plan_id, vcu_conn=vdu_conn)
        return result

    def _fix_error_cu(self, stage_plan_id):
        builtin_obj.log("====== step: _fix_error_cu ======")
        result = self.cu_obj.fix_plan_validation_errors(stage_plan_id, add_missing_objects=True,
                                                        fix_mandatory_parameters=True, connection=self.alias_cu)
        builtin_obj.log("fix_action_cu: %s" % result)
        fix_action_id = result["actionId"]
        fix_result = self.cu_obj.get_action_state_of_fix_plan(stage_plan_id, action_id=fix_action_id,
                                                              connection=self.alias_cu)
        builtin_obj.log("fix_result_cu: %s" % fix_result)
        if fix_result["status"] == "ongoing":
            time.sleep(5)
            fix_result = self.cu_obj.get_action_state_of_fix_plan(stage_plan_id, action_id=fix_action_id,
                                                                  connection=self.alias_cu)
            builtin_obj.log("fix_result2_cu: %s" % fix_result)

    def _get_plan_file_cu(self, plan_id, path):
        builtin_obj.log("====== step:_get_plan_file_cu ======")
        get_cu_plan_flag = False
        time_start = time.time()
        while get_cu_plan_flag is False:
            try:
                self.cu_obj.get_plan_file(plan_id, path, include_auto_config_data=True, connection=self.alias_cu)
                get_cu_plan_flag = True
                builtin_obj.log("get cu plan scf successful")
            except Exception as _err:
                builtin_obj.log(_err)
                builtin_obj.log("fail to get plan scf, try again after 5s")
                get_cu_plan_flag = False
                time.sleep(5)
                if time.time() - time_start >= 20:
                    break

    def _delete_plan_file_cu(self, plan_id):
        """delete plan scf from cu web_admin"""
        self.cu_obj.plan_delete(plan_id, connection=self.alias_cu)

    def _get_plan_info_cu(self):
        plan_info_list = self.cu_obj.get_plan_info(connection=self.alias_cu)
        return plan_info_list

    def _check_pod_reseting(self, namespace, podname, productVariant, interrupt_once_fail, alias, timeout=120):
        """timeout:    maximum time for waiting appointed pod to running state(default 120s)
           self.pod_ssh_ip/self.pod_ssh_usr/self.pod_ssh_pwd: fetch from class instance for each du separately
        """
        builtin_obj.log("step: check pod resetting")
        if productVariant == "cu":
            self.host_ssh_ip = builtin_obj.get_variable_value("${VCU_SSH_IP}")
            self.host_ssh_usr = builtin_obj.get_variable_value("${VCU_SSH_USER}")
            self.host_ssh_pwd = builtin_obj.get_variable_value("${VCU_SSH_PASSWD}")
            if self.alias == "gnb2":
                self.host_ssh_ip = builtin_obj.get_variable_value("${VCU2_SSH_IP}")
                self.host_ssh_usr = builtin_obj.get_variable_value("${VCU2_SSH_USER}")
                self.host_ssh_pwd = builtin_obj.get_variable_value("${VCU2_SSH_PASSWD}")
        try:
            self.fsm_obj = ute_fsmaccess()
            self.fsm_obj.setup_enb_fsm_access(remote_host=self.remote_host, alias=alias, prompt="$",
                                              user=self.host_ssh_usr, password=self.host_ssh_pwd, fallback_prompt="$",
                                              host=self.host_ssh_ip)
            pod_reset_flag = False
            pod_running_info = None
            timeout = timeout
            while pod_reset_flag is False and timeout >= 0:
                time.sleep(5)
                pod_running_info = self.fsm_obj.execute_command_on_enb("kubectl get pods -n %s" % namespace,
                                                                       alias=alias)
                for j in pod_running_info.split("\n")[1:]:
                    if j.split()[0].count("-" + podname + "-"):
                        if j.split()[2] != "Running":
                            pod_reset_flag = True
                            break
                        elif j.split()[2] == "Running":
                            if re.match(r"(\d+)/(\d+)", j.split()[1]).group(1) != re.match(r"(\d+)/(\d+)",
                                                                                           j.split()[1]).group(2):
                                pod_reset_flag = True
                                break
                            else:
                                timeout -= 5
                                pod_reset_flag = False
                                continue
                        else:
                            timeout -= 5
                            pod_reset_flag = False
                            continue
            builtin_obj.log("pod_reset_flag:%s" % pod_reset_flag)
        except Exception as e:
            builtin_obj.log("pod_reset_debug:%s" % e)
        finally:
            self.fsm_obj.teardown_enb_fsm_access(alias=alias)
        if pod_reset_flag is True:
            if interrupt_once_fail is True:
                raise Exception("xk:pod %s is not running" % podname)
            else:
                builtin_obj.log("xk:pod %s is resetting" % podname)
        builtin_obj.log("pod_running_info:\n %s" % pod_running_info)
        return pod_reset_flag

    def _perform_full_commission_cu(self, scf, plan_name, connection):
        """need check if plan_activation contain 'is complete' info and sustain time
           then consider if need get_operation_state_of_activating_plan operation ***
           status: should be 'success' for cu
        """
        vcu_namespace = builtin_obj.get_variable_value("${VCU_NAMESPACE}")
        if self.alias == "gnb2":
            vcu_namespace = builtin_obj.get_variable_value("${VCU2_NAMESPACE}")
        scf_plan_id = self._upload_plan_file_cu(scf, plan_name, connection)

        # verify relation error after migration before activate
        scf_action_id = self._plan_validation_cu(plan_id=scf_plan_id, connection=connection)
        scf_validation_id = self._get_operation_state_of_validating_plan_cu(plan_id=scf_plan_id,
                                                                            operation_id=scf_action_id,
                                                                            connection=connection)
        result = self._get_staged_plan_validation_results_cu(plan_id=scf_plan_id, validation_id=scf_validation_id)
        result_err_wrn = int(result["totalError"]) + int(result["totalWarning"])
        if result_err_wrn > 0 and scf.count("scf_for_startup_cu.xml"):
            comm_obj.log_to_console_with_time_prefix(
                "\033[1;31;47mExist relation errors in %s scf_for_startup_cu.xml after migration,"
                " pls fix them!\033[0m" % self.alias, level="WARN")
            raise Exception("Relation errors info:\n%s" % result)

        # activate scf
        scf_activation_id = self._plan_activation_cu(plan_id=scf_plan_id, connection=connection)
        # below wait ping not need due to will check pod reseting later.and du not add and work fine.
        # self._wait_ping_ok_cu_du_admin(productVariant="cu")
        full_commission_timeout = 300
        activation_status = None
        # below check full commission operation will put after all CU DU full commission finish
        # renew for detect scf relation error, fail commission due to aic can't download once relation error exist
        while full_commission_timeout >= 0:
            full_commission_timeout -= 5
            time.sleep(5)
            try:
                comm_obj.log_to_console_with_time_prefix("step:check cu activation status")
                pod_reset = self._check_pod_reseting(vcu_namespace, "oamext", productVariant="cu",
                                                     interrupt_once_fail=False, alias="cu_pod")
                if pod_reset is True:
                    activation_status = "Successfully"
                    break
                else:
                    result = self.cu_obj.get_operation_state_of_activating_plan(scf_plan_id, scf_activation_id,
                                                                                connection)
                    if result["status"] == "success":
                        activation_status = result["status"]
                        break
                    elif result["status"] == "failure":
                        activation_status = result["status"]
                        break
                    else:
                        activation_status = result["status"]
                        continue
            except Exception as e:
                builtin_obj.log("Cu is full commissioning %s" % e)
                activation_status = "Successful"
                break
        return activation_status

    def _plan_activation_cu(self, plan_id, connection):
        """:return    scf_active_action_id"""
        result = self.cu_obj.plan_activation(plan_id, timeout=600, connection=connection)
        builtin_obj.log("activation_action_cu: %s" % result)
        scf_activation_id = result["id"]
        return scf_activation_id

    def _generate_three_templates_cu(self, bts_id, save_path=None):
        os_obj.copy_file(self.scf_template_svn_cu, self.scf_template_full_cu)
        if bts_id != "1":
            comm_obj.execute_cmd_on_pc("sed -i 's:MRBTS-1:MRBTS-%s:g' %s" % (bts_id, self.scf_template_full_cu))
            comm_obj.execute_cmd_on_pc("sed -i 's:NRBTS-1:NRBTS-%s:g' %s" % (bts_id, self.scf_template_full_cu))

        self._delete_object_offline(self.scf_template_full_cu, self.scf_template_for_mo_cu,
                                    reduced_var_aic.STRUCT_REDUCED_FOR_MO)

        self._delete_object_offline(self.scf_template_for_mo_cu, self.scf_template_for_mo_cu,
                                    reduced_var_aic.STRUCT_REDUCED_FOR_LIST)

        self._delete_object_offline(self.scf_template_full_cu, self.scf_template_for_list_cu,
                                    reduced_var_aic.STRUCT_REDUCED_FOR_LIST)

        ret1 = self._scf_migration_cu(self.scf_template_full_cu)
        ret2 = self._scf_migration_cu(self.scf_template_for_mo_cu)
        ret3 = self._scf_migration_cu(self.scf_template_for_list_cu)

        if save_path is not None and os.path.exists(save_path):
            os_obj.copy_file(self.scf_template_full_cu,
                             os.path.join(save_path, os.path.basename(self.scf_template_full_cu)))
            os_obj.copy_file(self.scf_template_for_mo_cu,
                             os.path.join(save_path, os.path.basename(self.scf_template_for_mo_cu)))
            os_obj.copy_file(self.scf_template_for_list_cu,
                             os.path.join(save_path, os.path.basename(self.scf_template_for_list_cu)))
            os_obj.copy_file(ret1,
                             os.path.join(save_path, "migrated_%s" % os.path.basename(self.scf_template_full_cu)))
            os_obj.copy_file(ret2,
                             os.path.join(save_path, "migrated_%s" % os.path.basename(self.scf_template_for_mo_cu)))
            os_obj.copy_file(ret3,
                             os.path.join(save_path, "migrated_%s" % os.path.basename(self.scf_template_for_list_cu)))

    def _modify_scf_du(self, scf_base, parameters, scf_target, du_identity="du"):
        """du_identity should be du/du2/du3/du4"""
        builtin_obj.log("====== step: _modify_scf_du ======")
        builtin_obj.log("base scf_du is %s" % scf_base, console=True)
        self._setup_scf_control_aic_du(du_identity)

        # get bts id
        mrbts_dn = xml_obj.read_xml(scf_base, "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        bts_id = mrbts_dn.split("-")[-1]

        # migrate scf_base
        os_obj.copy_file(scf_base, scf_target)
        migrated_scf = self._scf_migration_du(scf_target, vdu_conn=self.alias_du, du_identity=du_identity)
        os_obj.move_file(migrated_scf, os.path.join(os.path.dirname(migrated_scf),
                                                    "migrated_SCFC_1_%s.xml" % du_identity))

        # create 3 scf template
        self._generate_three_templates_du(bts_id, du_identity=du_identity)

        # update scf  according to required parameters
        self._update_scf_aic(scf_target, parameters, productVariant="du", du_identity=du_identity)

    def _scf_migration_du(self, source_scf, vdu_conn, du_identity="du"):
        builtin_obj.log("====== step: _scf_migration_du ======")
        self._setup_scf_control_aic_du(du_identity)
        flag = False
        scf_name = source_scf.split("/")[-1]
        migrated_scf = os.path.join(self.full_commission_log_dir + "/scfc_logs", "migrated_%s" % scf_name)
        builtin_obj.log("src %s file is %s" % (du_identity, source_scf))
        builtin_obj.log("migrate %s file is %s" % (du_identity, migrated_scf))
        try:
            scf_plan_id = self._upload_plan_file_du(source_scf, plan_name=scf_name, connection=vdu_conn)
            scf_action_id = self._plan_validation_du(plan_id=scf_plan_id, connection=vdu_conn)
            scf_validation_id = self._get_operation_state_of_validating_plan_du(plan_id=scf_plan_id,
                                                                                operation_id=scf_action_id,
                                                                                connection=vdu_conn)
            result = self._get_staged_plan_validation_results_du(plan_id=scf_plan_id,
                                                                 validation_id=scf_validation_id,
                                                                 vdu_conn=vdu_conn)
            result_err_wrn = int(result["totalError"]) + int(result["totalWarning"])
            if result_err_wrn > 0 and source_scf.count("scf_for_startup_%s.xml" % du_identity):
                builtin_obj.log("xk:there are relation errors in initial startup scf_%s,"
                                "try to migration" % du_identity)

            self._fix_error_du(stage_plan_id=scf_plan_id, vdu_conn=vdu_conn)
            # revalidation after migration
            scf_act_id_fixerr = self._plan_validation_du(plan_id=scf_plan_id, connection=vdu_conn)
            scf_validation_id_fixerr = self._get_operation_state_of_validating_plan_du(plan_id=scf_plan_id,
                                                                                       operation_id=scf_act_id_fixerr,
                                                                                       connection=vdu_conn)
            result_fix_err = self._get_staged_plan_validation_results_du(plan_id=scf_plan_id,
                                                                         validation_id=scf_validation_id_fixerr,
                                                                         vdu_conn=vdu_conn)
            if source_scf.count("scf_for_startup_%s.xml" % du_identity):
                total_err_wrn_du = int(result_fix_err["totalError"]) + int(result_fix_err["totalWarning"])
                if total_err_wrn_du > 0:
                    self.init_relation_errors_num_du = total_err_wrn_du
                    comm_obj.log_to_console_with_time_prefix(
                        "there are relation errors in initial startup scf_%s after migration, "
                        "pls inform I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com to fix them" % du_identity,
                        level="WARN")
                else:
                    builtin_obj.log("xk:no relation errors in initial startup scf_%s after migration" % du_identity)

            # fetch migrated scf
            self._get_plan_file_du(scf_plan_id, self.full_commission_log_dir + "/scfc_logs",
                                   local_filename="migrated_%s" % scf_name, vcu_conn=vdu_conn)

            # delete migrated scf from cu web admin for avoiding massive of redundant plan file
            self._delete_plan_file_du(plan_id=scf_plan_id, vcu_conn=vdu_conn)

            if os_obj.get_file_size(migrated_scf) > 10000:
                # size > 10KB
                os_obj.copy_file(migrated_scf, source_scf)
                flag = True
            else:
                builtin_obj.log("fail to migrate %s" % source_scf, level="WARN")
                os_obj.copy_file(source_scf, migrated_scf)
        except Exception as _err:
            builtin_obj.log("fail to migrate %s because '%s'" % (source_scf, _err), level="WARN")
            os_obj.copy_file(source_scf, migrated_scf)
        # kw not support due to CB012840
        # finally:
        #     # search existed plan file in du web admin and delete them for avoiding maximum number exceed
        #     plan_info_list = self._get_plan_info_du(vdu_conn=vdu_conn)
        #     if len(plan_info_list) != 0:
        #         for plan_info in plan_info_list:
        #             self._delete_plan_file_du(plan_id=plan_info["plan_id"], vcu_conn=vdu_conn)
        return migrated_scf

    def _upload_plan_file_du(self, source_scf, plan_name, connection):
        """:return    scf_plan_id"""
        builtin_obj.log("====== step: _upload_plan_file_du ======")
        result = self.du_obj.upload_plan(source_scf, plan_name, vdu_connection=connection)
        builtin_obj.log("upload_action_du: %s" % result)
        scf_plan_id = result["plan_id"]
        scf_upload_action_id = result["action_id"]
        self._get_upload_plan_operation_status_du(action_id=scf_upload_action_id, connection=connection)
        return scf_plan_id

    def _get_upload_plan_operation_status_du(self, action_id, connection):
        """:return    scf_uploading state (ongoing, success)
           10s timeout setting for get validation plan result with validation_id
           get du plan file uploading state and check it is success but not ongoing
        """
        time_start = time.time()
        while True:
            result = self.du_obj.get_upload_plan_operation_status(operation_id=action_id, vdu_connection=connection,
                                                                  timeout=5)
            builtin_obj.log("step: get_uploading_plan_result_du: %s" % result)
            if result["status"] != "success":
                time.sleep(2)
                if time.time() - time_start > 10:
                    builtin_obj.log("get_operation_state_of_uploading_plan_du timeout", level="WARN")
                    break
            elif result["status"] == "success":
                break

    def _plan_validation_du(self, plan_id, connection):
        """:return    scf_action_id"""
        builtin_obj.log("====== step: _plan_validation_du ======")
        result = self.du_obj.validate_plan(plan_id, vdu_connection=connection)
        builtin_obj.log("validate_action_du: %s" % result)
        scf_action_id = result["action_id"]
        return scf_action_id

    def _get_operation_state_of_validating_plan_du(self, plan_id, operation_id, connection):
        """:return    scf_validation_id
           10s timeout setting for get validation plan result with validation_id
        """
        builtin_obj.log("====== step: _get_operation_state_of_validating_plan_du ======")
        time_start = time.time()
        while True:
            result = self.du_obj.get_validate_plan_operation_status(plan_id, operation_id, vdu_connection=connection)
            builtin_obj.log("validate_result_du: %s" % result)
            if result["validation_id"] is None:
                time.sleep(2)
                if time.time() - time_start > 10:
                    builtin_obj.log("get_operation_state_of_validating_plan_du timeout", level="WARN")
                    break
            else:
                break
        scf_validation_id = result["validation_id"]
        return scf_validation_id

    def _get_staged_plan_validation_results_du(self, plan_id, validation_id, vdu_conn):
        """using validate function in Vdu for cu plan file result validation due to no this func in taf cu now.
        Parameters:
            plan_id – staged plan id
            validation_id – validation id returned from validation operation
            error_type – parameterRelationError, topologyDefinitionError, occurrenceDefinitionError,
                    parameterDefinitionError, topologyRelationError default is none meaning all of the error types
            vdu_connection – VduConnection object or string name alias if used
        """
        builtin_obj.log("====== step: _get_staged_plan_validation_results_du ======")
        result = self.du_obj.get_staged_plan_validation_results(plan_id, validation_id, vdu_connection=vdu_conn)
        return result

    def _fix_error_du(self, stage_plan_id, vdu_conn):
        builtin_obj.log("====== step: _fix_error_du ======")
        result = self.du_obj.fix_vdu_staged_plan_error(stage_plan_id, add_missing_obj=True, timeout=30,
                                                       vdu_connection=vdu_conn)
        builtin_obj.log("fix_action_du: %s" % result)
        fix_action_id = result["actionId"]
        fix_result = self.du_obj.get_fix_vdu_staged_plan_operation_status(stage_plan_id, action_id=fix_action_id,
                                                                          vdu_connection=vdu_conn)
        builtin_obj.log("fix_result_du: %s" % fix_result)
        if fix_result["status"] == "ongoing":
            time.sleep(5)
            fix_result = self.du_obj.get_fix_vdu_staged_plan_operation_status(stage_plan_id, action_id=fix_action_id,
                                                                              vdu_connection=vdu_conn)
            builtin_obj.log("fix_result2_du: %s" % fix_result)

    def _get_plan_file_du(self, plan_id, path, local_filename, vcu_conn):
        builtin_obj.log("====== step: _get_plan_file_du ======")
        get_du_plan_flag = False
        time_start = time.time()
        while get_du_plan_flag is False:
            try:
                self.du_obj.get_staged_plan_file_with_planid(plan_id, path, local_filename,
                                                             include_auto_config_data=True, vdu_connection=vcu_conn)
                get_du_plan_flag = True
            except Exception as _err:
                builtin_obj.log(_err)
                builtin_obj.log("fail to get plan scf, try again after 5s")
                get_du_plan_flag = False
                time.sleep(5)
                if time.time() - time_start >= 20:
                    break

    def _delete_plan_file_du(self, plan_id, vcu_conn):
        """delete plan scf from du web_admin"""
        builtin_obj.log("====== step: _delete_plan_file_du ======")
        self.du_obj.delete_staged_plan_file(plan_id, vdu_connection=vcu_conn)

    def _get_plan_info_du(self, vdu_conn):
        plan_info_list = self.du_obj.get_staged_plans_info_list(vdu_connection=vdu_conn)
        return plan_info_list

    def _perform_full_commission_du(self, scf, plan_name, connection, du_identity="du"):
        """need check if plan_activation contain 'is complete' info and sustain time
           then consider if need get_operation_state_of_activating_plan opreation ***
           status: should be 'success' for du
           self.vdu_namespace fetch from class instance for each du separately.
        """
        scf_plan_id = self._upload_plan_file_du(scf, plan_name, connection)

        # verify relation error after migration before activate
        scf_action_id = self._plan_validation_du(plan_id=scf_plan_id, connection=connection)
        scf_validation_id = self._get_operation_state_of_validating_plan_du(plan_id=scf_plan_id,
                                                                            operation_id=scf_action_id,
                                                                            connection=connection)
        result = self._get_staged_plan_validation_results_du(plan_id=scf_plan_id,
                                                             validation_id=scf_validation_id,
                                                             vdu_conn=connection)
        result_err_wrn = int(result["totalError"]) + int(result["totalWarning"])
        if result_err_wrn > 0:
            if scf.count("scf_for_startup_%s.xml" % du_identity):
                comm_obj.log_to_console_with_time_prefix(
                    "\033[1;31;47mExist relation errors in scf_for_startup_%s.xml after migration,"
                    " pls fix them!\033[0m" % du_identity, level="WARN")
            raise Exception("Relation errors info:\n%s" % result)

        # activat scf
        scf_activation_id = self._plan_activation_du(plan_id=scf_plan_id, connection=connection)
        full_commission_timeout = 300
        activation_status = None
        # below check full commission operation will put after all CU DU full commission finish
        # renew for detect scf relation error, fail commission due to aic can't download once relation error exist
        while full_commission_timeout:
            full_commission_timeout -= 5
            time.sleep(5)
            try:
                comm_obj.log_to_console_with_time_prefix("step:check %s activation status" % du_identity)
                pod_reset = self._check_pod_reseting(self.vdu_namespace, "oamext", productVariant="du",
                                                     interrupt_once_fail=False, alias="du_pod")
                if pod_reset is True:
                    activation_status = "Successfully"
                    break
                else:
                    result = self.du_obj.get_activate_plan_operation_status(scf_plan_id, scf_activation_id,
                                                                            vdu_connection=connection)
                    if result["status"] == "success":
                        activation_status = result["status"]
                        break
                    elif result["status"] == "failure":
                        activation_status = result["status"]
                        builtin_obj.log("%s scf activate fail" % du_identity, level="ERROR", console=True)
                        break
                    else:
                        activation_status = result["status"]
                        continue
            except Exception as e:
                builtin_obj.log("%s is full commissioning: %s" % (du_identity, e))
                activation_status = "Successful"
                break
        return activation_status

    def _plan_activation_du(self, plan_id, connection):
        """:return    scf_active_action_id"""
        result = self.du_obj.activate_plan(plan_id, timeout=600, vdu_connection=connection)
        builtin_obj.log("activation_action_du: %s" % result)
        scf_activation_id = result["id"]
        return scf_activation_id

    def _generate_three_templates_du(self, bts_id, save_path=None, du_identity="du"):
        # builtin_obj.log("scf template is %s and SCFC_1_supplement_du.xml" % self.scf_template_svn_du, console=True)

        # one template becomes three template
        os_obj.copy_file(self.scf_template_svn_du, self.scf_template_full_du)
        if bts_id != "1":
            comm_obj.execute_cmd_on_pc("sed -i 's:MRBTS-1:MRBTS-%s:g' %s" % (bts_id, self.scf_template_full_du))
            comm_obj.execute_cmd_on_pc("sed -i 's:NRBTS-1:NRBTS-%s:g' %s" % (bts_id, self.scf_template_full_du))
        self._delete_object_offline(self.scf_template_full_du, self.scf_template_for_mo_du,
                                    reduced_var_aic.STRUCT_REDUCED_FOR_MO)
        self._delete_object_offline(self.scf_template_for_mo_du, self.scf_template_for_mo_du,
                                    reduced_var_aic.STRUCT_REDUCED_FOR_LIST)
        self._delete_object_offline(self.scf_template_full_du, self.scf_template_for_list_du,
                                    reduced_var_aic.STRUCT_REDUCED_FOR_LIST)
        ret1 = self._scf_migration_du(self.scf_template_full_du, vdu_conn=self.alias_du, du_identity=du_identity)
        ret2 = self._scf_migration_du(self.scf_template_for_mo_du, vdu_conn=self.alias_du, du_identity=du_identity)
        ret3 = self._scf_migration_du(self.scf_template_for_list_du, vdu_conn=self.alias_du, du_identity=du_identity)

        if save_path is not None and os.path.exists(save_path):
            os_obj.copy_file(self.scf_template_full_du,
                             os.path.join(save_path, os.path.basename(self.scf_template_full_du)))
            os_obj.copy_file(self.scf_template_for_mo_du,
                             os.path.join(save_path, os.path.basename(self.scf_template_for_mo_du)))
            os_obj.copy_file(self.scf_template_for_list_du,
                             os.path.join(save_path, os.path.basename(self.scf_template_for_list_du)))
            os_obj.copy_file(ret1,
                             os.path.join(save_path, "migrated_%s" % os.path.basename(self.scf_template_full_du)))
            os_obj.copy_file(ret2,
                             os.path.join(save_path, "migrated_%s" % os.path.basename(self.scf_template_for_mo_du)))
            os_obj.copy_file(ret3,
                             os.path.join(save_path, "migrated_%s" % os.path.basename(self.scf_template_for_list_du)))

    def _update_scf_aic(self, scf, parameters, productVariant, du_identity="du"):
        """
            | Input Parameters | Man. | Description |
            | scf  |  Yes  |
            | parameters | Yes |
            | productVariant  |  Yes  | cu, du
            | du_identity | No | du, du2, du3, du4 default is du
        """
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        parameters = self._convert_delete(parameters)
        # check if parameters are in NIDD, scf template or scf supplement
        self._search_params_in_template_aic(parameters, productVariant, du_identity)
        # extend NRCELL and LCELL and NRBTS according scf template
        parameters = self._extend_parameters(parameters, scf)
        builtin_obj.log("parameters to be changed: %s" % parameters)

        # modify scf according to parameters
        if len(parameters):
            params_classified = self._classify_parameters_according_to_moname(parameters)
            for mo in params_classified.keys():
                if mo == "delete":
                    self._delete_object_offline(
                        scf, scf, params_classified["delete"])

            for mo in params_classified.keys():
                if mo != "delete":
                    existing = self._find_mo(scf, mo)
                    if existing:
                        # update parameters of mo
                        builtin_obj.log("xk_mo: there is %s in %s, update it" % (mo, scf))
                        target_scf_content = self._add_or_update_parameters_element_aic(
                            scf, params_classified[mo], productVariant, du_identity)
                        commonxml = CommonXML(target_scf_content)
                        commonxml.save_xml(scf, target_scf_content)
                    else:
                        builtin_obj.log("xk_mo: no %s in %s, create it" % (mo, scf))
                        mo_create = self._create_mo_aic(params_classified[mo], productVariant, du_identity, "full")
                        mo_create = self._fix_mo_create_error(mo, scf, mo_create)
                        xml_obj.add_xml_element(scf, scf, mo_create + "|//cmData")
            # remove mo:key=${EMPTY}
            xml_obj.remove_xml_element(scf, scf, "//managedObject/p[not(text())]")
            # remove mo:list=${EMPTY}
            xml_obj.remove_xml_element(scf, scf, "//managedObject/list[not(node())]")
            # remove mo:list:key=${EMPTY}
            xml_obj.remove_xml_element(scf, scf,
                                       "//managedObject/list//p[not(text())]")
        else:
            builtin_obj.log("no parameters to be changed")

    def _search_params_in_template_aic(self, parameters, productVariant, du_identity="du"):
        """
            search parameters in scf template and SCFC_1_supplement.xml
            | Input Parameters | Man. | Description |
            | parameters  |  Yes  | parameters to be search
            | productVariant  |  Yes  | cu, du
            | du_identity  | No | du, du2, default is du
        """
        builtin_obj.log("step: start to _search_params_in_template_aic for %s" % productVariant)
        if productVariant == "du":
            self._setup_scf_control_aic_du(du_identity)
        if productVariant == "cu":
            self._setup_scf_control_aic_cu()

        # find mo:key, mo:list, mo:list:key, mo
        params_to_check = []
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if param.count("delete"):
                continue
            if param.count("="):
                params_to_check.append(param.split("=")[0])
                if param.count("|"):
                    mo, list_name = param.split(":")[0:2]
                    condition_key = param.split("|")[-1].split("=")[0]
                    params_to_check.append("%s:%s:%s" % (mo, list_name, condition_key))
            else:
                params_to_check.append(param)

        # remove instance id and the duplicate, and sort list
        params_to_check2 = []
        for param in params_to_check:
            mo = param.split(":")[0]
            new_param = param.replace(mo, "".join(re.split("-[0-9]+", mo)))
            if new_param not in params_to_check2:
                params_to_check2.append(new_param)
        params_to_check2.sort()
        builtin_obj.log("params to be checked: %s" % params_to_check2)

        # all parameters should be in NIDD
        params_pass_nidd, params_fail_nidd = self._search_in_NIDD_aic(params_to_check2, productVariant, du_identity)
        if len(params_fail_nidd):
            raise Exception("please make sure all parameters format right and can be found in WebGUI or NIDD")

        # MO need in SCF template, So all mandatory parameters will be in it.
        # for MO:list:key, MO:list need be defined in SCF template or supplement(if conflict in scf template)
        # MO:key, MO:list:key not in it, they are optional for MO or list creation
        mos_pass, mos_fail = self._search_mo_in_template_aic(params_to_check2, productVariant)
        lists_pass, lists_fail = self._search_mo_list_in_template_aic(params_to_check2, productVariant, du_identity)
        if len(mos_fail) or len(lists_fail):
            raise Exception(
                "missing parameters in scf_template_%s, "
                "contact I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com" % productVariant)

    def _search_in_NIDD_aic(self, parameters, productVariant, du_identity="du"):
        """
            parameters like:
            MRBTS/MNL/TCEADM
            MRBTS/MNL/TCEADM/TCE:tceIdentifier
            NRBTS/NRCTRLTS/NRMTRACECU:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced
        """
        builtin_obj.log("step: start to _search_in_NIDD_aic for %s" % productVariant)
        params_pass = []
        params_fail = []
        # check parameters in NIDD
        # nidd_pool is a list include multi dic of each parameter, structure is different with classical
        structure_parameters_name = "structure_parameters"
        complex_parameter_def_name = "complex_parameter_def"
        if productVariant == "cu":
            self._setup_scf_control_aic_cu()
            with open(self.nidd_file_cu, "r") as load_f:
                nidd_pool = ast.literal_eval(load_f.read())
            load_f.close()
        if productVariant == "du":
            self._setup_scf_control_aic_du(du_identity)
            with open(self.nidd_file_du, "r") as load_f:
                nidd_pool = ast.literal_eval(load_f.read())
            load_f.close()
        mo_class_name_list = []
        for mo_dic in nidd_pool:
            mo_class_name_list.append(mo_dic["class_name"])
        for param in parameters:
            # mo
            if param.count(":") == 0:
                if param.count("."):
                    builtin_obj.log("wrong format %s, should not contain '.'" % param, level="WARN")
                    params_fail.append(param)
                else:
                    for each in param.split("/"):
                        if each not in mo_class_name_list:
                            builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                            params_fail.append(param)
                if param not in params_fail:
                    params_pass.append(param)
            # mo:key
            elif param.count(":") == 1:
                mo_class = param.split(":")[0].split("/")[-1]
                key = param.split(":")[1]
                if mo_class in mo_class_name_list and key in list(
                        [mo_dic["parameters"].keys() for mo_dic in nidd_pool if mo_dic["class_name"] == mo_class][0]):
                    params_pass.append(param)
                else:
                    builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                    params_fail.append(param)
            # mo:list:key
            elif param.count(":") == 2:
                mo_class = param.split(":")[0].split("/")[-1]
                list_name = param.split(":")[1]
                key = param.split(":")[2]
                try:
                    if mo_class in mo_class_name_list and \
                            list_name in list([mo_dic["parameters"].keys() for mo_dic
                                               in nidd_pool if mo_dic["class_name"] == mo_class][0]) and \
                            key in list([mo_dic["parameters"][list_name][complex_parameter_def_name]
                                         [structure_parameters_name].keys() for mo_dic in
                                         nidd_pool if mo_dic["class_name"] == mo_class][0]):
                        params_pass.append(param)
                    else:
                        builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                        params_fail.append(param)
                except Exception:  # consider list in mo:list:key is not list
                    detail = traceback.format_exc()
                    builtin_obj.log(detail)
                    builtin_obj.log("no %s in NIDD, please double confirm" % param, level="WARN")
                    params_fail.append(param)
            else:
                builtin_obj.log("%s: wrong format" % param, level="WARN")
        return params_pass, params_fail

    def _search_mo_in_template_aic(self, parameters, productVariant):
        """
            parameters like:
            MRBTS/MNL/TCEADM
            MRBTS/MNL/TCEADM/TCE:tceIdentifier
            NRBTS/NRCTRLTS/NRMTRACECU:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced
        """
        builtin_obj.log("step: start to _search_mo_in_template_aic for %s" % productVariant)
        mos_pass = []
        mos_fail = []
        mo_class_list = []
        # get mo_class list, remove duplicate and remove LTEENB because it's not in scf template
        for param in parameters:
            mo_class = param.split(":")[0].split("/")[-1]
            mo_class_list.append(mo_class)
        mo_class_list = list(set(mo_class_list))
        if "LTEENB" in mo_class_list:
            mo_class_list.remove("LTEENB")

        # check mo should exist in scf template
        if productVariant == "cu":
            commonxml1 = CommonXML(self.scf_template_full_cu)
        elif productVariant == "du":
            commonxml1 = CommonXML(self.scf_template_full_du)
        else:
            raise Exception("%s is not support, pls double check " % productVariant)

        for mo_class in mo_class_list:
            xpath_mo = "//*[matches(@class, '.*:%s$')]" % mo_class
            for param in parameters:
                if param.split(":")[0].split("/")[-1] == mo_class:
                    mo = param.split(":")[0]
                    break
            if len(commonxml1.get_elements(xpath_mo)):
                mos_pass.append(mo)
            else:
                if productVariant == "cu":
                    builtin_obj.log("no %s in %s after migrated" % (mo, self.scf_template_svn_cu), level="WARN")
                if productVariant == "du":
                    builtin_obj.log("no %s in %s after migrated" % (mo, self.scf_template_svn_du), level="WARN")
                mos_fail.append(mo)
        return mos_pass, mos_fail

    def _search_mo_list_in_template_aic(self, parameters, productVariant, du_identity="du"):
        """
            parameters like:
            MRBTS/MNL/TCEADM
            MRBTS/MNL/TCEADM/TCE:tceIdentifier
            NRBTS/NRCTRLTS/NRMTRACECU:nrPeriodicUeMeas:cellMaxPeriodicUEsTraced
        """
        builtin_obj.log("step: start to _search_mo_list_in_template_aic for %s" % productVariant)
        lists_pass = []
        lists_fail = []
        if productVariant == "cu":
            self._setup_scf_control_aic_cu()
            commonxml1 = CommonXML(self.scf_template_full_cu)
            commonxml2 = CommonXML(self.scf_supplement_cu)
        elif productVariant == "du":
            self._setup_scf_control_aic_du(du_identity)
            commonxml1 = CommonXML(self.scf_template_full_du)
            commonxml2 = CommonXML(self.scf_supplement_du)
        else:
            raise Exception("%s is not support, pls double check " % productVariant)
        # check mo:list should exist in scf template
        for param in parameters:
            # for mo:list:key, search mo:list
            if param.count(":") == 2:
                mo, list_name, key = param.split(":")
                # list xpath in scf template
                mo_in_template = mo.replace("/", r"-\d+/") + r"-\d+"
                list_xpath_in_template = self._mo_xpath(mo_in_template) + "/*[@name='%s']" % list_name
                # list xpath in scf supplement
                list_xpath_in_supplement = self._mo_xpath(mo) + "/*[@name='%s']" % list_name
                # search in scf template and scf supplement
                if len(commonxml1.get_elements(list_xpath_in_template)) or len(
                        commonxml2.get_elements(list_xpath_in_supplement)):
                    lists_pass.append("%s:%s" % (mo, list_name))
                else:
                    lists_fail.append("%s:%s" % (mo, list_name))
        lists_pass = list(set(lists_pass))
        lists_fail = list(set(lists_fail))
        for each in lists_fail:
            if productVariant == "cu":
                builtin_obj.log("no %s in %s after migrated" % (each, self.scf_template_svn_cu), level="WARN")
            if productVariant == "du":
                builtin_obj.log("no %s in %s after migrated" % (each, self.scf_template_svn_du), level="WARN")
        return lists_pass, lists_fail

    def _add_or_update_parameters_element_aic(self, mo_element_or_scf, parameters, productVariant="cu",
                                              du_identity="du", active_scf=""):
        """add/update parameters value in managedObject element
        | Input Parameters | Man. | Description |
        | mo_element_or_scf  |  Yes  | managedObject or SCF where parameters will be add/update
        | parameters  |  Yes  | parameters to be added/updated, which belong to one mo
        | productVariant  |  No  | cu, du(default: cu)
        | du_identity | No | du, du2, default is du
        | active_scf  | No | it is used for delta commissioning |
        """
        builtin_obj.log("step: start to _add_or_update_parameters_element_aic for %s" % productVariant)
        class2, class3, class4 = self._classify_parameters_aic(parameters, productVariant)
        # try structure for class2: mo:key
        for param in class2:
            mo_element_or_scf = self._try_mo_key_parameter(mo_element_or_scf, param)

        # add or modify for class3: mo:list=value1,value2, mo:list=${EMPTY}
        for param in class3:
            mo_element_or_scf = self._handle_mo_list_value_parameter(mo_element_or_scf, param)

        # try structure for class4: mo:list:key=value(|cond_key=cond_value)
        for param in class4:
            builtin_obj.log("xk: handling mo:list:key parameter: %s" % param)
            mo = param.split(":")[0]
            list_name = param.split(":")[1]
            mo_element_or_scf = self._try_mo_list_with_item_aic(mo_element_or_scf, "%s:%s" % (mo, list_name),
                                                                productVariant, du_identity, active_scf)
            key_name = param.split("=")[0].split(":")[-1]
            mo_element_or_scf = self._try_mo_list_key_parameter(mo_element_or_scf,
                                                                "%s:%s:%s" % (mo, list_name, key_name))
            if param.count("|") == 1:
                condition_key_name = param.split("|")[-1].split("=")[0]
                mo_element_or_scf = self._try_mo_list_key_parameter(mo_element_or_scf,
                                                                    "%s:%s:%s" % (mo, list_name, condition_key_name))

        # handle mutiple items
        mo_element_or_scf = self._handle_items(mo_element_or_scf, parameters)

        # modify parameters
        parameters_xpath = comm_obj.match_to_xpath(class2 + class4)
        mo_element_or_scf_content = xml_obj.modify_xml(mo_element_or_scf, "", parameters_xpath)
        return mo_element_or_scf_content

    def _classify_parameters_aic(self, parameters, productVariant):
        """
        classify parameters to
        class1: mo
        class2: mo:key=value
        class3: mo:list=value1,value2, mo:list=${EMPTY}
        class4: mo:list:key=value(|cond_key=cond_value)
        """
        builtin_obj.log("step: start to _classify_parameters_aic for %s" % productVariant)
        class1 = []
        class2 = []
        class3 = []
        class4 = []
        if productVariant == "cu":
            parameter_container_type_name = "parameter_container_type"
            with open(self.nidd_file_cu, "r") as load_f:
                nidd_pool = ast.literal_eval(load_f.read())
            load_f.close()
        if productVariant == "du":
            parameter_container_type_name = "parameter_container_type"
            with open(self.nidd_file_du, "r") as load_f:
                nidd_pool = ast.literal_eval(load_f.read())
            load_f.close()
        for param in parameters:
            if param.split("=")[0].count(":") == 0:
                class1.append(param)
            elif param.split("=")[0].count(":") == 1:
                mo, key_or_list = param.split("=")[0].split(":")
                mo_class = mo.split("/")[-1].split("-")[0]
                # mo:key definition is different with classical in nidd
                if [mo_dic["parameters"][key_or_list][parameter_container_type_name] for mo_dic in nidd_pool if
                        mo_dic["class_name"] == mo_class][0] == "simple":
                    class2.append(param)
                else:
                    class3.append(param)
            elif param.split("=")[0].count(":") == 2:
                class4.append(param)
            else:
                raise Exception("wrong format: %s" % param)
        return class2, class3, class4

    def _try_mo_list_with_item_aic(self, mo_element_or_scf, param, productVariant, du_identity="du", active_scf=''):
        # para format is mo:list, the list has item
        builtin_obj.log("xk: trying mo:list parameter: %s" % param)
        if param.count(":") == 1:
            mo, list_name = param.split(":")
            mo_xpath = self._mo_xpath(mo)
            xpath_in_normal_scf = "*|%s/*[@name='%s']" % (mo_xpath, list_name)
            xpath_without_mo = "*|/managedObject/*[@name='%s']" % list_name
            xpath_in_scf_supplement = "*|%s/*[@name='%s']" % (
                self._mo_xpath("".join(re.split("-[0-9]+", mo))), list_name)
            xpath_parent = mo_xpath
            if productVariant == "cu":
                self._setup_scf_control_aic_cu()
                scf_template = self.scf_template_full_cu
                scf_supplement = self.scf_supplement_cu
            elif productVariant == "du":
                self._setup_scf_control_aic_du(du_identity)
                scf_template = self.scf_template_full_du
                scf_supplement = self.scf_supplement_du
        else:
            raise Exception("this function doesn't support %s" % param)

        # flag true means existing in mo_element_or_scf
        try:
            param_element = xml_obj.read_xml(mo_element_or_scf, xpath_in_normal_scf)
            flag = True
        except AssertionError:
            flag = False
            try:
                param_element = xml_obj.read_xml(active_scf, xpath_in_normal_scf)
            except Exception as err_info:
                if len(active_scf):
                    builtin_obj.log(err_info)
                    builtin_obj.log(
                        "no %s in active SCFC_%s,will try SCFC_template_%s" % (param, productVariant, productVariant))

                mo_template_name, mo_template_element = self._get_mo_template(mo, scf_template)
                try:
                    # get list from mo template
                    param_element = xml_obj.read_xml(mo_template_element, xpath_without_mo)
                    builtin_obj.log("get %s under %s in SCFC template(%s) " % (
                        param.partition(":")[-1], mo_template_name, scf_template))
                except AssertionError as err_info:
                    builtin_obj.log(err_info)
                    builtin_obj.log("no %s under %s in SCFC template(%s), will try SCFC_supplement_%s" % (
                        param.partition(":")[-1], mo_template_name, scf_template, productVariant))
                    try:
                        # get key or list from scfc supplement.xml
                        param_element = xml_obj.read_xml(scf_supplement, xpath_in_scf_supplement)
                        builtin_obj.log("get %s under %s in SCFC supplement(%s) " % (
                            param.partition(":")[-1], "".join(re.split("-[0-9]+", mo)), scf_supplement))
                    except AssertionError as err_info:
                        builtin_obj.log(err_info)
                        raise Exception("no %s under %s in SCFC supplement(%s) " % (
                            param.partition(":")[-1], "".join(re.split("-[0-9]+", mo)), scf_supplement))

        # only get the first item to avoid some parameter in first item and some in other items.
        # here make first item contain as much parameter as possible
        commonxml = CommonXML(param_element)
        get_all_items = commonxml.get_elements("//item")
        if len(get_all_items):
            item0 = xml_declare + commonxml.element_to_string(get_all_items[0])
            param_element = self._get_element_without_children(param_element, "/*")
            param_element = xml_obj.add_xml_element(param_element, "", item0 + "|/*")

        # add the list into mo_element_or_scf
        if flag is True:
            mo_element_or_scf = xml_obj.remove_xml_element(mo_element_or_scf, None,
                                                           "%s/*[@name='%s']" % (mo_xpath, list_name))
        mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "", param_element + "|" + xpath_parent)
        return mo_element_or_scf

    def _create_mo_aic(self, mo_params, productVariant, du_identity="du", commission_type="delta"):
        """create new managedObject element according to template.
           du_identity is support in [du, du2]
        """
        mo = mo_params[0].split(":")[0]
        # use reduced scf template because sometimes case don't want too many MO parameters
        if productVariant == "cu":
            mo_template_name, mo_template_element = self._get_mo_template(mo, self.scf_template_for_mo_cu)
            builtin_obj.log("get %s as %s template in SCFC template(%s)" %
                            (mo_template_name, mo, self.scf_template_for_mo_cu))
        elif productVariant == "du":
            mo_template_name, mo_template_element = self._get_mo_template(mo, self.scf_template_for_mo_du)
            builtin_obj.log("get %s as %s template in SCFC template(%s)" %
                            (mo_template_name, mo, self.scf_template_for_mo_du))
        else:
            raise Exception("%s or %s is not support, pls double check" % (productVariant, du_identity))
        # replace mo template distName with mo and modify parameters of mo
        mo_create = xml_obj.modify_xml(mo_template_element, "",
                                       "attrib=distName|replace('%s', '%s')|//managedObject" % (
                                           mo_template_name, mo))
        if commission_type == "delta":
            mo_create = xml_obj.modify_xml(mo_create, "", "attrib=operation|create|//managedObject")
            # mo_create = self._remove_parameters_set_by_system(mo_create)
        # for create mo, all structures come from template
        mo_create = self._add_or_update_parameters_element_aic(mo_create, mo_params, productVariant, du_identity)
        # remove mo:key=${EMPTY}
        mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/p[not(text())]")
        # remove mo:list=${EMPTY}
        mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/list[not(node())]")
        # remove mo:list:key=${EMPTY}
        mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/list//p[not(text())]")
        return mo_create

    # $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
    # def _create_mo_aic_only_include_give_params(self, mo_params, productVariant,
    #                                             du_identity="du", commission_type="delta"):
    #     mo = mo_params[0].split(":")[0]
    #     # use reduced scf template because sometimes case don't want too many MO parameters
    #     # mo_template_name是要创建的MO在template模板里的写法,如:NRCELL-1
    #     if productVariant == "cu":
    #         mo_template_name, mo_template_element = self._get_mo_template(mo, self.scf_template_for_mo_cu)
    #         builtin_obj.log("get %s as %s template in SCFC template(%s)" %
    #                         (mo_template_name, mo, self.scf_template_for_mo_cu))
    #     elif productVariant == "du":
    #         mo_template_name, mo_template_element = self._get_mo_template(mo, self.scf_template_for_mo_du)
    #         builtin_obj.log("get %s as %s template in SCFC template(%s)" %
    #                         (mo_template_name, mo, self.scf_template_for_mo_du))
    #     else:
    #         raise Exception("%s or %s is not support, pls double check" % (productVariant, du_identity))
    #     # replace mo template distName with mo and modify parameters of mo
    #     mo_create = xml_obj.modify_xml(mo_template_element, "",
    #                                    "attrib=distName|replace('%s', '%s')|//managedObject" % (
    #                                        mo_template_name, mo))
    #     if commission_type == "delta":
    #         mo_create = xml_obj.modify_xml(mo_create, "", "attrib=operation|create|//managedObject")
    #         # mo_create = self._remove_parameters_set_by_system(mo_create)
    #     # for create mo, all structures come from template
    #     mo_create = self._add_or_update_parameters_element_aic(mo_create, mo_params, productVariant, du_identity)
    #     # remove mo:key=${EMPTY}
    #     mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/p[not(text())]")
    #     # remove mo:list=${EMPTY}
    #     mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/list[not(node())]")
    #     # remove mo:list:key=${EMPTY}
    #     mo_create = xml_obj.remove_xml_element(mo_create, None, "//managedObject/list//p[not(text())]")
    #     return mo_create
    # $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

    def _set_pm_counters_interval_aic(self, scf, productVariant, du_identity="du"):
        exclude_intervals = ["ulUeThptMethod"]  # can't set to xxmin
        if productVariant == "cu":
            self._setup_scf_control_aic_cu()
        if productVariant == "du":
            self._setup_scf_control_aic_du(du_identity)
        # this keyword not _change_swconfig due to need re-deploy CU/DU
        # counter interval=interval in scf/value of 0x340000,Aic not support this flag currently
        interval = builtin_obj.get_variable_value("${PM_COUNTER_INTERVAL}")
        if interval == "5min":
            scf_target_interval = "5min"
        else:  # 15min
            scf_target_interval = "15min"
        params_modified = []
        comm_xml_obj = CommonXML(scf)
        for element in comm_xml_obj.get_elements("//managedObject[matches(@class, '.*:NRPMRNL$')]/*"):
            # element like: <p name="miNrBeamforming">15min</p>
            name = comm_xml_obj.get_element_attribute(element, "name")
            text = comm_xml_obj.get_element_text(element)
            if name in exclude_intervals:
                continue
            if text != scf_target_interval:
                param_modified = "text|%s|//managedObject[matches(@class, '.*:NRPMRNL$')]/*[@name='%s']" % \
                                 (scf_target_interval, name)
                builtin_obj.log("xk:modify %s" % param_modified)
                params_modified.append(param_modified)
        if len(params_modified):
            xml_obj.modify_xml(scf, scf, params_modified)
            # fix relation errors related to pm counter interval
            params_modified_2 = []
            if productVariant == "cu":
                result = self._validate_scf_and_get_validation_result_cu(scf,
                                                                         plan_name="auto_reltaion_error_fix")
            elif productVariant == "du":
                result = self._validate_scf_and_get_validation_result_du(scf,
                                                                         plan_name="auto_reltaion_error_fix",
                                                                         vdu_conn=self.alias_du)

            # errors = result['totalError'] + result['totalWarning']
            builtin_obj.log("xk_debug123: %s" % result)
            errors_definition = []
            errors_relation = []
            if 'definitionErrors' in result:
                errors_definition = errors_definition + result['definitionErrors']
            if 'relationErrors' in result:
                errors_relation = errors_relation + result['relationErrors']
            errors = errors_definition + errors_relation
            for entry in errors:
                builtin_obj.log("xk: %s" % entry['errorDescription'])
                # it is required that NRPMRNL-1.miNrInterGnbMobilityNsaPmqap (value: 5min) equal to disabled
                match1 = re.search(r"it is required that NRPMRNL-1.(\S+) \(value: \d+min\) equal to disabled",
                                   entry['errorDescription'], re.I)
                # 'The parameter NRPMRNL-1.miNrInterGnbMobilityCellCuNsa (value: 5min) shall be equal to disabled
                # in this release.'
                match2 = re.search(
                    r"The\s+parameter\s+NRPMRNL-1.(\S+) \(value: \d+min\)\s+shall\s+be\s+equal\s+to\s+disabled\s+"
                    r"in\s+this\s+release", entry['errorDescription'], re.I)
                # miNrRipSamples: '5min' is not from the defined list
                # miNrStrMeasure: '5min' is not from the defined list
                match3 = re.search(r"(\S+): \'5min\' is not from the defined list", entry['errorDescription'], re.I)

                if match1 is not None or match2 is not None:
                    if match1 is not None:
                        param = match1.group(1)
                    if match2 is not None:
                        param = match2.group(1)
                    param_modified = "text|disabled|" \
                                     "//managedObject[matches(@class, '.*:NRPMRNL$')]/*[@name='%s']" % param
                    builtin_obj.log("xk:modify %s" % param_modified)
                    params_modified_2.append(param_modified)
                    continue
                if match3 is not None:
                    param = match3.group(1)
                    param_modified = "text|5 minutes|" \
                                     "//managedObject[matches(@class, '.*:NRPMRNL$')]/*[@name='%s']" % param
                    builtin_obj.log("xk:modify %s" % param_modified)
                    params_modified_2.append(param_modified)
                    continue
            xml_obj.modify_xml(scf, scf, params_modified_2)

    def _modify_scf_and_perform_full_commission_cu(self, scf_base_cu, parameters):
        self.init_relation_errors_num_cu = 0
        self._setup_scf_control_aic_cu()
        # update scf according to parameters.
        self._modify_scf_cu(scf_base_cu, parameters, self.scf_for_startup_cu)
        # fix_relation_error need split to cu du separate.***
        self._fix_relation_error_aic(parameters, productVariant="cu")
        # set pm_interval_timer
        self._set_pm_counters_interval_aic(self.scf_for_startup_cu, productVariant="cu")

        # update cmData attributes in scf startup, plan id could be same in cu du
        plan_id = "3221225472"
        # mrbts_dn = xml_obj.read_xml(self.scf_for_startup_cu,
        #                             "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        # bts_id = mrbts_dn.split("-")[-1]   #just fot classical admin_obj full commission kw using
        # update cmData
        xml_obj.modify_xml(self.scf_for_startup_cu, self.scf_for_startup_cu, "attrib=type|plan|//cmData")
        xml_obj.modify_xml(self.scf_for_startup_cu, self.scf_for_startup_cu, "attrib=id|%s|//cmData" % plan_id)
        xml_obj.modify_xml(self.scf_for_startup_cu, self.scf_for_startup_cu, "attrib=scope|all|//cmData")

        # call cu to perform full commissioning
        try:
            current_time = builtin_obj.get_time()
            comm_obj.log_to_console_with_time_prefix("step: perform full commissioning in %s_cu with %s"
                                                     % (self.alias, self.scf_for_startup_cu))
            activation_status = self._perform_full_commission_cu(self.scf_for_startup_cu, "scf_for_startup_cu",
                                                                 connection=self.alias_cu)
            comm_obj.log_to_console_with_time_prefix("step: perform full commissioning in %s_cu with status:%s"
                                                     % (self.alias, activation_status))
            if activation_status == "failure":
                raise Exception("Cu scf activate failure")
        except Exception as e:
            raise Exception(str(e))
        return self.scf_for_startup_cu

    def _modify_fhuc_vlan_du(self, scf):
        """Whenever MNL-1.productVariantPlanned (value: 5gvDU) is equal to 5gvDU,
        it is required that one instance of MNL/MNLENT/MPLANEFHNW must be configured."""
        builtin_obj.log("step: start to _modify_fhuc_vlan_du")
        param_modified = "text|%s|//managedObject[matches(@class, '.*:LCELNR$')]/*[@name='vlanId']" % self.fhuc_vlan_id
        xml_obj.modify_xml(scf, scf, param_modified)

    def _modify_scf_and_perform_full_commission_du(self, scf_base_du, parameters, du_identity="du"):
        self.init_relation_errors_num_du = 0
        self._release_admin_conn_du()
        self._setup_scf_control_aic_du(du_identity)
        # update scf according to parameters.
        self._modify_scf_du(scf_base_du, parameters, self.scf_for_startup_du, du_identity)
        # update fhuc vlan id for du LCELNR
        self._modify_fhuc_vlan_du(self.scf_for_startup_du)
        # fix_relation_error need split to cu du separate.***
        self._fix_relation_error_aic(parameters, productVariant="du", du_identity=du_identity)
        # set pm_interval_timer
        self._set_pm_counters_interval_aic(self.scf_for_startup_du, productVariant="du", du_identity=du_identity)

        # update cmData attributes in scf startup, plan id could be same in cu du
        plan_id = "3221225472"
        mrbts_dn = xml_obj.read_xml(self.scf_for_startup_du,
                                    "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        bts_id = mrbts_dn.split("-")[-1]
        # update cmData
        xml_obj.modify_xml(self.scf_for_startup_du, self.scf_for_startup_du, "attrib=type|plan|//cmData")
        xml_obj.modify_xml(self.scf_for_startup_du, self.scf_for_startup_du, "attrib=id|%s|//cmData" % plan_id)
        xml_obj.modify_xml(self.scf_for_startup_du, self.scf_for_startup_du, "attrib=scope|all|//cmData")

        # call du to perform full commissioning
        try:
            current_time = builtin_obj.get_time()
            comm_obj.log_to_console_with_time_prefix("step: perform full commissioning in %s_%s with %s"
                                                     % (self.alias, du_identity, self.scf_for_startup_du))
            activation_status = self._perform_full_commission_du(self.scf_for_startup_du,
                                                                 "scf_for_startup_%s" % du_identity,
                                                                 connection=self.alias_du, du_identity=du_identity)
            comm_obj.log_to_console_with_time_prefix("step: perform full commissioning in %s_%s with status:%s"
                                                     % (self.alias, du_identity, activation_status))
            if activation_status == "failure":
                raise Exception("Du scf activate failure")
        except Exception as e:
            raise Exception(str(e))
        return self.scf_for_startup_du

    def _fix_relation_error_aic(self, user_params, productVariant, du_identity="du"):
        """
            | Input Parameters | Man. | Description |
            | user_params | Yes |
            | productVariant  |  Yes  | cu, du
            | du_identity | No |du, du2, default is du
        """
        # 1. fail new cases if there are any validation errors
        new_case_path = ["rework", "new_feature"]
        suite_path = builtin_obj.get_variable_value("${SUITE_SOURCE}")
        if productVariant == "cu":
            scf_for_startup = self.scf_for_startup_cu
            init_relation_errors_num = self.init_relation_errors_num_cu
        elif productVariant == "du":
            scf_for_startup = self.scf_for_startup_du
            init_relation_errors_num = self.init_relation_errors_num_du
        else:
            raise Exception("%s is not support, pls double check " % productVariant)
        for path in new_case_path:
            if suite_path.count(path):
                if productVariant == "cu":
                    result = self._validate_scf_and_get_validation_result_cu(scf_for_startup,
                                                                             plan_name="auto_reltaion_error_fix")
                elif productVariant == "du":
                    result = self._validate_scf_and_get_validation_result_du(scf_for_startup,
                                                                             plan_name="auto_reltaion_error_fix",
                                                                             vdu_conn=self.alias_du)
                errors_definition = []
                errors_relation = []
                if 'definitionErrors' in result:
                    errors_definition = errors_definition + result['definitionErrors']
                if 'relationErrors' in result:
                    errors_relation = errors_relation + result['relationErrors']
                errors = errors_definition + errors_relation
                for entry in errors:
                    builtin_obj.log("xk: %s" % entry['errorDescription'])
                if len(errors) > init_relation_errors_num:
                    raise Exception("new cases are not allowed to involve more validation errors,"
                                    "initial scf has %s errors, but scf_for_startup_%s.xml has %s errors, pls fix them"
                                    % (init_relation_errors_num, productVariant, len(errors)))
                break
        # 2. auto fix works if AUTO_FIX_VALIDATION_ERRORS=True and suite is in auto_fix_path
        auto_fix_flag = builtin_obj.get_variable_value("${AUTO_FIX_VALIDATION_ERRORS}")
        #         auto_fix_path_flag = False
        #         auto_fix_path = ["/CIT/", "/CRT/Regression_iPHY_AS/", "/Regression_iPHY_AS_FDD_9CELL/"]
        #
        #         for path in auto_fix_path:
        #             if suite_path.count(path):
        #                 auto_fix_path_flag = True
        #                 break
        #         if auto_fix_flag is not True or auto_fix_path_flag is not True:
        #             return
        if bool(auto_fix_flag) is not True:
            return

        # 3. if suite in auto_fix_path_fail, it will fail if auto-fix function can't fix all errors
        auto_fix_path_fail = []
        auto_fix_fail = False
        for path in auto_fix_path_fail:
            if suite_path.count(path):
                auto_fix_fail = True
                break

        # start to auto-fix validaiton errors
        builtin_obj.log("step: trying to fix validation errors")
        self.params_fixed_all = []
        max_retry_times = 1
        fixed = False
        if productVariant == "cu":
            os_obj.copy_file(scf_for_startup, "%s/scf_for_startup_%s_fixing_errors_0.xml"
                             % ((self.full_commission_log_dir + "/scfc_logs"), productVariant))
        if productVariant == "du":
            os_obj.copy_file(scf_for_startup, "%s/scf_for_startup_%s_fixing_errors_0.xml"
                             % ((self.full_commission_log_dir + "/scfc_logs"), du_identity))
        for time in range(0, max_retry_times):
            if productVariant == "cu":
                old_file = "%s/scf_for_startup_%s_fixing_errors_%s.xml" % (self.full_commission_log_dir + "/scfc_logs",
                                                                           productVariant, time)
                new_file = "%s/scf_for_startup_%s_fixing_errors_%s.xml" % (self.full_commission_log_dir + "/scfc_logs",
                                                                           productVariant, time + 1)
            if productVariant == "du":
                old_file = "%s/scf_for_startup_%s_fixing_errors_%s.xml" % (self.full_commission_log_dir + "/scfc_logs",
                                                                           du_identity, time)
                new_file = "%s/scf_for_startup_%s_fixing_errors_%s.xml" % (self.full_commission_log_dir + "/scfc_logs",
                                                                           du_identity, time + 1)
            try:
                if productVariant == "cu":
                    result = self._validate_scf_and_get_validation_result_cu(old_file,
                                                                             plan_name="auto_reltaion_error_fix")
                if productVariant == "du":
                    result = self._validate_scf_and_get_validation_result_du(old_file,
                                                                             plan_name="auto_reltaion_error_fix",
                                                                             vdu_conn=self.alias_du)
            except Exception:
                detail = traceback.format_exc()
                comm_obj.log_to_console_with_time_prefix("fail to fix relation error, contact "
                                                         "I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com: %s"
                                                         % detail, "WARN")
                break
            if len(result['totalError'] + result['totalWarning']) > 0:
                errors_definition = []
                errors_relation = []
                if 'definitionErrors' in result:
                    errors_definition = errors_definition + result['body']['definitionErrors']['errorDescription']
                if 'relationErrors' in result:
                    errors_relation = errors_relation + result['body']['relationErrors']['errorDescription']
                errors = errors_definition + errors_relation
                if time == 0:
                    if productVariant == "cu":
                        comm_obj.log_to_console_with_time_prefix(
                            "there are %s validation errors in scf_for_startup_%s.xml, "
                            "try to auto-fix them" % (len(errors), productVariant), "WARN")
                    else:
                        comm_obj.log_to_console_with_time_prefix(
                            "there are %s validation errors in scf_for_startup_%s.xml, "
                            "try to auto-fix them" % (len(errors), du_identity), "WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix("there are still %s validation errors after auto-fixing,"
                                                             " try again" % len(errors), "WARN")
                os_obj.copy_file(old_file, new_file)
                try:
                    fix_number = self._try_to_fix_relation_error_aic(new_file, errors, user_params,
                                                                     productVariant, du_identity)
                    if fix_number == 0:
                        comm_obj.log_to_console_with_time_prefix("no validation errors could be auto-fixed any longer,"
                                                                 " stop auto-fixing", "WARN")
                        fixed = True
                        break
                except Exception:
                    detail = traceback.format_exc()
                    comm_obj.log_to_console_with_time_prefix("fail to fix relation error, contact "
                                                             "I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com: %s"
                                                             % detail, "WARN")
                    break
            else:
                fixed = True
                if time == 0:
                    fixed = "No Need"
                    builtin_obj.log("xk: no PDL relation errors")
                else:
                    comm_obj.log_to_console_with_time_prefix("validation errors are auto-fixed", level="WARN")
                    os_obj.copy_file(old_file, scf_for_startup)
                break
        if fixed is False:
            if auto_fix_fail:
                raise Exception("there are still some validation errors, pls fix them, last scf is %s" % new_file)
            else:
                if productVariant == "cu":
                    comm_obj.log_to_console_with_time_prefix("revert scf_for_startup_%s.xml" % productVariant,
                                                             level="WARN")
                else:
                    comm_obj.log_to_console_with_time_prefix("revert scf_for_startup_%s.xml" % du_identity,
                                                             level="WARN")
        elif fixed is True:
            os_obj.copy_file(new_file, scf_for_startup)
        else:
            if productVariant == "cu":
                builtin_obj.log("Using scf_for_startup_%s.xml for startup" % productVariant)
            else:
                builtin_obj.log("Using scf_for_startup_%s.xml for startup" % du_identity)

    def _try_to_fix_relation_error_aic(self, scf, errors, user_params, productVariant, du_identity):
        """need implement later..."""
        builtin_obj.log("step: _try_to_fix_relation_error_aic")

        parameter_container_type_name = "parameter_container_type"
        parameter_value_type_name = "parameter_value_type"
        simple_parameter_def_name = "simple_parameter_def"
        _parameter_def_name = "_parameter_def"
        descrip_of_relationship_name = "description_of_relationship"
        if productVariant == "cu":
            with open(self.nidd_file_cu, "r") as load_f:
                nidd_pool = ast.literal_eval(load_f.read())
            load_f.close()
        if productVariant == "du":
            with open(self.nidd_file_du, "r") as load_f:
                nidd_pool = ast.literal_eval(load_f.read())
            load_f.close()
        init_param_need_fix_all_dict = {}
        for entry in errors:
            builtin_obj.log("xk_error_info: %s" % entry)
            # [{'error_index': '1', 'distname': 'MRBTS-1/NRBTS-1', 'nidd_id': '199432',
            #   'errorDescription': 'NRBTS.actOAMResiliency shall be set to false in this release.',
            #   'mo_uuid': '3784b315-e639-46b5-918f-974b14ac1adb'},
            #  {'error_index': '2', 'distname': 'MRBTS-1/NRBTS-1', 'nidd_id': '199432',
            #   'errorDescription': 'NRBTS-1.actVemResiliency (value: true) shall be set to false in this release.',
            #   'mo_uuid': '3784b315-e639-46b5-918f-974b14ac1adb'}]
            match = re.search(r"(NRBTS(-\d+|).(\S+))\s+shall\s+be\s+set\s+to\s+(\S+)\s+in\s+this\s+release",
                              entry["errorDescription"], re.I)
            if match is not None:
                param_distname = None
                param = match.group(3)
                value = match.group(4)
                if "distname" in entry:
                    if len(entry["distname"].strip()) != 0:
                        param_distname = entry["distname"]
                if param_distname is not None:
                    if len(param.split(".")) == 1:
                        nidd_rel_info_find = False
                        if entry["nidd_id"]:
                            for nidd_param in nidd_pool:
                                if nidd_param["nidd_id"] == entry["nidd_id"]:
                                    if nidd_param["parameters"][param][parameter_container_type_name] == "simple":
                                        p_v_t = nidd_param["parameters"][param][simple_parameter_def_name][
                                            parameter_value_type_name]
                                        if nidd_param["parameters"][param][simple_parameter_def_name][
                                                p_v_t + _parameter_def_name][descrip_of_relationship_name] is not None:
                                            for nidd_rel_info in \
                                                    nidd_param["parameters"][param][simple_parameter_def_name][
                                                        p_v_t + _parameter_def_name][descrip_of_relationship_name]:
                                                if re.search(
                                                        r"This\s+parameter\s+shall\s+be\s+equal\s+to\s+FALSE\s+"
                                                        r"in\s+this\s+release", nidd_rel_info, re.I):
                                                    builtin_obj.log("nidd defined this relationship, will be auto fix")
                                                    nidd_rel_info_find = True
                                                    break
                                    elif nidd_param["parameters"][param][parameter_container_type_name] == "complex":
                                        # check later..
                                        pass
                        else:
                            builtin_obj.log("nidd_id not found in Relation errors info, don't auto fix")
                        if nidd_rel_info_find is True:
                            single_param_need_fix = param_distname + ':' + param + '=' + value
                            if single_param_need_fix not in init_param_need_fix_all_dict:
                                init_param_need_fix_all_dict[single_param_need_fix] = {}
                                init_param_need_fix_all_dict[single_param_need_fix]["param"] = param
                                init_param_need_fix_all_dict[single_param_need_fix]["value"] = value
                    else:
                        builtin_obj.log("paramter %s structure is too long, contact "
                                        "I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com "
                                        "to further implement" % match.group(1), level="WARN")

                else:
                    builtin_obj.log("distname is empty in Relation errors info, don't auto fix")

            match = re.search(
                r"(NRBTS(-\d+|).(\S+))\s+\(value:\s+(\S+)\)\s+shall\s+be\s+set\s+to\s+(\S+)\s+in\s+this\s+release",
                entry["errorDescription"], re.I)
            if match is not None:
                param_distname = None
                param = match.group(3)
                value = match.group(5)
                if "distname" in entry:
                    if len(entry["distname"].strip()) != 0:
                        param_distname = entry["distname"]
                if param_distname is not None:
                    if len(param.split(".")) == 1:
                        nidd_rel_info_find = False
                        if entry["nidd_id"]:
                            for nidd_param in nidd_pool:
                                if nidd_param["nidd_id"] == entry["nidd_id"]:
                                    if nidd_param["parameters"][param][parameter_container_type_name] == "simple":
                                        p_v_t = nidd_param["parameters"][param][simple_parameter_def_name][
                                            parameter_value_type_name]
                                        if nidd_param["parameters"][param][simple_parameter_def_name][
                                                p_v_t + _parameter_def_name][descrip_of_relationship_name] is not None:
                                            for nidd_rel_info in \
                                                    nidd_param["parameters"][param][simple_parameter_def_name][
                                                        p_v_t + _parameter_def_name][descrip_of_relationship_name]:
                                                if re.search(
                                                        r"This\s+parameter\s+shall\s+be\s+equal\s+to\s+FALSE\s+"
                                                        r"in\s+this\s+release", nidd_rel_info, re.I):
                                                    builtin_obj.log("nidd defined this relationship, will be auto fix")
                                                    nidd_rel_info_find = True
                                                    break
                                    elif nidd_param["parameters"][param][parameter_container_type_name] == "complex":
                                        # check later..
                                        pass
                        else:
                            builtin_obj.log("nidd_id not found in Relation errors info, don't auto fix")
                        if nidd_rel_info_find is True:
                            single_param_need_fix = param_distname + ':' + param + '=' + value
                            if single_param_need_fix not in init_param_need_fix_all_dict:
                                init_param_need_fix_all_dict[single_param_need_fix] = {}
                                init_param_need_fix_all_dict[single_param_need_fix]["param"] = param
                                init_param_need_fix_all_dict[single_param_need_fix]["value"] = value
                        else:
                            builtin_obj.log("paramter %s structure is too long, contact "
                                            "I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com "
                                            "to further improve" % match.group(1), level="WARN")
                else:
                    builtin_obj.log("distname is empty in Relation errors info, don't auto fix")

        for param_need_fix in init_param_need_fix_all_dict:
            if param_need_fix not in self.params_fixed_all:
                for u_param in user_params:
                    para_match = re.search(
                        r"NRBTS(-\d+|):%s=(.*)" % init_param_need_fix_all_dict[param_need_fix]["param"], u_param, re.I)
                    if para_match is not None:
                        u_value = para_match.group(2).split("|")[0]
                        if u_value != value:
                            builtin_obj.log(
                                "parameter:%s value defined in case is: %s ,conflict with relation error,"
                                "don't auto fix" % (param_need_fix["param"], u_value), level="WARN")

                        else:
                            builtin_obj.log(
                                "parameter:%s value defined in case is: %s ,same with relation error,"
                                " no need fix" % (param_need_fix["param"], u_value))
                    else:
                        self.params_fixed_all.append(param_need_fix)
        builtin_obj.log("try to auto fix and change these parameter:%s" % self.params_fixed_all)
        if productVariant == "cu":
            self._update_scf_aic(scf, self.params_fixed_all, productVariant="cu")
            result_fix_err = self._validate_scf_and_get_validation_result_cu(scf, plan_name="auto_reltaion_error_fix")
        if productVariant == "du":
            self._update_scf_aic(scf, self.params_fixed_all, productVariant="du", du_identity=du_identity)
            result_fix_err = self._validate_scf_and_get_validation_result_du(scf, plan_name="auto_reltaion_error_fix",
                                                                             vdu_conn=self.alias_du)
        builtin_obj.log(result_fix_err)
        return len(result_fix_err["totalError"] + result_fix_err["totalWarning"])

    def _get_cu_state(self):
        self._setup_common_cu()
        cu_state_info = self.cu_obj.get_cu_state(connection=self.alias_cu)
        cu_state = cu_state_info["operational_state"]
        try:
            self.cu_obj.disconnect(connection=self.alias_cu)
        except Exception as e:
            pass
        return cu_state

    def _get_du_state(self):
        self._setup_common_du()
        du_state_info = self.du_obj.get_vdu_state_data(vdu_connection=self.alias_du)
        du_state = du_state_info["operational_state"]
        try:
            self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception as e:
            pass
        return du_state

    def _reset_vdu(self):
        self._setup_common_du()
        du_reset_state_info = self.du_obj.reset_vdu(timeout=15, vdu_connection=self.alias_du)
        du_reset_state = du_reset_state_info["status"]
        try:
            self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception as e:
            pass
        return du_reset_state

    def _reset_rmods(self, rmods_list):
        self._setup_common_du()
        rmod_id_info = self.du_obj.get_rmods_status(timeout=30, vdu_connection=self.alias_du)
        rmods_reset_state_info = self.du_obj.reset_rmods(rmods_list, reset_reason="user",
                                                         timeout=30, vdu_connection=self.alias_du)
        try:
            self.du_obj.disconnect(vdu_connection=self.alias_du)
        except Exception as e:
            pass
        return rmod_id_info, rmods_reset_state_info

    # Include _add_or_update_parameters_element_aic, need rewrite.
    def _update_trace_aic(self, trace_element, parameters):
        # delete old ltrace
        delete_trace = self._get_element_without_children(trace_element, "//managedObject", "operation=delete")
        # create new ltrace
        create_trace = self._add_or_update_parameters_element_aic(trace_element, parameters)
        create_trace = xml_obj.modify_xml(create_trace, "", "attrib=operation|create|//managedObject")
        # remove mo:key=${EMPTY}
        create_trace = xml_obj.remove_xml_element(create_trace, None, "//managedObject/p[not(text())]")
        return delete_trace, create_trace

    def _update_mo_aic(self, mo_in_scf, parameters, productVariant, active_scf):
        "create managedObject element with update operation according to the managedObject element \
        in SCF or SCF template"
        mo_update = self._get_element_without_children(mo_in_scf, "//managedObject", "operation=update")
        mo_update = self._add_or_update_parameters_element_aic(mo_element_or_scf=mo_update,
                                                               parameters=parameters,
                                                               productVariant=productVariant,
                                                               active_scf=active_scf)
        return mo_update

    def _create_delta_file_based_on_mo_elements_aic(self, active_scf, mos, save_path, commission_type):
        if len(mos) != 0:
            # get btsid
            commonxml = CommonXML(active_scf)
            mo_0 = commonxml.string_to_element(mos[0])
            dn = commonxml.get_element_attribute(mo_0, "distName")
            if "/" not in dn:
                btsid = dn.split("-")[-1]
            else:
                btsid = dn.split("/")[1].split("-")[-1]
            # create delta file with cmData
            # save_log_directory = comm_obj._get_save_log_dir(self.alias)
            save_log_directory = save_path
            delta_file_with_path = os.path.join(save_log_directory,
                                                "delta_file_%s_%s.xml" % (btsid, comm_obj.get_timestamp()))
            raml = self._get_element_without_children(active_scf, "/raml")
            cmData = self._get_element_without_children(active_scf, "//cmData")

            delta_file_content = xml_obj.add_xml_element(raml, "", cmData + "|/raml")
            # add mo elements into delta file
            for mo in mos:
                delta_file_content = xml_obj.add_xml_element(delta_file_content, "", mo + "|//cmData")
            if commission_type == "admin":
                delta_file_content = xml_obj.modify_xml(delta_file_content, "", "attrib=id|3221225472|//cmData")
                commonxml.save_xml(delta_file_with_path, delta_file_content)
                convert_delta_xml_to_json(delta_file_with_path)
                delta_file_with_path = delta_file_with_path.replace(".xml", ".json")
            elif commission_type == "netact":
                delta_file_content = xml_obj.modify_xml(delta_file_content, "", "attrib=type|plan|//cmData")
                commonxml.save_xml(delta_file_with_path, delta_file_content)
            else:
                raise Exception("no support for commission type %s" % commission_type)
            if len(mos) < 100:
                builtin_obj.log("step: delta file is %s" % delta_file_with_path)
                file_object = open(delta_file_with_path)
                try:
                    delta_content = file_object.read()
                    builtin_obj.log("step: delta file content:%s" % delta_content)
                finally:
                    file_object.close()
            return delta_file_with_path

    def _object_should_exist_aic(self, params, scf=None, productVariant="cu", du_identity="du", timeout="300"):
        """This keyword is to check  managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception

        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 5 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        Note: the last level instance of mo may be unknown. this keyword will support format like LNADJ or LNADJ-255

        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist | ${params}
        """
        if scf is None:
            retry_times = int(timeout) / 10
        else:
            retry_times = 0
        while retry_times >= 0:
            result, mo = self._object_exist_or_not_aic(params, scf, productVariant, du_identity)
            if result is False:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is False:
            raise Exception("mo with %s doesn't exist" % params)
        else:
            return mo

    def _object_exist_or_not_aic(self, params, scf, productVariant, du_identity="du",
                                 commission_type="admin", btsid=""):
        """
        the mo in param can be two formats:
        1. full name/short name, for example LNADJ-255
        2. mo class with full path, for example LNADJ, or LNADJ-255/LNADJL
        """

        params = comm_obj.remove_empty_from_list(params)
        builtin_obj.log("conditions are: %s" % params)
        if scf is None:
            if commission_type == "admin":
                if productVariant == "cu":
                    scf = self._download_scf_cu()
                elif productVariant == "du":
                    scf = self._download_scf_du(du_identity=du_identity)
                else:
                    raise Exception("no support productVariant %s" % productVariant)
                builtin_obj.log("step: check scf: %s" % scf)
            elif commission_type == "netact":
                scf = self._netact_cm_actual_export(btsid)
            else:
                raise Exception("no support commission commission_type for %s" % commission_type)

        mo = params[0].split(":")[0]
        if mo.split("/")[-1].count("-"):
            result = self._object_with_instance_exist_or_not(scf, params)
        else:
            # find all mos with the same as input mo
            result = False
            dn_list = []
            commonxml = CommonXML(scf)
            mo_class = mo.split("/")[-1]
            if mo.count("/"):
                parent_mo = mo.rpartition("/")[0]
                elements = commonxml.get_elements("//*[matches(@distName, '.*%s/%s-[0-9]+$')]" % (
                    parent_mo, mo_class))
            else:
                elements = commonxml.get_elements("//*[matches(@class, '.*:%s$')]" % mo_class)

            for element in elements:
                distName = commonxml.get_element_attribute(element, "distName")
                dn_list.append(distName)
            for dn in dn_list:
                builtin_obj.log("checking %s" % dn)
                params_new = []
                for param in params:
                    params_new.append(dn + ":" + param.partition(":")[-1])
                if self._object_with_instance_exist_or_not(scf, params_new) is True:
                    result = True
                    mo = dn
                    break
        builtin_obj.log("result is %s, mo is %s" % (result, mo))
        return result, mo

    def _object_should_exist_in_cu(self, params, scf=None, timeout="120"):
        self._object_should_exist_aic(params, scf, productVariant="cu", timeout=timeout)

    def _object_should_exist_in_du(self, params, scf=None, timeout="120", du_identity="du"):
        self._object_should_exist_aic(params, scf, productVariant="du", du_identity=du_identity, timeout=timeout)

    def _object_should_not_exist_aic(self, params, scf=None, productVariant="cu", du_identity="du", timeout="120"):
        """This keyword is to check if managedObject should not exist according to the conditions specified in params.
        1. If exist it will raise exception
        2. if not it succeeds

        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | timeout  |  No   | default is 2 minutes |
        Note: the last level instance of mo may be unknown. this keyword will support format like LNADJ or LNADJ-255

        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | object_should_not_exist | ${params}
        """
        if scf is None:
            retry_times = int(timeout) / 10
        else:
            retry_times = 0
        while retry_times >= 0:
            result, mo = self._object_exist_or_not_aic(params, scf, productVariant, du_identity)
            if result is True:
                retry_times = retry_times - 1
                time.sleep(10)
            else:
                break
        if result is True:
            raise Exception("mo with %s exist and it is %s" % (params, mo))

    def _object_should_not_exist_in_cu(self, params, scf=None, timeout="120"):
        self._object_should_not_exist_aic(params, scf, productVariant="cu", timeout=timeout)

    def _object_should_not_exist_in_du(self, params, scf=None, timeout="120", du_identity="du"):
        self._object_should_not_exist_aic(params, scf, productVariant="du", du_identity=du_identity, timeout=timeout)

    def _get_scf_parameter_value_cu(self, param_name, scf=None):
        if scf is None:
            scf = self._download_scf_cu()
        xpath = comm_obj.match_to_xpath(param_name)
        builtin_obj.log("xpath is %s" % xpath)
        param_value = xml_obj.read_xml(scf, "text|%s" % xpath[0])
        # if param_value is None, maybe it's simpleList param
        try:
            if param_value is None:
                builtin_obj.log("Don't check while set the parameter '%s' to simple param, "
                                "then try set it yo simpleList param" % param_name)
                import lxml.etree
                mo_xpath = re.search(r"managedObject\[.+?\]", xpath[0])
                list_xpath = re.search(r"\[@name=.+\]", xpath[0])
                if mo_xpath is not None and list_xpath is not None:
                    f = open(scf, "rb")
                    scf_text = f.read()
                    f.close()
                    tree = lxml.etree.fromstring(scf_text)
                    ns = tree.nsmap[None]
                    xpath_simpleList = "//ns:%s/ns:list%s/ns:p/text()" % (mo_xpath.group(), list_xpath.group())
                    builtin_obj.log("simpleList xpath is %s" % xpath_simpleList)
                    retList = tree.xpath(xpath_simpleList, namespaces={"ns": ns})
                    if len(retList) > 0:
                        param_value = ",".join(retList)
                        builtin_obj.log("simpleList xpath result is %s" % retList)
        except Exception as e:
            builtin_obj.log("Exception appear while try simpleList: %s, "
                            "could contact I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com " % str(e))

        return param_value

    def _get_scf_parameter_value_du_aic(self, param_name, scf=None, du_identity="du"):
        if scf is None:
            scf = self._download_scf_du(du_identity=du_identity)
        xpath = comm_obj.match_to_xpath(param_name)
        builtin_obj.log("xpath is %s" % xpath)
        param_value = xml_obj.read_xml(scf, "text|%s" % xpath[0])
        try:
            if param_value is None:
                builtin_obj.log("Don't check while set the parameter '%s' to simple param, "
                                "then try set it yo simpleList param" % param_name)
                import lxml.etree
                mo_xpath = re.search(r"managedObject\[.+?\]", xpath[0])
                list_xpath = re.search(r"\[@name=.+\]", xpath[0])
                if mo_xpath is not None and list_xpath is not None:
                    f = open(scf, "rb")
                    scf_text = f.read()
                    f.close()
                    tree = lxml.etree.fromstring(scf_text)
                    ns = tree.nsmap[None]
                    xpath_simpleList = "//ns:%s/ns:list%s/ns:p/text()" % (mo_xpath.group(), list_xpath.group())
                    builtin_obj.log("simpleList xpath is %s" % xpath_simpleList)
                    retList = tree.xpath(xpath_simpleList, namespaces={"ns": ns})
                    if len(retList) > 0:
                        param_value = ",".join(retList)
                        builtin_obj.log("simpleList xpath result is %s" % retList)
        except Exception as e:
            builtin_obj.log("Exception appear while try simpleList: %s, "
                            "could contact I_L3_HZH_HARMONIZED_TA_SUPPORT_GMS@internal.nsn.com " % str(e))
        return param_value

    # below kw inherit from cm_bts.py
    def _modify_mirror_script_parameters(self, flags, mirror_config_file):
        flags = comm_obj.remove_empty_from_list(flags)
        if len(flags) == 0:
            return
        else:
            builtin_obj.log("change mirror script with %s " % flags, console=True)
        if os.path.exists(mirror_config_file):
            mirror_file_base = mirror_config_file
        else:
            raise Exception("no base MirroringConfig.sh,please check %s" % mirror_config_file)
        mirror_config_file_dir, mirror_config_file_name = os.path.split(mirror_file_base)
        backup_mirror_file = os.path.join(mirror_config_file_dir,
                                          mirror_config_file_name.split(".")[0] +
                                          "_backup." + mirror_config_file_name.split(".")[-1]
                                          )
        os_obj.copy_file(mirror_config_file, backup_mirror_file)
        comm_obj.modify_parameter_defined_as_key_equal_value(mirror_config_file, flags)

    def _convert_delete(self, parameters):
        # convert delete:mo:list/key, delete:mo:list:key to mo:list/key=${EMPTY}, mo:list:key=${EMPTY}
        out = []
        parameters = comm_obj.remove_empty_from_list(parameters)
        for param in parameters:
            if param.count("delete:NRCELL_TDD-0") or param.count("delete:NRCELL_FDD-0"):
                param = "delete:NRCELL/%s" % param.partition(":")[-1]

            if param.count("delete") and param.count(":") > 1 and param.count("=") == 0 and param.count("*") == 0:
                out.append("%s=" % param.partition(":")[-1])
            else:
                out.append(param)
        return out

    def _mo_xpath(self, mo):
        # consider mo ending with same string
        if mo.count("MRBTS"):
            xpath = "//managedObject[matches(@distName, '%s$')]" % mo
        else:
            xpath = "//managedObject[matches(@distName, '.*/%s$')]" % mo
        return xpath

    def _extend_parameters(self, parameters, scf):
        parameters = comm_obj.remove_empty_from_list(parameters)
        out_parameters = self._extend_mo(parameters, scf, "NRCELL")
        out_parameters = self._extend_mo(out_parameters, scf, "NRBTS")
        out_parameters = self._extend_mo(out_parameters, scf, "MRBTS")
        return out_parameters

    def _classify_parameters_according_to_moname(self, parameters, position=0):
        """This keyword is to classify parameters according managedObject, return dictionary with key
        equals to managedObject, value is parameters belonging to the managedObject"""

        params_dict = {}
        mo_start = 0
        while (mo_start < len(parameters)):
            # judge mo already in params_dict or not
            mo = parameters[mo_start].split(":")[position]
            mo_exist = False
            for key in params_dict.keys():
                key_t = "/%s" % key
                mo_t = "/%s" % mo
                if key_t.endswith(mo_t) or mo_t.endswith(key_t):
                    mo_exist = True
            if mo_exist:
                mo_start = mo_start + 1
                continue
            # key is mo name, values are parameters belong to the mo
            paras_in_mo = []
            paras_in_mo.append(parameters[mo_start])
            for right in range(mo_start + 1, len(parameters)):
                mo_right = parameters[right].split(":")[position]
                mo_t = "/%s" % mo
                mo_right_t = "/%s" % mo_right
                if mo_t.endswith(mo_right_t) or mo_right_t.endswith(mo_t):
                    paras_in_mo.append(parameters[right])
            params_dict[mo] = paras_in_mo
            mo_start = mo_start + 1
        return params_dict

    def _delete_object_offline(self, source_scf, target_scf, mos_param):
        """
        Noted: match in all mo by regular expression should be '.*', but not be '*'
        | 1) | delete:mo_name or pattern | delete mo  |
        | 2) | delete:mo_name:list_name | delete list  |
        | 3) | delete:mo_name:list_name:key=value | delete the item that satisfy mo:list:key=value |
        Example
        | ${to_be_deleted_list} | Create List | delete:LNADJ.* | delete:PSGRP-1:lbpsPeriodList |
        delete:LNBTS-1824/PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ${TAR_SCF_STRING} | _delete_object_offline | D:\\scfc_1.xml | None | ${to_be_deleted_list} |
        | _delete_object_offline | D:\\scfc_1.xml | D:\\scfc_2.xml | ${to_be_deleted_list} |
        """
        mos_param = comm_obj.remove_empty_from_list(mos_param)
        for s_mo_param in mos_param:
            mo_name = s_mo_param.rsplit(":")[1].strip()
            mo_xpath = self._mo_xpath(mo_name)
            if "=" in s_mo_param:
                list_name = s_mo_param.rsplit(":")[2].strip()
                item_key = s_mo_param.rsplit(":")[3].split("=")[0].strip()
                item_value = s_mo_param.rsplit(":")[3].split("=")[1].strip()
                tbd_pattern = "%s//list[@name='%s']//*[@name='%s' and text()='%s']/.." % (
                    mo_xpath, list_name, item_key, item_value)
            else:
                if 1 == s_mo_param.count(":"):
                    tbd_pattern = mo_xpath
                elif 2 == s_mo_param.count(":"):
                    list_or_param_name = s_mo_param.rsplit(":")[2].strip()
                    tbd_pattern = "%s//list[@name='%s']|%s//p[@name='%s']" % (
                        mo_xpath, list_or_param_name, mo_xpath, list_or_param_name)
                elif 3 == s_mo_param.count(":"):
                    list_name = s_mo_param.rsplit(":")[2].strip()
                    param = s_mo_param.rsplit(":")[3].strip()
                    tbd_pattern = "%s//list[@name='%s']//p[@name='%s']" % (
                        mo_xpath, list_name, param)
            try:
                source_scf = xml_obj.remove_xml_element(
                    source_scf, None, tbd_pattern)
            except AssertionError as e:
                print(e)
                builtin_obj.log("No mo match %s\n" % tbd_pattern)

        if target_scf is None:
            return source_scf
        else:
            commonxml = CommonXML(source_scf)
            commonxml.save_xml(target_scf)
            return target_scf

    def _delete_object_online(self, active_scf, mos_param):
        """
        Noted: match in all mo by regular expression should be '.*', but not be '*'
        | 1) | delete:mo_name or pattern | delete mo  |
        | 2) | delete:mo_name:list_name | delete list  |
        | 3) | delete:mo_name:list_name:key=value | delete the item that satisfy mo:list:key=value |
        Example
        | ${to_be_deleted_list} | Create List | delete:LNADJ.* | delete:PSGRP-1:lbpsPeriodList |
        ... | delete:LNBTS-1824/PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | _delete_object_online | D:\\scfc_1.xml | ${to_be_deleted_list} |
        """
        l_mo_objects = []
        #   _verify_input_validity
        position = 1
        params_classified = self._classify_parameters_according_to_moname(mos_param, position)
        #     remove_replicate_mo
        for mo in params_classified.keys():
            mo_tbd = params_classified[mo][0]
            if 2 == len(mo_tbd.rsplit(":")):
                builtin_obj.log("Prepare to delete managedObject:\n")
                builtin_obj.log(params_classified[mo])
                l_mo_object = self._delete_mo_at_mo(active_scf, mo_tbd)
            else:
                # judge whether the mo exist or not
                mo_name = params_classified[mo][0].split(":")[1]
                mo_xpath = self._mo_xpath(mo_name)
                try:
                    pattern = "*|%s" % mo_xpath
                    s_element_mo = xml_obj.read_xml(active_scf, pattern)
                except AssertionError as e:
                    print(e)
                    builtin_obj.log(
                        "ManagedObject %s does not exist in current active_scf. Will Ignore this delete operation.\n"
                        % mo_name)
                    break
                l_mo_object = self._delete_mo_at_list_and_item(s_element_mo, params_classified[mo])

            l_mo_objects.extend(l_mo_object)

        return l_mo_objects

    def _delete_mo_at_mo(self, scf, delete_string):
        delete_list = delete_string.rsplit(":")
        mo_name = delete_list[1]
        mo_xpath = self._mo_xpath(mo_name)
        # get mo object's first line, also apply for regular expression.
        try:
            pattern = "*|%s" % mo_xpath
            s_mo_elements = self._get_multi_mo(scf, pattern)
            return s_mo_elements
        except AssertionError:
            builtin_obj.log("Can't match *|%s") % mo_xpath
            builtin_obj.log("No managed objects matching %s exists in the scf: %s" % (mo_name, scf))
            return False

    def _get_multi_mo(self, scf, pattern):
        commonxml = CommonXML(scf)
        result_mo = []
        pattern_split = pattern.split("|", 1)
        xpath = pattern_split[1]
        elements = commonxml.get_elements(xpath)
        for element in elements:
            mo_object = commonxml.element_to_string(element)
            mo_object = self._get_element_without_children(mo_object, "//managedObject", "operation=delete")
            result_mo.append(mo_object)
        return result_mo

    def _delete_mo_at_list_and_item(self, s_element_mo, l_under_the_same_mo):
        need_delete_flag = False
        list_position = 2
        d_under_the_same_mo = self._classify_parameters_according_to_list_dict(l_under_the_same_mo, list_position)
        mo_without_children = self._get_element_without_children(s_element_mo, "//managedObject", "operation=update")
        s_mo_object = mo_without_children
        for list_name in d_under_the_same_mo:
            l_under_the_same_list = d_under_the_same_mo[list_name]
            mo_name = l_under_the_same_list[0].split(":")[1]
            mo_xpath = self._mo_xpath(mo_name)
            # judge whether the list exist or not
            try:
                s_element_list = xml_obj.read_xml(s_element_mo,
                                                  "*|//list[@name='%s']|//p[@name='%s']" % (list_name, list_name))
                s_element_list_orignal = s_element_list
            except AssertionError as e:
                print(e)
                builtin_obj.log(" No list %s under %s exists in the scf." % (mo_name, l_under_the_same_list))
                #                 return []
                continue

            s_tbd_list = ""
            for s_delete in l_under_the_same_list:
                # judge whether the list is to be deleted or not
                if "=" not in s_delete:
                    s_tbd_list = self._get_element_without_children(s_element_list, "//list|/p")
                    break
                else:
                    s_tbd_item = self._delete_mo_at_item(s_element_list, s_delete)
                    if s_tbd_item:
                        s_element_list = s_tbd_item

            if s_tbd_list:
                need_delete_flag = True
                builtin_obj.log("The list %s will be deleted under %s ." % (list_name, mo_name))
                s_mo_object = xml_obj.add_xml_element(s_mo_object, None,
                                                      s_tbd_list + "|%s" % mo_xpath)
                continue
            if s_element_list != s_element_list_orignal:
                need_delete_flag = True
                builtin_obj.log("The item will be deleted under %s." % list_name)
                s_mo_object = xml_obj.add_xml_element(s_mo_object, None,
                                                      s_element_list + "|%s" % mo_xpath)

        if need_delete_flag:
            return [s_mo_object]
        else:
            return []

    def _classify_parameters_according_to_list_dict(self, list_param, position=1):
        # position=1 means mo; position=2 means list, but need to make sure the
        # lists exist.
        dict_param = {}
        for line in list_param:
            key = line.split(':')[position].split("/")[-1]
            if key not in dict_param:
                dict_param[key] = []
            dict_param[key].append(line)
        return dict_param

    def _delete_mo_at_item(self, s_element_list, delete_string):
        # match the format: delete:mo_name:list_name:key=value
        split = delete_string.rsplit(":")
        mo_name = split[1]
        list_name = split[2]
        key = split[3].split("=")[0]
        value = split[3].split("=")[1]
        l_element_item = []

        # judge whether item exists or not
        item_pattern = "//list[@name='%s']//*[@name='%s' and text()='%s']/.." % (list_name, key, value)
        try:
            l_element_item = xml_obj.read_xml(s_element_list, "*|" + item_pattern)
        except AssertionError as e:
            print(e)

        if not l_element_item:
            builtin_obj.log("No key=value: %s = %s under %s:%s. This item need not to be deleted." % (
                key, value, mo_name, list_name))
            return s_element_list

        # get the list which removes the item
        try:
            s_element_list = xml_obj.remove_xml_element(s_element_list, None, item_pattern)
            return s_element_list
        except AssertionError as e:
            print(e)
            builtin_obj.log("Remove key=value: %s=%s from %s:%s failed.\n") % (key, value, mo_name, list_name)
            raise AssertionError

    def _find_mo(self, scf, mo):
        comm_xml = CommonXML(scf)
        mo_xpath = self._mo_xpath(mo)
        elements = comm_xml.get_elements(mo_xpath)
        if len(elements):
            return True
        else:
            return False

    def _mo_xpath(self, mo):
        # consider mo ending with same string
        if mo.count("MRBTS"):
            xpath = "//managedObject[matches(@distName, '%s$')]" % mo  # mo写齐全了从MRBTS开始
        else:
            xpath = "//managedObject[matches(@distName, '.*/%s$')]" % mo  # MO没写齐全,前面可能需要补全MRBTS,NRBTS部分
        return xpath

    def _get_mo_template(self, mo, scf_template):
        dn_dict = {}
        # find all distnames which has same class as input mo
        mo_class = mo.split("/")[-1].split("-")[0]
        commonxml = CommonXML(scf_template)
        elements = commonxml.get_elements("//managedObject[matches(@class, '.*:%s$')]" % mo_class)
        for element in elements:
            distName = commonxml.get_element_attribute(element, "distName")
            # convert mo_template has same levels as mo
            mo_items = mo.split("/")
            mo_template_items = distName.split("/")
            mo_template_items = mo_template_items[-len(mo_items):]
            distName = "/".join(mo_template_items)
            element = xml_declare + commonxml.element_to_string(element)
            dn_dict[distName] = element

        if len(dn_dict):
            dn_all = sorted(list(dn_dict.keys()))
            for dn in dn_all:
                if dn.endswith("-1"):
                    return dn, dn_dict[dn]
            return dn_all[0], dn_dict[dn_all[0]]
        else:
            raise Exception("no template for %s in file %s" % (mo, scf_template))

    def _get_element_without_children(self, xml, xpath, modified_attribs=[]):
        """
        | Input Parameters  | Man. | Description |
        | xml        | Yes  |  xml file or xml format string |
        | xpath      | Yes  |  xpath
        | modified_attribs       |  No  |  attributes to be modified. format is attrib=value list|
        | Return | xml element without child elements |
        Example
        | ${element} | _get_element_without_children| D:\\SCFC_1.xml| //managedObject | operation=update |
        """
        # handle modified_attribs, return dictionary
        modified_attribs_d = {}
        if not isinstance(modified_attribs, list):
            if len(modified_attribs.strip()) == 0:
                return modified_attribs
            modified_attribs = BuiltIn().create_list(modified_attribs)
        for item in modified_attribs:
            attrib_key = item.split("=")[0]
            attrib_value = item.split("=")[1]
            modified_attribs_d[attrib_key] = attrib_value

        old_attribs = xml_obj.read_xml(xml, "attrib|%s" % xpath)
        tag = xml_obj.read_xml(xml, "tag|%s" % xpath)
        out_element = "<%s></%s>" % (tag, tag)
        commonxml = CommonXML(out_element)
        out_element = commonxml.string_to_element(out_element)
        for attrib in old_attribs.keys():
            commonxml.set_element_attribute(out_element, attrib, old_attribs[attrib])

        for attrib_m in modified_attribs_d.keys():
            commonxml.set_element_attribute(out_element, attrib_m, modified_attribs_d[attrib_m])
        out_element = commonxml.element_to_string(out_element)
        return out_element

    def _handle_items(self, mo_element, parameters):
        """
        input parameters: parameters which will be add/update and belong to one MO.

        if parameter contain condition, do the following actions
        1) get item0
        2) delete all items in the list
        3) add items according to item0 and condition specified in parameter
        """
        params_classified = self._classify_parameters_according_to_listname(parameters)
        for list_name in params_classified.keys():
            # get item0
            first_param = params_classified[list_name][0]
            mo_name = first_param.split(":")[0]
            mo_xpath = self._mo_xpath(mo_name)
            common_xml = CommonXML(mo_element)
            items = common_xml.get_elements(
                "%s/*[@name='%s']/item" % (mo_xpath, list_name))
            item0 = items[0]
            # delete old all items
            mo_element = xml_obj.remove_xml_element(mo_element, None,
                                                    "%s/*[@name='%s']/item" % (
                                                        mo_xpath, list_name))
            # add new items according to condition
            for param in params_classified[list_name]:
                condition = param.split("|")[1]
                condition_key = condition.split("=")[0]
                condition_value = condition.split("=")[1]
                try:
                    xml_obj.read_xml(mo_element,
                                     "*|%s/*[@name='%s']/item/*[@name='%s' and text()='%s']" % (
                                         mo_xpath, list_name, condition_key, condition_value))
                except AssertionError:
                    new_item = xml_declare + common_xml.element_to_string(item0)
                    new_item = xml_obj.modify_xml(new_item, "",
                                                  "text|%s|//*[@name='%s']" % (condition_value, condition_key))
                    mo_element = xml_obj.add_xml_element(mo_element, "",
                                                         new_item + "|%s/*[@name='%s']" % (mo_xpath, list_name))
        return mo_element

    def _classify_parameters_according_to_listname(self, parameters, position=1):
        """classify parameters which have condition(for example: mo:list:key=value|condition_key=condition_value),
           return dictionary with key equals to list_name, value is the list's parameters with condition
        """

        params_dict = {}
        # get parameters which contain condition
        params_cond = []
        for param in parameters:
            if param.count("|"):
                params_cond.append(param)

        list_start = 0
        while (list_start < len(params_cond)):
            # judge list already in params_dict or not
            list_name = params_cond[list_start].split(":")[position]
            list_exist = False
            for key in params_dict.keys():
                if key == list_name:
                    list_exist = True
            if list_exist:
                list_start = list_start + 1
                continue
            # key is list_name, values are parameters belong to the list
            paras_in_list = []
            paras_in_list.append(params_cond[list_start])
            for right in range(list_start + 1, len(params_cond)):
                list_right = params_cond[right].split(":")[1]
                if list_right == list_name:
                    paras_in_list.append(params_cond[right])
            params_dict[list_name] = paras_in_list
            list_start = list_start + 1
        return params_dict

    def _fix_mo_create_error(self, mo, scf, mo_create):
        # if cell is FDD, beamformingInScellAllowed should not be configured into CAREL, \
        # but NRCELL-1/CAREL-1 as mo template has it because it is TDD cell
        if mo.rpartition("-")[0].endswith("CAREL"):
            cellTechnology = xml_obj.read_xml(scf, "text|%s/p[matches(@name, 'cellTechnology')]"
                                              % self._mo_xpath(mo.split("/")[-2]))
            if cellTechnology == "FDD":
                mo_create = xml_obj.remove_xml_element(mo_create, None,
                                                       "//p[matches(@name, 'beamformingInScellAllowed')]")
        return mo_create

    def _ping_ok(self, ip):
        out = comm_obj.execute_cmd_on_pc("ping %s -c 2" % ip)
        if out.count("100% packet loss"):
            return False
        else:
            return True

    def _extend_mo(self, parameters, scf, mo_class):
        parameters = comm_obj.remove_empty_from_list(parameters)
        need_extend = False
        for param in parameters:
            if param.count(mo_class) and param.count("%s-" % mo_class) == 0:
                need_extend = True
                break
        if not need_extend:
            return parameters

        out_parameters = []
        all_dns = [dn.split("/")[-1] for dn in self._get_all_dns(scf, mo_class)]
        all_dns = list(set(all_dns))
        if len(all_dns) == 0:
            return parameters
        for para in parameters:
            first = para.partition(":")[0]
            second = para.partition(":")[2]
            # mo:key=value, mo:list:key=value, mo:list:key=value|condition_key=condition_value, \
            # mo:list=value1,value2..., mo
            if first.split("/").count(mo_class):
                for dn in all_dns:
                    # first like LNCEL/LNCEL_TDD-0
                    if first.count(mo_class + "/"):
                        first_e = first.replace(mo_class + "/", dn + "/")
                    # first like LNCEL
                    else:
                        first_e = first.replace(mo_class, dn)
                    if len(second):
                        out_parameters.append(first_e + ":" + second)
                    else:
                        out_parameters.append(first_e)
            # delete:mo, delete:mo:list
            elif first == "delete" and second.split(":")[0].split("/").count(mo_class):
                for dn in all_dns:
                    if second.count(mo_class + "/"):
                        second_e = second.replace(mo_class + "/", dn + "/")
                    else:
                        second_e = second.replace(mo_class, dn)
                    out_parameters.append(first + ":" + second_e)
            else:
                out_parameters.append(para)
        return out_parameters

    def _get_all_dns(self, scf, mo_class):
        all_dns = []
        commonxml_obj = CommonXML(scf)
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*:%s$')]" % mo_class)
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            all_dns.append(dn)
        all_dns = list(set(all_dns))
        return all_dns

    def _remove_same_params_in_scf(self, scf, parameters):
        out_parameters = []
        for param in parameters:
            # NRCELL:administrativeState sometimes not updated to SCFC, delta file will include it whenever \
            # it is same or not as active scfc
            if param.count("administrativeState"):
                out_parameters.append(param)
                continue

            if param.count("=") and param.count("|") == 0:
                param_name, param_value = param.split("=")
                param_name_xpath = comm_obj.match_to_xpath(param_name)[0]
                try:
                    param_value_in_scf = xml_obj.read_xml(scf, "text|%s" % param_name_xpath)
                    if param_value_in_scf != param_value:
                        out_parameters.append(param)
                except Exception:
                    out_parameters.append(param)
                finally:
                    pass
            else:
                out_parameters.append(param)
        return out_parameters

    def _combine_mos_element(self, mos_delta_1, mos_delta_2):
        # combine mo elment with same dn and operation
        mos_delta_combine = []
        for mo_1 in mos_delta_1:
            flag = False
            commonxml = CommonXML(mo_1)
            mo_1_dn = xml_obj.read_xml(mo_1, "attrib=distName|//managedObject")
            mo_1_operation = xml_obj.read_xml(mo_1, "attrib=operation|//managedObject")
            for mo_2 in mos_delta_2:
                mo_2_dn = xml_obj.read_xml(mo_2, "attrib=distName|//managedObject")
                mo_2_operation = xml_obj.read_xml(mo_2, "attrib=operation|//managedObject")
                if mo_1_dn == mo_2_dn and mo_1_operation == mo_2_operation:
                    flag = True
                    mo_1 = commonxml.parse_xml(mo_1)
                    childs = commonxml.get_child_elements(mo_1)
                    mo_2_add = mo_2
                    for child in childs:
                        child = commonxml.element_to_string(child)
                        mo_2_add = xml_obj.add_xml_element(mo_2_add, "", child + "|//managedObject")
                    mos_delta_combine.append(mo_2_add)
                    mos_delta_2.remove(mo_2)
                    break
            if flag is False:
                mos_delta_combine.append(mo_1)

        if len(mos_delta_2):
            mos_delta_combine.extend(mos_delta_2)

        return mos_delta_combine

    def _object_with_instance_exist_or_not(self, scf, params):
        """
        the mo in params must be full name or short name, for example LNADJ-255
        """
        exist_flag = True
        comm_xml = CommonXML(scf)
        for param in params:
            param_name = param.split("=")[0]
            expected_value = param.split("=")[1]
            param_name_xpath = comm_obj.match_to_xpath(param_name)
            try:
                actual_value = xml_obj.read_xml(scf, "text|%s" % param_name_xpath[0])
                # mo:list=value1,value2...
                if param.count(":") == 1 and actual_value is None:
                    try:
                        actual_value = []
                        p_elements = comm_xml.get_elements(param_name_xpath[0] + "/p")
                        for each in p_elements:
                            actual_value.append(comm_xml.get_element_text(each))
                        actual_value.sort()
                        expected_value = expected_value.split(",")
                        expected_value.sort()
                    except Exception:
                        raise AssertionError("maybe wrong format")
                if actual_value != expected_value:
                    builtin_obj.log("%s: actual value is %s in scf, but expected value is %s" % (
                        param_name, actual_value, expected_value))
                    exist_flag = False
                else:
                    builtin_obj.log("%s: actual value is %s in scf, expected value is %s" % (
                        param_name, actual_value, expected_value))
            except AssertionError as err_info:
                builtin_obj.log(err_info)
                exist_flag = False
        return exist_flag

    def _try_mo_key_parameter(self, mo_element_or_scf, param):
        # para format:  mo:key=value
        builtin_obj.log("xk: handling mo:key parameter: %s" % param)
        mo, key = param.split("=")[0].split(":")
        mo_xpath = self._mo_xpath(mo)
        try:
            xml_obj.read_xml(mo_element_or_scf, "*|%s/*[@name='%s']" % (mo_xpath, key))
        except AssertionError:
            mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                        "<p name='%s'></p>|%s" % (key, mo_xpath))
        return mo_element_or_scf

    def _handle_mo_list_value_parameter(self, mo_element_or_scf, param):
        """
            param: mo:list=value1,value2 or mo:list=${EMPTY}
            <list name="taList">
            <p>125</p>
            <p>100</p>
            </list>
        """
        builtin_obj.log("xk: handling mo:list=value parameter: %s" % param)
        mo, list_name = param.split("=")[0].split(":")
        values = param.split("=")[1]
        mo_xpath = self._mo_xpath(mo)
        # flag true means existing in mo_element_or_scf
        try:
            xml_obj.read_xml(mo_element_or_scf, "*|%s/*[@name='%s']" % (mo_xpath, list_name))
            flag = True
        except AssertionError:
            flag = False
        if flag:
            # delete list if existing
            mo_element_or_scf = xml_obj.remove_xml_element(mo_element_or_scf, None,
                                                           "%s/*[@name='%s']" % (mo_xpath, list_name))
        # add list
        mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                    "<list name='%s'></list>|%s" % (list_name, mo_xpath))
        # add p tag one by one
        if len(values):
            for p_value in values.split(","):
                new_p_element = "<p>%s</p>" % p_value
                mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                            new_p_element + "|%s/*[@name='%s']" % (
                                                                mo_xpath, list_name))
        return mo_element_or_scf

    def _try_mo_list_key_parameter(self, mo_element_or_scf, param):
        # para format:  mo:list:key=value
        builtin_obj.log("xk: trying mo:list:key parameter: %s" % param)
        mo, list_name, key = param.split(":")
        mo_xpath = self._mo_xpath(mo)
        try:
            xml_obj.read_xml(mo_element_or_scf, "*|%s/*[@name='%s']//*[@name='%s']" % (mo_xpath, list_name, key))
        except AssertionError:
            mo_element_or_scf = xml_obj.add_xml_element(mo_element_or_scf, "",
                                                        "<p name='%s'></p>|%s/*[@name='%s']/item"
                                                        % (key, mo_xpath, list_name))
        return mo_element_or_scf

    # kw inherit from cm_bts.py end

    def _get_all_cells_id(self):
        """fetch all cell id from cu"""
        self._setup_scf_control_aic_cu()
        cell_ids = []
        self.cu_obj.get_current_plan_file(path="./scf_cu.xml", include_runtime_data=True, timeout=100,
                                          connection=self.alias_cu)
        commonxml_obj = CommonXML("scf_cu.xml")
        all_elements = commonxml_obj.get_elements("//*[matches(@class, '.*:NRCELL$')]")
        for each_element in all_elements:
            dn = commonxml_obj.get_element_attribute(each_element, "distName")
            instance_id = dn.rpartition("-")[-1]
            lcr_id = xml_obj.read_xml(
                "scf_cu.xml", "text|//*[matches(@distName, '.*/NRCELL-%s$')]/*[matches(@name, 'lcrId')]" % instance_id)
            cell_ids.append((instance_id, lcr_id))
        return cell_ids

    def _get_nidd_file(self, nidd_file_path, productVariant):
        if productVariant == "cu":
            nidd_cu = self.cu_obj.get_nidd(connection=self.alias_cu)
            f = open(nidd_file_path, "w")
            f.write(str(nidd_cu))
            f.close()
        if productVariant == "du":
            nidd_du = self.du_obj.get_nidd(vdu_connection=self.alias_du)
            f = open(nidd_file_path, "w")
            f.write(str(nidd_du))
            f.close()

    def _release_admin_conn_cu(self):
        """ disconnect admin connection, remove alias if session expire or Token expire"""
        try:
            if comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu):
                self.cu_obj.disconnect(connection=self.alias_cu)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            if "Session expire" in str(detail) or "Token expire" in str(detail):
                self.cu_obj.store.remove(alias=self.alias_cu)

    def _release_admin_conn_du_common(self, conn_obj, alias):
        """ disconnect admin connection, remove alias if session expire or Token expire"""
        try:
            if comm_obj.check_alias_exist_on_admin(conn_obj, alias):
                conn_obj.disconnect(vdu_connection=alias)
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
            if "Session expire" in str(detail) or "Token expire" in str(detail):
                conn_obj.store.remove(alias=alias)

    def _release_admin_conn_du(self):
        """ disconnect admin connection, remove alias if session expire or Token expire"""
        self._release_admin_conn_du_common(self.du_obj, self.alias_du)

    def _create_delta_file(self, parameters, active_scf, productVariant, save_path, commission_type="admin"):
        delta_files = []
        mos_delta_1 = []
        mos_delta_2 = []
        one_file_flag = True
        parameters = self._extend_parameters(parameters, active_scf)
        params_classified = self._classify_parameters_according_to_moname(parameters)
        mo_list = list(params_classified.keys())
        mo_list.sort()

        for mo in mo_list:
            if mo == "delete":
                mo_deletes = self._delete_object_online(active_scf, params_classified["delete"])
                mos_delta_1.extend(mo_deletes)
            else:
                try:
                    mo_in_scf = xml_obj.read_xml(active_scf, "*|%s" % self._mo_xpath(mo))
                    if mo.count("LTRACE") or mo.count("MTRACE"):
                        mo_delete_trace, mo_create_trace = self._update_trace_aic(mo_in_scf, params_classified[mo])
                        mos_delta_1.append(mo_delete_trace)
                        mos_delta_2.append(mo_create_trace)
                        one_file_flag = False
                    else:
                        builtin_obj.log("mo:update %s with %s" % (mo, params_classified[mo]))
                        params_to_update = self._remove_same_params_in_scf(active_scf, params_classified[mo])
                        builtin_obj.log("mo:after remove same value as active scf, parameters need to update: %s"
                                        % params_to_update)
                        if len(params_to_update) != 0:
                            mo_update = self._update_mo_aic(mo_in_scf=mo_in_scf,
                                                            parameters=params_to_update,
                                                            productVariant=productVariant,
                                                            active_scf=active_scf)
                            mos_delta_2.append(mo_update)
                except AssertionError as err_info:
                    builtin_obj.log("mo:no '%s' in %s, create it. [%s]" % (mo, active_scf, err_info))
                    mo_create = self._create_mo_aic(mo_params=params_classified[mo],
                                                    productVariant=productVariant,
                                                    du_identity="du",
                                                    commission_type="delta")
                    mo_create = self._fix_mo_create_error(mo, active_scf, mo_create)
                    mos_delta_2.append(mo_create)

        if one_file_flag:
            mos_delta_combine = self._combine_mos_element(mos_delta_1, mos_delta_2)
            delta_file = self._create_delta_file_based_on_mo_elements_aic(active_scf, mos_delta_combine, save_path,
                                                                          commission_type)
            if delta_file is not None:
                delta_files.append(delta_file)
        else:
            delta_file_1 = self._create_delta_file_based_on_mo_elements_aic(active_scf, mos_delta_1, save_path,
                                                                            commission_type)
            BuiltIn().sleep("1s")
            delta_file_2 = self._create_delta_file_based_on_mo_elements_aic(active_scf, mos_delta_2, save_path,
                                                                            commission_type)
            delta_files.append(delta_file_1)
            delta_files.append(delta_file_2)
        return delta_files

    def _reconnect_cu_admin_session(self):
        ret = comm_obj.check_alias_exist_on_admin(self.cu_obj, self.alias_cu)
        if not ret:
            self._setup_common_cu()
        else:
            try:
                self.cu_obj.disconnect(connection=self.alias_cu)
            except Exception:
                exception_detail = traceback.format_exc()
                builtin_obj.log("[Reconnect cu_admin_session Exception] %s" % exception_detail)
                if any(item in str(exception_detail) for item in ["Session expire", "Token expire"]):
                    self.cu_obj.store.remove(alias=self.alias_cu)
            self._setup_common_cu()

    def _vcu_get_list_parameter_maxoccurs_from_nidd(self, class_name, param_name, vcu_conn, vcu_conn_alias):
        nidd_info = vcu_conn.get_nidd(connection=vcu_conn_alias, need_nidd_version=False)
        mo = list(filter(lambda x: x['class_name'] == class_name, nidd_info))
        params = mo[0]['parameters']
        for p_name, p_def in params.items():
            if p_name == param_name:
                if p_def.parameter_container_type == "simpleList":
                    return int(p_def.simple_list_parameter_def.max_occurs)
                elif p_def.parameter_container_type == "complex":
                    return int(p_def.complex_parameter_def.max_occurs)
        raise Exception("[eric]: Can not find the simpleList to complex parameter {} under {}}"
                        .format(param_name, class_name))

    def _vcu_delta_commission_by_FastJSON(self, delta_json_file, vcu_connection, vcu_sub_alias,
                                          use_m2m=True, timeout=300):
        with open(delta_json_file, "r") as f:
            delta_json_list = json.loads(f.read())
            delta_json_str = json.dumps(delta_json_list)
        builtin_obj.log("DeltaCommissionCU[fastJSON] --Delta json file content: %s" % delta_json_str, console=False)
        # delta_mo_list = []
        # for mo_dict in delta_json_list:
        #     aic_mo_dict = {}
        #     aic_mo_dict["class_name"] = mo_dict["distName"].split('/')[-1].split('-')[0]
        #     aic_mo_dict["dist_name"] = mo_dict["distName"]
        #     aic_mo_dict["operation_type"] = mo_dict["operation"]
        #
        #     payload_dict = {}
        #     for paramdict in mo_dict["parameters"]:
        #         param_value = paramdict["value"]
        #         param_name = paramdict["parameterName"]
        #         if isinstance(param_value, list) and len(param_value) == 1:
        #           max_occurs = self._vcu_get_list_parameter_maxoccurs_from_nidd(class_name=aic_mo_dict["class_name"],
        #                                                                           param_name=param_name,
        #                                                                           vcu_conn=vcu_connection,
        #                                                                           vcu_conn_alias=vcu_sub_alias)
        #             if max_occurs == 1:
        #                 payload_dict[param_name] = param_value[0]
        #             else:
        #                 payload_dict[param_name] = param_value
        #         else:
        #             payload_dict[param_name] = param_value
        #     aic_mo_dict["payload"] = json.dumps(payload_dict)
        #     delta_mo_list.append(aic_mo_dict)
        # builtin_obj.log("DeltaCommissionCU[fastJSON] --Delta M2M MOList: %s" % delta_mo_list, console=False)

        ret = vcu_connection.perform_delta_recommissioning(delta_file=delta_json_str,
                                                           connection=vcu_sub_alias)
        pro_delta_ope_id = ret["id"]
        builtin_obj.log("DeltaCommissionCU[fastJSON] --Execute provision delta, id [%s]" % pro_delta_ope_id)

        endtime = time.time() + 120
        while time.time() < endtime:
            pro_delta_plan_info = vcu_connection.get_status_of_perform_delta_recommissioning(
                operation_id=pro_delta_ope_id, connection=vcu_sub_alias, timeout=30)
            pro_delta_plan_status = pro_delta_plan_info["status"]
            if pro_delta_plan_status == "success":
                builtin_obj.log("DeltaCommissionCU[fastJSON] --Delta provisioned successfully!")
                return
            elif pro_delta_plan_status == "failure":
                raise Exception("Delta provisioned fail--{}".format(pro_delta_plan_info))
            else:
                builtin_obj.log("DeltaCommissionCU[fastJSON] --Delta provisioned ongoing,will retry in 5s",
                                level="INFO")
                time.sleep(5)
        raise Exception('DeltaCommissionCU[fastJSON] --Delta commissioning failed in the given 300s. '
                        'The status is {}'.format(pro_delta_plan_info))

    def _delta_commission_parameters_cu(self, parameters, background=False):
        self._setup_scf_control_aic_cu()
        self._reconnect_cu_admin_session()
        delta_timestamp = comm_obj.get_timestamp()
        builtin_obj.log("DeltaCommissionCU[%s] --Start delta commission on CU %s " %
                        (delta_timestamp, self.alias_cu), console=False)
        cu_save_log_dir = os.path.join(comm_obj._get_save_log_dir(self.alias),
                                       "cu_delta_commission_logs_%s" % delta_timestamp)
        if not os.path.exists(cu_save_log_dir):
            os.makedirs(cu_save_log_dir)

        cu_active_scf = os.path.join(cu_save_log_dir, "active_cu_scf_%s.xml" % delta_timestamp)
        ret = self._download_scf_cu(scf_tar_path=cu_active_scf)
        mrbts_dn = xml_obj.read_xml(cu_active_scf, "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
        bts_id = mrbts_dn.split("-")[-1]
        builtin_obj.log("DeltaCommissionCU[%s] --Download current before cu delta commission active scf: %s|%s"
                        % (delta_timestamp, self.alias_cu, cu_active_scf), console=False)

        ret = self._generate_three_templates_cu(bts_id=bts_id, save_path=cu_save_log_dir)
        builtin_obj.log("DeltaCommissionCU[%s] --Migrate and generate 3 template files, mrbts_dn & bts_id: %s | %s" %
                        (delta_timestamp, mrbts_dn, bts_id), console=False)

        parameters = self._convert_delete(parameters)
        builtin_obj.log("DeltaCommissionCU[%s] --Transfer 'delete' in robot params to 'EMPTY'" % delta_timestamp,
                        console=False)

        ret = self._search_params_in_template_aic(parameters=parameters, productVariant="cu", du_identity="du")
        builtin_obj.log("DeltaCommissionCU[%s] --Check all delta params exist in tempalte file" % delta_timestamp,
                        console=False)

        delta_files = self._create_delta_file(parameters=parameters,
                                              active_scf=cu_active_scf,
                                              productVariant="cu",
                                              save_path=cu_save_log_dir,
                                              commission_type="admin")
        if len(delta_files) == 0:
            builtin_obj.log("DeltaCommissionCU[%s] --No mo or params need update,end directly"
                            % delta_timestamp, console=False)
            return
        else:
            delta_json_file = delta_files[0]
            builtin_obj.log("DeltaCommissionCU[%s] --Generate classical delta xml & json files succeed"
                            % delta_timestamp, console=False)

        try:
            ret = self._vcu_delta_commission_by_FastJSON(delta_json_file=delta_files[0],
                                                         vcu_connection=self.cu_obj,
                                                         vcu_sub_alias=self.alias_cu,
                                                         use_m2m=True,
                                                         timeout=300)
        except Exception as e:
            traceback.print_exc()
            raise Exception(str(e))
        finally:
            self._release_admin_conn_cu()

    def _reconnect_du_admin_session(self):
        ret = comm_obj.check_alias_exist_on_admin(self.du_obj, self.alias_du)
        if not ret:
            self._setup_common_du()
        else:
            try:
                self.du_obj.disconnect(vdu_connection=self.alias_du)
            except Exception:
                exception_detail = traceback.format_exc()
                builtin_obj.log("[Reconnect du_admin_session Exception] %s" % exception_detail)
                if any(item in str(exception_detail) for item in ["Session expire", "Token expire"]):
                    self.du_obj.store.remove(alias=self.alias_du)
            self._setup_common_du()

    def _vdu_get_list_parameter_maxoccurs_from_nidd(self, class_name, param_name, vdu_conn, vdu_conn_alias):
        nidd_info = vdu_conn.get_nidd(vdu_connection=vdu_conn_alias, need_nidd_version=False)
        mo = list(filter(lambda x: x['class_name'] == class_name, nidd_info))
        params = mo[0]['parameters']
        for p_name, p_def in params.items():
            if p_name == param_name:
                if p_def.parameter_container_type == "simpleList":
                    return int(p_def.simple_list_parameter_def.max_occurs)
                elif p_def.parameter_container_type == "complex":
                    return int(p_def.complex_parameter_def.max_occurs)
        raise Exception("[eric]: Can not find the simpleList to complex parameter {} under {}}"
                        .format(param_name, class_name))

    def _vdu_delta_commission_by_FastJSON(self, delta_json_file, vdu_connection, vdu_sub_alias,
                                          use_m2m=True, timeout=300):
        with open(delta_json_file, "r") as f:
            delta_json_list = json.loads(f.read())
            delta_json_str = json.dumps(delta_json_list)
        builtin_obj.log("DeltaCommissionDU[fastJSON] --Delta json file content: %s" % delta_json_str, console=False)

        # delta_mo_list = []
        # for mo_dict in delta_json_list:
        #     aic_mo_dict = {}
        #     aic_mo_dict["class_name"] = mo_dict["distName"].split('/')[-1].split('-')[0]  # MO的种类名,不带ID
        #     aic_mo_dict["dist_name"] = mo_dict["distName"]
        #     aic_mo_dict["operation_type"] = mo_dict["operation"]
        #
        #     payload_dict = {}
        #     for paramdict in mo_dict["parameters"]:
        #         param_value = paramdict["value"]
        #         param_name = paramdict["parameterName"]
        #         if isinstance(param_value, list) and len(param_value) == 1:
        #           max_occurs = self._vdu_get_list_parameter_maxoccurs_from_nidd(class_name=aic_mo_dict["class_name"],
        #                                                                           param_name=param_name,
        #                                                                           vdu_conn=vdu_connection,
        #                                                                           vdu_conn_alias=vdu_sub_alias)
        #             if max_occurs == 1:
        #                 payload_dict[param_name] = param_value[0]
        #             else:
        #                 payload_dict[param_name] = param_value
        #         else:
        #             payload_dict[param_name] = param_value
        #     aic_mo_dict["payload"] = json.dumps(payload_dict)
        #     delta_mo_list.append(aic_mo_dict)
        # builtin_obj.log("DeltaCommissionDU[fastJSON] --Delta M2M MOList: %s" % delta_mo_list, console=False)

        ret = vdu_connection.perform_delta_recommissioning(delta_file=delta_json_str,
                                                           vdu_connection=vdu_sub_alias)
        pro_delta_ope_id = ret["id"]
        builtin_obj.log("DeltaCommissionDU[fastJSON] --Execute provision delta, id [%s]" % pro_delta_ope_id)

        endtime = time.time() + 120
        while time.time() < endtime:
            pro_delta_plan_info = vdu_connection.get_status_of_perform_delta_recommissioning(
                operation_id=pro_delta_ope_id, vdu_connection=vdu_sub_alias, timeout=30)
            pro_delta_plan_status = pro_delta_plan_info["status"]
            if pro_delta_plan_status == "success":
                builtin_obj.log("DeltaCommissionDU[fastJSON] --Delta provisioned successfully!")
                return
            elif pro_delta_plan_status == "failure":
                raise Exception("Delta provisioned fail--{}".format(pro_delta_plan_info))
            else:
                builtin_obj.log("DeltaCommissionDU[fastJSON] --Delta provisioned ongoing,will retry in 5s",
                                level="INFO")
                time.sleep(5)
        raise Exception('DeltaCommissionDU[fastJSON] --Delta commissioning failed in the given 300s. '
                        'The status is {}'.format(pro_delta_plan_info))

    def _delta_commission_parameters_du(self, parameters, background=False, du_identity="du"):
        self._setup_scf_control_aic_du(du_identity)
        self._reconnect_du_admin_session()

        delta_timestamp = comm_obj.get_timestamp()
        du_save_log_dir = os.path.join(comm_obj._get_save_log_dir(self.alias),
                                       "%s_delta_commission_%s" % (du_identity, delta_timestamp))
        if not os.path.exists(du_save_log_dir):
            os.makedirs(du_save_log_dir)
        builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s]: --Start on %s %s"
                        % (du_identity.upper(), delta_timestamp, du_identity.capitalize(), self.alias_du),
                        console=False)

        du_active_scf = os.path.join(du_save_log_dir, "active_%s_scf_%s.xml" % (du_identity, delta_timestamp))
        ret = self._download_scf_du(scf_tar_path=du_active_scf,
                                    scf_file_name="active_%s_scf_%s.xml" % (du_identity, delta_timestamp),
                                    du_identity=du_identity)
        builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s] --Download current active scf: %s|%s"
                        % (du_identity.upper(), delta_timestamp, self.alias_du, du_active_scf), console=False)

        if not os.path.exists(self.scf_template_full_du):
            mrbts_dn = xml_obj.read_xml(du_active_scf, "attrib=distName|//managedObject[matches(@class, '.*MRBTS$')]")
            bts_id = mrbts_dn.split("-")[-1]
            ret = self._generate_three_templates_du(bts_id=bts_id, save_path=du_save_log_dir, du_identity=du_identity)
            builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s] --Migrate and generate 3 template files" %
                            (du_identity.upper(), delta_timestamp), console=False)

        parameters = self._convert_delete(parameters)
        builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s] --Transfer 'delete' in robot params to 'EMPTY'"
                        % (du_identity.upper(), delta_timestamp), console=False)

        ret = self._search_params_in_template_aic(parameters=parameters, productVariant="du", du_identity=du_identity)
        builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s] --Check all delta params exist in tempalte file" %
                        (du_identity.upper(), delta_timestamp), console=False)

        delta_files = self._create_delta_file(parameters=parameters,
                                              active_scf=du_active_scf,
                                              productVariant="du",
                                              save_path=du_save_log_dir,
                                              commission_type="admin")
        if len(delta_files) == 0:
            builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s] "
                            "--No mo or params need update,end directly." % (du_identity.upper(), delta_timestamp),
                            console=False)
            return
        builtin_obj.log("DeltaCommissionDU[fastJSON][%s][%s] "
                        "--Generate classical delta xml|json files: "
                        "%s" % (du_identity.upper(), delta_timestamp, delta_files), console=False)

        try:
            ret = self._vdu_delta_commission_by_FastJSON(delta_json_file=delta_files[0],
                                                         vdu_connection=self.du_obj,
                                                         vdu_sub_alias=self.alias_du,
                                                         use_m2m=True,
                                                         timeout=300)
        except Exception as e:
            traceback.print_exc()
            raise Exception(str(e))
        finally:
            self._release_admin_conn_du()


class aic_cm_gnb1_cu(object):
    def __init__(self):
        alias = "gnb1"
        self.aic_cm_base_instant_1 = aic_cm_base(alias)

    def _setup_cm_gnb1_cu(self):
        self.aic_cm_base_instant_1.alias_cu = "gnb1_cu_cm"

    def get_cu_scf(self, scf_tar_path=""):
        self._setup_cm_gnb1_cu()
        self.aic_cm_base_instant_1._download_scf_cu(scf_tar_path)

    def get_cu_state(self):
        self._setup_cm_gnb1_cu()
        cu_state = self.aic_cm_base_instant_1._get_cu_state()
        return cu_state

    def modify_scf_and_perform_full_commission_cu(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1_cu.xml | ${parameters} |

        """
        self._setup_cm_gnb1_cu()
        return self.aic_cm_base_instant_1._modify_scf_and_perform_full_commission_cu(scf_base, parameters)

    def delta_commission_parameters_cu(self, parameters, background=False):
        self._setup_cm_gnb1_cu()
        return self.aic_cm_base_instant_1._delta_commission_parameters_cu(parameters=parameters, background=background)

    def object_should_exist_in_cu(self, params, scf=None, timeout="300"):
        """This keyword is to check  managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 5 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has one parameter in p tag  |
        Note: because the instance of mo may be unknown, this keyword supports format like LNADJ or LNADJ-255.\n
        for format 3)\n
        mo:list=value1,value2..., here list format is like:\n
        <list name="taList">\n
        <p>100</p>\n
        <p>150</p>\n
        </list>\n
        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist | ${params}
        """
        self._setup_cm_gnb1_cu()
        return self.aic_cm_base_instant_1._object_should_exist_in_cu(params, scf, timeout)

    def object_should_not_exist_in_cu(self, params, scf=None, timeout="120"):
        """This keyword is to check  managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 2 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has one parameter in p tag  |
        Note: because the instance of mo may be unknown, this keyword supports format like LNADJ or LNADJ-255.\n
        for format 3)\n
        mo:list=value1,value2..., here list format is like:\n
        <list name="taList">\n
        <p>100</p>\n
        <p>150</p>\n
        </list>\n
        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist | ${params}
        """
        self._setup_cm_gnb1_cu()
        return self.aic_cm_base_instant_1._object_should_not_exist_in_cu(params, scf, timeout)

    # below kw inherit from cm_bts.py
    def modify_mirror_script_parameters(self, flags, config_file):
        """This keyword is to modify the specific value in mirror script
        | Input Parameters | Man. | Description |
        | flags | Yes | the parameters what you want to modify.
        | config_file | Yes | MirroringConfig file path which is from gerrit.

        format of argument1 flags
        | 1) | key=value | modify parameter value, if param not exist, create it |
        Example
        | ${params_in_gnbmirror} | Create List | SYSCOM_MIRRORING=true | BACKHAUL_MIRRORING=true |
        | Modify Mirror Script Parameters| ${params_in_gnbmirror}| /home/ute/gnbMirroringConfig.sh |
        """
        self._setup_cm_gnb1_cu()
        self.aic_cm_base_instant_1._modify_mirror_script_parameters(flags, config_file)

    def get_scf_parameter_value_cu(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |

        format of param_name:
        | 1) | mo:key      | get parameter value in managedObject |
        | 2) | mo:list:key | get parameter value in list |

        Example
        | ${value} | get_scf_parameter_value_cu | LNADJ-1:cPlaneIpAddrCtrl |
        | should be equal | ${value} | oamControlled |
        """
        self._setup_cm_gnb1_cu()
        return self.aic_cm_base_instant_1._get_scf_parameter_value_cu(param_name, scf)

    def get_all_cells_id(self):
        """
        get instanceid and lcrid of all cells from cu
        """
        self._setup_cm_gnb1_cu()
        return self.aic_cm_base_instant_1._get_all_cells_id()


class aic_cm_gnb1_du(object):
    def __init__(self):
        alias = "gnb1"
        self.aic_cm_base_instant_2 = aic_cm_base(alias)

    def _setup_cm_gnb1_du(self):
        self.aic_cm_base_instant_2.alias_du = "gnb1_du_cm"
        self.aic_cm_base_instant_2.du_host = builtin_obj.get_variable_value("${VDU_IP}")
        self.aic_cm_base_instant_2.host_ssh_ip = builtin_obj.get_variable_value("${VDU_SSH_IP}")
        self.aic_cm_base_instant_2.host_ssh_usr = builtin_obj.get_variable_value("${VDU_SSH_USER}")
        self.aic_cm_base_instant_2.host_ssh_pwd = builtin_obj.get_variable_value("${VDU_SSH_PASSWD}")
        self.aic_cm_base_instant_2.vdu_namespace = builtin_obj.get_variable_value("${VDU_NAMESPACE}")
        self.aic_cm_base_instant_2.fhuc_vlan_id = builtin_obj.get_variable_value("${VDU_FHUC_VLAN}")

    def get_du_scf(self, scf_tar_path="", scf_file_name=""):
        self._setup_cm_gnb1_du()
        self.aic_cm_base_instant_2._download_scf_du(scf_tar_path, scf_file_name)

    def get_du_state(self):
        self._setup_cm_gnb1_du()
        du_state = self.aic_cm_base_instant_2._get_du_state()
        return du_state

    def reset_vdu(self):
        self._setup_cm_gnb1_du()
        du_reset_state = self.aic_cm_base_instant_2._reset_vdu()
        time.sleep(120)
        return du_reset_state

    def reset_rmods(self, rmods_list):
        self._setup_cm_gnb1_du()
        rmods_reset_state = self.aic_cm_base_instant_2._reset_rmods(rmods_list)
        return rmods_reset_state

    def modify_scf_and_perform_full_commission_du(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1_du.xml | ${parameters} |

        """
        self._setup_cm_gnb1_du()
        return self.aic_cm_base_instant_2._modify_scf_and_perform_full_commission_du(scf_base, parameters)

    def delta_commission_parameters_du(self, parameters, background=False):
        self._setup_cm_gnb1_du()
        return self.aic_cm_base_instant_2._delta_commission_parameters_du(parameters=parameters, background=background)

    def object_should_exist_in_du(self, params, scf=None, timeout="300"):
        self._setup_cm_gnb1_du()
        return self.aic_cm_base_instant_2._object_should_exist_in_du(params, scf, timeout)

    def object_should_not_exist_in_du(self, params, scf=None, timeout="120"):
        self._setup_cm_gnb1_du()
        return self.aic_cm_base_instant_2._object_should_not_exist_in_du(params, scf, timeout)

    def get_scf_parameter_value_du(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |

        format of param_name:
        | 1) | mo:key      | get parameter value in managedObject |
        | 2) | mo:list:key | get parameter value in list |

        Example
        | ${value} | get_scf_parameter_value_du | NRDRB_MAC-1:lcgid |
        | should be equal | ${value} | 1 |
        """
        self._setup_cm_gnb1_du()
        return self.aic_cm_base_instant_2._get_scf_parameter_value_du_aic(param_name, scf)


class aic_cm_gnb1_du2(object):
    def __init__(self):
        alias = "gnb1"
        self.aic_cm_base_instant_3 = aic_cm_base(alias)

    def _setup_cm_gnb1_du2(self):
        self.aic_cm_base_instant_3.alias_du = "gnb1_du2_cm"
        self.aic_cm_base_instant_3.du_host = builtin_obj.get_variable_value("${VDU2_IP}")
        self.aic_cm_base_instant_3.host_ssh_ip = builtin_obj.get_variable_value("${VDU2_SSH_IP}")
        self.aic_cm_base_instant_3.host_ssh_usr = builtin_obj.get_variable_value("${VDU2_SSH_USER}")
        self.aic_cm_base_instant_3.host_ssh_pwd = builtin_obj.get_variable_value("${VDU2_SSH_PASSWD}")
        self.aic_cm_base_instant_3.vdu_namespace = builtin_obj.get_variable_value("${VDU2_NAMESPACE}")
        self.aic_cm_base_instant_3.fhuc_vlan_id = builtin_obj.get_variable_value("${VDU2_FHUC_VLAN}")

    def get_du2_scf(self, scf_tar_path="", scf_file_name=""):
        self._setup_cm_gnb1_du2()
        self.aic_cm_base_instant_3._download_scf_du(scf_tar_path, scf_file_name, du_identity="du2")

    def get_du2_state(self):
        self._setup_cm_gnb1_du2()
        du2_state = self.aic_cm_base_instant_3._get_du_state()
        return du2_state

    def modify_scf_and_perform_full_commission_du2(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1_du.xml | ${parameters} |

        """
        self._setup_cm_gnb1_du2()
        return self.aic_cm_base_instant_3._modify_scf_and_perform_full_commission_du(
            scf_base, parameters, du_identity="du2")

    def delta_commission_parameters_du2(self, parameters, background=False):
        self._setup_cm_gnb1_du2()
        return self.aic_cm_base_instant_3._delta_commission_parameters_du(parameters=parameters,
                                                                          background=background,
                                                                          du_identity="du2")

    def object_should_exist_in_du2(self, params, scf=None, timeout="300"):
        self._setup_cm_gnb1_du2()
        return self.aic_cm_base_instant_3._object_should_exist_in_du(params, scf, timeout, du_identity="du2")

    def object_should_not_exist_in_du2(self, params, scf=None, timeout="120"):
        self._setup_cm_gnb1_du2()
        return self.aic_cm_base_instant_3._object_should_not_exist_in_du(params, scf, timeout, du_identity="du2")

    def get_scf_parameter_value_du2(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf, similar as du
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |
        """
        self._setup_cm_gnb1_du2()
        return self.aic_cm_base_instant_3._get_scf_parameter_value_du_aic(param_name, scf, du_identity="du2")


class aic_cm_gnb1_du3(object):
    def __init__(self):
        alias = "gnb1"
        self.aic_cm_base_instant_4 = aic_cm_base(alias)

    def _setup_cm_gnb1_du3(self):
        self.aic_cm_base_instant_4.alias_du = "gnb1_du3_cm"
        self.aic_cm_base_instant_4.du_host = builtin_obj.get_variable_value("${VDU3_IP}")
        self.aic_cm_base_instant_4.host_ssh_ip = builtin_obj.get_variable_value("${VDU3_SSH_IP}")
        self.aic_cm_base_instant_4.host_ssh_usr = builtin_obj.get_variable_value("${VDU3_SSH_USER}")
        self.aic_cm_base_instant_4.host_ssh_pwd = builtin_obj.get_variable_value("${VDU3_SSH_PASSWD}")
        self.aic_cm_base_instant_4.vdu_namespace = builtin_obj.get_variable_value("${VDU3_NAMESPACE}")
        self.aic_cm_base_instant_4.fhuc_vlan_id = builtin_obj.get_variable_value("${VDU3_FHUC_VLAN}")

    def get_du3_scf(self, scf_tar_path="", scf_file_name=""):
        self._setup_cm_gnb1_du3()
        self.aic_cm_base_instant_4._download_scf_du(scf_tar_path, scf_file_name, du_identity="du3")

    def get_du3_state(self):
        self._setup_cm_gnb1_du3()
        du3_state = self.aic_cm_base_instant_4._get_du_state()
        return du3_state

    def modify_scf_and_perform_full_commission_du3(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1_du.xml | ${parameters} |

        """
        self._setup_cm_gnb1_du3()
        return self.aic_cm_base_instant_4._modify_scf_and_perform_full_commission_du(scf_base, parameters,
                                                                                     du_identity="du3")

    def delta_commission_parameters_du3(self, parameters, background=False):
        self._setup_cm_gnb1_du3()
        return self.aic_cm_base_instant_4._delta_commission_parameters_du(parameters=parameters,
                                                                          background=background,
                                                                          du_identity="du3")

    def object_should_exist_in_du3(self, params, scf=None, timeout="300"):
        self._setup_cm_gnb1_du3()
        return self.aic_cm_base_instant_4._object_should_exist_in_du(params, scf, timeout, du_identity="du3")

    def object_should_not_exist_in_du3(self, params, scf=None, timeout="120"):
        self._setup_cm_gnb1_du3()
        return self.aic_cm_base_instant_4._object_should_not_exist_in_du(params, scf, timeout, du_identity="du3")

    def get_scf_parameter_value_du3(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf, similar as du
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |
        """
        self._setup_cm_gnb1_du3()
        return self.aic_cm_base_instant_4._get_scf_parameter_value_du_aic(param_name, scf, du_identity="du3")


class aic_cm_gnb1_du4(object):
    def __init__(self):
        alias = "gnb1"
        self.aic_cm_base_instant_5 = aic_cm_base(alias)

    def _setup_cm_gnb1_du4(self):
        self.aic_cm_base_instant_5.alias_du = "gnb1_du4_cm"
        self.aic_cm_base_instant_5.du_host = builtin_obj.get_variable_value("${VDU4_IP}")
        self.aic_cm_base_instant_5.host_ssh_ip = builtin_obj.get_variable_value("${VDU4_SSH_IP}")
        self.aic_cm_base_instant_5.host_ssh_usr = builtin_obj.get_variable_value("${VDU4_SSH_USER}")
        self.aic_cm_base_instant_5.host_ssh_pwd = builtin_obj.get_variable_value("${VDU4_SSH_PASSWD}")
        self.aic_cm_base_instant_5.vdu_namespace = builtin_obj.get_variable_value("${VDU4_NAMESPACE}")
        self.aic_cm_base_instant_5.fhuc_vlan_id = builtin_obj.get_variable_value("${VDU4_FHUC_VLAN}")

    def get_du4_scf(self, scf_tar_path="", scf_file_name=""):
        self._setup_cm_gnb1_du4()
        self.aic_cm_base_instant_5._download_scf_du(scf_tar_path, scf_file_name, du_identity="du4")

    def get_du4_state(self):
        self._setup_cm_gnb1_du4()
        du4_state = self.aic_cm_base_instant_5._get_du_state()
        return du4_state

    def modify_scf_and_perform_full_commission_du4(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1_du.xml | ${parameters} |

        """
        self._setup_cm_gnb1_du4()
        return self.aic_cm_base_instant_5._modify_scf_and_perform_full_commission_du(scf_base, parameters,
                                                                                     du_identity="du4")

    def delta_commission_parameters_du4(self, parameters, background=False):
        self._setup_cm_gnb1_du4()
        return self.aic_cm_base_instant_5._delta_commission_parameters_du(parameters=parameters,
                                                                          background=background,
                                                                          du_identity="du4")

    def object_should_exist_in_du4(self, params, scf=None, timeout="300"):
        self._setup_cm_gnb1_du4()
        return self.aic_cm_base_instant_5._object_should_exist_in_du(params, scf, timeout, du_identity="du4")

    def object_should_not_exist_in_du4(self, params, scf=None, timeout="120"):
        self._setup_cm_gnb1_du4()
        return self.aic_cm_base_instant_5._object_should_not_exist_in_du(params, scf, timeout, du_identity="du4")

    def get_scf_parameter_value_du4(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf, similar as du
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |
        """
        self._setup_cm_gnb1_du4()
        return self.aic_cm_base_instant_5._get_scf_parameter_value_du_aic(param_name, scf, du_identity="du4")


class aic_cm_gnb2_cu(object):
    def __init__(self):
        alias = "gnb2"
        self.aic_cm_base_instant_cu2 = aic_cm_base(alias)

    def _setup_cm_gnb2_cu(self):
        self.aic_cm_base_instant_cu2.alias_cu = "gnb2_cu_cm"

    def get_cu2_scf(self, scf_tar_path=""):
        self._setup_cm_gnb2_cu()
        self.aic_cm_base_instant_cu2._download_scf_cu(scf_tar_path)

    def get_cu2_state(self):
        self._setup_cm_gnb2_cu()
        cu2_state = self.aic_cm_base_instant_cu2._get_cu_state()
        return cu2_state

    def modify_scf_and_perform_full_commission_cu2(self, scf_base, parameters):
        """This keyword is to perform full commissioning with the specified parameters.
        | Input Parameters | Man. | Description |
        | scf_base  | Yes   | initial startup scf |
        | parameters | Yes |  parameters to be modified. format is same as delta_commission_parameters |

        format of parameters and action
        | 1) | mo:key=value | modify parameter of managedObject |
        | 2) | mo:list:key=value | modify list parameters of managedObject, modify all if mutiple items exist |
        | 3) | mo:list=value1,value2... | modify list which only has one parameter in p tag |
        | 4) | mo:list:key=value|condition_key=condition_value  | the list only contains item with
        condition_key=condition_value, key=vaule. Other parameters are same as item 0 in active SCF or template SCF |
        | 5) | delete:mo_name or pattern | delete mo  |
        | 6) | delete:mo_name:list_name or parameter | delete list or parameter |
        | 7) | mo | create/update MO, this is suggest to be used for empty MO |

        Note:
        1.for format 3)
        mo:list=value1,value2..., here list format is like:
        <list name="taList">
        <p>100</p>
        <p>150</p>
        </list>

        2. value could be ${EMPTY}, the parameter will have no value. But condition_value can't be ${EMPTY}

        3. support extension mode for NRBTS and NRCELL. NRBTS will be explained with actual NRBTS instance.
        NRCELL will be extend with all NRCELL instances as all NRCELLs instance.

        4. handle some abnormal scenarios:
        | 1) | MO doesn't exist | create the new MO based on scf template, and modify it with parameters
        specified in the new MO |
        | 2) | list doesn't exist | create the list based on scf tempalte |


        Example:
        | ${parameters} | Create List | PSGRP-1:lbpsISONCtlEnabled=true | PSGRP-1:lbpsCellList:lbpsCellSOOrder=50 |
        | ... | PSGRP-2:lbpsPeriodList:lbpsStartTimeHour=1|lbpsDayOfWeek=Mon | delete:PSGPR-[^2-3] |
        delete:PSGPR-1:lbpsPeriodList |
        | ... | delete:PSGRP-1:lbpsPeriodList:lbpsDayOfWeek=Mon | NRCELL/LNREL-1:amleAllowed=false |
        | modify_scf_and_perform_full_commission | C:\\SCFC_1_cu.xml | ${parameters} |

        """
        self._setup_cm_gnb2_cu()
        return self.aic_cm_base_instant_cu2._modify_scf_and_perform_full_commission_cu(scf_base, parameters)

    def delta_commission_parameters_cu2(self, parameters, background=False):
        self._setup_cm_gnb2_cu()
        return self.aic_cm_base_instant_cu2._delta_commission_parameters_cu(parameters=parameters,
                                                                            background=background)

    def object_should_exist_in_cu2(self, params, scf=None, timeout="300"):
        """This keyword is to check  managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 5 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has one parameter in p tag  |
        Note: because the instance of mo may be unknown, this keyword supports format like LNADJ or LNADJ-255.\n
        for format 3)\n
        mo:list=value1,value2..., here list format is like:\n
        <list name="taList">\n
        <p>100</p>\n
        <p>150</p>\n
        </list>\n
        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist | ${params}
        """
        self._setup_cm_gnb2_cu()
        return self.aic_cm_base_instant_cu2._object_should_exist_in_cu(params, scf, timeout)

    def object_should_not_exist_in_cu2(self, params, scf=None, timeout="120"):
        """This keyword is to check  managedObject should exist according to the conditions specified in params.
        1. If exist it will return the mo
        2. if not it will raise exception
        | Input Parameters | Man. | Description |
        | params   |  Yes  | parameters to be check |
        | scf  |  No   | scf file, if it is None, this keyword will download scf from BTS |
        | timeout  |  No   | default is 2 minutes |
        format of params:
        | 1) | mo:key=value | check parameter value |
        | 2) | mo:list:key=value | check parameter value in list |
        | 3) | mo:list=value1,value2... | check list which only has one parameter in p tag  |
        Note: because the instance of mo may be unknown, this keyword supports format like LNADJ or LNADJ-255.\n
        for format 3)\n
        mo:list=value1,value2..., here list format is like:\n
        <list name="taList">\n
        <p>100</p>\n
        <p>150</p>\n
        </list>\n
        Example
        | ${params} | create list | LNADJ:cPlaneIpAddrCtrl=oamControlled |  LNADJ:adjEnbId=11
        | ${mo_dn} | object_should_exist | ${params}
        """
        self._setup_cm_gnb2_cu()
        return self.aic_cm_base_instant_cu2._object_should_not_exist_in_cu(params, scf, timeout)

    def get_scf_parameter_value_cu2(self, param_name, scf=None):
        """This keyword is to get parameter value from active scf of specified scf
        | Arguments  | Man. | Default | Description |
        | param_name | Yes  | NA      | parameter name |
        | scf        | No   | None    | if None, it will download scf from GNB. |

        format of param_name:
        | 1) | mo:key      | get parameter value in managedObject |
        | 2) | mo:list:key | get parameter value in list |

        Example
        | ${value} | get_scf_parameter_value_cu | LNADJ-1:cPlaneIpAddrCtrl |
        | should be equal | ${value} | oamControlled |
        """
        self._setup_cm_gnb2_cu()
        return self.aic_cm_base_instant_cu2._get_scf_parameter_value_cu(param_name, scf)

    def get_all_cells_id_cu2(self):
        """
        get instanceid and lcrid of all cells from cu
        """
        self._setup_cm_gnb2_cu()
        return self.aic_cm_base_instant_cu2._get_all_cells_id()


class cm_aic(aic_cm_gnb1_cu, aic_cm_gnb1_du, aic_cm_gnb1_du2, aic_cm_gnb1_du3, aic_cm_gnb1_du4, aic_cm_gnb2_cu):
    def __init__(self):
        aic_cm_gnb1_cu.__init__(self)
        aic_cm_gnb1_du.__init__(self)
        aic_cm_gnb1_du2.__init__(self)
        aic_cm_gnb1_du3.__init__(self)
        aic_cm_gnb1_du4.__init__(self)
        aic_cm_gnb2_cu.__init__(self)

    def release_admin_connection(self):
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        cu_num = builtin_obj.get_variable_value("${CU_NUMBER}")
        self.aic_cm_base_instant_1._release_admin_conn_cu()
        self.aic_cm_base_instant_2._release_admin_conn_du()
        if du_num != "du" and du_num >= "2du":
            self.aic_cm_base_instant_3._release_admin_conn_du()
        if du_num != "du" and du_num >= "3du":
            self.aic_cm_base_instant_4._release_admin_conn_du()
        if du_num != "du" and du_num >= "4du":
            self.aic_cm_base_instant_5._release_admin_conn_du()
        if cu_num != "cu" and cu_num >= "2cu":
            self.aic_cm_base_instant_cu2._release_admin_conn_cu()

    def reestablish_all_admin_connection(self):
        """reestablish admin connection in cm_aic.py, admin connection in other lib release timely once kw end"""
        # will check if can use __enter__ and __exit__ .
        du_num = builtin_obj.get_variable_value("${DU_NUMBER}")
        cu_num = builtin_obj.get_variable_value("${CU_NUMBER}")
        self.release_admin_connection()
        try:
            self.aic_cm_base_instant_1._setup_common_cu()
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        try:
            self.aic_cm_base_instant_2._setup_common_du()
            # need _setup_common_du3/du4 later
        except Exception:
            detail = traceback.format_exc()
            builtin_obj.log(detail)
        if du_num != "du" and du_num >= "2du":
            try:
                self.aic_cm_base_instant_3._setup_common_du()
                # need _setup_common_du3/du4 later
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)
        if du_num != "du" and du_num >= "3du":
            try:
                self.aic_cm_base_instant_4._setup_common_du()
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)
        if du_num != "du" and du_num >= "4du":
            try:
                self.aic_cm_base_instant_5._setup_common_du()
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)
        if cu_num != "cu" and cu_num >= "2cu":
            try:
                self.aic_cm_base_instant_cu2._setup_common_cu()
            except Exception:
                detail = traceback.format_exc()
                builtin_obj.log(detail)


if __name__ == "__main__":
    obj = cm_aic()
    help(obj)
