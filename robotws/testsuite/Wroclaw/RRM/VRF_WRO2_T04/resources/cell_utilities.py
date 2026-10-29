import os
from robot.api import logger
from taf.config.scf import scf
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.regression.global_variables import bts_prefix, nrbts_id, mrbts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.admin_session import AdminSession
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.delta_utils import load_delta_template, DELTA_DIR, update_parameter

LOCALHOST = '127.0.0.1'

scf = scf()


def get_cells_identifiers(identifier, cell_type="nr", remote_host=LOCALHOST):
    """
    identifier takes two values: 'physicalCellId' or 'globalCellId'
    """
    with AdminSession(remote_host) as admin:
        cell_list = [str(cell[identifier]) for cell in admin.get_cells_info(cell_type=cell_type)]
    return cell_list


def calculate_nr_cell_identity(pci):
    distname = "{}".format(bts_prefix)
    cell_id = get_cell_id(pci)
    bts_id_length = get_bts_id_length_from_scf(
        parameter_abbreviation="gNbIdLength", parameter_dist_name=distname
    )
    cell_id_bin_as_str = str(bin(int(cell_id)))[2:].zfill(14)
    bts_id_bin_as_str = str(bin(int(nrbts_id)))[2:].zfill(int(bts_id_length))
    nci = int(bts_id_bin_as_str + cell_id_bin_as_str, 2)
    return nci


def get_cell_id(pci):
    with AdminSession() as admin:
        cells_dict = {}
        cells_info = admin.get_cells_info()
        for i in range(len(cells_info)):
            cells_dict.update(
                {cells_info[i]["physicalCellId"]: cells_info[i]["globalCellId"]}
            )
        return cells_dict[int(pci)]


def get_bts_id_length_from_scf(
    parameter_abbreviation=None, path=None, parameter_dist_name=None
):
    if not path:
        path = download_scf()
    scf.load_scf(path)
    return scf.get_value_from_scf(
        dist_name=parameter_dist_name, p_name=parameter_abbreviation
    )


def download_scf(file_name="scf.xml"):
    local_dir_path = BuiltIn().get_variable_value("${OUTPUT DIR}") + "/"
    with AdminSession() as admin:
        scf = admin.get_current_scf_file(
            local_dir_path=local_dir_path, file_name=file_name
        )
    return scf


def set_preferred_cell(cell_id, cell_type='nr', lnbts_id=None, preferred_value=-65):
    """
    :param cell_id: cell id or cells separated by comma
    """
    with AdminSession() as admin:
        cell_ids = [cell['globalCellId'] for cell in admin.get_cells_info(cell_type=cell_type)]
    if cell_type == 'lte' and not lnbts_id:
        raise RuntimeError("Missing lnbts_id parameter! Param is required when cell_type is lte.")
    if isinstance(cell_id, str):
        cell_id = cell_id.split(',')
    for cell in cell_id:
        cell_ids.remove(int(cell))
    qrx_preffered = preferred_value if cell_type == 'nr' else -130
    qrx_not_preffered = -22 if cell_type == 'nr' else -44
    logger.info("Setting preferred cell to: {}".format(cell_id))
    logger.info(f"Setting qRxLevMin={qrx_preffered} for cell: {cell_id}", also_console=True)
    logger.info(f"Setting qRxLevMin={qrx_not_preffered} for cells: {sorted(cell_ids)}", also_console=True)
    delta_template = 'qrx_delta.jinja2' if cell_type == 'nr' else 'qrx_delta_lte.jinja2'
    template = load_delta_template(os.path.join(DELTA_DIR, delta_template))
    delta = template.render(cell_id=cell_id, cell_ids=cell_ids, mrbts_id=mrbts_id, nrbts_id=nrbts_id, lnbts_id=lnbts_id)
    logger.debug(delta)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta)


def set_cell_to_barred(cell_id, mrbts=mrbts_id, remote_host='127.0.0.1'):
    _set_cell_param('cellBarred', 'barred', cell_id, mrbts=mrbts, remote_host=remote_host)


def set_cell_to_not_barred(cell_id, mrbts=mrbts_id, remote_host='127.0.0.1'):
    _set_cell_param('cellBarred', 'notBarred', cell_id, mrbts=mrbts, remote_host=remote_host)


def set_cell_as_reserved_for_operator(cell_id, mrbts=mrbts_id, remote_host='127.0.0.1'):
    _set_cell_param('cellReservedForOperatorUse', 'reserved', cell_id, mrbts=mrbts, remote_host=remote_host)


def set_cell_as_notreserved_for_operator(cell_id, mrbts=mrbts_id, remote_host='127.0.0.1'):
    _set_cell_param('cellReservedForOperatorUse', 'notReserved', cell_id, mrbts=mrbts, remote_host=remote_host)


def _set_cell_param(param, value, cell_id, mrbts, remote_host):
    dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell}'.format(mrbts_id=mrbts, nrbts_id=mrbts, cell=cell_id)
    update_parameter(param, value, dist_name, remote_host)


def block_all_lte_cells(remote_host='127.0.0.1'):
    with AdminSession(remote_host=remote_host) as admin:
        admin.block_all_cells(rat='LTE')


def unblock_all_lte_cells(remote_host='127.0.0.1'):
    with AdminSession(remote_host=remote_host) as admin:
        admin.unblock_all_cells(rat='LTE')


def unset_preferred_cell(cell_type='nr', lnbts_id=None):
    if cell_type == 'lte' and not lnbts_id:
        raise RuntimeError("Missing lnbts_id parameter! Param is required when cell_type is lte.")
    with AdminSession() as admin:
        cell_ids = [cell['globalCellId'] for cell in admin.get_cells_info(cell_type=cell_type)]
    qrx_preferred = -65 if cell_type == 'nr' else -130
    logger.info(f"Setting default qrxLevin {qrx_preferred} value for all {cell_type} cells", also_console=True)
    delta_template = 'qrx_reset.jinja2' if cell_type == 'nr' else 'qrx_reset_lte.jinja2'
    template = load_delta_template(os.path.join(DELTA_DIR, delta_template))
    delta = template.render(cell_ids=cell_ids, mrbts_id=mrbts_id, nrbts_id=nrbts_id, lnbts_id=lnbts_id)
    logger.debug(delta)
    with AdminSession() as admin:
        admin.perform_delta_recommissioning(delta)
