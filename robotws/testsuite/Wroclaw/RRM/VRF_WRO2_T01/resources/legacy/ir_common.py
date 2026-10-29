from time import sleep

from robot.libraries.BuiltIn import BuiltIn

import taf.hw.pdu as pdu
from taf.sbts.oam.coam.admin import admin
from taf.transport.ssh.ssh_keywords import SSHManager


def check_if_sw_changed(target_sw: str, alias: str) -> None:
    api = admin()
    current_sw = None
    while current_sw != target_sw:
        try:
            current_sw = api.get_sw_version(timeout=60, connection=alias)
            sleep(5)
        except Exception:
            continue


def close_smod_connection_if_opened(conn_alias: str) -> None:
    try:
        SSHManager().get_connection_by_alias(conn_alias)
        SSHManager().disconnect(connection=conn_alias)
        BuiltIn().log_to_console('Smod connection closed.')
    except Exception:
        BuiltIn().log_to_console('Smod connection already closed.')


def change_flag(flag: str) -> str:
    if flag == 'target':
        return 'source'
    else:
        return 'target'


def setup_pdus():
    pdu_objs = pdu.pdu()
    pdus = BuiltIn().get_variable_value('${tl.pdus}')

    for pdu_el in pdus:
        pdu_objs.setup_pdu(host=pdu_el.addr,
                           model=pdu_el.model,
                           version=pdu_el.version,
                           alias=pdu_el.addr)
    return pdu_objs


def rmod_filter(rmod_list: list, rmod_id: str) -> str:
    for rmod in rmod_list:
        if rmod[-1] == rmod_id:
            return rmod


def reset_target_rmod(pdu_ip: str, pdu_slot: int) -> None:
    pdu_objs = setup_pdus()
    pdu_objs.power_off(pdu_slot, pdu_ip)
    BuiltIn().sleep('10s')
    pdu_objs.power_on(pdu_slot, pdu_ip)


def close_uepc_connection_if_opened(conn_alias: str) -> None:
    try:
        SSHManager().get_connection_by_alias(conn_alias)
        SSHManager().disconnect(connection=conn_alias)
        BuiltIn().log_to_console('UEPC connection closed.')
    except Exception:
        BuiltIn().log_to_console('UEPC connection already closed.')


def get_dictionary_from_list(rmods_list: list, rmod_serial: str) -> dict:
    for rmod in rmods_list:
        if rmod['parameters']['serialNumber'] == rmod_serial:
            rmod_dict = rmod
            break
    try:
        return rmod_dict
    except UnboundLocalError as e:
        print(f'Target Rmod not found. Error: {e.args}')
