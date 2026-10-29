import os
import re
from subprocess import Popen, check_output
import tempfile
import time
import tarfile
from taf.transport.ssh import ssh
import yaml
from smtplib import SMTP
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from jinja2 import Environment, FileSystemLoader
from robot.api import logger
from robot.libraries.BuiltIn import BuiltIn
import ssl


class CommandExecutor():
    def __init__(self):
        self.stdout = ''
        self.stderr = ''
        self.rc = ''

    def _check_timeout(self, proc, timeout):
        current_time = initial_time = time.time()
        while (current_time - initial_time) < timeout:
            if proc.poll() is not None:
                return True
            time.sleep(0.5)
            current_time = time.time()
        return False

    def execute_cmd(self, cmd, timeout=600):
        self._clear()
        std_f = tempfile.NamedTemporaryFile()
        std_err_f = tempfile.NamedTemporaryFile()
        print("Executing the cmd: \n {}\n".format(cmd))
        proc = Popen(['/bin/bash', '-c', cmd], stdout=std_f, stderr=std_err_f, bufsize=0)
        timeout_flag = self._check_timeout(proc, timeout)
        std_f.seek(0)
        std_err_f.seek(0)
        self.stdout = std_f.read()
        self.stderr = std_err_f.read()
        self.rc = proc.returncode
        if timeout_flag:
            print("cmd executed successfully\n Output:\n {} \n\n".format(self.stdout))
        else:
            print("cmd execution failed\n Output:\n {} executed failed\n\n".format(self.stdout))
            raise Exception("cmd : {} failed".format(cmd))
        print("Return code of cmd {} is : {}\n".format(cmd, self.rc))
        if self.rc > 0:
            print("Possible that cmd failed !!!! Please check !!!!")
            print("Error seen :", self.stderr.decode("utf-8"))
        return self.stdout.decode("utf-8"), self.stderr.decode("utf-8"), int(self.rc)

    def _clear(self):
        self.stdout = ''
        self.stderr = ''
        self.rc = ''


class APCrashDetection():
    def __init__(self):
        self.cmd_exec = CommandExecutor()
        self.ap_crash_regex = 'grep -ai "192.168.200" {} | ' \
                              'grep -ai -e "Please contact the owner" ' \
                              '-e "EU name" -e "Program terminated with signal SIGSEGV"'
        self.wts_crash_regex = 'grep -ai "CRASH OCCURED" {}/*.log'
        self.crash_report = {}
        self.ssh = ssh()
        self.ap_build = self.get_ap_build_info()
        self.gnb_build = self.get_gnb_build_info()

    def get_ap_build_info(self):
        ap_build_id = ''
        ap_build_id = os.environ.get("LOAD_ID", '')
        if ap_build_id != '':
            print("AP Build :", ap_build_id)
            return ap_build_id
        try:
            self.ssh.connect_to("192.168.200.1", 'toor4nsn', 'oZPS0POrRieRtu', alias='AP')
            ssh_output = self.ssh.execute('/ffs/run/Target*xml', connection='AP')
            ap_build = re.findall('4_\d+_\d+', ssh_output)[0]  # noqa
            ap_build_id = ".".join([str(int(i)) for i in ap_build.split("_")])
            self.ssh.disconnect(connection='AP')
        except Exception as e:
            print("AP connection failed with exception : ", str(e))
        print("AP Build :", ap_build_id)
        return ap_build_id

    def get_gnb_sw_version(self):
        gnb_build = ''
        try:
            self.ssh.connect_to("192.168.255.1", 'toor4nsn', 'oZPS0POrRieRtu', alias='AP')
            ssh_output = self.ssh.execute('/ffs/run/Target*xml', connection='AP')
            gnb_build = re.findall('SBTS.*_\d+', ssh_output)[0]  # noqa
            trunk_flag = "true" if '_ENB_9999' else "false"
            gnb_build = "SBTS00_"+"_".join(gnb_build.split("_")[1:]) if trunk_flag == "true" else gnb_build
            self.ssh.disconnect(connection='AP')
        except Exception as e:
            print("gNB connection failed with exception : ", str(e))
        print("gnb Build :", gnb_build)
        return gnb_build

    def get_gnb_build_info(self):
        gnb_build_id = os.environ.get("GNB_BUILD_ID", '')
        gnb_build_id = os.environ.get("ENB_BUILD", '') if gnb_build_id == '' else gnb_build_id
        gnb_build_id = self.get_gnb_sw_version() if gnb_build_id == '' else gnb_build_id
        print("GNB Build :", gnb_build_id)
        return gnb_build_id

    def get_hostname(self):
        hostname = check_output("hostname", shell=True)
        hostname = hostname.decode('UTF-8')
        hostname = hostname.strip()
        return hostname.replace("-", "_")

    def airphone_crash_detection(self, ap_path):
        ap_output = self.check_crash_in_ap(ap_path)
        wts_output = self.check_crash_in_wts()
        if ap_output != '' or wts_output != '':
            print("Crash detected in AP SW \n")
            if ap_output != '':
                self.crash_report["AP"] = ap_output
                print("AP Crash info : {}\n".format(ap_output))
                logger.warn("AP Crash info : {}\n".format(ap_output))
            if wts_output != '':
                self.crash_report["WTS"] = wts_output
                print("WTS Crash info : {}\n".format(wts_output))
                logger.warn("WTS Crash info : {}\n".format(wts_output))
            self.crash_report["AP_BUILD"] = self.ap_build
            self.crash_report["GNB_BUILD"] = self.gnb_build
            self.crash_report["build_url"] = os.environ.get("BUILD_URL", "NA")
            self.crash_report["configuration"] = os.environ.get("AP_CONFIGURATION", "NA")
            if self.crash_report["configuration"] == "NA":
                try:
                    self.crash_report["configuration"] = BuiltIn().get_variable_value('${TOPOLOGY}')
                except Exception as e:
                    print("Exception occurred : ", repr(e))
            self.crash_report["user"] = os.environ.get("BUILD_USER", "NA")
            try:
                test_mode = BuiltIn().get_variable_value('${gNB_P1_Run}')
            except Exception as e:
                print("Exception occurred : ", repr(e))
                test_mode = "false"
            self.crash_report["TESTLINE"] = self.get_hostname()
            self.publish_mail(test_mode=test_mode)
            return True
        else:
            print("No crash detected in AP preliminary log analysis\n")
            return False

    def untar_ap_syslog(self, path):
        folder_path = "/".join(path.split("/")[:-1])
        with tarfile.open(path, "r:gz") as tar:
            tar.list()
            tar.extractall(path=folder_path)

    def check_crash_in_wts(self):
        self.wts_crash_regex = self.wts_crash_regex.format("/opt/wts/latest")
        try:
            wts_output, wts_error, wts_rc = self.cmd_exec.execute_cmd(self.wts_crash_regex)
        except Exception as e:
            print("Crash search cmd failed with exception :\n{}".format(repr(e)))
        print("WTS output: {}\n\n".format(wts_output))
        return wts_output

    def check_crash_in_ap(self, path):
        self.untar_ap_syslog(path)
        folder_path = "/".join(path.split("/")[:-1])
        syslog_path = os.path.join(folder_path, "SYSLOG*")
        self.ap_crash_regex = self.ap_crash_regex.format(syslog_path)
        try:
            ap_output, ap_error, ap_rc = self.cmd_exec.execute_cmd(self.ap_crash_regex)
            print("Grep output without any known print removal : ", ap_output)
            ap_output = re.sub(r".*ueappoam_lastreboot_request.*\n", "", ap_output)
            print("Grep output after known signatures are removed : ", ap_output)
            ap_del, ap_error_del, ap_rc_del = self.cmd_exec.execute_cmd("ls -ltr {}".format(folder_path))
            ap_del, ap_error_del, ap_rc_del = self.cmd_exec.execute_cmd("rm -f {}".format(syslog_path))
            ap_del, ap_error_del, ap_rc_del = self.cmd_exec.execute_cmd("ls -ltr {}".format(folder_path))
        except Exception as e:
            print("Crash search cmd failed with exception :\n{}".format(repr(e)))
        print("AP output: {}\n\n".format(ap_output))
        return ap_output

    def generate_report(self):
        root = os.path.dirname(os.path.abspath(__file__))
        env = Environment(loader=FileSystemLoader(root))
        template = env.get_template('crash_report_mail_template.yaml')
        html_file_name = 'crash_report_mail.html'
        report_filename = os.path.join(root, html_file_name)
        print("Crash details for report :\n", self.crash_report)
        with open(report_filename, 'w') as fh:
            fh.write(template.render(crash_info=self.crash_report))
        return report_filename

    def publish_mail(self, test_mode="true"):
        mail_setting_file = os.path.dirname(os.path.abspath(__file__))
        mail_setting_file = os.path.join(mail_setting_file, "mail_settings.yaml")
        mail_settings = yaml.load(open(mail_setting_file, 'r'), yaml.SafeLoader)['MailSettings']
        smtpserver = mail_settings['General']['server']
        sender = mail_settings['General']['sender']
        message = MIMEMultipart()
        test_mode_sub = "[Test Mail]" if test_mode == "true" else ""
        subject = f"{test_mode_sub} AP Crash Report Generated"
        html_report_file = self.generate_report()
        if test_mode != 'true':
            print('Test Mode is Set to False Publish to External')
            receiver = mail_settings['External']['recepients'] + mail_settings['Internal']['recepients']
        else:
            print('Test Mode is Set to True Publish to Internal')
            receiver = mail_settings['Internal']['recepients']
        with open(html_report_file, 'r') as release_report:
            body = release_report.read()
        message['Subject'] = subject
        message['From'] = sender
        message['Reply-to'] = receiver
        message['To'] = receiver
        message.attach(MIMEText(body, "html"))
        msg_body = message.as_string()
        server = SMTP(smtpserver)
        context = ssl.SSLContext(ssl.PROTOCOL_TLSv1_2)
        context.set_ciphers('HIGH:!DH:!aNULL')
        server.starttls(context=context)
        problems = server.sendmail(sender, receiver.split(';'), msg_body)


if __name__ == "__main__":
    crash_obj = APCrashDetection()
    crash_obj.airphone_crash_detection("/home/ute/gopal/syslog/syslog_files.tgz")
