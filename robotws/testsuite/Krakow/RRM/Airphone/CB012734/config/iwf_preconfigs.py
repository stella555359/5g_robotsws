"""
:copyright: Nokia Networks
:authors:
:maintainers:
    Arkadiusz Sobejko, arkadiusz.sobejko@nokia.com
"""
import logging
import os
import re
import subprocess
import time
import argparse

logger = logging.getLogger()


class ConfigureIWFException(Exception):
    pass


class ConfigureIWF:
    def __init__(self):
        self.nr_hugepages_size = "1024"
        self.device_interface = "eth5"
        self.config_file_path = "/usr/local/etc/"
        self.iwf_config_file = "iwf_split_single.conf"
        self.sysctl_file = "sysctl.conf"
        self.enable_dss = "False"
        self.mac_add = None
        self.device_id = None
        self.process_root = None
        self.hgpages_path = "/sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages"

    def open_command(self, cmd):
        try:
            if self.process_root is None:
                self.process_root = subprocess.Popen(["sudo", "-i"], stdin=subprocess.PIPE)
            logger.info(cmd)
            self.process_root.communicate("{}\n".format(cmd).encode("utf-8"))
        except ConfigureIWFException as e:
            logger.exception(f"open command failed with - {e}")

    def run_command(self, command):
        try:
            if isinstance(command, str):
                command = [command]
            output = subprocess.check_output(
                command, shell=True, stdin=subprocess.PIPE, stderr=subprocess.STDOUT
            )
            logger.info(command)
            logger.info(output)
            return output.decode("utf-8").strip()
        except ConfigureIWFException as e:
            logger.info(f"run command failed with - {e}")

    def fetch_mac_add(self):
        output = self.run_command("ip link show " + self.device_interface)
        if "does not exist" in output:
            raise ConfigureIWFException(
                f"{self.device_interface} interface is not configured"
            )
        match = re.search(r"link/ether\s([\d\w\:]+)", output)
        if match:
            return match.group(1)
        else:
            logger.info("mac address not found")
            raise ConfigureIWFException(
                f"{self.device_interface} interface mac address is not found"
            )

    def config_lib(self):
        try:
            self.run_command("sudo apt update")
        except subprocess.CalledProcessError as cpe:
            if cpe.returncode == 100:
                logging.info("Updates for repository will not be applied")
        self.run_command("sudo apt install igb-uio")
        if not os.path.islink("/usr/lib/x86_64-linux-gnu/libpcap.so.1"):
            self.run_command("sudo bash -c \"cd /usr/lib/x86_64-linux-gnu/; ln -s libpcap.so.1.10.3 libpcap.so.1\"")

    def config_hugepages(self, nr_hugepages_size):
        self.nr_hugepages_size = str(nr_hugepages_size)
        self.run_command("sudo bash -c \"rm -rf /dev/hugepages/rtemap*\"")
        if self.nr_hugepages_size not in self.run_command("cat " + self.hgpages_path):
            self.run_command(
                "sudo bash -c \"echo  " + self.nr_hugepages_size + " > " + self.hgpages_path + "\""
            )

    def reset_hugepages(self):
        self.run_command("sudo bash -c \"rm -rf /dev/hugepages/rtemap*\"")
        self.run_command("sudo bash -c \"echo 0 > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages\"")
        output = self.run_command("cat /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages")
        if "0" not in output:
            raise ConfigureIWFException("Hugepage file not teardown properly")

    def configure_device_path(self):
        if self.speed == '25000':
            self.run_command("sudo modprobe igb_uio")
        else:
            self.run_command("sudo modprobe uio_pci_generic")
        time.sleep(5)
        output = self.run_command("ls -ltr /sys/class/net").split("\n")
        regex = ".*pci[\\d\\:]+\\/([\\w\\d\\:\\.]+).*"
        for entries in output:
            m = re.search(
                self.device_interface + regex + self.device_interface, entries
            )
            if m:
                self.device_id = m.group(1)
        logging.info(self.device_id)
        if self.device_id is None:
            raise ConfigureIWFException("Device id is not defined")
        if self.device_interface in self.run_command("ip link show"):
            if self.speed == '25000':
                self.open_command('echo "8086 158b" > /sys/bus/pci/drivers/igb_uio/new_id')
            else:
                self.open_command('echo "8086 10fb" > /sys/bus/pci/drivers/uio_pci_generic/new_id')
            self.run_command(
                "sudo bash -c \"echo "
                + self.device_id
                + " > /sys/bus/pci/devices/"
                + self.device_id
                + "/driver/unbind\""
            )
            time.sleep(5)
            if self.speed == '25000':
                self.run_command(
                    "sudo bash -c \"echo "
                    + self.device_id
                    + " > /sys/bus/pci/drivers/igb_uio/bind\""
                )
            else:
                self.run_command(
                    "sudo bash -c \"echo "
                    + self.device_id
                    + " > /sys/bus/pci/drivers/uio_pci_generic/bind\""
                )

    def unbind_nic_card(self):
        try:
            self.run_command('sudo echo "8086 158b" > /sys/bus/pci/drivers/i40e/new_id')
        except subprocess.CalledProcessError as cpe:
            if cpe.returncode == 2:
                logging.info("new_id already created go to unbind")
        try:
            self.run_command(
                "sudo bash -c \"echo " + self.device_id + " > /sys/bus/pci/devices/"
                + self.device_id + "/driver/unbind\"")
        except TypeError:
            self.run_command(
                "sudo bash -c \"echo 0000:00:0c.0 > /sys/bus/pci/devices/0000:00:0c.0/driver/unbind\"")
        try:
            self.run_command("sudo bash -c \"echo " + self.device_id + " > /sys/bus/pci/drivers/i40e/bind\"")
        except TypeError:
            self.run_command("sudo bash -c \"echo 0000:00:0c.0 > /sys/bus/pci/drivers/i40e/bind\"")
        time.sleep(2)
        try:
            self.run_command("sudo ip link set dev ens12 down")
            self.run_command("sudo ip link set dev ens12 name eth5")
        except subprocess.CalledProcessError as error:
            logger.info("Other altname for interface configured need work with altname ens13")
            self.run_command("sudo ip link set dev ens13 down")
            self.run_command("sudo ip link set dev ens13 name eth5")
        self.run_command("sudo ip link set dev eth5 up")

    def create_iwf_file(self):
        string = """ports =
    (
    {
        name = "ens3v";
        mac = "d8:c4:97:d2:2e:1a";
        inet =
        (
            { address = "10.0.2.100"; netmask = "255.255.255.0"; },
            { address = "10.0.2.101"; netmask = "255.255.255.0"; },
            { address = "10.0.2.102"; netmask = "255.255.255.0"; },
            { address = "10.0.2.103"; netmask = "255.255.255.0"; }
        );
        inet6 =
        (
            {
                address = "fe80::dac4:97ff:fed2:2e1a";
                prefixlen = 64;
            }
        );
    }
);\n"""

        if self.enable_dss == 'true':
            dss_info = """iwfclients =
    (
        {
            UPF = "1";
            UEC = "1";
            ENB = "2,4";
            MME = "1";
            PGW = "1";
            SGW = "1";
        }
    );\n"""
            string = string+dss_info

        if self.mac_add is not None:
            new_string = re.sub(
                "mac\\s*\\=.*\\;", 'mac = "' + self.mac_add + '";', string
            )
            try:
                with open("/tmp/" + self.iwf_config_file, "w") as file1:
                    file1.write(new_string)
                self.run_command(
                    "sudo cp /tmp/"
                    + self.iwf_config_file
                    + " "
                    + self.config_file_path
                    + "."
                )
            except Exception:
                raise (f"unable to write to {self.iwf_config_file}")
        else:
            raise ("mac address of the devices is not found")

    def update_sysctl_file(self):
        if "net.ipv4.conf.lo.rp_filter" not in self.run_command("cat /etc/sysctl.conf"):
            sysctl_info = [
                "net.ipv4.conf.all.arp_ignore = 1",
                "net.ipv4.conf.default.arp_ignore = 1",
                "net.ipv4.conf.eth0.arp_ignore = 1",
                "net.ipv4.conf.eth1.arp_ignore = 1",
                "net.ipv4.conf.eth2.arp_ignore = 1",
                "net.ipv4.conf.eth3.arp_ignore = 1",
                "net.ipv4.conf.eth4.arp_ignore = 1",
                "net.ipv4.conf.eth5.arp_ignore = 1",
                "net.ipv4.conf.lo.arp_ignore = 1",
                "net.ipv4.conf.all.rp_filter = 0",
                "net.ipv4.conf.default.rp_filter = 0",
                "net.ipv4.conf.eth0.rp_filter = 0",
                "net.ipv4.conf.eth1.rp_filter = 0",
                "net.ipv4.conf.eth2.rp_filter = 0",
                "net.ipv4.conf.eth3.rp_filter = 0",
                "net.ipv4.conf.eth4.rp_filter = 0",
                "net.ipv4.conf.eth5.rp_filter = 0",
                "net.ipv4.conf.lo.rp_filter = 0",
            ]
            self.run_command("rm -rf /tmp/" + self.sysctl_file)
            with open("/tmp/" + self.sysctl_file, "a") as file:
                for items in sysctl_info:
                    file.write(items + "\n")
            self.run_command(
                "sudo cp -f /tmp/" + self.sysctl_file + " /etc/" + self.sysctl_file
            )
            self.run_command("sudo cat /etc/" + self.sysctl_file)
            self.run_command("sudo bash -c \"sudo sysctl --system\"")

    def revert_sysctl_file(self):
        if "net.ipv4.conf.lo.rp_filter" not in self.run_command("cat /etc/sysctl.conf"):
            sysctl_info = [
                "net.ipv4.conf.all.arp_ignore = 0",
                "net.ipv4.conf.default.arp_ignore = 0",
                "net.ipv4.conf.eth0.arp_ignore = 0",
                "net.ipv4.conf.eth1.arp_ignore = 0",
                "net.ipv4.conf.eth2.arp_ignore = 0",
                "net.ipv4.conf.eth3.arp_ignore = 0",
                "net.ipv4.conf.eth4.arp_ignore = 0",
                "net.ipv4.conf.eth5.arp_ignore = 0",
                "net.ipv4.conf.lo.arp_ignore = 0",
                "net.ipv4.conf.all.rp_filter = 0",
                "net.ipv4.conf.default.rp_filter = 0",
                "net.ipv4.conf.eth0.rp_filter = 0",
                "net.ipv4.conf.eth1.rp_filter = 0",
                "net.ipv4.conf.eth2.rp_filter = 0",
                "net.ipv4.conf.eth3.rp_filter = 0",
                "net.ipv4.conf.eth4.rp_filter = 0",
                "net.ipv4.conf.eth5.rp_filter = 0",
                "net.ipv4.conf.lo.rp_filter = 0",
            ]
            self.run_command("sudo rm -rf /tmp/" + self.sysctl_file)
            with open("/tmp/" + self.sysctl_file, "a") as file:
                for items in sysctl_info:
                    file.write(items + "\n")
            self.run_command(
                "sudo cp -f /tmp/" + self.sysctl_file + " /etc/" + self.sysctl_file
            )
            self.run_command("sudo cat /etc/" + self.sysctl_file)
            self.run_command("sudo bash -c \"sudo sysctl --system\"")

    def configure_mac_add(self):
        self.mac_add = self.fetch_mac_add()
        if self.mac_add is None:
            raise ConfigureIWFException(
                "unable to get Mac Address for the eth interface"
            )
            logging.debug("mac address")

    def check_iwf_status(self):
        output = self.run_command("ps -eaf | grep iwf | grep rx:8192")
        if "rx:8192,tx:8192" not in output:
            return False
        else:
            return True

    def kill_iwf_process(self):
        output = self.run_command("ls -lrt /var/run/")
        if "iwf.pid" in output:
            self.run_command("sudo bash -c \"rm -rf /var/run/iwf.pid\"")
        try:
            iwf_pid = subprocess.check_output(["pidof", "iwf"]).decode("utf-8")
            if iwf_pid != "":
                self.run_command('sudo kill -9 ' + iwf_pid)
        except subprocess.CalledProcessError as error:
            logger.info("IWF process killed earlier or not started")

    def check_ens3v(self):
        output = self.run_command("ip link")
        if "ens3v" not in output:
            return False
        else:
            return True

    def check_hugepages(self, nr_hugepages_size):
        output = self.run_command("cat /proc/meminfo | grep HugePages_Total")
        self.run_command("cat /proc/meminfo | grep HugePages_Free")
        self.nr_hugepages_size = nr_hugepages_size
        if str(self.nr_hugepages_size) not in output:
            self.run_command(
                "sudo bash -c \"echo  " + str(self.nr_hugepages_size) + " > " + self.hgpages_path + "\""
            )
            time.sleep(2)
            self.run_command("sudo bash -c \"rm -rf /dev/hugepages/rtemap*\"")
            output = self.run_command("cat /proc/meminfo | grep HugePages_Total")
            self.run_command("cat /proc/meminfo | grep HugePages_Free")
            if self.nr_hugepages_size not in output:
                raise ConfigureIWFException("Hugepage file not updated properly")

    def iwf_config(self):
        output = self.run_command("ls -lrt /var/run/")
        if "iwf.pid" in output:
            self.run_command("sudo bash -c \"rm -rf /var/run/iwf.pid\"")
        time.sleep(2)
        self.run_command(
            "sudo /opt/wts/latest/iwf -- -K period:6,count:10 -R rx:8192,tx:8192 -r rx:8192,tx:8192 -v info"
        )

    def check_eth_speed(self):
        self.speed = '0'
        output = str(self.run_command("sudo ethtool eth5"))
        m = re.search(r"Speed\s*\:\s*([\d]+)", output)
        if m:
            self.speed = m.group(1)
        if self.speed == '0':
            raise ("eth speed is not set as per expectation")
        return self.speed

    def config_iwf(self):
        if not self.check_ens3v() and not self.check_iwf_status():
            self.config_lib()
            self.check_eth_speed()
            self.config_hugepages(1024)
            self.check_hugepages(1024)
            self.configure_mac_add()
            self.configure_device_path()
            self.update_sysctl_file()
            self.create_iwf_file()
            self.check_hugepages(1024)

    def teardown_iwf(self):
        self.kill_iwf_process()
        self.unbind_nic_card()
        self.revert_sysctl_file()

    def printInfo(self, info):
        logger.info("confog_lib: " + info["config_lib"])
        logger.info("update_sysctl_file: " + info["update_sysctl_file"])
        logger.info("config_hugepages: " + info["config_hugepages"])
