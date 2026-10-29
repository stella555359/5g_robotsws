
import re
import pathlib
import logging

import taf.config.scf
from testsuite.Ulm.ET.Performance_Test.resources.python import taf_transport_ssh_wrapper as sshw
from testsuite.Ulm.ET.Performance_Test.resources.python import perf_distnames

logger = logging.getLogger(__name__)
SCF_OBJ = [None, None]
SCF_IS_MODIFIED = False
CACHED_LOGS = []


def modify_scf(scf_path, scf_name, tp, oam_alias, target=None):
    if tp["SCF_ENABLE_COMMISSIONING"].lower() == "false":
        return ("", scf_path)
    target = pathlib.Path(scf_path).parent if target is None else pathlib.Path(target)
    scf_updated = str(target.joinpath(scf_name))
    if tp['ENABLE_MARVIN'].lower() == 'true':
        configure_marvin(scf_path, tp["CFG_MARVIN_ID_TYPE"], tp["CFG_MARVIN_ID_MODE"], oam_alias)
    else:
        get_scf_obj().load_scf(scf_path)

    # add all scf changes here #####

    get_scf_obj().save_scf(scf_updated)

    return ("\n".join(cached_log("")), scf_updated)


def configure_marvin(scf_path: str, id_type: str, id_mode: str, oam_alias: str):
    cached_log("Configure Marvin")
    original_btsid = perf_distnames.get_distnames(r"MRBTS-[0-9]+", scf=scf_path, connection=oam_alias)[0].split("-")[1]
    if id_type == "ipaddr":
        unique_id = get_unique_id_by_ip(oam_alias, split=0)
    else:
        unique_id = get_unique_id_by_hostname(oam_alias)
    if id_mode == "mrbts_only":
        scf_mod = change_mrbts_nrbts_index(scf_path, unique_id, None)
    else:
        scf_mod = change_mrbts_nrbts_index(scf_path, unique_id, unique_id)
    cached_log(f"   - Changed BTSID from {original_btsid} to {unique_id}")
    get_scf_obj().load_scf(scf_mod)
    # change_all_nrrel_gnbid(scf_mod, original_btsid, unique_id)


def change_mrbts_nrbts_index_to_testline_by_ip(scf_path: str, vm_connection: str, split: int = 2) -> str:
    unique_id = get_unique_id_by_ip(vm_connection, split)
    return change_mrbts_nrbts_index(scf_path, unique_id, unique_id)


def change_mrbts_nrbts_index_to_testline_by_hostname(scf_path: str, vm_connection: str) -> str:
    unique_id = get_unique_id_by_hostname(vm_connection)
    return change_mrbts_nrbts_index(scf_path, unique_id, unique_id)


def get_unique_id_by_ip(vm_connection=sshw.CONST_CORE_ALIAS, split: int = 0) -> str:
    ipaddr = sshw.execute(r"ip -o route get to 8.8.8.8 | sed -n 's/.*src \([0-9.]\+\).*/\1/p'",
                          connection=vm_connection).rstrip()
    return ipaddr.split(".", maxsplit=split)[split].replace(".", "")


def get_unique_id_by_hostname(vm_connection=sshw.CONST_CORE_ALIAS):
    sshw.ssh_connect(alias=vm_connection)
    hostname = sshw.execute(r"hostname", connection=vm_connection).rstrip()
    return re.sub(r"([0-9]+)-([0-9]+)-.*[A-Za-z]([0-9]+)", r"\1\2\3", hostname)


def change_mrbts_nrbts_index(scf_path: str,
                             new_mrbts: str = None,
                             new_nrbts: str = None,
                             scf_name: str = 'scfc_unique_id.xml',
                             target: str = None) -> str:
    if target is None:
        scf_path_unique_id = str(pathlib.Path(scf_path).parent.joinpath(scf_name))
    else:
        scf_path_unique_id = str(pathlib.Path(target).joinpath(scf_name))
    with open(scf_path, 'r', encoding='utf-8') as rstream:
        scf_orig = rstream.read()
    scf_mod = scf_orig
    if new_mrbts:
        scf_mod = re.sub(r"MRBTS-[0-9]+", f"MRBTS-{new_mrbts}", scf_mod)
    if new_nrbts:
        scf_mod = re.sub(r"NRBTS-[0-9]+", f"NRBTS-{new_nrbts}", scf_mod)
    with open(scf_path_unique_id, 'w', encoding='utf-8') as wstream:
        wstream.write(scf_mod)
    return scf_path_unique_id


def change_all_nrrel_gnbid(scf_path: str, gnbid: str, new_gnbid: str, connection: str = None) -> None:
    nrrell_distnames = perf_distnames.get_nrrell_distnames(scf=scf_path, connection=connection)
    if len(nrrell_distnames) > 0:
        cached_log(f"   - Change all nrrel value from {gnbid} to {new_gnbid}")
        for dist_name in nrrell_distnames:
            nrid = get_value_from_scf(scf_file=scf_path, dist_name=dist_name, p_name="gNbId")
            logger.debug("nrid: %s, gnbid: %s, dist_name: %s", nrid, gnbid, dist_name)
            if str(nrid).rstrip() == str(gnbid).rstrip():
                scf_set_element(dist_name, "gNbId", new_gnbid)


def scf_set_element(dist_name, p_name, value):
    """modify parameter if exists, otherwise add it
    """
    readvalue = ""
    element_exist = get_scf_obj().is_element_in_object(
        dist_name=dist_name, p_name=p_name)
    if element_exist:
        try:
            readvalue = get_scf_obj().get_value_from_scf(dist_name=dist_name, p_name=p_name)
        except KeyError:
            pass
        get_scf_obj().modify_scf_element(dist_name=dist_name, p_name=p_name, value=value)
        cached_log(f"{'': >4}- Set {shorten_distname(f'{dist_name}/{p_name}')} to {value} (orig.: {readvalue})")
    else:
        get_scf_obj().add_element_to_scf(dist_name=dist_name, p_name=p_name, value=value)
        cached_log(f"{'': >4}- Added {shorten_distname(f'{dist_name}/{p_name}')} to {value}")
    scf_modified_flag(flag=True)


def get_current_scf_file(target_dir="/tmp", gnb_id=0, component="DU", scfname=None, remote_ip=None, retries=3,
                         no_cache=False):
    if scfname is None:
        scfname = f"SCFC_gNB{gnb_id}_{component}.xml"
    if pathlib.Path(f"{target_dir}/{scfname}").is_file() and not no_cache:
        return f"{target_dir}/{scfname}"
    with sshw.oam_http_session_context(remote_ip=remote_ip, retries=retries) as oam_alias:
        sshw.get_admin_obj().get_current_scf_file(
            target_dir, scfname, timeout=30, connection=oam_alias)
        return f"{target_dir}/{scfname}"


def get_value_from_scf(*args, scf_file=None, gnb_id=0, component='DU', target_dir="/tmp", no_cache=False, **kwargs):
    if scf_file is None:
        scf_file = get_current_scf_file(gnb_id=gnb_id,
                                        component=component, target_dir=target_dir, no_cache=no_cache)
    get_scf_obj(instance=1).load_scf(scf_file)
    return get_scf_obj(instance=1).get_value_from_scf(*args, **kwargs)


def get_scf_obj(instance=0):
    global SCF_OBJ
    if SCF_OBJ[instance] is None:
        logger.debug("instantiate taf.config.scf.scf(%s)", instance)
        SCF_OBJ[instance] = taf.config.scf.scf()
    return SCF_OBJ[instance]


def scf_modified_flag(flag=None):
    global SCF_IS_MODIFIED
    if flag is not None:
        SCF_IS_MODIFIED = flag
    return SCF_IS_MODIFIED


def shorten_distname(name):
    return "/".join(name.split('/')[2:]) if len(name.split('/')) > 3 else name


def cached_log(log):
    global CACHED_LOGS
    CACHED_LOGS.append(log)
    return CACHED_LOGS
