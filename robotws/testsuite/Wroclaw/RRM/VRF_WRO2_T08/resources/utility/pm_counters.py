from time import sleep, time

from taf.internal.sbts.admin.exceptions import (
    AdminApiException, AdminApiProcedureTimeoutException)
from taf.rfrl.procedures.resources.python.connections import \
    get_http_connection_credentials
from taf.sbts.oam.coam.admin import admin, admin_interface_context

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

api = admin()


def wait_for_next_pm_interval_and_get_counters(counter_ids, admin_connection=None, reference_point=None, timeout=960):
    """
    Collect PM counter values. Function poll BTS (via 'get_pm_counters' method from taf.sbts.oam.coam.admin library)
    until all requested counters are updated. If reference_point is provided, it filters out 'old' counters leaving
    only counters that were generated after the last one in reference.
    example return value:
    {
     'BTS/BTS/NRBTS-50819/PDCP1/M55319C02009': [('1675548000', 0),
                                                ('1675548900', 9243701)]
    }

    :param counter_ids: Counter ids to be collected, eg. 'M51363C7' or ['M51363C7', 'M51363C8']
    :type counter_ids: list
    :param admin_connection: taf.sbts.oam.coam.admin AdminConnection object (result of Setup Admin). If not provided,
                             it tries to connect to first GNB from ${tl} object of taf.config.testline
    :type admin_connection: AdminConnection
    :param reference_point: return value of previous call to this function
    :type reference_point: dict
    :param timeout: maximum wait time for counters to update in seconds
    :type timeout: int
    :raises: AdminApiProcedureTimeoutException
    :returns: dict where keys are counter dist names and values are lists of tuples (<timestamp>, <counter_value>
    """

    if admin_connection is None:
        creds = get_http_connection_credentials("GNB", 0)
        with admin_interface_context(
            bts_host=creds["ip"], bts_port=creds["port"], username=creds["username"], password=creds["password"]
        ) as admin_connection:
            return wait_for_next_pm_interval_and_get_counters(
                counter_ids, admin_connection, reference_point=reference_point
            )

    counters_dict = _wait_for_new_pm_interval_update_and_get_all_counters(counter_ids, admin_connection, timeout)
    reference_point = {} if reference_point is None else _create_reference_point(reference_point, counter_ids)
    return _filter_counters(counters_dict, counter_ids, reference_point)


def _wait_for_new_pm_interval_update_and_get_all_counters(counter_ids, admin_connection, timeout):
    if isinstance(counter_ids, str):
        counter_ids = [counter_ids]
    counters_dict = _request_counters_from_bts(counter_ids, admin_connection)
    update_reference_point = _create_reference_point(counters_dict, counter_ids)
    full_dn_counter_ids = list(update_reference_point.keys())
    start_time = time()
    while True:
        if time() - start_time > timeout:
            raise TimeoutError(f"Not all counters have updated during {timeout}s period")
        counters_dict = _request_counters_from_bts(counter_ids, admin_connection)
        updated_counters = _filter_counters(counters_dict, counter_ids, update_reference_point)
        if _all_counters_are_updated(updated_counters, full_dn_counter_ids):
            return counters_dict
        sleep(10)


def _request_counters_from_bts(counter_ids, admin_connection, retries=3):
    counter_ids_string = ",".join(counter_ids)
    for retry in range(retries + 1):
        try:
            return api.get_pm_counters(counter_ids=counter_ids_string, connection=admin_connection, timeout=90)
        except AdminApiException as e:
            logger.info("Request for counters failed with AdminApi error:", also_to_console=False)
            logger.info(e, also_to_console=False)
            if retry < retries:
                logger.info(f"Retrying counters request... ({retry+1}/{retries})", also_to_console=False)
            api.reset_admin(connection=admin_connection)
            sleep(5)
    raise AdminApiProcedureTimeoutException("Did not receive response from BTS on getCounters request")


def _create_reference_point(counters_dict, counter_ids):
    reference_dict = _filter_counters(counters_dict, counter_ids, reference_counter_dict={})
    return {k: v[-1][0] for k, v in reference_dict.items()}


def _filter_counters(counters_dict, counter_ids, reference_counter_dict):
    unnested_dict = _unnest_counter_dict(counters_dict, counter_ids, current_keypath="")
    return {k[1:]: _get_relevant_counters(v, reference_counter_dict.get(k[1:], None)) for k, v in unnested_dict.items()}


def _unnest_counter_dict(counters_dict, counter_ids, current_keypath):
    relevant_counters = {}
    for current_key, counter_subdict in counters_dict.items():
        keypath = f"{current_keypath}/{current_key}"
        if current_key in counter_ids or current_key.split("/")[-1] in counter_ids:
            relevant_counters[keypath] = counter_subdict
        elif isinstance(counter_subdict, dict):
            relevant_counters.update(_unnest_counter_dict(counter_subdict, counter_ids, keypath))
    return relevant_counters


def _get_relevant_counters(counters_dict, only_later_than=None):
    time_threshold = only_later_than if only_later_than is not None else 0
    if isinstance(counters_dict, list):
        counters_dict = dict(counters_dict)
    relevant_counters = sorted(
        {k: v for k, v in counters_dict.items() if int(k) > int(time_threshold)}.items(), key=lambda x: int(x[0])
    )
    return relevant_counters if only_later_than is not None else relevant_counters[-1:]


def _all_counters_are_updated(updated_counters, counter_ids):
    return all(map(lambda x: len(updated_counters.get(x, [])), counter_ids))
