from taf.sbts.oam.coam.admin import admin
from ScfHandlerLogger import ScfHandlerLogger
from robot.libraries.BuiltIn import BuiltIn
from config import Config


"""
Documentation
...  AUTHORS:       sebastian.suwada@nokia.com
...  MAINTAINER:    MN_RAN_RD_VRF_WRO3_2
...  *****************
...  Basic information
...  *****************
...  The scfHandler library is designed to facilitate the retrieval and verification of information within SCF files.
...  Its primary use case is to assist users during testing by identifying missing parameters that can be configured
...  on the test line. This ensures a more streamlined and efficient testing process
...  by providing actionable insights into parameter settings.
...
...  bts_connection.py file is responsible for creating and closing BTS connection.
...  ******************
...  History of changes
...  ******************
...  https://jiradc.ext.net.nokia.com/browse/FCA_VRF_OAM-26930 - Creation of library
"""


class bts_connection:

    def __init__(self, host):
        self.host = host
        self.admin_instance = admin()
        self.log = ScfHandlerLogger()

    def __enter__(self):
        self.log.info_robot("Initialization of connection")
        return self.admin_instance.connect_to(self.host)

    def __exit__(self, *args, **kwargs):
        self.log.info_robot("Teardown of connection")
        self.admin_instance.teardown()


def get_admin_api_connection(host: str = None) -> str:
    """
    Get admin API connection and retrieve SCF file.

    Args:
        host: BTS host IP address. If None, uses config default.

    Returns:
        Path to downloaded SCF file
    """
    config = Config.get_bts_config()
    target_host = host or config['host']

    with bts_connection(host=target_host) as api:
        scfPath = api.get_current_scf_file(
            local_dir_path=BuiltIn().get_variable_value("${OUTPUT_DIR}"),
            file_name="EE_scf.xml",
            export_type="configurationAndRuntimeObjects",
            timeout=config['timeout']
        )
        return scfPath
