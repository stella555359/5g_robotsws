# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Chen Jin Emily
:contact: jin_emily.chen@nokia.com
:maintainer: I_MN_RAN_L2_SW_3_CN_SG9_TA_GMS
:contact: i_mn_ran_l2_sw_3_cn_sg9_ta@internal.nsn.com
"""
import re
import os
import logging as log
from ute_fsmaccess import ute_fsmaccess
from robot.utils import timestr_to_secs
from .common_xml import CommonXML


class CounterControl(object):
    """enable bts ssh and rdport"""

    def _get_current_bts_time(self, remote_host):
        """get current time in bts through send "date" command to bts
        | Return | time_str |
        kwargs optional parameters:
            1, host, bts ip, default is fcmd ip.
        Example
        | get_current_bts_time |
        """

        obj = ute_fsmaccess()
        obj.setup_enb_fsm_access(prompt=' >', fallback_prompt='#', remote_host=remote_host)
        ret = obj.execute_command_on_enb(cmd='date "+%Y-%m-%d %H:%M:%S"')
        log.info("time is %s" % ret)
        obj.teardown_enb_fsm_access()

        re_result = re.search(
            "(\\d{4}-\\d{2}-\\d{2} \\d{2}\\:\\d{2}\\:\\d{2})", ret)
        if re_result:
            time_str = re_result.group(1)
            return time_str
        raise Exception('The infomation do not include time')

    def get_counter_file_remaining_time(self, counter_refresh_period="15min", **kwargs):
        """calculate next counter file generated remaining time.
        :param counter_refesh_period: counter file refresh period default is 15 minutes

        :return: time string | #unit seconds

        """
        remote_host = kwargs.get('remote_host', None)
        counter_refresh_period = timestr_to_secs(counter_refresh_period) / 60
        time_str = self._get_current_bts_time(remote_host=remote_host)
        temp_list = time_str.split(":")
        counter_refresh_period = int(counter_refresh_period)
        return (counter_refresh_period -
                int(temp_list[1]) % counter_refresh_period) * 60 - int(temp_list[2]) + 80

    def _get_value(self, e):
        return int(e.text)

    def get_counter_value_from_counter_file(self,
                                            counter_file,
                                            counter_id,
                                            cell_id=None,
                                            cmcc_cmnc=None,
                                            counter_index=-1):
        """get counter value from given counter file

        :param counter_file: source counter file
        :param counter_id: counter id that like M8XXXX
        :param cell_id: cell_id in counter file.
        :param counter_index: the position of counter in counter file.

        :return: counter value

        """
        counter_index = int(counter_index)
        countervalue = []
        xml = CommonXML(counter_file)
        if cell_id is None and cmcc_cmnc is None:
            xpath = "//%s" % counter_id
            elements = xml.get_elements(xpath)
            countervalue = list(map(self._get_value, elements))
        elif cell_id and (cmcc_cmnc is None):
            xpath = "//*[contains(text(), 'LNCEL-%s')]/../..//%s" % \
                (cell_id, counter_id)
            elements = xml.get_elements(xpath)
            countervalue = list(map(self._get_value, elements))
        elif cell_id and cmcc_cmnc:
            xpath = "//*[contains(text(), 'LNCEL-%s')]/../..//*[text()='PLMN-PLMN/%s']/../..//%s" % \
                (cell_id, cmcc_cmnc, counter_id)
            elements = xml.get_elements(xpath)
            countervalue = list(map(self._get_value, elements))
        else:
            raise Ecxception('Please check the arguments!')
        log.info("counter file '%s' : xpath '%s' value is '%s'" %
                 (counter_file, xpath, countervalue))
        return countervalue[counter_index]

    def _get_timestamp_in_latest_file(self, file_list, suffix):
        rep = 'PM\\.BTS-\\d+\\.(\\d{8}\\.\\d{6})\\..*\\..*%s' % suffix
        log.info(rep)
        try:
            return list(filter(None, [re.match(rep, item).groups()[0] for item in file_list]))
        except Exception as e:
            log.debug(str(e))
            raise Exception("Don't find the counter file as the format of {}".format(rep))

    def _get_latest_file_from_file_list(self, file_list, suffix):
        time_tag = self._get_timestamp_in_latest_file(file_list, suffix)
        latest_file = None
        for item in file_list:
            if max(time_tag) in item and '.xml.{}'.format(suffix) in item:
                return item
            if max(time_tag) in item:
                latest_file = item
        if latest_file is not None:
            return latest_file
        else:
            raise Exception("Analyze the timestamp of PM counter file Fail!")

    def _unzip_pm_counter_file(self, counter_file, suffix):
        uncompress_dic = {'xz': 'xz -d', 'gz': 'gunzip'}
        if suffix == 'xz' or suffix == 'gz':
            cmd = "{} {} -k -f".format(uncompress_dic[suffix], counter_file)
            os.system(cmd)
        else:
            raise Exception('Uncompress {} format is not supported, please creat a jira to realize.'.format(suffix))
        basename, postfix = os.path.splitext(counter_file)
        if os.path.isfile(basename):
            return basename
        else:
            raise Exception("Decompression {} fail!".format(counter_file))

    def _execute_fsm_command(self, fsm, cmd):
        try:
            return fsm.execute_command_on_enb(cmd, return_rc=True)
        except Exception as e:
            log.info(e)
            return ('', 1)

    def _get_pm_counter_source_path(self, fsm, source_path):
        source_path_dic = {'/tmp/': '/tmp/bts/', '/tmp/bts/': '/tmp/'}
        ret = self._execute_fsm_command(fsm, 'ls {}|grep PM.BTS'.format(source_path))
        if ret[1] == 1:
            ret = self._execute_fsm_command(fsm, 'ls {}|grep PM.BTS'.format(source_path_dic[source_path]))
            if ret[1] == 1:
                raise Exception("Do not get pmcounter file. 'ls' resulte is {}".format(ret))
            return source_path_dic[source_path]
        return source_path

    def _get_pm_counter_suffix(self, fsm, source_path):
        ret = fsm.execute_command_on_enb('ls {}|grep PM.BTS'.format(source_path), return_rc=True)
        return ret[0].split()[0].split('.')[-1]

    def _try_get_pm_counter_file_in_different_path_with_different_suffix(self, fsm, source_path, suffix):
        cmd = "ls {}|grep PM.BTS|grep .{}".format(source_path, suffix)
        out = fsm.execute_command_on_enb(cmd, return_rc=True)
        log.debug("command :{},result:{}".format(cmd, out))
        if out[1] == 1:
            raise Exception("Do not get PM counter file.")
        return out

    def _update_path_and_suffix(self, fsm, source_path, suffix):
        if source_path in ['/tmp/', '/tmp/bts/']:
            source_path = self._get_pm_counter_source_path(fsm, source_path)
            log.info("PM counter file create in {}".format(source_path))
        if suffix in ['xz', 'gz']:
            suffix = self._get_pm_counter_suffix(fsm, source_path)
            log.info("PM counter file suffix is '{}'".format(suffix))
        return source_path, suffix

    def download_latest_pmcounter(self, local_path, **kwargs):
        """download pmcounter file from enb
        :param string local_path: pm counter save path

        :Supported source path parameter are available via kwargs:
            * **source_path**      (string)  -  the source path in enb that counter file exist
            * **host**             (string)  -  enb lmp ip  eg. 192.168.255.1
            * **remote_host**      (string)  -  remote pc ip address
            * **suffix**           (string)  -  the file suffix of pm counter file

        """
        host = kwargs.get('host', '192.168.255.1')
        remote_host = kwargs.get('remote_host', None)
        source_path = kwargs.get('source_path', '/tmp/bts/')
        suffix = kwargs.get('suffix', 'xz')
        fsm = ute_fsmaccess()
        fsm.setup_enb_fsm_access(prompt=' >', fallback_prompt='#', host=host, remote_host=remote_host)
        source_path,  suffix = self._update_path_and_suffix(fsm, source_path, suffix)
        out = self._try_get_pm_counter_file_in_different_path_with_different_suffix(fsm, source_path, suffix)
        latest_file = self._get_latest_file_from_file_list(str(out[0]).split(), suffix)
        destination = fsm.get_enb_file(source='{}{}'.format(source_path, latest_file), destination=local_path)
        fsm.teardown_enb_fsm_access()
        return self._unzip_pm_counter_file(destination, suffix)
