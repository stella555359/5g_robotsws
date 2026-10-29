import os
import subprocess
import sys
import shutil
from robot.api import logger
from packaging.version import Version
from pathlib import Path
# from ute_ca_utils.models.topology_configs import ConfigFile


UTE_AGENT_PATH = "/opt/ute-ca/"
HOOK_NAME = "ute-ca-hook-aic-docker-knife"
# TOPOLOGY_VARIANT = "SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD"


class Hook:
    def __init__(self):
        self.hook_config_path = "/home/ute/testline_init_results/execution/configs/hooks/hook_config_for_node_1.json"
        self.topology_config_base_path = "/home/ute/testline_init_results/execution/configs/topology_configs/node_1"
        self.python_version_new_venv_path = ""
        self.python_version_new_venv_path_full = ""
        self.existing_swconfig_lines = []

    def run_hook(self, command):
        activate_script = Path(self.python_version_new_venv_path_full) / "bin" / "activate"
        if not activate_script.exists():
            raise FileNotFoundError(f"Activation script not found at {activate_script}")
        shell_command = f"cd {self.topology_config_base_path} && source {activate_script} && {command}"
        logger.info(f"Running command: {shell_command}", also_console=True)

        result = subprocess.run(
            shell_command, shell=True, text=True, capture_output=True, executable="/bin/bash", check=True)
        logger.info(result.stdout)  # przerobic na printowanie do pliku
        if result.returncode != 0:
            raise subprocess.CalledProcessError(returncode=result.returncode, cmd=shell_command,
                                                output=result.stdout, stderr=result.stderr)
        else:
            logger.info(f"Applying flags using {HOOK_NAME} with command {command} done.", also_console=True)
        return result

    @staticmethod
    def get_highest_python_version(base_path):
        try:
            entries = os.listdir(base_path)
            versions = []
            for entry in entries:
                full_path = os.path.join(base_path, entry)
                if os.path.isdir(full_path):
                    try:
                        versions.append(Version(entry))
                    except ValueError:
                        pass
            return str(max(versions)) if versions else None
        except Exception as e:
            print(f"Error occured {e}")
            return None

    @staticmethod
    def activate_venv_and_install_hook(venv_path):
        venv_path = Path(venv_path)
        if os.name == "nt":  # Windows
            activate_script = venv_path / "Scripts" / "activate.bat"
            pip_executable = venv_path / "Scripts" / "pip"
        else:  # Unix/Linux/Mac
            activate_script = venv_path / "bin" / "activate"
            pip_executable = venv_path / "bin" / "pip"
        if not activate_script.exists():
            raise FileNotFoundError(f"Activation script not found at {activate_script}")
        try:
            logger.info(f"Installing {HOOK_NAME} in virtual environment: {venv_path}")
            subprocess.run(
                [str(pip_executable), "install", HOOK_NAME], check=True, text=True,
                stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
            logger.info(f"Successfully installed {HOOK_NAME} in {venv_path}.")
        except subprocess.CalledProcessError as e:
            logger.error(f"An error occurred during installation: {e}")
            sys.exit(1)

    @staticmethod
    def copy_ute_agent_venv_to_different_location(source, destination):
        src_dir = os.path.abspath(source)
        dest_dir = os.path.abspath(destination)
        if not os.path.isdir(src_dir):
            raise FileNotFoundError(f"Source directory does not exist: {src_dir}")
        try:
            subprocess.run(["sudo", "mkdir", "-p", dest_dir], check=True)
            subprocess.run(
                ["sudo", "cp", "-r", source + ".", destination],
                check=True,
                text=True
            )
            logger.info(f"Successfully copied {source} to {destination}")
        except subprocess.CalledProcessError as err:
            logger.error(f"Error occured while copying directory: {err}")

    @staticmethod
    def change_user_and_group_to_ute(target_dir):
        user_group = "ute"
        try:
            subprocess.run(["sudo", "chown", "-R", f"{user_group}:{user_group}", target_dir])
            logger.info(f"Successfully changed ownership of {target_dir} to {user_group}:{user_group}.")
        except subprocess.CalledProcessError as err:
            logger.error(f"Error occured while copying directory: {err}")

    def install_hook_in_venv(self, new_venv_name):
        new_venv_name_dir = os.path.join("/opt", new_venv_name)
        self.copy_ute_agent_venv_to_different_location(UTE_AGENT_PATH, new_venv_name_dir)
        if os.path.exists(new_venv_name_dir) and os.path.exists(UTE_AGENT_PATH):
            self.change_user_and_group_to_ute(new_venv_name_dir)
            self.change_user_and_group_to_ute(UTE_AGENT_PATH)
        else:
            logger.error(f"Provided path {new_venv_name_dir} does not exist.")
        highest_python_version = self.get_highest_python_version(os.path.join(new_venv_name_dir, "versions"))
        python_version_new_venv_path_partial = os.path.join(new_venv_name_dir, "versions", highest_python_version)
        new_venv_path = os.path.join(
            python_version_new_venv_path_partial, "envs", new_venv_name.replace("_", "-"))
        self.python_version_new_venv_path_full = new_venv_path
        self.activate_venv_and_install_hook(new_venv_path)

    def get_topology_config_file(self, topology):
        if os.path.exists(self.topology_config_base_path):
            topology_config_path = os.path.join(self.topology_config_base_path, topology, "config.yaml")
            return topology_config_path
            # YAML + ute_ca_utils.models.topology_configs import ConfigFile - da sie zrobic?
            # load_config = load(topology_config_path)
            # print(ConfigFile(**load_config))
            # return ConfigFile(**load_config)
        else:
            logger.error(f"Provided path {self.topology_config_base_path} does not exist.")

    def read_swconfig_content(self, swconfig_file):
        if os.path.exists(swconfig_file):
            with open(swconfig_file, "r") as file:
                self.existing_swconfig_lines = file.read().splitlines()
        else:
            self.existing_swconfig_lines = []

    def append_flags_to_swconfig(self, flags, topology, component):
        """Append R&D flags to specific swconfig component. Allowed component names: l2rt or cprt."""
        swconfig_file_path = os.path.join(
            self.topology_config_base_path, topology, f"dockerfiles-{component}", f"swconfig_{component}.txt")
        try:
            self.read_swconfig_content(swconfig_file_path)
            with open(swconfig_file_path, 'a') as file:
                for i, line in enumerate(flags):
                    if not isinstance(line, str):
                        logger.error(f"Warning: Non-string value at index {i}: {line}")
                        continue
                    if line not in self.existing_swconfig_lines:
                        file.write(line + ("\n" if i < len(flags) - 1 else ""))
                        self.existing_swconfig_lines.append(line)
        except FileNotFoundError as err:
            logger.error(f"Provided path: {swconfig_file_path} does not exist. {err}")

    @staticmethod
    def _read_file_lines(file_path):
        """Read lines from a file, handling file not found gracefully."""
        try:
            with open(file_path, 'r') as file:
                return file.readlines()
        except FileNotFoundError:
            return []

    @staticmethod
    def _write_updated_lines(file_path, lines):
        """Write updated lines back to the file."""
        with open(file_path, 'w') as file:
            file.writelines(lines)

    def clear_flags_in_swconfig(self, flags, topology, component):
        """
        Remove specified flags from the swconfig file.
        Flags should be in the form of strings, e.g., "KEY=VALUE".
        """
        swconfig_file_path = os.path.join(
            self.topology_config_base_path, topology, f"dockerfiles-{component}", f"swconfig_{component}.txt")
        try:
            self.read_swconfig_content(swconfig_file_path)
            lines = self._read_file_lines(swconfig_file_path)
            filtered_lines = [line for line in lines if line.strip() not in flags]
            self._write_updated_lines(swconfig_file_path, filtered_lines)
        except FileNotFoundError as err:
            logger.error(f"Provided path: {swconfig_file_path} does not exist. {err}")

    def copy_dockerfiles_and_config_yaml(self, topology, dockerfile_src, config_yaml_src):
        dockerfiles_dir_dest = os.path.join(self.topology_config_base_path, topology)
        if not os.path.exists(dockerfiles_dir_dest.rstrip("/") + "/dockerfiles-l2rt"):
            shutil.copytree(dockerfile_src, dockerfiles_dir_dest.rstrip("/") + "/dockerfiles-l2rt")
            shutil.copy2(config_yaml_src, self.topology_config_base_path)

    def add_content_to_yaml_file(self):
        pass


# flags = ['0x58093B=50',    '0x58093C=50',    '0x58093D=9',   '0x58093E=1',    '0x58093F=100',
#     '0x580940=50',    '0x580941=50',    '0x580942=9',    '0x580943=1',    '0x580944=100']
#
# hook = Hook()
# hook.append_flags_to_swconfig(flags=flags, topology="SANSA_FS_CPRI_CMWV_FDD+ECPRI_CMWV_TDD", component="l2rt")
# hook.install_hook_in_venv(new_venv_name="ute_ca_venv")
# hook.run_hook(
#     "ute-ca-hook-aic-docker-knife knife --config "
#     "/home/ute/testline_init_results/execution/configs/hooks/hook_config_for_node_1.json")
