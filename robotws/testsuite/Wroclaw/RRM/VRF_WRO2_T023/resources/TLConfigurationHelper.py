"""
:copyright: Nokia Networks
:author: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:maintainer: 'Monika Ceglarek'
:contact: 'monika.ceglarek@nokia.com'
:version: 0.1
"""
from robot.api import logger


class TLConfigurationHelper:

    def __init__(self):
        pass

    def get_all_bts_data(self, tl):
        """
        Creates dictionary with SMOD serial numbers as keys and dictionaries
        with BTS data as values. It also returns dictionary with data
        for main BTS

        :param tl: TL object from __init__.py file with TL configuration.
        :return Dictionary with SMOD serial numbers as keys and dictionaries
         with BTS data as values and dictionary with data for main BTS.
        """

        all_bts_data = {}
        if tl.enbs and tl.gnbs:
            bts_list = tl.enbs + tl.gnbs
        elif tl.enbs and not tl.gnbs:
            bts_list = tl.enbs
        else:
            bts_list = tl.gnbs

        for bts in bts_list:
            bts_data = self.get_bts_data(bts, tl.test_pcs, tl.test_pc)
            logger.debug('{}\n===================================================================\n'.format(bts_data))
            all_bts_data[bts_data['serial_number']] = bts_data
            if bts_data['is_main_bts']:
                main_bts = bts_data
        return all_bts_data, main_bts

    def get_bts_data(self, bts, test_pcs, test_pc):
        """
        Created dictionary with BTS data. Data included (keys in brackets):
        serial number of SMOD ("serial_number"), boolean value determining
        if BTS is gNb or not("is_gnb"), boolean value determining if BTS
        is secondary SMOD or not ("is_secondary"), IP of VM connected to BTS
        ("vm_ip"), boolean value determining if BTS is connected to main VM
        defined in __init__.py ("is_main_bts"), M-plane IP ("mplane_ip").

        :param bts: BTS object (gNb or eNB).
        :param test_pcs: List of TestPC objects.
        :param test_pc: TestPC object for main VM from which tests should be run.
        :return Dictionary with BTS data.
        """

        logger.debug('get_bts_data')
        serial_number = self.get_serial_number(bts)
        is_gnb = self.is_gnb_object(bts)
        is_secondary = self.is_secondary_smod(bts)
        vm_ip = self.get_vm_ip_by_serial_number(test_pcs, serial_number)
        is_main_bts = self.is_main_test_pc(test_pc, serial_number)
        mplane_ip = self.get_mplane_ip(bts)
        return {"serial_number": serial_number, "vm_ip": vm_ip, "mplane_ip": mplane_ip,
                "is_gnb": is_gnb, "is_secondary": is_secondary, "is_main_bts": is_main_bts}

    def get_serial_number(self, bts):
        """
        Returns serial number of SMOD for BTS object passed by user.

        :param bts: BTS object (gNb or eNB).
        :return Serial number of SMOD for BTS object passed by user.
        """

        logger.debug('get_serial_number')
        if self.is_gnb_object(bts):
            return bts.dus[0].airscale.common_units[0].serial_number
        else:
            return bts.system_module.common_units[0].serial_number

    def get_mplane_ip(self, bts):
        """
        Gets M-plane IP for BTS object passed by user.

        :param bts: BTS object (gNb or eNB).
        :return M-plane IP for BTS object passed by user.
        """

        logger.debug('get_mplane_ip')
        if not self.is_secondary_smod(bts) and self.is_gnb_object(bts):
            logger.debug(bts.cu.backhaul_site_oam_ip.v4)
            return bts.cu.backhaul_site_oam_ip.v4
        elif not self.is_secondary_smod(bts) and not self.is_gnb_object(bts):
            logger.debug(bts.oam_ip.v4)
            return bts.oam_ip.v4
        else:
            return None

    def get_ssh_credentials(self, bts):
        """
        Gets ssh credentials for BTS (addres, username, password)
        from __init__.py file.

        :param bts: BTS object (gNb or eNB).
        :return ssh credentials for BTS (addres, username, password).
        """

        logger.debug('get_ssh_credentials')
        if self.is_gnb_object(bts):
            ssh_data = bts.cu.oam_ssh_connection_details
            logger.debug(ssh_data)
        else:
            ssh_data = bts.system_module.common_units[0].lmp_connection
            logger.debug(ssh_data)
        return ssh_data.addr, ssh_data.username, ssh_data.password

    def get_vm_credentials(self, test_pcs, bts):
        """
        Gets ssh credentials for VM (addres, username)
        from __init__.py file.

        :param test_pcs: List of TestPC objects.
        :param bts: BTS object (gNb or eNB).
        :return ssh credentials for BTS (addres, username).
        """

        logger.debug('get_vm_credentials')
        serial_number = self.get_serial_number(bts)
        for test_pc in test_pcs:
            connection = [connection_type for connection_type in test_pc.connections
                          if 'taf.config.testline.testpc.Connection' in str(type(connection_type))]
            if connection[0].device.serial_number == serial_number:
                ssh_data = test_pc.default_ssh_connection_details
                logger.debug(ssh_data)
                return ssh_data.addr, ssh_data.username

    def get_bts_object_with_serial_number(self, tl, serial_number):
        """
        Gets BTS object with SMOD that has serial number passed by user.

        :param tl: TL object from __init__.py file with TL configuration.
        :param serial_number: Serial number of SMOD.
        :return BTS object with SMOD that has serial number passed by user.
        """

        logger.debug('get_bts_object_with_serial_number')
        if tl.enbs and tl.gnbs:
            bts_list = tl.enbs + tl.gnbs
        elif tl.enbs and not tl.gnbs:
            bts_list = tl.enbs
        else:
            bts_list = tl.gnbs
        for bts in bts_list:
            if serial_number == self.get_serial_number(bts):
                return bts
        logger.debug('For loop ended without finding match.')

    @staticmethod
    def is_gnb_object(bts):
        """
        Checks if BTS object passed by user is gNb (True) or not (False).
        The check is done by searching if object's attributes list contains 'cu'.

        :param bts: BTS object (gNb or eNB).
        :return True if BTS object is gNb and False otherwise.
        """

        logger.debug('is_gnb_object')
        logger.debug(dir(bts))
        return True if 'cu' in dir(bts) else False

    @staticmethod
    def is_secondary_smod(bts):
        """
        Checks if BTS object passed by user is secondary SMOD (True) or not (False).

        :param bts: BTS object (gNb or eNB).
        :return True if BTS object is secondary SMOD and False otherwise.
        """

        logger.debug('is_secondary_smod')
        return True if bts.master is not None else False

    @staticmethod
    def get_vm_ip_by_serial_number(test_pcs, serial_number):
        """
        Gets IP of VM connected to SMOD with serial number passed by user.

        :param test_pcs: List of TestPC objects.
        :param serial_number: Serial number of SMOD.
        :return IP of VM connected to SMOD with serial number passed by user.
        """

        logger.debug('get_vm_ip_by_serial_number')
        for test_pc in test_pcs:
            connection = [connection_type for connection_type in test_pc.connections
                          if 'taf.config.testline.testpc.Connection' in str(type(connection_type))]
            if connection[0].device.serial_number == serial_number:
                logger.debug(test_pc.default_ssh_connection_details)
                return test_pc.default_ssh_connection_details.addr

    @staticmethod
    def is_main_test_pc(test_pc, serial_number):
        """
        Returns True if TestPC object is connected to SMOD
        with serial number passed by user and False otherwise.

        :param test_pc: TestPC object for main VM from which tests should be run.
        :param serial_number: Serial number of SMOD.
        :return True if TestPC object is connected to SMOD
         with serial number passed by user and False otherwise.
        """

        logger.debug('is_main_test_pc')
        connection = [connection_type for connection_type in test_pc.connections
                      if 'taf.config.testline.testpc.Connection' in str(type(connection_type))]
        return True if connection[0].device.serial_number == serial_number else False
