# -*- coding:utf-8 -*-
# Author: Zhang Yin
import os
import sys
import time
from taf.gnb.oam.coam.cu import cu
from taf.gnb.oam.coam.vdu import Vdu
from taf.sbts.oam.coam.admin import admin

cwd = os.path.split(os.path.abspath(__file__))[0]
sys.path.append("{}/../../resources/DevHZ5_lib/src/base_lib".format(cwd))
try:
    from ta_xml import ta_xml
    from ta_xml.common_xml import CommonXML
except Exception:
    raise

xml_obj = ta_xml()


class scf_admin(object):
    def __init__(self):
        self.enb_build_file = ""
        self.alias = "scf_admin"
        self.cu_host = "192.168.100.129"
        self.du_host = "192.168.255.129"
        self.classical_host = "192.168.255.129"
        self.bts_port = "443"
        self.use_ssl = True

    def __enter__(self):
        pass

    def __exit__(self, exc_type, exc_val, exc_tb):
        pass

    def _upload_plan_file_cu(self, scf):
        # upload plan file
        result = self.cu_obj.upload_plan_file(scf, os.path.basename(scf), connection=self.alias)
        plan_id = result["plan_id"]
        action_id = result["action_id"]
        # wait upload finished
        interval = 2
        timeout = 10
        start_time = time.time()
        while True:
            result = self.cu_obj.get_operation_state_of_uploading_plan(operation_id=action_id, connection=self.alias)
            if result["status"] != "success":
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    raise Exception("fail to load scf:{} to cu".format(scf))
            else:
                break
        return plan_id

    def _get_plan_file_cu(self, plan_id, target_scf):
        interval = 5
        timeout = 20
        start_time = time.time()
        while True:
            try:
                self.cu_obj.get_plan_file(plan_id, target_scf, connection=self.alias)
                break
            except Exception as _err:
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    raise Exception("fail to get scf plan file")

    def _migrate_scf_cu(self, scf, migrated_scf):
        print("migrate {}".format(scf))
        try:
            self.cu_obj = cu()
            self.cu_obj.connect_to(alias=self.alias, port=self.bts_port, secure=self.use_ssl,
                                   host=self.cu_host, username="Nemuadmin", password="nemuuser")
            plan_id = self._upload_plan_file_cu(scf)
            self._get_plan_file_cu(plan_id, migrated_scf)
            self.cu_obj.plan_delete(plan_id, connection=self.alias)
        except Exception as _err:
            raise Exception(_err)
        finally:
            self.cu_obj.disconnect(self.alias)

    def _upload_plan_file_du(self, scf):
        # upload plan file
        result = self.du_obj.upload_plan(scf, os.path.basename(scf), vdu_connection=self.alias)
        plan_id = result["plan_id"]
        action_id = result["action_id"]
        # wait upload finished
        interval = 2
        timeout = 10
        start_time = time.time()
        while True:
            result = self.du_obj.get_upload_plan_operation_status(operation_id=action_id, vdu_connection=self.alias,
                                                                  timeout=5)
            if result["status"] != "success":
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    raise Exception("fail to load scf:{} to cu".format(scf))
            else:
                break
        return plan_id

    def _get_plan_file_du(self, plan_id, target_scf):
        scf_dir, scf_name = os.path.split(target_scf)
        interval = 5
        timeout = 20
        start_time = time.time()
        while True:
            try:
                self.du_obj.get_staged_plan_file_with_planid(plan_id, scf_dir, scf_name, vdu_connection=self.alias)
                break
            except Exception as _err:
                time.sleep(interval)
                if time.time() - start_time > timeout:
                    raise Exception("fail to get scf plan file")

    def _migrate_scf_du(self, scf, migrated_scf):
        print("migrate {}".format(scf))
        try:
            self.du_obj = Vdu()
            self.du_obj.connect_to(host=self.du_host, port=self.bts_port, secure=self.use_ssl,
                                   username="Nemuadmin", password="nemuuser", connection_name=self.alias)
            plan_id = self._upload_plan_file_du(scf)
            self._get_plan_file_du(plan_id, migrated_scf)
            self.du_obj.delete_staged_plan_file(plan_id, vdu_connection=self.alias)
        except Exception as _err:
            raise Exception(_err)
        finally:
            self.du_obj.disconnect(self.alias)

    def _migrate_scf_classical(self, scf, migrated_scf):
        print("migrate {}".format(scf))
        try:
            self.admin_obj = admin()
            self.admin_obj.setup_admin(alias=self.alias, bts_port=self.bts_port, use_ssl=self.use_ssl,
                                       bts_host=self.classical_host, admin_api_log_dir="/tmp")
            self.admin_obj.migrate_scf(scf, migrated_scf, alias=self.alias)
        except Exception as _err:
            raise Exception(_err)
        finally:
            self.admin_obj.teardown_admin(alias=self.alias)

    def _get_scf_type(self, scf):
        # version example in CU: sBTSCU23R1_2216_000
        # version example in DU: sBTSVDU23R1_2216_000
        version = xml_obj.read_xml(scf, "attrib=version|//managedObject[matches(@class, '.*:MRBTS$')]")
        if version.count("CU"):
            return "cu"
        elif version.count("DU"):
            return "du"
        else:
            return "classical"

    def migrate_scf(self, scf, migrated_scf=None):
        if migrated_scf is None:
            migrated_scf = scf
        scf_type = self._get_scf_type(scf)
        if scf_type == "cu":
            self._migrate_scf_cu(scf, migrated_scf)
        elif scf_type == "du":
            self._migrate_scf_du(scf, migrated_scf)
        else:
            self._migrate_scf_classical(scf, migrated_scf)

    def get_scf_template(self, input_scf):
        release_path = "trunk"  # hardcode now, will dynamically get later
        scf_type = self._get_scf_type(input_scf)
        if scf_type == "cu":
            scf_template_svn = os.path.join(os.path.dirname(__file__),
                                            "../../resources_aic/configuration_file/%s/SCFC_template_cu.xml"
                                            % release_path)
            scf_supplement = os.path.join(os.path.dirname(__file__),
                                          "../../resources_aic/configuration_file/%s/SCFC_1_supplement_cu.xml"
                                          % release_path)
        elif scf_type == "du":
            scf_template_svn = os.path.join(os.path.dirname(__file__),
                                            "../../resources_aic/configuration_file/%s/SCFC_template_du.xml"
                                            % release_path)
            scf_supplement = os.path.join(os.path.dirname(__file__),
                                          "../../resources_aic/configuration_file/%s/SCFC_1_supplement_du.xml"
                                          % release_path)
        else:
            scf_template_svn = os.path.join(os.path.dirname(__file__),
                                            "../../resources/configuration_file/%s/SCFC_template.xml"
                                            % release_path)
            scf_supplement = os.path.join(os.path.dirname(__file__),
                                          "../../resources/configuration_file/%s/SCFC_1_supplement.xml"
                                          % release_path)
        return scf_template_svn, scf_supplement
