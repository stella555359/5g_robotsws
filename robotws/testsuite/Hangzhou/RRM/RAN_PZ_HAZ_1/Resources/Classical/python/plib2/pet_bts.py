#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

from optparse import Values
import os
import time
import sys
from lxml import etree
from types import SimpleNamespace
import tempfile
import json

from petbase import gv
logger = gv.logger
kw = gv.kw


class pet_bts(object):

    """
    This library will provide BTS related keywords for RRM5/RRM6.
    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'

    def __init__(self):
        pass

    def pet_bts_should_be_onair(self, connection):
        """
        This keyword will check if bts is onAir (Use AdminAPI to get bts status)

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | AdminAPI connection |

        *Return:* True/False

        *Examples:*
        | Pet BTS Should Be OnAir | connection=${ADMIN_MASTER} |

        """

        status = kw('get_bts_statuses', 10, connection)['proceduralState']
        logger.info('bts status: {}'.format(status))
        if status != 'OnAir':
            raise Exception('BTS is not OnAir')

    def _availability_status(self, item):
        if 'availabilityStatus' in item:
            return item['availabilityStatus']
        else:
            if item['administrativeState'].upper() == 'unlocked'.upper() and\
               item['operationalState'].upper() == 'enabled'.upper():
                return 'ONLINE'
            else:
                return 'OFFLINE'

    def _get_cell_info(self, connection=None, rat='LTE'):
        from lib_devices.common import IpaMmlItem
        btsinfo = kw('get_bts_info', '120', connection)
        result = []
        items = []
        for ratname in rat.lower().split(','):
            items += btsinfo['cells'].get(ratname, [])
        for item in items:
            cell = IpaMmlItem()
            cell.configuration = item['id']['configuration']
            cell.internal = item['id']['internal']
            cell.name = item['cellName']
            cell.administrativeState = item['status']['administrativeState']
            cell.blockingState = item['status']['blockingState']
            cell.operationalState = item['status']['operationalState']
            cell.availabilityStatus = self._availability_status(item['status'])
            cell.phyCellId = item['physicalCellId']
            result.append(cell)
        return result

    def pet_cells_should_be_onair(self, connection):
        """
        This keyword will check if LTE cells and NR cells are onAir (Use AdminAPI to get bts status)

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | AdminAPI connection |

        *Return:* True/False

        *Examples:*
        | Pet Cells Should be OnAir | connection=${ADMIN_MASTER} |

        """
        cells = self._get_cell_info(connection=connection, rat='lte,nr')
        for cell in cells:
            logger.info('Cell: {}, Status: {}'.format(cell.name, cell.availabilityStatus))
            if cell.availabilityStatus.upper() != 'ONLINE':
                raise Exception('Cell {} status is {}, not online'.format(cell.name, cell.availabilityStatus))

    def pet_wait_until_bts_all_onair(self, connection=None, timeout='15min', interval='5sec', ignore_cell=False):
        """
        This keyword will wait until bts is onair and 4g/5g cells are onAir

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | AdminAPI connection |
        | timeout | string | N | 15min | timeout value with robot format |
        | interval | string | N | 5sec | interval value for check with robot format |
        | ignore_cell | boolean | N | False | If ignore cell check |

        *Return:* True/False

        *Examples:*
        | Pet Wait until BTS all onAir | connection=${ADMIN_MASTER} | timeout=10mins |
        | Pet Wait until BTS all onAir | connection=${ADMIN_MASTER} | timeout=10mins | interval=5sec |
        | Pet Wait until BTS all onAir | connection=${ADMIN_MASTER} | timeout=10mins | interval=5sec |
        | ... | ignore_cell=${TRUE} |

        """
        gv.kw('Wait Until Keyword Succeeds', timeout, interval, 'pet_bts_should_be_onair', connection)
        if not ignore_cell:
            gv.kw('Wait Until Keyword Succeeds', timeout, interval, 'pet_cells_should_be_onair', connection)

    def pet_fct_connect(self, **kwargs):
        """
        This keyword will create a ssh connection to bts fct

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | N | 192.168.255.129 | fct ip address  |
        | username | string | N | toor4nsn | username to login fct |
        | password | string | N | oZPS0POrRieRtu | password to login fct |

        *Return:* object for ssh connection

        *Examples:*
        | ${FCT_MASTER}= | Pet FCT Connect |
        | ${FCT_MASTER}= | Pet FCT Connect | host=192.168.255.129 |
        | ${FCT_MASTER}= | Pet FCT Connect | host=192.168.255.129 | username=toor4nsn |
        | ${FCT_MASTER}= | Pet FCT Connect | host=192.168.255.129 | username=toor4nsn | password=oZPS0POrRieRtu |

        """
        from lib_devices.pet_ssh import cpc_linux
        intf = cpc_linux(host=kwargs.get('host', '192.168.255.129'),
                         username=kwargs.get('username', 'toor4nsn'),
                         password=kwargs.get('password', 'oZPS0POrRieRtu'))
        intf.setup()
        return intf

    def pet_fct_disconnect(self, connection):
        """
        This keyword will disconnect a ssh connection to bts fct

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | connection object return by Pet FCT Connect |

        *Return:* None

        *Examples:*
        | ${FCT_MASTER}=| connection=Pet FCT DisConnect |

        """
        connection.teardown()

    def pet_fct_exec_command(self, connection, command):
        """
        This keyword will execute a command through fct connection

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | connection object return by Pet FCT Connect |
        | command | string | Y |  | The command you need to execute  |

        *Return:* output string of the command;

        *Examples:*
        | Pet FCT Exec Command | connection${FCT_MASTER} | command=ls /tmp |

        """
        return connection.exec_command(command)

    def pet_get_sw_version(self, connection):
        """
        This keyword will get bts version through fct connection

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | connection object return by Pet FCT Connect |

        *Return:* bts version;

        *Examples:*
        | Pet Get SW Version | command=${FCT_MASTER} |

        """
        line = [x for x in connection.exec_command('ls /ffs/run/Target*.xml ').splitlines() if x.strip()]
        if line:
            sw_version = line[0].split('TargetBD_')[-1].replace('.xml', '')
            return sw_version
        else:
            logger.warning('Output for get sw version: %s' % (str(line)))
            raise Exception('Get BTS Version failed, make sure S1 is reachable')

    def pet_fct_upload_file(self, connection=None, local_file='', remote_file=''):
        """
        This keyword will put file from local to fct

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | connection object return by Pet FCT Connect  |
        | local_file | string | Y |  | Local file path  |
        | remote_file | string | Y |  | Remote file path  |

        *Return:* output string of the command;

        *Examples:*
        | Pet FCT Upload File | command=${FCT_MASTER} | local_file=sw_config.txt | remote_file=/tmp/sw_config.txt |

        """
        connection.put_file_to_cpc(local_file, remote_file)

    def pet_create_btslog_collector(self, **kwargs):
        """
        This keyword will create a btslog collector
        The collector is a udp forward python script that will receive 51000 udp packet and forward
        to specific ip

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | N | 127.0.0.1 | host ip of the bts vm, for master bts, it is 127.0.0.1 |
        | username | string | N | ute | username for host |
        | password | string | N | uteUTE! | password for host |

        *Return:* btslog collector object;

        *Examples:*
        | Pet Create Btslog Collecotr |
        | Pet Create Btslog Collecotr | host=127.0.0.1 |
        | Pet Create Btslog Collecotr | host=127.0.0.1 | username=ute |
        | Pet Create Btslog Collecotr | host=127.0.0.1 | username=ute | password=uteUTE! |

        """
        from lib_devices.pet_btslog import pet_btslog
        obj = pet_btslog(**kwargs)
        gv.teardown_list.append(obj)
        return obj

    def pet_start_capture_btslog(self, collector):
        """
        This keyword will start to caputre btslog with a btslog collector

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | collector | object | Y | None | btslog collector create by kw: Pet Create Btslog Collecotr |

        *Return:* None;

        *Examples:*
        | Pet Start Capture Btslog | collector=collector |

        """
        collector.start()

    def pet_stop_capture_btslog(self, collector):
        """
        This keyword will stop caputring btslog with a btslog collector

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | collector | object | Y | None | btslog collector create by kw: Pet Create Btslog Collecotr |

        *Return:* None;

        *Examples:*
        | Pet Stop Capture Btslog | collector=collector |

        """
        collector.stop()

    def pet_download_latest_pm_file(self):
        pass

    def pet_read_pm_file(self, pmfile, cared_counters=''):
        from lib_devices.pet_counter import c_counter_manager
        return c_counter_manager().parse_pm_file(pmfile, cared_counters.split(','))

    def pet_fct_stop_tshark(self, connection):
        """
        This keyword will stop tcpdump command on s1 interface

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | Fct connection object, get from  Pet FCT Connect |

        *Return:* None

        *Examples:*
        | Pet FCT Stop Tshark| connection=${FCT_MASTER} |
        """

        logger.info('Stop tshark...')
        cmd = "ps -ef|grep tcpdump|grep local.pcap|grep -v grep|awk {'print $2'}|xargs kill -9"
        connection.exec_command(cmd)

    def pet_fct_start_tshark(self, connection=None, protocol='sctp', intf_name='any', args=''):
        """
        This keyword will start tcpdump command on fct connection

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | s1 object, get from  Pet FCT Connect |
        | protocol | string | N | sctp | specific the protocol you need to capture |
        | intf_name | string | N | any | interface name for the s1 interface, like: any |
        | args | string | N |  | other parameters for tcpdump command |

        *Return:* None

        *Examples:*
        | Pet Fct Start Tshark | connection=${FCT_MASTER} | protocol=sctp | intf_name=any |
        """

        logger.info('Start tshark')
        kw('Pet FCT Exec Command', connection, 'rm -rf /tmp/local.pcap')
        cmd = 'nohup tcpdump -i {} '.format(intf_name)
        if protocol:
            cmd += ' {} '.format(protocol)
        if args:
            cmd += ' {} '.format(args)
        cmd += ' -w /tmp/local.pcap &'
        connection.exec_command_background(cmd)

    def pet_fct_get_file(self, connection, remote_filename, local_filename):
        """
        This keyword will download file from fct to local

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | s1 object, get from  Pet FCT Connect |
        | remote_filename | string | Y | Remote filename to be downloaded |
        | local_filename | string | Y | local filename to be downloaded |

        *Return:* None

        *Examples:*
        | Pet FCT Get file | connection=${FCT_MASTER} | remote_filename=/tmp/local.pcap |
        | ... | local_filename=/tmp/case.pcap |
        """

        connection.get_file_from_cpc(remote_filename, local_filename)

    def pet_wait_until_all_pm_file_done(self, connection=None, interval='10s', timeout='16 mins'):
        """
        This keyword will wait until found new PM file in specific timeout

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | connection | object | Y | None | FCT connection object, get from  Pet FCT Connect |
        | interval | string | N | 10s | Check interval |
        | timeout | string | N | 16 mins | Check timeout |

        *Return:* None

        *Examples:*
        | Pet Wait Until All PM file done| connection=${FCT_MASTER} |
        | Pet Wait Until All PM file done| connection=${FCT_MASTER} | interval=10s |
        | Pet Wait Until All PM file done| connection=${FCT_MASTER} | interval=10s | timeout=16mins |
        """

        from robot.utils import timestr_to_secs
        timeout = timestr_to_secs(timeout)
        interval = timestr_to_secs(interval)
        olines = kw('Pet Fct Exec Command', connection, 'ls -latr /tmp/PM*.gz').splitlines()
        olines = [x for x in olines if 'No such file or directory' not in x]
        start_time = time.time()
        while time.time() < start_time + timeout:
            nlines = kw('Pet Fct Exec Command', connection, 'ls -latr /tmp/PM*.gz').splitlines()
            nlines = [x for x in nlines if 'No such file or directory' not in x]
            if len(nlines) > len(olines):
                return
            else:
                time.sleep(interval)
        raise Exception('Could not find new file in specific timeout.')

    def pet_sum_counter_in_files(self, pm_file, counterid, distname=''):
        """
        This keyword will Sum counter in counter files

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pm_file | string | Y | None | pm file or directory that contains pm files |
        | counterid | string | Y | None | The Counter ID |
        | distname | string | N | None | distname for counter |

        *Return:* float value for sum of counter

        *Examples:*
        | ${counter_value}= | Pet Sum Counter in files | a.raw.gz | MC000232 |
        | ${counter_value}= | Pet Sum Counter in files | /mypmfile_directory | MC000232 |
        | ${counter_value}= | Pet Sum Counter in files | /mypmfile_directory | MC000232,MC000233 |
        """

        from lib_devices.pet_counter import c_counter_manager
        path = pm_file
        result = []
        values = []
        cid_list = counterid.split(',')
        if os.path.isdir(path):
            files = [x for x in os.listdir(path)]
            for filename in files:
                result += c_counter_manager().parse_pm_file(os.path.join(path, filename), cid_list)
        else:
            result += c_counter_manager().parse_pm_file(path, cid_list)

        if distname and distname.lower() != 'all':
            result = [x for x in result if x.cellinfo == distname]

        for cid in cid_list:
            values += [sum([int(item.value) for item in result if item.counter == cid])]

        if len(values) == 1:
            return values[0]
        else:
            return values

    def pet_avg_counter_in_files(self, pm_file, counterid, distname=''):
        """
        This keyword will calculate average for counter in counter files

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pm_file | string | Y | None | pm file or directory that contains pm files |
        | counterid | string | Y | None | The Counter ID |
        | distname | string | N | None | distname for counter |

        *Return:* float value for sum of counter

        *Examples:*
        | ${counter_value}= | Pet Avg Counter in files | a.raw.gz | MC000232 |
        | ${counter_value}= | Pet Avg Counter in files | /mypmfile_directory | MC000232 |
        | ${counter_value}= | Pet Avg Counter in files | /mypmfile_directory | MC000232,MC000233 |
        """

        from lib_devices.pet_counter import c_counter_manager
        path = pm_file
        result = []
        values = []
        cid_list = counterid.split(',')
        if os.path.isdir(path):
            files = [x for x in os.listdir(path)]
            for filename in files:
                result += c_counter_manager().parse_pm_file(os.path.join(path, filename), cid_list)
        else:
            result += c_counter_manager().parse_pm_file(path, cid_list)

        if distname and distname.lower() != 'all':
            result = [x for x in result if x.cellinfo == distname]

        for cid in cid_list:
            lines = [item for item in result if item.counter == cid]
            total = sum([int(item.value) for item in lines])
            if len(lines) > 0:
                values.append(round(total / len(lines), 2))
            else:
                values.append('NA')

        if len(values) == 1:
            return values[0]
        else:
            return values

    def pet_max_counter_in_files(self, pm_file, counterid, distname=''):
        """
        This keyword will Max counter in counter files

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pm_file | string | Y | None | pm file or directory that contains pm files |
        | counterid | string | Y | None | The Counter ID |
        | distname | string | N | None | distname for counter |

        *Return:* float value for max of counter

        *Examples:*
        | ${counter_value}= | Pet Max Counter in files | a.raw.gz | MC000232 |
        | ${counter_value}= | Pet Max Counter in files | /mypmfile_directory | MC000232 |
        | ${counter_value}= | Pet Max Counter in files | /mypmfile_directory | MC000232,MC000233 |
        """

        from lib_devices.pet_counter import c_counter_manager
        path = pm_file
        result = []
        values = []
        cid_list = counterid.split(',')
        if os.path.isdir(path):
            files = [x for x in os.listdir(path)]
            for filename in files:
                result += c_counter_manager().parse_pm_file(os.path.join(path, filename), cid_list)
        else:
            result += c_counter_manager().parse_pm_file(path, cid_list)

        if distname and distname.lower() != 'all':
            result = [x for x in result if x.cellinfo == distname]

        for cid in cid_list:
            values += [max([int(item.value) for item in result if item.counter == cid])]

        if len(values) == 1:
            return values[0]
        else:
            return values

    def pet_get_counter_in_files(self, pm_file, counterid, distname=''):
        """
        This keyword will Get counter in counter files

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pm_file | string | Y | None | pm file or directory that contains pm files |
        | counterid | string | Y | None | The Counter ID |
        | distname | string | N | None | distname for counter |

        *Return:* list value for counter

        *Examples:*
        | ${counter_value}= | Pet Get Counter in files | a.raw.gz | MC000232 |
        | ${counter_value}= | Pet Get Counter in files | /mypmfile_directory | MC000232 |
        | ${counter_value}= | Pet Get Counter in files | /mypmfile_directory | MC000232,MC000233 |
        PLMN-PLMN/MRBTS-11648/NRBTS-11648/NRCELL-1 |
        """

        from lib_devices.pet_counter import c_counter_manager
        path = pm_file
        result = []
        values = dict()
        cid_list = counterid.split(',')
        if os.path.isdir(path):
            files = [x for x in os.listdir(path)]
            for filename in files:
                result += c_counter_manager().parse_pm_file(os.path.join(path, filename), cid_list)
        else:
            result += c_counter_manager().parse_pm_file(path, cid_list)

        if distname and distname.lower() != 'all':
            result = [x for x in result if x.cellinfo == distname]

        for cid in cid_list:
            values[cid] = []
            for item in result:
                if item.counter == cid:
                    values[cid].append(int(item.value))
        return values

    def pet_check_counter(self, pm_file, condition):
        """
        This keyword will check if pm counter as expected
        The condition format is like:  counterid,distname>=value or counterid,all>=value
        If not pass the check condition, a error will happened

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pm_file | string | Y | None | pm file or directory that contains pm files |
        | condition | string | Y | None | The Counter check item defination |

        *Return:* None

        *Examples:*
        | Pet Check Counter | pm_file=a.raw.gz | condition=MC000232,all>1000 |
        """

        if '>' in condition:
            op = '>=' if '=' in condition else '>'
        elif '<' in condition:
            op = '<=' if '=' in condition else '<'
        elif '=' in condition:
            op = '='
        else:
            raise Exception('Could not find valid compare operation in ' + condition)
        gv.logger.info('Compare Opeation: [{}]'.format(op))
        p1, exp_result = condition.split(op)
        counterid, distname = [x.strip() for x in p1.strip().split(',')]
        gv.logger.info('Countid: [{}],  distname: [{}]'.format(counterid, distname))
        exp_result = float(exp_result.strip())
        real_value = self.pet_sum_counter_in_files(pm_file, counterid, distname)
        gv.logger.info('Real value: {}, check condition: {}'.format(real_value, condition))
        msg = 'Counter {} check failed, Condition: {}, Real value: {}'.format(counterid, condition, real_value)
        if op == '>=' and not real_value >= exp_result:
            raise Exception(msg)
        elif op == '>' and not real_value > exp_result:
            raise Exception(msg)
        elif op == '=' and not real_value == exp_result:
            raise Exception(msg)
        elif op == '<=' and not real_value <= exp_result:
            raise Exception(msg)
        elif op == '<' and not real_value < exp_result:
            raise Exception(msg)
        else:
            pass

    def pet_check_counters(self, pm_file, check_items):
        """
        This keyword will check if a list of pm counter check items

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pm_file | string | Y | None | pm file or directory that contains pm files |
        | check_items | list | Y | None | A list, each element is a check item |

        *Return:* None

        *Examples:*
        | Pet Check Counters | pm_file=a.raw.gz | check_items=&{check_items} |
        """

        for item in check_items:
            kw('Run keyword and Check later', 'Pet Check Counter', pm_file, item)

    def pet_get_bts_params(self, parameter, connection='${ADMIN_MASTER}'):
        """
        获取基站的某个参数的值；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | parameter | string | Y | None | 参数名称，例如：earfcn |
        | connection | string | Y | None | AdminAPI连接的别名，通常是：${ADMIN_MASTER} |

        *返回值:*
        返回一个列表，每一个列表元素是一个字典，包含2个属性：
            distname
            value

        *Examples:*
        | ${params}= | Pet Get BTS Params | parameter=earfcn | connection=${ADMIN_MASTER} |
        | log | ${params[0]['distname']} |
        | log | ${params[0]['value']} |
        """
        scf_file = '/tmp/scf.xml'
        if os.path.exists(scf_file):
            os.remove(scf_file)
        kw('Get Current SCF File', '/tmp', 'scf.xml', 10, connection, 'configuration')
        if os.path.exists(scf_file):
            scfns = {"scfns": "raml21.xsd"}
            tree = etree.parse(scf_file)
            nodes = tree.xpath(f'//scfns:p[@name="{parameter}"]', namespaces=scfns)
            return [dict(distname=node.getparent().get('distName'),
                         value=node.text) for node in nodes]
        else:
            raise Exception('Failed to get SCF file.')

    def _prepare_scf_pm_list(self, scf_file, pm_list):
        # each item is a dict, dict(dist_name=dist_name, p_name=p_name,value=value)

        def _get_parent_mo(node):
            if 'managedObject' in node.getparent().tag:
                return node.getparent()
            else:
                return _get_parent_mo(node.getparent())

        def _get_parameters(scftree, pname):
            scfns = {"scfns": "raml21.xsd"}
            if scftree:
                return scftree.xpath(
                    '//scfns:p[@name="%s"]' % (pname), namespaces=scfns)
            else:
                return []

        scftree = etree.parse(scf_file)

        result = []
        for item in pm_list:
            name = item['name']
            pm_nodes = _get_parameters(scftree, name)
            if pm_nodes:
                for i, node in enumerate(pm_nodes):
                    distnode = _get_parent_mo(node)
                    if distnode is not None:
                        dist_name = distnode.get('distName')
                        if (item['dist_name'] == '') or (item['dist_name'] and item['dist_name'] == dist_name):
                            value = item['value'][i] if isinstance(item['value'], list) else item['value']
                            gv.logger.info(
                                f'比较参数, dist_name={dist_name}, name={name}, value={value}, scf_value={node.text}')
                            if node.text == value:
                                gv.logger.info('当前值和新设值相同, 忽略它.')
                            else:
                                gv.logger.info('当前值和新设值不同')
                                result.append(dict(dist_name=dist_name, name=name, value=value))
                    else:
                        raise Exception(f'Could not find the managedObject for paramter [{name}]')
            else:
                raise Exception(f'Could not find parameter name [{name}] in SCF, please check it.')

        return result

    def pet_change_parameter_with_pmlist(self, pmlist):
        def pmlist_to_delta_file(pm_list, dest_file):
            lines = []
            for item in pm_list:
                lines.append({
                    'distName': item['dist_name'],
                    'operation': 'update',
                    'parameters': [{
                        'parameterName': item['name'],
                        'value': item['value'],
                        'operation': 'update'}]})
            with open(dest_file, 'w', encoding='utf-8') as f:
                f.write(json.dumps(lines))

        _, scf_file = tempfile.mkstemp(suffix='.xml')
        local_dir_path, file_name = os.path.split(scf_file)
        kw('get_current_scf_file', f'local_dir_path={local_dir_path}', f'file_name={file_name}',
           'export_type=configurationAndRuntimeObjects', 'connection=${admin_master}')

        changes = self._prepare_scf_pm_list(scf_file, pmlist)
        if os.path.exists(scf_file):
            os.remove(scf_file)

        if changes:
            _, delta_file = tempfile.mkstemp(suffix='.json')
            pmlist_to_delta_file(changes, delta_file)
            kw('perform_delta_recommissioning', f'delta_file={delta_file}',
               'skip_parameter_relation_errors=True',
               'timeout=300', 'connection=${admin_master}')
            if os.path.exists(delta_file):
                os.remove(delta_file)
            return True
        else:
            gv.logger.info('当前所有参数都不需要改动；')
            return False
