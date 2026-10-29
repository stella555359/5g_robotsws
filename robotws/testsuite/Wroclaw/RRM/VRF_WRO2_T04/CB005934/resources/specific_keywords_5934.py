from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.cell_utilities import calculate_nr_cell_identity


def veify_scell_swap(pcap_file, from_scell, to_scell):
    with LogHelper() as lh:
        filtered = lh.add_pcap(
            pcap_file_path=pcap_file,
            lua=None,
            shark_filter="f1ap.UEContextModificationRequest_element",
            ts_output_data_file_path=None,
            clean_up_tmp_file=False,
        )
    scell_removed = filtered.find_one(
        pm("SCell-ToBeRemoved-Item", name_line_pattern="empty")
        .containing("nRCellIdentity", "* decimal value {}*".format(calculate_nr_cell_identity(from_scell)))
     )
    scell_added = filtered.find_one(
        pm("SCell-ToBeSetupMod-Item", name_line_pattern="empty")
        .containing("nRCellIdentity", "* decimal value {}*".format(calculate_nr_cell_identity(to_scell)))
     )
    logger.info(
        "\n SCell swap from scell pci: {} to scell pci: {} done successfully\n".format(
            from_scell, to_scell
        ),
        also_console=True,
    )
