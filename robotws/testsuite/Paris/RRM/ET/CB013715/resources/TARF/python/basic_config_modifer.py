from taf.config.wts import wts
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.ue.ue_group import SA_UE_START, NSA_UE_START
from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python import wts_ue

from testsuite.Paris.RRM.ET.CB013715.resources.TARF.python.logger import logging, logger
import re

DEFAULT_SA_UE_START = 1
DEFAULT_NSA_UE_START = 101


class Modifier:
    @logger
    def __init__(self, path_to_basic_cfg, modified_file_path, scenario_parser):
        self.wtsobj = wts()
        self.scenario_parser = scenario_parser
        self.default_nsa_ue_nr_capabilities = None
        self.default_ue_nr_capabilities = None
        self.sa_ue_id_start = SA_UE_START
        self.nsa_ue_id_start = NSA_UE_START
        self.path_to_basic_cfg = path_to_basic_cfg
        self.modified_file_path = modified_file_path

    @logger
    def initialize_basic_config_file(self):
        self.align_basic_cfg_file()
        self.basic_cfg_reference_nsa_ue, self.basic_cfg_reference_sa_ue = self.get_default_nsa_sa_ue_ids()
        self._get_default_ue_capability()
        self._delete_additionally_predefined_sansa_ues()
        self._change_nsa_ue_id_in_reference_file(new_nsa_ue_id=self.nsa_ue_id_start)

    @logger
    def align_basic_cfg_file(self):
        """This is a workaround to align the basic config of certain files
        where PDN_IP1 and PDN_IP2 are used in contrast to the basic config file where
        only one PDN_IP us defined"""
        """ Look for set PDN_IP1 and replace it with set PDN_IP"""
        set_commands = self.wtsobj.find_all("set")
        set_pdn_ip_commands = []
        for command in set_commands:
            if "PDN_IP101" in command:
                set_pdn_ip_commands.append(command)
                self.wtsobj.insert(command.replace("PDN_IP101", "PDN_IP"), "after", "set PGW_ADDR=\"4.7.254.207\"")
                self.wtsobj.delete(command)
                try:
                    pdn_ip_uses = self.wtsobj.find_all_by_parameter("ip", "ip=$PDN_IP101")
                    self.wtsobj.modify(pdn_ip_uses[0], "ip=$PDN_IP")
                except IndexError:
                    logging.info("No commands found with variable name $PDN_IP")
                    break
            if "PDN_IP1" in command:
                set_pdn_ip_commands.append(command)
                self.wtsobj.insert(command.replace("PDN_IP1", "PDN_IP"), "after", "set PGW_ADDR=\"4.7.254.207\"")
                self.wtsobj.delete(command)
                try:
                    pdn_ip_uses = self.wtsobj.find_all_by_parameter("ip", "ip=$PDN_IP1")
                    self.wtsobj.modify(pdn_ip_uses[0], "ip=$PDN_IP")
                except IndexError:
                    logging.info("No commands found with variable name $PDN_IP")
        """ Look for PDN_IP1 usage in other commands and replace it with set PDN_IP"""

    @logger
    def configure_ues(self):
        print("Configuring UEs in Basic Config File")
        for scenario_name, scenario_object in self.scenario_parser.scenarios.items():
            for ue_collection in scenario_object.ue_groups:
                if ue_collection.configured_sa_ues:
                    self.configure_sa_ues_to_cells_in_basic_cfg(ue_collection.get_configuration_parameters(True))
                elif ue_collection.configured_nsa_ues:
                    self.configure_nsa_ues_in_basic_cfg(ue_collection.get_configuration_parameters(True))
                else:
                    print("No UEs configured in Scenario", scenario_name)

    @logger
    def configure_new_cells(self):
        reference_command, to_be_configured_cells = self._identify_missing_nr_cell_instances()
        to_be_configured_cells.sort()
        for cell_itr, item in enumerate(to_be_configured_cells):
            params_to_be_modified = self._generate_parms_for_new_cell(
                reference_command, cell_itr)
            str_param_to_be_modified = self._generate_string_from_args(
                params_to_be_modified)
            str_param_to_be_modified = str_param_to_be_modified + \
                str(' id=%s' % item)
            self.wtsobj.clone_and_modify(reference_command, str_param_to_be_modified, 'after',
                                         str('set_cell id=%s' % (int(item)-1)))

    @logger
    def load_basic_cfg(self):
        self.wtsobj.load_wts_cfg(self.path_to_basic_cfg)

    @logger
    def save_modified_basic_cfg(self):
        self.wtsobj.save_wts_cfg(file_path=self.modified_file_path)

    @logger
    def get_default_nsa_sa_ue_ids(self):
        nsa_ue_id = self.wtsobj.find_all_by_parameter(parameter="id", parameter_filter="dual_conn=eutra_nr")
        sa_ue_id = self.wtsobj.find_all_by_parameter(parameter="id", parameter_filter="mode=nr")
        nsa_ue_ids = []
        sa_ue_ids = []
        for item_nsa in nsa_ue_id:
            ue_id_nsa = re.search(r"(id=)(\d+)", item_nsa)
            nsa_ue_ids.append(int(ue_id_nsa.groups()[1]))
        for item_sa in sa_ue_id:
            ue_id_sa = re.search(r"(id=)(\d+)", item_sa)
            sa_ue_ids.append(int(ue_id_sa.groups()[1]))
        nsa_ue_ids.sort(), sa_ue_ids.sort()
        if not sa_ue_ids:
            logging.warning("It seems like you have a NSA Testline")
            return nsa_ue_ids[0], 0
        elif not nsa_ue_ids:
            logging.warning("It seems like you have a SA Testline")
            return 0, sa_ue_ids[0]
        elif nsa_ue_ids and sa_ue_ids:
            logging.info("Detected SANSA Testline.")
        else:
            if DEFAULT_SA_UE_START != sa_ue_ids[0] or DEFAULT_NSA_UE_START != nsa_ue_ids[0]:
                logging.warning("It seems like the default basic_cfg file was not restored before the test execution,"
                                " perhaps the previous test was stopped abruptly or the default basic_cfg file has been"
                                " changed. The template will try to adapt the basic_cfg file to your test but accuracy "
                                "cannot be guaranteed. Please review the basic_cfg file generated manually!")
        return (nsa_ue_ids[0], sa_ue_ids[0])

    @logger
    def configure_nsa_ues_in_basic_cfg(self, ue_parameters):
        """Configures required NSA UEs in the basic config file"""
        pdn = self.wtsobj.get_parameter(command='set', parameter='PDN_IP')
        octetList = list(re.findall(r"(\d+).(\d+).(\d+).(\d+)", pdn)[0])
        octetList[-1] = str(int(octetList[-1])-100) if int(octetList[-1]) > 100 else octetList[-1]
        pdn = ".".join(octetList)
        imsi = self.wtsobj.get_parameter(command=str("set_ue simulated id=%s" % self.nsa_ue_id_start),
                                         parameter='imsi')
        logging.info("Reference PDN IP: %s" % pdn)
        logging.info("Reference IMSI IP: %s" % imsi)
        for nsa_ue, ue_param in ue_parameters.items():
            new_imsi = wts_ue.obtain_new_imsi(ue_id=nsa_ue, imsi_extract=imsi)
            new_ip = wts_ue.obtain_new_ip(ue_id=nsa_ue, wts_extract=pdn)
            ue_cap = ue_param['nr_ue_cap']
            ue_eutra_nr_capabilities = ue_param['ue_eutra_nr_capabilities']
            if not ue_cap:
                ue_cap = self.default_nsa_ue_nr_capabilities
            if not ue_eutra_nr_capabilities:
                ue_eutra_nr_capabilities = self.default_ue_eutra_nr_capabilities
            bearer = ue_param['bearer']
            if self.nsa_ue_id_start == nsa_ue:
                self.wtsobj.modify(command=str('set_ue simulated id=%s' % nsa_ue),
                                   modification=str("id=%s" % nsa_ue) + " " + str("imsi=%s" % new_imsi))
                self.wtsobj.modify(command=str("ue_param id=%s" % self.nsa_ue_id_start),
                                   modification=str("id=%s ue_nr_capabilities=%s ue_eutra_nr_capabilities=%s" %
                                                    (nsa_ue, ue_cap, ue_eutra_nr_capabilities)))
                self.wtsobj.modify(command=str("set_bearer id=2 ue=%s" % self.nsa_ue_id_start),
                                   modification=str("id=%s ue=%s ip=%s" % (bearer, nsa_ue, new_ip)))
            else:
                self.wtsobj.delete(command=str("set_ue simulated id=%s" % nsa_ue))
                self.wtsobj.delete(command=str("ue_param id=%s" % nsa_ue))
                self.wtsobj.delete(command=str("set_bearer id=%s ue=%s" % (bearer, nsa_ue)))
                self.wtsobj.clone_and_modify(command=str("set_ue simulated id=%s" % self.nsa_ue_id_start),
                                             modification=str("id=%s" % nsa_ue) + " " + str("imsi=%s" % new_imsi),
                                             location='after',
                                             reference=str("ue_param id=%s" % self.nsa_ue_id_start))
                self.wtsobj.clone_and_modify(command=str("ue_param id=%s" % self.nsa_ue_id_start),
                                             modification=f"id={nsa_ue} ue_nr_capabilities={ue_cap} "
                                                          f"ue_eutra_nr_capabilities={ue_eutra_nr_capabilities}",
                                             location='after', reference=str("set_ue simulated id=%s" % nsa_ue))
                self.wtsobj.clone_and_modify(command=str("set_bearer id=2 ue=%s" % self.nsa_ue_id_start),
                                             modification=str("id=%s ue=%s ip=%s" % (bearer, nsa_ue, new_ip)),
                                             location='after',
                                             reference=str("set_bearer"))

            logging.info("Configuring NSA UE id: %s with PDN IP: %s and IMSI: %s" % (nsa_ue, new_ip, new_imsi))

    @logger
    def _determine_cells_configured(self):
        instances_of_cells_configured = self.wtsobj.find_all(command='set_cell')
        return instances_of_cells_configured

    @logger
    def _generate_string_from_args(self, params):
        generated_command = ''
        for key in params:
            temp_string = key+'='+params[key]
            generated_command = generated_command + temp_string + ', '
        return generated_command[:-2]

    @logger
    def _generate_parms_for_new_cell(self, reference_command, cell_itr):
        """Extract and modify PCI"""
        parms_to_be_modified = {}
        pci = re.search(r"pci=(\d+):(\d+)", reference_command)
        if cell_itr == 0:
            self._set_start_cell(pci)
        new_pci = self._calculate_new_pci(cell_itr)
        parms_to_be_modified['pci'] = new_pci
        return parms_to_be_modified

    @logger
    def _set_start_cell(self, pci):
        phy_cell_id = ((int(pci.group(1))) * 3) + int(pci.group(2))
        self.start_cell = phy_cell_id

    @logger
    def _calculate_new_pci(self, cell_itr):
        sss, pss = divmod((self.start_cell + cell_itr + 1), 3)
        new_pci = str(sss)+':'+str(pss)
        return new_pci

    @logger
    def _get_nr_cell_instances(self, nr_cell_identifier='gnb=2'):
        all_cell_instances = self._determine_cells_configured()
        nr_cells_configured = {}
        for instance in all_cell_instances:
            if nr_cell_identifier in instance:
                cell_id = re.search(r"set_cell\sid=(\d+)", instance)
                cell_id_number = cell_id.group(1)
                nr_cells_configured[cell_id_number] = instance
        return nr_cells_configured

    @logger
    def _identify_reference_cell(self, existing_nr_cells):
        return existing_nr_cells[max(existing_nr_cells.keys())]

    @logger
    def _identify_missing_nr_cell_instances(self):
        existing_nr_cells = self._get_nr_cell_instances()
        required_nr_cells = self.scenario_parser.get_required_cells()
        to_be_configured_cells = []
        for item in required_nr_cells:
            if item not in existing_nr_cells.keys():
                to_be_configured_cells.append(str(item))
        reference_cell = self._identify_reference_cell(existing_nr_cells)
        return reference_cell, to_be_configured_cells

    @logger
    def _delete_additionally_predefined_sansa_ues(self):
        """Deletes pre-configured UEs from basic configuration file
        Retains the reference NSA and SA UEs defined in variables self.basic_cfg_reference_nsa_ue
        self.basic_cfg_reference_sa_ue respectively"""
        predefined_ues = self.wtsobj.find_all(command="set_ue")
        for ue_command in predefined_ues:
            ue_id = re.search(r"set_ue\ssimulated\sid=(\d+)", ue_command)
            if (int(self.basic_cfg_reference_sa_ue) != int(ue_id.group(1)) and "suci" in ue_command) or \
                    (int(self.basic_cfg_reference_nsa_ue) != int(ue_id.group(1)) and "imsi" in ue_command):
                logging.info("Deleting UE %s from Basic config file" % ue_id.group(1))
                self.wtsobj.delete(command=str("set_ue simulated id=%s" % ue_id.group(1)))
                self.wtsobj.delete(command=str("set_bearer id=2 ue=%s" % ue_id.group(1)))
                self.wtsobj.delete(command=str("ue_param id=%s" % ue_id.group(1)))
                self.wtsobj.delete(command=str("set_pdu_gateway id=%s" % ue_id.group(1)))

    @logger
    def _change_nsa_ue_id_in_reference_file(self, new_nsa_ue_id):
        """Replaces the reference NSA UE id related parameters in basic config with
        given ue_id (new_nsa_ue_id)"""
        # self.wtsobj.save_wts_cfg("/home/ute/modified_file.cfg")
        if not self.basic_cfg_reference_nsa_ue:
            return
        self.wtsobj.modify(command="set_ue simulated id=%s" % self.basic_cfg_reference_nsa_ue,
                           modification="id=%s" % new_nsa_ue_id)
        self.wtsobj.modify(command="ue_param id=%s" % self.basic_cfg_reference_nsa_ue,
                           modification="id=%s" % new_nsa_ue_id)
        self.wtsobj.modify(command="set_bearer ip=$PDN_IP ue=%s" % self.basic_cfg_reference_nsa_ue,
                           modification="id=2 ue=%s" % new_nsa_ue_id)
        ref_ue_nat_ip, _ = self._get_sa_reference_parameters()
        """To be checked if the PDU Gateway is needed for NSA UE"""
        if not ref_ue_nat_ip:
            ref_ue_nat_ip = self._get_nsa_reference_parameters()
        ip = wts_ue.obtain_new_ip(ue_id=new_nsa_ue_id, wts_extract=ref_ue_nat_ip)
        try:
            self.wtsobj.modify(command="set_pdu_gateway id=%s" % self.basic_cfg_reference_nsa_ue,
                               modification="id=%s ue_nat_ip=%s" % (new_nsa_ue_id, ip))
        except Exception as e:
            print("Exception:" + str(e))

    @logger
    def _get_sa_reference_parameters(self):
        ref_ue_nat_ip = self.wtsobj.get_parameter(
            "set_pdu_gateway id=1", "ue_nat_ip")
        ref_suci = self.wtsobj.get_parameter("set_ue simulated id=1",  "suci")
        return ref_ue_nat_ip, ref_suci

    def _get_nsa_reference_parameters(self):
        ref_ue_nat_ip = self.wtsobj.get_parameter(
            "set", "PDN_IP")
        return ref_ue_nat_ip

    @logger
    def _get_default_ue_capability(self):
        self.default_nsa_ue_nr_capabilities = \
            self.wtsobj.get_parameter(command="ue_param id=%s" % self.basic_cfg_reference_nsa_ue,
                                      parameter="ue_nr_capabilities")
        self.default_ue_eutra_nr_capabilities = \
            self.wtsobj.get_parameter(command="ue_param id=%s" % self.basic_cfg_reference_nsa_ue,
                                      parameter="ue_eutra_nr_capabilities")
        self.default_ue_nr_capabilities = \
            self.wtsobj.get_parameter(command="ue_param id=%s" % self.basic_cfg_reference_sa_ue,
                                      parameter="ue_nr_capabilities")

    @logger
    def configure_sa_ues_to_cells_in_basic_cfg(self, ue_parameters):
        ref_ue_nat_ip, ref_suci = self._get_sa_reference_parameters()
        for ue_id, ue_params in ue_parameters.items():
            ue_cap = ue_params['nr_ue_cap']
            pdu = ue_params['pdu']
            if not ue_cap:
                ue_cap = self.default_ue_nr_capabilities
            if self.basic_cfg_reference_sa_ue == ue_id:
                self.wtsobj.modify(command=str('set_ue simulated id=%s' % ue_id),
                                   modification=str("cell=%s" % ue_params['cell']))
                self.wtsobj.modify(command=str("ue_param id=%s" % (ue_id)),
                                   modification=str("ue_nr_capabilities=%s" % ue_cap))
            else:
                suci = wts_ue.obtain_new_suci(ue_id=ue_id, suci_extract=ref_suci)
                ip = wts_ue.obtain_new_ip(ue_id=ue_id, wts_extract=ref_ue_nat_ip)
                command = str('set_ue simulated id=%s' % self.basic_cfg_reference_sa_ue)
                modification = str("id=%s suci=%s cell=%s" % (ue_id, suci, ue_params['cell']))
                self.wtsobj.delete(command=str("set_ue simulated id=%s" % ue_id))
                self.wtsobj.delete(command=str("ue_param id=%s" % ue_id))
                self.wtsobj.delete(command=str("set_pdu_gateway id=%s" % ue_id))
                self.wtsobj.clone_and_modify(command=command,
                                             modification=modification,
                                             location='after',
                                             reference='set_ue simulated id=1')
                self.wtsobj.clone_and_modify(command="ue_param id=1",
                                             modification=str("id=%s ue_nr_capabilities=%s" % (ue_id, ue_cap)),
                                             location='after',
                                             reference='ue_param id=1')
                self.wtsobj.clone_and_modify(command="set_pdu_gateway id=1",
                                             modification=str("id=%s ue_nat_ip=%s" % (ue_id, ip)),
                                             location='after',
                                             reference='set_pdu_gateway id=1')

        self.wtsobj.modify(command="set_nwslice id=1", modification="ue=all")
