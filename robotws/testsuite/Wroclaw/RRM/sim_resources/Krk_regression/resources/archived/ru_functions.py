from taf.rfrl.bts.devices.ru.ru_operations import GnbRuOperations
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl
from moler.device import DeviceFactory


class ru_functions(GnbRuOperations):

    @load_moler_configuration_from_tl()
    def compare_password_hashes_between_bts_and_ru(self, password, user="serviceuser", gnb_id=0, du_id=0):
        """
        Compares password hashes between bts and ru for given user
        :param user:        User to compare values for
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: bool       True if equal / False if diffrent
        """
        ru = DeviceFactory.get_device(self.ssh_ru_alias.format(gnb_id, du_id, 0))
        ru._configurations['CONNECTION_HOPS']['FHNET']['RU']["command_params"]['password'] = password
        ru.goto_state("FHNET")
        cat_cmd = ru.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/shadow",
                                                         "options": " | grep {}".format(user)})
        output1 = cat_cmd()['LINES'][0].split(":")[1]
        ru.goto_state("RU")
        cat_cmd2 = ru.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/shadow",
                                                          "options": " | grep {}".format(user)})
        sudo_cmd = ru.get_cmd(cmd_name="sudo",
                              cmd_params={
                                  "cmd_object": cat_cmd2
                              })
        output2 = sudo_cmd()['LINES'][0].split(":")[1]
        return output1 == output2

    @load_moler_configuration_from_tl()
    def compare_ssh_login_configuration_parameters_between_bts_and_ru(self, password, gnb_id=0, du_id=0):
        """
        Compare SSH Login Configuration Parameters Between Bts and RU
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :return: bool       True if equal / False if diffrent
        """
        ru = DeviceFactory.get_device(self.ssh_ru_alias.format(gnb_id, du_id, 0))
        ru._configurations['CONNECTION_HOPS']['FHNET']['RU']["command_params"]['password'] = password
        ru.goto_state("FHNET")
        cat_cmd = ru.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/ssh/sshd_config",
                                                         "options": "| grep Client | sort | uniq"})
        output1 = cat_cmd()['LINES']
        ru.goto_state("RU")
        cat_cmd2 = ru.get_cmd(cmd_name="cat", cmd_params={"path": "/etc/ssh/sshd_config",
                                                          "options": "| grep Client | sort | uniq"})
        sudo_cmd = ru.get_cmd(cmd_name="sudo",
                              cmd_params={
                                  "cmd_object": cat_cmd2
                              })
        output2 = sudo_cmd()['LINES']
        if output1[0] == output2[0] and output1[1] == output2[1]:
            return True
        else:
            return False

    @load_moler_configuration_from_tl()
    def start_tcpdump_between_bts_and_ru(self, options, gnb_id=0, du_id=0, filename="tcpdump", timeout=120):
        """
        Starts tcpdump with given options in background, in order to catch massages between RU and BTS and save them
        in /tmp/ file with given name.
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param options:     options for tcpdump command
        :param filename:    name of file to save caught tcpdump to
        :param timeout:     timeout for tcpdump command in seconds
        :return: None
        """
        gnb = DeviceFactory.get_device(self.ssh_alias.format(gnb_id, du_id))
        container_id = self._get_container_id_gnb2ru(dev_name=gnb.name)
        gnb.change_fhnet_container_id(container_id=container_id)
        gnb.goto_state("FHNET")
        tcpdump_cmd = gnb.get_cmd(cmd_name="tcpdump", cmd_params={"options":
                                                                  "{} > /tmp/{}.txt".format(options, filename)})
        tcpdump_cmd.start(timeout=timeout)

    @load_moler_configuration_from_tl()
    def get_tcpdump_caught_massages(self, gnb_id=0, du_id=0, filename="tcpdump"):
        """
        Gets massages caught by start_tcpdump_between_bts_and_ru() function from file with given name
        :param gnb_id:      gNB id - related to Test Line configuration.
        :param du_id:       DU id(Distributed Unit) - id related to Test Line configuration - gnb.dus[]
        :param filename:    name of file to check for caught tcpdump
        :return: lines in file with given name in /tmp/
        """
        gnb = DeviceFactory.get_device(self.ssh_alias.format(gnb_id, du_id))
        container_id = self._get_container_id_gnb2ru(dev_name=gnb.name)
        gnb.change_fhnet_container_id(container_id=container_id)
        gnb.goto_state("FHNET")
        cat_cmd = gnb.get_cmd(cmd_name="cat", cmd_params={"path": "/tmp/{}.txt".format(filename)})
        return cat_cmd()['LINES']

    def get_tcpdump(self):
        if self.get_tcpdump_caught_massages():
            return True
        else:
            return False
