"""
:author: Mateusz Potoniec
:contact: mateusz.potoniec@nokia.com
:maintainer: mateusz.potoniec@nokia.com
"""

from robot.api import logger
from robot.api.deco import keyword

from taf.rfrl.bts.helpers.sw_versions import SbtsSwVersion
from taf.sbts.oam.coam.admin.interface import admin
from taf.internal.sbts.admin import exceptions as admin_exceptions


class SWNotDetectedException(Exception):
    pass


TEST_TO_QC_ID_MAP = {
    "E2E_TL_Activation_Reset_with_OAM_KPI": {
        "SBTS00": "272095",
        "SBTS26R1": "275300"
    }
}


@keyword()
def get_sw_from_bts():
    """
    Retrieves the software versions for gNB from BTS.

    The function detects the software versions for gNB and eNB using the REST API.
    If the software release is TRUNK, it replaces part of the version with 'SBTS00'.

    Returns:
        tuple: SW versions from gNB.
    """

    sw_gnb = detect_bts_sw_version_via_rest_api()
    if get_release_from_sw(sw_gnb) == 'SBTS00':
        trunk_release = sw_gnb[0:8]
        sw_gnb = sw_gnb.replace(trunk_release, 'SBTS00')

    return sw_gnb


@keyword()
def get_qc_tag_from_release(test_name: str, release: str) -> str:
    """
    Retrieves the QC test ID based on the test name and BTS software release.

    Args:
        test_name (str): The name of the test.
        release   (str): Release of BTS SW.

    Returns:
        str: The QC test ID corresponding to the given test name and BTS software release.

    Raises:
        KeyError: If the test name or BTS software release is not found in the mapping.
    """

    logger.debug("Getting QC ID from test name and BTS SW release.")
    qc_test_id = TEST_TO_QC_ID_MAP[test_name][release]
    logger.info(f"For test {test_name} QC test ID is: {qc_test_id}.")
    return qc_test_id


@keyword()
def get_release_from_sw(bts_sw: str) -> str:
    """
    Retrieves the BTS software release version.

    Args:
        bts_sw Software of BTS.

    Returns:
        str: The BTS software release version.

    Raises:
        SWNotDetectedException: If the BTS software version cannot be detected.
    """

    logger.debug("Getting release from BTS SW.")
    bts_sw_release = SbtsSwVersion(bts_sw).release
    logger.info(f"BTS SW Release is: {bts_sw_release}.")
    return bts_sw_release


@keyword()
def detect_bts_sw_version_via_rest_api(bts_host: str = '192.168.255.129',
                                       bts_port: int = 443,
                                       username: str = 'Nemuadmin',
                                       password: str = 'nemuuser',
                                       timeout: int = 30) -> str:
    """
    Detects the BTS software version via REST API.

    Args:
        bts_host (str): The IP address of the BTS host. Default is '192.168.255.129'.
        bts_port (int): The port to connect to the BTS. Default is 443.
        username (str): The username for login. Default is 'Nemuadmin'.
        password (str): The password for login. Default is 'nemuuser'.
        timeout (int): The connection timeout in seconds. Default is 30.

    Returns:
        str: The BTS software version.

    Raises:
        SWNotDetectedException: If the connection to the BTS is not possible via REST API.
    """

    admin_rest_api = admin()
    connection = None

    try:
        logger.debug("Try to connect to BTS via Rest API.")
        connection = admin_rest_api.connect_to(bts_host, bts_port, username, password, timeout)
        logger.debug("Connection successful. Try to get SW from BTS.")
        bts_sw = connection.get_sw_version()
        logger.debug("BTS SW check successful.")
    except (admin_exceptions.AdminApiConnectionClosedException, admin_exceptions.AdminApiProcedureFailureException,
            admin_exceptions.AdminApiNoResponseException, admin_exceptions.AdminApiTerminatedException) as error:
        logger.error(f"Error: Connection to BTS is not possible via REST API: {error}")
        raise SWNotDetectedException(f"Error: Connection to BTS is not possible via REST API: {error}")
    finally:
        if connection is not None:
            logger.debug("Close admin connection to BTS.")
            admin_rest_api.teardown()
            logger.debug("Admin connection closed.")

    logger.info(f"Detected BTS SW: {bts_sw}.")
    return bts_sw
