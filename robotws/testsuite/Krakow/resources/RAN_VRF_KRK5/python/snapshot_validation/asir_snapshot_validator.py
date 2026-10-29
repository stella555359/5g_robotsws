import importlib.util
import json
import os.path
import re
from taf.rfrl.bts.devices.asir.asir_operations import GnbAsirHubOperations
from taf.rfrl.bts.devices.du.commissioning import GnbCommissioning
from taf.rfrl.bts.devices.du.du_operations import GnbDuOperations
from taf.rfrl.bts.devices.exceptions import FileNotFound
from taf.rfrl.bts.parsers.snapshot_analyzer import find_mandatory_files_in_snapshot
from taf.rfrl.procedures.resources.python.logger import log_result
from taf.rfrl.utilities.test_config import get_repository_path, DefaultFileLocation
from taf.rfrl.utilities.logger.custom_logger import log_warn_to_console, log_info_to_console


class AsirSnapshotValidator:
    ASIR_SNAPSHOT_FILES = {}
    ASIR_RRH_VERSION = {}
    AASIR_HUB_VERSION = {}

    @staticmethod
    def get_asir_variables(asir_variables_file):
        """
        Loads ASIR variables from a specified Python file.

        This function dynamically imports a Python file containing ASIR variables and updates the class-level
        dictionaries `ASIR_SNAPSHOT_FILES`, `ASIR_RRH_VERSION`, and `AASIR_HUB_VERSION` with the values from the file.

        Args:
            asir_variables_file (str): The path to the Python file containing ASIR variables.

        Raises:
            FileNotFoundError: If the specified file does not exist.
        """
        asir_variables_file_path = os.path.join(get_repository_path(), asir_variables_file)
        module_name = os.path.splitext(os.path.basename(asir_variables_file))[0]
        spec = importlib.util.spec_from_file_location(module_name, asir_variables_file_path)
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
        AsirSnapshotValidator.ASIR_SNAPSHOT_FILES = module.ASIR_SNAPSHOT_FILES
        AsirSnapshotValidator.ASIR_RRH_VERSION = module.ASIR_RRH_VERSION
        AsirSnapshotValidator.AASIR_HUB_VERSION = module.AASIR_HUB_VERSION
        log_info_to_console(f'asir_variables_file = `{asir_variables_file_path}`\n')

    @staticmethod
    def get_info_about_asir_hubs():
        """
        Retrieves information about ASIR hubs, including their types and associated pico types.

        This function first gathers cable link types for the hubs and then uses the GnbAsirHubOperations
        to get additional information about all hubs, including their cell and antenna mappings.
        It updates the hub information with the type and pico types extracted from the antennas.

        Returns:
            dict: A dictionary where the keys are hub identifiers and the values are dictionaries
                containing the hub type and a set of pico types.
        """
        def extract_pico_types(antennas):
            """
            Extracts the types of pico antennas from the given antenna information.

            Args:
                antennas (dict): A dictionary containing antenna information.

            Returns:
                set: A set of unique pico types.
            """
            return {antenna_info['type'] for antenna_info in antennas.values()}

        asir_hubs_info = AsirSnapshotValidator.get_cable_link_types_for_hubs()
        asir_hub_operation = GnbAsirHubOperations()
        additional_hubs_info = asir_hub_operation.get_all_hubs_with_cell_and_antenna_mapping()
        for hub, hub_info in additional_hubs_info.items():
            asir_hubs_info[hub].update({
                'type': hub_info['type'],
                'pico': extract_pico_types(antennas=hub_info['antennas'])
            })
        return asir_hubs_info

    @staticmethod
    def get_cable_link_types_for_hubs():
        """
        Retrieves the cable link types for ASIR hubs.

        This function uses the GnbDuOperations to get BTS information and extracts the cable link types
        for the ASIR hubs based on the configuration of the radio modules and cables.

        Returns:
            dict: A dictionary where the keys are the serial numbers of the ASIR modules and the values
                are dictionaries containing the cable link type and the name of the ASIR module.
        """
        asir_pattern = r".*(ASIRMOD-\d)"
        gnb_du = GnbDuOperations()
        bts_info = gnb_du.get_bts_info()
        temp_info = {
            re.match(asir_pattern, str(module['id']['configuration'])).group(1): module['serialNumber']
            for module in bts_info['radioModules']['asirmod']
        }
        hubs_info = {}
        for cable in bts_info['cables']:
            configuration = cable['secondEndPointId']['configuration']
            match = re.match(asir_pattern, str(configuration))
            if match:
                asir_name = match.group(1)
                hubs_info[temp_info[asir_name]] = {
                    'cablinkType': cable['cablinkType'],
                    'name': asir_name
                }
        return hubs_info

    @staticmethod
    def get_asir_files(asir_serial, files_type='COMMON'):
        """
        Generates a list of ASIR file patterns based on the given ASIR serial number and file type.

        Args:
            asir_serial (str): The serial number of the ASIR module.
            files_type (str): The type of files to retrieve patterns for. Defaults to 'COMMON'.

        Returns:
            list: A list of file patterns for the specified ASIR serial number and file type.
        """
        release = DefaultFileLocation().get_commissioning_branch()
        if release in ['SBTS24R3', 'SBTS25R1']:
            return [f'BTS_{asir_serial}_RMOD_\\w_\\d{file_name}' for file_name in
                    AsirSnapshotValidator.ASIR_SNAPSHOT_FILES[files_type]]
        mrbts_id = GnbDuOperations().get_global_bts_id()
        return [f'BTS{mrbts_id}_{asir_serial}_RMOD_\\w_\\d{file_name}' for file_name in
                AsirSnapshotValidator.ASIR_SNAPSHOT_FILES[files_type]]

    @staticmethod
    def get_mandatory_asir_files():
        """
        Retrieves the mandatory ASIR files required for each ASIR hub.

        This function gathers information about ASIR hubs and generates a list of mandatory file patterns
        for each hub based on its type, pico types, and cable link type.

        Returns:
            dict: A dictionary where the keys are ASIR serial numbers and the values are lists of mandatory file
                  patterns.
        """
        def extend_files(asir_serial, files_type):
            """
            Extends the list of files for a given ASIR serial number with additional file patterns based on the file
            type.

            Args:
                asir_serial (str): The serial number of the ASIR module.
                files_type (str): The type of files to retrieve patterns for.
            """
            files[asir_serial].extend(AsirSnapshotValidator.get_asir_files(asir_serial=asir_serial,
                                                                           files_type=files_type))

        asir_hubs_info = AsirSnapshotValidator.get_info_about_asir_hubs()
        files = {}
        for asir_serial, hub_info in asir_hubs_info.items():
            files[asir_serial] = AsirSnapshotValidator.get_asir_files(asir_serial=asir_serial)
            if AsirSnapshotValidator.AASIR_HUB_VERSION[hub_info['type']] == 'HUB_VER2':
                extend_files(asir_serial=asir_serial, files_type='HUB_VER2')
            for pico in hub_info['pico']:
                if AsirSnapshotValidator.ASIR_RRH_VERSION[pico] == 'PICO_VER1':
                    extend_files(asir_serial=asir_serial, files_type='PICO_VER1')
                elif AsirSnapshotValidator.ASIR_RRH_VERSION[pico] == 'PICO_VER2':
                    extend_files(asir_serial=asir_serial, files_type='PICO_VER2')
                elif AsirSnapshotValidator.ASIR_RRH_VERSION[pico] == 'PICO_VER3':
                    extend_files(asir_serial=asir_serial, files_type='PICO_VER3')
            if hub_info['cablinkType'] == 'eCPRI':
                extend_files(asir_serial=asir_serial, files_type='eCPRI')
        log_result(f'files')
        return files

    @staticmethod
    def combine_all_mandatory_files(files_per_hub):
        """
        Combines all mandatory files from multiple hubs into a single list.

        Args:
            files_per_hub (dict): A dictionary where the keys are hub identifiers and the values are lists of file
            patterns.

        Returns:
            list: A combined list of all file patterns from all hubs.
        """
        return [file for files in files_per_hub.values() for file in files]

    @staticmethod
    def remove_prefix_from_filename(file_name):
        """
        Removes the prefix from the given file name if it matches a specific pattern.

        This function uses a regular expression to match and remove the prefix from the file name.
        The prefix is expected to follow the pattern 'BTS_<serial>_RMOD_<w>_<d>'.

        Args:
            file_name (str): The name of the file from which to remove the prefix.

        Returns:
            str: The file name without the prefix if the pattern matches, otherwise the original file name.
        """
        pattern = r'BTS_\S+_RMOD_\\w_\\d_(.*)'
        match = re.match(pattern, file_name)
        return match.group(1) if match else file_name

    @staticmethod
    def check_for_asir_files_in_snapshot(snapshot_file, asir_variables_file):
        """
        Checks the snapshot directory for the presence of mandatory ASIR files.

        This function finds all mandatory files in the given snapshot directory and compares them
        with the list of mandatory ASIR files. It identifies any missing files and raises a FileNotFound
        exception if any mandatory files are missing.

        Args:
            snapshot_file (str): The path to the snapshot file to check.
            asir_variables_file (str): The path to the asir_variables_file.py file.

        Raises:
            FileNotFound: If any mandatory ASIR files are missing.

        """
        AsirSnapshotValidator.get_asir_variables(asir_variables_file=asir_variables_file)
        files_in_snapshot, files_dict = find_mandatory_files_in_snapshot(directory=snapshot_file,
                                                                         return_extended_info=True)
        files_in_snapshot.extend(files_dict)
        mandatory_files = AsirSnapshotValidator.get_mandatory_asir_files()
        all_missing_files = []
        for asir in mandatory_files:
            log_result(f'ASIR_SERIAL: {asir}')
            asir_mandatory_files = mandatory_files[asir]
            missing_files = []
            for mandatory_file in asir_mandatory_files:
                regex = re.compile(rf'{mandatory_file}')
                founded_file = list(filter(regex.match, files_in_snapshot))
                if not founded_file:
                    file_name = AsirSnapshotValidator.remove_prefix_from_filename(mandatory_file)
                    missing_files.append(file_name)
                else:
                    log_result(f'FILE PATTERN: {mandatory_file}')
                    log_result(f'FILE FOUND: {set(founded_file)}')
                    log_result('')

            if missing_files:
                all_missing_files.append({'ru_serial_number': asir, 'missing_files': f'{missing_files}'})
        if all_missing_files:
            log_result(f'MISSING FILES: {all_missing_files}')
            raise FileNotFound(all_missing_files)

    @staticmethod
    def convert_status_to_json(status):
        """
        Converts the given status string to a JSON object.

        This function processes the status string by removing unnecessary parts,
        replacing certain characters, and formatting it into a valid JSON string.
        It then logs the formatted status and converts it to a JSON object.

        Args:
            status (str): The status string to be converted.

        Returns:
            dict: The JSON object representation of the status string.
        """
        status = "".join(status.split())
        status = re.sub(r'^.*?\[', '[', status)
        status = status.split('}]', 1)[0] + '}]'
        status = f'{status}'
        status = status.replace('\'', '\"').replace('\"[', '[').replace(']\"', ']')
        return json.loads(status)

    @staticmethod
    def check_snapshot_status(status, expected_missing_files):
        """
        Checks the snapshot status against the expected missing files.

        This function converts the status string to a JSON object, filters out the expected missing files,
        and identifies any files that are really missing. If any files are found to be really missing,
        it raises a FileNotFound exception.

        Args:
            status (str): The status string to be checked.
            expected_missing_files (dict): A dictionary where the keys are ASIR serial numbers and the values
                                           are lists of file names that are expected to be missing.

        Raises:
            FileNotFound: If any files are found to be really missing.
        """
        def filter_missing_files(rrh):
            """
            Filters out the expected missing files from the list of reported missing files.

            Args:
                rrh (dict): A dictionary containing the reported missing files for a specific ASIR module.

            Returns:
                list: A list of file names that are really missing.
            """
            return [
                file_name for file_name in rrh['missing_files']
                if file_name not in expected_missing_files.get(rrh['ru_serial_number'], [])
            ]

        reported_missings = AsirSnapshotValidator.convert_status_to_json(status)
        really_missing = []
        if not expected_missing_files:
            really_missing = reported_missings
        else:
            for reported_missing in reported_missings:
                really_missing_files = filter_missing_files(rrh=reported_missing)
                if really_missing_files:
                    really_missing.append({
                        'ru_serial_number': reported_missing['ru_serial_number'],
                        'missing_files': really_missing_files,
                    })
        if really_missing:
            log_warn_to_console(f'Really missing {really_missing}')
            raise FileNotFound(str(really_missing))
        else:
            log_info_to_console('Only expected files are missing.\n')

    @staticmethod
    def get_asir_csv_path(asir_csv_file):
        """
        Retrieves the file path to the ASIR CSV file.

        This function constructs the full path to the ASIR CSV file by combining the repository path
        with the relative path to the CSV file.

        Returns:
            str: The full file path to the ASIR CSV file.
        """
        gnb_scf = GnbCommissioning()
        if gnb_scf.is_asir_configuration():
            asir_csv_path = os.path.join(get_repository_path(), asir_csv_file)
            log_info_to_console(f'asir_csv_file = `{asir_csv_path}`\n')
            return asir_csv_path
        return None

    @staticmethod
    def get_all_asirhubs_serials():
        asir_hub_operation = GnbAsirHubOperations()
        return asir_hub_operation.get_all_hubs_with_cell_and_antenna_mapping().keys()

    @staticmethod
    def verify_if_missing_files_defined_for_asirhubs(expected_missing_files):
        if expected_missing_files:
            asirhubs_serials = AsirSnapshotValidator.get_all_asirhubs_serials()
            missing_asirhubs_serials = expected_missing_files.keys()
            if any(element in asirhubs_serials for element in missing_asirhubs_serials):
                return True
        return False
