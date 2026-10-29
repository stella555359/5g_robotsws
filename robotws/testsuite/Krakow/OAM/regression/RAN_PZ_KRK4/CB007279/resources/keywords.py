from moler.device import DeviceFactory
from moler.exceptions import ExecutionException
from moler.util.moler_test import MolerTest
from taf.rfrl.bts.connections import device_aliases
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from robot.libraries.BuiltIn import BuiltIn


class HubPassword:

    def __init__(self):
        self.builtin = BuiltIn()
        self.hash_dict = dict()
        self.password_hash_paths = \
            ["/ffs/run/config/ASICNTR/WsUser.data", "/ffs/run/config/huacadm.db", "/ffs/run/config/huacapp.db"]

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def get_password_hash_for_all_users(self, bts_id=0, du_id=0):
        """
        Get password hash.

        :param bts_id: BTS ID
        :param du_id: DU ID
        :return: None
        """

        for password_hash_path in self.password_hash_paths:
            self.hash_dict.update({password_hash_path: self._get_password_hash(path=password_hash_path)})
        MolerTest.info("hash dict:", dump=self.hash_dict)

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_passwords_are_synced_to_passive_partition(self, bts_id=0, du_id=0):
        """
        Verify that passwords are synced to passive partition.

        :param bts_id: BTS ID
        :param du_id: DU ID
        :return: None
        """
        error_dict = dict()
        for password_hash_path in self.password_hash_paths:
            new_hash = self._get_password_hash(path=password_hash_path, bts_id=bts_id, du_id=du_id)["LINES"]
            if new_hash != self.hash_dict[password_hash_path]["LINES"]:
                error_dict.update({password_hash_path: {"active partition": self.hash_dict,
                                                        "passive partition": new_hash}})
        if error_dict:
            MolerTest.error("Passwords are not synced after sw rollback",
                            dump=error_dict,
                            raise_exception=True)
        else:
            MolerTest.info("Passwords are synced after sw rollback")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_passwords_are_not_synced_to_passive_partition(self, bts_id=0, du_id=0):
        """
        Verify that passwords are not synced to passive partition.

        :param bts_id: BTS ID
        :param du_id: DU ID
        :return: None
        """
        new_hash_dict = dict()
        error_dict = dict()
        for password_hash_path in self.password_hash_paths:
            new_hash_dict.update({password_hash_path: self._get_password_hash(path=password_hash_path,
                                                                              bts_id=bts_id, du_id=du_id)})
        MolerTest.info("hash dict:", dump=new_hash_dict)
        for path in self.password_hash_paths:
            if new_hash_dict[path] == self.hash_dict[path]:
                error_dict.update({path: {"active partition": self.hash_dict, "passive partition": new_hash_dict}})
        if error_dict:
            MolerTest.error("Passwords are synced after sw rollback",
                            dump=error_dict,
                            raise_exception=True)
        else:
            MolerTest.info("Passwords are not synced after sw rollback")

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def _get_password_hash(self, path, bts_id=0, du_id=0):
        """
        Get password hash.

        :param bts_id: BTS ID
        :param du_id: DU ID
        :return: None
        """
        vm = DeviceFactory.get_device(device_aliases.ssh_bts_du.format('GNB', bts_id, du_id), initial_state="FCT")
        return vm.get_cmd(cmd_name="cat", cmd_params={"path": path + "; echo"})()

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions()
    def verify_asir_users_credentials_are_cleared(self, bts_id=0, du_id=0):
        """
        Verify that ASiR users credentials are cleared on the platform (/ffs/run/config).

        :param bts_id: BTS ID
        :param du_id: DU ID
        :return: None
        """
        users_error_list = list()
        for password_hash_path in self.password_hash_paths:
            try:
                cmd_output = self._get_password_hash(path=password_hash_path, bts_id=bts_id, du_id=du_id)
                if ".db" in password_hash_path and "No such file or directory" not in cmd_output["LINES"][0]:
                    users_error_list.append(password_hash_path.split("/")[-1].split(".")[0])
            except ExecutionException as e:
                if ".db" in password_hash_path and "No such file or directory" not in str(e):
                    raise e
            if ".data" in password_hash_path and len(cmd_output["LINES"]) > 1:
                users_error_list.append(password_hash_path.split("/")[-1].split(".")[0])
        if users_error_list:
            MolerTest.error("ASiR users: {} credentials are not cleared".format(",".join(users_error_list)))
