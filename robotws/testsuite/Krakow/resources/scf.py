from moler.device import DeviceFactory
from taf.config.scf.scf_operations import SCFOperations
from robot.libraries.BuiltIn import BuiltIn
from taf.rfrl.utilities.tl_config import load_moler_configuration_from_tl


class Scf(object):

    def __init__(self):
        self.scf = SCFOperations()
        self.tl = BuiltIn().get_variable_value('${{{}}}'.format("tl"), None)
        self.cu_instance_id = self.tl.gnbs[0].cu.instance_id
        self.du_instance_id = self.tl.gnbs[0].dus[0].instance_id

    def add_object_to_scf(self, scf_local_file_path, class_name, dist_name, version):
        """
        Add new object to scf file.

        :param scf_local_file_path: scf file path
        :param class_name: name of class
        :param dist_name: dist name
        :param version: version
        :return: path to edited scf file
        """
        new_path = scf_local_file_path[0:-4] + "new" + scf_local_file_path[-4:]
        self.scf.load_scf(scf_local_file_path)
        if not self.scf.is_in_scf(dist_name.format(self.cu_instance_id)):
            self.scf.add_object_to_scf(class_name, dist_name.format(self.cu_instance_id), version, "create")
        self.scf.save_scf(new_path)
        return new_path

    def add_ipv6_route_to_scf(self, scf_local_file_path, dist_name, route_ip, gateway_ip, route_prefix_length):
        """
        Add route to scf file.

        :param scf_local_file_path: scf file path
        :param dist_name: dist name
        :param route_ip: name of class
        :param gateway_ip: gateway ip address
        :param route_prefix_length: length of route prefix
        :return: None
        """
        self.scf.load_scf(scf_local_file_path)
        if not self.scf.is_in_scf(dist_name.format(self.cu_instance_id), "staticIpv6Routes"):
            self.scf.add_list_to_scf(dist_name.format(self.cu_instance_id), "staticIpv6Routes")
        route_config = {"destIpv6Addr": route_ip,
                        "destinationIpv6PrefixLength": route_prefix_length,
                        "gatewayIpv6Addr": gateway_ip}
        self.scf.add_item_to_list(dist_name.format(self.cu_instance_id), "staticIpv6Routes", route_config)
        self.scf.save_scf(scf_local_file_path)

    def add_ipv4_route_to_scf(self, scf_local_file_path, dist_name, route_ip, gateway_ip, route_prefix_length):
        """
        Add route to scf file.

        :param scf_local_file_path: scf file path
        :param dist_name: dist name
        :param route_ip: name of class
        :param gateway_ip: gateway ip address
        :param route_prefix_length: length of route prefix
        :return: None
        """
        self.scf.load_scf(scf_local_file_path)
        if not self.scf.is_in_scf(dist_name.format(self.cu_instance_id), "staticRoutes"):
            self.scf.add_list_to_scf(dist_name.format(self.cu_instance_id), "staticRoutes")
        route_config = {"destIpAddr": route_ip,
                        "destinationIpPrefixLength": route_prefix_length,
                        "gateway": gateway_ip}
        self.scf.add_item_to_list(dist_name.format(self.cu_instance_id), "staticRoutes", route_config)
        self.scf.save_scf(scf_local_file_path)

    def add_local_ip_addr_to_scf(self, scf_local_file_path, dist_name, local_ip_addr, local_ip_prefix_length):
        """
        Add route to scf file.

        :param scf_local_file_path: scf file path
        :param dist_name: dist name
        :param local_ip_addr: ip address
        :param local_ip_prefix_length: length of prefix
        :return: None
        """
        self.scf.load_scf(scf_local_file_path)
        if self.scf.is_in_scf(dist_name.format(self.cu_instance_id)):
            self.scf.modify_scf_element("MANUAL", dist_name=dist_name.format(self.du_instance_id),
                                        p_name="ipAddressAllocationMethod", )
            self.scf.modify_scf_element(local_ip_addr, dist_name=dist_name.format(self.du_instance_id),
                                        p_name="localIpAddr", )
            self.scf.modify_scf_element(local_ip_prefix_length, dist_name=dist_name.format(self.du_instance_id),
                                        p_name="localIpPrefixLength")
        else:
            self.scf.add_element_to_scf(dist_name.format(self.du_instance_id), "ipAddressAllocationMethod", "MANUAL")
            self.scf.add_element_to_scf(dist_name.format(self.du_instance_id), "localIpAddr", local_ip_addr)
            self.scf.add_element_to_scf(dist_name.format(self.du_instance_id), "localIpPrefixLength",
                                        local_ip_prefix_length)
        self.scf.save_scf(scf_local_file_path)

    def add_cu_ssh_key_with_passphrase(self, scf_local_file_path):
        """
        Add ssh key with passphrase on CU.

        :param scf_local_file_path: scf file path
        :return: path to edited scf file
        """
        dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.tl.gnbs[0].cu.instance_id)
        new_path = scf_local_file_path[0:-4] + "new" + scf_local_file_path[-4:]
        self.scf.load_scf(scf_local_file_path)
        if not self.scf.is_in_scf(dist_name):
            self.scf.add_object_to_scf("com.nokia.srbts.mnl:SECADM", dist_name, "MNLCU20B_2008_002", "create")
        self.scf.add_list_to_scf(dist_name, "serviceUserPublicKeys")
        key = {"keyValue": self._get_ssh_key_with_passphrase(),
               "keyDescription": "#1"}
        self.scf.add_item_to_list(dist_name, "serviceUserPublicKeys", key)
        self.scf.save_scf(new_path)
        return new_path

    def add_cu_ssh_keys(self, scf_local_file_path, add_eleventh_key=False):
        """
        Add ssh keys on CU.

        :param scf_local_file_path: scf file path
        :param add_eleventh_key: True if 11th key is to be added
        :return: path to edited scf file
        """
        dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.tl.gnbs[0].cu.instance_id)
        new_path = scf_local_file_path[0:-4] + "new" + scf_local_file_path[-4:]
        self.scf.load_scf(scf_local_file_path)
        if not self.scf.is_in_scf(dist_name):
            self.scf.add_object_to_scf("com.nokia.srbts.mnl:SECADM", dist_name, "MNLCU20B_2008_002", "create")
        self.scf.add_list_to_scf(dist_name, "serviceUserPublicKeys")
        keys = self._get_ssh_keys(add_eleventh_key)
        for i in range(len(keys)):
            key = {"keyValue": keys[i],
                   "keyDescription": "#{}".format(i)}
            self.scf.add_item_to_list(dist_name, "serviceUserPublicKeys", key)
        self.scf.save_scf(new_path)
        return new_path

    @staticmethod
    @load_moler_configuration_from_tl()
    def _get_ssh_key_with_passphrase(bts_id=0):
        """
        Get value of ssh key with passphrase.

        :param bts_id: ID of BTS
        :return: value of key with passphrase
        """
        moler_device = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="UNIX_LOCAL")
        cmd_cat = moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/home/ute/serviceuser_key_passphrase.pub"})
        return cmd_cat()["LINES"][0]

    @staticmethod
    @load_moler_configuration_from_tl()
    def _get_ssh_keys(eleventh_key=True, bts_id=0):
        """
        Get value of ssh keys.

        :param eleventh_key: True if 11th key is to be added to list
        :param bts_id: ID of BTS
        :return: list of keys
        """
        moler_device = DeviceFactory.get_device("GNB{}_CU".format(bts_id), initial_state="UNIX_LOCAL")
        res = list()
        cmd_cat = moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/home/ute/serviceuser_key.pub"})
        res.append(cmd_cat()["LINES"][0])
        for i in range(1, 10):
            cmd_cat = moler_device.get_cmd(cmd_name="cat",
                                           cmd_params={"path": "/home/ute/serviceuser_key_0{}.pub".format(i)})
            res.append(cmd_cat()["LINES"][0])
        if eleventh_key:
            cmd_cat = moler_device.get_cmd(cmd_name="cat",
                                           cmd_params={"path": "/home/ute/serviceuser_key_10.pub"})
            res.append(cmd_cat()["LINES"][0])
        return res

    @load_moler_configuration_from_tl()
    def change_one_ssh_key(self, scf_local_file_path):
        """
        Change value of ssh key.

        :param scf_local_file_path: scf file path
        :return: changed key
        """
        dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.tl.gnbs[0].cu.instance_id)
        self.scf.load_scf(scf_local_file_path)
        key = self._get_ssh_key_with_passphrase()
        self.scf.modify_scf_element("#11", dist_name=dist_name, list_name="serviceUserPublicKeys",
                                    p_name="keyDescription", index=0)
        self.scf.modify_scf_element(key, dist_name=dist_name, list_name="serviceUserPublicKeys",
                                    p_name="keyValue", index=0)
        self.scf.save_scf(scf_local_file_path)
        return key

    @load_moler_configuration_from_tl()
    def change_key_description_to_incorrect(self, scf_local_file_path):
        """
        Change description of ssh key to incorrect.

        :param scf_local_file_path: scf file path
        :return: None
        """
        dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.tl.gnbs[0].cu.instance_id)
        self.scf.load_scf(scf_local_file_path)
        self.scf.modify_scf_element("11", dist_name=dist_name, list_name="serviceUserPublicKeys",
                                    p_name="keyDescription", index=0)
        self.scf.save_scf(scf_local_file_path)

    @load_moler_configuration_from_tl()
    def change_key_value_to_incorrect(self, scf_local_file_path):
        """
        Change value of ssh key to incorrect.

        :param scf_local_file_path: scf file path
        :return: None
        """
        dist_name = "MRBTS-{}/MNL-1/MNLENT-1/SECADM-1".format(self.tl.gnbs[0].cu.instance_id)
        self.scf.load_scf(scf_local_file_path)
        self.scf.modify_scf_element("key", dist_name=dist_name, list_name="serviceUserPublicKeys",
                                    p_name="keyValue", index=0)
        self.scf.save_scf(scf_local_file_path)

    @load_moler_configuration_from_tl()
    def change_icmpResponseEnabled_value(self, scf_file_path, dist_name, value):
        """
        :param scf_file_path: path to scf file
        :param dist_name: path in WebEM to the particular parameter  e.g. MRBTS-392/TNLSVC-1/TNL-1/IPNO-1
        :param value: icmpResponseEnabled value, true or false
        :return: None
        """
        self.scf.load_scf(scf_file_path)
        self.scf.modify_scf_element(value, dist_name=dist_name, p_name="icmpResponseEnabled")
        self.scf.save_scf(scf_file_path)

    @load_moler_configuration_from_tl()
    def modify_nrsctp_object(self, scf_file_path):
        """
        :param scf_file_path: path to scf file
        :param dist_name: path in WebEM to the particular parameter  e.g. MRBTS-392/TNLSVC-1/TNL-1/IPNO-1
        :param value: icmpResponseEnabled value, true or false
        :return: None
        """
        params = {"sctpChunkBundlingEnabled": "false",
                  "sctpHeartbeatInterval": "0",
                  "sctpMaxBurst": "0",
                  "sctpMaxPayloadSize": "0",
                  "sctpMaxTimeSctpSetup": "0",
                  "sctpPathMaxRetrans": "0",
                  "sctpProfileId": "0",
                  "sctpRandomTimeInitSeqRetry": "0",
                  "sctpRtoInit": "0",
                  "sctpRtoMax": "0",
                  "sctpRtoMin": "0",
                  "sctpSackDelay": "0",
                  "sctpSackFreq": "0",
                  "sctpValidCookieLife": "0",
                  "sctpWaitTimeInitSeqRetry": "0"}
        dist_name = "MRBTS-{}/NRBTS-1/NRSCTP-1".format(self.tl.gnbs[0].cu.instance_id)
        new_path = scf_file_path[0:-4] + "new" + scf_file_path[-4:]
        self.scf.load_scf(scf_file_path)
        self.scf.remove_list_from_scf(dist_name=dist_name, list_name="sctpProfile")
        self.scf.add_list_to_scf(dist_name=dist_name, list_name="sctpProfile")
        self.scf.add_item_to_list(dist_name=dist_name, list_name="sctpProfile", elements=params)
        self.scf.save_scf(new_path)
        return new_path

    def get_number_of_structures(self, scf_file_path, dist_name):
        """
        Get number of structures in DistName.

        :param scf_file_path: path to scf file
        :param dist_name: path in WebEM to the particular parameter  e.g. MRBTS-392/TNLSVC-1/TNL-1/IPNO-1
        :return: None
        """
        dist_name = dist_name.format(self.tl.gnbs[0].cu.instance_id)
        with open(scf_file_path, "r") as scf:
            data = scf.read().replace('\n', '')
        value = data.partition('distName="{}"'.format(dist_name))[2].partition('</managedObject>')[0]
        return value.count("<item>")
