"""
:copyright: Nokia Networks
:author: Konrad Krzyzak <konrad.krzyzak@nokia.com>
:maintainer: Konrad Krzyzak <konrad.krzyzak@nokia.com>
"""
import paramiko
import re
from robot.libraries.BuiltIn import BuiltIn
from robot.api.deco import keyword


def py3_string(x):
    """
    In python3 converts bytes to string if needed. This method should be used in every place when being uncertain
    of type of output
    :param x:
    :return:
    """
    if isinstance(x, bytes):
        return x.decode('utf-8')
    else:
        return x


class CplaneOverloadSetter(object):
    def __init__(self):
        self.gNB_connection = None
        self.ABIL_connection = None
        self.BBMOD_ip = None
        self.ovl_script_cmd = "./opt/nokia/SS_CPLANE/bin/set_overload_high_threshold " \
                              "--port 30671 --overload_high_threshold "
        self.cpue_location = None
        self.cpue_instances = []
        self.bbmod_prompt = None

    @keyword("Set Overload High Threshold to ${ovl_threshold}")
    def set_ovlthreshold_to_specific_value(self, ovl_threshold):
        """
        Set value for rdOverloadHighThreshold inside gNB
        OLV is set on all CPUE instances for multiple instance hardware
        Script delivered by DEV team for details refer to:
        https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1131998755

        Parameters
        ---------
        ovl_threshold : string
        expected value to be applied by gNB CPUE

        """
        if not self.cpue_location:
            self.__start_cplane_lxc_container_connection()
            self.__get_cpue_core_id()

        for (cpue_node, cpue_prompt) in self.cpue_instances:
            lxc_cpue_attach_cmd = 'lxc-attach --name {}'.format(cpue_node)
            BuiltIn().log(str(cpue_prompt))
            expected_prompt = cpue_prompt + ':~ >'
            cpue_connection_status = self.__chan_expect(chan=self.ABIL_connection, cmd=lxc_cpue_attach_cmd,
                                                        expect=expected_prompt)
            BuiltIn().log(cpue_connection_status)
            expected_prompt = cpue_prompt + ':/ >'
            cpue_cmd_execution_status = self.__chan_expect(chan=self.ABIL_connection, cmd="cd /",
                                                           expect=expected_prompt)
            BuiltIn().log(cpue_cmd_execution_status)
            cpln_script_lib_location = "LD_LIBRARY_PATH=./opt/nokia/lib64/ "
            cpln_overload_cmd = cpln_script_lib_location + self.ovl_script_cmd + str(ovl_threshold)
            BuiltIn().log('Command to execute: {}'.format(cpln_overload_cmd))

            cpln_ovl_cmd_output = py3_string(self.__chan_expect(chan=self.ABIL_connection, cmd=cpln_overload_cmd,
                                                                expect=expected_prompt, timeout=30))
            BuiltIn().log('Command execution output: {}'.format(cpln_ovl_cmd_output))
            exit_cmd_output = self.__chan_expect(chan=self.ABIL_connection, cmd='exit', expect=self.bbmod_prompt)
            BuiltIn().log('Exit execution output: {}'.format(exit_cmd_output))

            # assert "No such file or directory" not in str(cpln_ovl_cmd_output), "Script is not avaliable on gNB!"
            # assert "Sent request to change overload high threshold" in str(cpln_ovl_cmd_output), "Request not send!"
            # assert "Overload high threshold changed" in str(cpln_ovl_cmd_output), "Script execution failed!"

            cmd_success = False
            if "Overload high threshold changed" in str(cpln_ovl_cmd_output):
                cmd_success = True
            elif "Overload high threshold changed" in str(exit_cmd_output):
                BuiltIn().log('Output from exit cmd checked!')
                cmd_success = True

            assert cmd_success, "Script execution failed!"

    def __chan_expect(self, chan, cmd, expect=':~ >', expect2=None, timeout=10):
        """
        Send a command on the channel and expect a specific output ending

        Parameters
        ----------
        chan : Paramiko.channel.Channel
            channel used to communicate
        cmd : string
            command to send
        expect : string
            string by which we expect the output to end
        expect2 : string
            optional string by which we expect the output to end as well
        timeout : int
            timeout value for all operations performed by the channel

        Returns
        -------
        string
            output of the command
        """
        chan.send(py3_string(cmd) + '\r\n')
        return self.__chan_display(chan, expect, expect2, timeout)

    @staticmethod
    def __chan_display(chan, expect=':~ >', expect2=None, timeout=10):
        """
        Read the channel output and expect a specific output ending

        Parameters
        ----------
        chan : Paramiko.channel.Channel
            channel used to communicate
        expect : string
            string by which we expect the output to end
        expect2 : string
            optional string by which we expect the output to end as well
        timeout : int
            timeout value for all operations performed by the channel

        Returns
        -------
        string
            output of the command
        boolean
            True if the 2nd expect was found
        """
        buff = ''
        chan.timeout = timeout
        if expect2 is None:
            expect2 = expect
        try:
            while not buff.endswith(expect) and not buff.endswith(expect2):
                resp = py3_string(chan.recv(9999))
                buff += resp
        except Exception as e:
            BuiltIn().log('Exception raised: {}'.format(type(e)))
            raise e
        return buff, buff.endswith(expect2)

    def __connect_to_gNB(self):
        self.gNB_connection = paramiko.SSHClient()
        self.gNB_connection.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self.gNB_connection.connect('192.168.255.129', username='toor4nsn', password='oZPS0POrRieRtu')
        (stdin, stdout, stderr) = self.gNB_connection.exec_command('cat /etc/hosts | grep 127.0.0.1')
        gnb_platform_search = stdout.readlines()
        self.__set_cpue_location(str(gnb_platform_search))

    def __set_cpue_location(self, localhost):
        if 'fct' in localhost:
            BuiltIn().log('ABIL/ABIO detected for CPUE location based on {}'.format(localhost))
            self.cpue_location = 'ABIL/ABIO'
        elif 'asc' in localhost:
            BuiltIn().log('ASOE detected for CPUE location based on {}'.format(localhost))
            self.cpue_location = 'ASOE'
        else:
            raise Exception("Not recognized platform for cpue based on {}".format(localhost))

    def __get_bbmod_ip(self):
        ip_search_cmds = []
        ip_search_cmds.append('cat /etc/hosts | grep asp-1a')
        ip_search_cmds.append('cat /etc/hosts | grep asp-5a')

        for ip_search_cmd in ip_search_cmds:
            (stdin, stdout, stderr) = self.gNB_connection.exec_command(ip_search_cmd)
            ip_search = stdout.readlines()
            if ip_search:
                BuiltIn().log('BBMOD ip detected based on {}'.format(ip_search))
                self.BBMOD_ip = str(ip_search[0].split(" ")[0])
                break
        if not self.BBMOD_ip:
            raise Exception("Cannot find BBMOD IP")

    def __get_list_of_active_components(self):
        expected_prompt = ':~ >'
        ls_cmd_result = self.__chan_expect(chan=self.ABIL_connection, cmd='ls', expect=expected_prompt)

        bbmod_prompt = 'root' + ls_cmd_result[0].split('root')[-1]
        BuiltIn().log('BBMOD detected prompt: {}'.format(bbmod_prompt))
        self.bbmod_prompt = bbmod_prompt

        lxc_list_cmd = 'lxc-ls'
        retry = 0
        components_list = []
        while retry < 5:
            lxc_container_list = self.__chan_expect(chan=self.ABIL_connection, cmd=lxc_list_cmd, expect=bbmod_prompt)
            BuiltIn().log('lxc-ls result: {}'.format(lxc_container_list))

            components_list = lxc_container_list[0].split()
            BuiltIn().log('Executed cmd: {}'.format(components_list[0]))
            if py3_string(components_list[0]) == py3_string(lxc_list_cmd):
                break
            else:
                retry = retry + 1
                BuiltIn().log('Retry {} for cmd lxc-ls'.format(retry))

        if components_list[0] != lxc_list_cmd:
            raise Exception("Not able to execute proper command!")
        components_list = [component for component in components_list if "0x" in component]

        if components_list:
            BuiltIn().log('Discovered node_ids: {}'.format(components_list))
            return components_list
        else:
            raise Exception("Not able to detect any active gNB component!")

    def __get_cpue_core_id(self):
        components_list = self.__get_list_of_active_components()
        expected_prompt = ':~ >'
        for component in components_list:
            lxc_attach_cmd = 'lxc-attach --name {}'.format(component)
            try:
                cpue_connection_status = self.__chan_expect(chan=self.ABIL_connection, cmd=lxc_attach_cmd,
                                                            expect=expected_prompt)
            except Exception as e:
                BuiltIn().log("Retry with new prompt")
                self.__chan_expect(chan=self.ABIL_connection, cmd='exit', expect=':~ >')
                cpue_connection_status = self.__chan_expect(chan=self.ABIL_connection, cmd=lxc_attach_cmd,
                                                            expect=':/ >')
            BuiltIn().log('Node id result: {}'.format(cpue_connection_status))
            cp_ue_prompt = re.findall(r'CPUE.\d', cpue_connection_status[0])
            if len(cp_ue_prompt):
                BuiltIn().log('CPUE instance: {} running on node_id {}'.format(cp_ue_prompt, component))
                self.cpue_instances.append((component, cp_ue_prompt[0]))
            self.__chan_expect(chan=self.ABIL_connection, cmd='exit', expect=expected_prompt)

        if not self.cpue_instances:
            raise Exception("Not able to detect any active CPUE component on system!")

    def __start_cplane_lxc_container_connection(self):
        """
        Set connection to CPUE location on ABIL for gNB setup ASIK+ABIL or ASOE or ASIB+ABIO
        """
        self.__connect_to_gNB()
        if self.cpue_location == 'ABIL/ABIO':
            self.__get_bbmod_ip()
            cpue_location_ip = (self.BBMOD_ip, 22)
            BuiltIn().log('Board ip: {}'.format(self.BBMOD_ip))
        else:
            cpue_location_ip = ("127.0.0.1", 22)

        local_addr = ('192.168.255.129', 22)
        gNB_transport_tunnel = self.gNB_connection.get_transport()
        ABIL_redirect = gNB_transport_tunnel.open_channel("direct-tcpip", cpue_location_ip, local_addr)

        ABIL_tunnel = paramiko.SSHClient()
        ABIL_tunnel.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ABIL_tunnel.connect(self.BBMOD_ip, username='toor4nsn', password='oZPS0POrRieRtu', sock=ABIL_redirect)
        self.ABIL_connection = ABIL_tunnel.invoke_shell()
