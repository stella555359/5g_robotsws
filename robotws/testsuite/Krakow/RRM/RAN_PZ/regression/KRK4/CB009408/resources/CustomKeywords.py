from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.utilities.robot.general import get_builtin_value
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Krakow.RRM.RAN_PZ.regression.KRK4.CB009408.resources.UeOperations import UeOperations
from taf.rfrl.bts.devices.exceptions import AlarmIsNotActive
from taf.internal.sbts.admin.exceptions import AdminApiProcedureTimeoutException, AdminApiNoResponseException
import logging
import time
import re


class CustomKeywords(object):
    def __init__(self):
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.gnb_scf = GnbCommissioning()
        self.gnb_du = GnbDuOperations()
        self.log_path = get_builtin_value("LOG_PATH")
        self.ue_operations = UeOperations()
        self.gnb_alarm = GnbAlarmVerification()
        self.gnb_cell = GnbCellOperations()
        self.alarms_no_internal_lnadjgnb = [
            "Cell problem due to associated X2 links and/or NG links and/or E1 link unavailability",
            "Cell Activation timeout at gNB-DU"]
        self.alarms_could_not_create_lnadjgnb = ["LNADJGNB for the SBTS EN-DC gNB neighbor could not be created"]
        self.alarm_failed_x2 = ["Setup of X2 connectivity to gNB failed", "X2(gNB) link ANR establishment failure"]
        self.alarms_maximum_lnadjgnbs_exceeded = ["Maximum number of EN-DC neighbor gNBs is exceeded"]
        self.alarm_ng_gnb_reset = ["NgGnbInitFullReset", "NgSetupFailure"]

    def upload_custom_swconfig(self, path, bts_id=0, du_id=0):
        self.gnb_du.upload_swconfig(sw_config_path=path, bts_id=bts_id, du_id=du_id, reboot_after_upload=False)

    def set_swconfig_cp_debug_flags(self):
        flags = {'0x890005': 1,  # CP-IF log
                 '0x890001': 1,  # CP-NB log
                 '0x890003': 1,  # CP-UE log
                 '0x890004': 1}  # CP-CL log

        for cp_flag, debug_lvl in flags.items():
            self.gnb_du.set_swconfig_flag(flag=cp_flag, value=debug_lvl)

    def set_cb009408_feature_flag(self, operation, gnb_id=0, timeout=300):
        global_bts_id = self.tl.gnbs[gnb_id].global_bts_id
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            timeout=timeout,
            dist_name="MRBTS-{}/LNBTS-{}".format(global_bts_id, global_bts_id),
            parameter="actEndcAutoX2SetupSbts",
            operation='update',
            value='true' if operation.lower() == 'enable' else 'false')

    def set_cb007334_feature_flag(self, operation, gnb_id=0, timeout=300):
        global_bts_id = self.tl.gnbs[gnb_id].global_bts_id
        flags = {"actUeBasedAnrNr": "MRBTS-{}/LNBTS-{}".format(global_bts_id, global_bts_id),
                 "actAutoNrNeighRemoval": "MRBTS-{}/LNBTS-{}/ANR-0".format(global_bts_id, global_bts_id)}
        for flag_name in flags.keys():
            value = "true" if flag_name == "actUeBasedAnrNr" and operation.lower() == "enable" else "false"
            self.gnb_scf.perform_configuration_parameter_recommissioning(
                timeout=timeout,
                dist_name=flags[flag_name],
                parameter=flag_name,
                operation='update',
                value=value
            )

    def verify_validation_errors_not_exists(self):
        self.gnb_scf.verify_validation_error_not_active()

    def get_gnb_configuration(self, bts_id=0, du_id=0, config_type="configuration", filename=None):
        return self.gnb_du.get_bts_configuration_file(bts_id=bts_id, local_dir=self.log_path, config_type=config_type,
                                                      filename=filename, du_id=du_id)

    def get_x2cplane_distname(self):
        pattern_dn = r"x2Cplane.*\s.*\s.*>(MRBTS-\d+\/TNLSVC-\d+\/TNL-\d+\/IPNO-\d+\/IPIF-\d+\/IPADDRESSV\d-\d+)<\/p>"
        scf = self.get_gnb_configuration()
        cplane_dn = re.search(pattern_dn, self._file_reader(scf))
        if cplane_dn:
            return cplane_dn.group(1)
        else:
            raise Exception("Not found x2cplane distname in SCF: '{}'".format(scf))

    def get_x2cplane_addr(self, bts_id=0, du_id=0):
        cplane_distname = self.get_x2cplane_distname()
        addr_objects = self._get_object_from_configuration(
            class_name="com.nokia.srbts.tnl:IPADDRESSV4", bts_id=bts_id, du_id=du_id)
        for addr_object in addr_objects:
            if addr_object['dist_name'] == cplane_distname:
                return addr_object['params']['localIpAddr']

    def get_lnrelgnbcell_from_configuration(self, bts_id=0, du_id=0):
        lnrelgnbcell_object = self._get_object_from_configuration(
            class_name="NOKLTE:LNRELGNBCELL", bts_id=bts_id, du_id=du_id)
        if lnrelgnbcell_object:
            return lnrelgnbcell_object
        else:
            logging.info("LNRELGNBCELL not found in current BTS configuration")

    def get_lnadjgnb_from_configuration(self, bts_id=0, du_id=0):
        lnadjgnb_object = self._get_object_from_configuration(
            class_name="NOKLTE:LNADJGNB", scf_export_type="configurationAndRuntimeObjects", bts_id=bts_id, du_id=du_id)
        if lnadjgnb_object:
            return lnadjgnb_object
        else:
            logging.info("LNADJGNB not found in current BTS configuration")

    def _get_object_from_configuration(self, class_name, max_retry=5, scf_export_type=None, timeout=120, bts_id=0,
                                       du_id=0):
        if max_retry > 0:
            try:
                scf_object = self.gnb_scf.get_all_params_under_class_name(
                    class_name=class_name, scf_export_type=scf_export_type, bts_id=bts_id, du_id=du_id,
                    timeout=timeout)
            except (AdminApiProcedureTimeoutException, AdminApiNoResponseException):
                logging.info("Unable to extract '{}' object from SCF. Retrying".format(class_name))
                self._get_object_from_configuration(
                    class_name=class_name, max_retry=max_retry - 1, scf_export_type=scf_export_type, timeout=timeout,
                    bts_id=bts_id, du_id=du_id)
            else:
                return scf_object
        else:
            raise Exception("Failed to extract '{}' object from SCF".format(class_name))

    def _verify_cplane_ipaddr_of_neighbor_gnb(self, lnadjgnb_object=None):
        x2cplane_addr = self.get_x2cplane_addr()
        lnadjgnb_cplane_addr = lnadjgnb_object['params']['cPlaneIpAddr']
        if x2cplane_addr == lnadjgnb_cplane_addr:
            logging.info("Success! cPlaneIpAddr from LNADJGNB object: '{}' equals gNB x2cplane IP address: '{}' "
                         "".format(lnadjgnb_cplane_addr, x2cplane_addr))
        else:
            raise Exception("Failed! cPlaneIpAddr from LNADJGNB object: '{}' is not the same as gNB x2cplane IP "
                            "address: '{}'".format(lnadjgnb_cplane_addr, x2cplane_addr))

    def modify_x2cplane_addr(self, distname, bts_id=0, du_id=0):
        x2cplane = [{
            "distName": "MRBTS-{}/NRBTS-{}",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "x2Cplane",
                    "value":
                        [{
                            "ipV4AddressDN1": distname
                        }]
                }]
        }]
        self.gnb_alarm.allow_alarm(alarm=self.alarms_no_internal_lnadjgnb + self.alarm_failed_x2,
                                   bts_id=bts_id, du_id=du_id)
        self.gnb_scf.perform_bts_delta_commissioning(delta=x2cplane)

    def verify_internal_neighbouring_gnb_object(self, bts_id=0, du_id=0, cplane_control="enbControlled",
                                                wait_for_x2_availability=False):
        internal_neighbour = self._get_internal_neighbouring_object(bts_id=bts_id, du_id=du_id)
        if internal_neighbour:
            self._verify_identity_of_neighbor_gnb(internal_neighbour)
            self._verify_length_of_neighbor_gnb_id(internal_neighbour, bts_id, du_id)
            self._verify_cplane_ipaddr_of_neighbor_gnb(internal_neighbour)
            self._verify_cplane_ip_address_control(internal_neighbour, expected_state=cplane_control)
            self._verify_plmn_identity(internal_neighbour, bts_id, du_id)
            if wait_for_x2_availability:
                self._wait_for_availability_of_x2_link_to_gnb(bts_id=bts_id, du_id=du_id, max_retry=40, interval=30)
            else:
                self._verify_status_of_x2_link_to_gnb(internal_neighbour, expected_state="available")
        else:
            raise Exception("Not found internal neighbouring gnb object LNADJGNB in current gNB configuration")

    def _check_if_neighbouring_object_is_internal(self, lnadjgnb_object, bts_id=0):
        nrbts_id = self.tl.gnbs[bts_id].global_bts_id
        adj_gnb_id = lnadjgnb_object["params"]["adjGnbId"]
        if int(adj_gnb_id) == int(nrbts_id):
            logging.info("Found internal neighbouring object: '{}'".format(lnadjgnb_object))
            return lnadjgnb_object

    def _get_internal_neighbouring_object(self, bts_id=0, du_id=0):
        neighbouring_gnbs = self.get_lnadjgnb_from_configuration(bts_id=bts_id, du_id=du_id)
        for neighbouring_gnb in neighbouring_gnbs:
            if self._check_if_neighbouring_object_is_internal(neighbouring_gnb):
                return neighbouring_gnb

    def _get_nrbts_plmn(self, bts_id=0, du_id=0):
        nrbts = self._get_object_from_configuration(
            class_name="com.nokia.srbts.nrbts:NRBTS", bts_id=bts_id, du_id=du_id)[0]
        nrbts_plmn = {"mcc": nrbts["params"]["mcc"],
                      "mnc": nrbts["params"]["mnc"],
                      "mncLength": nrbts["params"]["mncLength"]}
        return nrbts_plmn

    def _verify_plmn_identity(self, lnadjgnb_object, bts_id=0, du_id=0):
        nrbts_plmn = self._get_nrbts_plmn(bts_id=bts_id, du_id=du_id)
        lnadjgnb_plmn = lnadjgnb_object["params"]["plmnId"][0]
        if lnadjgnb_plmn == nrbts_plmn:
            logging.info("Success! LNADJGNB PLMN identity: '{}' maps to NRBTS PLMN identity: '{}'"
                         "".format(lnadjgnb_plmn, nrbts_plmn))
        else:
            raise Exception("Failed! LNADJGNB PLMN identity: '{}' from distname '{}' doesn't maps to NRBTS PLMN "
                            "identity: '{}'".format(lnadjgnb_plmn, lnadjgnb_object["dist_name"], nrbts_plmn))

    def _verify_identity_of_neighbor_gnb(self, lnadjgnb_object, bts_id=0):
        nrbts_id = self.tl.gnbs[bts_id].global_bts_id
        adj_gnb_id = lnadjgnb_object["params"]["adjGnbId"]
        if int(adj_gnb_id) == int(nrbts_id):
            logging.info("Success! adjGnbId parameter value: '{}' maps to New Radio Basestation instance identifier "
                         "(nrBtsId): '{}'".format(adj_gnb_id, nrbts_id))
        else:
            raise Exception("Failed! adjGnbId parameter value: '{}' from LNADJGNB '{}' doesn't maps to New Radio "
                            "Basestation instance identifier (nrBtsId): '{}'"
                            "".format(adj_gnb_id, lnadjgnb_object["dist_name"], nrbts_id))

    @staticmethod
    def _get_status_of_x2_link_to_gnb(lnadjgnb_object):
        return lnadjgnb_object["params"]["x2ToGnbLinkStatus"]

    def _verify_status_of_x2_link_to_gnb(self, lnadjgnb_object, expected_state="available"):
        x2_status = self._get_status_of_x2_link_to_gnb(lnadjgnb_object)
        if x2_status == expected_state:
            logging.info("Success! x2ToGnbLinkStatus parameter has expected value: '{}'".format(x2_status))
        else:
            raise Exception("Failed! x2ToGnbLinkStatus parameter has wrong value: '{}', expected value: '{}'"
                            "".format(x2_status, expected_state))

    def _wait_for_availability_of_x2_link_to_gnb(self, bts_id=0, du_id=0, max_retry=40, interval=30):
        if max_retry > 0:
            internal_neighbour = self._get_internal_neighbouring_object(bts_id=bts_id, du_id=du_id)
            if internal_neighbour:
                x2_status = self._get_status_of_x2_link_to_gnb(internal_neighbour)
                if x2_status == "available":
                    logging.info("Success! x2ToGnbLinkStatus parameter in LNADJGNB: '{}' has expected value: '{}'"
                                 "".format(internal_neighbour["dist_name"], x2_status))
                else:
                    logging.info(
                        "Current x2ToGnbLinkStatus: '{}' in LNADJGNB: '{}'. Wait '{}'s for next status check attempt"
                        "".format(x2_status, internal_neighbour["dist_name"], interval))
                    time.sleep(interval)
                    self._wait_for_availability_of_x2_link_to_gnb(bts_id=0, du_id=0, max_retry=max_retry - 1)
            else:
                raise Exception("Not found internal neighbouring gnb object LNADJGNB in current gNB configuration")
        else:
            raise Exception("Failed. Waiting for X2 availability timeout exceeded")

    def _get_gnb_id_length(self, bts_id=0, du_id=0):
        gnb_id_length = self._get_object_from_configuration(
            class_name="com.nokia.srbts.nrbts:NRBTS", bts_id=bts_id, du_id=du_id)[0]["params"]["gNbIdLength"]
        return gnb_id_length

    def _verify_length_of_neighbor_gnb_id(self, lnadjgnb_object, bts_id=0, du_id=0):
        gnb_id_length = self._get_gnb_id_length(bts_id=bts_id, du_id=du_id)
        adj_gnb_id_length = lnadjgnb_object["params"]["adjGnbIdLength"]
        if adj_gnb_id_length == gnb_id_length:
            logging.info("Success! adjGnbIdLength parameter value: '{}' maps to gNbIdLength: "
                         "'{}'".format(adj_gnb_id_length, gnb_id_length))
        else:
            raise Exception("Failed! adjGnbIdLength parameter value: '{}' doesn't maps to gNbIdLength: "
                            "'{}'".format(adj_gnb_id_length, gnb_id_length))

    @staticmethod
    def _verify_cplane_ip_address_control(lnadjgnb_object, expected_state="enbControlled"):
        cplane_ip_addr_ctrl = lnadjgnb_object["params"]["cPlaneIpAddrCtrl"]
        if cplane_ip_addr_ctrl == expected_state:
            logging.info("Success! cPlaneIpAddrCtrl parameter has expected value: '{}'".format(cplane_ip_addr_ctrl))
        else:
            raise Exception("Failed! cPlaneIpAddrCtrl parameter has wrong value: '{}', expected value: '{}'"
                            "".format(cplane_ip_addr_ctrl, expected_state))

    def remove_all_neighbouring_gnb(self, bts_id=0, du_id=0):
        lnadjgnbs = self.get_lnadjgnb_from_configuration(bts_id=bts_id, du_id=du_id)
        if lnadjgnbs:
            self._delete_objects_from_configuration(lnadjgnbs, bts_id, du_id)

    def remove_lte_neighbor_relation_to_cells(self, bts_id=0, du_id=0):
        lnrelgnbcells = self.get_lnrelgnbcell_from_configuration(bts_id=bts_id, du_id=du_id)
        if lnrelgnbcells:
            self._delete_objects_from_configuration(lnrelgnbcells, bts_id, du_id)

    def _delete_objects_from_configuration(self, objects, bts_id=0, du_id=0):
        delta_objects = []
        for obj in objects:
            delete_pattern = {
                "distName": obj["dist_name"],
                "operation": "delete",
                "parameters": []
            }
            delta_objects.append(delete_pattern)
        logging.info("delta_objects: {}".format(delta_objects))
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta_objects, bts_id=bts_id, du_id=du_id)

    def perform_ue_attach_and_verify_lte_neighbor_relation_to_cells(self, cell_type="LTE", cell_id='19736435',
                                                                    check_endc_call=True, bts_id=0, du_id=0):
        self.ue_operations.perform_attach_procedure(cell_type=cell_type, cell_id=cell_id,
                                                    check_endc_call=check_endc_call, bts_id=bts_id, du_id=du_id)
        self.check_if_internal_nr_cells_exists_in_lte_neighbor_relations()

    def verify_if_lte_neighbor_relation_to_cell_not_exist(self, lnrelgnbcell_id):
        lnrelgnbcells = self.get_lnrelgnbcell_from_configuration()
        if lnrelgnbcells:
            lnrel_pattern = re.compile("LNRELGNBCELL-{}".format(lnrelgnbcell_id))
            for lnrel in lnrelgnbcells:
                if re.search(lnrel_pattern, lnrel["dist_name"]):
                    raise Exception("Failure! LNRELGNBCELL-'{}' found in current BTS configuration. "
                                    "Object should not exist! '{}'".format(lnrelgnbcell_id, lnrel))
        else:
            logging.info("LNRELGNBCELL-'{}' not found in current BTS configuration".format(lnrelgnbcell_id))

    def verify_if_internal_neighbouring_gnb_object_not_exist(self, bts_id=0, du_id=0):
        lnadjgnbs = self.get_lnadjgnb_from_configuration(bts_id=bts_id, du_id=du_id)
        if lnadjgnbs:
            for lnadjgnb in lnadjgnbs:
                if self._check_if_neighbouring_object_is_internal(lnadjgnb):
                    raise Exception("Failed! Found internal LNADJGNB object: '{}'. "
                                    "It should not exist in BTS configuration".format(lnadjgnb))

    def perform_attach_procedure(self, cell_type="LTE", cell_id='19736435', check_endc_call=False):
        self.ue_operations.perform_attach_procedure(cell_type=cell_type, cell_id=cell_id,
                                                    check_endc_call=check_endc_call)

    def remove_all_neighbouring_gnb_and_check_fault_5518_activation(self, bts_id=0, du_id=0):
        self.remove_all_neighbouring_gnb(bts_id=bts_id, du_id=du_id)
        self.verify_if_internal_neighbouring_gnb_object_not_exist(bts_id=bts_id, du_id=du_id)
        self.gnb_alarm.allow_alarm(alarm=self.alarms_no_internal_lnadjgnb + self.alarms_could_not_create_lnadjgnb,
                                   bts_id=bts_id, du_id=du_id)
        self.gnb_alarm.wait_for_alarm_activation(fault_id="5518", awaiting_time=60, bts_id=bts_id, du_id=du_id)
        self._check_if_cells_are_degraded(technology="nr", bts_id=bts_id, du_id=du_id)

    def disable_and_enable_feature_flag_and_check_automatic_neighbouring_gnb_addition(self, gnb_id=0, du_id=0):
        self.set_cb009408_feature_flag(operation="disable", gnb_id=gnb_id)
        self.set_cb009408_feature_flag(operation="enable", gnb_id=gnb_id)
        self.verify_internal_neighbouring_gnb_object(bts_id=gnb_id, du_id=du_id)
        self.gnb_cell.verify_all_cells_are_onair(bts_id=gnb_id, du_id=du_id, cell_type="all")
        self.gnb_alarm.verify_alarm_is_not_active(
            fault_name="LNADJGNB for the SBTS EN-DC gNB neighbor could not be created", fault_id="5518", bts_id=gnb_id,
            du_id=du_id)
        self.gnb_alarm.verify_alarm_is_not_active(
            fault_name="Maximum number of EN-DC neighbor gNBs is exceeded", fault_id="5515", bts_id=gnb_id,
            du_id=du_id)

    def restart_bts_and_check_automatic_neighbouring_gnb_addition(self, bts_id=0, du_id=0):
        self.gnb_du.reset_bts(bts_id=bts_id, du_id=du_id, wait_for_reconnection=True)
        self.gnb_du.wait_for_site_to_be_onair(bts_id=bts_id, du_id=du_id, timeout=600, interval=30)
        self.gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id, cell_type="all", timeout=600,
                                                     interval=30)
        self.verify_internal_neighbouring_gnb_object(bts_id=bts_id, du_id=du_id, wait_for_x2_availability=True)
        self.gnb_alarm.verify_alarm_is_not_active(
            fault_name="LNADJGNB for the SBTS EN-DC gNB neighbor could not be created", fault_id="5518", bts_id=bts_id,
            du_id=du_id)

    def _check_if_cells_are_degraded(self, technology="nr", bts_id=0, du_id=0):
        self.gnb_cell.verify_all_cells_statuses(bts_id=bts_id, du_id=du_id, cell_type=technology,
                                                availability_status="degraded")

    @staticmethod
    def get_plmn_delta(plmn_param_name, plmn_param_value):
        plmn_distnames = ["MRBTS-{}/NRBTS-{}", "MRBTS-{}/NRBTS-{}/NRPLMN-1"]
        delta = []
        for distname in plmn_distnames:
            delta_pattern = {
                "distName": distname,
                "operation": "update",
                "parameters": [
                    {
                        "operation": "update",
                        "parameterName": plmn_param_name,
                        "value": plmn_param_value
                    }]}
            delta.append(delta_pattern)
        return delta

    def modify_public_land_mobile_network(self, mcc="1", mnc="1", mnc_length="2", timeout=1500, bts_id=0, du_id=0):
        plmn = {"mcc": mcc,
                "mnc": mnc,
                "mncLength": mnc_length}
        delta_plmn = []
        for param, value in plmn.items():
            sub_delta = self.get_plmn_delta(plmn_param_name=param, plmn_param_value=value)
            delta_plmn.extend(sub_delta)
        self.gnb_alarm.allow_alarm(alarm=self.alarm_ng_gnb_reset, bts_id=bts_id, du_id=du_id)
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta_plmn, bts_id=bts_id, du_id=du_id, timeout=timeout)
        self.gnb_du.wait_for_site_to_be_onair(bts_id=bts_id, du_id=du_id)
        self.gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id, cell_type="all", timeout=timeout,
                                                     interval=30)

    def modify_plmn_and_check_automatic_neighbouring_gnb_addition(self, mcc="244", mnc="8", mnc_length="2",
                                                                  bts_id=0, du_id=0):
        self.modify_public_land_mobile_network(mcc=mcc, mnc=mnc, mnc_length=mnc_length, bts_id=bts_id, du_id=du_id)
        self.verify_internal_neighbouring_gnb_object(bts_id=bts_id, du_id=du_id, wait_for_x2_availability=True)
        self.gnb_alarm.verify_alarm_is_not_active(
            fault_name="LNADJGNB for the SBTS EN-DC gNB neighbor could not be created", fault_id="5518", bts_id=bts_id,
            du_id=du_id)

    def modify_gnb_id_length(self, bts_id=0, du_id=0, gnb_id_length=22, timeout=900):
        delta = [{
            "distName": "MRBTS-{}/NRBTS-{}",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "gNbIdLength",
                    "value": "{}".format(gnb_id_length)
                }]}]
        self.gnb_alarm.allow_alarm(alarm=self.alarm_ng_gnb_reset, bts_id=bts_id, du_id=du_id)
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, du_id=du_id)
        self.gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id, cell_type="all", timeout=timeout,
                                                     interval=30)

    def modify_gnb_id_length_and_check_automatic_neighbouring_gnb_addition(self, bts_id=0, du_id=0, gnb_id_length=22,
                                                                           timeout=900):
        self.modify_gnb_id_length(bts_id=bts_id, du_id=du_id, gnb_id_length=gnb_id_length, timeout=timeout)
        self.verify_internal_neighbouring_gnb_object(bts_id=bts_id, du_id=du_id, wait_for_x2_availability=True)

    def update_gnb_black_list_in_anr(self, operation="add_internal_gnb", bts_id=0, du_id=0):
        nrbts_id = self.tl.gnbs[bts_id].global_bts_id
        nrbts_plmn = self._get_nrbts_plmn(bts_id, du_id)
        delta_black_list = [{
            "distName": "MRBTS-{}/LNBTS-{}/ANR-0",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update" if operation == "add_internal_gnb" else "delete",
                    "parameterName": "glNbGnbIdBlackList",
                    "value":
                        [{
                            "gnbId": nrbts_id,
                            "gnbIdRange": "1",
                            "mcc": nrbts_plmn["mcc"],
                            "mnc": nrbts_plmn["mnc"],
                            "mncLength": nrbts_plmn["mncLength"]
                        }]
                }]}]
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta_black_list, bts_id=bts_id, du_id=du_id)

    def enable_feature_flag_and_check_automatic_neighbouring_gnb_addition(self, wait_for_x2_availability=False,
                                                                          cplane_control="enbControlled",
                                                                          bts_id=0, du_id=0):
        self.set_cb009408_feature_flag(operation="enable", gnb_id=bts_id)
        self.verify_internal_neighbouring_gnb_object(wait_for_x2_availability=wait_for_x2_availability,
                                                     cplane_control=cplane_control, bts_id=bts_id, du_id=du_id)
        self.gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id, cell_type="all", timeout=120,
                                                     interval=30)
        self.gnb_alarm.verify_alarm_is_not_active(
            fault_name="LNADJGNB for the SBTS EN-DC gNB neighbor could not be created", fault_id="5518", bts_id=bts_id,
            du_id=du_id)

    def enable_feature_flag_and_check_if_automatic_neighbouring_gnb_addition_not_triggered(self, bts_id=0, du_id=0):
        self.set_cb009408_feature_flag(operation="enable", gnb_id=bts_id)
        self.verify_if_internal_neighbouring_gnb_object_not_exist(bts_id=bts_id, du_id=du_id)

    def disable_feature_flag_and_verify_lte_cells_setup(self, bts_id=0, du_id=0):
        self.set_cb009408_feature_flag(operation="disable", gnb_id=bts_id)
        self.gnb_alarm.allow_alarm(alarm=self.alarms_no_internal_lnadjgnb, bts_id=bts_id, du_id=du_id)
        self.remove_all_neighbouring_gnb(bts_id=bts_id, du_id=du_id)
        self.remove_lte_neighbor_relation_to_cells(bts_id=bts_id, du_id=du_id)
        self.gnb_cell.verify_all_cells_are_onair(bts_id=bts_id, du_id=du_id, cell_type="lte")

    def disable_feature_flag_and_remove_neighbouring_gnb_and_relation_to_cells(self, bts_id=0, du_id=0):
        self.set_cb009408_feature_flag(operation="disable", gnb_id=bts_id)
        self.gnb_alarm.allow_alarm(alarm=self.alarms_no_internal_lnadjgnb, bts_id=bts_id, du_id=du_id)
        self.remove_lte_neighbor_relation_to_cells(bts_id=bts_id, du_id=du_id)
        self.remove_all_neighbouring_gnb(bts_id=bts_id, du_id=du_id)

    def clear_neighbors_switch_feature_flag_and_wait_for_all_cells_setup(self, bts_id=0, du_id=0):
        self.remove_lte_neighbor_relation_to_cells(bts_id=bts_id, du_id=du_id)
        self.remove_all_neighbouring_gnb(bts_id=bts_id, du_id=du_id)
        self.set_cb009408_feature_flag(operation="disable", gnb_id=bts_id)
        self.set_cb009408_feature_flag(operation="enable", gnb_id=bts_id)
        self.gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id, cell_type="all", timeout=120,
                                                     interval=30)

    def enable_feature_flag_and_catch_fault_5518_5515(self, bts_id=0, du_id=0):
        self.gnb_alarm.allow_alarm(
            alarm=self.alarms_could_not_create_lnadjgnb + self.alarms_maximum_lnadjgnbs_exceeded,
            bts_id=bts_id, du_id=du_id)
        self.set_cb009408_feature_flag(operation="enable", gnb_id=bts_id)
        self.wait_for_fault_activation(fault_name="LNADJGNB for the SBTS EN-DC gNB neighbor could not be created",
                                       fault_id="5518", max_retry=12, interval=5, bts_id=bts_id, du_id=du_id)
        self.wait_for_fault_activation(fault_name="Maximum number of EN-DC neighbor gNBs is exceeded",
                                       fault_id="5515", max_retry=12, interval=5, bts_id=bts_id, du_id=du_id)
        self.verify_if_internal_neighbouring_gnb_object_not_exist(bts_id=0, du_id=0)

    def load_neighbouring_gnbs_objects(self, number_of_objects=32, bts_id=0, du_id=0):
        self.gnb_alarm.allow_alarm(alarm=self.alarm_failed_x2, bts_id=bts_id, du_id=du_id)
        self.create_multiple_neighbouring_gnb_objects(range_of_neighbours=int(number_of_objects), location="76",
                                                      bts_id=bts_id, du_id=du_id)
        self.verify_if_internal_neighbouring_gnb_object_not_exist(bts_id=0, du_id=0)

    def remove_neighbouring_gnb_object(self, neighbour_id, bts_id=0, du_id=0):
        pattern_neighbour = [{
            "distName": "MRBTS-{}/LNBTS-{}/LNADJGNB-{}".format("{}", "{}", neighbour_id),
            "operation": "delete",
            "parameters": []
        }]
        self.gnb_scf.perform_bts_delta_commissioning(delta=pattern_neighbour, bts_id=bts_id, du_id=du_id)

    def wait_for_fault_activation(self, fault_name, fault_id, max_retry=30, interval=3, bts_id=0, du_id=0):
        if max_retry > 0:
            try:
                self.gnb_alarm.verify_alarm_is_active(fault_name=fault_name, fault_id=fault_id, bts_id=bts_id,
                                                      du_id=du_id)
            except (AlarmIsNotActive, AdminApiNoResponseException):
                logging.info("Fault '{}: {}' is not active. Wait '{}'s for next status check attempt"
                             "".format(fault_id, fault_name, interval))
                time.sleep(interval)
                self.wait_for_fault_activation(fault_name, fault_id, max_retry=max_retry - 1, interval=interval,
                                               bts_id=bts_id, du_id=du_id)
            else:
                logging.info("Success! Fault '{}: {}' is active.".format(fault_id, fault_name))
        elif max_retry == 0 and str(fault_id) == "5515":
            logging.warning("Fault '{}: {}' activation timeout exceeded. Check if there is any major or critical"
                            " fault which suppress it".format(fault_id, fault_name))
        else:
            raise Exception("Failed. Fault '{}: {}' activation timeout exceeded".format(fault_id, fault_name))

    def check_fault_activation(self, fault_name, fault_id, bts_id=0, du_id=0):
        self.gnb_alarm.verify_alarm_is_active(fault_name=fault_name, fault_id=fault_id, bts_id=bts_id,
                                              du_id=du_id)

    def increase_max_x2_links(self, operation="enable"):
        self.gnb_scf.perform_configuration_parameter_recommissioning(
            dist_name="MRBTS-{}/LNBTS-{}",
            parameter="actX2gNB128",
            operation='update',
            value='true' if operation.lower() == 'enable' else 'false')

    def load_nr_cell_configuration(self, cell_type="SA", bts_id=0, du_id=0):
        cell_ids = self.gnb_cell.get_all_cells_id(bts_id=bts_id, du_id=du_id, ru_id=None, cell_type="nr")
        delta = [{
            "distName": "MRBTS-{}/NRBTS-{}",
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "gNbCuType",
                    "value": "{}".format(cell_type.upper())
                }
            ]}]
        for cell_id in cell_ids:
            delta_cell = self.get_cell_type_change_pattern(cell_id, cell_type)
            delta.append(delta_cell)
        delta.append(self.set_sleeping_cell_detection(cell_type=cell_type))
        self.gnb_alarm.allow_alarm(alarm=self.alarm_ng_gnb_reset, bts_id=bts_id, du_id=du_id)
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id, du_id=du_id)
        self.gnb_du.wait_for_site_to_be_onair(bts_id=bts_id, du_id=du_id, timeout=900, interval=30)
        self.gnb_cell.wait_for_all_cells_to_be_onair(bts_id=bts_id, du_id=du_id, cell_type="all", timeout=600,
                                                     interval=30)

    def create_multiple_neighbouring_gnb_objects(self, range_of_neighbours=32, location="77", bts_id=0, du_id=0,
                                                 timeout=600):
        self.increase_max_x2_links(operation="enable" if int(range_of_neighbours) > 32 else "disable")
        delta_neighbours = [self.get_neighbour_pattern(lnadjgnb_id=neighbour, location=location) for neighbour in
                            range(range_of_neighbours)]
        self.gnb_scf.perform_bts_delta_commissioning(delta=delta_neighbours, bts_id=bts_id, du_id=du_id,
                                                     timeout=timeout)

    def create_custom_neighbouring_gnb_object(self, lnadjgnb_id=0, gnb_id=None, cplane_ctrl="oamControlled",
                                              cplane_addr=None, plmn=None, gnb_id_length=22, mcc=1, mnc=1,
                                              mnc_length=2, bts_id=0, du_id=0):
        self.gnb_alarm.allow_alarm(alarm=self.alarm_failed_x2 + self.alarms_no_internal_lnadjgnb, bts_id=bts_id,
                                   du_id=du_id)
        if cplane_addr == "internal":
            cplane_addr = self.get_x2cplane_addr(bts_id=bts_id, du_id=du_id)
        if plmn == "internal":
            internal_plmn = self._get_nrbts_plmn(bts_id=bts_id, du_id=du_id)
            mcc = internal_plmn["mcc"]
            mnc = internal_plmn["mnc"]
            mnc_length = internal_plmn["mncLength"]
        if gnb_id_length == "internal":
            gnb_id_length = self._get_gnb_id_length(bts_id=bts_id, du_id=du_id)
        neighbour = [self.get_neighbour_pattern(
            lnadjgnb_id=lnadjgnb_id, gnb_id=gnb_id, cplane_ctrl=cplane_ctrl, cplane_addr=cplane_addr,
            gnb_id_length=gnb_id_length, mcc=mcc, mnc=mnc, mnc_length=mnc_length)]
        self.gnb_scf.perform_bts_delta_commissioning(delta=neighbour, bts_id=bts_id, du_id=du_id)

    def create_custom_lte_neighbour_relation_to_cell(self, lnrelgnbcell_id=255, lncell_id=115, nr_cell_id=1263124591,
                                                     plmn=None, gnb_id_length=22, mcc=1, mnc=1, mnc_length=2, bts_id=0,
                                                     du_id=0):
        if plmn == "internal":
            internal_plmn = self._get_nrbts_plmn(bts_id=bts_id, du_id=du_id)
            mcc = internal_plmn["mcc"]
            mnc = internal_plmn["mnc"]
            mnc_length = internal_plmn["mncLength"]
        if gnb_id_length == "internal":
            gnb_id_length = self._get_gnb_id_length(bts_id=bts_id, du_id=du_id)
        self.gnb_scf.perform_bts_delta_commissioning(
            delta=self.get_neighbour_relation_to_cell_pattern(
                lnrelgnbcell_id=lnrelgnbcell_id, lncell_id=lncell_id, nr_cell_id=nr_cell_id,
                gnb_id_length=gnb_id_length, mcc=mcc, mnc=mnc, mnc_length=mnc_length), bts_id=bts_id, du_id=du_id)

    def set_attenuation(self, attenuation_values, port_identifiers=None):
        attenuator_cfg = {
            "port_identifiers": port_identifiers if port_identifiers else list(
                self.tl.attenuator.attenuation_port_numbers),
            "attenuation_values": attenuation_values}
        self.ue_operations.set_attenuation(attenuator_cfg)

    @staticmethod
    def get_cell_type_change_pattern(cell_id, cell_type):
        delta_cell = {
            "distName": "MRBTS-{}/NRBTS-{}/NRCELL-{}".format("{}", "{}", cell_id),
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "cellDepType",
                    "value": "{}".format(cell_type)
                },
                {
                    "operation": "update",
                    "parameterName": "actSib1ForNsaCell",
                    "value": "false" if cell_type == "SA" else "true"
                },
                {
                    "operation": "delete" if cell_type == "SA" else "update",
                    "parameterName": "configuredEpsTac",
                    "value": [] if cell_type == "SA" else "1"
                },
            ]}
        return delta_cell

    @staticmethod
    def set_sleeping_cell_detection(cell_type, mnl_id="1", mnlent_id="1", featcadm_id="1"):
        scell_value = "false" if cell_type == "SA" else "true"
        delta_sleeping_cell = {
            "distName": "MRBTS-{}/MNL-{}/MNLENT-{}/FEATCADM-{}".format("{}", mnl_id, mnlent_id, featcadm_id),
            "operation": "update",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "actNrAutSgnbAddCplSlCellDetRec",
                    "value": scell_value
                },
                {
                    "operation": "update",
                    "parameterName": "actNrAutUeCtxStpRtSlCellDetRec",
                    "value": scell_value
                },
                {
                    "operation": "update",
                    "parameterName": "actNrAutDegAdmCtrlSlCellDetRec",
                    "value": scell_value
                },
            ]}
        return delta_sleeping_cell

    @staticmethod
    def get_neighbour_pattern(lnadjgnb_id, gnb_id=None, cplane_ctrl="oamControlled", cplane_addr=None,
                              gnb_id_length=22, mcc=1, mnc=1, mnc_length=2, location="77"):
        pattern_neighbour = {
            "distName": "MRBTS-{}/LNBTS-{}/LNADJGNB-{}".format("{}", "{}", lnadjgnb_id),
            "operation": "create",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "adjGnbId",
                    "value": "{}".format(gnb_id) if gnb_id else "{}{:03d}".format(location, int(lnadjgnb_id))
                },
                {
                    "operation": "update",
                    "parameterName": "adjGnbIdLength",
                    "value": "{}".format(gnb_id_length)
                },
                {
                    "operation": "update",
                    "parameterName": "administrativeState",
                    "value": "unlocked"
                },
                {
                    "operation": "update",
                    "parameterName": "cPlaneIpAddr",
                    "value": "{}".format(cplane_addr) if cplane_addr else "1.1.1.{:d}".format(lnadjgnb_id)
                },
                {
                    "operation": "update",
                    "parameterName": "cPlaneIpAddrCtrl",
                    "value": "{}".format(cplane_ctrl)
                },
                {
                    "operation": "update",
                    "parameterName": "plmnId",
                    "value":
                        [{
                            "mcc": "{}".format(mcc),
                            "mnc": "{}".format(mnc),
                            "mncLength": "{}".format(mnc_length)
                        }]
                },
            ]}
        return pattern_neighbour

    @staticmethod
    def get_neighbour_relation_to_cell_pattern(lnrelgnbcell_id, lncell_id, nr_cell_id, gnb_id_length=22, mcc=1, mnc=1,
                                               mnc_length=2):
        pattern_relation = [{
            "distName": "MRBTS-{}/LNBTS-{}/LNCEL-{}/LNRELGNBCELL-{}".format("{}", "{}", lncell_id, lnrelgnbcell_id),
            "operation": "create",
            "parameters": [
                {
                    "operation": "update",
                    "parameterName": "gnbIdLength",
                    "value": "{}".format(gnb_id_length)
                },
                {
                    "operation": "update",
                    "parameterName": "lteNrDualConnectAllowed",
                    "value": "allowed"
                },
                {
                    "operation": "update",
                    "parameterName": "nrCellId",
                    "value": "{}".format(nr_cell_id)
                },
                {
                    "operation": "update",
                    "parameterName": "nrCgiPlmnId",
                    "value":
                        [{
                            "mcc": "{}".format(mcc),
                            "mnc": "{}".format(mnc),
                            "mncLength": "{}".format(mnc_length)
                        }]
                },
                {
                    "operation": "update",
                    "parameterName": "removeAllowed",
                    "value": "true"
                },
            ]}]
        return pattern_relation

    def check_if_internal_nr_cells_exists_in_lte_neighbor_relations(self, bts_id=0, du_id=0):
        internal_nr_cells = self._get_internal_nr_cells_identity(bts_id=bts_id, du_id=du_id)
        lnrelgnbcells = self.get_lnrelgnbcell_from_configuration()
        if lnrelgnbcells:
            relation_to_internal_cells = [lnrel if lnrel['params']['nrCellId'] in internal_nr_cells else None for lnrel
                                          in lnrelgnbcells]
            if any(relation_to_internal_cells):
                logging.info("Success! Found LNRELGNBCELL objects related to internal gNB NR cells '{}': "
                             "'{}'".format(internal_nr_cells, [relation for relation in relation_to_internal_cells if
                                                               relation is not None]))
            else:
                raise NotFoundLteNeighborRelationException(
                    "Not found LNRELGNBCELL object related to any internal gNB NR cell '{}' "
                    "among existing objects: '{}'".format(internal_nr_cells, lnrelgnbcells))
        else:
            raise NotFoundLteNeighborRelationException("Not found LNRELGNBCELL in current BTS runtime configuration")

    def _get_internal_nr_cells_identity(self, bts_id=0, du_id=0):
        cell_ids = []
        cells = self.gnb_cell.get_all_cells_id(cell_type="nr", bts_id=bts_id, du_id=du_id)
        for cell in cells:
            cell_id = self.gnb_cell.get_cell_parameters(bts_id=bts_id, cell_id=cell, du_id=du_id)['nrCellIdentity']
            cell_ids.append(cell_id)
        return cell_ids

    @staticmethod
    def _file_reader(filename):
        with open(filename, 'r') as f:
            file = f.read()
            return file


class NotFoundLteNeighborRelationException(Exception):
    pass
