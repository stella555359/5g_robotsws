import logging
import re
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from taf.rfrl.utilities.tl_config import tl
from taf.ul.moler.converter import add_unix_remote_device_to_already_loaded_configuration
from moler.device import DeviceFactory
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
import json
import io
from testsuite.Krakow.SISO.regression.RAN_PZ_KRK3.CB011058.resources.validation_exeptions import \
    DifferentNumberOfValidationErrorsException, ScfRamlErrorsDoNotMatchException


class BtsHelper(GnbDuOperations):
    scf = GnbCommissioning()
    vm_user = tl.test_pcs[0].default_ssh_connection_details.username
    vm_pass = tl.test_pcs[0].default_ssh_connection_details.password
    vm_addr = tl.test_pcs[0].default_ssh_connection_details.addr
    vm_tmp_dir = "/tmp"
    artifactory_url = "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local" \
                      "/build"

    @staticmethod
    def get_vm_as_device(device_name, device_addr, device_user, device_pass):
        try:
            device = DeviceFactory.get_device(name=device_name)
        except KeyError:
            add_unix_remote_device_to_already_loaded_configuration(
                device_name=device_name,
                host=device_addr,
                login=device_user,
                password=device_pass
            )
            device = DeviceFactory.get_device(name=device_name)
        return device

    @load_moler_configuration_from_tl()
    def get_tl_vm_as_device(self):
        return self.get_vm_as_device(device_name='UnixLocal', device_addr=self.vm_addr, device_user=self.vm_user,
                                     device_pass=self.vm_pass)

    def get_current_sw_release(self):
        """
        Get current SW release for BTS
        :return: SW release version (i.e. SBTS00)
        """
        sw_version = self.get_bts_sw_version()
        sw_release = SbtsSwVersion(sw_version).release
        return sw_release

    @staticmethod
    def get_pdl_plugin_name(sw_version):
        pdl_plugin_name = f"{sw_version}_pdl_validation_service_plugin.zip"
        return pdl_plugin_name

    def get_pdl_plugin_url(self):
        sw_release = self.get_current_sw_release()
        sw_version = self.get_bts_sw_version()
        sw_build = f"{sw_release}_{sw_version[-22:]}"
        pdl_plugin_name = self.get_pdl_plugin_name(sw_version=sw_version)
        pdl_plugin_url = f"{self.artifactory_url}/{sw_release}/{sw_build}/{pdl_plugin_name}"
        return pdl_plugin_url, pdl_plugin_name

    def download_pdl_plugin(self):
        vm = self.get_tl_vm_as_device()
        pdl_plugin_url, pdl_plugin_name = self.get_pdl_plugin_url()
        wget_cmd_options = f"{pdl_plugin_url} -o {self.vm_tmp_dir}/{pdl_plugin_name}"
        download_pdl_plugin = vm.get_cmd(cmd_name='wget', cmd_params={'options': wget_cmd_options})
        download_pdl_plugin()
        return pdl_plugin_name

    def prepare_sw_package_with_pdl_plugin(self):
        vm = self.get_tl_vm_as_device()
        sw_version = self.get_bts_sw_version()
        pdl_plugin_name = self.get_pdl_plugin_name(sw_version=sw_version)
        zip_pdl_plugin = vm.get_cmd(cmd_name='zip', cmd_params={'options': "", 'file_name': pdl_plugin_name,
                                                                'zip_file': f"{self.vm_tmp_dir}/{sw_version}"})
        zip_pdl_plugin()
        sw_package_path = f"{self.vm_tmp_dir}/{sw_version}.zip"
        return sw_package_path

    def get_scf_validation_errors(self, validation_output):
        validation_errors = dict()
        validation_errors_json = self._get_scf_validation_result_as_json_from_output(output=validation_output)
        validation_errors.update(
            {"relationErrors": validation_errors_json['pdlValidationResult']['logs']['relationErrors']})
        validation_errors.update(
            {"hardwareErrors": validation_errors_json['pdlValidationResult']['logs']['hardwareErrors']})
        logging.info(f"Validation errors:\n{validation_errors}")
        return validation_errors

    @staticmethod
    def get_list_of_scf_validation_errors(validation_errors):
        validation_errors_list = list()
        relation_errors = validation_errors["relationErrors"]
        hardware_errors = validation_errors["hardwareErrors"]
        for rel_error in relation_errors:
            rel_error_str = rel_error["feedback"]
            rel_error_str = rel_error_str.replace("${", "")
            rel_error_str = rel_error_str.replace("}", "")
            validation_errors_list.append(rel_error_str)
        for hw_error in hardware_errors:
            hw_error_str = hw_error["feedback"]
            hw_error_str = hw_error_str.replace("${", "")
            hw_error_str = hw_error_str.replace("}", "")
            validation_errors_list.append(hw_error_str)
        return validation_errors_list

    @staticmethod
    def _get_scf_validation_result_as_json_from_output(output):
        logging.info(f"SCF Validation response from WebEM:\n{output}")
        output = output[1]
        result_json_style = output.split("Status reached: ")[1][:-15]
        result_json_style = rf'{result_json_style}'
        str_to_modify_start = [m.start() for m in re.finditer(': \"', result_json_style)]
        str_to_modify_end = [m.start() for m in re.finditer('\",', result_json_style)]
        for i in range(0, len(str_to_modify_start)):
            str_to_switch1 = result_json_style[str_to_modify_start[i]: str_to_modify_end[i]]
            str_to_switch2 = str_to_switch1.replace("'", "*")
            result_json_style = result_json_style.replace(str_to_switch1, str_to_switch2)
        result_json_style = result_json_style.replace("'", "\"")
        result_json_style = result_json_style.replace("None", "\"None\"")
        validation_json = json.loads(result_json_style)
        return validation_json

    def save_active_bts_config(self):
        sw_version = self.get_bts_sw_version()
        gnb_id = tl.gnbs[0].global_bts_id
        scf_file = f"SCF_MRBTS-{gnb_id}_{sw_version}-OK.xml"
        scf_path = self.get_bts_configuration_file(filename=scf_file)
        return scf_path

    def _copy_and_rename_scf(self, scf_path):
        vm = self.get_tl_vm_as_device()
        scf_err_path = f"{scf_path[:-7]}-FAIL.xml"
        copy_and_rename_scf = vm.get_cmd(cmd_name='cp', cmd_params={'src': scf_path, 'dst': scf_err_path})
        copy_and_rename_scf()
        return scf_err_path

    def create_invalid_scf(self, scf_path):
        cablink5_id = 4
        scf_err_list = list()
        scf_err_path = self._copy_and_rename_scf(scf_path=scf_path)
        with open(scf_err_path, 'r') as scf:
            cablink_id = 1
            scf_lines = scf.readlines()
            for line in scf_lines:
                scf_err_list.append(line)
                if line.__contains__("radioProtocolType"):
                    if cablink_id == cablink5_id:
                        cablink5_line_num = scf_lines.index(line)
                        scf_err_list[cablink5_line_num] = scf_err_list[cablink5_line_num].replace("eCPRI", "OBSAI")
                    else:
                        cablink_id += 1
        with open(scf_err_path, 'w') as scf_err:
            scf_err.writelines(scf_err_list)
        return scf_err_path

    @staticmethod
    def get_scf_name(scf_path):
        scf_name = scf_path.split("/")[-1]
        return scf_name

    @staticmethod
    def prepare_raml_name(scf_name):
        raml_name = f"RAML_{scf_name[4:]}"
        return raml_name

    @staticmethod
    def get_last_operation_id(last_operation):
        last_operation = last_operation.split(":")[1][1:-5]
        return last_operation

    @staticmethod
    def get_raml_validation_errors(validation_feedback):
        validation_errors = list()
        with io.StringIO(validation_feedback) as feedback:
            for line in feedback:
                if line.__contains__("ERROR TEXT"):
                    validation_errors.append(line.strip())
        return validation_errors

    @staticmethod
    def get_list_of_raml_validation_errors(validation_errors):
        validation_errors_list = list()
        for error in validation_errors:
            error_json = json.loads(error[19:])
            validation_errors_list.append(error_json["Text"])
        return validation_errors_list

    @staticmethod
    def compare_scf_ram_validation_errors(scf_errors, raml_errors):
        logging.info(f"SCF validation errors:\n{scf_errors}")
        logging.info(f"RAML validation errors:\n{raml_errors}")
        errors_not_match = list()
        if len(scf_errors) != len(raml_errors):
            raise DifferentNumberOfValidationErrorsException(f"Number of SCF [{len(scf_errors)}] and RAML "
                                                             f"[{len(raml_errors)}] validation errors don't match.")
        for scf_err in scf_errors:
            if scf_err not in raml_errors:
                errors_not_match.append(scf_err)
        if len(errors_not_match) > 0:
            raise ScfRamlErrorsDoNotMatchException(f"SCF validation errors: \n{errors_not_match} \nnot found in RAML "
                                                   "validation errors")
        logging.info("SCF validation errors and RAML validation errors are identical")
