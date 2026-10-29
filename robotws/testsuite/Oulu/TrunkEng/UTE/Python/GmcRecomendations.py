import json
from logging import disable
import pprint
import socket
import sys
import re
import subprocess
import yaml
from pathlib import Path
from time import sleep, time
from typing import Any, Dict, List, Optional, Tuple
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, warning
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.WorkflowTool import WorkflowTool
from taf.sbts.oam.coam.admin import admin, AdminConnection
from taf.internal.sbts.admin.exceptions import AdminApiException, AdminApiVersionMismatchException
from taf.sbts.oam.coam.admin.exceptions import DataNotAvailable
from robot.libraries.BuiltIn import BuiltIn


class GmcRecomendations:
    """
    Class for Automated GMC-Recomendation checking.
    """

    def __init__(self):
        self.taf_admin: Optional[admin] = None
        self.taf_connection: Optional[AdminConnection] = None
        self.reservation_context_json: Any = None
        self.output_folder = BuiltIn().get_variable_value("${OUTPUT DIR}") or "/home/ute/test_results"
        Path(self.output_folder).mkdir(parents=True, exist_ok=True)
        self.sw_builds_folder = BuiltIn().get_variable_value("${BUILDS DIR}") or "/home/ute/sw_builds"
        Path(self.sw_builds_folder).mkdir(parents=True, exist_ok=True)
        self.testline_init_results_folder = BuiltIn().get_variable_value("${TESTLINE INIT RESULTS DIR}") or\
            "/home/ute/testline_init_results"
        Path(self.testline_init_results_folder).mkdir(parents=True, exist_ok=True)
        self.logger = BuiltIn().get_library_instance("LOG")
        info(
            f"output_folder: '{self.output_folder}' "
            f"sw_builds_folder: '{self.sw_builds_folder}' "
            f"testline_init_results_folder : '{self.testline_init_results_folder}'"
            )

    def _execute_popen(self, command: str) -> Tuple[Any, Any, int]:
        proc = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
        stdout, stderr = proc.communicate()
        return stdout, stderr, proc.returncode

    def get_reservation_context(self) -> Dict[str, Any]:
        """
        This method reads content of file /opt/ute/reservation.context.json
        """
        if not self.reservation_context_json:
            reservation_context = Path("/opt/ute/reservation.context.json")
            if reservation_context.exists():
                info("Read /opt/ute/reservation.context.json")
                self.reservation_context_json = json.loads(reservation_context.read_text())
            else:
                warning(f"File {reservation_context.absolute()} doesn't exists, check reservation.")
        return self.reservation_context_json

    def get_cm_tags(self) -> List[str]:
        """
        Gets all TAGS that have been used when creating reservation. Returns used TAGS.
        """
        reservation_context_json = self.get_reservation_context()
        used_tags = []
        if reservation_context_json:
            for cm_element in reservation_context_json["CM_TAGS"]:
                used_tags.append(cm_element)
        return used_tags

    def get_topology_name(self, cm_tags: List[str]) -> Optional[str]:
        """
        Get's topology_name
        """
        topology_name = None
        for tag in cm_tags:
            if tag.lower().startswith("cloud_"):
                topology_name = tag
                break
        return topology_name

    def install_ute_ca_hook_dynamic_commissioning(self) -> None:
        """
        Install's ute-ca-hook-dynamic-commissioning
        """
        cmd = f"{sys.executable} -m pip install ute-ca-hook-dynamic-commissioning -U"
        info(f"Installing ute-ca-hook-dynamic-commissioning with cmd: '{cmd}'")
        stdout, stderr, returncode = self._execute_popen(cmd)
        info(f"stdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'")
        if returncode:
            info("Installing ute-ca-hook-dynamic-commissioning failed.")
            raise Exception(
                "Installing ute-ca-hook-dynamic-commissioning failed."
                f"\nstdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'"
                )

    def get_ta_dynamic_commissioning_tag(self, cm_tags: List[str]) -> Optional[str]:
        """
        Get's tag_or_branch
        """
        tag_or_branch = None
        for tag in cm_tags:
            if "ta_dyn_com_source" in tag.lower():
                tag_or_branch = tag.split("=", 1)[1]
                break
        return tag_or_branch

    def install_ta_dynamic_commissioning(self, tag_or_branch: str) -> None:
        """
        Install's ta-dynamic-commissioning
        """
        cmd = f"{sys.executable} -m pip uninstall ta-dynamic-commissioning -y;{sys.executable} -m pip install "\
            "git+https://vdtl:r2ps5quoFUGWkEyui_Yi@gitlabe2.ext.net.nokia.com/uca/libs/ta-dynamic-commissioning.git@"\
            f"{tag_or_branch} -U"
        info(f"Installing ta-dynamic-commissioning from {tag_or_branch} with cmd: '{cmd}'")
        stdout, stderr, returncode = self._execute_popen(cmd)
        info(f"stdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'")
        if returncode:
            info("Installing ta-dynamic-commissioning failed.")
            raise Exception(
                "Installing ta-dynamic-commissioning failed."
                f"\nstdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'"
                )

    def get_sw_branches(self, cm_tags: List[str]) -> List[str]:
        """
        Get sw-branches from CM_TAGS
        """
        branches = []
        for tag in cm_tags:
            if "branches" in tag.lower():
                branches.extend((tag.split("=", 1)[1]).split(";"))
                break
        branches.sort()
        if "SBTS00" in branches:
            branches.remove("SBTS00")
            branches.append("SBTS00")
        info(f"Sw-branches: {branches}")
        return branches

    def download_sw_build(self, build: str) -> str:
        """
        Downloads sw-build
        """
        filename = rf"{build}.*downloadable_A54.zip"
        branch = build.split("_")[0] if "FSM3" not in build else "_".join(build.split("_")[:2])
        # Remove earlier downloaded sw-build to prevent space running out
        cmd = f"rm -f {self.sw_builds_folder}/SBTS*.zip && wget --directory-prefix {self.sw_builds_folder} "\
            f"--no-verbose --no-parent --no-directories --recursive --accept-regex '{filename}$' " \
            "https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build/"\
            f"{branch}/{build}/ && rm -f {self.sw_builds_folder}/index.html"
        info(f"Downloading build with cmd: '{cmd}'")
        stdout, stderr, returncode = self._execute_popen(cmd)
        info(f"stdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'")

        results = re.findall(rf"\".*{filename}.*\"", stderr)
        if not results:
            info(f"Downloading '{build}' failed.")
            raise Exception(
                f"Downloading '{build}' failed."
                f"\nstdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'"
                )
        return results[0][1:-1]  # Don't include first " and last "

    def get_builds_for_branch(self, branch: str, page: int, promoted_builds: List[str]) -> Tuple[List[str], int]:
        """
        Get sw-build for branch
        """
        branch_builds = []
        while not branch_builds:
            branch_builds = [
                build for build in promoted_builds
                if (
                    build.startswith(branch) and
                    (
                        ("FSM3" in branch and "FSM3" in build) or
                        ("FSM3" not in branch and "FSM3" not in build)
                        )
                    )
                ]
            info(f"branch_builds: {branch_builds} for branch {branch}")
            if not branch_builds:
                if page >= 10:
                    break
                promoted_builds.extend(WorkflowTool.promoted_builds(page=page))
                info(f"promoted_builds from pages 1-{page}: {promoted_builds}")
                page += 1
        return branch_builds, page

    def wait_until_cmd(self, cmd: str, timeout: int, until_fails: bool) -> None:
        """
        Waits until cmd fails or succeeds.
        """
        start_time = time()
        while True:
            info(f"Executing cmd: '{cmd}'")
            stdout, stderr, returncode = self._execute_popen(cmd)
            info(f"\nstdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'")
            if (returncode and until_fails) or (not returncode and not until_fails):
                break
            if (time() - start_time) >= timeout:
                info(f"Cmd {cmd} has NOT {'failed' if until_fails else 'succeeded'} after timeout {timeout}.")
            sleep(10)

    def wait_until_bts_is_up(self, timeout: int) -> None:
        """
        Waits until BTS is up.
        """
        start_time = time()
        while True:
            cmd = f"ping -c 1 192.168.255.129"
            info(f"Pinging BTS with cmd: '{cmd}'")
            _, _, returncode = self._execute_popen(cmd)
            if not returncode:
                break
            if (time() - start_time) >= timeout:
                info(f"BTS's state is NOT valid after timeout {timeout}.")
                raise Exception(f"BTS's state is NOT valid after timeout {timeout}.")
            sleep(30)

        while True:
            try:
                bts_statuses = self.taf_connection.get_bts_statuses()
                info(f"bts_statuses: '{bts_statuses}'")
                if "onair" in bts_statuses.get("proceduralState", "").lower():
                    break
            except AdminApiVersionMismatchException as e:
                info(f"AdminApiVersionMismatchException: '{str(e)}'")
                info("Re-connecting to BTS")
                self.close_admin_connection()
                self.make_admin_connection(timeout=max(30, timeout - int(time() - start_time)))
            except AdminApiException as e:
                info(f"AdminApiException: '{str(e)}'")

            if (time() - start_time) >= timeout:
                info(f"BTS's state is NOT valid after timeout {timeout}.")
                raise Exception(f"BTS's state is NOT valid after timeout {timeout}.")
            sleep(30)

    def wait_until_cells_are_up(self, timeout: int) -> None:
        """
        Waits until Cell(s) are up.
        """
        start_time = time()
        while True:
            cmd = f"ping -c 1 192.168.255.129"
            info(f"Pinging BTS with cmd: '{cmd}'")
            _, _, returncode = self._execute_popen(cmd)
            if not returncode:
                break
            if (time() - start_time) >= timeout:
                info(f"Cell's state are NOT valid after timeout {timeout}.")
                raise Exception(f"Cell's state are NOT valid after timeout {timeout}.")
            sleep(30)

        disabled_cells = []
        while True:
            try:
                bts_info = self.taf_connection.get_bts_info()
                lte_cells_info = bts_info.get("cells", {}).get("lte", [])
                info(f"lte-cells_info:\n'{pprint.pformat(lte_cells_info, indent=4)}'")
                nr_cells_info = bts_info.get("cells", {}).get("nr", [])
                info(f"nr-cells_info:\n'{pprint.pformat(nr_cells_info, indent=4)}'")
                disabled_cells = []
                for cell in lte_cells_info + nr_cells_info:
                    if cell.get("status", {}).get("operationalState") != "enabled":
                        disabled_cells.append(cell)
                if not disabled_cells:
                    break
            except AdminApiVersionMismatchException as e:
                info(f"AdminApiVersionMismatchException: '{str(e)}'")
                info("Re-connecting to BTS")
                self.close_admin_connection()
                self.make_admin_connection(timeout=max(30, timeout - int(time() - start_time)))
            except AdminApiException as e:
                info(f"AdminApiException: '{str(e)}'")

            if (time() - start_time) >= timeout:
                info(
                    f"Cell's state are NOT valid after timeout {timeout}. Disabled cells:\n" +
                    pprint.pformat(
                        [
                            {"globalCellId": cell.get("globalCellId"), "status": cell.get("status")}
                            for cell in disabled_cells
                        ], indent=4
                        )
                    )
                raise Exception(f"Cell's state are NOT valid after timeout {timeout}.")
            sleep(30)

    def wait_until_sw_version_has_changed(self, prev_build: str, timeout: int) -> None:
        """
        Waits until BTS is up.
        """
        start_time = time()
        while True:
            cmd = f"ping -c 1 192.168.255.129"
            info(f"Pinging BTS with cmd: '{cmd}'")
            _, _, returncode = self._execute_popen(cmd)
            if not returncode:
                break
            if (time() - start_time) >= timeout:
                info(f"BTS's state is NOT valid after timeout {timeout}.")
                raise Exception(f"BTS's state is NOT valid after timeout {timeout}.")
            sleep(30)

        while True:
            try:
                sw_version = self.taf_connection.get_sw_version()
                info(f"current sw_version: '{sw_version}'")
                if prev_build != sw_version:
                    break
            except DataNotAvailable as e:
                info(f"DataNotAvailable: '{str(e)}'")
            except AdminApiVersionMismatchException as e:
                info(f"AdminApiVersionMismatchException: '{str(e)}'")
                info("Re-connecting to BTS")
                self.close_admin_connection()
                self.make_admin_connection(timeout=max(30, timeout - int(time() - start_time)))
            except AdminApiException as e:
                info(f"AdminApiException: '{str(e)}'")

            if (time() - start_time) >= timeout:
                info(f"BTS's sw-version has NOT changed after timeout {timeout}.")
                raise Exception(f"BTS's sw-version has NOT changed after timeout {timeout}.")
            sleep(30)

    def make_commissioning_file(
        self, sw_package: str, branch: str, topo_config_file: Path, hook_config_file: Path
            ) -> str:
        """
        Makes commissioning-file for requested branch.
        """
        hook_config = json.loads(hook_config_file.read_text())
        for config in hook_config:
            for build in config.get("builds", []):
                build.update({
                    "name": sw_package,
                    "branch": branch,
                    "sw_version": sw_package, })

        branch_hook_config_file = Path(f"{hook_config_file.parent}/{branch}_hook_config_for_node_1.json")
        branch_hook_config_file.write_text(json.dumps(hook_config, indent=4, sort_keys=True))

        topo_config = yaml.full_load(topo_config_file.read_text())
        entrypoint = topo_config.get("ute_ca_hooks", {}).get("commission", {}).get("entrypoint")

        files = topo_config.get("variants", [{}])[0].get("nodes", [{}])[0].get("files", [])
        scf_file_path = [file.get("file_path") for file in files if file.get("file_type") == "scf"][0]
        scf_result_path = str(Path(f"{self.output_folder}/{branch}_{scf_file_path}").absolute())

        cmd = f"(cd {topo_config_file.parent} && "\
            f"{entrypoint} --config '{branch_hook_config_file.absolute()}' && cp {scf_file_path} {scf_result_path})"
        info(f"Making commissioning with cmd: '{cmd}'")

        stdout, stderr, returncode = self._execute_popen(cmd)
        info(f"stdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'")

        if returncode:
            info("Making commissioing file failed.")
            raise Exception(
                "Making commissioing file failed."
                f"\nstdout:\n'{stdout}'\nstderr:\n'{stderr}'\nreturncode: '{returncode}'"
                )
        return scf_result_path

    def make_admin_connection(self, timeout) -> None:
        """
        Make's admin connection
        """
        start_time = time()
        while True:
            try:
                self.taf_admin = admin()
                self.taf_connection = self.taf_admin.connect_to(timeout=max(30, timeout - int(time() - start_time)))
                break
            except AdminApiException as e:
                info(f"AdminApiException: '{str(e)}'")
            if (time() - start_time) >= timeout:
                info(f"Could NOT connect to BTS after timeout {timeout}.")
                raise Exception(f"Could NOT connect to BTS after timeout {timeout}.")
            sleep(30)

    def close_admin_connection(self) -> Any:
        """
        Close's admin connection
        """
        if self.taf_admin and self.taf_connection:
            self.taf_admin.teardown(connection=self.taf_connection)
            self.taf_admin = None
            self.taf_connection = None

    def perform_commissioning(self, commissioning_file: str, timeout: int) -> None:
        """
        Perform commissioning
        """
        start_time = time()
        while True:
            try:
                info(f"Performing commissioning. Timeout: {max(30, timeout - int(time() - start_time))}")
                self.taf_connection.perform_commissioning(
                    scf_file=commissioning_file, timeout=max(30, timeout - int(time() - start_time)))
                break
            except AdminApiException as e:
                info(f"AdminApiException: '{str(e)}'")
                info("Waiting 60s and trying again")
                sleep(60)
                info("Re-connecting to BTS")
                self.close_admin_connection()
                self.make_admin_connection(timeout=max(30, timeout - (time() - start_time)))
            if (time() - start_time) >= timeout:
                info(f"Could NOT commissioned BTS after timeout {timeout}.")
                raise Exception(f"Could NOT commissioned BTS after timeout {timeout}.")

    def collect_gmc_logs(self) -> None:
        """
        Collect's GMC Logs
        """
        self.install_ute_ca_hook_dynamic_commissioning()
        cm_tags = self.get_cm_tags()
        info(f"CM_TAGS: {cm_tags}")
        ta_dyn_com_tag_or_branch = self.get_ta_dynamic_commissioning_tag(cm_tags=cm_tags)
        if ta_dyn_com_tag_or_branch:
            self.install_ta_dynamic_commissioning(tag_or_branch=ta_dyn_com_tag_or_branch)

        topology_name = self.get_topology_name(cm_tags=cm_tags)
        host_name = socket.gethostname().replace("-", "_")

        info("Connecting to admin")
        self.make_admin_connection(timeout=45*60)
        page = 1
        promoted_builds = []
        branches = self.get_sw_branches(cm_tags=cm_tags)
        max_retries_per_branch = 2
        errors = []
        try:
            for branch_index, branch in enumerate(branches):
                try:
                    branch_builds, page = self.get_builds_for_branch(
                        branch=branch, page=page, promoted_builds=promoted_builds)
                    if not branch_builds:
                        info(f"Sw-build for branch '{branch}' not found from promoted builds.")
                        raise Exception(f"Sw-build for branch '{branch}' not found from promoted builds.")
                    branch_build = Path(branch_builds[0])

                    current_build = self.taf_connection.get_sw_version()
                    info(f"Current BTS-build: '{current_build}'")
                    trunk_build = branch_build.name.startswith("SBTS00")
                    current_build_splits = current_build.split("_", 1)
                    branch_build_splits = branch_build.name.split("_", 1)
                    if (not trunk_build and current_build_splits[0] != branch_build_splits[0]) or \
                       (trunk_build and current_build_splits[1] != branch_build_splits[1]):
                        sw_package = Path(self.download_sw_build(build=branch_build.name))

                        info(f"Updating sw to: '{sw_package.absolute()}'")
                        self.taf_connection.update_software(str(sw_package.absolute()), timeout=45*60)

                        remove_key_cmd = 'ssh-keygen -f "/home/ute/.ssh/known_hosts" -R "192.168.255.129"'
                        info(f"Removing key with cmd: {remove_key_cmd}")
                        self._execute_popen(remove_key_cmd)

                        info("Waiting until ssh-connection to BTS id down")
                        self.wait_until_cmd(
                            cmd="sshpass -poZPS0POrRieRtu ssh toor4nsn@192.168.255.129 uname -m",
                            timeout=15*60,
                            until_fails=True
                            )

                        info(f"Removing key with cmd: {remove_key_cmd}")
                        self._execute_popen(remove_key_cmd)

                        info("Waiting until ssh-connection to BTS id up")
                        self.wait_until_cmd(
                            cmd="sshpass -poZPS0POrRieRtu ssh toor4nsn@192.168.255.129 uname -m",
                            timeout=15*60,
                            until_fails=False
                            )

                        info("Waiting until BTS is up (onAir)")
                        self.wait_until_bts_is_up(timeout=45*60)

                        info("Waiting until sw-version has changed in BTS")
                        self.wait_until_sw_version_has_changed(prev_build=current_build, timeout=45*60)

                    commissioning_file = self.make_commissioning_file(
                        sw_package=branch_build.name.split("_release", 1)[0],
                        branch=branch,
                        topo_config_file=Path(
                            f"{self.testline_init_results_folder}/execution/configs/topology_configs/node_1/config.yaml"
                            ),
                        hook_config_file=Path(
                            f"{self.testline_init_results_folder}/execution/configs/hooks/hook_config_for_node_1.json"
                            ))

                    if branch_index or ta_dyn_com_tag_or_branch:
                        info(f"Performing commissioning, scf-file: '{commissioning_file}'")
                        self.perform_commissioning(commissioning_file=commissioning_file, timeout=15*60)

                        for try_count in range(max_retries_per_branch):
                            try:
                                info("Waiting 60s before continuing")
                                sleep(60)

                                info("Waiting until BTS is up (onAir)")
                                self.wait_until_bts_is_up(timeout=45*60)

                                info("Waiting until all Cell(s) are up (operationalState==enabled)")
                                self.wait_until_cells_are_up(timeout=15*60)
                                break
                            except Exception as try_count_exception:
                                info(
                                    f"Exception occurred during waiting after commissioning:"
                                    f" '{str(try_count_exception)}'."
                                    )
                                if try_count + 1 >= max_retries_per_branch:
                                    raise try_count_exception
                                info(f"Resetting site and retrying for branch '{branch}'.")
                                reset_status = self.taf_connection.reset_site()
                                info(f"Reset site with result: '{reset_status}'")
                    else:
                        info(
                            "BTS commissioning is skipped because BTS is already commissioned in the first branch: "
                            f"{branch} by the ute-ca and NO branch/tag is defined for ta-dynamic-commissioning."
                            )
                    info("Getting current scf-file (configurationAndRuntimeObjects) from BTS.")
                    scf = self.taf_connection.get_scf(
                        export_type="configurationAndRuntimeObjects",
                        with_auto_configured_parameters=True,
                        )
                    org_bts_id = int(re.search(r"BTS-(\d+)", scf).group(1))
                    new_bts_id = org_bts_id + branch_index * 100000
                    scf_file = Path(f"{self.output_folder}/{host_name}_{topology_name}_{branch}.xml")
                    scf_file.write_text(
                        scf if org_bts_id == new_bts_id else scf.replace(f"BTS-{org_bts_id}", f"BTS-{new_bts_id}")
                        )
                    info(
                        (f"Replaced 'BTS-{org_bts_id}' to 'BTS-{new_bts_id}' and saved scf to "
                            if org_bts_id != new_bts_id else "Saved scf to ") +
                        f"'{scf_file.absolute()}'"
                        )
                except Exception as e:
                    info(
                        f"Exception occurred during processing branch '{branch}'. '{str(e)}'" +
                        (
                            " Continuing with next branch." if ((branch_index + 1) < len(branches)) else
                            " No more branches to process.")
                        )
                    errors.append({
                        "branch": branch,
                        "reason": f"Exception occurred: '{str(e)}'."
                    })
        finally:
            info("Admin-connection teardown")
            self.close_admin_connection()
        if errors:
            info(f"GMC-Recommendation errors:\n{pprint.pformat(errors, indent=4)}")
            raise Exception(f"GMC-Recommendation errors: {errors}")
