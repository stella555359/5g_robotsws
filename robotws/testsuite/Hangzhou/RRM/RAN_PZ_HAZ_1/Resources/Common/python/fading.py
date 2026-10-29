# -*- coding: utf-8 -*-
"""
Author: Yang Mengli
Contacts: mengli.yang@nokia-sbell.com
Description: this script is related to fading KW.

"""
import socket
import paramiko


class fading:
    def __init__(self):
        self.ip = None
        self.user = None
        self.password = None
        self.port = None
        self.ssh_port = None
        self.conn = None
        self.ssh_client = None

    def connect(self, ip, user, password, port=5025, ssh_port=22):
        """建立与设备的SSH连接"""
        self.ip = ip
        self.user = user
        self.password = password
        self.port = port
        self.ssh_port = ssh_port
        try:
            self.ssh_client = paramiko.SSHClient()
            self.ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            self.ssh_client.connect(self.ip, username=self.user, password=self.password, port=self.ssh_port)
            print(f"SSH连接到 {self.ip} 成功")
        except paramiko.SSHException as e:
            raise Exception(f"SSH连接失败: {str(e)}")

    def setup(self):
        """通过TCP连接设备以便进行SCPI通信"""
        try:
            self.conn = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.conn.settimeout(120)
            self.conn.connect((self.ip, self.port))
            print(f"TCP连接到 {self.ip}:{self.port} 成功")
        except socket.error as msg:
            raise Exception(f"连接到服务器失败，错误: {msg}")

    def disconnect(self):
        """断开与设备的SSH和TCP连接"""
        if self.conn:
            self.conn.close()
            print("TCP连接已断开")
            self.conn = None
        if self.ssh_client:
            self.ssh_client.close()
            print("SSH连接已断开")
            self.ssh_client = None

    def only_send_command(self, command):
        """发送SCPI命令并接收响应"""
        if not self.conn:
            raise ConnectionError("未建立TCP连接")
        # 发送SCPI命令
        self.conn.sendall(f"{command}\n".encode('ascii'))

    def send_command(self, command, retries=3):
        """发送SCPI命令并接收响应"""
        if not self.conn:
            raise ConnectionError("未建立TCP连接")

        for attempt in range(retries):
            try:
                # 发送SCPI命令
                self.conn.sendall(f"{command}\n".encode('ascii'))

                # 接收响应
                response = self.conn.recv(1024).decode('ascii').strip()

                # 确保响应不为空
                if response:
                    print(f"响应: {response}")
                    # 解析响应，假设响应是 "status_code result" 格式
                    try:
                        status_code, results = response.split(' ', 1)
                        return int(status_code), results
                    except ValueError:
                        # 如果解析失败，返回错误状态码
                        return -1, "解析响应时出错"
                else:
                    return -1, "没有收到响应"
            except socket.timeout as e:
                print(f"发送命令超时，重试 {attempt + 1}/{retries}")
                if attempt == retries - 1:
                    raise Exception(f"发送命令失败: {str(e)}")
            except socket.error as e:
                raise Exception(f"发送命令失败: {str(e)}")

    def set_scheme_director(self, mode):
        command = f"PROject:CALibrate:MODe {mode}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def load_scheme(self, project_name):
        command = f"PROject:LOAd {project_name}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def set_correcting_model(self, mode=0):
        command = f"PROject:CALibrate:MODe {mode}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def combain_external_correcting(self, filename):
        command = f"PROject:CALibrate:RECover {filename}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def set_model_file(self, sceneId, updwtype, filename):
        command = f"FACtor:LOAd:FILe {sceneId},{updwtype},{filename}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def enable_model_download(self, sceneId=0, mode=0, enableLargeScale='false'):
        command = f"FACtor:LOAd:STArt {sceneId},{mode},{enableLargeScale}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def full_start_or_pause_control(self, sceneId=0, controlMode=3):
        command = f"FACtor:PLAy:CONtrol:ALL {sceneId},{controlMode}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def part_start_or_pause_control(self, sceneId=0, Ueid=0, controlMode=3):
        command = f"FACtor:PLAy:CONtrol:UE {sceneId},{Ueid},{controlMode}"
        print(command)
        self.send_command(command)
        status_code, results = self.send_command(command)
        return status_code, results

    def remote_control(self, enable):
        command = f"SYStem:REMote:ENAble {enable}"
        print(command)
        self.send_command(command)
        # status_code = self.send_command(command)
        # return status_code

    def set_smulate_parameters(self, sceneid, type, steplimit, Timeout, loopcnt, loopmode):
        command = f"SIMulate:FADe:BASic:PARameter {sceneid},{type},{steplimit},{Timeout},{loopcnt},{loopmode}"
        print(command)
        self.only_send_command(command)
        # status_code, results = self.send_command(command)
        # return status_code, results

    def get_smulate_parameters(self, sceneid):
        command = f"SIMulate:FADe:BASic:PARameter? {sceneid}"
        print(command)
        status_code, results = self.send_command(command)
        return status_code, results


# 示例使用
if __name__ == "__main__":
    # 连接到fading PC
    controller = SCPIController()
    # 连接到设备
    controller.connect(ip="10.68.254.12", user="Administrator", password="ksw123")
    controller.setup()
    # 打开remote control
    # status_code = controller.remote_control(enable="true")
    # 获取慢衰落仿真基本参数和设置慢衰落仿真基本参数
    status_code, results = controller.get_smulate_parameters(sceneid=0)
    print(status_code)
    print(results)
    controller.set_smulate_parameters(sceneid=0, type=1, steplimit=60, Timeout=1000, loopcnt=1, loopmode=0)
    status_code, results = controller.get_smulate_parameters(sceneid=0)
    print(status_code)
    print(results)
    controller.set_smulate_parameters(sceneid=0, type=1, steplimit=80, Timeout=3000, loopcnt=1, loopmode=0)
    status_code, results = controller.get_smulate_parameters(sceneid=0)
    print(status_code)
    print(results)
    # 断开连接
    controller.disconnect()
