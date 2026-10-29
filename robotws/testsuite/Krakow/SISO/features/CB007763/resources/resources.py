import logging

from taf.hw.rf_switch import rf_switch
from taf.sbts.oam.coam.admin.exceptions import DataNotAvailable, IncorrectParameterValue
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns

cell_operations = GnbCellOperations()


def set_rf_switch_output_ports(rfs_alias, vendor, ip_addr, model, output_ports, max_retries=5):
    """
    Connects input ports: IN1:IN2:IN3:IN4 with chosen output ports: OUT1:OUT2:OUT3:OUT4

    :param rfs_alias: alias for rf switch used in keywords, str
    :param vendor: rf switch vendor, str
    :param ip_addr: IP address of rf switch, str
    :param model: RF switch model, str
    :param output_ports: output ports in format OUT1:OUT2:OUT3:OUT4
           where OUT1 is a channel connected to input1, OUT2 to input2 etc, str
    :param max_retries: number of performed retry operations before function raises an exception
    Return: None
    """

    rf = rf_switch()
    rf.setup_rf_switch(alias=rfs_alias, vendor=vendor, ip=ip_addr, model=model)
    logging.info(
        "Initial port status:{}".format(
            rf.get_connected_ports(rf_switch_device=rfs_alias)
        )
    )
    logging.info("Changing output ports to:{}".format(output_ports))
    output_ports = output_ports.split(':')
    max_retries = int(max_retries)
    for in_port in range(1, len(output_ports) + 1):
        out_port = output_ports[in_port - 1]
        logging.debug("Setting IN{} to OUT{}".format(in_port, out_port))
        for iter_counter in range(max_retries):
            try:
                rf.connect_ports(rf_switch_device=rfs_alias, port_in=in_port, port_out=out_port)
                break
            except Exception as error:
                if iter_counter == max_retries - 1:
                    logging.error("Last retry operation of setting port IN{}:OUT{} failed!".format(in_port, out_port))
                    raise error
                logging.warning("Error '{}' occurred during setting port IN{}:OUT{}. Retrying operation...".format(
                    error, in_port, out_port))
    logging.info(
        "Current port status:{}".format(
            rf.get_connected_ports(rf_switch_device=rfs_alias)
        )
    )


def get_number_of_cells_onair(bts_id=0, du_id=0):
    """
    Get number of cells onair.
    ...   Author: Jaroslaw Lezon
    ...   Contact: jaroslaw.lezon@nokia.com
    ...   Date: 15.12.2021
    :param bts_id: ID of gNB/eNB, default 0
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :return: None
    """
    expected_statuses = {
        # "availabilityStatus": "Online",
        "operationalState": "enabled",
        "administrativeState": "Unlocked",
    }

    cell_onair_number = 0
    cell_ids = cell_operations._get_all_global_cell_ids(bts_id=bts_id, du_id=du_id)
    for cell_id in cell_ids:
        tmp_counter = 0
        dist_name = cell_operations._get_runtime_cell_dist_name(bts_id=bts_id, cell_id=cell_id, du_id=du_id)
        cell_specific_info = cell_operations.admin.get_cell_specific_info(cell_id=dist_name,
                                                                          connection=cell_operations.rest_alias.format(
                                                                              bts_id, du_id))
        try:
            for status in expected_statuses:
                if expected_statuses[status] != cell_specific_info["status"][status]:
                    break
                tmp_counter += 1
        except KeyError as e:
            raise DataNotAvailable("Cannot get expected status info: {}".format(repr(e)))
        if tmp_counter == 2:
            cell_onair_number += 1
    return cell_onair_number


def verify_number_of_cells_onair(bts_id=0, du_id=0, exp_cells_number=0):
    """
    Verify the number of cells that are onair
    ...   Author: Jaroslaw Lezon
    ...   Contact: jaroslaw.lezon@nokia.com
    ...   Date: 15.12.2021
    :param bts_id:  ID of gNB/eNB, default 0
    :param du_id: DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
    :param exp_cells_number:  expected number of cells onair, default 0
    :return:        None
    """

    # cells_number = self.get_number_of_cells_onair(bts_id=bts_id, du_id=du_id)
    cells_number = get_number_of_cells_onair(bts_id=bts_id, du_id=du_id)
    if cells_number != exp_cells_number:
        logging.debug("Expected cells onair number: {}".format(exp_cells_number))
        logging.debug("Received cells onair number: {}".format(cells_number))
        raise IncorrectParameterValue(
                "Expected number of cells onair: {}, but received number of cells onair is: {}".format(
                    exp_cells_number, cells_number))


def prepare_cells_setup_for_bidir_thpt(ru_map):
    """
        Prepare cells setup for bidir thpt.
        ...   Author/Contact: damian.silkowski@nokia.com
        ...   Date: 22.07.2022
        :param ru_map: dictionary prepared for script ru_map.py
        :return: cells_setup_list of dictionaries for running bidirectional thpt for feature 7763
        """
    cells_setup_list = []
    for ru in ru_map:
        number_of_cells = len(ru['cells'])
        if number_of_cells == 1:
            temp_list = [{'ru_id': ru['ru_id'],
                          'active_cell': {'id': ru['cells'][0]['cell_id'], 'ports': ru['cells'][0]['ports'],
                                          'exp_dl_tput': ru['cells'][0]['exp_dl_tput'],
                                          'exp_ul_tput': ru['cells'][0]['exp_ul_tput']},
                          'cells_to_block': []}]
        else:
            temp_list = []
            for cell in ru['cells']:
                multiple_cell_info_dict = {'ru_id': ru['ru_id'],
                                           'active_cell': {'id': cell['cell_id'], 'ports': cell['ports'],
                                                           'exp_dl_tput': cell['exp_dl_tput'],
                                                           'exp_ul_tput': cell['exp_ul_tput']}}
                cells_to_block_list = []
                for ru_cell in ru['cells']:
                    if ru_cell['cell_id'] != cell['cell_id']:
                        cells_to_block_list.append(ru_cell['cell_id'])
                multiple_cell_info_dict['cells_to_block'] = cells_to_block_list
                temp_list.append(multiple_cell_info_dict)
        cells_setup_list.extend(temp_list)
    return cells_setup_list


def preapre_distname_for_fexCAMod(bts_id=0):
    return GenericBts().adjust_dist_name(dist_name='{}/NRDU-1'.format(GnbDistNamePatterns().bts_dist_name),
                                         bts_id=bts_id)
