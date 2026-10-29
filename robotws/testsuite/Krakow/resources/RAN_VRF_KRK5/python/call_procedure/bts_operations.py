import taf.rfrl.utilities.logger.custom_logger as logger
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.bts.devices.generic_bts import GenericBts
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.dist_name_patterns import GnbDistNamePatterns, EnbDistNamePatterns
from testsuite.Krakow.resources.RAN_VRF_KRK5.python.call_procedure.call_exceptions import RatNotKnown, \
    NoGnbInTestLineConfigFile


def get_prefix_for_specific_rat(rat):
    """
    Returns the cell prefix for a specific RAT.

    This method determines the appropriate prefix based on the provided RAT.
    It supports LTE and NR RATs.

    Parameters:
    rat (str): The Radio Access Technology. Expected values are "lte" or "nr".

    Returns:
    str: The cell prefix corresponding to the provided RAT.

    Raises:
    RatNotKnown: If the provided RAT is not recognized.
    """
    if rat.lower() == "lte":
        return "LNCEL-"
    elif rat.lower() == "nr":
        return "NRCELL-"
    else:
        raise RatNotKnown(f"RAT {rat} is not known by this function. Please contact with autor")


def get_all_cells_from_bts(bts_id=0):
    """
    Retrieves all cells from the BTS.

    This method uses the `GnbDuOperations` class to get information about the cells from the BTS.
    It then processes the cell information to generate a list of cell names with global cell IDs.

    Returns:
    list: A list of dictionaries containing both 'cell_name' and 'global_cell_id'.
    """
    du_operations = GnbDuOperations()
    cells_info = du_operations.get_bts_info(bts_id=bts_id)["cells"]
    cell_list = []
    for rat in cells_info:
        for cell in cells_info[rat]:
            prefix = get_prefix_for_specific_rat(rat=rat)
            if vars == "cell_name":
                cell_list.append(prefix + str(cell["globalCellId"]))
            elif vars == "globalCellId":
                cell_list.append(cell["globalCellId"])
            else:
                cell_list.append({
                    'cell_name': prefix + str(cell["globalCellId"]),
                    "global_cell_id": cell["globalCellId"]
                })
    return cell_list


def adjust_dist_name(dist_name, bts_id=0, du_id=0):
    """
    Adjusts object dist name (dist_name) for a given BTS and DU.

    This method modifies the provided `dist_name` based on the specified `bts_id` and `du_id`.

    Parameters:
    dist_name (str): Object dist name ie. "MRBTS-{}/NRBTS-{}".
    bts_id (int): The identifier of the BTS. Default is 0.
    du_id (int): The identifier of the DU. Default is 0.

    Returns:
    str: The adjusted object dist name with proper values.
    """
    bts = GenericBts()
    return bts.adjust_dist_name(dist_name=dist_name, bts_id=bts_id, du_id=du_id)


def perform_qrxlev_recommissioning(cell_list, bts_id=0, qrx_level="max", log_hierarchy=2):
    """
    Performs QRXLEV recommissioning for a list of cells.

    This method sets the QRXLEV parameter for each cell in the provided `cell_list` to the specified `qrx_level`.
    It logs the operation and performs the necessary updates on the BTS.

    Parameters:
    cell_list (list): A list of dictionaries containing cell information, including 'cell_name' and 'global_cell_id'.
    qrx_level (str): The QRXLEV level to set for the cells. Default is "max".
    log_hierarchy (int): The logging hierarchy level. Default is 2.
    """
    qrxlev_levels = {
        'LTE': {
            'max': '-44',
            'min': '-90',
        },
        'NR': {
            'max': '-22',
            'min': '-45',
        }
    }
    delta = list()
    cell_names = list()
    for cell in cell_list:
        bts_patterns = GnbDistNamePatterns if 'NRCELL' in cell['cell_name'] else EnbDistNamePatterns
        dist_name = adjust_dist_name(dist_name=bts_patterns.cell_dist_name.format({}, {}, cell['global_cell_id']),
                                     bts_id=bts_id)
        if 'LNCEL' in cell['cell_name']:
            dist_name = '{}/SIB-0'.format(dist_name)
        parameter = 'qRxLevMin' if 'NRCELL' in cell['cell_name'] else 'qrxlevmin'
        value = qrxlev_levels['NR'][qrx_level.lower()] if 'NRCELL' in cell['cell_name'] \
            else qrxlev_levels['LTE'][qrx_level.lower()]
        delta.append({
            'distName': dist_name,
            'operation': 'update',
            'parameters': [{
                'operation': 'update',
                'value': value,
                'parameterName': parameter,
            }]
        })
        cell_names.append(cell['cell_name'])
    logger.log_info_to_console(f"Setting qrxlev parameter in BTS{bts_id} for cells {sorted(cell_names)}, "
                               f"to {qrx_level}", log_hierarchy=log_hierarchy)
    gnb_commissioning = GnbCommissioning()
    gnb_commissioning.perform_bts_delta_commissioning(delta=delta, bts_id=bts_id)


def prepare_bts_before_call(log_hierarchy=2):
    """
    Prepares the BTS before making a call.

    This method retrieves all cells from the BTS and performs QRXLEV recommissioning on them.
    It sets the QRXLEV parameter for each cell to max level .

    Parameters:
    log_hierarchy (int): The logging hierarchy level. Default is 2.
    """
    bts_list = BuiltIn().get_variable_value('${tl.gnbs}')
    if bts_list:
        for bts_id in range(len(bts_list)):
            all_cell_list = get_all_cells_from_bts(bts_id=bts_id)
            perform_qrxlev_recommissioning(cell_list=all_cell_list, bts_id=bts_id, log_hierarchy=log_hierarchy)
    else:
        raise NoGnbInTestLineConfigFile("No gNB defined in test line config file")
