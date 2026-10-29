from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ConfigurationIssue, EnvironmentIssue,
                                                                        ScriptIssue, ErrorFromAdmin)
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.ParameterChange import ParameterChange
from testsuite.Oulu.TrunkEng.RecoveryAndAlarms.Python.Interfaces.FaultingRmod import FaultingRmod


class VSWR:
    def __init__(self):
        self.admin = BuiltIn().get_library_instance('ADMIN')
        self.antennae = BuiltIn().get_library_instance('ANTENNAE')
        self.bts = BuiltIn().get_library_instance('BTS')
        self.logger = BuiltIn().get_library_instance('LOG')
        self.parameter_change = ParameterChange()
        self.scf = BuiltIn().get_library_instance('SCF')
        self.faulting_rmod = FaultingRmod()
        self.cells = BuiltIn().get_library_instance("CELLS")
        self.bts_status = BuiltIn().get_library_instance("BTSSTATUS")
        self.cell_resources = BuiltIn().get_library_instance("CELL_RESOURCES")
        self.tx_affected_cells = None

    def set_vswr_value_to_trigger_alarm(self, alarm, antenna_line, threshold='15'):
        """
        Set VSWR value to trigger alarm in Admin.
        :param str alarm: Alarm ID
        :param obj antenna_line: Antenna object
        :param str threshold: Threshold value for VSWR, given by user. Default is 15.

        """
        info("Set VSWR value to trigger alarm in Admin.")
        al_distname = antenna_line.dist_name
        parameter_value_dict = {}
        if alarm == "1838":
            parameter_value_dict = {"vswrMinorThreshold": threshold, "vswrMajorThreshold": '31'}
        if alarm == "1837":
            parameter_value_dict = {"vswrMajorThreshold": threshold, "vswrMinorThreshold": threshold}
        self.parameter_change.set_vswr_value(al_distname, parameter_value_dict)

    def set_vswr_value_to_clear_alarm(self, antenna_line, initial_value='31'):
        """
        Set VSWR value to clear alarm in Admin.
        :param obj antenna_line: Antenna object
        :param str initial_value: Initial value for VSWR, given by user. Default is 31.
        """
        info("Set VSWR value to clear alarm in Admin.")
        al_distname = antenna_line.dist_name
        parameter_value_dict = {"vswrMinorThreshold": initial_value, "vswrMajorThreshold": initial_value}
        self.parameter_change.set_vswr_value(al_distname, parameter_value_dict)

    def compare_vswr_values(self, alarm, antenna_line, threshold="15"):
        """
        Compares VSWR values between SCF and Admin and user given value.
        :param str alarm: Alarm ID
        :param obj antenna_line: Antenna object
        :param str threshold: Threshold value for VSWR, given by user. Default is 15.

        """
        info("Compare VSWR values between SCF and Admin and user given value.")
        success = True
        vswr_scf = self.vswr_value_from_scf(alarm, antenna_line)
        vswr_admin = self.vswr_value_from_admin(alarm, antenna_line)
        if vswr_scf == vswr_admin:
            info("VSWR values are the same in SCF and Admin.")
        else:
            error("VSWR values are different in SCF and Admin.")
            success = False
        if vswr_admin == threshold:
            info(f"VSWR value ({vswr_admin}) is equal to given threshold ({threshold}).")
        else:
            error(f"VSWR value ({vswr_admin}) from Admin is not equal to given threshold ({threshold}).")
            success = False
        if not success:
            raise EnvironmentIssue("Incorrect VSWR values.")

    def vswr_value_from_scf(self, alarm, antenna_line):
        vswr_threshold = '0'
        al_distname = antenna_line.dist_name
        info(f"SCF distname: {al_distname}")
        if alarm == "1838":
            vswr_threshold = self.scf.get_value_from_scf(al_distname, "vswrMinorThreshold")
        if alarm == "1837":
            vswr_threshold = self.scf.get_value_from_scf(al_distname, "vswrMajorThreshold")
        if not vswr_threshold:
            error("Could not find VSWR value from scf.")
            raise ConfigurationIssue("Could not find VSWR value from scf.")
        info(f"Found threshold value from SCF: {vswr_threshold}")
        return vswr_threshold

    def vswr_value_from_admin(self, alarm, antenna_line):
        vswr_threshold = '0'
        al_distname = antenna_line.runtime_dist_name
        mos = self.admin.get_managed_objects("ANTL_R")
        for mo in mos:
            if mo["distName"] == al_distname:
                if alarm == "1838":
                    vswr_threshold = mo["parameters"]["vswrMinorThreshold"]
                if alarm == "1837":
                    vswr_threshold = mo["parameters"]["vswrMajorThreshold"]
        info(f"Found threshold value from Admin: {str(int(float(vswr_threshold)*10))}")
        return str(int(float(vswr_threshold)*10))

    def cause_fault_with_telnet(self, radio, fault, resource="", alarm_severity="", deactivate_fault=False):
        """
        Cause given fault to given radio with given severity

        :param object radio: Radio object.
        :param str fault: Fault id to be raised. Can be 1837 or 1838.
        :param str resource: Resource can have values LTX, TX1-TX8 or RX1-RX8
        :param str alarm_severity: Severity can be Minor or Major
        :param bool deactivate_fault: Default is False and then fault is activated. If True, deactivate fault.
        """
        if alarm_severity == 'Minor':
            severity = '1'
        elif alarm_severity == 'Major':
            severity = '0'
        if not deactivate_fault:
            info(f"Setting fault {fault} to radio {radio.name} with alarm severity {alarm_severity}...")
        else:
            info(f"Canceling fault {fault} from radio {radio.name}, alarm severity {alarm_severity}...")
        self.faulting_rmod.raise_fault_to_rmod(fault, radio, resource, deactivate_fault, severity)

    @staticmethod
    def _get_antennas_with_tx_resource(ant_rmod_cell):
        """
        Get antennas that have TX resources.

        :param dict ant_rmod_cell: Dictionary of antennas, TX and RX resources and cells.
        :return: List of antennas with TX capabilities.
        """
        tx_resources_antenna = []
        for ant, resource_cell in ant_rmod_cell.items():
            if "TX" in resource_cell[0]:
                if ant not in tx_resources_antenna:
                    tx_resources_antenna.append(ant)
        info(f"Antennas with TX capabilities are {tx_resources_antenna}")
        return sorted(tx_resources_antenna)

    def get_tx_resource_to_be_used(self, radio, ant_line_cells, antenna_line):
        """
        Get TX resource to be faulted from cell and radio.

        :param object radio: Radio object.
        :param list ant_line_cells: List of cells of antenna line
        :param antenna_line: Antenna line to be tested
        :return: TX resource to be used for faulting for example TX1
        """
        ant_rmod_cell = self.bts.get_active_antennas_of_radio_and_cells(radio)
        tx_antennas = self._get_antennas_with_tx_resource(ant_rmod_cell)
        self.tx_affected_cells = self.cell_resources.get_cells_of_antenna_with_given_direction_from_radio(
            'TX', radio, antenna_line[-1])
        for ant, resource_cell in ant_rmod_cell.items():
            for cell in ant_line_cells:
                if (cell in resource_cell[1] and ant in tx_antennas and ant[-1] == antenna_line[-1]
                        and self.tx_affected_cells):
                    tx_number = int(tx_antennas.index(ant)) + 1
                    info(f"TX{tx_number} of {radio.name} is connected to selected Antenna Line")
                    return f"TX{tx_number}"
        error(f"Could not find TX resource to be used for faulting from cell {ant_line_cells} and radio {radio.name}.")
        raise ScriptIssue

    def check_expected_states(self, ant_line_cells, radio_module, state="cell_disabled_radio_enabled"):
        """
        Create dictionary for expected cell states

        :param list ant_line_cells: List of cells
        :param object radio_module: Radio object.
        :param str state: State of cells and radio. Default is cell_disabled_radio_enabled.
        """
        ok_state = {"operationalState": "enabled"}  # , "availabilityStatus": "online"}
        enabled_degraded_state = {"operationalState": "enabled", "availabilityStatus": "degraded"}
        # cell_state = {"operationalState": "disabled", "availabilityStatus": "faulty"}
        nok_state = {"operationalState": "disabled", "availabilityStatus": "failed"}
        rmod_state = {"administrativeState": "Unlocked", "operationalState": "enabled"}
        rmod_state_lock = {"administrativeState": "Locked", "operationalState": "enabled"}
        cell_state = {}
        # checking if cells have more than 1 TX. If so, set cell states to ok_state, otherwise proceed normally
        checked_cells = self._change_affected_cells_based_on_tx_amount(ant_line_cells)
        BuiltIn().sleep("10s")
        if checked_cells:
            for cell in checked_cells:
                if "cell_disabled" in state:
                    cell_state[cell] = nok_state
                # used to check availabilityStatus of affected cells with VSWR minor alarm
                elif "cell_enabled_degraded" in state:
                    cell_state[cell] = enabled_degraded_state
                else:
                    cell_state[cell] = ok_state
            try:
                if "radio_locked" in state:
                    radio_states = {radio_module.name: rmod_state_lock}
                else:
                    radio_states = {radio_module.name: rmod_state}
                bts_state = self.bts_status.get_expected_bts_state(checked_cells)
                self.cells.check_cell_states(cell_state, states_of_other_cells=ok_state)
                self.bts_status.check_radio_states(radio_states, states_of_other_rmods=ok_state,
                                                   print_ok_states=True)
                self.bts_status.check_bts_state(bts_state)
            except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                    AliasLookupError, AdminApiTerminatedException, AliasInUse,
                    AdminApiConnectionClosedException) as admin_error:
                error(f"Unable to check_expected_states. {admin_error.__class__.__name__}:{admin_error} was raised.\n"
                      f"{''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))}")
                raise ErrorFromAdmin(f"Unable to check_expected_states, {admin_error.__class__.__name__} was raised.")
        else:
            # Cell has more than 1 TX
            if "cell_disabled" in state:
                # Only print in > 1 TX with VSWR major alarm
                info("In ALD, lte441-a is considered to be active to be"
                     " able to use Degraded cells instead of Faulty cells")
            for cell in ant_line_cells:
                if "cell_enabled_degraded" in state or "cell_disabled" in state:
                    cell_state[cell] = enabled_degraded_state
                else:
                    cell_state[cell] = ok_state
                self.cells.check_cell_states(cell_state, states_of_other_cells=ok_state, print_ok_cell_states=True)

    def check_antenna_tx_power(self, rmod, antenna):
        """
        Check TX power of an antenna in the given radio.
        :param obj rmod: Radio object.
        :param obj antenna: Antenna object.
        """
        info("Check TX power of an antenna in the given radio.")
        tx_power = self.antennae.get_txrx_powers(rmod, antenna, direction="TX")
        info(f"TX power is {tx_power}")
        return tx_power

    def get_cells_connected_to_selected_tx(self, selected_tx, rmod, antenna_line):
        """
        Get cells connected to selected TX.
        :param str selected_tx: Selected TX for example TX1.
        :param object rmod: Radio object.
        :param str antenna_line: Antenna line for example RMOD-1/ANTL-1.
        """
        info(f"Getting cells connected to selected {selected_tx} of {antenna_line} of {rmod.name}.")
        # direction, radio, antenna
        antenna = antenna_line.split("/")[1].split("-")[1]
        info(f"Cells {self.tx_affected_cells} are affected by {selected_tx} of {antenna_line} of {rmod.name}.")
        return self.tx_affected_cells

    def wait_cells_based_on_affected_cells(self, cell):
        """
        If affected cell has more than 1 TX, wait for all cells to be up. Otherwise, wait for faulty cells.

        :param cell: affected cell
        """
        affected_cells = self._change_affected_cells_based_on_tx_amount(cell)
        if affected_cells:
            self.cells.wait_for_cells_faulty(time_limit=120, cells_to_be_faulty=affected_cells)
        else:
            self.cells.wait_for_all_cells_up(time_limit=300)

    def _change_affected_cells_based_on_tx_amount(self, cell):
        """
        Check if cells more than 1 TX and change affected cells based on that.

        :param obj cell: cell object
        :return list: empty list if cell has more than 1 TX, otherwise return affected cells normally
        """
        result = self.cells.check_if_cells_have_at_least_two_tx(selected_cell=cell)
        if result:
            cell = []
            return cell
        else:
            return cell
