#################################################################################
# File           : AIC_LogCapture.py
# Version        : 1.0
# Modified       : Vivek GV 12.09.2021
# Description    :
# Supported HW  :
# Version        :
#   1.0			 :
# Requires files : -
# Requires options: -
# Copyright (C) Nokia 2021. All Rights Reserved.
# Author: GV Vivek
# Log of changes : $Log:
# ================================================================================
# Functions           Descriptions
# -------------------------------------------------------------------------------
#
#
#################################################################################


import paramiko
import sys
import re
import os
import time
import yaml
from yaml.loader import SafeLoader
import pexpect
import tarfile
from CommonClass import sFTP_Logs
from CommonClass import Cmd_Executor
from datetime import datetime
from zipfile import ZipFile


class AIC_Monitoring(sFTP_Logs, Cmd_Executor):
    def __init__(self, logtype, envtype, hwtype, ipaddr=None, user=None, password=None, domain=None,
                 remotepath=None, localpath=None):
        self.log_type = logtype
        self.env_type = envtype
        self.hw_type = hwtype
        self.object = self._getinfo()
        self.ip = ipaddr
        self.Uname = user
        self.passw = password
        #        self.ip = self.object.get('Ipaddress')
        #        self.Uname = self.object.get('UserName')
        #        self.passw = self.object.get('PassWord')
        self.namespace = domain
        sFTP_Logs.__init__(self, remotepath, localpath)
        Cmd_Executor.__init__(self, self.ip, self.Uname, self.passw)
        self.vcu_cpif_pod = "ute-" + self.namespace + "-cpif-0"
        self.vcu_cpif_container = "ctr-" + self.namespace + "-cpif"
        self.vcu_cpif_nwmgmt_container = "ctr-" + self.namespace + "-nwmgmt "
        self.vdu_cprt_pod = "ute-" + self.namespace + "-cprt-0"
        self.vdu_cprt_nwmgmt_container = "ctr-" + self.namespace + "-nwmgmt "
        self.pod = None
        self.container_logs = None
        self.container_l2rt = None
        self.container_l2hi = None
        self.container_l1hi = None
        self.oamfh_pod = None
        self.oamfh_container = None
        self.VmPath = localpath

    def get_logserver_pod_container_info(self):
        cmd1 = "kubectl get pods -n " + self.namespace + " | grep -i log | cut -d ' ' -f1"
        cmd2 = "kubectl describe pod -n " + self.namespace + \
               " | grep -i ctr-.*logs | awk '{print $1}'| cut -d ':' -f1 | grep -i ctr"
        self.pod = self.exec_get_output(cmd1, 'vDU')
        self.container_logs = self.exec_get_output(cmd2, 'vDU')
        if ((len(self.pod) or len(self.container_logs)) == 0):
            raise Exception("ERROR - NO Pod or Container Found")

    def get_oamfh_pod_container_info(self):
        cmd1 = "kubectl get pods -n " + self.namespace + " | grep -i oamfh | cut -d ' ' -f1"
        cmd2 = "kubectl describe pod -n " + self.namespace + " | grep -i ctr.*oamfh: | cut -d ':' -f1"
        self.oamfh_pod = self.exec_get_output(cmd1, 'vDU')
        self.oamfh_container = self.exec_get_output(cmd2, 'vDU')
        if ((len(self.oamfh_pod) or len(self.oamfh_container)) == 0):
            raise Exception("ERROR - oamfh Pod or Container Not Found. Check whether all pods are running or not")

    def execute_prerequisite_cmd(self):
        cmd = "oc login --username=nokiaadmin --password=nokiaadmin --server=" + self.ip + \
              ":6443 --insecure-skip-tls-verify=true"
        nullify_ssh_known_hosts = ">/home/ute/.ssh/known_hosts"
        os.system(nullify_ssh_known_hosts)
        self.exec_cmd(cmd, 'vDU')
        cmd = self.object.get('OC_login')
        cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
        self.expect_list(cmd, 'vDU')

    def aic_start_vdu_syslog(self):
        cmdlist = ["", "", "", "", "", "", ""]
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        self.get_logserver_pod_container_info()
        cmdlist[0] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'ls /var/log/syslog/'"
        cmdlist[1] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'rm /var/log/syslog/*'"
        cmdlist[2] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'ls /var/log/syslog/'"
        cmdlist[3] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'ls /var/log/localvolume/'"
        cmdlist[4] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'rm /var/log/localvolume/syslog.1'"
        cmdlist[5] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'truncate -s 0 /var/log/localvolume/syslog'"
        cmdlist[6] = "kubectl -n " + self.namespace + " exec -it " + self.pod + \
                     " -c " + self.container_logs + " -- bash -c 'ls /var/log/localvolume/'"
        self.exec_cmd_list(cmdlist, 'vDU')

    def get_targetbd_file(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        self.get_oamfh_pod_container_info()
        cmd = self.object.get('get_targetbd')
        cmd1 = "kubectl exec -it -n " + self.namespace + " " + self.oamfh_pod + " -c " + self.oamfh_container + \
               " -- bash -c \"ls -lrt /ffs/run/RFSW/ \" | grep -i Target | awk '{ print $9}' "
        targetbd_file_name = self.exec_get_output(cmd1, 'vDU')
        cmd[2][1] = "kubectl -n " + self.namespace + " cp " + self.oamfh_pod + \
                    ":/ffs/run/RFSW/" + targetbd_file_name + " -c " + \
                    self.oamfh_container + " TargetBD_vDU.xml "
        self.expect_list(cmd, 'vDU')
        self.sFTP_TargetBD_File()
        if os.path.exists("/home/ute/TargetBD_vDU.xml"):
            print("TargetBD file copied to /home/ute/TargetBD_vDU.xml")
        else:
            raise Exception("ERROR - argetBD file copy failed")

    """
    def aic_stop_collect_vdu_syslog(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        self.get_logserver_pod_container_info()
        self.exec_cmd_list(self.object.get('Mkdir_oam'), 'vDU')
        cmdlist1 = "oc get pod -n " + self.namespace + " -owide |grep logservice|awk '{print $6}'"
        LogServerIp = self.exec_get_output(cmdlist1, 'vDU')
        cmdlist2 = "curl -X GET http://" + str(LogServerIp) + \
                   ":50108/api/trc/v1/log_data -o /tmp/Syslog_dir/syslog_vdu.zip"
        self.exec_cmd(cmdlist2, 'vDU')
        self.exec_cmd("ls -l", 'vDU')
        time.sleep(20)
        self.sFTP_Files()
        print("localpath=" + self.VmPath)
        with ZipFile(self.VmPath + "/syslog_vdu.zip", 'r') as zObject:
            zObject.extractall(path=self.VmPath)
        ListOfZipFile = os.listdir(self.VmPath)
        print(ListOfZipFile)
        for filename in ListOfZipFile:
            with ZipFile(self.VmPath + filename, 'r') as zObject1:
                zObject1.extractall(path=self.VmPath)
    """

    def aic_stop_collect_vdu_syslog(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        self.get_logserver_pod_container_info()
        self.exec_cmd_list(self.object.get('Mkdir_oam'), 'vDU')
        cmdlist1 = "oc get pod -n " + self.namespace + " -owide |grep logservice|awk '{print $6}'"
        LogServerIp = self.exec_get_output(cmdlist1, 'vDU')
        cmdlist = self.object.get('copysyslog')
        cmdlist[1][1] = cmdlist[1][1].replace("Log_Server_Ip_var", str(LogServerIp))
        self.expect_list(cmdlist, 'vDU')
        self.sFTP_Files()
        print("localpath=" + self.VmPath)
        with ZipFile(self.VmPath + "/syslog_vdu.zip", 'r') as zObject:
            zObject.extractall(path=self.VmPath)
        ListOfZipFile = os.listdir(self.VmPath)
        print(ListOfZipFile)
        for filename in ListOfZipFile:
            with ZipFile(self.VmPath + filename, 'r') as zObject1:
                zObject1.extractall(path=self.VmPath)

    def _getinfo(self):
        dir_path = os.path.dirname(os.path.realpath(__file__))
        with open(dir_path + '/' + 'abstract.yaml') as f:
            data = yaml.load(f, Loader=SafeLoader)
            return data[self.log_type][self.env_type][self.hw_type]

    def aic_start_cpif_x2_F1_Mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        cmd1 = "kubectl get pod " + 'ute-' + self.namespace + "-cpif-0 -o yaml -n " + self.namespace + \
               " |grep nodeName | awk '{print $2}'"
        cpif_worker_node = self.exec_get_output(cmd1, 'vCU')
        #       print("cpif worker _node is ",cpif_worker_node)
        cmd1 = "ssh " + cpif_worker_node + " sudo crictl ps|grep cpif |grep -v cpif- |grep " + self.namespace + \
               "|awk '{ print $1}'"
        Continer_id = self.exec_get_output(cmd1, 'vCU')
        #       print("container number", container_id)
        cmd1 = "ssh " + cpif_worker_node + " sudo crictl inspect --output yaml " + Continer_id + \
               " | grep 'pid:'|awk '{print $2}'"
        pod_pid = self.exec_get_output(cmd1, 'vCU')
        cmd1 = "ssh " + cpif_worker_node + " sudo rm -rf /var/home/core/tcpdump_cpif.pcap"
        self.exec_cmd(cmd1, 'vCU')
        #       print("Pod number", pod_pid)
        cmd1 = "ssh " + cpif_worker_node + " sudo nohup nsenter -r -n -t " + pod_pid + \
               " tcpdump -i any -s 0 -w ./tcpdump_cpif.pcap > .//tcpdump_vgv 2>&1 &"
        self.exec_cmd(cmd1, 'vCU')

    def aic_stop_collect_cpif_x2_F1_Mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        cmd1 = "kubectl get pod " + 'ute-' + self.namespace + "-cpif-0 -o yaml -n " + self.namespace + \
               " |grep nodeName | awk '{print $2}'"
        cpif_worker_node = self.exec_get_output(cmd1, 'vCU')
        cmd1 = "ssh " + cpif_worker_node + \
               " \"sudo kill -9 \\$(ps -ef| grep -i 'tcpdump_cpif' | grep -v grep |tr -s ' '| cut -d ' ' -f2)\" "
        self.exec_cmd(cmd1, 'vCU')
        self.exec_cmd("mkdir -p /tmp/Cpif_dir/", 'vCU')
        cmd1 = "scp " + cpif_worker_node + ":/var/home/core/tcpdump_cpif.pcap  /tmp/Cpif_dir/"
        self.exec_cmd(cmd1, 'vCU')
        #         node = 'ssh  '+self.Uname+'@'+self.ip
        #         fout = open('mylog.txt', 'wb') #comment this
        #         child = pexpect.spawn(node)
        #         child.logfile = fout #comment this
        #         child.expect("password")
        #         child.sendline(self.passw)
        #         child.expect('[$#]')
        #         cmd1 = "ssh "+cpif_worker_node
        #         child.sendline(cmd1)
        #         child.expect('[$#]')
        #         print("scp Hostkey chk")
        #         cmd1 = "sudo scp -o UserKnownHostsFile=/dev/null -oStrictHostKeyChecking=no tcpdump_cpif.pcap " + \
        #                self.Uname + "@" + self.ip + ":" + self.remote_path
        #         print("scp cmd",cmd1,"pass")
        #         child.sendline(cmd1)
        #         child.expect("password",self.passw)
        #         child.sendline(self.passw)
        #         fout.close()  #comment this
        time.sleep(10)
        self.sFTP_Files()

    #         child.close()

    def aic_start_cprt_F1C_Mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        cmd = self.object.get('Cmd_CPRT_enable')
        print("cmd[1][1]", cmd[1][1])
        print("cmd[2][1]", cmd[2][1])
        print("cmd[3][1]", cmd[3][1])
        print("cmd[4][1]", cmd[4][1])
        cmd[1][1] = "oc login --username=nokiaadmin --password=nokiaadmin --server=" + self.ip + \
                    ":6443 --insecure-skip-tls-verify=true"
        cmd[3][1] = "kubectl -n " + self.namespace + " exec -it " + self.vdu_cprt_pod + \
                    " -c " + self.vdu_cprt_nwmgmt_container + " -- bash"
        print("cmd[3][1]", cmd[3][1])
        os.system(">/home/ute/.ssh/known_hosts")
        self.expect_list(cmd, 'vDU')

    def aic_stop_collect_cprt_F1C_Mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        cmd = self.object.get('Cmd_CPRT_disable')
        print("cmd[1][1]", cmd[1][1])
        print("cmd[2][1]", cmd[2][1])
        print("cmd[3][1]", cmd[3][1])
        print("cmd[4][1]", cmd[4][1])
        print("cmd[5][1]", cmd[5][1])
        print("cmd[6][1]", cmd[6][1])
        print("cmd[7][1]", cmd[7][1])
        print("cmd[8][1]", cmd[8][1])
        cmd[2][1] = "kubectl -n " + self.namespace + " exec -it " + self.vdu_cprt_pod + \
                    " -c " + self.vdu_cprt_nwmgmt_container + " -- bash"
        cmd[8][1] = "kubectl exec -n " + self.namespace + " " + self.vdu_cprt_pod + \
                    " -c " + self.vdu_cprt_nwmgmt_container + " -- cat /tmp/CPRT.pcap > /tmp/CPRT/CPRT.pcap "
        print("cmd[8][1]", cmd[8][1])
        self.expect_list(cmd, 'vDU')
        self.sFTP_Files()

    def aic_start_cpif_Mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        cmd = self.object.get('Cmd_CPIF_enable')
        print("cmd[1][1]", cmd[1][1])
        print("cmd[2][1]", cmd[2][1])
        print("cmd[3][1]", cmd[3][1])
        print("cmd[4][1]", cmd[4][1])
        cmd[1][1] = "oc login --username=nokiaadmin --password=nokiaadmin --server=" + self.ip + \
                    ":6443 --insecure-skip-tls-verify=true"
        cmd[3][1] = "kubectl -n " + self.namespace + " exec -it " + self.vcu_cpif_pod + \
                    " -c " + self.vcu_cpif_nwmgmt_container + " -- bash"
        print("cmd[3][1]", cmd[3][1])
        os.system(">/home/ute/.ssh/known_hosts")
        self.expect_list(cmd, 'vCU')

    def aic_stop_collect_cpif_Mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        cmd = self.object.get('Cmd_CPIF_disable')
        print("cmd[1][1]", cmd[1][1])
        print("cmd[2][1]", cmd[2][1])
        print("cmd[3][1]", cmd[3][1])
        print("cmd[4][1]", cmd[4][1])
        print("cmd[5][1]", cmd[5][1])
        print("cmd[6][1]", cmd[6][1])
        print("cmd[7][1]", cmd[7][1])
        print("cmd[8][1]", cmd[8][1])
        cmd[2][1] = "kubectl -n " + self.namespace + " exec -it " + self.vcu_cpif_pod + \
                    " -c " + self.vcu_cpif_nwmgmt_container + " -- bash"
        cmd[8][1] = "kubectl exec -n " + self.namespace + " " + self.vcu_cpif_pod + \
                    " -c " + self.vcu_cpif_nwmgmt_container + " -- cat /tmp/CPRT.pcap > /tmp/CPRT/CPRT_cpif.pcap "
        print("cmd[8][1]", cmd[8][1])
        self.expect_list(cmd, 'vCU')
        self.sFTP_Files()

    def get_pod_container_info(self):
        cmd1 = "kubectl get pods -n " + self.namespace + " |egrep '(-up-)' |awk '{print $1}'"
        self.pod = self.exec_get_output(cmd1, 'vDU')
        cmd2 = "kubectl describe pods " + self.pod + " -n " + self.namespace + \
               "|grep -i ctr-" + self.namespace + "-l2rt.*:" + " |sed 's/:/ /g'"
        cmd3 = "kubectl describe pods " + self.pod + " -n " + self.namespace + \
               "|grep -i ctr-" + self.namespace + "-l2hi.*:" + " |sed 's/:/ /g'"
        cmd4 = "kubectl describe pods " + self.pod + " -n " + self.namespace + \
               "|grep -i ctr-" + self.namespace + "-l1hi.*:" + " |sed 's/:/ /g'"
        self.container_l2rt = self.exec_get_output(cmd2, 'vDU')
        self.container_l2hi = self.exec_get_output(cmd3, 'vDU')
        self.container_l1hi = self.exec_get_output(cmd4, 'vDU')
        print(self.pod, self.container_l2rt, self.container_l2hi, self.container_l1hi)
        if ((len(self.pod) and len(self.container_l2rt) and len(self.container_l2hi) and len(self.container_l1hi))
                == 0):
            print("ERROR - Check if Pod and Container is accessable")
            raise Exception("ERROR - NO Pod or Container Found.")

    def validate_namespace(self):
        cmd1 = "kubectl get namespace | grep -i \"" + self.namespace + " \" | awk {'print$1'}"
        cmd2 = "kubectl get namespace | grep -i \"" + self.namespace + " \" | awk {'print$2'}"
        if (self.exec_get_output(cmd1, 'vDU') != self.namespace or self.exec_get_output(cmd2, 'vDU') != "Active"):
            print("\n\n\tERROR - Invalid Namespace  (or)  Namespace not Active\n\n")
            sys.exit()

    def get_pod_status(self):
        Restart = "0"
        cmd = "kubectl get pod -n " + self.namespace + " | awk {'print$1'}"
        Pod_List = self.exec_get_output(cmd, 'vDU')
        Pod_List = Pod_List.split('\n')
        del Pod_List[0]
        for _ in Pod_List:
            cmd = "kubectl get pod -n " + self.namespace + " | grep -i " + _ + " | tr -s ' '"
            element = self.exec_get_output(cmd, 'vDU')
            element = element.split(' ')
            container = element[1]
            container = container.split('/')
            if (element[2] != "Running" or element[3] != Restart or container[0] != container[1]):
                print(self.exec_get_output("kubectl get pod -n " + self.namespace, 'vDU'))
                raise Exception("ERROR - POD(" + element[0] + ") OR CONTAINER IS DOWN")

    def aic_collect_journal(self, logtype):
        if (logtype != "consolidate" and logtype != "nonconsolidate"):
            raise Exception("ERROR - Argument Logtype need to be consolidate/nonconsolidate")
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        #        self.get_pod_status()
        for _ in self.object.get('Mkdir'):
            self.exec_cmd(_, "vDU")
        cmd = "kubectl get pod -n " + self.namespace + "| awk '{if (NR != 1) print $1}'"
        podlist = self.exec_get_output(cmd, 'vDU').split('\n')
        for pod in podlist:
            if (logtype == "consolidate"):
                filename = "Journal_log"
            else:
                filename = pod
            cmd = "kubectl describe pods " + pod + " -n " + self.namespace + \
                  "|grep -i ctr-" + self.namespace + ".*:" + "|sed 's/:/ /g'"
            container_list = self.exec_get_output(cmd, 'vDU')
            container_list = container_list.split("\n")
            for ctr in container_list:
                cmd = "echo \"---Start Collecting logs for POD " + pod + " container: " + ctr + \
                      "\" >>/tmp/Journal_dir/" + filename + ".txt"
                self.exec_cmd(cmd, 'vDU')
                cmd = "kubectl logs " + pod + " -c " + ctr + " -n " + self.namespace + \
                      ">>/tmp/Journal_dir/" + filename + ".txt"
                self.exec_cmd(cmd, 'vDU')
        self.sFTP_Files()

    def aic_start_l1l2_bip_mon(self, container_name):
        log_name = ""
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        #        self.get_pod_status()
        self.get_pod_container_info()
        for _ in self.object.get('Mkdir_cmd'):
            self.exec_cmd(_, "vDU")

        if (self.container_l2rt.find(container_name) >= 0):
            log_name = "bip_log_l2rt"
            container = self.container_l2rt
            cmd = self.object.get('Cmd_enable_l2rt')
            #          #####  Commented as below cmd is not working on l2rt   ####
            #            Tmp_cmd = "kubectl -n " + self.namespace + " exec -it " + self.pod + " -c " + container + \
            #                      " -- dpdk-cli show port table | grep -i BIP| awk '{print $1}'"
            #            BIP_port = self.exec_get_output(Tmp_cmd, 'vDU')
            BIP_port = "0"
            cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
            cmd[2][1] = cmd[2][1].replace("Var_namespace", self.namespace).replace("Var_pod", self.pod)
            cmd[2][1] = cmd[2][1].replace("Var_container", container)
            cmd[6][1] = cmd[6][1].replace("Var_bip_port_num", BIP_port)

        if (self.container_l2hi.find(container_name) >= 0):
            log_name = "bip_log_l2hi"
            container = self.container_l2hi
            cmd = self.object.get('Cmd_enable_l1hi_l2hi')

        if (self.container_l1hi.find(container_name) >= 0):
            log_name = "bip_log_l1hi"
            container = self.container_l1hi
            cmd = self.object.get('Cmd_enable_l1hi_l2hi')

        if (log_name == "bip_log_l2hi" or log_name == "bip_log_l1hi"):
            Tmp_cmd = "kubectl -n " + self.namespace + " exec -it " + self.pod + " -c " + container + \
                      " -- dpdk-cli show port table | grep -i BIP| awk '{print $1}'"
            BIP_port = self.exec_get_output_timeout(Tmp_cmd, 'vDU')
            cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
            cmd[2][1] = cmd[2][1].replace("Var_namespace", self.namespace).replace("Var_pod", self.pod)
            cmd[2][1] = cmd[2][1].replace("Var_container", container)
            cmd[6][1] = cmd[6][1].replace("Var_bip_port_num", BIP_port)

        self.expect_list(cmd, 'vDU')

    def aic_stop_collect_l1l2_bip_mon(self, container_name):
        log_name = ""
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        #        self.get_pod_status()
        self.get_pod_container_info()
        if (self.container_l2rt.find(container_name) >= 0):
            log_name = "bip_log_l2rt"
            bip_log1 = "l1biprt"
            container = self.container_l2rt
            cmd = self.object.get('Cmd_disable_l2rt')
            cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
            cmd[2][1] = cmd[2][1].replace("Var_namespace", self.namespace).replace("Var_pod", self.pod)
            cmd[2][1] = cmd[2][1].replace("Var_container", container)
            cmd[9][1] = cmd[9][1].replace("Var_namespace", self.namespace).replace("Var_pod", self.pod)
            cmd[9][1] = cmd[9][1].replace("Var_bip_logs", log_name).replace("Var_container", container)
            cmd[9][1] = cmd[9][1].replace("Var_file", bip_log1)

        if (self.container_l2hi.find(container_name) >= 0):
            log_name = "bip_log_l2hi"
            bip_log1 = "l2biphi"
            container = self.container_l2hi
            cmd = self.object.get('Cmd_disable_l1hi_l2hi')

        if (self.container_l1hi.find(container_name) >= 0):
            log_name = "bip_log_l1hi"
            bip_log1 = "l1bipl1"
            container = self.container_l1hi
            cmd = self.object.get('Cmd_disable_l1hi_l2hi')

        if (log_name == "bip_log_l2hi" or log_name == "bip_log_l1hi"):
            cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
            cmd[2][1] = cmd[2][1].replace("Var_namespace", self.namespace).replace("Var_pod", self.pod)
            cmd[2][1] = cmd[2][1].replace("Var_container", container)
            cmd[9][1] = cmd[9][1].replace("Var_namespace", self.namespace).replace("Var_pod", self.pod)
            cmd[9][1] = cmd[9][1].replace("Var_bip_logs", log_name).replace("Var_container", container)
            cmd[9][1] = cmd[9][1].replace("Var_file", bip_log1)
        self.expect_list(cmd, 'vDU')
        self.sFTP_Files()

    def aic_start_tti_mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        self.get_pod_container_info()
        cmd = self.object.get('Cmd_enable')
        cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
        cmd[2][1] = "kubectl -n " + self.namespace + " exec -it " + self.pod + " -c " \
                    + self.container_l2rt + " -- bash"
        self.expect_list(cmd, 'vDU')

    def aic_stop_collect_tti_mon(self):
        self.execute_prerequisite_cmd()
        self.validate_namespace()
        self.get_pod_container_info()
        for _ in self.object.get('Mkdir_cmd'):
            self.exec_cmd(_, "vDU")
        cmd = self.object.get('Cmd_disable')
        cmd[1][1] = cmd[1][1].replace("Var_ip_addr", self.ip)
        cmd[2][1] = "kubectl -n " + self.namespace + " exec -it " + self.pod + " -c " + \
                    self.container_l2rt + " -- bash"
        cmd[7][1] = "kubectl -n " + self.namespace + " cp " + self.pod + \
                    ":/var/eventsTrace/. -c " + self.container_l2rt + " /tmp/TTrace_dir/"
        self.expect_list(cmd, 'vDU')
        self.sFTP_Files()

    def ttitrace_decode_convert_to_readable_format(self):
        vduVersion = self.exec_get_output("helm list -n cran10|grep -i ocp-vdu| awk {'print$9'}", "vDU").split("-")[2]
        print(vduVersion)

    #        vduVersion = vduVersion.split("-")[2]
    #        ttidecodername = "5G22R1_GNB_000" + vduVersion.split(".")[0] + "_000" + vduVersion.split(".")[1] + "_00" \
    #                         + vduVersion.split(".")[2] + "_tti-dec_qemux86-64-static.txz"
    #        DownloadUrl = "wget https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local" \
    #                      "/System_Release/0.300.2035/5G22R1_GNB_0000_000300_002035_tti-dec_qemux86-64-static.txz "
    #        DownloadUrl = "wget https://artifactory-espoo1.int.net.nokia.com/artifactory/mnp5g-central-public-local" \
    #                      "/System_Release/" + vduVersion + "/" + ttidecodername
    #        print(DownloadUrl)
    #        os.system(DownloadUrl)
    # #        os.system("tar -xvf /home/ute/" + ttidecodername)
    #        os.system("tar -xvf 5G22R1_GNB_0000_000300_002035_tti-dec_qemux86-64-static.txz")

    #        my_tar = tarfile.open("/home/ute/" + ttidecodername)
    #        my_tar = tarfile.open("/home/ute/5G22R1_GNB_0000_000300_002035_tti-dec_qemux86-64-static.txz")
    #        my_tar.extractall("/home/ute/")
    #        my_tar.close()
    #        for file1 in os.listdir(self.localpath):
    #            # os.system("/home/ute/tti-dec-bin/bin/eventDecoder /home/ute/vgv/" + file1 + " excelCsv")
    #            os.system("python3 /home/ute/tti-dec-bin/TtiTraceDecoder.py /home/ute/vgv/" + file1 + " excelCsv")

    def ttitrace_untar_and_rename(self):
        for fp1 in os.listdir(self.localpath):
            my_tar = tarfile.open(self.localpath + fp1)
            my_tar.extractall(self.localpath)
            my_tar.close()
            os.remove(self.localpath + fp1)
        for fp1 in os.listdir(self.localpath):
            file1 = str(fp1.split(".")[0]) + "_" + str(fp1.split(".")[2]) + "." + str(fp1.split(".")[1])
            os.rename(self.localpath + fp1, self.localpath + file1)

    def aic_sync_meas_period(self, bypass):

        ClearFile = 'kubectl exec -n ' + self.namespace + ' ute-' + self.namespace + '-oampm-0 -c ctr-' + \
                    self.namespace + \
                    '-pmdataserver -- bash -c "rm -rf /mnt/services/SS_OAM/PMSTAT/pm_report_files/*.gz"'

        CheckFile = 'kubectl exec -n ' + self.namespace + ' ute-' + self.namespace + '-oampm-0 -c ctr-' + \
                    self.namespace + \
                    '-pmdataserver -- bash -c "ls /mnt/services/SS_OAM/PMSTAT/pm_report_files/*.gz"'
        self.exec_cmd(ClearFile, 'vDU')
        print(ClearFile)
        if bypass == 'No':
            WaitTimeInSecs = 1000
            TimeStart = datetime.now()
            TimeLapsed = 0
            time.sleep(3)
            while TimeLapsed <= int(WaitTimeInSecs):
                response = self.exec_get_output(CheckFile, 'vDU')
                if response != '':
                    print("Counter file found")
                    time.sleep(8)
                    self.exec_cmd(ClearFile, 'vDU')
                    break
                time.sleep(10)
                TimeLapsed = (datetime.now() - TimeStart).total_seconds()
                print("TimeLapsed " + str(TimeLapsed))
            if response == '' and TimeLapsed > WaitTimeInSecs:
                raise Exception("PM Counter not getting generated")


##########################################################################################################


def AIC_Start_vDU_Syslog(ipaddr, user, password, domain):
    y = AIC_Monitoring('SysLog', 'AIC', 'vDU', ipaddr, user, password, domain)
    y.aic_start_vdu_syslog()
    del y


def AIC_Stop_Collect_vDU_Syslog(vm_path, ipaddr, user, password, domain):
    x = AIC_Monitoring('SysLog', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/tmp/Syslog_dir/', localpath=vm_path)
    x.aic_stop_collect_vdu_syslog()
    del x


##########################################################################################################


def get_vDU_TargetBD_file(vm_path, ipaddr, user, password, domain):
    y = AIC_Monitoring('vDu_Target_bd', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/var/home/core/TargetBD_vDU.xml', localpath=vm_path)
    y.get_targetbd_file()
    del y


##########################################################################################################


def AIC_Start_CPIF_x2_F1_Mon(ipaddr, user, password, domain):
    y = AIC_Monitoring('CPIFMon', 'AIC', 'vCU', ipaddr, user, password, domain)
    y.aic_start_cpif_x2_F1_Mon()
    del y


def AIC_Stop_Collect_CPIF_x2_F1_Mon(vm_path, ipaddr, user, password, domain):
    x = AIC_Monitoring('CPIFMon', 'AIC', 'vCU', ipaddr, user, password,
                       domain, remotepath='/tmp/Cpif_dir/', localpath=vm_path)
    x.aic_stop_collect_cpif_x2_F1_Mon()
    del x


##########################################################################################################


def AIC_Start_CPRT_F1_Mon(ipaddr, user, password, domain):
    y = AIC_Monitoring('CPRTMon', 'AIC', 'vDU', ipaddr, user, password, domain)
    y.aic_start_cprt_F1C_Mon()
    del y


def AIC_Stop_Collect_CPRT_F1_Mon(vm_path, ipaddr, user, password, domain):
    x = AIC_Monitoring('CPRTMon', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/tmp/CPRT/', localpath=vm_path)
    x.aic_stop_collect_cprt_F1C_Mon()
    del x


##########################################################################################################


def AIC_Start_CPIF_Mon(ipaddr, user, password, domain):
    y = AIC_Monitoring('CPIF', 'AIC', 'vCU', ipaddr, user, password, domain)
    y.aic_start_cpif_Mon()
    del y


def AIC_Stop_Collect_CPIF_Mon(vm_path, ipaddr, user, password, domain):
    x = AIC_Monitoring('CPIF', 'AIC', 'vCU', ipaddr, user, password,
                       domain, remotepath='/tmp/CPRT/', localpath=vm_path)
    x.aic_stop_collect_cpif_Mon()
    del x


##########################################################################################################

def AIC_Start_L1L2_Bip_Mon(ipaddr, user, password, domain, container):
    y = AIC_Monitoring('BIPSection', 'AIC', 'vDU', ipaddr, user, password, domain)
    y.aic_start_l1l2_bip_mon(container)
    del y


def AIC_Stop_Collect_L1L2_Bip_Mon(vm_path, ipaddr, user, password, domain, container):
    x = AIC_Monitoring('BIPSection', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/tmp/biplog/', localpath=vm_path)
    x.aic_stop_collect_l1l2_bip_mon(container)
    del x


##########################################################################################################


def AIC_Start_TTI_Mon(ipaddr, user, password, domain):
    y = AIC_Monitoring('TTISection', 'AIC', 'vDU', ipaddr, user, password, domain)
    y.aic_start_tti_mon()
    del y


def AIC_Stop_Decode_Collect_TTI_Mon(vm_path, ipaddr, user, password, domain):
    y = AIC_Monitoring('TTISection', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/tmp/TTrace_dir/', localpath=vm_path)
    y.aic_stop_collect_tti_mon()
    y.ttitrace_untar_and_rename()
    #    y.ttitrace_decode_convert_to_readable_format()
    del y


def AIC_TTI_Start_Stop_Collect_timer_based(TimeInSec, vm_path):
    AIC_Start_TTI_Mon()
    print("Collecting TTI trace for " + str(TimeInSec) + "seconds")
    time.sleep(TimeInSec)
    AIC_Stop_Decode_Collect_TTI_Mon(vm_path)


##########################################################################################################


def AIC_Collect_Journal_Logs(vm_path, ipaddr, user, password, domain, logtyp):
    x = AIC_Monitoring('Journal', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/tmp/Journal_dir/', localpath=vm_path)
    x.aic_collect_journal(logtyp)
    del x


##########################################################################################################


def AIC_Sync_With_Measurement_Period(ipaddr, user, password, domain, bypass):
    x = AIC_Monitoring('Journal', 'AIC', 'vDU', ipaddr, user, password,
                       domain, remotepath='/tmp/Journal_dir/')
    x.aic_sync_meas_period(bypass)
    del x

##########################################################################################################
# if __name__ == "__main__":
#
#    AIC_Start_CPRT_F1_Mon("10.84.144.213", "core", "system123", "7-7-ute5gcloudt7sk020")
#    time.sleep(5)
#    AIC_Stop_Collect_CPRT_F1_Mon("/home/ute", "10.84.144.213", "core", "system123", "7-7-ute5gcloudt7sk020")

#    get_vDU_TargetBD_file("/home/ute/TargetBD_vDU.xml","10.58.111.162", "core", "system123", "cran1")
#    AIC_Collect_Journal_Logs("/home/ute/test1/", "10.58.111.114", "core", "system123", "cran10", "consolidate")
#    AIC_Collect_Journal_Logs("/home/ute/test1/", "10.58.111.242", "core", "system123", "cran10", "nonconsolidate")

#    AIC_Start_vDU_Syslog("10.58.111.162", "core", "system123", "cran1")
#    time.sleep(30)
#    AIC_Stop_Collect_vDU_Syslog("/home/ute/vgv/", "10.58.111.179", "core", "system123", "7-2-uteaictl2")
#    AIC_Start_CPIF_x2_F1_Mon("10.107.125.66", "core", "system123", "7-5-ute5gaic001")
#    time.sleep(30)
#    AIC_Stop_Collect_CPIF_x2_F1_Mon("/home/ute", "10.107.125.66", "core", "system123", "7-5-ute5gaic001")

#    AIC_Start_L1L2_Bip_Mon("10.58.111.242", "core", "system123", "cran10", "l2hi")
#    time.sleep(10)
#    AIC_Stop_Collect_L1L2_Bip_Mon("/home/ute", "10.58.111.242", "core", "system123", "cran10", "l2hi")

#    AIC_Start_TTI_Mon("10.58.111.242", "core", "system123", "cran10")
#    time.sleep(10)
#    AIC_Stop_Decode_Collect_TTI_Mon("/home/ute/vgv/", "10.58.111.242", "core", "system123", "cran10")
#    AIC_TTI_Start_Stop_Collect_timer_based(100)
#    AIC_Sync_With_Measurement_Period("10.58.111.114", "core", "system123", "cran8", "No")
