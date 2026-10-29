import re
import os
import robot.api.logger as logger
import paramiko


class CB001049_NftHandler:

    def __init__(self):
        self.file_name = 'nft_list_ruleset'
        self.address_type = ['ipv6_addr', 'ipv4_addr']
        self.plane_name = ['xnCplaneRemoteIpAddrList', 'ngCplaneRemoteIpAddrList']
        self.address_re = [
            r'(?<=\{ )([\da-fA-F:]+)(?= \})',
            r'([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})'
        ]
        self.plane = [
            r'set.',
            r'_[0-9].\{\n\t\ttype.',
            r'\n\t\telements.=.\{.',
            r'.\}\n\t\}'
        ]
        self.chainv6 = [
            r'sctp.sport.\{.[0-9]{5}.\}.sctp.dport.\{.[0-9]{5}.\}.ip6.saddr.\@',
            r'_[0-9].ip6.daddr.\{.',
            r'.\}.counter.packets.[0-9].bytes.[0-9].accept'
        ]
        self.chainv4 = [
            r'sctp.sport.\{.[0-9]{5}.\}.sctp.dport.\{.[0-9]{5}.\}.ip.saddr.\@',
            r'_[0-9].ip.daddr.\{.',
            r'.\}.counter.packets.[0-9].bytes.[0-9].accept'
        ]
        self.grep_values = {
            'all_remote': 'elements',
            'local_xnCplane': 'xnCplaneRemoteIpAddrList',
            'local_ngCplane': 'ngCplaneRemoteIpAddrList'
        }

    def __del__(self):
        pass

    @staticmethod
    def execute_ssh_command(ip: str, command: str):
        logger.info(f"{command}")
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        client.load_system_host_keys()
        client.connect(ip, username='toor4nsn', password='oZPS0POrRieRtu')
        logger.info(f"ssh :$ {command}", html=True, also_console=True)
        _, stdout, _ = client.exec_command(command)
        output = stdout.readlines()
        client.close()
        return output

    @staticmethod
    def execute_command(command: str):
        logger.info(f":$ {command}", html=True, also_console=True)
        stdout = os.popen(command).read()

    @staticmethod
    def supplement_address_v6(file_name):
        """
        Replaces :: in ipv6 addresses with :0000: and creates copy of the file.

        :return string: new file name.
        """
        with open(f'{file_name}.txt', 'r') as file:
            filedata = file.read()

        filedata = filedata.replace('::', ':0000:')

        with open(f'{file_name}_copy.txt', 'w') as file:
            file.write(filedata)

        logger.info(f"file created at {file_name}_copy", html=True, also_console=True)
        return f"{file_name}_copy.txt"

    def find_rule(self, name: str, a_type: int) -> list:
        """
        Finds correct rule using regex.

        :param string name: name for correct plane.
        :param int a_type: address type -> ipv6 = 0, ipv4 = 1.
        :return list: output, address.
        """
        with open(f'{self.file_name}_copy.txt', 'r') as ruleset:
            text = ruleset.read()
            finds = re.compile("(%s%s%s%s%s%s%s)" % (
                self.plane[0],
                name,
                self.plane[1],
                self.address_type[a_type],
                self.plane[2],
                self.address_re[a_type],
                self.plane[3]
            )
                               ).findall(text)

        logger.info(f'{finds}', html=True, also_console=True)
        return finds

    def find_chain_v6(self, name: str) -> list:
        """
        Finds correct chain ipv6 using regex.

        :param string name: name for correct plane.
        :return list: output, address.
        """
        with open(f'{self.file_name}_copy.txt', 'r') as ruleset:
            text = ruleset.read()
            finds = re.compile("(%s%s%s%s%s)" % (
                self.chainv6[0],
                name,
                self.chainv6[1],
                self.address_re[0],
                self.chainv6[2]
            )
                               ).findall(text)

        logger.info(f'{finds}', html=True, also_console=True)
        return finds

    def find_chainv4(self, name: str) -> list:
        """
        Finds correct chain ipv4 using regex.

        :param string name: name for correct plane.
        :return list: output, address.
        """
        with open(f'{self.file_name}_copy.txt', 'r') as ruleset:
            text = ruleset.read()
            finds = re.compile("(%s%s%s%s%s)" % (
                self.chainv4[0],
                name,
                self.chainv4[1],
                self.address_re[1],
                self.chainv4[2]
            )
                               ).findall(text)

        logger.info(f'{finds}', html=True, also_console=True)
        return finds

    def gather_ipv4_address(self) -> list:
        ipsv4 = list()
        ipsv4 += [find[1] for find in self.find_rule(self.plane_name[0], 1)]
        ipsv4 += [find[1] for find in self.find_rule(self.plane_name[1], 1)]
        ipsv4 += [find[1] for find in self.find_chainv4(self.plane_name[0])]
        ipsv4 += [find[1] for find in self.find_chainv4(self.plane_name[1])]

        logger.info(f'Found IPv4 Addresses: {ipsv4}', html=True, also_console=True)
        return ipsv4

    def gather_ipv6_address(self) -> list:
        ipsv6 = list()
        ipsv6 += [find[1] for find in self.find_rule(self.plane_name[0], 0)]
        ipsv6 += [find[1] for find in self.find_rule(self.plane_name[1], 0)]
        ipsv6 += [find[1] for find in self.find_chain_v6(self.plane_name[0])]
        ipsv6 += [find[1] for find in self.find_chain_v6(self.plane_name[1])]

        logger.info(f'Found IPv6 Addresses: {ipsv6}', html=True, also_console=True)
        return ipsv6

    def check_classifier_table_v4(self) -> bool:
        ipsv4 = self.gather_ipv4_address()
        print(ipsv4)
        with open('l3l4_classifier_table.txt', 'r') as table:
            text = table.read()

            ips = [ip in text for ip in ipsv4]
            logger.info(ips, html=True, also_console=True)
            return all(ips)

    def check_classifier_table_v6(self) -> bool:
        ipsv6 = self.gather_ipv6_address()
        print(ipsv6)
        name = self.supplement_address_v6(file_name='l3l4_classifier_table_ipv6')
        with open(f'{name}', 'r') as table:
            text = table.read()

            ips = [ip in text for ip in ipsv6]
            logger.info(ips, html=True, also_console=True)
            return all(ips)

    def get_addresses_from_nft_list_ruleset_output_file(self, pattern: str) -> str:
        execdir = os.getcwd()
        return os.popen(f'grep {self.grep_values[pattern]} {execdir}/nft_list_ruleset.txt').read()

    @staticmethod
    def get_section_from_output(section_name: str, section_lines_count: int) -> str:
        execdir = os.getcwd()
        return os.popen(f'grep {section_name} {execdir}/nft_list_ruleset.txt -A {section_lines_count}').read()
