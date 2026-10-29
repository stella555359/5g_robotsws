# pylint: skip-file
# -*- coding: utf-8 -*-
""" All the services supplied by tdd_bts
:copyright: Nokia
:author: qi rengang (NSN - CN/Shanghai)
:contact: rengang.qi@alcatel-sbell.com.cn
"""
import os
import re
import six
import signal
import time
import subprocess
import logging
from contextlib import contextmanager
import pkg_resources
from tak_config import *
from tak_core import tak_core
from ute_common_store import *
from ute_fsmaccess import ute_fsmaccess


class LocalCommand(object):

    def __init__(self):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)

    def _write_and_read_result(self, cmd, timeout):
        self._log.debug(cmd)
        proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
        return self._wait_for_execution_result(proc, timeout)

    def _wait_for_execution_result(self, proc, timeout):
        begin_time = time.time()
        while int(time.time() - begin_time) < timeout:
            if self._is_process_working(proc):
                continue
            return self._read_process_data(proc)
        proc.send_signal(signal.SIGINT)
        proc.send_signal(signal.SIGQUIT)
        raise Exception("Execute command fail within {}".format(timeout))

    def _read_process_data(self, proc):
        stdout, stderr = proc.communicate()
        rc = proc.poll()
        return stdout, stderr, rc

    def _is_process_working(self, proc):
        rc = proc.poll()
        return True if rc is None else False

    def _show_debug_log(self, log):
        """show log if it is not null"""
        if log != "":
            self._log.debug(log.strip())

    def write_and_read_until_regex(self, cmd, regex, timeout):
        """write command and wait command execute finish"""
        err, out, rc = self._write_and_read_result(cmd, timeout)
        err = self._change2string(err)
        out = self._change2string(out)
        self._show_debug_log(out)
        self._show_debug_log(err)
        if rc != 0:
            raise Exception("Command execute fail!")
        if regex not in out:
            raise Exception("{} execute result is fail!".format(cmd))
        return out

    def execute_cmd(self, cmd):
        """execute commad"""
        out, err, rc = self._write_and_read_result(cmd, timeout=60)
        out = self._change2string(out)
        err = self._change2string(err)
        self._show_debug_log(out)
        self._show_debug_log(err)
        if rc != 0:
            raise Exception("Command execute fail.")
        return out, err, rc

    def _change2string(self, data):
        if not isinstance(data, six.string_types):
            return data.decode('utf-8')
        return data


class SshCommand(object):

    def __init__(self, host_ip, user_name, password, prompt):
        self._log = logging.getLogger(__name__)
        self._log.setLevel(logging.DEBUG)
        self.host_ip = host_ip
        self.user_name = user_name
        self.password = password
        self.prompt = prompt

    @contextmanager
    def _sshclient(self):
        """ssh connection operation.
        """
        ssh_client = tak_core().execute(self.host_ip, self.user_name, self.password, "22", self.prompt)
        try:
            ssh_client._setup()
            yield ssh_client
        finally:
            ssh_client._teardown()

    def execute_cmd(self, cmd):
        """ssh execute command"""
        try:
            with self._sshclient() as sshclient:
                return sshclient.execute("{}\n".format(cmd))
        except Exception as e:
            self._log.debug("{} execute fail:{}".format(cmd, str(e)))
            raise Exception("Execute {} with error.".format(cmd))

    def write_and_read_until_regex(self, cmd, regex, timeout):
        """ssh execute command and read return data"""
        try:
            with self._sshclient() as sshclient:
                sshclient.write(cmd + '\r')
                return sshclient.read_until_regex(regex, timeout)
        except Exception as err:
            self._log.debug("{} write and read fail with:{}".format(cmd, str(err)))
            raise Exception("Execute {} fail.".format(cmd))

    def get_file(self, src, dst):
        """get file"""
        try:
            with self._sshclient() as sshclient:
                return sshclient.get_file(src, dst)
        except Exception as err:
            self._log.debug("Get file {} to {} fail with:{}".format(src, dst, str(err)))
            raise Exception("Get file {} to {} fail.".format(src, dst))


class ExecuteCommand(object):

    def __init__(self, host_ip,  **kwargs):
        self.host_ip = host_ip
        self.user_name = kwargs.get('username', 'ute')
        self.password = kwargs.get('password', 'ute')
        self.prompt = kwargs.get('prompt', '$')
        self._is_localhost = host_ip in ('localhost', '127.0.0.1')

    def execute_cmd(self, cmd):
        """execute command"""
        if self._is_localhost:
            return LocalCommand().execute_cmd(cmd)
        else:
            return SshCommand(self.host_ip, self.user_name, self.password, self.prompt).execute_cmd(cmd)

    def write_and_read_until_regex(self, cmd, regex, timeout=360):
        """write and wait command execute finsh"""
        if self._is_localhost:
            return LocalCommand().write_and_read_until_regex(cmd, regex, timeout)
        else:
            return SshCommand(self.host_ip, self.user_name, self.password, self.prompt).\
                write_and_read_until_regex(cmd, regex, timeout)

    def get_file(self, src, dst):
        """ get file"""
        if self._is_localhost:
            return LocalCommand().get_file(src, dst)
        else:
            return SshCommand(self.host_ip, self.user_name, self.password, self.prompt).get_file(src, dst)


class ToolPrepare(ExecuteCommand):
    """collect .h and .hpp file, change tool permission
    """

    def __init__(self, host_ip, **kwargs):
        """"init"""
        super(ToolPrepare, self).__init__(host_ip, **kwargs)
        self.rd_define_file = "ERadSwDomainLteMac.h"
        self.log_define_file = "PsFeatureLevels.hpp"
        self.tool_dir = pkg_resources.resource_filename(__name__, "resources")
        self.tool_path = os.path.join(self.tool_dir, 'macpscli')
        self.host_ip = host_ip
        self.user_name = kwargs.get('username', 'ute')
        self.password = kwargs.get('password', 'ute')
        self.host = kwargs.get('enb_ip', '192.168.255.1')
        self.ensure_pstool_existed()
        self.collect_head_files()
        # self.change_tool_permission()

    def ensure_pstool_existed(self):
        """download pstools.zip and Ttitrace.zip"""
        if self._is_dir_empty():
            sw_version = self._get_enb_sw_version()
            self._download_and_unzip_pstools(sw_version)
        if self._is_dir_empty():
            raise Exception("Pstool.zip download fail!")

    def _is_dir_empty(self):
        ret = False
        try:
            out, err, rc = self.execute_cmd("ls -A /opt/TtiTracer/pscli/ |wc -w")
            ret = False if 0 != int(out) else True
        except Exception as e:
            if "No such file or directory" in str(e):
                ret = True
        return ret

    def _get_enb_sw_version(self):
        fsm = ute_fsmaccess()
        fsm.setup_enb_fsm_access(remote_host=self.host_ip, remote_ssh_user=self.user_name,
                                 remote_ssh_pass=self.password, host=self.host)
        sw_ver = fsm.get_enb_sw_version()
        fsm.teardown_enb_fsm_access()
        return sw_ver

    def _download_and_unzip_pstools(self, sw_version):
        sw_ver = (re.sub(r'SBTS[0-9A-Z]*_', "SBTS00_", sw_version)) if "9999" or "9990" in sw_version else sw_version
        self._download_remote_file("pstools.zip", sw_ver)
        self._download_remote_file("TtiTracer.zip", sw_ver)

    def _download_remote_file(self, file_name, sw_version):
        if sw_version.split("_")[1] == "ENB":
            branch = sw_version.split("_")[0]
        else:
            branch = sw_version.split("_")[0]+"_FSM3"
        wfturl = 'https://artifactory-espoo2.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-local/build'
        link1 = "{}/{}/{}/{}_{}".format(wfturl, branch, sw_version, sw_version, file_name)
        link2 = 'http://lterel.es-si-s3-z2.eecloud.nsn-net.net/build/{}/{}_{}'.format(branch, sw_version, file_name)
        link3 = 'http://lterel.es-si-s3-z4.eecloud.nsn-net.net/build/{}/{}_{}'.format(branch, sw_version, file_name)
        for url in [link1, link2, link3]:
            if self._is_remote_file_exists(url):
                self.execute_cmd('wget -P /opt/TtiTracer/ {} --timeout 10 --tries 1 --quiet'.format(url))
                self.execute_cmd('unzip -qo /opt/TtiTracer/{}_{} -d /opt/TtiTracer/'.format(sw_version, file_name))
                self.execute_cmd("rm /opt/TtiTracer/{}_{}".format(sw_version, file_name))
                return

    def _is_remote_file_exists(self, file_link):
        wget_spider = "wget --spider {}".format(file_link)
        try:
            self.execute_cmd(wget_spider)
            return True
        except Exception as e:
            return False

    def collect_head_files(self):
        """find and copy head file to tool path"""
        log = self._find_file_path(self.log_define_file)
        rd = self._find_file_path(self.rd_define_file)
        self.execute_cmd("sudo cp {} {}/".format(log.strip(), self.tool_dir))
        self.execute_cmd("sudo cp {} {}/".format(rd.strip(), self.tool_dir))

    def change_tool_permission(self):
        """ change tool permission as executable"""
        output, err, rc = self.execute_cmd("ls {}".format(self.tool_path))
        if self.tool_path not in output:
            raise Exception("{} is not exist in {}!".format(self.tool_path, output))
        self.execute_cmd("sudo chmod 777 {}".format(self.tool_path))

    def _find_file_path(self, file_name):
        """ find file path"""
        find_cmd = 'find {} -name {}'.format('/opt/TtiTracer/', file_name)
        out, err, rc = self.execute_cmd(find_cmd)
        if out == "":
            raise Exception("{} not find in /opt/ttiTracer/".format(file_name))
        return out.split()[0]


class Macpscli(ToolPrepare):
    """This clasee for macpscli
    """

    def __init__(self, host_ip='127.0.0.1', **kwargs):
        """init"""
        super(Macpscli, self).__init__(host_ip, **kwargs)
        self.enb_ip = kwargs.get('enb_ip', '192.168.255.1')
        self.port = kwargs.get('enb_port', '15003')
        self._is_localhost = host_ip in ('localhost', '127.0.0.1')
        self._un_pw = '-u toor4nsn -w oZPS0POrRieRtu'

    def set_rad_parameter(self, condition, node_type, cell_id, parameter, value):
        """
        set rad parameter.
        :param condition: setlog or setrd
        :param node_type: node type
        :param cell_id: cell id
        :param parameter: feature id or rad name
        :param value: set value
        :return: None
        """
        if condition not in ['setlog', 'setrd']:
            self._raise_error("condition should set as one of ['setlog', 'setrd']")
        if condition == "setlog":
            ret = self._setlog(node_type, cell_id, parameter, value)
        if condition == "setrd":
            ret = self._setrd(node_type, cell_id, parameter, value)
        tool_log_name = self._get_tool_log_file_name(ret)
        self._get_tool_log_to_local(tool_log_name)
        if "result is failed" in ret:
            raise Exception("set rad parameter fail.")

    def query_rad_parameter(self, condition, node_type, cell_id, parameter):
        """
        query rad parameter
        :param condition: setlog or setrd
        :param node_type: node type
        :param cell_id: cell id
        :param parameter: feature id or rad name
        :return: query value
        """
        if condition not in ['querylog', 'queryrd']:
            self._raise_error("condition should set as one of ['querylog', 'queryrd']")
        if condition == "querylog":
            ret, tool_log_name = self._querylog(node_type, cell_id, parameter)
        if condition == "queryrd":
            ret, tool_log_name = self._queryrd(node_type, cell_id, parameter)
        self._get_tool_log_to_local(tool_log_name)
        return ret

    def _setlog(self, node_type, cell_id, parameter, value):
        """setlog"""
        base_cmd = "{} setlog -f {} -l {} -n {} -c {}".format(self.tool_path, parameter, value, node_type, cell_id)
        cmd = "{} -i {} -p {} -o {} {}".format(base_cmd, self.enb_ip, self.port, test_log_directory(), self._un_pw)
        return self.write_and_read_until_regex(cmd, "Set FID parameters finished")

    def _setrd(self, node_type, cell_id, parameter, value):
        """set rad"""
        base_cmd = "{} setrd -r {} -v {} -n {} -c {}".format(self.tool_path, parameter, value, node_type, cell_id)
        cmd = "{} -i {} -p {} -o {} {}".format(base_cmd, self.enb_ip, self.port, test_log_directory(), self._un_pw)
        return self.write_and_read_until_regex(cmd, "Set RD parameters finished")

    def _querylog(self, node_type, cell_id, parameter):
        """query log"""
        base_cmd = "{} querylog -f {} -n {} -c {}".format(self.tool_path, parameter, node_type, cell_id)
        cmd = "{} -i {} -p {} -o {} {}".format(base_cmd, self.enb_ip, self.port, test_log_directory(), self._un_pw)
        out = self.write_and_read_until_regex(cmd, "Query FID parameters finished")
        return self._return_query_result(out)

    def _queryrd(self, node_type, cell_id, parameter):
        """query rd"""
        base_cmd = "{} queryrd -r {} -n {} -c {}".format(self.tool_path, parameter, node_type, cell_id)
        cmd = "{} -i {} -p {} -o {} {}".format(base_cmd, self.enb_ip, self.port, test_log_directory(), self._un_pw)
        out = self.write_and_read_until_regex(cmd, "Query RD parameters finished")
        return self._return_query_result(out)

    def _return_query_result(self, result):
        """return result"""
        dic = {}
        log_file_name = ''
        for line in result.split('\n'):
            if "=" in line:
                key = line.split("|")[-1].split(":")[0].strip()
                dic[key] = line.split("=")[-1].strip()
            if "Log file name:" in line:
                log_file_name = line.split(":")[-1].strip()
        return dic, log_file_name

    def _get_tool_log_file_name(self, result):
        for line in result.split('\n'):
            if "Log file name:" in line:
                return line.split(":")[-1].strip()
        return ""

    def _get_tool_log_to_local(self, tool_log_name):
        if tool_log_name == "":
            return
        tool_log_path = "{}{}".format(test_log_directory(), tool_log_name)
        if not self._is_localhost:
            local_path = os.path.join(test_log_directory(), 'remote/')
            if not os.path.exists(local_path):
                os.makedirs(local_path)
            return self.get_file(tool_log_path, local_path)

    def _raise_error(self, msg):
        """raise error"""
        raise Exception(msg)
