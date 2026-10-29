import logging
import os
import json
from operator import eq, contains
from cell_deltas import cell_deltas
from cell_deltas24R1 import cell_deltas24R1
from enb_deltas import enb_deltas
from taf.config.scf import scf
from taf.rfrl.utilities.robot.general import get_builtin_value, set_robot_test_variable
from taf.rfrl.bts.devices.generic_bts import login_logout
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning, EnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations


class GnbCellCustomKeywords(GnbCellOperations):

    @login_logout
    def get_all_sa_cell_ids(self, bts_id=0, du_id=0):
        """
        Get all SA cells for given BTS
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: list of SA cells(dist names)
        """
        return self._get_all_cell_ids_met_requirements(
            param_name='cellDepType',
            param_value='SA',
            cell_type='NRCELL',
            bts_id=bts_id,
            du_id=du_id,
            operator=eq
        )

    @login_logout
    def get_all_nsa_cell_ids(self, bts_id=0, du_id=0):
        """
        Get all NSA cells for given BTS
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: list of SA cells(dist names)
        """
        return self._get_all_cell_ids_met_requirements(
            param_name='cellDepType',
            param_value='NSA',
            cell_type='NRCELL',
            bts_id=bts_id,
            du_id=du_id,
            operator=eq
        )

    @login_logout
    def get_pscell_id(self, bts_id=0, du_id=0):
        pass

    @login_logout
    def get_scell_id(self, bts_id=0, du_id=0):
        pass

    @login_logout
    def get_all_ul_cell_ids(self, bts_id=0, du_id=0, cell_type='NRCELL'):
        return self._get_all_cell_ids_met_requirements(
            param_name='nrCellType',
            param_value='UL',
            cell_type=cell_type,
            bts_id=bts_id,
            du_id=du_id,
            operator=contains
        )

    @login_logout
    def get_all_dl_cell_ids(self, bts_id=0, du_id=0, cell_type='NRCELL'):
        # w zaleznosci od RAT rone celltype
        return self._get_all_cell_ids_met_requirements(
            param_name='nrCellType',
            param_value='DL',
            cell_type=cell_type,
            bts_id=bts_id,
            du_id=du_id,
            operator=contains
        )

    def _get_all_cell_ids_met_requirements(self, param_name, param_value, cell_type='NRCELL', bts_id=0, du_id=0,
                                           operator=eq):
        """
        Get all cells that meet requirements
        :param param_name: parameter name
        :param param_value: parameter value
        :param cell_type: cell type, default NRCELL
        :param bts_id: ID of gNB/eNB, default 0
        :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param operator: operator for comparison, default eq
        """
        cell_ids = []
        cell_id_param_name = None
        if cell_type == 'NRCELL':  # check param name for rest of RATs
            cell_id_param_name = 'nrCellId'
        all_nrcell_config = self.admin.get_parameter_by_class(
            class_name=cell_type.upper(),
            parameter_list=[param_name, cell_id_param_name],
            connection=self.rest_alias.format(bts_id, du_id))
        for cell_record in all_nrcell_config:
            if operator(cell_record['parameters'].get(param_name), param_value):
                cell_ids.append(cell_record['parameters'][cell_id_param_name])

        return cell_ids

    def get_all_cell_ids_linked_to_all_extension_rmods(self, bts_id=0, du_id=0):
        cell_ids = []
        main_rmod_ids = GnbRuOperations()._get_all_radio_ids(bts_id=bts_id, du_id=du_id)['rmod']
        all_rmod_ids = GnbRuOperations()._get_all_radio_ids(bts_id=bts_id, du_id=du_id, extension=True)['rmod']
        extension_rmod_ids = set(all_rmod_ids) - set(main_rmod_ids)
        logging.debug("Extension RMODs: {}".format(extension_rmod_ids))
        for rmod_id in extension_rmod_ids:
            cell_ids.extend(self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, radio_id=rmod_id))
        return cell_ids

    def get_all_cell_ids_linked_to_all_main_rmods(self, bts_id=0, du_id=0):
        cell_ids = []
        main_rmod_ids = GnbRuOperations()._get_all_radio_ids(bts_id=bts_id, du_id=du_id)['rmod']
        logging.debug("Main RMODs: {}".format(main_rmod_ids))
        for rmod_id in main_rmod_ids:
            cell_ids.extend(self._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id, radio_id=rmod_id))

        return cell_ids

    def get_cells_not_related_with_ru(self, ru_id=0):
        all_cells = self.get_all_cells_id()
        rmod_cells = self.get_all_cells_id(ru_id=ru_id)
        return [cell for cell in all_cells if cell not in rmod_cells]

    def get_cells_not_related_with_cell_grp(self, cell_grp_id):
        all_cells = self.get_all_cells_id()
        cell_grp_cells = self._get_cell_ids_in_specific_cell_group(cell_group_id=cell_grp_id)
        return [cell for cell in all_cells if cell not in cell_grp_cells]

    def get_all_cell_grp_ids(self):
        cell_grp_ids = self._get_all_cell_group_ids()
        return list(cell_grp_ids)

    def get_cells_to_lock(self, cells):
        all_cells = list(self.get_all_cells_id())
        return [cell_id for cell_id in all_cells if cell_id not in cells]

    @staticmethod
    def delete_cell_grp_from_configuration(cell_grp_id):
        delete_delta = cell_deltas[f'del_cell_grp{cell_grp_id}']
        GnbCommissioning().perform_bts_delta_commissioning(delete_delta)

        logging.debug(f"Download SCF configuration after deleting cell group-{cell_grp_id}")
        scf_path = GnbDuOperations().get_bts_configuration_file(
            filename=f'bts_config_cell_grp{cell_grp_id}_deleted.xml',
            local_dir=get_builtin_value('scf_dir'))
        logging.debug(f"Configuration saved in {scf_path}")

        logging.debug(f"Generate delta for adding CELL_GRP-{cell_grp_id}")
        add_cell_grp_delta = os.path.join(get_builtin_value('scf_dir'), f'add_cell_grp{cell_grp_id}_delta.json')
        scf().calculate_delta_scf(actual_scf_path=scf_path,
                                  target_scf_path=get_builtin_value('full_bts_config'),
                                  delta_scf_path=add_cell_grp_delta)
        logging.debug(f"Delta saved in {add_cell_grp_delta}")
        set_robot_test_variable(f'add_cell_grp{cell_grp_id}_delta', add_cell_grp_delta)

    @staticmethod
    def add_cell_grp_to_configuration(cell_grp_id):
        add_delta = get_builtin_value(f'add_cell_grp{cell_grp_id}_delta')
        with open(add_delta, 'r') as file:
            data = json.load(file)
            GnbCommissioning().perform_bts_delta_commissioning(data, adjust_dist_name=False)

    @staticmethod
    def change_defaultLnRelGnbCellId(rmod_id):
        default_cell = enb_deltas[f'defaultrmod{rmod_id}']
        EnbCommissioning().perform_bts_delta_commissioning(default_cell)
