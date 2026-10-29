# -*- coding: utf-8 -*-

import taf.transport.ssh as ssh


class Pioneer_DL_Traffic:
    def _appserver_connect(self, conn):
        """
        Connect to appserver by ssh
        :param conn: conn alias
        :return ssh connection
        """
        hostname = '10.57.153.50'
        username = 'cmw_sg3'
        password = 'iW_K#8.ute%A10h0m0ra'
        sshconn = ssh.ssh()
        sshconn.connect_to(
            hostname=hostname,
            username=username,
            password=password,
            alias=conn)
        return sshconn

    def start_dl_traffic(self, ueip, port, tp="50M", dur=9999, taskname="DL test"):
        sshconn = self._appserver_connect(taskname)
        cmd = "iperf -c {} -u -t {} -i 1 -p {} -P 1 -f m -b {} -l 1024B -T 64".format(
            ueip, dur, port, tp)
        sshconn.send_command(command=cmd, connection=taskname)
        sshconn.disconnect(connection=taskname)
        return ueip

    def stop_dl_traffic(self, ueip, port):
        sshconn = self._appserver_connect("killdl")
        cmd = "ps aux |grep iperf |grep " + \
              str(ueip) + " |grep " + str(port) + " |awk '{print $2}' | xargs kill -9"
        sshconn.send_command(command=cmd, connection="killdl")
        sshconn.disconnect(connection="killdl")
        return ueip
