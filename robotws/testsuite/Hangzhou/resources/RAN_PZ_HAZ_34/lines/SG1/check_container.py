from taf.transport.ssh import ssh
import logging
import re

csn = ssh()


class demplowment:

    def __init__(self):
        pass

    def setup(self, gnbip, isPrimaryCoreInLeftSubrack=True, targetNode=None):
        if not isPrimaryCoreInLeftSubrack:
            self.config = {
                "ASIK": {
                    "ip": gnbip,
                    "nodeid": "0x2011",
                    "container": [],
                    "cmd": "0:0"},
                "FCT": {
                    "ip": "192.168.253.33",
                    "nodeid": "0x2021",
                    "container": [],
                    "cmd": "0:1"},
                "FSP": {
                    "ip": "192.168.253.20",
                    "nodeid": "0x123D",
                    "container": [],
                    "cmd": "1:0"}
            }
            if targetNode == 'secondary':
                self.config = {
                    "ASIK": {
                        "ip": gnbip,
                        "nodeid": "0x1011",
                        "container": [],
                        "cmd": "0:0"},
                    "FCT": {
                        "ip": "192.168.253.17",
                        "nodeid": "0x1021",
                        "container": [],
                        "cmd": "0:1"},
                    "FSP": {
                        "ip": "192.168.253.20",
                        "nodeid": "0x123D",
                        "container": [],
                        "cmd": "1:0"}
                }
        else:
            self.config = {
                "ASIK": {
                    "ip": gnbip,
                    "nodeid": "0x1011",
                    "container": [],
                    "cmd": "0:0"},
                "FCT": {
                    "ip": "192.168.253.17",
                    "nodeid": "0x1021",
                    "container": [],
                    "cmd": "0:1"},
                "FSP": {
                    "ip": "192.168.253.20",
                    "nodeid": "0x123D",
                    "container": [],
                    "cmd": "1:0"}
            }
            if targetNode == 'secondary':
                self.config = {
                    "ASIK": {
                        "ip": gnbip,
                        "nodeid": "0x2011",
                        "container": [],
                        "cmd": "0:0"},
                    "FCT": {
                        "ip": "192.168.253.33",
                        "nodeid": "0x2021",
                        "container": [],
                        "cmd": "0:1"},
                    "FSP": {
                        "ip": "192.168.253.20",
                        "nodeid": "0x123D",
                        "container": [],
                        "cmd": "1:0"}
                }

        self.username = "toor4nsn"
        self.password = "oZPS0POrRieRtu"
        self.conn = ssh()
        self._get_containers()
        print(self.config)

    def _ssh_connect(self, nodename):
        proxy = None
        if nodename != "ASIK":
            proxy = "alias_ASIK"
        self.conn.connect_to(
            hostname=self.config[nodename]['ip'],
            username=self.username,
            password=self.password,
            proxy=proxy,
            alias="alias_{}".format(nodename))

    def _get_containers(self):
        self._ssh_connect("ASIK")
        for node in self.config:
            cmd = "export PYTHONPATH=/opt/hwmt/python; \
            python3 /opt/hwmt/python/hwapi/SupervisorS.py -n {} -o list_cbts -p 15004 |grep {}".format(
                self.config[node]['nodeid'], self.config[node]['nodeid'])
            outcome = self.conn.execute(command=cmd, connection="alias_ASIK")
            lines = outcome.strip().split("\r\n")
            for line in lines:
                res = re.findall(
                    r"nodeId:(0x[A-F|0-9]*), nodeState:.*nodeName:([A-Z|0-9|-]*),?", line)
                if len(res) > 0:
                    self.config[node]['container'].append(res[0])

    def get_container(self, nodename):
        for key in self.config:
            for node in self.config[key]["container"]:
                if nodename in node[1]:
                    self._ssh_connect("ASIK")
                    outcome = self.conn.execute(
                        command="bsh {} ls /tmp/node_{}".format(
                            self.config[key]['cmd'], node[0].lower()), connection="alias_ASIK")
                    if "No such file or directory" not in outcome:
                        return (key, self.config[key]['cmd'], node[0].lower(), node[1],
                                "/tmp/node_{}".format(node[0].lower()))
                    outcome = self.conn.execute(
                        command="bsh {} ls /tmp/node_{}".format(
                            self.config[key]['cmd'], node[1]), connection="alias_ASIK")
                    if "No such file or directory" not in outcome:
                        return (key, self.config[key]['cmd'], node[0].lower(), node[1], "/tmp/node_{}".format(
                            node[1]))

    def download_file_from_container(self, filename, nodename, localpath):
        res = self.get_container(nodename)
        print(res)
        localpath = "{}/{}".format(localpath, filename)
        remotepath = "{}/tmp/{}".format(res[4], filename)
        cmd = "bget {} {} .".format(res[1], remotepath)
        self.conn.execute(command=cmd, connection="alias_ASIK")
        out = self.conn.execute(command="ls", connection="alias_ASIK")
        print(out)
        self.conn.download_file("/user/toor4nsn/{}".format(filename), localpath, connection="alias_ASIK")
        self.conn.execute(command="rm {}".format(filename), connection="alias_ASIK")

    def check_board_status_on_gnb(self, connection):
        """ This keyword is used to get the board status, including ASIK/ASIB/ABIO and ABIK/ABIL from ASIK
        Return the board status"""
        # feature1514_flag = stream_manager.feature_1514_opened(connection=connection)
        # if feature1514_flag is True:
        #     command = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004'
        # else:
        #     command = 'export PYTHONPATH=/opt/hwmt/python; python /opt/hwmt/python/hwapi/AdetS.py -s'
        command = 'export PYTHONPATH=/opt/hwmt/python; python3 /opt/hwmt/python/hwapi/AdetS.py -s -p 15004'
        output = csn.execute(command, connection=connection, timeout='60 s')
        re_command = r'0x\d+\s+FSM1_FCT\s+(\w+)\[\d\]'
        fct_result = re.findall(re_command, output)
        re_command = r'0x\d+\s+FSM1_FSP1\s+(\w+)\[\d\]'
        fsp_result = re.findall(re_command, output)
        return ''.join(fct_result), ''.join(fsp_result)
