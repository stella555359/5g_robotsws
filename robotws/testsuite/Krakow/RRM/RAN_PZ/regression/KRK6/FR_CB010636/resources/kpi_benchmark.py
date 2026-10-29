import logging
from datetime import datetime, timedelta

from robot.api import logger
from robot.api.deco import keyword
from tzlocal import get_localzone

from taf.rfrl.procedures.resources.python.scout.scout_comparator.ScoutComparator import ScoutComparator
from taf.rfrl.bts.devices.du.sw_update import GnbSwUpdate
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.du.cell_operations import GnbCellOperations


@keyword()
def trigger_report(scout_tl_name: str, template_id: str, first_period_description: str,
                   second_period_description: str, api_key: str, reference_start_time: str,
                   reference_end_time: str, current_start_time: str, current_end_time: str):
    """
    This KW is used for triggering comparator Scout report
    and checking if the KPIs are similar between reference and current time.
    :scout_tl_name: TL name in Scout tool
    :template_id: ID of the template used to generate report
    :first_period_description: Optional for naming reference period description, like name, TC etc.
    :second_period_description: Optional for naming current period description, like name, TC etc.
    :api_key: Key used to trigger KPI report in Scout
    :reference_start_time: Time start of the reference TC
    :reference_end_time: Time end of the reference TC
    :current_start_time: Time start of the current TC
    :current_end_time: Time end of the current TC
    """
    date_format = "%Y-%m-%dT%H:%M:00.000Z"
    reference_start_time = datetime.strptime(reference_start_time, date_format)
    reference_end_time = datetime.strptime(reference_end_time, date_format)
    current_start_time = datetime.strptime(current_start_time, date_format)
    current_end_time = datetime.strptime(current_end_time, date_format)

    logger.info(f"Reference period: {reference_start_time} to {reference_end_time}")
    logger.info(f"Current period: {current_start_time} to {current_end_time}")
    alpha = '0.005'
    scout_comparator = ScoutComparator()
    scout_comparator._api_key = api_key
    logger.info(f"Triggering Scout report generation for test list: {scout_tl_name}, template ID: {template_id}")
    report_id = scout_comparator.trigger_report_generation(
        scout_tl_name=scout_tl_name,
        template_id=template_id,
        reference_start_time=reference_start_time,
        reference_end_time=reference_end_time,
        current_start_time=current_start_time,
        current_end_time=current_end_time,
        first_period_description=first_period_description,
        second_period_description=second_period_description,
        alpha=alpha
    )
    logger.info("Scout report generation triggered successfully.")
    return report_id


def correct_time_for_scout():
    start_time = datetime.now()
    return start_time.astimezone(get_localzone()).strftime("%Y-%m-%dT%H:%M:00.000Z")


@keyword()
def upgrade_bts_sw(sw_version: str) -> None:
    """
    Upgrade SW on BTS
    :param sw_version: version of bts sw used to during upgrade
    """
    logger.info('Upgrading BTS SW')
    dl_path = '/home/ute/.ute-ca/cache/bts'
    swup = GnbSwUpdate()

    sw_path = swup.download_sw_package(sw_version, dl_path)
    swup.update_software(sw_package_dir=sw_path, timeout=3600, bts_id=0)
    du_oper = GnbDuOperations()
    du_oper.wait_for_site_to_be_available(bts_id=0, timeout=600)
    logger.info('Wait for GNB0 to be on air')
    wait_for_all_cells_to_be_onair(bts_id=0, timeout=600)
    logger.info('BTSes SW Upgrade Complete')


@keyword()
def wait_for_all_cells_to_be_onair(bts_id: int = 0, timeout=900):
    logger.info('Wait for all cells to be on air')
    GnbCellOperations().wait_for_all_cells_statuses(bts_id=bts_id,
                                                    availability_status='online',
                                                    operational_state='enabled',
                                                    administrative_state='Unlocked',
                                                    blocking_state='Unblocked',
                                                    procedural_status='configured',
                                                    barring_status='unbarred',
                                                    timeout=timeout)
