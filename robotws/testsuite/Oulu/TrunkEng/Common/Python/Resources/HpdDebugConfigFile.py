"""
:author:  Terhi Talvitie
:contact: I_MN_RAN_RD_TV_OTACI_CITCRT1@internal.nsn.com
"""

from robot.libraries.BuiltIn import BuiltIn
from traceback import format_exception
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import error, info
from testsuite.Oulu.TrunkEng.Common.Python.Resources.exceptions import (ScriptIssue, InvalidUserInput)


class HpdDebugConfigFile:
    """
    HpdDebugConfigFile is used for faulting BBMODs by user given BBMOD_MASK value. This is used for testing the new
    feature CB012702 -  Improving the BTS start-up time when faulty ABIO or any-other Baseband card is not detected.
    """
    mask_value_fsp_slot = {
        '0x02': ['BBMOD1'],  # FSP slot1 disabled
        '0x04': ['BBMOD2'],  # FSP slot2 disabled
        '0x06': ['BBMOD1', 'BBMOD2'],  # FSP slots 1&2 disabled
        '0x08': ['BBMOD3'],  # FSP slot3 disabled
        '0x0A': ['BBMOD1', 'BBMOD3'],  # FSP slots 1&3 disabled
        '0x0C': ['BBMOD2', 'BBMOD3'],  # FSP slots 2&3 disabled
        '0x0E': ['BBMOD1', 'BBMOD2', 'BBMOD3'],  # FSP slots 1,2&3 disabled

        '0x20': ['BBMOD1'],  # FSP slot4 disabled NOTE if fullrack then this should be BBMOD2.1
        '0x40': ['BBMOD2'],  # FSP slot5 disabled NOTE if fullrack then this should be BBMOD2.2
        '0x60': ['BBMOD1', 'BBMOD2'],  # FSP slots 4&5 disabled
        '0x80': ['BBMOD3'],  # FSP slot6 disabled NOTE if fullrack then this should be BBMOD2.3
        '0xA0': ['BBMOD1', 'BBMOD3'],  # FSP slots 4&6 disabled
        '0xC0': ['BBMOD2', 'BBMOD3'],  # FSP slots 5&6 disabled
        '0xE0': ['BBMOD1', 'BBMOD2', 'BBMOD3'],  # FSP slots 4,5&6 disabled

        '0x22': ['BBMOD1', 'BBMOD2.1'],  # FSP slot 1 & 4 disabled
        '0x44': ['BBMOD2', 'BBMOD2.2'],  # FSP slot 2 & 5 disabled
        '0x66': ['BBMOD1', 'BBMOD2', 'BBMOD2.1', 'BBMOD2.2'],  # FSP slots 1,2,4,5 disabled
        '0x88': ['BBMOD3', 'BBMOD2.3'],  # FSP slot 3,6 disabled
        '0xAA': ['BBMOD1', 'BBMOD3', 'BBMOD2.1', 'BBMOD2.3'],  # FSP slots 1,3,4,6 disabled
        '0xCC': ['BBMOD2', 'BBMOD3', 'BBMOD2.2', 'BBMOD2.3'],  # FSP slots 2,3,5,6 disabled
        '0xEE': ['BBMOD1', 'BBMOD2', 'BBMOD3', 'BBMOD2.1', 'BBMOD2.2', 'BBMOD2.3'],  # FSP slots 1,2,3,4,5 & 6 disabled
    }

    @staticmethod
    def _modify_fullrack_bbmods():
        """
        Make list bbmod names for fullrack environment. For example BBMOD1 becomes BBMOD2.1, BBMOD2 becomes BBMOD2.2
        and BBMOD3 becomes BBMOD2.3
        """
        for key in HpdDebugConfigFile.mask_value_fsp_slot:
            modified_bbmods = []
            if key[-1] == "0":
                print(f"Change {key}: {HpdDebugConfigFile.mask_value_fsp_slot[key]}")
                for v in HpdDebugConfigFile.mask_value_fsp_slot[key]:
                    if "." not in v:
                        modified_bbmods.append(f"{v[:-1]}2.{v[-1]}")
                    else:  # already in fullrack right-side-style, so keep as is
                        modified_bbmods.append(v)
                HpdDebugConfigFile.mask_value_fsp_slot[key] = modified_bbmods
        print(f"Modified mask value dictionary for fullrack environment: {HpdDebugConfigFile.mask_value_fsp_slot}")

    @staticmethod
    def _modify_bbmod_list(bbmods):
        """Make list bbmod names equal to HpdDebugConfigFile.mask_value_fsp_slot names"""
        bbmod_list = []
        for bbmod in bbmods:
            if "." in bbmod:
                bbmod_list.append(bbmod.replace(bbmod[:-3], 'BBMOD'))
            else:
                bbmod_list.append(bbmod.replace(bbmod[:-1], 'BBMOD'))
        return bbmod_list

    def _check_if_mask_given_to_bbmod_that_exists(self, bbmods, mask_value_bbmods):
        """
        Check if mask value is given to bbmod that exists in the environment.

        :parma list bbmods: List of bbmod names in the environment
        :param list mask_value_bbmods: List of bbmod names that are affected by the mask value
        """
        modified_bbmods = self._modify_bbmod_list(bbmods)
        err_bbmod = []
        for bbmod in mask_value_bbmods:
            if bbmod not in modified_bbmods:
                err_bbmod.append(bbmod)
        if err_bbmod:
            error(f"Given mask value {self.bbmod_mask} includes BBMODs {err_bbmod} that are not found from the "
                  f"environment, all found bbmods are {bbmods} ({modified_bbmods}).")
            InvalidUserInput(f"Given mask value is for BBMODs that are not found from the reserved environment.")

    def check_mask_value_user_input(self, side_is_right, fullrack, bbmod_objects):
        """
        Check mask value user input. Check if mask value is for left side BBMODs, right side BBMODs or both sides
        BBMODs.

        :param bool side_is_right: Is BTS side right side. True or False.
        :param bool fullrack: Is BTS fullrack. True or False.
        """
        bbmods = [bbmod.name for bbmod in bbmod_objects]
        print(f"Checking mask value {self.bbmod_mask} for user input. Side is right: {side_is_right}, fullrack: "
              f"{fullrack}, bbmods: {bbmods}")
        if self.bbmod_mask not in HpdDebugConfigFile.mask_value_fsp_slot:
            error(f"Given mask value {self.bbmod_mask} is not valid. It is not found Check mask value dictionary: "
                  f"{HpdDebugConfigFile.mask_value_fsp_slot}.")
            raise InvalidUserInput(f"Given mask value {self.bbmod_mask} is not valid.")
        if fullrack:
            info(f"Environment is full rack. Modify BBMOD names of mask value dictionary for fullrack environment.")
            self._modify_fullrack_bbmods()
        if self.bbmod_mask[-2] == '0':  # Command is to left side BBMODs
            print("User given BBMOD_MASK is to left side BBMOD(s)")
            if side_is_right and not fullrack:
                info(f"User given mask value {self.bbmod_mask} is for left side BBMODs but environment is not full "
                     f"rack and BBMODs in this environment are on right side. Change mask value for right side.")
                self.bbmod_mask = f"{self.bbmod_mask[:-2]}{self.bbmod_mask[-1]}{self.bbmod_mask[-2]}"
                info(f"Changed given mask value to {self.bbmod_mask} for right side BBMODs.")
        elif self.bbmod_mask[-1] == '0':  # Command is to right side BBMODs
            print("User given BBMOD_MASK is to right side BBMOD(s)")
            if not side_is_right and not fullrack:
                info(f"User given mask value {self.bbmod_mask} is for right side BBMODs but environment is not full "
                     f"rack and BBMODs in the environment are on left side. Change mask value for left side.")
                self.bbmod_mask = f"{self.bbmod_mask[:-2]}{self.bbmod_mask[-1]}{self.bbmod_mask[-2]}"
                info(f"Changed given mask value to {self.bbmod_mask} for left side BBMODs.")
        elif self.bbmod_mask[-1] != '0' and self.bbmod_mask[-2] != '0':  # Command is to BBMODS of both sides
            print("User given BBMOD_MASK is to BBMODs on both sides.")
            if not fullrack:
                info(f"User given mask value {self.bbmod_mask} is for both sides BBMODs but environment is not "
                     f"full rack. Change mask value.")
                if side_is_right:
                    self.bbmod_mask = f"{self.bbmod_mask[:-1]}0"
                    info(f"Changed given mask value to {self.bbmod_mask} for right side BBMODs.")
                else:
                    self.bbmod_mask = f"{self.bbmod_mask[:-2]}0{self.bbmod_mask[-1]}"
                    info(f"Changed given mask value to {self.bbmod_mask} for left side BBMODs.")
        else:
            info(f"Mask value {self.bbmod_mask} is OK for this test environment without changes.")
        if self.bbmod_mask not in HpdDebugConfigFile.mask_value_fsp_slot:
            error(f"Mask value {self.bbmod_mask} is not valid. It is not found Check mask value dictionary: "
                  f"{HpdDebugConfigFile.mask_value_fsp_slot}.")
            raise ScriptIssue(f"Mask value {self.bbmod_mask} is not valid.")
        mask_value_bbmods = HpdDebugConfigFile.mask_value_fsp_slot[self.bbmod_mask]
        self._check_if_mask_given_to_bbmod_that_exists(bbmods, mask_value_bbmods)
        return self.bbmod_mask

    def __init__(self):
        """
        :param string bbmod_mask: BBMOD_MASK value
        """
        self.bbmod_mask = BuiltIn().get_variable_value("${BBMODS_MASK}")
        self.ssh = BuiltIn().get_library_instance("SSH")
        self.logger = BuiltIn().get_library_instance("LOG")

    def write_mask_value_to_file_and_reboot(self):
        """
        Write BBMODS_MASK value to the config file. This is used for faulting BBMODs by user given BBMOD_MASK value.
        1. Ssh to smod
        2. Create file /ffs/run/config/hpd_debug_config.txt
        3. Add BBMODS_MASK value to file, for example hpd_detect_only_mask=0x02
        4. crasign /ffs/run/config/hpd_debug_config.txt
        5. reboot
        """
        try:
            commands = [
                "ls /ffs/run/config/",
                f"echo hpd_detect_only_mask={self.bbmod_mask} > /ffs/run/config/hpd_debug_config.txt",
                "crasign /ffs/run/config/hpd_debug_config.txt",
                f"ls /ffs/run/config/",
                "reboot"
            ]
            self.ssh.send_command_to_smod_by_ssh(commands)
        except Exception as e:
            error(f"Problems while writing BBMODS_MASK value to the /ffs/run/config/hpd_debug_config.txt file. "
                  f"{e.__class__.__name__}:{e}\n"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise ScriptIssue(f"Problems when adding BBMODS_MASK value. {e.__class__.__name__}:{e}")

    def remove_mask_value_from_file_and_reboot(self):
        """
        Remove BBMODS_MASK value from the config file. This is used for faulting BBMODs by user given BBMOD_MASK value.
        1. Ssh to smod
        2. Remove file /ffs/run/config/hpd_debug_config.txt
        3. reboot
        """
        try:
            info("Removing /ffs/run/config/hpd_debug_config* files.")
            commands = [
                "ls /ffs/run/config/",
                "rm /ffs/run/config/hpd_debug_config*",
                "ls /ffs/run/config/",
                "reboot"
            ]
            self.ssh.send_command_to_smod_by_ssh(commands)
        except Exception as e:
            error(f"Problems while removing mask {e.__class__.__name__}:{e}"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
            raise ScriptIssue(f"Problems while removing mask {e.__class__.__name__}:{e}")
