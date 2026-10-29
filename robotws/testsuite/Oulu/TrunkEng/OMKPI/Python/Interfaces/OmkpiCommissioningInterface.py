import os
import re
from datetime import datetime
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import EnvironmentIssue
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import ValueNotChangedException, ValueNotSameException


class OmkpiCommissioningInterface(object):

    def __init__(self):
        """
        OmkpiCommissioningInterface is collection of needed scf changes for OMKPI
        """
        self.scf = BuiltIn().get_library_instance("SCF")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.bts = BuiltIn().get_library_instance("BTS")

    def commission_value(self, parameter, value, distname="", sleep=True):
        """
        Perform recommissioning for wanted parameter

        :param str parameter: <p name>
        :param str value: Value that parameter should have
        :param str distname: Dist name of commissioning parameter
        :param bool sleep: Sleep after commissioning
        """
        if not distname:
            distname = self.scf.get_distname_based_on_class("com.nokia.srbts.mnl:FEATCADM")[0]
        info(f"Commissioning {parameter}: {value} to {distname}")
        self.admin.perform_parameter_recommissioning(distname, parameter, "update", value,
                                                     skip_parameter_relation_errors=True)
        info(f"Commissioning {parameter} to {value} is done")
        if sleep:
            BuiltIn().sleep("5s", "Wait after commissioning")

    def get_current_value(self, parameter, scf_class=None, distname="", allow_missing=False):
        """
        Get current value of commissioning parameter
        :param str parameter: <p name>
        :param str scf_class: Class of commissioning.
        :param str distname: Dist name of commissioning parameter. If scf_class is given, distname is searched based on
                             class and this parameter is not needed.
        :param bool allow_missing: If true will not fail if parameter is missing
        """
        self.scf.get_scf()
        if scf_class:
            distname = self.scf.get_distname_based_on_class(scf_class)[0]
        current_value = self.scf.get_value_from_scf(dist_name=distname, p_name=parameter, allow_missing=allow_missing)
        info(f"Current value for {parameter} is {current_value}")
        if not current_value and allow_missing:
            if parameter == "actTimeErrorManagement":
                info("Optional parameter actTimeErrorManagement was not in commissioning file, default value is false.")
                # added setting of default value to false because test with it is robot based, easier to do here
                return "false"
            elif parameter == "actRatResetEnhancement":
                # added setting of default value to false because test with it is robot based, easier to do here
                return "true"
            elif parameter in ("actHighAvailabilityCapability", "actHighAvailabilityDeployment"):
                info(f"Optional parameter {parameter} was not in commissioning file, default value is false.")
                return "false"
            else:
                info(f"Parameter {parameter} is optional and may not be in scf file. Returning empty string.")
        return current_value

    def opposite_boolean_commissioning_value(self, parameter):
        """
        Chooses opposite boolean value from FEATCADM parameters

        :param str parameter: <p name> for FEATCADM parameter
        :return str: Opposite value for parameter
        """
        allow_missing = False
        info("Choose opposite value for {}".format(parameter))
        if parameter == "actTimeErrorManagement":
            self.logger.debug(f"Parameter {parameter} is optional, may be missing from scf file. ")
            allow_missing = True
        current_value = self.get_current_value(parameter, "com.nokia.srbts.mnl:FEATCADM", allow_missing=allow_missing)
        return_value = 'true' if current_value.lower() == 'false' else 'false'
        info("Value is going to be changed to {}".format(return_value))
        return return_value

    def check_value_is_changed(self, parameter, value, allow_missing=False):
        """
        Check that commissioning parameter is changed correctly

        :param str parameter: <p name> for FEATCADM parameter
        :param str value: Value that parameter should have
        :param bool allow_missing: If true will not fail if parameter is missing
        :raise ValueNotChangedException: If current value is different than value
        """
        info("Check that {} is {}".format(parameter, value))
        if parameter == "actTimeErrorManagement":
            self.logger.debug(f"Parameter {parameter} is optional, may be missing from scf file. ")
            allow_missing = True
        current_value = self.get_current_value(parameter, "com.nokia.srbts.mnl:FEATCADM", allow_missing=allow_missing)
        if not current_value and allow_missing:
            if parameter == "actTimeErrorManagement":
                info("Optional parameter actTimeErrorManagement was not in commissioning file, default value is false.")
                # added setting of default value to false because test with it is robot based, easier to do here
                current_value = "false"
        if current_value.lower() != value.lower():
            error(f"Value for {parameter} is not changed")
            raise ValueNotChangedException(f"Value for {parameter} is not changed")
        info(f"Parameter {parameter} value is changed correctly to {current_value}")

    def commission_energy_consumption_parameters(self):
        info("Commission needed energy consumption parameters for the actual test")
        self.admin.create_delta("energy_measurements")
        period = "15min"
        pmcadm_distname = self.scf.get_distname_based_on_class("PMCADM")[0]
        self.admin.append_parameter_update_to_delta(pmcadm_distname, "reportingIntervalPm", period,
                                                    delta_id="energy_measurements")
        pmmnl_distname = self.scf.get_distname_based_on_class("PMMNL")[0]
        self.admin.append_parameter_update_to_delta(pmmnl_distname, "mtBtsEnergyMonitoring", period,
                                                    delta_id="energy_measurements")
        self.admin.append_parameter_update_to_delta(pmmnl_distname, "mtSBTSSmEnergyMonitoring", period,
                                                    delta_id="energy_measurements")
        self.admin.append_parameter_update_to_delta(pmmnl_distname, "mtSBTSRfmEnergyMonitoring", period,
                                                    delta_id="energy_measurements")
        featcadm_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.mnl:FEATCADM")[0]
        self.admin.append_parameter_update_to_delta(featcadm_distname, "actPowerMeter", "true",
                                                    delta_id="energy_measurements")
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, "energy_commission_{}.json".format(timestamp))
        self.admin.save_delta(path_to_delta_file, delta_id="energy_measurements")
        info("Delta commissioning file is saved to {}".format(path_to_delta_file))
        self.admin.perform_delta_recommissioning(path_to_delta_file, skip_parameter_relation_errors=True)
        info("Commissioning finished")

    def _format_nrcellgrp_distname(self, scf_class, cell_local_id):
        cell_global_id = self.cells.get_cell_global_id_by_local_id(cell_local_id, rat="nr")
        self.logger.debug(f"Checked cell: {cell_global_id}")
        nrcellgrp_dn_list = self.scf.get_distname_based_on_class(scf_class)
        for nrcellgrp_dn in nrcellgrp_dn_list:
            nrcellgrp_cells = self.scf.get_all_p_values(dist_name=nrcellgrp_dn, list_name="nrCellList")
            self.logger.debug(f"NRCELLGRP {nrcellgrp_dn} cells: {nrcellgrp_cells}")
            if str(cell_global_id) in nrcellgrp_cells:
                return nrcellgrp_dn
        error(f"NRCELLGRP was not found for {cell_local_id}")

    def get_cell_locking_parameters(self, commissioning_parameters, cell_local_id, cell_distname):
        parameter = ""
        value = ""
        pattern = re.compile(r'(?P<scf_class>.*:\w+)\.(?P<parameter>.*)=(?P<value>.*)')
        match = pattern.match(commissioning_parameters)
        if match:
            scf_class = match.group('scf_class')
            if "NRCELLGRP" in scf_class:
                cell_distname = self._format_nrcellgrp_distname(scf_class, cell_local_id)
            parameter = match.group('parameter')
            value = match.group('value')
        else:
            error("Check format of commissioning value from script settings")
        return cell_distname, parameter, value

    def check_current_parameter(self, parameter, value, distname, negative_output=False):
        current_value = self.get_current_value(parameter, distname=distname)
        if not negative_output and current_value.lower() != value.lower():
            error(f"Value for {parameter} is not {value} but {current_value}")
            raise ValueNotSameException(f"Value for {parameter} is not {value} but {current_value}")
        elif negative_output and current_value.lower() == value.lower():
            error(f"Value for {parameter} is {value} and it should be something else")
            raise ValueNotChangedException(f"Value for {parameter} is {value} and it should be something else")
        info(f"Value for {parameter} is {current_value}")

    def check_if_commissioning_is_needed_for_rat_reset(self, rat, kpi):
        """
        Check if commissioning is needed before RAT reset
        :param str rat: RAT
        :param str kpi: KPI
        :return bool: True if commissioning is needed
        """
        info("Checking if recommissioning is needed before RAT reset")
        if self.bts.bbmods:
            bbmod_name = self.bts.bbmods[0].name  # There is only one BBMOD type per config atm
            info(f"Chosen BBMOD for checking if recommissioning is needed: {bbmod_name}")
            act_rat_reset_enhancement = self.get_current_value("actRatResetEnhancement",
                                                               scf_class="com.nokia.srbts.mnl:FEATCADM",
                                                               allow_missing=True)
            if (kpi == "KPI#7a" and rat == "LTE" and act_rat_reset_enhancement.lower() == "false" and
                    ("FBB" not in bbmod_name or "ABIA" not in bbmod_name)):
                info("Recommissioning is needed before RAT reset")
                return True
            elif (kpi == "KPI#7b" and rat == "LTE" and act_rat_reset_enhancement.lower() == "true" and
                  "ABIC" not in bbmod_name):
                info("Recommissioning is needed before RAT reset")
                return True
            else:
                info("Recommissioning is not needed before RAT reset")
                return False

    def commission_rat_reset_enhancement(self, rat, kpi):
        """
        Commission RAT reset enhancement
        :param str rat: RAT
        :param str kpi: KPI
        """
        if self.check_if_commissioning_is_needed_for_rat_reset(kpi, rat):
            if kpi == "KPI#7a":
                self.commission_value("actRatResetEnhancement", "true")
            elif kpi == "KPI#7b":
                self.commission_value("actRatResetEnhancement", "false")

    def get_value_of_ru_phase_activation_reset_policy(self):
        """
        Get value of ru phase activation reset policy method gets value of ruPhaseSwActivationResetPolicy of class
        com.nokia.srbts.mnl:MNL
        :return: Value of ruPhaseSwActivationResetPolicy
        """
        object_distname = self.scf.get_distname_based_on_class("com.nokia.srbts.mnl:MNL")[0]
        if object_distname:
            ru_phase_activation_reset_policy = self.scf.get_value_from_scf(
                dist_name=object_distname, p_name="ruPhaseSwActivationResetPolicy")
            if ru_phase_activation_reset_policy:
                info(f"Value of ruPhaseSwActivationResetPolicy is {ru_phase_activation_reset_policy}")
                return ru_phase_activation_reset_policy
            else:
                info("Class com.nokia.srbts.mnl:MNL doesn't have any ruPhaseSwActivationResetPolicy object.")
                return None
        else:
            info("Class com.nokia.srbts.mnl:MNL is not found from the scf.xml")
            return None

    def kpi55d_commissioning(self):
        """
        Kpi55d commissioning sets commissioning parameters to be suitable for calculating Independent sequential RUs SW
        upgrade duration.
        Needed changes:
            com.nokia.srbts.mnl:MNL: ruPhaseSwActivationResetPolicy: Sequential
            com.nokia.srbts.eqm:RMOD: upgradePhase: To all RMODs -> RU
            com.nokia.srbts.eqm:RMOD: ruPhaseResetOrder: To all RMODs -> undefined
        """
        self.admin.create_delta("kpi55d")
        distname = self.scf.get_distname_based_on_class("com.nokia.srbts.mnl:MNL")[0]
        self.admin.append_parameter_update_to_delta(distname, "ruPhaseSwActivationResetPolicy", "Sequential",
                                                    delta_id="kpi55d")
        ru_distnames = self.scf.get_distname_based_on_class("com.nokia.srbts.eqm:RMOD")
        if not ru_distnames:
            error("No distnames from com.nokia.srbts.eqm:RMOD. There aren't any radios in environment or problems with "
                  "admin connection.")
            raise EnvironmentIssue("No values to class com.nokia.srbts.eqm:RMOD")
        for ru in ru_distnames:
            self.admin.append_parameter_update_to_delta(ru, "upgradePhase", "RU", delta_id="kpi55d")
            phase_order = self.admin.get_parameter_by_distname(ru, parameter_list=["ruPhaseResetOrder"],
                                                               detailed_output=True)
            self.logger.debug(f"ruPhaseResetOrder: {phase_order}")
            if phase_order:
                info(f"There were values for ruPhaseResetOrder in {ru}. Remove the parameter.")
                self.admin.append_parameter_delete_to_delta(ru, "ruPhaseResetOrder", delta_id="kpi55d")
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, f"kpi55d_commission_{timestamp}.json")
        self.admin.save_delta(path_to_delta_file, delta_id="kpi55d")
        info(f"Delta commissioning file is saved to {path_to_delta_file}")
        self.admin.perform_delta_recommissioning(path_to_delta_file, skip_parameter_relation_errors=True)
        info("Commissioning finished")

    def kpi55e_commissioning(self, ahloa_radios):
        """
        Kpi55e commissioning sets commissioning parameters to be suitable for calculating Independent selective RUs SW
        upgrade duration. This KPI measures independent sequential upgrade of selective RUs  group (low bands RUs only)
        using common BTS SW package during activation for RU SW only.
        Needed changes:
            com.nokia.srbts.mnl:MNL: ruPhaseSwActivationResetPolicy: User configuration
            com.nokia.srbts.eqm:RMOD: upgradePhase: AHLOA RMODs -> RU,  Other RMODs -> DU
            com.nokia.srbts.eqm:RMOD: ruPhaseResetOrder: '1' set for AHLOA RUs, other RUs -> undefined
        :param list ahloa_radios: AHLOA radios
        """
        self.admin.create_delta("kpi55e")
        distname = self.scf.get_distname_based_on_class("com.nokia.srbts.mnl:MNL")[0]
        self.admin.append_parameter_update_to_delta(distname, "ruPhaseSwActivationResetPolicy", "User configuration",
                                                    delta_id="kpi55e")
        ahloa_scf = []
        for radio in ahloa_radios:
            ahloa_scf.append(radio.scf_dist_name)
        ru_distnames = self.scf.get_distname_based_on_class("com.nokia.srbts.eqm:RMOD")
        if not ru_distnames:
            error("No distnames from com.nokia.srbts.eqm:RMOD. There aren't any radios in environment or problems with "
                  "admin connection.")
            raise EnvironmentIssue("No values to class com.nokia.srbts.eqm:RMOD")
        for ru in ru_distnames:
            if ru in ahloa_scf:
                self.admin.append_parameter_update_to_delta(ru, "upgradePhase", "RU", delta_id="kpi55e")
                self.admin.append_parameter_update_to_delta(ru, "ruPhaseResetOrder", "1", delta_id="kpi55e")
            else:
                self.admin.append_parameter_update_to_delta(ru, "upgradePhase", "DU", delta_id="kpi55e")
                phase_order = self.admin.get_parameter_by_distname(ru, parameter_list=["ruPhaseResetOrder"],
                                                                   detailed_output=True)
                self.logger.debug(f"ruPhaseResetOrder: {phase_order}")
                if phase_order:
                    info(f"There were values for ruPhaseResetOrder in {ru}. Remove the parameter.")
                    self.admin.append_parameter_delete_to_delta(ru, "ruPhaseResetOrder", delta_id="kpi55e")
        timestamp = datetime.now().strftime("%Y%m%d%H%M%S")
        path_to_delta_file = os.path.join(self.logger.log_dir, f"kpi55e_commission_{timestamp}.json")
        self.admin.save_delta(path_to_delta_file, delta_id="kpi55e")
        info(f"Delta commissioning file is saved to {path_to_delta_file}")
        self.admin.perform_delta_recommissioning(path_to_delta_file, skip_parameter_relation_errors=True)
        info("Commissioning finished")

    def check_if_high_availability_is_active(self):
        """
        Check if high availability is active checks if actHighAvailabilityCapability and actHighAvailabilityDeployment
        of class com.nokia.srbts.mnl:FEATCADM are true. If both parameters are true, high availability environment is
        detected. If parameters are missing from SCF.xml, default value is false.
        """
        value1 = self.get_current_value("actHighAvailabilityCapability", scf_class="com.nokia.srbts.mnl:FEATCADM",
                                        allow_missing=True)
        value2 = self.get_current_value("actHighAvailabilityDeployment", scf_class="com.nokia.srbts.mnl:FEATCADM",
                                        allow_missing=True)
        if value1.lower() == "true" and value2.lower() == "true":
            info("High availability environment is detected based on com.nokia.srbts.mnl:FEATCADM parameters "
                 "actHighAvailabilityCapability and actHighAvailabilityDeployment.")
            BuiltIn().set_suite_variable("${HIGH_AVAILABILITY_ENVIRONMENT}", True)
            return True
        else:
            self.logger.debug("High availability environment is not detected based on com.nokia.srbts.mnl:FEATCADM "
                              "parameters actHighAvailabilityCapability and actHighAvailabilityDeployment.")
            return False
