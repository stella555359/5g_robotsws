"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""
import os.path
import re
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, EnvironmentIssue)
import testsuite.Oulu.TrunkEng.Common.Python.Resources.GetFileFromArchivedFolder as GetFromArchived
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import NoCooledSFPInfo


class CooledSfpCheck:
    """
    CooledSfpCheck class gets all radios that has cooled SFPs and gets the cooled sfp information from the snapshot
    files.
    """

    def __init__(self):
        self.logger = BuiltIn().get_library_instance("LOG")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.bts = BuiltIn().get_library_instance("BTS")

    def get_ru_serial_number(self, cooled_sfp):
        """
        Get RU serial number from given dist names. Serial number is needed to match the cooled SFPs to the correct
        radio unit and get the correct radio logs from snapshot.

        :param list cooled_sfp: List of dist name of the SFP that has cooled transceiver declaration set to true
        :return list: serial number of the RU that has cooled SFP
        """
        try:
            ru_serial_numbers = []
            for dist_name in cooled_sfp:
                ru_dist_name = dist_name.split("/SFP_R")[0]
                for radio in self.bts.radios:
                    if radio.dist_name and radio.dist_name == ru_dist_name:
                        if radio.serial_number:
                            info(f"Serial number for radio {radio.name} that has cooled SFP ({dist_name}) is "
                                 f"{radio.serial_number}.")
                            if radio.serial_number not in ru_serial_numbers:
                                ru_serial_numbers.append(radio.serial_number)
                        else:
                            error(f"Serial number parameter not found for {dist_name}.")
                            raise ScriptIssue(f"Serial number parameter not found for {radio.name}.")
            return ru_serial_numbers
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            error(f"Exception occurred while getting RU serial number for {dist_name}. {e.__class__.__name__}:{e}")
            raise ScriptIssue(f"Exception occurred while getting RU serial number for {dist_name}: "
                              f"{e.__class__.__name__}")

    def get_all_cooled_sfps(self):
        """
        Get all cooled sfps. Gets all SFPs that have 'Cooled Transceiver Declaration' as true
        """
        cooled_sfp = []
        try:
            sfp_mos = self.bts.admin.get_managed_objects("SFP_R", timeout=10)
            for sfp_mo in sfp_mos:
                cooled = False
                vendor = False
                dist_name = sfp_mo["distName"]
                for sfp_parameter in sfp_mo["parameters"]:
                    if 'cooledTransceiverDeclaration' == sfp_parameter:
                        if sfp_mo["parameters"][sfp_parameter] and ("/RMOD_R" in dist_name):
                            cooled = True
                    if 'vendorPartNumber' == sfp_parameter:
                        if str(sfp_mo["parameters"][sfp_parameter]) == "RTXM330-930-C39" and ("/RMOD_R" in dist_name):
                            vendor = True
                    if cooled and vendor:
                        info(f"\t'Cooled Transceiver Declaration' is set to True and on {dist_name} and 'Vendor Part "
                             f"Number' is RTXM330-930-C39 --> this is cooled SFP")
                        cooled_sfp.append(dist_name)
            return cooled_sfp
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
                AliasInUse) as admin_error:
            info(''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__)))
            error(f"Admin Exception occurred while getting cooled SFPs.{admin_error.__class__.__name__}: {admin_error}")
            raise ScriptIssue(f"Exception occurred while getting cooled SFPs: {admin_error.__class__.__name__}")
        except Exception as e:
            info(''.join(format_exception(type(e), e, e.__traceback__)))
            error(f"Exception occurred while getting cooled SFPs. {e.__class__.__name__}:{e}")
            raise ScriptIssue(f"Exception occurred while getting cooled SFPs: {e.__class__.__name__}")

    def check_cooled_sfps(self):
        """
        Check cooled sfp checks print from snapshot. Get 'SFP init can be skipped' prints from all radios in the
        environment that has cooledTransceiverDeclaration set to True.

        Print example:
        53 LINUX-0-port::0 <2025-05-29T18:49:41.077291Z> E99 INF/coco/PortControl, SFP::SfpInitSkipPolicy::
        shouldInitBeSkipped: SFP init can be skipped (reset cause: 4, SFP serial number: FR222909046).
        """
        info("Checking cooled SFP...")
        if not self.collect_logs:
            BuiltIn().get_library_instance("COLLECTLOGS")
        if not self.collect_logs.snapshot_file_name or not os.path.isfile(self.collect_logs.snapshot_file_name):
            info("Get snapshot")
            self.collect_logs.collect_snapshot(connection_name="default")
        if not self.collect_logs.snapshot_file_name or not os.path.isfile(self.collect_logs.snapshot_file_name):
            error("No snapshot file get from BTS. Unable to check 'Cooled SFP' prints from radio logs.")
            raise EnvironmentIssue("Snapshot was not get from BTS.")
        cooled_fsps = self.get_all_cooled_sfps()
        if not cooled_fsps:
            error("No cooled SFPs found from radios. Unable to check prints from snapshot.")
            raise EnvironmentIssue("No cooled SFPs found from any radio. Select suitable environment for this check.")
        ru_serials = self.get_ru_serial_number(cooled_fsps)
        info(f"Getting Cooled SFP prints from radio logs from {self.collect_logs.snapshot_file_name}")
        all_prints_found = True
        search_string = "The Max wait time for stabilization SFP is 300ms. SFP init is skipped."
        if BuiltIn().get_variable_value("${COOLED_SFP_PRINT}"):
            search_string = BuiltIn().get_variable_value("${COOLED_SFP_PRINT}")
        for serial in ru_serials:
            ru_files = self.collect_logs.get_file_from_zip_or_tar('runtime_DEFAULT.log.xz',
                                                                  archived_path=self.collect_logs.snapshot_file_name,
                                                                  folder_to_extract=self.logger.log_dir,
                                                                  upper_folder=f"{serial}_RMOD_L",
                                                                  add_name_to_get_file=f"{serial}_",
                                                                  get_multiple_files=True)

            if ru_files:
                for ru_file in ru_files:
                    found_lines, uncompressed_file = GetFromArchived.search_from_xz_gz_archive(
                        ru_file, search_string, return_multiple=True, add_to_folder="cooled_sfp_logs",
                        remove_compressed=True)
                    if found_lines:
                        info(f"Print '{search_string}' was found in {uncompressed_file} ({serial}):" + "\n\t".join(
                            line.strip() for line in found_lines))
                    else:
                        error(f"Print '{search_string}' was NOT found from {uncompressed_file} ({serial})")
                        all_prints_found = False
            else:
                error(f"File 'runtime_DEFAULT.log' is not found with serial number {serial} from snapshot. Unable "
                      f"to check cooled sfp prints of this radio.")
                all_prints_found = False
        if not all_prints_found:
            raise NoCooledSFPInfo("Not all expected prints were found from the cooled SFP radio logs. ")
        info("Cooled SFP check is passed, all expected prints were found from the cooled SFP radio logs.")
