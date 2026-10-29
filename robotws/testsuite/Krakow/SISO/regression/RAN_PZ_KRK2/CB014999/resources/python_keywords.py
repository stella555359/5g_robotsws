from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations as CellOp
from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations as RuOp
from taf.rfrl.csv4all.resources.node.node import Node
from taf.rfrl.utilities.tl_config import get_testline_configuration_directory_path
import variables


tl = BuiltIn().get_variable_value('${tl}')
node = None
RuOp = RuOp()
CellOp = CellOp()


def setup_csv4all_node():
    global node
    node = Node(node_mrbts_id=tl.gnbs[0].global_bts_id,
                node_vm={"host": tl.test_pc.default_ssh_connection_details.addr,
                         "user": tl.test_pc.default_ssh_connection_details.username,
                         "password": tl.test_pc.default_ssh_connection_details.password},
                ru_manager_yaml_file="{}/ru_manager_CB014999.yml".format(get_testline_configuration_directory_path()))
    node.setup_node()


def download_blackbox(target_dir):
    node.download_blackbox_files_from_rmods(target_dir=target_dir)


def teardown_csv4all_node():
    node.node_teardown()


def parse_rtwp_dict_from_awk_output(rtwp_awk_output):
    logger.debug("rtwp_awk_output: {}".format(rtwp_awk_output))
    assert rtwp_awk_output.count("Item type: rtwp_histogram") != 0, "No rtwp items found in rtwp command output"

    all_rtwp_items = rtwp_awk_output.split("---")
    if "Item type: " in all_rtwp_items[-1] and "Item type: rtwp_histogram" not in all_rtwp_items[-1]:
        all_rtwp_items = all_rtwp_items[:-1]

    logger.debug("all_rtwp_items: {}".format(rtwp_awk_output))

    # check that number of extracted rtwp sections equals to number of "Item type: rtwp_histogram"
    # occurrences in input string.
    assert len(all_rtwp_items) == rtwp_awk_output.count("Item type: rtwp_histogram"), \
        "Incorrect input text - number of extracted rtwp sections ({}) doesn't equal to number of " \
        "\"Item type: rtwp_histogram\" occurences in input string ({}). - this method expects input text to be " \
        "a section of BBOX consisting of consequent rtwp_histogram sections (starting with " \
        "'Item type: rtwp_histogram'), optionally with one extra line of another Item type at the end.".format(
            len(all_rtwp_items), rtwp_awk_output.count("Item type: rtwp_histogram"))

    rtwp_dict = {}
    for rtwp_item in all_rtwp_items:
        time_vars = {}
        rtwp_item.split("_")
        table = {}
        for line in rtwp_item.split('\n'):
            if line.startswith('Item id: '):
                item_id = line.removeprefix("Item id: ")
                antenna_id = item_id.split("_")[-1].rstrip()
                cell_dist = "_".join(item_id.split("_")[:-1])
            elif line.startswith('First write: '):
                time_vars["first_write"] = line.removeprefix("First write: ").rstrip()
            elif line.startswith('Last write: '):
                time_vars["last_write"] = line.removeprefix("Last write: ").rstrip()
            elif line.startswith('First write ISTI: '):
                time_vars["first_write_isti"] = line.removeprefix("First write ISTI: ").rstrip()
            elif line.startswith('Last write ISTI: '):
                time_vars["last_write_isti"] = line.removeprefix("Last write ISTI: ").rstrip()
            elif line.startswith('Last ISTI range: '):
                time_vars["last_isti_range"] = line.removeprefix("Last ISTI range: ").rstrip()
            elif line.rstrip() != '' and line.rstrip() != "Item type: rtwp_histogram":
                if line.startswith('Ranges [dBm]:'):
                    line = line.removeprefix('Ranges [dBm]:')
                    table['Ranges'] = [i.strip() for i in line.split()]
                elif line.startswith('Day['):
                    row_data = []
                    for item in line.split():
                        if item.startswith('Day['):
                            day = item.removeprefix("Day[").removesuffix("]:")
                        else:
                            row_data.append(int(item))
                    table[day] = row_data
                elif line.startswith('LIFETIME:'):
                    line = line.removeprefix('LIFETIME:')
                    table['LIFETIME'] = [int(i.strip()) for i in line.split()]
                else:
                    raise ValueError("Unexpected line found in rtwp_histogram output: {}".format(line))

        if cell_dist not in rtwp_dict:
            rtwp_dict[cell_dist] = {}

        rtwp_dict[cell_dist][antenna_id] = {"time_vars": time_vars, "table": table}

    number_of_antenna_items = len([antenna_id for cell in rtwp_dict for antenna_id in rtwp_dict[cell]])
    assert number_of_antenna_items == len(all_rtwp_items), "Parsing of rtwp histogram failed. Number of antenna " \
                                                           "items ({}) isn't equal to number of rtwp_histogram items " \
                                                           "({})".format(number_of_antenna_items, len(all_rtwp_items))
    logger.info("Found {} antenna items in RU BlackBox log".format(number_of_antenna_items), also_console=True)
    return rtwp_dict


def verify_number_of_samples_appeared_in_rtwp_histograms(rtwp_histograms_1, rtwp_histograms_2,
                                                         expected_number_of_new_samples):
    """Verifies rtwp values only for cells defined in variables.RUS_INFO dictionary, rtwp values for other BTS cells
    are ignored"""

    wrong_number_of_samples_detected = False

    for rmod_id, ru in variables.RUS_INFO.items():
        for cell_id, cell_rtwp_ids in ru["cells"].items():
            logger.debug("cell_id: {}, cell_rtwp_ids: {}".format(cell_id, cell_rtwp_ids))
            cell_dist = cell_rtwp_ids["cell_dist"]
            assert cell_dist in rtwp_histograms_1[rmod_id].keys(), "Didn't find rtwp histogram item for cell {} in " \
                                                                   "first rtwp dict".format(cell_dist)
            assert cell_dist in rtwp_histograms_2[rmod_id].keys(), "Didn't find rtwp histogram item for cell {} in " \
                                                                   "second rtwp dict".format(cell_dist)
            for antenna_id in cell_rtwp_ids["antennas"]:
                logger.debug("antenna_id: {}".format(antenna_id))

                is_antenna_id_found_in_rtwp = False

                for antenna_dist in rtwp_histograms_1[rmod_id][cell_dist].keys():
                    if antenna_dist[:-1] == "antenna" + str(antenna_id):

                        is_antenna_id_found_in_rtwp = True

                        sum_day0_dict_1 = sum(rtwp_histograms_1[rmod_id][cell_dist][antenna_dist]["table"]["0"])
                        sum_day0_dict_2 = sum(rtwp_histograms_2[rmod_id][cell_dist][antenna_dist]["table"]["0"])
                        actual_number_of_new_samples = sum_day0_dict_2 - sum_day0_dict_1
                        logger.debug("sum of all samples on Day[0] in dict 1: {}".format(sum_day0_dict_1))
                        logger.debug("sum of all samples on Day[0] in dict 2: {}".format(sum_day0_dict_2))
                        logger.debug("actual number of new samples: {}".format(actual_number_of_new_samples))

                        if actual_number_of_new_samples != expected_number_of_new_samples:
                            wrong_number_of_samples_detected = True
                            logger.warn("Wrong number of samples appeared in rtwp histogram for item: {}_{}. Actual: "
                                        "{}, expected: {}".format(cell_dist, antenna_dist,
                                                                  actual_number_of_new_samples,
                                                                  expected_number_of_new_samples))

                assert is_antenna_id_found_in_rtwp, "Didn't find rtwp histogram item for antenna id: {} of cell:" \
                                                    " {}.".format(antenna_id, cell_dist)

    assert not wrong_number_of_samples_detected, "Wrong number of samples appeared in rtwp_histogram for at least " \
                                                 "one cell, please check warnings in the log"


def reset_radio_units():
    for rmod_id in variables.RUS_INFO.keys():
        logger.info('Trigger reset of {}'.format(rmod_id), also_console=True)
        rmod_id_int = int(rmod_id.split("-")[1])
        RuOp.reset_radio_unit(radio_unit_id=rmod_id_int)


def wait_for_radio_units_to_be_online():
    for rmod_id in variables.RUS_INFO.keys():
        logger.info('Waiting for {} to be online'.format(rmod_id), also_console=True)
        rmod_id_int = int(rmod_id.split("-")[1])
        RuOp.wait_for_radio_unit_to_be_online(ru_id=rmod_id_int)


def wait_for_cells_to_be_onair():
    for rmod_id, ru in variables.RUS_INFO.items():
        for cell_id in ru["cells"].keys():
            logger.info('Waiting for cell {} to be OnAir'.format(cell_id), also_console=True)
            CellOp.wait_for_cell_to_be_onair(cell_id=cell_id, timeout=300)


def display_rus_and_cells_for_verification_and_fail_if_empty():
    logger.info('\nNOTE: will verify only following RUs and cells:', also_console=True)
    assert len(variables.RUS_INFO) > 0, "No RUs specified for test - please fill variables.RUS_INFO dictionary"
    for rmod_id, ru in variables.RUS_INFO.items():
        logger.info(" {} ({} {})".format(rmod_id, ru["name"], ru["sn"]), also_console=True)
        assert len(ru["cells"]) > 0, "No Cells specified to test for {} ({}) - please fill variables.RUS_INFO" \
                                     " dictionary".format(rmod_id, ru["name"])
        for cell_id, cell_rtwp_ids in ru["cells"].items():
            logger.info("  cell: {}".format(cell_id), also_console=True)

    logger.info('To test other RUs/cells please modify variables.RUS_INFO dictionary accordingly', also_console=True)
