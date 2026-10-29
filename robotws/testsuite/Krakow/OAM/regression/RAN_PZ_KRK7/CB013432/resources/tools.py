from taf.rfrl.bts.devices.exceptions import InvalidStatuses
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from wlan_generic_asir import WlanGenericAsir
from typing import NoReturn
import time


wlan_asir = WlanGenericAsir()


def verify_operational_antmod_status(ant_ids: list = [1], bts_id: int = 0) -> NoReturn:
    expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes',
                         'localState': 'unblocked', 'hardwareState': 'working',
                         'softwareState': 'detected',
                         'fronthaulStatusLedColor': 'Off', 'rfStatusLedColor': 'Off',
                         'unitStatusLedColor': 'Off'}
    GnbAsirHubOperations().verify_antmod_status([1], expected_statuses, 0)


def connect_to_asir_by_wlan(wlan_host: str, wlan_alias: str) -> NoReturn:
    wlan_asir.connect(wlan_host, wlan_alias)


def disconnect_wlan_asir_connect() -> NoReturn:
    wlan_asir.disconnect()


def update_aisr_parmeter_maxParallelUserSessions(value: str) -> NoReturn:
    asir_operations = GnbAsirHubOperations()
    delta_plan = [{'distName': 'ASI-1/SECPRM-1',
                   'parameters': [{
                                   'operation': 'update',
                                   'parameterName': 'maxParallelUserSessions',
                                   'value': value}]}]
    asir_operations.perform_asir_recommissioning(delta_plan)


def wait_for_all_hubmods_is_operational(timeout: int = 60) -> NoReturn:
    asir_operations = GnbAsirHubOperations()
    expected_statuses = {'operationalState': 'enabled', 'commissioned': 'Yes', 'localState': 'unblocked',
                         'hardwareState': 'working', 'softwareState': 'configured', 'activeStatusLEDColor': 'Green',
                         'faultStatusLEDColor': 'Off', 'powerStatusLEDColor': 'Green'}
    start_time = time.time()
    while time.time() - start_time < timeout:
        try:
            asir_operations.verify_status_of_all_hubmods(expected_statuses)
        except InvalidStatuses:
            logging.info("Waiting for all humods to be operational...")
            time.sleep(30)
            continue
        finally:
            break
    else:
        raise InvalidStatuses("Hubmods not operational")
