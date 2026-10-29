"""
        Keywords Purpose:
            Keywords to drive switches

        AUTHOR (I&V-2):
            Ismael Moliage          ismael.moliage@nokia.com
            David Jollivet          david.jollivet@nokia.com
"""

from SSHLibrary import SSHLibrary
from abc import abstractmethod
import time
from robot.api import logger
import datetime


class Switch(object):
    _switchdict = None
    _PORT = 22
    _ssh = None

    def __init__(self, switchdict, debug=False, console=False):
        if type(debug) is bool:
            self._debug = debug
        else:
            if debug == 'True':
                self._debug = True
            else:
                self._debug = False
        if type(console) is bool:
            self._console = console
        else:
            if console == 'True':
                self._console = True
            else:
                self._console = False
        self._switchdict = switchdict

    def switch_debug(self, msg):
        if self._debug:
            logger.info(msg, html=True, also_console=self._console)

    def get_type(self):
        return self._switchdict.get('TorSwitch_type')

    def get_ipaddress(self):
        return self._switchdict.get('TorSwitch_addr')

    def get_login(self):
        return self._switchdict.get('TorSwitch_login')

    def get_passwd(self):
        return self._switchdict.get('TorSwitch_passwd')

    def get_alias(self):
        return self._switchdict.get('TorSwitch_alias')

    def ssh_connect_to_switch(self):
        """
        open a ssh connection to switch
        :return: NA, raise an ConnexionException
        """
        if self._ssh is None:
            self._ssh = SSHLibrary()
        connection = self._ssh.open_connection(host=self.get_ipaddress(), alias=self.get_alias(), port=self._PORT)
        self._ssh.switch_connection(connection)
        self._ssh.login(username=self.get_login(), password=self.get_passwd())

    def ssh_disconnect_to_switch(self):
        """
        disconnect to switch
        :return: NA, raise an ConnexionException
        """
        if self._ssh is None:
            self._ssh = SSHLibrary()
        self._ssh.close_connection()

    def run_cmd(self, cmd):
        if self._ssh is None:
            self._ssh = SSHLibrary()
        self.switch_debug("Running: {}".format(cmd))
        self._ssh.write(cmd)
        time.sleep(1)

    @abstractmethod
    def shutdown(self):
        """shutdown interface.
        """
        pass

    @abstractmethod
    def noshutdown(self):
        """enable interface.
        """
        pass

    @abstractmethod
    def ptp_shutdown(self):
        """shutdown interface.
        """
        pass

    @abstractmethod
    def ptp_noshutdown(self):
        """enable interface.
        """
        pass

    @abstractmethod
    def synce_set_ssm(self, ssm):
        """shutdown interface.
        """
        pass

    @abstractmethod
    def configure_switch_mirroring(self, tl, traffic_type):
        """ Configure mirroring on switch sandbox """
        pass

    @abstractmethod
    def configure_filter(self, ip_version):
        """ Configure Filtering on switch interface """
        pass

    @abstractmethod
    def activate_filter(self, ip_version, filter_type):
        """ Activate Filtering on switch interface """
        pass

    @abstractmethod
    def deactivate_filter(self, filter_type):
        """ Deactivate Filtering on switch interface """
        pass


class SwitchQuanta(Switch):
    def __init__(self, switchdict, debug=False, console=False):
        super(SwitchQuanta, self).__init__(switchdict, debug, console)

    def get_interface(self):
        return self._switchdict.get('TorSwitch_Fronthaul_interface')

    def shutdown(self):
        self.switch_debug("interface: %s" % (self.get_interface()))
        if self._ssh is None:
            self._ssh = SSHLibrary()
        self._ssh.write('configure')
        time.sleep(1)
        self._ssh.write('interface ' + self.get_interface())
        time.sleep(1)
        self._ssh.write('shutdown')
        time.sleep(1)
        self._ssh.write('exit')
        time.sleep(1)
        self._ssh.write('logout')

    def noshutdown(self):
        self.switch_debug("interface: %s" % (self.get_interface()))
        if self._ssh is None:
            self._ssh = SSHLibrary()
        self._ssh.write('configure')
        time.sleep(1)
        self._ssh.write('interface ' + self.get_interface())
        time.sleep(1)
        self._ssh.write('no shutdown')
        time.sleep(1)
        self._ssh.write('exit')
        time.sleep(1)
        self._ssh.write('logout')


class SwitchTPS(Switch):
    def get_port(self):
        return self._switchdict.get('TorSwitch_port')

    def ssh_connect_to_switch(self):
        """
        open a ssh connection to switch
        :return: NA, raise an ConnexionException
        """
        if self._ssh is None:
            self._ssh = SSHLibrary()
        connection = self._ssh.open_connection(host=self.get_ipaddress(), alias=self.get_alias(), port=self._PORT)
        self._ssh.switch_connection(connection)
        self._ssh.login(username='cli', password=None)
        time.sleep(1)
        self._ssh.write(self.get_login())
        time.sleep(1)
        # self._ssh.write('Admin@1830')
        self._ssh.write('Admin@TPS24')
        time.sleep(1)
        self._ssh.write('Y')
        time.sleep(1)

    def ptp_shutdown(self):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('conf sync 1 ptp clock1 ' + self.get_port() + ' adminState down')
        self.switch_debug("ptp port {} is shutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('logout')

    def ptp_noshutdown(self):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('conf sync 1 ptp clock1 ' + self.get_port() + ' adminState up')
        self.switch_debug("ptp port {} is shutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('logout')

    def synce_set_ssm(self, ssm):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('conf interface ' + self.get_port() + ' tenGige ssmtrans ' + format(ssm))
        self.switch_debug("ptp set ssm {} on port {} at : {}".format(ssm, self.get_port(), datetime.datetime.now()))
        self.run_cmd('logout')


class Switch7250(Switch):
    def get_port(self):
        return self._switchdict.get('TorSwitch_port')

    def ptp_shutdown(self):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('configure system ptp port ' + self.get_port())
        self.run_cmd('shutdown')
        self.switch_debug("ptp port {} is shutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('exit')
        self.run_cmd('logout')

    def ptp_noshutdown(self):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('configure system ptp port ' + self.get_port())
        self.run_cmd('no shutdown')
        self.switch_debug("ptp port {} is up at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('exit')
        self.run_cmd('logout')


class Switch7850(Switch):
    def get_vpls(self):
        return self._switchdict.get('TorSwitch_vpls')

    def get_sap(self):
        return self._switchdict.get('TorSwitch_sap')

    def get_port(self):
        return self._switchdict.get('TorSwitch_port')

    def shutdown(self):
        self.switch_debug("vpls: %s" % (self.get_vpls()))
        self.switch_debug("sap: %s" % (self.get_sap()))
        self.run_cmd('configure service vpls ' + self.get_vpls())
        self.run_cmd('sap ' + self.get_sap())
        self.run_cmd('shutdown')
        self.run_cmd('exit')
        self.run_cmd('logout')

    def noshutdown(self):
        self.switch_debug("vpls: %s" % (self.get_vpls()))
        self.switch_debug("sap: %s" % (self.get_sap()))
        self.run_cmd('configure service vpls ' + self.get_vpls())
        self.run_cmd('sap ' + self.get_sap())
        self.run_cmd('no shutdown')
        self.run_cmd('exit')
        self.run_cmd('logout')

    def portShutdown(self):
        self.switch_debug("port: %s" % (self.get_port()))
        self.run_cmd('configure port ' + self.get_port())
        self.run_cmd('shutdown')
        self.switch_debug("port {} is shutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('exit')
        self.run_cmd('logout')

    def ptp_shutdown(self):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('configure system ptp clock csm port ' + self.get_port())
        self.run_cmd('shutdown')
        self.switch_debug("ptp port {} is shutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('exit')
        self.run_cmd('logout')

    def ptp_noshutdown(self):
        self.switch_debug("ptp port: %s" % (self.get_port()))
        self.run_cmd('configure system ptp clock csm port ' + self.get_port())
        self.run_cmd('no shutdown')
        self.switch_debug("ptp port {} is noshutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('exit')
        self.run_cmd('logout')

    def portNoshutdown(self):
        self.switch_debug("port: %s" % (self.get_port()))
        self.run_cmd('configure port ' + self.get_port())
        self.run_cmd('no shutdown')
        self.switch_debug("port {} is noshutdown at : {}".format(self.get_port(), datetime.datetime.now()))
        self.run_cmd('exit')
        self.run_cmd('logout')

    def get_mirror_source(self, traffic_type):
        return self._switchdict['TorSwitch_mirror_src'][traffic_type]

    def get_mirror_dest(self):
        return self._switchdict['TorSwitch_mirror_dest']

    def configure_switch_mirroring(self, tl, traffic_type):
        self.switch_debug("configuring mirroring CV{}".format(tl))
        mirror_source = self.get_mirror_source(traffic_type)
        mirror_dest = self.get_mirror_dest()

        # Remove existing mirroring conf if any
        self.run_cmd('/debug no mirror-source {}'.format(tl))
        self.run_cmd('/configure mirror mirror-dest {} shutdown'.format(tl))
        self.run_cmd('/configure mirror no mirror-dest {}'.format(tl))

        # Configure mirror destination
        self.run_cmd('/configure mirror mirror-dest {} create'.format(tl))
        self.run_cmd('/configure mirror mirror-dest {} sap {} create'.format(tl, mirror_dest))
        self.run_cmd('/configure mirror mirror-dest {} no shutdown'.format(tl))

        # Configure mirror source
        self.run_cmd('/debug mirror-source {} port {} egress ingress'.format(tl, mirror_source))


class Switch7750(Switch7850):
    # Until the day God sees to it that both 7750 are on the same SROS version!
    _filter_tag = dict()

    def configure_switch_mirroring(self, tl, traffic_type):
        self.switch_debug("configuring mirroring CV{}".format(tl))
        traffic = {
            'OAM': 'OAM',
            'S1-C': 'CPIF',
            'X2-C': 'CPIF',
            'S1-U': 'UEUP',
            'X2-U': 'UEUP'
        }
        mirror_source = self.get_mirror_source(traffic[traffic_type])

        # Remove existing mirroring conf if any
        self.run_cmd('/debug mirror-source 2 no port {}'.format(mirror_source))

        # Configure mirror source
        self.run_cmd('/debug mirror-source 2 port {} egress ingress'.format(mirror_source))

    def get_filter_data(self):
        return self._switchdict['TorSwitch_filter']

    def configure_filter(self, ip_version):
        # Configuring the 7750 ipfilter
        self._filter_tag = {
            'egress': 1,
            'ingress': 2
        }
        match_type = {
            'ip': 'protocol',
            'ipv6': 'next-header'
        }
        netmask = {
            'ip': 32,
            'ipv6': 128
        }
        label = self.get_alias()
        filter_data = self.get_filter_data()
        self.switch_debug(
            "configuring {}-filter for {} on {}".format(ip_version, filter_data['proto'], filter_data['ip']))

        # To Do on 7750 - Egress
        egress_label = '{}{}'.format(label, self._filter_tag['egress'])
        self.run_cmd('/configure filter no {}-filter {}'.format(ip_version, egress_label))
        self.run_cmd('/configure filter {}-filter {} create'.format(ip_version, egress_label))
        self.run_cmd('/configure filter {}-filter {} default-action forward'.format(ip_version, egress_label))
        self.run_cmd('/configure filter {}-filter {} entry 1 create'.format(ip_version, egress_label))
        self.run_cmd('/configure filter {}-filter {} entry 1 match {} {}'.format(ip_version, egress_label,
                                                                                 match_type[ip_version],
                                                                                 filter_data['proto']))
        self.run_cmd('/configure filter {}-filter {} entry 1 match {} {} dst-ip {}/{}'.format(ip_version,
                                                                                              egress_label,
                                                                                              match_type[ip_version],
                                                                                              filter_data['proto'],
                                                                                              filter_data['ip'],
                                                                                              netmask[ip_version]))
        self.run_cmd('/configure filter {}-filter {} entry 1 action drop'.format(ip_version, egress_label))

        # To Do on 7750 - Ingress
        ingress_label = '{}{}'.format(label, self._filter_tag['ingress'])
        self.run_cmd('/configure filter no {}-filter {}'.format(ip_version, ingress_label))
        self.run_cmd('/configure filter {}-filter {} create'.format(ip_version, ingress_label))
        self.run_cmd('/configure filter {}-filter {} default-action forward'.format(ip_version, ingress_label))
        self.run_cmd('/configure filter {}-filter {} entry 1 create'.format(ip_version, ingress_label))
        self.run_cmd('/configure filter {}-filter {} entry 1 match {} {}'.format(ip_version, ingress_label,
                                                                                 match_type[ip_version],
                                                                                 filter_data['proto']))
        self.run_cmd('/configure filter {}-filter {} entry 1 match {} {} src-ip {}/{}'.format(ip_version,
                                                                                              ingress_label,
                                                                                              match_type[ip_version],
                                                                                              filter_data['proto'],
                                                                                              filter_data['ip'],
                                                                                              netmask[ip_version]))
        self.run_cmd('/configure filter {}-filter {} entry 1 action drop'.format(ip_version, ingress_label))

    def activate_filter(self, ip_version, flow_type):
        # Activation filter on vpls
        label = "{}{}".format(self.get_alias(), self._filter_tag[flow_type])
        vpls = self.get_vpls()
        sap = self.get_sap()
        self.switch_debug("Activating filter {} on vpls {} sap {}".format(label, vpls, sap))

        # To Do On 7750
        self.run_cmd(
            '/configure service vpls {} sap {} {} filter {} {}'.format(vpls, sap, flow_type, ip_version, label))

    def deactivate_filter(self, flow_type):
        # Deactivation filter on vpls
        label = "{}{}".format(self.get_alias(), self._filter_tag[flow_type])
        vpls = self.get_vpls()
        sap = self.get_sap()
        self.switch_debug("Deactivating filter {} on vpls {} sap {}".format(label, vpls, sap))

        # To Do On 7750
        self.run_cmd('/configure service vpls {} sap {} {} no filter'.format(vpls, sap, flow_type))


class SwitchWbx(Switch):
    def __init__(self, switchdict, debug=False, console=False):
        super(SwitchWbx, self).__init__(switchdict, debug, console)

    def get_vpls(self):
        return self._switchdict.get('TorSwitch_vpls')

    def get_sap(self):
        return self._switchdict.get('TorSwitch_sap')

    def get_port(self, porttag):
        if str(porttag) == 'master':
            return self._switchdict.get('TorSwitch_frontaul_master_port')
        if str(porttag) == 'backup':
            return self._switchdict.get('TorSwitch_frontaul_backup_port')

    def portShutdown(self, porttag):
        if self._ssh is None:
            self._ssh = SSHLibrary()
        self._ssh.write('configure port ' + self.get_port(porttag))
        time.sleep(1)
        self._ssh.write('shutdown')
        self.switch_debug("port {} is shutdown at : {}".format(self.get_port(porttag), datetime.datetime.now()))
        time.sleep(1)
        self._ssh.write('exit')
        time.sleep(1)
        self._ssh.write('logout')

    def portNoshutdown(self, porttag):
        if self._ssh is None:
            self._ssh = SSHLibrary()
        self._ssh.write('configure port ' + self.get_port(porttag))
        time.sleep(1)
        self._ssh.write('no shutdown')
        self.switch_debug("port {} is noshutdown at : {}".format(self.get_port(porttag), datetime.datetime.now()))
        time.sleep(1)
        self._ssh.write('exit')
        time.sleep(1)
        self._ssh.write('logout')

    def get_mirror_source(self, traffic_type):
        return self._switchdict['TorSwitch_mirror_src'][traffic_type]

    def get_mirror_dest(self):
        return self._switchdict['TorSwitch_mirror_dest']

    def configure_switch_mirroring(self, tl, traffic_type):
        self.switch_debug("configuring mirroring CV{}".format(tl))
        mirror_source = self.get_mirror_source(traffic_type)
        mirror_dest = self.get_mirror_dest()

        # Remove existing mirroring conf if any
        self.run_cmd('/debug no mirror-source {}'.format(tl))
        self.run_cmd('/configure mirror mirror-dest {} shutdown'.format(tl))
        self.run_cmd('/configure mirror no mirror-dest {}'.format(tl))

        # Configure mirror destination
        self.run_cmd('/configure mirror mirror-dest {} create'.format(tl))
        self.run_cmd('/configure mirror mirror-dest {} sap {} create'.format(tl, mirror_dest))
        self.run_cmd('/configure mirror mirror-dest {} no shutdown'.format(tl))

        # Configure mirror source
        self.run_cmd('/debug mirror-source {} port {} egress ingress'.format(tl, mirror_source))
