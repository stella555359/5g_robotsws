#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import logging
import os
import sys
import re
import time

from petbase import gv
logger = gv.logger
kw = gv.kw
gv.smf = None

msg_recv_ind = 'UlData_PrachReceiveInd'
msg_send_req = 'DlData_PdcchSendReq'
msg_recv_req = 'UlData_PucchReceiveReq'

smf_list = ['10.107.246.100', '10.110.125.68', '10.70.123.2']
# smf_list = ['10.70.123.2', '10.110.90.148', '10.110.163.34']


class pet_feature_kw(object):

    """

    本库主要包含一些feature相关的关键字，主要是有些逻辑比较复杂，直接用robot语言实现比较麻烦，
    所以我们实现在这里，供相关feature的TA case来调用；

    """

    def btslog_check_for_cb008379(self, logfile, keyword, yuzhi, min_ratio):
        """
            *FeatureID: CB008379*
             -   对btslog进行检查，
             -   查找具有关建字的行的条数，计算有关键字的行数占总行数的百分比；
             -   这个百分比不能超过指定值，否则报错

        """
        import re
        lines = open(logfile).readlines()
        lines = [x for x in lines if keyword.lower() in x.lower() and x.strip()]
        values = [x for x in re.findall(r' 4:([0-9.]*)', '\n'.join(lines)) if x.strip()]
        total_lines = len(values)
        good_lines = [x for x in values if float(x) >= float(yuzhi)]
        good_ratio = round(len(good_lines) * 100 / total_lines, 2)
        logger.info(str(values))
        logger.info('Total line: {}, good lines: {}, good_ratio: {}'.format(
            total_lines, len(good_lines), good_ratio))
        if good_ratio < float(min_ratio):
            raise Exception('Ratio check faild in btslog for keyword {} {}, {} vs {}'.format(
                            keyword, yuzhi, min_ratio, good_ratio))

    def smf_setup(self, host='10.110.90.148', username='ipsl', password='system123'):
        """
            *FeatureID: CB008379*
            -   这个feature需要和核心网的SMF打交道，因此这里提供了几个SMF打交道的关键字；
            -   此kw通过ssh连接到SMF设备；

            *通常的用法是：*
            SMF Setup
            Get UE Contenxt from SMF
            SMF Teardown

        """
        if gv.smf is None:
            from lib_devices.pet_ssh import pet_ssh
            gv.smf = pet_ssh(host=host, username=username, password=password)
            gv.smf.connect()
            gv.smf.prompt = '#'
            gv.smf.shell.settimeout(180)
            # gv.smf.read_until_prompt(prompt='B:SMF4-SUI#', timeout=5)
            gv.smf.read_until_prompt(prompt='#', timeout=5)

    def smf_teardown(self):
        """
            *FeatureID: CB008379*

            断开与SMF的连接；
        """
        if gv.smf:
            gv.smf.exec_shell_command('logout')
            gv.smf.disconnect()
            gv.smf = None

    def get_ue_context_from_smf(self, imsi):
        """
            *FeatureID: CB008379*

            获取指定IMSI的UE在SMF中的信息；

            *返回值：*
            字典, 包括以下3个字段：
            -   attached,
            -   apn,
            -   ip

        """
        for smfip in smf_list:
            self.smf_teardown()
            self.smf_setup(host=smfip, username='admin', password='admin')
            gv.logger.info(f'Try to get ue context on {smfip}')
            cmd = 'show mobile-gateway pdn pdn-context imsi {} | match v4v6 | match stmdrb'.format(imsi)
            output = gv.smf.exec_shell_command(cmd, 5).splitlines()
            output = [x for x in output if cmd not in x and 'SMF' not in x]
            self.smf_teardown()
            if output:
                for line in output:
                    print('---->    ', line)
                apn = output[0].split()[1]
                ip = output[0].split()[4].split('/')[0]
                return dict(attached=True, apn=apn, ip=ip)
            else:
                gv.logger.info(f'Could not find ue info in {smfip}')
        raise Exception('Could not find ue Context in any smf')

    def get_ue_dedicate_5qi(self, imsi):
        """
            *FeatureID: CB008379*

            获取指定IMSI的UE的Dedicated 5QI值；

            *返回值：*
            如果查询不到，返回-1

        """
        for smfip in smf_list:
            gv.logger.info(f'Try to get ue dedicated 5qi on {smfip}')
            self.smf_setup(host=smfip, username='admin', password='admin')
            cmd = 'show mobile-gateway pdn bearer-context imsi {} | match Ded'.format(imsi)
            output = gv.smf.exec_shell_command(cmd, 5).splitlines()
            self.smf_teardown()
            output = [x for x in output if 'show' not in x and 'SMF' not in x]
            if output:
                return output[0].split()[4].split('/')[0]
            else:
                pass
        return '-1'

    def switch_xiaomi_apn(self, ue, points):
        ue._enter_config_app()
        ue._touch_points(points)

    def delete_ue_context_in_smf(self, imsi):
        """
            *FeatureID: CB008379*

            到SMF上删除指定IMSI的UE的信息；

        """
        gv.smf.exec_shell_command('clear mobile-gateway pdn 1 bearer-context imsi {}'.format(imsi))
        gv.smf.exec_shell_command(
            'show mobile-gateway pdn pdn-context imsi {} detail | match sm-policies'.format(imsi))

    def get_measuredGbrLoad_100(self, pcapfile):
        cmd = ('tshark -r {} -Tfields -e frame.number -e _ws.col.Info '
               '-e "xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad" '
               '-Y "xp_dss_EnDssDlQosLoadMeasurement.measuredGbrLoad == 100"|wc -l').format(pcapfile)
        gv.logger.info(cmd)
        print(cmd)
        output = [x.strip() for x in os.popen(cmd).readlines() if x.strip()][0]
        return output

    def clear_imsi_info_in_srn(self, username='', password='', imsi_start='', imsi_end='', amf=''):
        """
            *FeatureID: CB008379*

            登录到SRN的服务器上，删除UE信息；
            -   服务器地址：https://newhorizons.srn.dyn.nesc.nokia.net
            -   此服务器需要登录，鉴权信息是域用户名和密码；
            -   然后访问https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/delete_ue_context 接口来删除
            -   如果失败，请检查其中的status code;

        """
        from requests import Session
        import urllib3
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        s = Session()
        headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 6.0; WOW64; rv:24.0) Gecko/20100101 Firefox/24.0',
                   'content-type': 'application/x-www-form-urlencoded'}
        resp = s.post('https://newhorizons.srn.dyn.nesc.nokia.net/api/aaa/auth/', proxies={},
                      data=dict(username=username, password=password), headers=headers, verify=False)
        if resp.status_code == 200:
            token = resp.json()['token']
            headers.update({'authorization': 'Bearer {}'.format(token)})
            payload = dict(imsi_start=imsi_start, imsi_end=imsi_end,
                           amf='{"amf":"SRNCN-CMMQA5-Han","smf":["SRNCN-SMF5-ZHOU"]}')
            resp2 = s.post('https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/delete_ue_context',
                           headers=headers, proxies={}, verify=False, data=payload)
            if resp2.status_code == 200:
                logging.info('Delete UE info ok')
            else:
                raise Exception('Failed to delete ue info {}'.format(resp2.status_code))
        else:
            raise Exception('Auth https://newhorizons.srn.dyn.nesc.nokia.net/api/aaa/auth/ failed, {}'.format(
                resp.status_code))

    # Feature 9007相关KW

    def get_ind_from_sherpa_log(self, sherpa_log='', indi='.03'):
        """
            *FeatureID: CB009007*

            Fearture 9007要通过gnbtool来抓sherpa log，然后用sherpa log的linux的解析工具解析，解析出来后再分析；

        sherpa_log是通过sherpa的tool转换出来的csv文件，可以作为普通文本文件处理；

        查找逻辑：
            -   1、查找包含 PdcchSendReq 和 startPDCCHSymbol=0 和 nbPDCCHSymbol= 的行；
            -   2、如果indi值为.03 查找包含xxx.03;这样的行，比如270.03; cid为270.03
            -   3、对这些行，取第一条记录，查找其中nbPDCCHSymbol=后面的值，作为S
            -   4、全文查找包含 PdschSendReq 、startPDSCHSymbol= 、 nbPDSCHSymbols= 和cid 的行；
            -   5、在4的查询结果中，查找nbPDSCHSymbols=后面的值；作为L
            -   6、根据公式，计算SLIV，公式：如果L小于等于8，sliv = (L - 1) * 14 + S, 否则：sliv = 14 * (15 - L) + 13 - S

        *返回值：*
            计算出的sliv的字符串为返回值；

        """

        logging.info('Analysis sherpa log {}, indication: {}'.format(sherpa_log, indi))
        lines = open(sherpa_log).read().splitlines()
        logging.info('All total lines : {}'.format(len(lines)))

        rs = '[0-9]+\\{};'.format(indi)
        logging.info('pattern: ' + rs)

        p1 = [x for x in lines if 'PdcchSendReq' in x and 'startPDCCHSymbol=0' in x and 'nbPDCCHSymbol=' in x]
        p1 = [x for x in p1 if re.findall(rs, x)]
        xxx = list(set([re.findall('nbPDCCHSymbol=([0-9])', x)[0] for x in p1 if re.findall(rs, x)]))
        logging.info(xxx)
        if p1:
            logging.info('Total p1 lines: {}'.format(len(p1)))
            line = p1[0]
            cid = re.findall(rs, line)[0]
            logging.info('CID: ' + cid)
            S = int(re.findall('nbPDCCHSymbol=([0-9])', line)[0])
            p2 = [x for x in lines if 'PdschSendReq' in x and 'startPDSCHSymbol=' in x]
            p2 = [x for x in p2 if 'nbPDSCHSymbols=' in x and cid in x]
            logging.info('Total p2 lines: {}'.format(len(p2)))
            if p2:
                line = p2[0]
                L = int(re.findall('nbPDSCHSymbols=([0-9])', line)[0])
            else:
                raise Exception('Could not find matched nbPDSCHSymbols')
        else:
            raise Exception('Could not find matched nbPDCCHSymbol')

        logging.info('Start Symbol Index(S): {}, Number of Consecutive Symbols(L): {}'.format(S, L))
        if L - 1 <= 7:
            sliv = (L - 1) * 14 + S
        else:
            sliv = 14 * (14 - L + 1) + (14 - 1 - S)
        logging.info('SLIV is: {}'.format(sliv))
        return str(sliv)

    def check_tti_file_for_cb009007(self, indi, sherpa_log, tti_log):
        """
            *FeatureID: CB009007*

            -   根据指定的indi值和sherpa_log, 计算sliv的值
            -   到ttilog里面查找sliv这一列：
            -   如果里面包含csiRsSchedData或者dlFdSchedData，读取这一行的sliv值，和sherpa log中计算的sliv值比较
            -   如果相同，case pass
            -   如果始终找不到，报错；

        *返回值：*
            返回Boolean值，表明有没有找到；

        """
        i_sliv = self.get_ind_from_sherpa_log(sherpa_log, indi)
        logging.info('Analysis TTI log: {}, SLIV: {}'.format(tti_log, i_sliv))
        lines = open(tti_log).read().splitlines()
        fields = [x.lower() for x in lines[0].split(',')]

        index = fields.index('sliv')
        for line in lines[1:]:
            if line.strip() and line.split(',')[0].lower() in ['csiRsSchedData'.lower(), 'dlFdSchedData'.lower()]:
                sliv = line.split(',')[index].strip()
                if sliv == i_sliv:
                    logging.info('Found SLIV={} tti log'.format(i_sliv))
                    return True
        logging.warning('Could not find SLIV={} tti log'.format(i_sliv))
        return False

    def get_sliv_from_ttilog(self, tti_log, slots):
        """
            *FeatureID: CB009007*

            -   到指定的TTI log里面搜索满足一下条件的行：
            -   1. type为csiRsSchedData或者dlFdSchedData
            -   2. slot为给定的slots里面的任意值；
            -   返回满足条件行的sliv字段的值；去重；

        *输入参数：*
        | Parameter | Type | Man. | Default | Description |
        | tti_log | string | Y | None | tti log file name |
        | slots | string | Y | None | specific slot value, such as: 3,7 |

        *返回值：*
            返回一个列表，里面是所有的满足条件的sliv的值

        """
        lines = open(tti_log).read().splitlines()
        fields = [x.lower() for x in lines[0].split(',')]
        index = fields.index('sliv')

        lines = lines[1:]
        lines = [line for line in lines if line.strip() and line.split(',')[0].lower() in [
            'csiRsSchedData'.lower(),
            'dlFdSchedData'.lower()]]
        lines = [line for line in lines if line.split(',')[fields.index('slot')] in slots.split(',')]
        slivs = list(set([line.split(',')[index].strip() for line in lines]))
        slivs = [x for x in slivs if x.strip()]
        slivs.sort()
        logging.info('Found slivs: {}'.format(slivs))
        return slivs

    def setup_sherpalog_tool(self):
        if os.path.exists('/opt/Nokia/Sherpa_5G_18'):
            logging.info('Sherpa directory already exist')
        else:
            logging.info('Sherpa directory does not exist')
            cmd = f'sudo sshpass -p qqwweeRR0- scp -r ute@{gv.file_server}:/home/ute/store/Sherpa_5G_18 /opt/Nokia/'
            gv.exec_local_command(cmd)
            gv.exec_local_command('sudo chmod +x /opt/Nokia/Sherpa_5G_18/Sherpa')
            gv.exec_local_command('sudo chmod +x /opt/Nokia/Sherpa_5G_18/Sherpa.run')

    # Feature CB000791相关KW

    def unpack_gnb_pcap_file(self, work_dire):
        """
            FeatureID: CB000791
            -   到指定的gnbtool的log目录里面，找到zip文件，把zip文件里面的.pcap文件解压出来，放到workdire里面；
            -   返回这个pcap文件的全路径；

        """
        import zipfile
        zip_filename = [x for x in os.listdir(work_dire) if x.endswith('.zip')][0]
        biplog_filename = os.path.join(work_dire, zip_filename)
        logging.info('Bip log file: {}'.format(biplog_filename))
        zfile = zipfile.ZipFile(biplog_filename)
        pcap_filename = ''
        for pname in [x for x in zfile.namelist() if x.endswith('.pcap')]:
            pcap_filename = os.path.basename(pname)
            zfile.extract(pname, work_dire)
        if not pcap_filename:
            raise Exception('Could not find pcap file in bip log file.')
        pcap_filename = os.path.join(work_dire, pname)

        logging.info('Pcap file: {}'.format(pcap_filename))
        return pcap_filename

    def _get_aggregation_level_str(self, pcap_filename=''):
        logger.info('Try to get aggregationLevel string...')
        cmd = 'sudo tshark -T pdml -r {} |grep aggregationLevel >/tmp/aggre.pdml'.format(pcap_filename)
        gv.exec_local_command(cmd)
        lines = [x for x in open('/tmp/aggre.pdml').read().splitlines() if x.strip() and 'aggregationLevel' in x]
        if lines:
            gv.aggregation_level_str = lines[0].strip().split('"')[1]
            logger.info('Found aggregation_level_str: ' + gv.aggregation_level_str)
        else:
            gv.aggregation_level_str = ''
            logger.error('Could not find aggregationLevel in pdml file.')

    def analysis_aggregation_level_for_791_a(self, pcap_filename='', outputfile=''):
        """

            FeatureID: CB000791
            -   根据给定的pcap文件，通过tshark目录，查询指定的消息的指定字段，然后返回这些指定字段的值；
            -   返回指定字段的值；交给 check_aggregation_level_for_791_a kw来进行判断；
            -   这个kw主要是服务于CB000791的第一类case；

        """
        self._get_aggregation_level_str(pcap_filename)
        if gv.aggregation_level_str == '':
            return []
        tshark_filter = 'dldata_pdcchsendreq||uldata_prachreceiveind||uldata_pucchreceivereq'
        cmd = 'sudo tshark -Tfields -e _ws.col.Info -e ' + gv.aggregation_level_str
        cmd += ' -Y "{}" -r {}'.format(tshark_filter, pcap_filename)
        cmd += ' |grep -v "decode_uci"|grep -v "CSI BEAM"|grep -v "uci_bundle"|grep -v "uci_init"'
        cmd += '|tee {}'.format(outputfile)
        logger.console(cmd)
        output = [x.strip() for x in os.popen(cmd).read().splitlines()]
        for line in output:
            logger.info('[{}]'.format(line))
        exp_list = [msg_recv_ind, msg_send_req, msg_recv_req, msg_send_req]
        summary = []
        for line in output:
            if exp_list:
                if exp_list[0] in line:
                    logger.console('Found {} [{}]'.format(exp_list[0], line))
                    summary.append(line)
                    exp_list = exp_list[1:]
            else:
                break
        logger.console('Summary: {}'.format(summary))
        if len(summary) == 4:
            logger.console('Summary1: {}'.format(summary[1].split()[-1].strip()))
            logger.console('Summary3: {}'.format(summary[3].split()[-1].strip()))
            return [summary[1].split()[-1].strip(), summary[3].split()[-1].strip()]
        else:
            logger.console('\nThe message list is not complete!')
            return []

    def analysis_aggregation_level_for_791_b(self, pcap_filename=''):
        """

            FeatureID: CB000791
            -   根据给定的pcap文件，通过tshark目录，查询指定的消息的指定字段，然后返回这些指定字段的值；
            -   返回指定字段的值；交给 check_aggregation_level_for_791_a kw来进行判断；
            -   这个kw主要服务于Feature CB000791的第二类case

        """
        self._get_aggregation_level_str(pcap_filename)
        if gv.aggregation_level_str == '':
            return ''
        tshark_filter = 'dldata_pdcchsendreq'
        cmd = 'sudo tshark -Tfields -e _ws.col.Info -e  ' + gv.aggregation_level_str
        cmd += ' -Y "{}" -r {} '.format(tshark_filter, pcap_filename)
        cmd += ' |grep -v "decode_uci"|grep -v "CSI BEAM"|grep -v "uci_bundle"|grep -v "uci_init"'
        logging.info(cmd)
        output = os.popen(cmd).read().splitlines()
        for i, line in enumerate(output):
            logging.info('index: {}, [{}]'.format(i, line))
            if msg_send_req in line:
                gv.write_console('Found {}'.format(msg_send_req))
                return output[i + 1].split()[-1].strip()
        return ''

    def check_aggregation_level_for_791_a(self, test_aggregation_level, exp_aggregation_level):
        error_msg = ''
        if test_aggregation_level == []:
            error_msg = 'Failed to find needed message, case will failed.'
        else:
            a1, a2 = test_aggregation_level
            ea1, ea2 = exp_aggregation_level.split(',')
            if a1 != ea1:
                error_msg = 'First dldata_pdcchsendreq aggregation_level is wrong, {} vs {}'.format(a1, ea1)
            elif a2 != ea2:
                error_msg = 'Second dldata_pdcchsendreq aggregation_level is wrong, {} vs {}'.format(a2, ea2)
            else:
                gv.write_console('First dldata_pdcchsendreq aggregation_level is {}'.format(a1))
                gv.write_console('Second dldata_pdcchsendreq aggregation_level is {}'.format(a2))
                gv.write_console('All aggregation level are as expected')
        if error_msg:
            raise Exception('Check Aggregation Level Failed.')

    def check_aggregation_level_for_791_b(self, test_aggregation_level, exp_value):
        if test_aggregation_level == '':
            raise Exception('Could not find dldata_pdcchsendreq')
        elif test_aggregation_level == exp_value:
            gv.write_console('Found aggregation level as expected: {}'.format(test_aggregation_level))
        else:
            gv.write_console('Found  aggregation level: {}'.format(test_aggregation_level))
            gv.write_console(
                'ERROR: found aggregation level but not as exepcted: {} vs {}'.format(
                    test_aggregation_level, exp_value))
            raise Exception('Found aggregation level but not as exepcted')

    def read_pmlist_from_excel(self, excelfile):
        """
            这个kw是为Feature 8662引入的， case需要计算KPI，KPI由几十个Counter参与计算；
            为了方便管理这些KPI和Counter之间的关系，定义：

            -   1、定义一个excel文件，用xls结尾（不支持xlsx）
            -   2、每一列代表一个KPI，列头是KPI的变量名称，比如：DL_VOP，列的其他内容就是计算这个KPI的Counter
            -   3、这个kw执行后，会产生一个Suite级别的变量，名字就是${DL_VOP}, 方便case里面使用；
            -   4、注意，这些变量是一个字符串，用逗号拼接了所有的counter；

        """
        import json
        import codecs
        data = {}
        with codecs.open(excelfile, encoding='utf-8') as f:
            data = json.load(f)
        for fieldname in data:
            counter_list = data[fieldname]
            gv.kw('Set Suite Variable', '${' + fieldname + '}', ','.join(counter_list))

    # Feature CB9007 KW
    def unpack_gnblog_for_cb009007(self, gnblogfile, result_dire):
        '''
            为Feature CB9007 预处理big log，biplog是zip文件
            -   进入biplog的目录，unzip biplogfile
            -   如果目录result_dire不存在，创建它；
            -   搜索解压出的bip log的子目录，把里面的.pcap文件复制到result_dire目录；
            -   搜索解压出的bip log的子目录，把里面的dl__all.csv文件，复制到result_dire目录；
            -   调用shepa log的解析工具，对pcap文件进行解析，输出到result_dire目录；
        '''
        dire = os.path.dirname(gnblogfile)
        fname = os.path.basename(gnblogfile)
        gv.exec_local_command('cd {};unzip {}'.format(dire, fname))

        if not os.path.exists(result_dire):
            os.mkdir(result_dire)
        pcap_filenname, tti_filename = '', ''
        for root, dirs, files in os.walk(dire, topdown=False):
            files.sort()
            for filename in files:
                fullname = os.path.join(root, filename)
                if '.pcap' in filename:
                    gv.exec_local_command('cp {} {}/'.format(fullname, result_dire))
                    pcap_filenname = os.path.join(result_dire, filename)
                    cmd = '/opt/Nokia/Sherpa_5G_18/Sherpa.run -d 3000 -o {} {}'.format(result_dire, pcap_filenname)
                    gv.exec_local_command(cmd)
                if filename.endswith('dl__all.csv'):
                    tti_filename = os.path.basename(filename)
                    gv.exec_local_command('cp {} {}/'.format(fullname, result_dire))

    def set_rule_for_ue_in_pcf(self, imsi, rule_name):
        '''
            为指定UE在PCF上下发规则

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | imsi | 字符串 | 是 | 无 | UE的imsi |
        | rule_name | 字符串 | 是 | 无 | 规则名称 |

        *返回值:* 无

        *示例:*
        | set_rule_for_ue_in_pcf | 460023100009683 | PZ1-ADD-5QI9 |

        '''

        token = (
            'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejFfaHo1IiwiZW1haWwiOiJ5YW5nanVuLnpoYW5Abm9ra'
            'WEtc2JlbGwuY29tIiwiZGlzcGxheW5hbWUiOiJQejEgSHo1IiwibnNuY2l0eSI6Ikhhbmd6aG91Iiwicm9sZXMiOlsicHox'
            'X2h6NV9hdXRvbWF0aW9uIl0sImV4cCI6MjAxNDc4MDYxNS44NDkyNjJ9.evq9X2M8c-jqWhBSrxfaWFX0U2mIKGTODKZaxT'
            'KtdfCPI9iBTwXH1lJ_3cRHLDCn_3XQaUJW0VpHaJBuhUzAdo3K7w-SSDZtQ-Lh5Kwhl8ZGkhTDrl8NTPcyQzRe2nOE1OXTgh'
            'GjY-rlOIJR5z-92TuZPJYTMi14aZIflKKYa6oCw2Xq6NUW0XSF-u46_JSFKz--5ZxfxEo0mj9oHKQgH8jZjnBnfUx7mwiLUq'
            '7yoUtpT2Qw5gtfOc6HXuGAJ3YWoVpPeZCL-JcKyTMVu9wlSNd4yEKgAXBBr3HaIb2jmR2R32FWyjwILPSWwd1x_HRv0Iy'
            'Icc1S2oXoEQ26AGnA0A'
        )

        # token = 'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1aWQiOiJwejFfaHo1IiwiZW1haWwiOiJ5YW5nanVuLnpoYW5Abm9raWEt'
        # token += 'c2JlbGwuY29tIiwiZGlzcGxheW5hbWUiOiJQejEgSHo1IiwibnNuY2l0eSI6Ikhhbmd6aG91Iiwicm9sZXMiOlsicHoxX2h6N'
        # token += 'V9hdXRvbWF0aW9uIl0sImV4cCI6MjAxNDc4MDYxNS44NDkyNjJ9.evq9X2M8c-jqWhBSrxfaWFX0U2mIKGTODKZaxTKtdfCPI'
        # token += '9iBTwXH1lJ_3cRHLDCn_3XQaUJW0VpHaJBuhUzAdo3K7w-SSDZtQ-Lh5Kwhl8ZGkhTDrl8NTPcyQzRe2nOE1OXTghGjY-rlOI'
        # token += 'JR5z-92TuZPJYTMi14aZIflKKYa6oCw2Xq6NUW0XSF-u46_JSFKz--5ZxfxEo0mj9oHKQgH8jZjnBnfUx7mwiLUq7yoUtpT2Qw'
        # token += '5gtfOc6HXuGAJ3YWoVpPeZCL-JcKyTMVu9wlSNd4yEKgAXBBr3HaIb2jmR2R32FWyjwILPSWwd1x_HRv0IyIcc1S2oXoEQ26AG'
        # token += 'nA0A'
        import requests

        url = 'https://newhorizons.srn.dyn.nesc.nokia.net/api/selfservice/ncp_api_update_device'
        headers = {
            'Content-Type': 'application/x-www-form-urlencoded',
            'Authorization': f'Bearer {token}'
        }
        data = {
            'imsi': imsi,
            'rule_name': rule_name
        }
        gv.logger.info(f'设置UE规则  IMSI: {imsi}, 规则： {rule_name}')
        resp = requests.post(url, headers=headers, data=data, verify=False)
        if resp.status_code == 200:
            gv.logger.info('设置成功')
        else:
            raise Exception(f'设置UE规则  IMSI: {imsi}, 规则： {rule_name} 失败！！！')

    # For feature 8441

    def download_latest_mdt_log_from_dcap(self, host, username, password, btsid, dest_dire, latest='1'):
        from lib_devices.pet_ssh import cpc_factory
        cpc = cpc_factory(host=host, username=username, password=password, os='linux')
        cpc.setup()
        if str(latest) == '1':
            cmd = f'find /sharedvolume/ntracer/_data -name *.lcbin|grep {btsid}|tail -n 1'
        else:
            cmd = f'find /sharedvolume/ntracer/_data -name *.lcbin|grep {btsid}|tail -n 2|head -n 1'
        src = cpc.exec_command(cmd).splitlines()[0]
        dst = os.path.basename(src).replace(':', '').replace('_', '').replace('ffff', '')
        cpc.get_file_from_cpc(src, os.path.join(dest_dire, dst))
        cpc.teardown()
        return os.path.join(dest_dire, dst)


if __name__ == '__main__':
    p = pet_feature_kw()
    # print(p.get_measuredGbrLoad_100('/home/ute/test_results/suite_2022_07_12__07_13_41/325458/ucap.pcap'))
    # p.smf_setup()
    # print(p.get_ue_dedicate_5qi('460023100009671'))
    # p.smf_teardown()
    import urllib3
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
    logging.info('OK')
    sherpa_log = '/home/ute/temp/bantao/d2/gNB_10.108.231.208_20220822_142346_m/L2_trace/csv1/l1l2Trace.csv'
    # sherpa_log = '/home/ute/temp/bantao/d2/gNB_10.108.231.208_20220822_142346_m/L2_trace/csv2/l1l2Trace.csv'
    # tti_log = ('/home/ute/temp/2730_TTI.bin.19.dl__all.csv')
    # print(p.get_sliv_from_ttilog(tti_log, '3,7'))
    # print(p.check_tti_file('.07', sherpa_log, tti_log))
    # p.set_rule_for_ue_in_pcf(imsi='460023100009683', rule_name='PZ1-ADD-5QI9')
    # p.get_ue_context_from_smf('460023100009671')
    p.download_latest_mdt_log_from_dcap('10.97.92.238', 'dcapuser', 'T@dmin@123', 11007, '/tmp')
