
import re
import pathlib
import logging
import base64
import zlib

from testsuite.Ulm.resources.Common.python import gnb
from testsuite.Ulm.resources.Common.python import coam_parameter
from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper as sshsw

logger = logging.getLogger(__name__)

CACHED_SCF = None
distname_storage = {}


def ensure_connection(func):
    def wrapper(*args, **kwargs):
        connection = None
        if kwargs.get('connection', None) is None:
            logging.debug('no connection passed to function %s', func.__name__)
            connection = sshsw.oam_http_session()
            kwargs.update({'connection': connection})
            logging.debug('connection object has been created with alias: %s', connection)
        result = func(*args, **kwargs)
        if connection:
            sshsw.oam_http_session_td(connection)
            logging.debug('connection has been cut for alias %s', connection)
        return result
    return wrapper


@ensure_connection
def get_nrbts_distnames(mrbts='[0-9]+', nrbts='[0-9]+', connection=None, scf=None):
    """
        returns list of the distnames for nrbts
        e.x.
            [
                MRBTS-1/NRBTS-1,
                MRBTS-1/NRBTS-2,
                ...
            ]
    """
    return get_distnames(f"MRBTS-{mrbts}/NRBTS-{nrbts}", scf=scf, connection=connection)


@ensure_connection
def get_nrcell_distnames(mrbts='[0-9]+', nrbts='[0-9]+', cell='[0-9]+', connection=None, scf=None):
    """
        returns list of the distnames for nrcell
        e.x.
            [
                MRBTS-1/NRBTS-1/NRCELL-1,
                MRBTS-1/NRBTS-1/NRCELL-2,
                ...
            ]
    """
    return get_distnames(f"MRBTS-{mrbts}/NRBTS-{nrbts}/NRCELL-{cell}", scf=scf, connection=connection)


@ensure_connection
def get_nrpqmap_distnames(mrbts='[0-9]+', nrbts='[0-9]+', cell='[0-9]+', nrpmqap_ids=None, connection=None, scf=None):
    """
        returns list of the distnames for nrpqmap
    """
    if nrpmqap_ids is None:
        nrpmqap_ids = [1]
    distnames_nrcell = get_nrcell_distnames(mrbts=mrbts, nrbts=nrbts, cell=cell, scf=scf, connection=connection)
    dist_nrpmqap_per_cell = []
    for distname_nrcell in distnames_nrcell:
        for nrpmqap_id in nrpmqap_ids:
            dist_nrpmqap_per_cell.append(f"{distname_nrcell}/PLMN-PLMN/NRPMQAP-{nrpmqap_id}")
    return dist_nrpmqap_per_cell


@ensure_connection
def get_plmn_distnames(connection=None, scf=None):
    """
        returns list of the distnames for plmn
        e.x.
            [
                MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-311/MNC-489,
                MRBTS-1/NRBTS-1/PLMN-PLMN/MCC-001/MNC-001
                ...
            ]
    """
    distnames_nrbts = get_nrbts_distnames(
        connection=connection, scf=scf)
    dist_nrbts_w_plmn = []
    plmns = get_plmns_from_scf(connection=connection, scf=scf)
    for plmn in plmns:
        for distname_nrbts in distnames_nrbts:
            dist_nrbts_w_plmn.append(f"{distname_nrbts}/PLMN-PLMN/MCC-{plmn[0]}/MNC-{plmn[1]}")
    dist_nrbts_w_plmn.sort(key=natural_sort)  # always remember: sort returns nothing! it is a mutator.
    return dist_nrbts_w_plmn


@ensure_connection
def get_plmn_per_cell_distnames(cell='[0-9]+', connection=None, scf=None):
    """
        returns list of the distnames for plmn per cell
        e.x.
            [
                MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489,
                MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-002/MNC-002,
                ...
            ]
    """
    distnames_nrcell = get_nrcell_distnames(cell=cell, scf=scf)
    dist_plmn_per_cell = []
    plmns = get_plmns_from_scf(connection=connection, scf=scf)
    for plmn in plmns:
        for distname_nrcell in distnames_nrcell:
            dist_plmn_per_cell.append(f"{distname_nrcell}/PLMN-PLMN/MCC-{plmn[0]}/MNC-{plmn[1]}")
    dist_plmn_per_cell.sort(key=natural_sort)  # always remember: sort returns nothing! it is a mutator.
    return dist_plmn_per_cell


@ensure_connection
def get_nrrell_distnames(mrbts='[0-9]+', nrbts='[0-9]+', cell='[0-9]+', nrrel='[0-9]+', connection=None, scf=None):
    """
        returns list of the distnames for NRREL
        e.x.
            [
                MRBTS-1/NRBTS-1/NRCELL-1/NRREL-1,
                MRBTS-1/NRBTS-1/NRCELL-2/NRREL-1,
                ...
            ]
    """
    return get_distnames(f"MRBTS-{mrbts}/NRBTS-{nrbts}/NRCELL-{cell}/NRREL-{nrrel}", scf=scf, connection=connection)


@ensure_connection
def get_slice_per_plmn_distnames(snssai='[0-9]+', connection=None, scf=None):
    """
        returns list of the distnames for plmn per cell
        e.x.
            [
                MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-1/SD-1,
                MRBTS-1/NRBTS-1/NRCELL-1/PLMN-PLMN/MCC-311/MNC-489/PLMN-PLMN/SST-2/SD-2,
                ...
            ]
    """
    distnames_nrbts = get_nrbts_distnames(connection=connection, scf=scf)
    distnames_snssai = get_distnames(f"MRBTS-[0-9]+/NRBTS-[0-9]+/SNSSAI-{snssai}", scf=scf, connection=connection)
    dist_nrbts_w_plmn = []
    plmns = get_plmns_from_scf(connection=connection, scf=scf)
    for plmn in plmns:
        for distname_nrbts in distnames_nrbts:
            dist_nrbts_w_plmn.append(f"{distname_nrbts}/PLMN-PLMN/MCC-{plmn[0]}/MNC-{plmn[1]}")

    dist_slice_per_plmn = []
    for distname_snssai in distnames_snssai:
        sst = coam_parameter.get_single_value_from_scf_file(parameter='sst', dist_name=distname_snssai,
                                                            connection=connection)
        sd = coam_parameter.get_single_value_from_scf_file(parameter='sd', dist_name=distname_snssai,
                                                           connection=connection)
        for distname in dist_nrbts_w_plmn:
            dist_slice_per_plmn.append(f"{distname}/PLMN-PLMN/SST-{sst}/SD-{sd}")
    dist_slice_per_plmn.sort(key=natural_sort)  # always remember: sort returns nothing! it is a mutator.
    logger.debug("get_slice_per_plmn_distnames: %s", dist_slice_per_plmn)
    return dist_slice_per_plmn


@ensure_connection
def get_plmns_from_scf(mrbts='[0-9]+', nrbts='[0-9]+', nrplmn='[0-9]+', connection=None, scf=None):
    """
        returns list of the plmn which is a list containg mcc and mnc
        e.x.
            [
                [389, 486], [001, 001], [002, 002]
            ]
    """
    distnames_nrplmn = get_distnames(
        f"MRBTS-{mrbts}/NRBTS-{nrbts}/NRPLMN-{nrplmn}", scf=scf, connection=connection)
    plmns = []
    for distname_nrplmn in distnames_nrplmn:
        mcc = coam_parameter.get_single_value_from_scf_file('mcc',
                                                            dist_name=distname_nrplmn,
                                                            connection=connection)
        mnc = coam_parameter.get_single_value_from_scf_file('mnc',
                                                            dist_name=distname_nrplmn,
                                                            connection=connection)
        plmns.append([mcc, mnc])
    logger.debug("get_plmns_from_scf: %s", plmns)
    return plmns


@ensure_connection
def get_distnames(regex, scf=None, connection=None):
    logger.debug("===== start: get_distnames(%s) =====", regex)
    global CACHED_SCF
    scf = CACHED_SCF if scf is None else scf
    if scf is not None and len(scf) < 4096 and pathlib.Path(scf).is_file():
        logger.debug("scf is a path")
        with open(scf, "r", encoding="utf-8") as rstream:
            scf = rstream.read()
    if regex in distname_storage:  # if regex was searched before, then just return that
        logger.debug("get_distnames: get from storage: %s", distname_storage[regex])
        return distname_storage[regex]
    try:
        distnames = None
        if scf is None:
            scf = sshsw.get_admin_obj().get_scf(connection=connection)
            CACHED_SCF = scf
        distnames = gnb.get_distNames_from_scf(regex, scf)
        distnames.sort(key=natural_sort)  # always remember: sort returns nothing! it is a mutator.
    except sshsw.Exc.AdminConnectionError as e:
        logger.exception(e)

    if distnames is None or len(distnames) == 0:
        logger.debug(" - Failed to get distnames: %s, %s, %s, scf: %s",
                     distnames, regex, connection, scf)
    distname_storage[base64.b64encode(zlib.compress(bytes(scf, 'utf-8'))).decode()] = {
        regex: distnames
    }
    logger.debug("get_distnames: %s", distnames)
    logger.debug("===== end: get_distnames() =====")

    return distnames


def natural_sort(text):
    return [(lambda text: int(text) if text.isdigit() else text)(c) for c in re.split(r'(\d+)', text)]


def _main():
    # nrbts_distnames = get_nrbts_distnames()
    plmns = get_slice_per_plmn_distnames()
    print(f"plmns: {plmns}")


if __name__ == "__main__":
    _main()
