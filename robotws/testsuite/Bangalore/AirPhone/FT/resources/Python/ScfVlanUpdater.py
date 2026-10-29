import os
import subprocess
import importlib.util

try:
    from ute_common_config_files.scfc.scfc import Scfc
except ImportError:
    os.system('pip install ute_common_config_files')
    from ute_common_config_files.scfc.scfc import Scfc

# Name of the TL configuration package folder
TESTLINE_CONFIGURATION_DIR = "/home/ute/testline_configuration"


class Host:
    def __init__(self):
        self.hostname = self.get_hostname()

    def get_hostname(self):
        hostname = subprocess.check_output(["hostname"]).decode().strip()
        return hostname.replace("-", "_")


class ScfVlanUpdater:
    """
    CI-safe SCF updater.
    Fetches VLAN ID from TL config and updates SCF in-place.
    """

    def _load_tl_module(self, tl_name):
        """
        Load TL config as a module from absolute path (CI-safe).
        """
        tl_path = os.path.join(TESTLINE_CONFIGURATION_DIR, tl_name, "__init__.py")

        if not os.path.exists(tl_path):
            raise FileNotFoundError(f"TL config not found at: {tl_path}")

        spec = importlib.util.spec_from_file_location(tl_name, tl_path)
        tl_module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(tl_module)
        return tl_module

    def update_scf_with_tl_info(self, scf_input_path):
        if not os.path.exists(scf_input_path):
            raise FileNotFoundError(f"SCF file not found: {scf_input_path}")

        # Step 1: Detect hostname
        host = Host()
        tl_name = host.hostname
        print(f"[INFO] Hostname: {tl_name}")

        # Step 2: Load TL module dynamically (CI-safe)
        tl_config = self._load_tl_module(tl_name)
        print(f"[INFO] Loaded TL config from: {tl_config.__file__}")

        # Step 3: Fetch VLAN ID
        try:
            new_vlan = tl_config.tl.gnbs[0].cu.x2c.vlan_id
            print(f"[INFO] VLAN ID from TL config: {new_vlan}")
        except Exception as e:
            raise Exception(f"Unable to fetch VLAN ID from TL config: {e}")

        # Step 4: Load SCF
        root = Scfc(scf_input_path)

        mo = root.find_managed_object(
            "MRBTS-1/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1"
        )
        if mo is None:
            raise Exception("VLANIF-1 managed object not found in SCF")

        vlan_param = mo.find_param("vlanId")
        if vlan_param is None:
            raise Exception("vlanId parameter not found in SCF")

        # Step 5: Replace VLAN
        vlan_param.value = new_vlan
        print(f"[INFO] Updated SCF VLAN ID to: {new_vlan}")

        # Step 6: Save SCF in-place
        root.save(scf_input_path)
        print(f"[INFO] SCF file updated successfully: {scf_input_path}")

        return scf_input_path
