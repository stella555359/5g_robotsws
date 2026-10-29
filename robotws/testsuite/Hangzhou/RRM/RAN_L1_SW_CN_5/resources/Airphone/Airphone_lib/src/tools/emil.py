import os
import time
import re

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from common_lib import common_lib
from cm import cm

os_obj = OperatingSystem()
builtin_obj = BuiltIn()
comm_obj = common_lib()
gnb1_mplane_ip = '10.0.1.2'
gnb2_mplane_ip = '10.0.1.3'


class capture_emil_base(object):
    def __init__(self, alias):
        self._setup_capture_emil_flag = False
        self.alias = alias
        self.remote_host = None
        self.emil_docker_compose_file = "docker-compose.yml"
        self.emil_start_script = "emil_start_cmd.txt"
        self.capture_emil_shell_script_path = os.path.join(os.path.dirname(__file__), "emil")
        self.gnb2_emil_path = "/home/ute/gnb2_emil"

    def _setup_capture_emil(self):
        if not self._setup_capture_emil_flag:
            self._setup_capture_emil_flag = True
            self.cm_obj = cm()

    def execute_cmd_on_gnb(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_gnb(cmd)
        else:
            return comm_obj.execute_cmd_on_gnb2(cmd)

    def execute_cmd_on_pc(self, cmd):
        if self.alias == "gnb1":
            return comm_obj.execute_cmd_on_pc(cmd, timeout='60')
        else:
            return comm_obj.execute_cmd_on_pc_gnb2(cmd, timeout='60')

    def _check_the_docker_status(self, status='healthy', timeout=240, interval_t=10):
        builtin_obj.log(
            "Debug: Check the docker status:{}".format(status))
        retry_times = timeout / interval_t
        while retry_times > 0:
            result = self.execute_cmd_on_pc("sudo docker ps|grep condor-worker-1")
            if status in result:
                break
            else:
                time.sleep(interval_t)
                retry_times = retry_times-1
        else:
            raise Exception("failed to check docker: {}".format(result))

    def _start_docker(self, emil_log_dir):
        builtin_obj.log(
            "step: Pull docker image and start condor container")
        cmd = 'sudo docker stop $(sudo docker ps -aq);sudo docker rm $(sudo docker ps -aq);' \
              'sudo docker rmi $(sudo docker images -q)'
        self.execute_cmd_on_pc("{}".format(cmd))
        local_time = time.strftime(
            '%Y%m%d-%H%M%S', time.localtime())
        start_docker_log = 'sudo docker logs -t --since="{}" condor-worker-1 > {}'.format(local_time,
                                                                                          emil_log_dir)
        self.execute_cmd_on_pc("{}".format(start_docker_log))
        cmd = 'sudo docker-compose -f {}/{} kill; sudo rm -rf /home/sharedvolume'.format(
            self.capture_emil_shell_script_path, self.emil_docker_compose_file)
        self.execute_cmd_on_pc("{}".format(cmd))
        cmd = 'sudo mkdir /home/sharedvolume; sudo ln -s /home/sharedvolume /sharedvolume;' \
              'sudo chown -R ute:ute /home/sharedvolume; mkdir -p /sharedvolume/condor;' \
              'sudo docker volume create --name=sack-volume'
        self.execute_cmd_on_pc("{}".format(cmd))
        start_cmd = 'sudo docker-compose -f {}/{} up -d'.format(self.capture_emil_shell_script_path,
                                                                self.emil_docker_compose_file)
        self.execute_cmd_on_pc("{}".format(start_cmd))
        self._check_the_docker_status()

    def _start_emil_script(self, emil_log_dir):
        local_time = time.strftime(
            '%Y-%m-%dT%H:%M:%S', time.localtime())
        emil_cmd_script_path = self.capture_emil_shell_script_path + '/' + 'emil_start_cmd.txt'
        start_emil_cmd_path = emil_log_dir + '/' + '{}_emil_start_cmd.txt'.format(self.alias)
        builtin_obj.log(
            "GNB alias: {}".format(self.alias))
        if self.alias == "gnb1":
            mplane_ip = gnb1_mplane_ip
            os_obj.copy_file(emil_cmd_script_path, start_emil_cmd_path)
            self.execute_cmd_on_pc("sed -i 's/10.0.1.2/{}/g' {}".format(gnb1_mplane_ip,
                                                                        start_emil_cmd_path))
            cmd = os_obj.get_file("{}/{}_emil_start_cmd.txt".format(emil_log_dir, self.alias))
            result = self.execute_cmd_on_pc(cmd)
        else:
            mplane_ip = gnb2_mplane_ip
            cmd = 'cp {} {}'.format(emil_cmd_script_path, start_emil_cmd_path)
            self.execute_cmd_on_pc(cmd)
            self.execute_cmd_on_pc("sed -i 's/10.0.1.2/{}/g' {}".format(gnb2_mplane_ip,
                                                                        start_emil_cmd_path))
            cmd = ("cat {}/{}_emil_start_cmd.txt".format(emil_log_dir, self.alias))
            cmd1 = self.execute_cmd_on_pc(cmd)
            result = self.execute_cmd_on_pc(cmd1)
            builtin_obj.log(
                "Debug: GNB2 emil start status {}".format(result))
        builtin_obj.log(
            "Debug: start cmd status {}".format(result))
        time.sleep(2)
        cmd = 'netstat -an|grep 15067'
        result = self.execute_cmd_on_gnb(cmd)
        builtin_obj.log(
            "Debug: the status of netstat 15067 on GNB {}".format(result))
        cmd = 'sudo docker logs -t --since="{}" condor-worker-1 > {}/docker_log_start.txt'.format(
            local_time, emil_log_dir)
        self.execute_cmd_on_pc(cmd)
        if 'ESTABLISHED' not in result:
            raise Exception("check the netstat failed: {}".format(result))

    def _start_capture_emil_log_by_script(self, emil_log_dir):
        self._setup_capture_emil()
        result = self.execute_cmd_on_pc("sudo docker ps|grep condor-worker-1")
        builtin_obj.log(
            "Debug: The docker status: {}".format(result))
        pattern = re.compile(r"Up \d+\s(\S+)\s\(healthy\)")
        up_time = pattern.findall(result)
        if 'healthy' not in result or up_time and 'day' in up_time[0]:
            reboot_docker_flag = 1
        else:
            reboot_docker_flag = 0
        if reboot_docker_flag:
            self._start_docker(emil_log_dir)
        self._start_emil_script(emil_log_dir)

    def start_to_capture_emil_log(self, tag):
        builtin_obj.log("step: start emil")
        self._setup_capture_emil()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        if self.alias == 'gnb2':
            cmd = "sudo ifconfig eth3:enb_emil 10.0.1.200/24 up"
            self.execute_cmd_on_pc(cmd)
            save_log_dir = self.gnb2_emil_path
            cmd = "rm {}/gnb_emil_logs".format(save_log_dir)
            cmd = "mkdir -p {}/gnb_emil_logs".format(save_log_dir)
            self.execute_cmd_on_pc(cmd)
        emil_log_dir = "{}/gnb_emil_logs".format(save_log_dir, tag) \
            if 'startup' in tag else "{}/gnb_emil_logs/".format(save_log_dir)
        self._start_capture_emil_log_by_script(emil_log_dir)

    def stop_to_capture_emil_log(self, tag):
        self._setup_capture_emil()
        save_log_dir = comm_obj._get_save_log_dir(self.alias)
        emil_log_dir = "{}/{}_logs/gnb_emil_logs/".format(save_log_dir, tag) \
            if 'startup' in tag else "{}/gnb_emil_logs/".format(save_log_dir)
        builtin_obj.log("step: stop emil")
        cmd = 'curl -X DELETE http://172.21.0.11:10009/dataCollections/CPlane_Traces_5G-10.0.1.2-172.21.0.11'
        result = self.execute_cmd_on_pc(cmd)
        builtin_obj.log(
            "debug: Stop emil result: {}".format(result))
        builtin_obj.log(
                "Step: Collect emil start")
        cmd = 'find /sharedvolume/condor |grep .5gm'
        result = self.execute_cmd_on_pc(cmd)
        print(result.split('\n'))
        if '5gm' in result:
            for file in result.split():
                if self.alias == "gnb2":
                    cmd = 'mv {} {}/gnb_emil_logs/'.format(file.split()[0], self.gnb2_emil_path)
                    self.execute_cmd_on_pc(cmd)
                else:
                    os_obj.move_file(file.split()[0], emil_log_dir)
            if self.alias == "gnb2":
                ute1_ip = builtin_obj.get_variable_value('${testline_ip}')
                builtin_obj.log(
                    "Step: Collect emil done on gnb2 {} {} {}".format(self.gnb2_emil_path, ute1_ip, emil_log_dir))
                cmd = 'scp -r {} {}:{}'.format(self.gnb2_emil_path, ute1_ip, emil_log_dir)
                self.execute_cmd_on_pc(cmd)
            builtin_obj.log(
                "Step: Collect emil done")
        else:
            raise Exception("No emil log in /sharedvolume/condor")


class capture_emil_gnb1(object):

    def __init__(self):
        alias = "gnb1"
        self.capture_emil_base_instance_1 = capture_emil_base(alias)

    def start_to_capture_emil_log(self, tag=''):
        self.capture_emil_base_instance_1.start_to_capture_emil_log(tag)

    def stop_to_capture_emil_log(self, tag=''):
        self.capture_emil_base_instance_1.stop_to_capture_emil_log(tag)


class capture_emil_gnb2(object):
    def __init__(self):
        alias = "gnb2"
        self.capture_emil_base_instance_2 = capture_emil_base(alias)

    def _setup_emil_gnb2(self):
        self.capture_emil_base_instance_2.bts_host = builtin_obj.get_variable_value('${GNB2_IP}')  # NG IP
        self.capture_emil_base_instance_2.remote_host = builtin_obj.get_variable_value('${GNB2_PC_IP}')

    def start_to_capture_emil_log_GNB2(self, tag=''):
        self._setup_emil_gnb2()
        self.capture_emil_base_instance_2.start_to_capture_emil_log(tag)

    def stop_to_capture_emil_log_GNB2(self, tag=''):
        self._setup_emil_gnb2()
        self.capture_emil_base_instance_2.stop_to_capture_emil_log(tag)


class capture_emil(capture_emil_gnb1, capture_emil_gnb2):
    def __init__(self):
        capture_emil_gnb1.__init__(self)
        capture_emil_gnb2.__init__(self)


if __name__ == "__main__":
    capture_emil_obj = capture_emil()
    help(capture_emil)
