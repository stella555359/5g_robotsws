"""
:author:  Test script team
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

import os
import re
from datetime import datetime
from traceback import format_exception
from robot.libraries.BuiltIn import BuiltIn
from taf.internal.sbts.admin.exceptions import (
    AdminApiConnectionClosedException, AdminApiProcedureFailureException, AdminApiProcedureTimeoutException,
    AdminApiNoResponseException, AdminApiTerminatedException)
from taf.internal.aliasing.exceptions import AliasLookupError
from taf.sbts.oam.coam.admin.exceptions import AliasInUse
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, SoftwareUpdateFailure,
                                                                        SoftwareRollbackFailure, EnvironmentIssue,
                                                                        InvalidUserInput, BTSConnectionFailure,
                                                                        ErrorFromAdmin, IncorrectDocxoValues,
                                                                        SwActivationNotSuccessful,
                                                                        SoftwarePrecheckFailure)
from testsuite.Oulu.TrunkEng.OMKPI.Python.Resources.exceptions import (RadioSofwareNotUpdated, FileNotFound,
                                                                       KpiValuesNotMatching, RadioSoftwareUpdateError)
from testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.ImAnalyserUsage import ImAnalyserUsage
from testsuite.Oulu.TrunkEng.OMKPI.Python.Interfaces.E2EBtsStartupCheckpoint import E2EBtsStartupCheckpoint


class OmkpiCommonInterface:
    """Class for common functionalities for OMKPI test cases"""
    branch_of_triggering_build = ""
    older_build_for_swdl = ""
    # this variable can have value intra or inter
    intra_or_inter = ""
    bts_ip = "192.168.255.129"

    def __init__(self):
        self.bts = BuiltIn().get_library_instance("BTS")
        self.syslog_search = BuiltIn().get_library_instance("SYSLOGSEARCH")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.reservation = BuiltIn().get_library_instance("ENV_RESERVATION")
        self.wft = BuiltIn().get_library_instance("WFT")
        self.admin = BuiltIn().get_library_instance("ADMIN")
        self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.scf = BuiltIn().get_library_instance("SCF")
        if BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}"):
            OmkpiCommonInterface.bts_ip = BuiltIn().get_variable_value("${DEFAULT_ADMIN_IP}")

    def get_intra_or_inter(self):
        """
        Get intra or inter.
        :return: Intra or inter.
        """
        return OmkpiCommonInterface.intra_or_inter

    def _check_if_path_valid(self, path_to_file):
        """
        Checks if path to file exists and it is file.

        :param str path_to_file: Path to file.
        Raises InvalidUserInput if path is not valid.
        """
        if not os.path.exists(path_to_file) or not os.path.isfile(path_to_file):
            error(f"File {path_to_file} that user has given doesn't exist.")
            raise InvalidUserInput
        else:
            self.logger.debug(f"{path_to_file} exists and is file")
        return True

    def _builds_given_in_testcase(self):
        """ Check if user has given special builds in test case. """
        if "${NO_BUILD_PATH_UPDATE}" in BuiltIn().get_variables() and BuiltIn().get_variable_value(
                "${NO_BUILD_PATH_UPDATE}"):
            if (self._check_if_path_valid(BuiltIn().get_variable_value("${BUILD_N}")) and
                    self._check_if_path_valid(BuiltIn().get_variable_value("${BUILD_T1}")) and
                    self._check_if_path_valid(BuiltIn().get_variable_value("${BUILD_T2}"))):
                info("User has given builds to tests.\n\tBuild given for BUILD_N is {}\n\tBuild given for BUILD_T1 is "
                     "{}\n\tBuild given for BUILD_T2 is {}".format(BuiltIn().get_variable_value("${BUILD_N}"),
                                                                   BuiltIn().get_variable_value("${BUILD_T1}"),
                                                                   BuiltIn().get_variable_value("${BUILD_T2}")))
                return True
        self.logger.debug("User has not given any specific builds in test")
        return False

    def set_build_names_and_get_packages_that_will_be_used_in_swdl(self, branch_of_active_sw, save_build_to_pc=True,
                                                                   update_path_build="", customer_build="",
                                                                   uuf_build=""):
        """
        Set build names in SWDL. If UPDATE_PATH was used when reservation was made get triggering builds. If UPDATE_PATH
        was not used, get SW builds of active SW. Get testpackage_T1_A54, testpackage_T2_A54 and A54 builds from
        artifactory.

        :param str branch_of_active_sw: Branch of active SW.
        :param str save_build_to_pc: Save build to PC. Default is True.
        :param str update_path_build: Build used in UPDATE_PATH. If UPDATE_PATH was not used empty string.
        :param str customer_build: Name of build of customer. If UUF_CUSTOMER was not used empty string.
        :param str uuf_build: Build given in UUF_BUILD. If UUF_BUILD was not used empty string.
        """

        not_the_first_loop = self.more_than_one_test_loop_current_loop_is_not_first()
        if not update_path_build:
            update_path_build = BuiltIn().get_variable_value("${UPDATE_PATH}", default="")
        if not customer_build:
            customer_build = BuiltIn().get_variable_value("${UUF_CUSTOMER}", default="")
        if not uuf_build:
            uuf_build = BuiltIn().get_variable_value("${UUF_BUILD}", default="")
        if not_the_first_loop or self._builds_given_in_testcase():
            self.logger.debug("Skip package fetch and build setting. Everything is already set.")
        else:
            if update_path_build or customer_build or uuf_build:
                triggering_build = self.reservation.get_triggering_build()
                OmkpiCommonInterface.branch_of_triggering_build = self.bts.get_branch_from_build_name(triggering_build)
                b_t1 = self.bts.get_build_from_artifactory(triggering_build, package_type="testpackage_T1_A54",
                                                           save_to_pc=save_build_to_pc)
                b_t2 = self.bts.get_build_from_artifactory(triggering_build, package_type="testpackage_T2_A54",
                                                           save_to_pc=save_build_to_pc)
                normal = self.bts.get_build_from_artifactory(triggering_build, package_type="A54",
                                                             save_to_pc=save_build_to_pc)
            else:
                b_t1 = self.bts.get_build_that_is_currently_active_on_bts(branch_of_active_sw,
                                                                          save_to_pc=save_build_to_pc, testpackage="T1")
                b_t2 = self.bts.get_build_that_is_currently_active_on_bts(branch_of_active_sw,
                                                                          save_to_pc=save_build_to_pc, testpackage="T2")
                normal = self.bts.get_build_that_is_currently_active_on_bts(branch_of_active_sw,
                                                                            save_to_pc=save_build_to_pc)
            BuiltIn().set_suite_variable("${BUILD_T1}", b_t1)
            BuiltIn().set_suite_variable("${BUILD_T2}", b_t2)
            BuiltIn().set_suite_variable("${BUILD_N}", normal)
            BuiltIn().set_suite_variable("${SWDL_FIRST}", '1')
            BuiltIn().set_suite_variable("${SWDL_SECOND}", '2')

    def check_if_specific_build_is_selected_as_base_build(self):
        """
        Check if user has given some specific build with variable ${BASE_BUILD} that should be used as a base build
        on which all SWDLs will be made.
        """
        all_suite_variables = BuiltIn().get_variables()
        print(f"All suite variables: {all_suite_variables}")
        if "${BASE_BUILD}" in all_suite_variables:
            name_of_base = BuiltIn().get_variable_value("${BASE_BUILD}")
            info(f"User has given special build that should be used as a base build: {name_of_base}")
            path_to_base = self.bts.get_build_from_artifactory(name_of_base, package_type="A54", save_to_pc=True)
            return path_to_base
        else:
            print("${BASE_BUILD} is not given")
            self.logger.debug("${BASE_BUILD} is not given")
            return ""

    def check_if_build_in_passive_side_is_same_that_is_planned_to_be_downloaded(self, planned_build, switch_order=True,
                                                                                return_boolean=False, check_ru=False):
        """
        Check if build planned to be downloaded is already on passive partition. If build is in passive side switch
         order of test packages.

        :param str planned_build: Planned build.
        :param bool switch_order: Default is True. If False no SWDL order changes will be made even if build is in
                                   passive side.
        :param bool return_boolean: If True, return True if build is in passive side, otherwise return False.
        :param bool check_ru: In addition to BTS SW checks, if this is True check if RUs has T1 or T2 software active
        """
        if not planned_build:
            error("Planned build is not given")
            raise ScriptIssue("Planned build is not given")
        build_name = self.bts.parse_sw_build_name_from_download_package(planned_build)
        if check_ru:
            ru_sw_versions = self.get_rf_sw_version(print_to_event_log=False)
            if build_name[-2:] in ("T1", "T2"):
                if [ru for ru in ru_sw_versions.values() if build_name[-2:] == str(ru)[-2:]]:
                    info(f"Software {planned_build} is already on radios")
                    if switch_order:
                        OmkpiCommonInterface.change_test_package_swdl_order()
                    return True
        if self.bts.passive_sw[self.bts.passive_sw.find('_'):] == build_name[build_name.find('_'):]:
            info(f"Build {planned_build} is already on passive side (passive SW on BTS is {self.bts.passive_sw})")
            if switch_order:
                OmkpiCommonInterface.change_test_package_swdl_order()
            if return_boolean:
                return True
        else:
            self.logger.debug(
                f"Build {build_name} (planned_build:{planned_build}) is not on passive side (passive SW on BTS is "
                f"{self.bts.passive_sw})")
            if return_boolean:
                return False
        return None

    def check_if_build_in_active_side_is_same_that_is_planned_to_be_downloaded(self, planned_build,
                                                                               boolean_return=False):
        """
        Check if build in active side is same that is planned to be downloaded. If boolean_return is True then just
         returns True/False, otherwise suite execution is stopped.

        :param str planned_build: Planned build.
        :param bool boolean_return: Default is False that will stop execution of suite if same sw that is planned.
                                    If You want just True/False return then set this to True.
        """
        if not planned_build:
            error("Planned build is not given")
            raise ScriptIssue("Planned build is not given")
        build_name = self.bts.parse_sw_build_name_from_download_package(planned_build)
        if self.bts.active_sw[self.bts.active_sw.find('_'):] == build_name[build_name.find('_'):]:
            error(f"Build {planned_build} is already on active side (active SW on BTS is {self.bts.active_sw})")
            if boolean_return:
                return True
            else:
                BuiltIn().fatal_error("Build to be downloaded is already active. Stopping execution of the suite.")
        else:
            self.logger.debug(
                f"Build {build_name} (planned_build:{planned_build}) is not on active side (active SW on BTS is "
                f"{self.bts.active_sw})")
            return False

    def build_in_passive_is_test_package_of_active_and_vice_versa(self, testpackage="T1"):
        """
        Check if sw build on passive side is testpackage of the sw build in active side or sw build on active side is
        testpackage of the sw build in passive side. If it is, return True,
        otherwise return False.
        :param str testpackage: can have value T1 or T2, default is T1.
        """
        if not self.bts.passive_sw or not self.bts.active_sw:
            error("Passive and/or active SW is not found. Check if connection to admin is working properly or if there "
                  "are some issues with HW.")
            raise EnvironmentIssue("Passive and/or active SW is not found.")
        if self.bts.active_sw in self.bts.passive_sw and testpackage in self.bts.passive_sw:
            info(f"Passive SW {self.bts.passive_sw} is {testpackage} test package of active SW {self.bts.active_sw}.")
            return True
        elif self.bts.passive_sw in self.bts.active_sw and testpackage in self.bts.active_sw:
            info(f"Active SW {self.bts.active_sw} is {testpackage} test package of passive SW {self.bts.passive_sw}.")
            return True
        else:
            info(f"Passive SW {self.bts.passive_sw} is not {testpackage} test package of active SW "
                 f"{self.bts.active_sw} nor Active SW {self.bts.active_sw} is not {testpackage} test package of "
                 f"Passive SW {self.bts.passive_sw}")
            return False

    @staticmethod
    def select_kpi_depending_on_firmware_update(firmware_was_updated, selected_kpi):
        """
        Check if firmware was updated and select KPI method.

        :param str firmware_was_updated: Firmware was updated, has value True or False.
        :param str selected_kpi: Selected KPI, can have value 'kpi 2a or 2b' or 'kpi 2c or 2d' or 'Independent Manual
                                 DU SW Activation'.
        """
        k_method = ""
        if selected_kpi in ["kpi 2a or 2b", "kpi 2c or 2d"]:
            if selected_kpi == "kpi 2a or 2b":  # inter
                info("It is defined in test case that calculated KPI should be inter KPI. Selecting method for "
                     "inter KPI.")
                if OmkpiCommonInterface.intra_or_inter and OmkpiCommonInterface.intra_or_inter != "inter":
                    warning("In test user has defined that KPI should be inter, but according parsing done in the "
                            "script the SWDL is not inter SWDL. Check if selected KPI is correct in test or if there is"
                            " some parsing problems in script.")
                if firmware_was_updated:
                    k_method = "Sw inter activation with firmware update"
                else:
                    k_method = "Sw inter activation without firmware update"
            elif selected_kpi == "kpi 2c or 2d":  # intra
                info("It is defined in test case that calculated KPI should be intra KPI. Selecting method for "
                     "intra KPI.")
                if OmkpiCommonInterface.intra_or_inter and OmkpiCommonInterface.intra_or_inter != "intra":
                    warning("In test user has defined that KPI should be intra, but according parsing done in the "
                            "script the SWDL is not intra SWDL. Check if selected KPI is correct in test or if there is"
                            " some parsing problems in script.")
                if firmware_was_updated:
                    k_method = "Sw intra activation with firmware update"
                else:
                    k_method = "Sw intra activation without firmware update"
# independent du sw upgrade
        if selected_kpi == "Independent Manual DU SW Activation":
            if OmkpiCommonInterface.intra_or_inter and OmkpiCommonInterface.intra_or_inter == "inter":
                info("Selecting method for inter KPI.")
                if firmware_was_updated:
                    k_method = "Manual DU Inter-release SW activation downtime with firmware update downtime"
                else:
                    k_method = "Manual DU Inter-release SW activation downtime without firmware update downtime"
            elif OmkpiCommonInterface.intra_or_inter and OmkpiCommonInterface.intra_or_inter == "intra":
                info("Selecting method for intra KPI.")
                if firmware_was_updated:
                    k_method = "Manual DU Intra-release SW activation downtime with firmware update downtime"
                else:
                    k_method = "Manual DU Intra-release SW activation downtime without firmware update downtime"
            else:
                error(f"Unknown variables for {selected_kpi}: OmkpiCommonInterface.intra_or_inter="
                      f"'{OmkpiCommonInterface.intra_or_inter}', but it should have intra or inter as a value.")
                raise ScriptIssue
        if k_method:
            info(f"Selected KPI is: {k_method}")
            BuiltIn().set_suite_variable("${SELECTED_KPI}", k_method)
        # else:
        #     error(f"Selected KPI {selected_kpi} is not valid")
        #     raise InvalidUserInput(f"Selected KPI {selected_kpi} is not valid for this test case")

    def _check_if_builds_given_in_testcase_and_basebuild(self, base_build, active_branch):
        """
        User has given software builds in test case, check if base_build is also given and if rollbacks should be done
        between software updates.

        :param str base_build: Base_build that user has given with parameter ${BASE_BUILD}.
        :param str active_branch: Release of active software, for example SBTS00 or SBTS24R1.
        """
        rollbacks = True
        release_of_t1 = self.bts.get_branch_from_build_name(BuiltIn().get_variable_value("${BUILD_T1}"))
        if base_build:
            OmkpiCommonInterface.older_build_for_swdl = base_build
            base_build_branch = self.bts.get_branch_from_build_name(base_build)
            if base_build_branch == release_of_t1:
                info(f"User has given BASE_BUILD and BUILD_T1 and release of the BASE_BUILD is {base_build_branch}"
                     f" that is same as BUILD_T1 has {release_of_t1} (Intra).\nRollback will be done between software"
                     f" updates.")
                OmkpiCommonInterface.intra_or_inter = "intra"
            else:
                info(f"User has given BASE_BUILD and BUILD_T1 and release of the BASE_BUILD is {base_build_branch}"
                     f" that is not the same as BUILD_T1 has {release_of_t1} (Inter).\nRollback will be done between"
                     f" software updates.")
                OmkpiCommonInterface.intra_or_inter = "inter"
        else:
            if active_branch == release_of_t1:
                rollbacks = False
                OmkpiCommonInterface.intra_or_inter = "intra"
                info(f"User has given BUILD_T1 and release of the software is {release_of_t1} it is same as active "
                     f"software has {active_branch} (Intra).\nRollback will not be done between software updates.")
            else:
                OmkpiCommonInterface.intra_or_inter = "inter"
                info(f"User has given BUILD_T1 and release of the software is {release_of_t1} it is not the same as "
                     f"active software has {active_branch} (Inter).\nRollback will be done between software updates.")
        return rollbacks

    def check_if_swdl_of_build_will_be_intra_or_inter(self, build):
        """
        Check if SWDL of build will be intra or inter. Compares release of active sw and release of given build.
        If release of build is same that is already active on BTS, SWDL will be intra, otherwise it will be inter.

        :param str build: Build name, for example SBTS25R2_ENB_9999_241217_000014 or path to build.
        """
        active_branch = self.bts.get_branch_of_active_build()
        release_of_build = self.bts.get_branch_from_build_name(build)
        if active_branch == release_of_build:
            info("Branch of active software is same as branch of build (Intra).")
            OmkpiCommonInterface.intra_or_inter = "intra"
        else:
            info("Branch of active software is not same as branch of build (Inter)")
            OmkpiCommonInterface.intra_or_inter = "inter"
        return OmkpiCommonInterface.intra_or_inter

    def check_if_swdl_intra_or_inter_and_if_rollbacks_in_test(self, release="", promotion_tag="", save_to_pc=True):
        """
        Checks if SWDL is intra or inter. Compares release (if given) and active sw, checks if UPDATE_PATH/UUF_CUSTOMER
        /UUF_BUILD has been given. Returns True if rollbacks will be done between tests and False if rollback will not
        be done between tests.

        :param str release: Release given in test, for example SBTS00 (OPTIONAL)
        :param str promotion_tag: Promotion tag, for example REGRESSION (OPTIONAL)
        :param bool save_to_pc: Default is True and then build is saved to tester PC.
        """
        rollbacks = True
        active_branch = self.bts.get_branch_of_active_build()
        base_build = self.check_if_specific_build_is_selected_as_base_build()
        if self._builds_given_in_testcase():
            rollbacks = self._check_if_builds_given_in_testcase_and_basebuild(base_build, active_branch)
        elif OmkpiCommonInterface.branch_of_triggering_build:  # triggering build exists -> rollback tests
            if active_branch == OmkpiCommonInterface.branch_of_triggering_build:
                info("Branch of active software is same as branch of triggering build (Intra).")
                OmkpiCommonInterface.intra_or_inter = "intra"
            else:
                info("Branch of active software is not same as branch of triggering build (Inter)")
                OmkpiCommonInterface.intra_or_inter = "inter"
            info("UPDATE_PATH/UUF_CUSTOMER/UUF_BUILD has been given in reservation. Rollback will be done between "
                 "software updates.")
        elif base_build:
            OmkpiCommonInterface.older_build_for_swdl = base_build
            base_build_branch = self.bts.get_branch_from_build_name(base_build)
            if active_branch == base_build_branch:
                info(f"Branch of active software is same as it is in given BASE_BUILD {base_build_branch} (Intra).")
                OmkpiCommonInterface.intra_or_inter = "intra"
            elif active_branch != base_build_branch:
                info(f"Branch of active software is not same as it is in given BASE_BUILD {base_build_branch} (Inter).")
                OmkpiCommonInterface.intra_or_inter = "inter"
            info("BASE_BUILD has been given in reservation. Rollback will be done between software updates.")
        else:
            if not release or release == '""':
                info("No release given nor UPDATE_PATH/UUF_CUSTOMER/UUF_BUILD used in reservation (Intra, no "
                     "rollbacks).")
                OmkpiCommonInterface.intra_or_inter = "intra"
                rollbacks = False
            elif release and active_branch == release:
                info(f"Branch of active software is same as given release {release} (Intra, no rollbacks).")
                OmkpiCommonInterface.intra_or_inter = "intra"
                rollbacks = False
            elif release and active_branch != release:
                info(f"Branch of active software is not same as given release {release} (Inter).")
                OmkpiCommonInterface.intra_or_inter = "inter"
                info("Rollback will be done between software updates.")
                build = self.wft.get_promoted_build(promotion_tag=promotion_tag, branch=release)
                OmkpiCommonInterface.older_build_for_swdl = self.bts.get_build_from_artifactory(
                    build, release, package_type="A54", save_to_pc=save_to_pc)
        return rollbacks

    @staticmethod
    def get_older_build_path():
        """Returns path to older software build, if the older build exists"""
        print(f"Path to older build to be downloaded: {OmkpiCommonInterface.older_build_for_swdl}")
        return OmkpiCommonInterface.older_build_for_swdl

    def get_sw_update_report_to_logs(self, admin_connection="log_admin", file_name=None, retry=0):
        """
        Get sw update report to logs gets SWDLreport.txt file from BTS. Raise error if cannot get the report.

        :param str admin_connection: Default is log_admin
        :param str file_name: Name of the file. If not given, default name is SWDLreport_<timestamp>.txt
        :param int retry: Default is 0. If 0, try to get SWDL report again once.
        """
        swdl_report = None
        try:
            if file_name:
                log_name = f"SWDLreport_{file_name.replace(' ', '_')}.txt"
                swdl_report = os.path.join(self.logger.log_dir, log_name)
            else:
                time_stamp = datetime.now().strftime("%Y%m%d_%H%M%S")
                swdl_report = os.path.join(self.logger.log_dir, f"SWDLreport_{time_stamp}.txt")
            self.admin.get_sw_update_report(swdl_report, connection=admin_connection)
            info(f"SWDL report is saved to {swdl_report}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
                AliasInUse) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            warning(f"Error noticed during getting SWDL report. {admin_error.__class__.__name__}:{admin_error} was "
                    f"raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get SWDL report from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin=admin_connection)
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_sw_update_report_to_logs again after admin connection reset.")
                    self.get_sw_update_report_to_logs(admin_connection=admin_connection, file_name=file_name,
                                                      retry=1)
                elif retry == 1:
                    error("Unable to get sw update report from admin, because of session invalidation. Admin connection"
                          " restart did not help.")
            # raise EnvironmentIssue("Error noticed during getting SWDL report.")
        return swdl_report

    def _get_size_of_build_from_ssh(self, ssh_object, sw_path, try_time=1):
        """Get size of build from SSH"""
        info(f"Get size of build from remote VM by SSH ({try_time}. try)")
        size_of_build = self.ssh.send_command_to_ip_by_ssh(
            f"ls -lha {sw_path}", ssh_object=ssh_object, return_output=True,
            ssh_timeout=60, print_to_eventlog=True, ip_to_connect=self.collect_logs.remote_vm_ip, username="ute",
            pw=self.collect_logs.remote_vm_pw, raise_error=True, disconnect_ssh=False)
        if sw_path not in size_of_build:
            if try_time < 4:
                try_time += 1
                info("Path to build was not found in the output. Try to get size of build again.")
                self._get_size_of_build_from_ssh(ssh_object, sw_path, try_time)
            else:
                error("Path to build was not found in the SSH output. Cannot get size of the build.")
                ScriptIssue("Path to build was not found in the output. Cannot get size of build.")
        else:
            pattern = re.compile(r".*\s+(?P<koko>\d+.\d+|\d+)G\s+.*")
            slist = size_of_build.split("\n")
            build_size = ""
            for i in slist:
                match = pattern.match(i)
                if match:
                    build_size = match.group("koko")
                    break
            if build_size:
                info(f"Size of build in remote VM: {build_size}G")
                if float(build_size) < 8:
                    error(f"Size of build is {build_size}G, it is too small. Size of build is expected to be at least "
                          f"8G. Build is not suitable.")
                    raise FileNotFound("Size of build is less than 8G. Build is not suitable.")
                else:
                    info("Size of sw build in remote VM is more than 8G. OK.")
                    return build_size
            else:
                error(r"Size of build was not parsed from the output {} with regex "
                      r".*\s+(?P<koko>\d+.\d+)G\s+.*".format(size_of_build))
                ScriptIssue("Wasn't able to parse the size of build from the output.")
        return None

    def _build_already_exists_on_remote_vm(self, ssh_object, sw_path):
        """
        Check if build already exists on remote VM

        :param ssh_object: SSH object.
        :param str sw_path: Path to build in remote VM.
        :return: True if build already exists on remote VM, otherwise False.
        """
        info("Check if build already exists on remote VM")
        try_time = 0
        check_if_build_exists = ""
        while try_time < 4:
            try_time += 1
            check_if_build_exists = self.ssh.send_command_to_ip_by_ssh(
                f"ls -lah {sw_path}", ssh_object=ssh_object, return_output=True,
                ssh_timeout=60, print_to_eventlog=True, ip_to_connect=self.collect_logs.remote_vm_ip, username="ute",
                pw=self.collect_logs.remote_vm_pw, raise_error=False, disconnect_ssh=False)
            if check_if_build_exists:
                if "No such file or directory" in check_if_build_exists:
                    info(f"Build {sw_path} does not exist on remote VM.")
                    return False
                else:
                    pattern = re.compile(r".*\s+(?P<koko>\d+.\d+)G\s+.*")
                    slist = check_if_build_exists.split("\n")
                    for i in slist:
                        match = pattern.match(i)
                        self.logger.debug(f"Match: {match}, {i}")
                        if match:
                            info(f"Build {sw_path} already exists on remote VM.")
                            return True
        error(f"Output from remote VM was not received properly. Cannot check if build {sw_path} already exists on "
              f"remote VM. ({check_if_build_exists})")
        raise EnvironmentIssue("Output from remote VM was not received. Cannot check if build already exists.")

    def _get_build_from_artifactory_to_remote_vm(self, ssh_object, build_to_dl, sw_path):
        """Get build from artifactory to remote VM"""
        build_on_remote_vm = self._build_already_exists_on_remote_vm(ssh_object, sw_path)
        if not build_on_remote_vm:
            if "https:" not in build_to_dl:
                self.logger.debug("No https in path, most likely the path is special build path, use scp instead")
                get_build = self.collect_logs.give_command_to_terminal(
                    f"sshpass -p {self.collect_logs.remote_vm_pw} scp {build_to_dl} "
                    f"ute@{self.collect_logs.remote_vm_ip}:{sw_path}", print_to_eventlog=True,
                    return_output=True)
            else:
                get_build = self.ssh.send_command_to_ip_by_ssh(
                    f"wget --content-on-error -P /home/ute/logs/ {build_to_dl}", ssh_object=ssh_object,
                    return_output=True, ssh_timeout=3700, print_to_eventlog=False,
                    ip_to_connect=self.collect_logs.remote_vm_ip, username="ute", pw=self.collect_logs.remote_vm_pw,
                    raise_error=True, disconnect_ssh=False, delay_before_expect=180, retry_command=False)
            if get_build and "ERROR 404: Not Found." in get_build:
                error(f"ERROR: Build '{build_to_dl}' was not found from artifactory. Cannot download build. Url "
                      f"returns ERROR: 404 Not Found")
                raise FileNotFound(f"Build '{build_to_dl}' was not found from artifactory. Cannot download build.")
            elif get_build and "No space left on device" in get_build:
                error("No space left on remote VM. Cannot download build.")
                self.collect_logs.give_command_to_terminal("df -h", print_to_eventlog=True, command_timeout=300)
                raise EnvironmentIssue("No space left on remote VM. Cannot download build.")
            elif get_build and "100%" in get_build:
                info(f"Software successfully fetched to remote VM. Path to build in remote VM: {sw_path}")
            if sw_path:
                self._get_size_of_build_from_ssh(ssh_object, sw_path)
        else:
            info("Build already in VM")

    def _swdl_on_remote_vm(self, build_to_dl, should_activate, ru_swdl_only):
        """
        Swdl on remote VM

        :param str build_to_dl: Build to download. This is path to artifactory.
        :param bool should_activate: If True, activate SW after download. Default is True.
        :param bool ru_swdl_only: If True, do only RU SWDL. Default is False and then whole BTS is doing reset.
        """
        path_to_ws = "/home/ute/MN/UTE/robotws/"
        path_to_test = f"{path_to_ws}testsuite/Oulu/TrunkEng/OMKPI/Python/Resources/rfs_lmp_swdl_on_other.py"
        sw_path = r"/home/ute/logs/{}".format(build_to_dl[build_to_dl.rfind("/") + 1:])
        info("Create SSH connection to remote VM.")
        ssh_object = self.ssh.ssh_connection_to_given_ip(
            user_name="ute", ssh_password=self.collect_logs.remote_vm_pw, ip_to_connect=self.collect_logs.remote_vm_ip,
            name_for_log="lmp_swdl", print_to_eventlog=True, raise_error=True)
        if ssh_object:
            info("SSH connection to remote VM was successful. Activate source.")
            self.ssh.send_command_to_ip_by_ssh(
                "source /home/ute/test_repo/bin/activate", ssh_object=ssh_object, return_output=False,
                ssh_timeout=60, print_to_eventlog=True, ip_to_connect=self.collect_logs.remote_vm_ip, username="ute",
                pw=self.collect_logs.remote_vm_pw, raise_error=True, disconnect_ssh=False)
            info("Source activated. Get Build to remote VM.")
            self._get_build_from_artifactory_to_remote_vm(ssh_object, build_to_dl, sw_path)
            info("Update software.")
            command = f"python {path_to_test} {sw_path} {ru_swdl_only} {should_activate}"
            output = self.ssh.send_command_to_ip_by_ssh(
                command, ssh_object=ssh_object, return_output=True,
                ssh_timeout=12000, print_to_eventlog=True, ip_to_connect=self.collect_logs.remote_vm_ip, username="ute",
                pw=self.collect_logs.remote_vm_pw, raise_error=True, disconnect_ssh=True, delay_before_expect=180,
                retry_command=False)
            print(f"Output from remote VM:\n{output}")
            # TODO ota disconnection logit vm:lta
            if "Software update has been completed" in output:
                info("Software update has been completed.")
            else:
                if ("Error when creating admin connection" in output or
                        "ERROR: No admin connection -> we cannot update software" in output):
                    error("Unable to create admin connection to remote VM when MASTER is Other and LMP_SWDL is True. "
                          "There may be issue with environment or with script. Take contact to script developers.")
                    raise EnvironmentIssue("Unable to create admin connection to Other LMP.")
                elif ("Error noticed during Software update" in output or
                      "ERROR: Unable to update software from admin" in output):
                    error("Problems with SWDL when Other MASTER and LMP_SWDL is True. Check if pronto is needed.")
                    raise SoftwareUpdateFailure
        else:
            error("SSH connection to remote VM was not successful.")
            raise EnvironmentIssue("SSH connection to remote VM was not successful.")

    def update_software_on_bts(self, build_to_dl, should_activate=True, timeout=18000, admin_connection="log_admin",
                               ru_swdl_only=False, retry=0):
        """
        Update software on BTS. Uses update_software method of taf.sbts.oam.coam.admin library.

        :param str build_to_dl: Build to download.
        :param bool should_activate: If True, activate SW after download. Default is True.
        :param int timeout: Timeout for software update. Default is 18000 seconds.
        :param str admin_connection: Default is log_admin
        :param bool ru_swdl_only: If True, do only RU SWDL. Default is False
        :param int retry: Default is 0. If 0, try to update software again once.
        """
        tb = ""
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        try:
            lmp_on_other = self.bts.check_if_rfs_other_is_master_and_lmp()
            if lmp_on_other:
                BuiltIn().set_suite_variable("${OTHER_MASTER_LMP_SWDL}", "${True}")
                info("RFS and Other is master and LMP SWDL")
                self._swdl_on_remote_vm(build_to_dl, should_activate, ru_swdl_only)
            else:
                time_1 = datetime.now()
                info(f"Time before update_software: {time_1.strftime('%Y-%m-%d %H:%M:%S')}")
                if ru_swdl_only:
                    response = self.admin.update_software(
                        build_to_dl, should_activate=should_activate, timeout=timeout,
                        independent_sw_update_type="RuSwOnly", connection=admin_connection)
                else:
                    response = self.admin.update_software(build_to_dl, timeout=timeout, connection=admin_connection)
                time_2 = datetime.now()
                info(f"Time after update_software: {time_2.strftime('%Y-%m-%d %H:%M:%S')}")
                duration = (time_2 - time_1).total_seconds()
                info(f"Duration of update_software procedure: {duration} seconds")
                print(f"SWDL response: {response}")
                self.logger.debug(f"SWDL response: {response}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
                AliasInUse) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            info(f"{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    warning(f"Loop {self.logger.loop + 1}: Unable to update software from admin, because of session "
                            f"invalidation. Restart admin connection.")
                    self.bts.reset_admin_connection(admin=admin_connection)
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method update_software_on_bts again after admin connection reset.")
                    self.update_software_on_bts(build_to_dl, should_activate=should_activate, timeout=timeout,
                                                admin_connection=admin_connection, ru_swdl_only=ru_swdl_only, retry=1)
                elif retry == 1:
                    error("Unable to update software from admin, because of session invalidation. Admin connection "
                          "restart did not help.")
            elif "BTS is busy" in tb and ("ErrorCode: 17" in tb or "ErrorCode: 69" in tb):
                if retry == 0:
                    wait_time = BuiltIn().get_variable_value("${BTS_BUSY_WAIT_TIME}", default="600")
                    warning(f"Loop {self.logger.loop + 1}: ErrorCode noticed with status: BTS is busy. Wait "
                            f"{wait_time} seconds and try to update software again.")
                    BuiltIn().sleep(f"{wait_time}s")
                    self.update_software_on_bts(build_to_dl, should_activate=should_activate, timeout=timeout,
                                                admin_connection=admin_connection, ru_swdl_only=ru_swdl_only, retry=1)
                else:
                    error(f"Loop {self.logger.loop + 1}: BTS is busy noticed during Software update. "
                          f"{admin_error.__class__.__name__}:{admin_error} was raised.")
            else:
                error(f"Loop {self.logger.loop + 1}: Error noticed during Software update. "
                      f"{admin_error.__class__.__name__}:{admin_error} was raised.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise SoftwareUpdateFailure
        print("SWDL done.")

    def rollback_to_passive_sw(self, timeout=1800, admin_connection="log_admin", passive_sw="", retry=0):
        """
        Perform software rollback to passive SW. Uses rollback_software method of taf.sbts.oam.coam.admin library.

        :param int timeout: Timeout for software rollback. Default is 1800 seconds.
        :param str admin_connection: Default is log_admin
        :param str passive_sw: If given, check if passive SW is same as given passive_sw after rollback.
        :param int retry: Default is 0. If 0, try to rollback software again max three times.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        current_passive_sw = self.bts.get_passive_sw_of_bts
        tb = ""
        try:
            if passive_sw:
                current_active_sw = self.bts.get_active_sw_of_bts
                self.logger.debug(f"Passive SW in parameter: {passive_sw}.\nPassive SW on BTS: {current_passive_sw}\n"
                                  f"Active SW on BTS: {current_active_sw}.")
                if (current_active_sw == passive_sw and
                        current_passive_sw != "Unknown passive sw build, no admin connection"):
                    info(f"Active SW before next rollback is same as passive SW to which rollback is requested: "
                         f"{passive_sw}.")
                    return
            self.logger.debug(f"Try to make software rollback, {retry + 1}. try.")
            self.admin.rollback_software(timeout=timeout, connection=admin_connection, detailed_output=True)
            self.logger.debug(f"Software rollback successfully made in {retry + 1}. try.")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
                AliasInUse) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            info(f"{tb}")
            if "BTS is busy" in tb and ("ErrorCode: 17" in tb or "ErrorCode: 69" in tb):
                if 0 <= retry < 3:  # try max 3 times
                    wait_time = BuiltIn().get_variable_value("${BTS_BUSY_WAIT_TIME}", default="600")
                    warning(f"Loop {self.logger.loop + 1}, {retry +1 }. try: ErrorCode noticed with status: BTS is busy"
                            f". Wait {wait_time} seconds and try to do software rollback again.")
                    BuiltIn().sleep(f"{wait_time}s")
                    retry += 1
                    self.rollback_to_passive_sw(timeout=timeout, admin_connection=admin_connection,
                                                passive_sw=current_passive_sw, retry=retry)
            elif "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if 0 <= retry < 3:  # try max 3 times
                    warning(f"Loop {self.logger.loop + 1}, {retry +1 }. try: Unable to do sw rollback from admin, "
                            f"because of session invalidation. Restart admin connection and try again.")
                    self.bts.reset_admin_connection(admin=admin_connection)
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    retry += 1
                    self.rollback_to_passive_sw(timeout=timeout, admin_connection=admin_connection,
                                                passive_sw=current_passive_sw, retry=retry)
            if retry > 2:  # 3 times already tried
                error(f"Loop {self.logger.loop + 1}: Software rollback failed after 3 attempts. "
                      f"{admin_error.__class__.__name__}:{admin_error} was raised.")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                raise SoftwareRollbackFailure
            else:  # less than 3 times tried, try again
                warning(f"Loop {self.logger.loop + 1}, {retry + 1}. try: Unable to do sw rollback from admin, "
                        f"because of {admin_error.__class__.__name__}:{admin_error}. Wait 300s and try again.")
                BuiltIn().sleep("300s")
                retry += 1
                self.rollback_to_passive_sw(timeout=timeout, admin_connection=admin_connection,
                                            passive_sw=current_passive_sw, retry=retry)
            print("Software rollback is done")

    def reset_admin_connections(self):
        """Reset log_admin and default admin connections."""
        fail = False
        self.logger.debug("Teardown log_admin connection")
        self.bts.teardown_selected_admin_connection(selected_admin="log_admin")
        self.logger.debug("Teardown default connection")
        self.bts.teardown_selected_admin_connection(selected_admin=None)
        self.logger.debug("Connect log_admin")
        if self.collect_logs.rfs:
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
            other_master = BuiltIn().get_variable_value("${MASTER}") == "Other"
            if other_master:
                ip = remote_mplane_ip
        try:
            self.bts.wait_time_and_reason("5", "after admin teardowns before trying to reconnect admin.")
            self.bts.wait_admin_connection(admin_connection="log_admin", bts_ip=OmkpiCommonInterface.bts_ip,
                                           wait_admin=300, connect_always=True)
        except BTSConnectionFailure:
            info("Reconnection of admin connection named to log_admin was not successful after teardowns.")
            fail = True
        try:
            self.logger.debug("Connect default connection")
            self.bts.connect_suite_admin()
        except BTSConnectionFailure:
            info("Reconnection of default admin connection was not successful after teardowns.")
            fail = True
        if fail:  # This is needed so test will fail if admin connections are not working properly
            raise BTSConnectionFailure("Reconnection of admin was not successful after teardowns.")
        # This method doesn't work properly with FSMF raises always error, questions send if pronto needed
        # try:
        #     self.logger.debug(f"Try to reset log_admin connection.")
        #     self.admin.reset_admin(connection="log_admin")
        #     self.logger.debug(f"log_admin reset successfully made. Try to reset default connection.")
        #     self.admin.reset_admin()
        #     self.logger.debug(f"default reset successfully made.")
        # except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
        #         AliasLookupError, AdminApiTerminatedException, AdminApiConnectionClosedException,
        #         AliasInUse) as admin_error:
        #     error(f"Error noticed during admin connection reset. {admin_error.__class__.__name__}:{admin_error} was "
        #           f"raised.")
        #     raise EnvironmentIssue("Error noticed during admin connection reset.")

    @staticmethod
    def more_than_one_test_loop():
        """
        Check if there are more than one test loops in test case. If there are, return True, otherwise return False.

        return: True if more than one test loop, otherwise False
        """
        test_loops = BuiltIn().get_variable_value("${TEST_LOOPS}")
        if int(test_loops) > 1:
            info(f"There are more than one test loop in the test case. Test loops: {test_loops}")
            return True
        return False

    @staticmethod
    def change_test_package_swdl_order():
        """
        If T1 test package is in passive side, change order of test packages in SWDL so that T1 is downloaded after
        T2 test package.
        """
        b_t1 = BuiltIn().get_variable_value("${BUILD_T2}")
        b_t2 = BuiltIn().get_variable_value("${BUILD_T1}")
        info(f"Switch order. First download package {b_t1}, then {b_t2}")
        BuiltIn().set_suite_variable("${BUILD_T1}", b_t1)
        BuiltIn().set_suite_variable("${BUILD_T2}", b_t2)
        BuiltIn().set_suite_variable("${SWDL_FIRST}", '2')
        BuiltIn().set_suite_variable("${SWDL_SECOND}", '1')

    def logs_should_be_collected(self):
        """
        Check if logs should be collected. Logs are collected if ${COLLECT_LOGS} is Always or if ${COLLECT_LOGS} is On
        failure and ${KW_SUCCESS} or ${LOOP_KPI_SUCCESS} is False. If COLLECT_LOGS_FROM_PASS_LOOP is True and test is
        pass, also then logs should be collected. If logs should be collected return True, otherwise return False.
        """
        log_collection = BuiltIn().get_variable_value("${COLLECT_LOGS}")
        kw_success = BuiltIn().get_variable_value("${KW_SUCCESS}")
        loop_success = BuiltIn().get_variable_value("${LOOP_KPI_SUCCESS}")
        print(f"COLLECT_LOGS:{log_collection}, KW_SUCCESS:{kw_success}, LOOP_KPI_SUCCESS:{loop_success}")
        self.logger.debug(f"Log collection is set to: {log_collection}")
        self.logger.debug(f"KW_SUCCESS is: {kw_success}")
        if (log_collection == "Always") or (log_collection == "On failure" and (not kw_success or not loop_success)):
            print("Logs will be collected.")
            return True
        elif (log_collection == "On failure" and BuiltIn().get_variable_value("${OMKPI_CASE}", default=False) and
                BuiltIn().get_variable_value("${COLLECT_LOGS_FROM_PASS_LOOP}", default=False) and
              kw_success and loop_success):
            print("Collect test logs from passed loop")
            return True
        print("Logs will not be collected.")
        return False

    def get_rf_sw_build(self, rf_sw_url):
        """
        Get RF SW build from WFT.

        :param str rf_sw_url: Url from where the build is downloaded.
        """
        if not rf_sw_url:
            error("RF SW URL is not given.")
            raise InvalidUserInput("RF SW URL is not given.")
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        build_to_download = rf_sw_url[rf_sw_url.rfind('/')+1:]
        path_to_saved_build = "/home/ute/logs/{}".format(rf_sw_url[rf_sw_url.rfind('/')+1:])
        self.bts.use_wget_commands(rf_sw_url, build_to_download, path_to_saved_build)
        return path_to_saved_build

    def get_rf_sw_version(self, retry=0, print_to_event_log=True):
        """
        Check RF SW version.

        :param int retry: Default is 0. If 0, try to get RF SW version again once if error 6.
        :param bool print_to_event_log: If True prints the values to eventlog, otherwise just to debug.
        """
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        try:
            radio_sw_version = {}
            rmod_mos = self.admin.get_managed_objects("RMOD_R")
            if not rmod_mos:
                error("Unable to get rmod_mos (RMOD_R) objects from admin.")
                raise EnvironmentIssue
            for rmod_mo in rmod_mos:
                parameter_dict = rmod_mo["parameters"]
                self.logger.debug(parameter_dict)
                if "activeSwVersion" in parameter_dict:
                    sw_version = str(parameter_dict["activeSwVersion"])
                    for radio in self.bts.radios:
                        if radio.dist_name == rmod_mo["distName"]:
                            radio_sw_version[radio.name] = sw_version
                            break
            self.logger.debug(radio_sw_version)
            for rmod in radio_sw_version:
                if print_to_event_log:
                    info(f"Radio {rmod} has RF SW version {radio_sw_version[rmod]}")
                else:
                    self.logger.debug(f"Radio {rmod} has RF SW version {radio_sw_version[rmod]}")
                    print(f"Radio {rmod} has RF SW version {radio_sw_version[rmod]}")
            return radio_sw_version
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Unable to get activeSwVersions of RMOD_R. {admin_error.__class__.__name__}:"
                  f"{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get rf sw versions from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method get_rf_sw_version again after admin connection reset.")
                    self.get_rf_sw_version(retry=1)
                else:
                    error("Unable to get rf sw versions from admin, because of session invalidation. Admin connection "
                          "restart did not help")
            raise ErrorFromAdmin(f"Unable to get activeSwVersions of RMOD_R, {admin_error.__class__.__name__} was "
                                 f"raised.")

    @staticmethod
    def _get_radios_to_be_updated(master_radios):
        update_radio = []
        radios_to_update = BuiltIn().get_variable_value("${RADIOS_TO_UPDATE}")
        for rmod in radios_to_update:
            if rmod.name in master_radios:
                update_radio.append(rmod.name)
            else:
                info(f"Radio {rmod.name} is not a master radio so it will not be updated.")
        return update_radio

    def compare_radio_sw_versions(self, rf_sw_version, kpi55e=False):
        """
        Compare current RF SW version with given RF SW version. If none of the radios has changed version return False,
        otherwise return True.

        :param dict rf_sw_version: RF SW versions before RF SW update.
        :param bool kpi55e: Default is False. If True then only selected radios are expected to change software
        """
        current_rf_sw_version = self.get_rf_sw_version()
        rf_sw_changes = False
        if not current_rf_sw_version:
            error("Unable to get current RF SW versions.")
            raise EnvironmentIssue("Unable to get current RF SW versions.")
        master_radios = self.bts.get_master_radios()
        update_radio = []
        sw_was_changed = []
        if kpi55e:
            update_radio = self._get_radios_to_be_updated(master_radios)
        for radio in current_rf_sw_version:
            if radio not in rf_sw_version:
                error(f"Radio {radio} was not found from given RF SW version dictionary {rf_sw_version}.")
                raise EnvironmentIssue
            if current_rf_sw_version[radio] != rf_sw_version[radio]:
                radio_cells = self.bts.get_cells_of_radio(radio, print_to_eventlog=False)
                info(f"RF SW version of radio {radio} has changed from {rf_sw_version[radio]} to "
                     f"{current_rf_sw_version[radio]}. Cells: {radio_cells}")
                rf_sw_changes = True
                sw_was_changed.append(radio)
            elif kpi55e and radio not in update_radio and radio not in master_radios and current_rf_sw_version[
                    radio] == rf_sw_version[radio]:
                info(f"RF SW version of radio {radio} is not updated, it is still {rf_sw_version[radio]} because radio "
                     f"is shared and not master.")
            elif kpi55e and radio not in update_radio and radio in master_radios and current_rf_sw_version[
                    radio] == rf_sw_version[radio]:
                info(f"RF SW version of radio {radio} is not updated, it is still {rf_sw_version[radio]} because radio "
                     f"was not selected to be updated (by commissioning).")
            elif not kpi55e and radio not in master_radios and current_rf_sw_version[radio] == rf_sw_version[radio]:
                info(f"RF SW version of radio {radio} is not updated, it is still {rf_sw_version[radio]} because radio "
                     f"is shared and not master.")
            else:
                info(f"No changes in RF SW version of radio {radio}, still {rf_sw_version[radio]}.")
        if not rf_sw_changes:
            error(f"Loop {self.logger.loop + 1}: No radio software updates were noticed.")
            raise RadioSofwareNotUpdated
        elif (not kpi55e and len(sw_was_changed) != len(rf_sw_version.keys())) or (
                kpi55e and len(sw_was_changed) != len(update_radio)):
            err_txt = f"{[j for j in update_radio if j not in sw_was_changed]}" if kpi55e else \
                f"{[j for j in rf_sw_version.keys() if j not in sw_was_changed]}"
            error(f"Software was not updated on radios {err_txt}. NOK.")
            raise RadioSofwareNotUpdated
        else:
            info("SW was updated to radios. OK.")
        return rf_sw_changes

    def wait_until_all_radios_have_updated_sw(self, rf_sw_version, time_limit="300"):
        """
        Wait until all radios have updated their SW.

        :param dict rf_sw_version: RF SW versions before SW update.
        :param str time_limit: (Optional) Time limit for waiting
        """
        master_radios = self.bts.get_master_radios()
        start_time = datetime.now()
        while (datetime.now() - start_time).total_seconds() < int(time_limit):
            current_rf_sw_version = self.get_rf_sw_version(print_to_event_log=False)
            if not current_rf_sw_version:
                error("Unable to get current RF SW versions.")
                raise EnvironmentIssue("Unable to get current RF SW versions.")
            all_master_radios_updated = True
            for radio in current_rf_sw_version:
                if radio not in rf_sw_version:
                    error(f"Radio {radio} was not found from given RF SW version dictionary {rf_sw_version}.")
                    raise EnvironmentIssue
                if radio in master_radios and current_rf_sw_version[radio] == rf_sw_version[radio]:
                    all_master_radios_updated = False
                    self.logger.debug(f"Master radio {radio} still has old SW version {rf_sw_version[radio]}")
                elif current_rf_sw_version[radio] != rf_sw_version[radio]:
                    radio_cells = self.bts.get_cells_of_radio(radio, print_to_eventlog=False)
                    self.logger.debug(f"Radio {radio} has changed from {rf_sw_version[radio]} to "
                                      f"{current_rf_sw_version[radio]}. Cells: {radio_cells}")
                elif radio not in master_radios:
                    info(f"RF SW version of radio {radio} is still {rf_sw_version[radio]} "
                         f"because radio is shared and not master.")
            if all_master_radios_updated:
                info("All master radios have successfully updated their SW")
                return True
            BuiltIn().sleep("10s")
        error(f"All radios were not updated in {time_limit} seconds.")
        raise RadioSofwareNotUpdated

    def wait_until_given_radios_have_updated_sw(self, rf_sw_version, radios_to_update, time_limit="300"):
        """
        Wait until given radios have updated SW.

        :param dict rf_sw_version: RF SW versions before SW update.
        :param list radios_to_update: Radios that software is expected to be updated
        :param str time_limit: (Optional) Time limit for waiting, default is 300 (seconds)
        """
        if not radios_to_update:
            error("No radios given to radios_to_update parameter")
            raise ScriptIssue("No radios given to method wait_until_given_radios_have_updated_sw")
        master_radios = self.bts.get_master_radios()
        update_radio = self._get_radios_to_be_updated(master_radios)
        start_time = datetime.now()
        radios_that_are_updated = []
        while (datetime.now() - start_time).total_seconds() < int(time_limit):
            current_rf_sw_version = self.get_rf_sw_version(print_to_event_log=False)
            if not current_rf_sw_version:
                error("Unable to get current RF SW versions.")
                raise EnvironmentIssue("Unable to get current RF SW versions.")
            for radio in current_rf_sw_version:
                if radio not in rf_sw_version and radio in update_radio:
                    error(f"Radio {radio} was not found from given RF SW version dictionary {rf_sw_version}.")
                    raise EnvironmentIssue
                if radio in update_radio and current_rf_sw_version[radio] == rf_sw_version[radio]:
                    self.logger.debug(f"Selected radio {radio} still has old SW version {rf_sw_version[radio]}")
                elif current_rf_sw_version[radio] != rf_sw_version[radio]:
                    if radio not in radios_that_are_updated:
                        radio_cells = self.bts.get_cells_of_radio(radio, print_to_eventlog=False)
                        info(f"Radio {radio} has changed from {rf_sw_version[radio]} to {current_rf_sw_version[radio]}."
                             f"Cells of the radio: {radio_cells}")
                        radios_that_are_updated.append(radio)
                    else:
                        self.logger.debug(f"Change of software to {current_rf_sw_version[radio]} on Radio {radio} was "
                                          f"already noticed.")
                elif radio not in master_radios:
                    self.logger.debug(f"RF SW version of radio {radio} is still {rf_sw_version[radio]} "
                                      f"because radio is shared and not master.")
            if set(sorted(radios_that_are_updated)) == set(sorted(update_radio)):
                info(f"All selected master radios {update_radio}  have successfully updated their SW.")
                return True
            BuiltIn().sleep("10s")
        if radios_that_are_updated and len(radios_that_are_updated) > len(update_radio):
            error(f"Software has been updated to unexpected radios {set(radios_that_are_updated) - set(update_radio)}. "
                  f"Software update is expected only for radios {update_radio}, but software update has been made to "
                  f"radios {radios_that_are_updated}. NOK.")
            raise RadioSoftwareUpdateError("Software was updated to unexpected radios.")
        elif radios_that_are_updated and len(update_radio) < len(radios_that_are_updated):
            error(f"Given radios {update_radio} were not updated in {time_limit} seconds. Software of radios "
                  f"{set(update_radio) - set(radios_that_are_updated)} was not updated. NOK.")
            raise RadioSoftwareUpdateError("Software was not updated to all expected radios.")
        else:
            error(f"Given radios {update_radio} were not updated in {time_limit} seconds.")
            raise RadioSofwareNotUpdated("Software was not updated to any radio.")

    def _check_if_cells_in_list_and_add_to_list(self, affected_cells, cells):
        """
        This check is needed because some radios have cells and some don't, some radios have same cells. If cells are
        found and not already in affected_cells list, add them to affected cells list.
        :param list affected_cells: List of affected cells.
        :param list cells: List of cells on radio.
        :return: List of affected cells with added cells on radio.
        """
        if cells:
            self.logger.debug(f"There were cells {cells}, add them to affected cells {affected_cells}.")
            for cell in cells:
                if cell not in affected_cells:
                    affected_cells.append(cell)
        else:
            self.logger.debug("No cells found for this radio.")
        return affected_cells

    def get_cells_that_are_affected_by_swdl(self, rf_sw_path):
        """
        Get cells that are affected by RF SWDL. Only radios that are same type that is given in software package will
        be updated and cells of them are returned.
        :param str rf_sw_path: Path to RF SW package, for example /home/ute/logs/RUSW_AZQS_000004_475664A.zip
        """
        radio_pattern = re.compile(r".*RUSW_(?P<radio>\w+)_(?P<version>\d+_\d+\w+).*")
        radio_match = radio_pattern.match(rf_sw_path)
        if not radio_match:
            error(r"Parsing RF SW path {} with regex .*RUSW_(?P<radio>\w+)_(?P<version>\d+_\d+\w+).*. is not working. "
                  r"Take contact to script developers".format(rf_sw_path))
            raise ScriptIssue("Unable to get cells that are affected by RF SWDL.")
        radio_type = radio_match.group("radio")
        if not self.bts:
            self.bts = BuiltIn().get_library_instance("BTS")
        affected_cells = []
        for rmod in self.bts.radios:
            if radio_type in rmod.name:
                info(f"Radio {rmod.name} is affected by RF SWDL.")
                cells = self.bts.get_cells_of_radio(rmod.name)
                affected_cells = self._check_if_cells_in_list_and_add_to_list(affected_cells, cells)
        info(f"Cells that are affected by RF SWDL are: {affected_cells}")
        return affected_cells

    def more_than_one_test_loop_current_loop_is_not_first(self):
        """
        Check if there are more than one test loops in test case. If there are more than one and current loop is not
        the first loop return True, otherwise return False.
        """
        # if "${BASE_BUILD}" in BuiltIn().get_variables():
        #     self.logger.debug("BASE_BUILD has been given in reservation.")
        current_loop = self.logger.loop + 1
        if self.more_than_one_test_loop():
            if current_loop > 1:
                info(f"Current loop is not the first loop. Current loop: {current_loop}")
                return True
        info(f"Current loop is the first loop. (Current loop: {current_loop})")
        return False

    def loop_is_the_last_one(self):
        """
        Loop Is the Last One checks if the current loop is the last loop. Returns True if last loop, otherwise False.
        """
        current_loop = int(self.logger.loop) + 1
        if current_loop == int(self.logger.loops):
            info(f"Current loop is the last loop. (Current loop is {current_loop})")
            return True
        info(f"Current loop is not the last loop. (Current loop is {current_loop}/{self.logger.loops})")
        return False

    def perform_site_reset(self, timeout=300, wait_for_reconnection=True, graceful_cell_shutdown=None,
                           reset_without_ru=False, retry=0):
        """
        Perform site reset methods does site reset with user given selection.

        :param int timeout: Timeout for site reset. Default is 300 seconds.
        :param bool wait_for_reconnection: If True, wait for reconnection after site reset. Default is True.
        :param bool graceful_cell_shutdown: If True, do graceful cell shutdown. Default is None.
        :param bool reset_without_ru: If True, do site reset without RU. Default is False.
        :param int retry: Default is 0. If 0, try to perform site reset again once.
        """
        try:
            if ("${GRACEFUL_CELL_SHUTDOWN}" in BuiltIn().get_variables() and BuiltIn().get_variable_value(
                    "${GRACEFUL_CELL_SHUTDOWN}")) or graceful_cell_shutdown:
                graceful_cell_shutdown = True
                info("Resetting site with Graceful cell shutdown")
            if ("${RESET_WITHOUT_RU}" in BuiltIn().get_variables() and BuiltIn().get_variable_value(
                    "${RESET_WITHOUT_RU}")) or reset_without_ru:
                reset_without_ru = True
                info("Resetting site without RU reset")
                result = self.admin.reset_site(timeout=timeout, wait_for_reconnection=wait_for_reconnection,
                                               detailed_output=True, graceful_cell_shutdown=graceful_cell_shutdown,
                                               reset_without_ru=reset_without_ru)
            else:
                result = self.admin.reset_site(timeout=timeout, wait_for_reconnection=wait_for_reconnection,
                                               detailed_output=True, graceful_cell_shutdown=graceful_cell_shutdown)
            print(f"Admin response for reset_site: {result}")
            self.logger.debug(f"Admin response for reset_site: {result}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Problems when resetting site. {admin_error.__class__.__name__}:{admin_error} was raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to get perform site reset, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method perform_site_reset again after admin connection reset.")
                    self.perform_site_reset(timeout=timeout, wait_for_reconnection=wait_for_reconnection,
                                            graceful_cell_shutdown=graceful_cell_shutdown,
                                            reset_without_ru=reset_without_ru, retry=1)
                elif retry == 1:
                    error("Unable to perform site reset, because of session invalidation. Admin connection "
                          "restart did not help.")
            raise ErrorFromAdmin(f"Problems when resetting site, {admin_error.__class__.__name__} was raised.")

    def perform_configuration_reset(self, remove_operator_certificates=False, remove_user_account_credentials=False,
                                    timeout=500, admin_connection="log_admin", detailed_output=True,
                                    reset_type="ConfigurationWithDiagnosticAndRecoverySw", retry=0):
        """
        Perform configuration reset.

        :param bool remove_operator_certificates: If True, remove operator certificates. Default is False.
        :param bool remove_user_account_credentials: If True, remove user account credentials. Default is False.
        :param int timeout: Timeout for configuration reset. Default is 500 seconds.
        :param str admin_connection: Default is log_admin
        :param bool detailed_output: If True, return detailed output. Default is True.
        :param str reset_type: Type of reset. Default is ConfigurationWithDiagnosticAndRecoverySw.
                Possible values: ConfigurationWithSecurityCredentials, ConfigurationWithOperatorCertificates,
                ConfigurationWithLocalUserCredentials, ConfigurationWithResetOnlyActivePartitionAndRestoreNcf and
                ConfigurationWithDiagnosticAndRecoverySw
        :param int retry: Default is 0. If 0, try to perform configuration reset again once if there is error 6.
        """
        try:
            result = self.admin.reset_configuration(remove_operator_certificates=remove_operator_certificates,
                                                    remove_user_account_credentials=remove_user_account_credentials,
                                                    timeout=timeout, connection=admin_connection,
                                                    detailed_output=detailed_output, reset_type=reset_type)
            print(f"Admin response for configuration reset: {result}")
            self.logger.debug(f"Admin response for configuration reset: {result}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Problems when performing configuration reset. {admin_error.__class__.__name__}:{admin_error} was "
                  f"raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to perform configuration reset, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin=admin_connection)
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method perform_configuration_reset again after admin connection reset.")
                    self.perform_configuration_reset(remove_operator_certificates=remove_operator_certificates,
                                                     remove_user_account_credentials=remove_user_account_credentials,
                                                     timeout=timeout, admin_connection=admin_connection,
                                                     detailed_output=detailed_output, reset_type=reset_type, retry=1)
                elif retry == 1:
                    error("Unable to perform configuration reset, because of session invalidation. Admin connection "
                          "restart did not help.")
            raise ErrorFromAdmin(f"Problems when performing configuration reset., {admin_error.__class__.__name__} was "
                                 f"raised.")

    def perform_bbpool_reset(self, bbpool, timeout=300, retry=0):
        """
        Perform bbpool reset to given BBPool

        :param list bbpool:BBPools to reset. For example [MRBTS-31232/MNL-1/MNLENT-1/BBADM-1/BBPOOL-12]
        :param str/int timeout: Timeout for procedure, default is 300s
        :param int retry: Default is 0. If 0, try to perform configuration reset again once if there is error 6.
        """
        try:
            result = self.admin.reset_bbpool(bbpool, timeout=int(timeout))
            print(f"Admin response for bbpool reset: {result}")
            self.logger.debug(f"Admin response for bbpool reset: {result}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Problems when performing BBPool reset. {admin_error.__class__.__name__}:{admin_error} was "
                  f"raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to perform bbpool reset, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin="default")
                    info("Call method _get_active_alarms_from_admin again after admin connection reset.")
                    self.perform_bbpool_reset(bbpool, timeout=timeout, retry=1)
                elif retry == 1:
                    error("Unable to perform BBPool reset, because of session invalidation. Admin connection "
                          "restart did not help.")
            raise ErrorFromAdmin(f"Problems when performing BBPool reset. {admin_error.__class__.__name__} was "
                                 f"raised.")

    def _check_temperature(self, success, smod=None, remote_mplane_ip=""):
        temp_regex = r"temp=(?P<temp_group>\d+)"
        output = self.ssh.send_command_to_smod_by_ssh("ddal -s ddal_temp_get_init 'DDAL_TEMP_DEV_LOCAL_OCXO'",
                                                      ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                                      else OmkpiCommonInterface.bts_ip, return_output=True,
                                                      print_to_eventlog=False)
        if not output:
            error("No output was found for OCXO init temperature")
            raise EnvironmentIssue("No output was found for OCXO init temperature")
        temperature = float(re.search(temp_regex, output).group("temp_group")) / 1000
        if smod and "ASIA" in smod.name:
            if temperature < float(70):
                error(f"OCXO init temperature is under 70 degrees for {smod.name}. Temperature is {temperature}")
                success = False
            else:
                info(f"{smod.name} OCXO init temperature is: {temperature} --> OK")
        else:
            info(f"{smod.name} init temperature is: {temperature}")
        return success

    def check_ocxo_init_temperature(self):
        """Check ocxo init temperature after power reset."""
        if self.bts.smod_is_fsmf(include_fsih=True):
            info("FSMF is used, OCXO init temperature is not checked.")
            return
        remote_mplane_ip = ""
        if BuiltIn().get_variable_value("${RFS}"):
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
        info("Checking OCXO init temperature warmup time from syslogs")
        temp_pattern = "[OcxoInitialization] StartOcxoWarmUp(), warmup time"
        f_ocxo = BuiltIn().get_variable_value("${FIRST_OCXO_SYSLOG}", default=True)
        j_o = False if f_ocxo in (False, "False", "false", "FALSE") else True
        self.syslog_search.get_prints_from_syslogs(expected_print=temp_pattern, print_eventlog=True, time_stamp=None,
                                                   both_sides=True, just_once=j_o)
        info("Sending OCXO debugging commands")
        self._debug_ocxo_temp(remote_mplane_ip)
        info("Checking OCXO init temperature after power reset")
        success = True
        for smod in self.bts.smods:
            if smod.remote:
                success = self._check_temperature(success, smod, remote_mplane_ip) and success
            else:
                success = self._check_temperature(success, smod) and success
        if not success:
            error("Incorrect OCXO init temperature was found")
            raise IncorrectDocxoValues

    def _check_setpoints(self, remote_mplane_ip=""):
        a_setpoint = self.ssh.send_command_to_smod_by_ssh("cat /dev/ddal/docxo/a_setpoint",
                                                          ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                                          else OmkpiCommonInterface.bts_ip,
                                                          return_output=True, print_to_eventlog=False)
        b_setpoint = self.ssh.send_command_to_smod_by_ssh("cat /dev/ddal/docxo/b_setpoint",
                                                          ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                                          else OmkpiCommonInterface.bts_ip,
                                                          return_output=True, print_to_eventlog=False)
        c_setpoint = self.ssh.send_command_to_smod_by_ssh("cat /dev/ddal/docxo/c_setpoint",
                                                          ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                                          else OmkpiCommonInterface.bts_ip,
                                                          return_output=True, print_to_eventlog=False)
        success = self._check_specific_setpoint("a", a_setpoint)
        success = self._check_specific_setpoint("b", b_setpoint) and success
        success = self._check_specific_setpoint("c", c_setpoint) and success
        if success:
            info("All the setpoints have correct values")
        return success

    def _set_checkpoints(self, remote_mplane_ip=""):
        info("Setting DOCXO setpoints")
        self.ssh.send_command_to_smod_by_ssh("echo 0 > /dev/ddal/docxo/a_setpoint",
                                             ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                             else OmkpiCommonInterface.bts_ip,
                                             return_output=True, print_to_eventlog=False)
        self.ssh.send_command_to_smod_by_ssh("echo 0xfffff4fe > /dev/ddal/docxo/b_setpoint",
                                             ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                             else OmkpiCommonInterface.bts_ip,
                                             return_output=True, print_to_eventlog=False)
        self.ssh.send_command_to_smod_by_ssh("echo 0x00005500 > /dev/ddal/docxo/c_setpoint",
                                             ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                             else OmkpiCommonInterface.bts_ip,
                                             return_output=True, print_to_eventlog=False)
        self.ssh.send_command_to_smod_by_ssh("echo 0x1 > /dev/ddal/docxo/ctrl_flag",
                                             ip_to_connect=remote_mplane_ip if remote_mplane_ip
                                             else OmkpiCommonInterface.bts_ip,
                                             return_output=True, print_to_eventlog=False)

    def check_ocxo_setpoints(self):
        success = True
        remote_mplane_ip = ""
        if BuiltIn().get_variable_value("${RFS}"):
            remote_mplane_ip = BuiltIn().get_variable_value("${OTHER_BTS_MPLANE}")
        info("Checking that DOCXO setpoints have correct values")
        for smod in self.bts.smods:
            if "ASI" in smod.name:
                if smod.remote:
                    success = self._check_setpoints(remote_mplane_ip) and success
                    if not success:
                        warning("Incorrect DOCXO setpoints were found. Trying to set correct values to setpoints")
                        self._set_checkpoints(remote_mplane_ip)
                        success = self._check_setpoints(remote_mplane_ip) and success
                else:
                    success = self._check_setpoints() and success
                    if not success:
                        warning("Incorrect DOCXO setpoints were found. Trying to set correct values to setpoints")
                        self._set_checkpoints()
                        success = self._check_setpoints() and success
            else:
                info("DOCXO setpoints are only checked for ASIx")
        if not success:
            raise IncorrectDocxoValues

    @staticmethod
    def _check_specific_setpoint(setpoint, value):
        correct_setpoints = {
            "a": ["0x00000000"],
            "b": ["0xfffff4fe", "0xfffff768"],
            "c": ["0x00005500", "0x00005407"]
        }
        for correct_setpoint in correct_setpoints[setpoint]:
            if correct_setpoint in value:
                return True
        error(f"{setpoint}_setpoint is incorrect: {value}, the value should be {correct_setpoints[setpoint]}")
        return False

    def _debug_ocxo_temp(self, remote_mplane_ip):
        first_commands = ["uptime",
                          "ddal -s ddal_docxo_get_uptime",
                          "ddal -s ddal_temp_get_init 'DDAL_TEMP_DEV_LOCAL_OCXO'",
                          "ddal -s ddal_temp_get_curr 'DDAL_TEMP_DEV_LOCAL_OCXO'",
                          "ddal -s ddal_temp_get_curr 'DDAL_TEMP_DEV_FCT_OCXO'"]

        second_commands = ["cat /dev/ddal/docxo/id_ver",
                           "cat /dev/ddal/docxo/temp2_input",
                           "cat /dev/ddal/docxo/temp3_input",
                           "cat /dev/ddal/docxo/temp4_input",
                           "cat /dev/ddal/docxo/temp5_input",
                           "cat /dev/ddal/docxo/error",
                           "cat /dev/ddal/docxo/temperr",
                           "cat /dev/ddal/docxo/setpoint",
                           "cat /dev/ddal/docxo/a_setpoint",
                           "cat /dev/ddal/docxo/b_setpoint",
                           "cat /dev/ddal/docxo/c_setpoint",
                           "cat /dev/ddal/docxo/p_value",
                           "cat /dev/ddal/docxo/i_value",
                           "cat /dev/ddal/docxo/d_value",
                           # "cat /dev/ddal/docxo/ctrl_flag",
                           "cat /dev/ddal/docxo/uptime"]

        first_output = self.ssh.send_command_to_smod_by_ssh(first_commands, print_to_eventlog=False, return_output=True,
                                                            ip_to_connect=OmkpiCommonInterface.bts_ip)
        second_output = self.ssh.send_command_to_smod_by_ssh(second_commands, print_to_eventlog=False,
                                                             return_output=True,
                                                             ip_to_connect=OmkpiCommonInterface.bts_ip)
        self.logger.debug(f"{first_output}")
        self.logger.debug(f"{second_output}")
        if remote_mplane_ip:
            first_output_remote = self.ssh.send_command_to_smod_by_ssh(first_commands, print_to_eventlog=False,
                                                                       return_output=True,
                                                                       ip_to_connect=remote_mplane_ip)
            second_output_remote = self.ssh.send_command_to_smod_by_ssh(second_commands, print_to_eventlog=False,
                                                                        return_output=True,
                                                                        ip_to_connect=remote_mplane_ip)
            self.logger.debug(f"{first_output_remote}")
            self.logger.debug(f"{second_output_remote}")

    def enable_extended_post_test(self):
        """
        Enable extended post test by setting ddal_boot_set_no_extended_post to 0.
        If ${EXTENDED_POST_TEST} is False, disable extended post test by setting ddal_boot_set_no_extended_post to 1.

        """
        value = "0" if BuiltIn().get_variable_value("${EXTENDED_POST_TEST}", default=True) else "1"
        enable_text = "Enabling" if value == "0" else "Disabling"
        info(f"{enable_text} extended post test by setting ddal_boot_set_no_extended_post to {value}")
        output = self.ssh.send_command_to_smod_by_ssh(f"ddal -s ddal_boot_set_no_extended_post {value}",
                                                      return_output=True, print_to_eventlog=False,
                                                      ip_to_connect=OmkpiCommonInterface.bts_ip)
        if "DDAL_RETURN_VALUE=0" in output:
            enabled = "enabled" if value == "0" else "disabled"
            info(f"Extended post test is {enabled}")
        else:
            warning("Extended post test might failed. There is no DDAL_RETURN_VALUE=0 in output.")

    def get_build_given_as_one_build_argument(self, one_build):
        """
        Get build given as one build argument check user given value and gets the build to control PC.

        :param str one_build: Build given as one build argument. Can have values T1, T2 or path to file.
        """
        if not one_build:
            error("User has not given any values to ONE_BUILD variable.")
            raise InvalidUserInput("User has not given any values to ONE_BUILD valriable.")
        update_path_build = BuiltIn().get_variable_value("${UPDATE_PATH}", default="")
        customer_build = BuiltIn().get_variable_value("${UUF_CUSTOMER}", default="")
        uuf_build = BuiltIn().get_variable_value("${UUF_BUILD}", default="")
        triggering_build = self.reservation.get_triggering_build()
        OmkpiCommonInterface.branch_of_triggering_build = self.bts.get_branch_from_build_name(triggering_build)
        if one_build == "T1":
            if update_path_build or customer_build or uuf_build:
                build = self.bts.get_build_from_artifactory(triggering_build, package_type="testpackage_T1_A54",
                                                            save_to_pc=True)
            else:
                build = self.bts.get_build_that_is_currently_active_on_bts(save_to_pc=True, testpackage="T1")
        elif one_build == "T2":
            if update_path_build or customer_build or uuf_build:
                build = self.bts.get_build_from_artifactory(triggering_build, package_type="testpackage_T2_A54",
                                                            save_to_pc=True)
            else:
                build = self.bts.get_build_that_is_currently_active_on_bts(save_to_pc=True, testpackage="T2")
        elif one_build in ("normal", "Normal"):
            if update_path_build or customer_build or uuf_build:
                build = self.bts.get_build_from_artifactory(triggering_build, package_type="A54", save_to_pc=True)
            else:
                build = self.bts.get_build_that_is_currently_active_on_bts(save_to_pc=True)
        elif os.path.isfile(one_build):
            build = one_build
        else:
            error(f"User has given invalid value {one_build} to ONE_BUILD variable.")
            raise InvalidUserInput(f"User has given invalid value {one_build} to ONE_BUILD variable.")
        return build

    def save_rmod_uptimes_to_suite_variable(self):
        """
        Saving RMOD uptimes to a suite variable to help out with checking them in case of OMKPI site reset without RU.
        """
        rmod_uptimes = self.bts.check_rmod_uptimes()
        BuiltIn().set_suite_variable("${RMOD_UPTIMES}", rmod_uptimes)

    def check_and_create_file_on_radio(self, radio, file_names, mounting_point="/mnt/factory"):
        """
        Check if file(s) is/are created on radio(s). If file is not created, create it.

        :param list/RCI/str radio: Radio-object(s) or "all" where file should be checked.
        :param list file_names: List of paths of files that should be checked.
        :param str mounting_point: Remounting point if creation is failing. Default is /mnt/factory.
        """
        error_texts = []
        radios = self.bts.radios if isinstance(radio, str) and "all" in radio else radio
        radios = [radio] if isinstance(radio, str) and "all" not in radio else radios
        for radio in radios:
            for file_name in file_names:
                check_file_existence = f'ls {file_name} '
                output = self.ssh.send_command_to_radio_by_ssh(radio, check_file_existence, return_output=True,
                                                               ignore_expect=True)
                if "No such file or directory" in output:
                    error_text = f"File {file_name} is not found for {radio.name}. Creating it."
                    error_texts.append(error_text)
                    error(error_text)
                    output = self.ssh.send_command_to_radio_by_ssh(radio, f"touch {file_name}", return_output=True,
                                                                   ignore_expect=True)
                    if "cannot touch" in output:
                        info(f"Creation failed. Trying to remount {mounting_point} as rw and create file again")
                        create_file_cmd = [f"sudo mount -o remount,rw {mounting_point}", f"touch {file_name}"]
                        self.ssh.send_command_to_radio_by_ssh(radio, create_file_cmd, ignore_expect=True)
                else:
                    info(f"File {file_name} is found.")
                    continue
                output = self.ssh.send_command_to_radio_by_ssh(radio, check_file_existence, return_output=True,
                                                               ignore_expect=True)
                if "1" in output:
                    info(f"File {file_name} is found for {radio.name}.")
                else:
                    error_text = f"File {file_name} is not found for {radio.name}. Creation failed."
                    error(error_text)
                    error_texts.append(error_text)
        if error_texts:
            raise FileNotFound("\n".join(error_texts))

    def check_and_get_if_customer_or_update_path_or_t1_in_passive(self):
        """
        Check if UUF_CUSTOMER or UPDATE_PATH or UUF_BUILD has been given in environment reservation, if is then use
        triggering build instead of T1 build. If user has give ${NO_BUILD_PATH_UPDATE} then rollbacks are done with
        software already on active and passive bank. If UPDATE_PATH or UUF_CUSTOMER or UUF_BUILD is used then return
        the build.
        """
        update_path_build = self.reservation.get_build_used_in_update_path_tag()  # Get Build Used In Update Path Tag
        customer_build = self.reservation.get_customer_build_used_in_tag()  # Get Customer Build Used In Tag
        uuf_build = self.reservation.get_uuf_build_used_in_tag()  # Get UUF Build Used In Tag
        build = ""
        if update_path_build or customer_build or uuf_build:
            explanation = "{}".format(
                "UPDATE_PATH" if update_path_build else "UUF_BUILD" if uuf_build else "UUF_CUSTOMER")
            info(f"{explanation} was used when environment reservation was made. Upload triggering software to BTS.")
            build = self.reservation.get_triggering_build()
            BuiltIn().set_suite_variable("${EXPLANATION}", explanation)
        elif self.build_in_passive_is_test_package_of_active_and_vice_versa():
            # testpackage is in passive bank
            BuiltIn().set_suite_variable("${EXPLANATION}", "T1 testpackage")
        return build

    def change_aatracerecordused_value(self):
        if BuiltIn().get_variable_value("${AaTraceRecordUsed}") is not None:
            value = BuiltIn().get_variable_value("${AaTraceRecordUsed}")
            info(f"Change AaTraceRecordUsed value to {value}")
            self.admin.set_multiple_rad_debug_parameters("Ccs", "Persistent", [{"name": "ERadCcs_AaTraceRecordUsed",
                                                                                "value": value}])

    def check_aatracerecordused_value(self, only_print=False):
        if BuiltIn().get_variable_value("${AaTraceRecordUsed}") is not None:
            value = BuiltIn().get_variable_value("${AaTraceRecordUsed}")
            output_json = self.admin.get_rad_debug_parameters("Ccs")
            print(output_json)
            if output_json:
                for name_value in output_json["parameters"]:
                    if name_value["name"] == "ERadCcs_AaTraceRecordUsed":
                        if only_print:
                            info(f"AaTraceRecordUsed value is {name_value['value']}")
                            return
                        if name_value["value"] == value:
                            info(f"AaTraceRecordUsed value is correct. Value is {value}")
                        else:
                            error(f"AaTraceRecordUsed value is incorrect. Value is {name_value['value']}, "
                                  f"should be {value}")

    def _collect_avg_times_from_files(self):
        """
        Collect average times from every KPI files in test logs folder
        :return: Dictionary of average times
        """
        import json
        all_average_times = {}
        for root, dirs, files in os.walk(self.logger.suite_folder):
            for file_name in files:
                if file_name.endswith(".txt") and "KPI" in file_name:
                    test_case_folder_name = root.split('/')[-1]
                    info(f"Collecting average times from KPI file: {test_case_folder_name}/{file_name}")
                    with open(os.path.join(root, file_name), "r") as f:
                        average_times = {}
                        data = json.load(f)
                        if data:
                            for kpi in data:
                                average_times[kpi] = data[kpi]["avg"]
                                info(f"KPI: {kpi}, Average time: {data[kpi]['avg']}")
                            all_average_times[test_case_folder_name] = average_times
        info(f"Collected average times from KPI files: {all_average_times}")
        return all_average_times

    def compare_avg_times(self, max_diff=10):
        """
        Compare average times of KPIs from different files. At this point two files are supported. Checks if difference
        between average times is more than max_diff. If it is, raises error. test_case folder names have to be unique.

        Example usage. Note test_case -arguments:
        *** Test Cases ***
        Automated_OAMKPI_Site_Reset
            [Documentation]  Perform site reset and collect KPI results.
            [Tags]           "Site reset" -test loops: ${TEST_LOOPS}
             Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
                ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
                ...    name=Site Reset
                ...    test_case=Site_reset
                ...    loops=${TEST_LOOPS}
                ...    keywords=Site reset
                ...    expected_pass_rate=1.0
                ...    collect_test_logs=${COLLECT_LOGS}
                ...    omkpi_case=${True}
             Set Global Variable  ${AaTraceRecordUsed}  true
             Run Keyword And Continue On Failure  Run Keyword In Loop And Return Pass Rate
                ...    ${SYSLOG_LIST}  ${UNALLOWED_SYSLOGS}  ${WAIT_CHECKS}  ${WAIT_FOR_CELLS_UP}  ${OAM_KPI_TARGETS}
                ...    name=Site Reset
                ...    test_case=Site_reset_aatrace
                ...    loops=${TEST_LOOPS}
                ...    keywords=Site reset
                ...    expected_pass_rate=1.0
                ...    collect_test_logs=${COLLECT_LOGS}
                ...    omkpi_case=${True}
            Run Keyword And Continue On Failure  Compare Avg Times  max_diff=8

        :param int max_diff: Maximum difference between average times. Default is 10
        :return:
        """
        avg_times = self._collect_avg_times_from_files()
        if avg_times:
            if len(avg_times) == 2:
                for kpi in avg_times[list(avg_times.keys())[0]]:
                    diff = abs(avg_times[list(avg_times.keys())[0]][kpi] - avg_times[list(avg_times.keys())[1]][kpi])
                    if diff > int(max_diff):
                        error(f"Average time difference of {kpi} is too high. Difference is {diff}")
                        raise KpiValuesNotMatching(f"Average time difference of {kpi} is too high. "
                                                   f"Difference is {diff}")
                    else:
                        info(f"Average time difference of {kpi} is {diff}")
            else:
                error("Only two files are supported for comparing average times.")

    def _calculate_activation_time(self, activation_started, activation_success):
        """
        Calculate Activation Time

        :param list activation_started: SW build download started time
        :param list activation_success: Activation success time
        :return: Activation time delta datetime object
        """
        activation_started_str = activation_started[-1].split("SW build download started ")[1]
        activation_success_str = activation_success[-1].split("SW build activation result: success ")[1]
        info(f"\n{activation_started[-1]}\n{activation_success[-1]}")
        self.logger.debug(f"Get latest SW build download started : {activation_started_str}\nGet latest activation "
                          f"success time: {activation_success_str}")
        activation_started_time = datetime.strptime(activation_started_str, "%a %b %d %H:%M:%S %Y")
        activation_success_time = datetime.strptime(activation_success_str, "%a %b %d %H:%M:%S %Y")
        now = datetime.now()
        if (now - activation_success_time).total_seconds() > 901:
            error(f"Activation success time is more than 15min ago (now: {now}, activation success {activation_success}"
                  f") so not from this test run. Check from logs if there were some problems in SW activation.")
            raise SwActivationNotSuccessful("Activation success time is not from this test run.")
        activation_time = activation_success_time - activation_started_time
        info(f"Activation time from FDSW to RAT SW: {activation_time.total_seconds()} seconds")
        BuiltIn().set_suite_variable("${SW_ACTIVATION_DELTA_TIME}", activation_time)
        BuiltIn().set_suite_variable("${SW_SWDL_START_TIME}", activation_success_time)
        BuiltIn().set_suite_variable("${SW_ACTIVATION_END_TIME}", activation_success_time)
        return activation_time

    def get_sw_activation_time_from_fdsw_to_rat_sw(self, swdl_report_path, retry=0):
        """
        Get SW activation time from FDSW to RAT SW. Activation time is calculated from information in SWDLreport.

        :param str swdl_report_path: Path to SWDL report.
        :param int retry: Retry count. Default is 0. Will try to get SWDLreport.txt from BTS by ssh if SWDL report is
                                       empty.
        """
        with open(swdl_report_path, 'r') as f:
            content = f.read()
        if not content:
            if not self.bts:
                self.bts = BuiltIn().get_library_instance("BTS")
            ip = self.bts.default_smod_ip
            if retry == 0:
                info("SWDL report is empty. Try to get file /ffs/run/config/SWDLreport.txt by ssh connection")
                self.ssh.get_file_or_folder_from_bts_to_test_logs(
                    "/ffs/run/config/SWDLreport.txt", bts_ip=ip, local_dir=swdl_report_path)
                BuiltIn().sleep(5)
                self.get_sw_update_report_to_logs(swdl_report_path, retry=1)
            else:
                error("SWDL report is empty.")
                raise EnvironmentIssue("SWDL report is empty.")
        sw_build_dl_start = re.findall(r"SW build download started.*20\d\d", content)
        self.logger.debug(f"SW Build download started: {sw_build_dl_start}")
        activation_started = re.findall(r"SW build activation started.*20\d\d", content)
        self.logger.debug(f"Activation started: {activation_started}")
        activation_success = re.findall(r"SW build activation result: success.*20\d\d", content)
        self.logger.debug(f"Activation success: {activation_success}")
        if not sw_build_dl_start:
            error("SW build download started -text was not found from SWDL report.")
            raise EnvironmentIssue("SW build download started was not found from SWDLreport.txt.")
        if not activation_success:
            error("Activation result: success -text was not found from SWDLreport.txt.")
            raise EnvironmentIssue("Activation result: success was not found from SWDL report.")
        return self._calculate_activation_time(sw_build_dl_start, activation_success)

    def check_if_im_analysis_should_be_done_in_swdl(self):
        """
        Check If IM Analysis Should Be Done In SWDL checks if we should do IM Analysis for the snapshot.
        """
        run_im_analyser = BuiltIn().get_variable_value("${RUN_IM_ANALYSER}", default=None)
        if run_im_analyser:
            info("IM Analysis will be done after SWDL.")
            info("Check if there is snapshot in the files")
            snapshot_path = self.collect_logs.check_if_file_is_in_logs("snapshot", path_for_search=self.logger.log_dir,
                                                                       return_file_path=True, print_walk=True,
                                                                       files_renamed_to_5g4g=False)
            if not snapshot_path:
                info("Snapshot was not collected in test, collect it for IM analyzer use")
                snapshot_coverage = "FullWithoutRFLogs"
                if self.bts.smod_is_fsmf():
                    snapshot_coverage = "Full"
                self.collect_logs.collect_snapshot(extra_name="im_analyser",
                                                   connection_name="default",
                                                   coverage=snapshot_coverage,
                                                   reg_exp_filter="._startup.zip$|.ims.$|^.AaConfigRadMasterHistory.$",
                                                   no_rfs=True)
                ImAnalyserUsage().check_and_run_im_analyser("im_analyser.zip")
            else:
                ImAnalyserUsage().check_and_run_im_analyser(full_path_to_snapshot=snapshot_path)
        else:
            self.logger.debug("IM Analysis will not be done after SWDL.")
            print("IM Analysis will not be done after SWDL.")

    def enable_ssh_access_from_admin(self, timeout=60, admin_connection="log_admin", retry=0):
        """
        Enable ssh access from admin

        :param int timeout: Default is 60 seconds.
        :param str admin_connection: Default is log_admin.
        :param int retry: Default is 0. If 0, try to enable_ssh_access again once if there is error 6.
        """
        try:
            result = self.admin.enable_ssh_access(timeout=timeout, connection=admin_connection)
            print(f"Admin response for enable_ssh_access: {result}")
            self.logger.debug(f"Admin response for enable_ssh_access: {result}")
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            error(f"Problems when performing enable_ssh_access. {admin_error.__class__.__name__}:{admin_error} was "
                  f"raised.\n{tb}")
            if "ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb):
                if retry == 0:
                    info("Unable to give command enable_ssh_access from admin, because of session invalidation."
                         "Set test to fail so we will have logs about the issue and restart admin connection.")
                    BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                    if not self.bts:
                        self.bts = BuiltIn().get_library_instance("BTS")
                    self.bts.reset_admin_connection(admin=admin_connection)
                    BuiltIn().set_suite_variable("${RESTART_ADMIN_ERR_6}", "${True}")
                    info("Call method enable_ssh_access_from_admin again after admin connection reset.")
                    self.enable_ssh_access_from_admin(timeout=timeout, admin_connection=admin_connection, retry=1)
                elif retry == 1:
                    error("Unable to enable_ssh_access_from_admin, because of session invalidation. Admin connection "
                          "restart did not help.")
            raise ErrorFromAdmin(f"Problems when giving command enable_ssh_access from admin, "
                                 f"{admin_error.__class__.__name__} was raised.")

    def get_admin_logs_from_other_to_test_logs(self):
        """
        Get admin logs from other to test logs gets folder /tmp/admin_logs_other to test logs, that is created
        if LMP_SWDL is True and MASTER is other and SWDL test has been run.
        """
        info("Get admin logs from Other MASTER.")
        self.collect_logs.get_file_or_folder_by_scp("/tmp/admin_logs_other", self.collect_logs.remote_vm_ip, "ute",
                                                    self.collect_logs.remote_vm_pw)
        self.logger.debug("Remove folder from Other after copying it.")
        ssh_object = self.ssh.ssh_connection_to_given_ip(
            user_name="ute", ssh_password=self.collect_logs.remote_vm_pw, ip_to_connect=self.collect_logs.remote_vm_ip,
            name_for_log="remove_admin_log", print_to_eventlog=True, raise_error=True)
        if ssh_object:
            info("SSH connection to remote VM was successful. Remove folder /tmp/admin_logs_other")
            self.ssh.send_command_to_ip_by_ssh(
                "rm -rf /tmp/admin_logs_other/", ssh_object=ssh_object, return_output=False,
                ssh_timeout=180, print_to_eventlog=False, ip_to_connect=self.collect_logs.remote_vm_ip,
                username="ute", pw=self.collect_logs.remote_vm_pw, raise_error=True, disconnect_ssh=True)
        else:
            warning("Could not create SSH connection to the Other VM. Cannot get admin logs from the Other.")

    def get_e2e_startup_points_from_syslog_and_snapshot(self):
        """
        Get e2e startup points from syslog and snapshot
        """
        if BuiltIn().get_variable_value("${E2E_CHECKPOINTS}"):
            self.logger.debug("Get E2E startup points from syslog and snapshot")
            e2e_startup_points = E2EBtsStartupCheckpoint()
            e2e_startup_points.get_pssw_service_breakdown_kpi_check_points()
            self.logger.debug("E2E startup points from syslog and snapshot collected")
        else:
            info("E2E checkpoints are not collected (variable E2E_CHECKPOINTS is not given or it is False/Empty/None).")

    def _move_disconnection_logs_from_sub_folder_to_upper(self, im_path):
        """
        Move disconnection logs from sub folder to upper
        """
        if "/admin/" in im_path:
            print("Move file from admin sub folder to upper folder.")
            mv_im_path = self.collect_logs.move_file_to_folder(im_path, im_path.replace("/admin/", "/"))
            if mv_im_path:
                return mv_im_path
        return im_path

    def _get_from_disconnection_logs(self, log_path, omkpi_utilities):
        """
        Get from disconnection logs

        :param str log_path: Path to the log file
        :param omkpi_utilities: Instance named to oam_kpi_utilities from common_resources.robot
        :return: Path to the disconnection log file or None if not found
        """
        im_path = ""
        self.logger.debug(f"Try to find disconnection ims2 logs from path {log_path}")
        dir_content = os.listdir(log_path)
        print(f"Content of dir {log_path}: {dir_content}")
        disconnection_files = sorted(
            [d_f for d_f in dir_content if re.search(r'log_admin_disconnect_at_.*\.ims2$', d_f)])
        print(f"Sorted disconnection files: {disconnection_files}")
        if disconnection_files:
            im_path = os.path.join(log_path, disconnection_files[-1])  # the newest file
        im_path2 = omkpi_utilities.get_last_disconnected_ims_log(
            log_path, log_name_regex=r'admin_api_log_admin.*disconnect_at.*\.ims2$')
        if (im_path and im_path != im_path2) or (im_path2 and im_path != im_path2):
            warning(f"Method omkpi_utilities.get_last_disconnected_ims_log returns path {im_path2} that differs from "
                    f"the path was found {im_path}. If there are problems with KPI RST timestamp take contact to script"
                    f" developers.")
        if im_path:
            return self._move_disconnection_logs_from_sub_folder_to_upper(im_path)
        if im_path2:
            return self._move_disconnection_logs_from_sub_folder_to_upper(im_path2)
        return None

    def get_ims2_file_from_disconnection_file(self, fail_if_not_success=True):
        """
        Get Ims2 File From Disconnection File
        Sets path to self.collect_logs.ims_file_from_disconnection if the disconnect log exists otherwise raises error.

        :param bool fail_if_not_success: Default value is True. If we don't want the test to fail if there aren't any
                                         disconnection logs available, this can be given as False.
        """
        self.collect_logs.ims_file_from_disconnection = ""
        omkpi_utilities = BuiltIn().get_library_instance("oam_kpi_utilities")
        im_path = self._get_from_disconnection_logs(self.logger.log_dir, omkpi_utilities)
        if not im_path:
            log_path = os.path.join(self.logger.log_dir, "admin")
            im_path = self._get_from_disconnection_logs(log_path, omkpi_utilities)
        if not im_path:
            # check if disconnection log is found from a bit higher folder
            log_path = self.logger.log_dir[:self.logger.log_dir.rfind("/")]
            im_path = self._get_from_disconnection_logs(log_path, omkpi_utilities)
        if not im_path:
            # check if disconnection log is found admin folder from a bit higher folder
            l_path = self.logger.log_dir[:self.logger.log_dir.rfind("/")]
            log_path = os.path.join(l_path, "admin")
            im_path = self._get_from_disconnection_logs(log_path, omkpi_utilities)
        if im_path:
            info(f"Disconnection ims2 file was get from logs: {im_path}")
            self.collect_logs.ims_file_from_disconnection = im_path
            return self.collect_logs.ims_file_from_disconnection
        else:
            if fail_if_not_success:
                error("Could not get the disconnection logs created by admin_cli. RST timestamp may be missing. NOTE "
                      "that this may have effects to KPI calculations.")
                raise EnvironmentIssue("Could not get the disconnection logs.")
            else:
                info("Could not get the disconnection logs created by admin_cli. RST timestamp may be missing. NOTE "
                     "that this may have effects to KPI calculations.")
        return None

    def get_syslogs_and_e2e(self, wait_for_syslog_collection=2):
        """
        Get syslogs and e2e method checks if user wants to get E2E_CHECKPOINTS and if wants then gets them to file.
        After that it stops syslog and collects the syslogs. Then waits 2 seconds and starts syslog collection again.
        :param int/str wait_for_syslog_collection: Time to wait for after syslog collection before starting again.
                                                   Default is 2 seconds.
        :return: None
        """
        if not self.collect_logs:
            self.collect_logs = BuiltIn().get_library_instance("COLLECTLOGS")
        if not self.collect_logs.syslog_log_folder:
            warning("No syslog folder was set in CollectLogs library. Cannot get syslog folder to test logs.")
            return None
        # self.get_e2e_checkpoints_from_syslog()
        if BuiltIn().get_variable_value("${E2E_CHECKPOINTS}", default=False):
            e2e_startup_points = E2EBtsStartupCheckpoint()
            e2e_startup_points.get_pssw_service_breakdown_kpi_check_points()
# stop syslog and collect logs
        self.collect_logs.collect_syslog()
        BuiltIn().sleep(f"{wait_for_syslog_collection}s")
# start syslog collection for next test case
        self.collect_logs.start_syslog_collection()
        if self.collect_logs.rfs or BuiltIn().get_variable_value("${HIGH_AVAILABILITY_ENVIRONMENT}", default=False):
            self.collect_logs.start_remote_syslog_collection()
        return None

    def upgrade_phase_parameter_of_radios(self, upgrade_value, retry=0):
        """
        Check upgrade phase parameter of radios checks if radios have upgrade_value as upgradePhase. If any radio has
         different value, False is returned.

        :param str upgrade_value: Checked value.
        :param int retry: Default is 0. If 0, try to check_upgrade_phase_parameter again once if there is ErrorCode 6.
        :return bool: True if upgradePhase has expected otherwise False
        :raise EnvironmentIssue: If no RMOD distnames found (com.nokia.srbts.eqm:RMOD)
        """
        if (BuiltIn().get_variable_value("${ADD_KPI55D}", default=False) or
                BuiltIn().get_variable_value("${ADD_KPI55E}", default=False)):
            self.logger.debug(
                "In KPI#55d and KPI#55e tests value for upgradePhase is set in test to desired. Skip this check.")
            return False
        try:
            ru_distnames = self.scf.get_distname_based_on_class("com.nokia.srbts.eqm:RMOD")
            if not ru_distnames:
                error("No distnames from com.nokia.srbts.eqm:RMOD. There aren't any radios in environment or problems"
                      " with admin connection.")
                raise EnvironmentIssue("No values to class com.nokia.srbts.eqm:RMOD")
            phase_du = []
            phase_other = []
            for ru in ru_distnames:
                phases_all = self.admin.get_parameter_by_distname(
                    ru, parameter_list=["upgradePhase"], detailed_output=True)
                self.logger.debug(f"upgradePhase: {phases_all}")
                phases_list = phases_all['requestMessage']
                if phases_list:
                    for phase in phases_list:
                        if 'distName' in phase and phase["distName"] == ru:
                            if 'parameters' in phase:
                                if 'upgradePhase' not in phase['parameters']:
                                    info(f"No upgradePhase parameter found from {ru}.")
                                    phase_other.append(ru)
                                else:
                                    upv = str(phase['parameters']['upgradePhase'])
                                    info(f"The upgradePhase value for {ru} is {upv}.")
                                    if upv.lower() == upgrade_value.lower():
                                        self.logger.debug(f"The upgradePhase is {upgrade_value}")
                                        phase_du.append(ru)
                                    else:
                                        self.logger.debug(f"The upgradePhase is not {upgrade_value}")
                                        phase_other.append(ru)
                else:
                    info(f"No upgradePhase parameter found from {ru}.")
                    phase_other.append(ru)
            if phase_du and upgrade_value == "DU" and len(phase_du) == len(ru_distnames):
                warning(f"All radios have upgradePhase={upgrade_value}. RU sw will be activated during DU swdl and this"
                        f" may increase KPI.")
                return True
            else:
                self.logger.debug(f"Some of radios has upgradePhase different than DU {phase_other}.")
                return False
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            if ("ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb) and
                    retry == 0):
                info("Unable to check_upgrade_phase_parameter from admin, because of session invalidation."
                     "Set test to fail so we will have logs about the issue and restart admin connection.")
                info(tb)
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                if not self.bts:
                    self.bts = BuiltIn().get_library_instance("BTS")
                self.bts.reset_admin_connection(admin="default")
                info("Call method upgrade_phase_parameter_of_radios again after admin connection reset.")
                self.upgrade_phase_parameter_of_radios(upgrade_value, retry=1)
            else:
                error(f"Problems when performing check_upgrade_phase_parameter. {admin_error.__class__.__name__}:"
                      f"{admin_error} was raised.")
                info(f"{tb}")
            raise ErrorFromAdmin(f"Problems when check_upgrade_phase_parameter from admin, "
                                 f"{admin_error.__class__.__name__} was raised.")

    def special_logs_and_or_ssh_commands_after_reset_before_test(self, after_what="SWDL"):
        """
        Check if user has given values to suite variables SPECIAL_LOG and or to SSH_COMMANDS_BEFORE_TEST. If SPECIAL_LOG
        has value, collects all logs given in SPECIAL_LOG. If there is value in SSH_COMMANDS_BEFORE_TEST execute the
         commands after log collection.

        :param after_what: String to indicate after what action this method is called. Default is SWDL.
        """
        special_log = BuiltIn().get_variable_value("${SPECIAL_LOG}", default=None)
        ssh_commands_before_test = BuiltIn().get_variable_value("${SSH_COMMANDS_BEFORE_TEST}", default=None)
        if special_log:
            info(f"Collect log(s) '{special_log}' (before executing SSH commands again after {after_what})")
            self.collect_logs.special_log_collection(special_log, add_timestamp=True)
        if ssh_commands_before_test:
            info(f"Execute SSH command(s) '{ssh_commands_before_test}' again after {after_what}")
            ssh_object = self.ssh.send_command_to_smod_by_ssh(ssh_commands_before_test, disconnect_ssh=False,
                                                              ip_to_connect=OmkpiCommonInterface.bts_ip)
            self.collect_logs.add_ssh_object_to_list(ssh_object)

    def _check_sw_precheck_results(self, result):
        """
        Check sw precheck results. Checks software precheck result and write it to a text file.

        :param dict result: Response dictionary from software_precheck_local.
        """
        import json

        if not isinstance(result, dict):
            error(f"Software precheck result is not dict (type={type(result)}), skip report writing.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise SoftwarePrecheckFailure(f"Response from admin is expected to be dictionary, but is {type(result)}")
        request_status = str(result.get("requestStatus", "N/A")).strip().lower()
        err_code = str(result.get('errorCode', 'N/A'))
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        report_path = os.path.join(self.logger.log_dir, f"software_precheck_report_{timestamp}.txt")
        lines = [
            "Software Precheck Report",
            "========================",
            f"time: {result.get('time', 'N/A')}",
            f"requestStatus: {request_status}",
            f"errorCode: {err_code}",
            "",
            "Full admin response payload:",
            json.dumps(result, indent=2, ensure_ascii=False),
            "",
        ]

        with open(report_path, "w", encoding="utf-8") as report_file:
            report_file.write("\n".join(lines))
        info(f"Software precheck report written to: {report_path}")
        if err_code != '0':
            error(f"Software precheck failed with errorCode {err_code} and requestStatus {request_status}. Check the "
                  f"report for details.")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise SoftwarePrecheckFailure(f"Software precheck failed with errorCode {err_code}.")
        else:
            info("Software precheck passed.")

    def software_precheck(self, sw_package, precheck_type='FullCheck', check_timeout=300, connection="log_admin",
                          retry=0):
        """
        Software precheck checks if there is any problems with software package before starting SWDL.

        :param sw_package: Path to software zip for checks.
        :param str precheck_type: can have value 'FullCheck', 'RebootCheck' or 'UpgradeCheck'. Defaulr is 'FullCheck'.
        :param int check_timeout: timeout for precheck. Default is 300s.
        :param str connection: Name for admin connection to be used for checks.
        :param int retry: Parameter for retries.
        """
        info(f"Doing '{precheck_type}' for build {sw_package}...")
        result = {}
        try:
            result = self.admin.software_precheck_local(
                sw_package, precheck_type, timeout=check_timeout, connection=connection)
        except (AdminApiProcedureFailureException, AdminApiProcedureTimeoutException, AdminApiNoResponseException,
                AliasLookupError, AdminApiTerminatedException, AliasInUse,
                AdminApiConnectionClosedException) as admin_error:
            tb = ''.join(format_exception(type(admin_error), admin_error, admin_error.__traceback__))
            info(tb)
            if ("ErrorCode: 6" in tb and ("Version request failed" in tb or "http sessionId invalid" in tb)) and (
                    retry == 0):
                info("Unable to do software_precheck, because of admin session invalidation. Set test to fail so we"
                     " will have logs about the issue and restart admin connection.")
                BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
                if not self.bts:
                    self.bts = BuiltIn().get_library_instance("BTS")
                self.bts.reset_admin_connection(admin=connection)
                self.software_precheck(sw_package, precheck_type=precheck_type, check_timeout=check_timeout,
                                       connection=connection, retry=1)
            error(f"Problems when doing software precheck: {admin_error.__class__.__name__}: {admin_error}")
            raise SoftwarePrecheckFailure(f"{admin_error.__class__.__name__} was raised when doing software precheck.")
        if not result:
            error("Admin didn't return any response for command software_precheck_local. Check documentation of "
                  "taf.sbts.oam.coam.admin library")
            BuiltIn().set_suite_variable("${KW_SUCCESS}", "${False}")
            raise SoftwarePrecheckFailure("Admin didn't return any response for command software_precheck_local.")
        self._check_sw_precheck_results(result)
