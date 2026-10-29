#!/usr/bin/python3
# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import sys
import os
import time
import json
from petbase import gv

from pet_shell import PetShell
logger = gv.logger
kw = gv.kw


class taobject(object):

    def __init__(self, name):
        self.name = name

    def __str__(self):
        return self.name

    def __repr__(self):
        return self.name


class pet_robot(object):

    """
    This library will provide keywords for RRM5/RRM6.

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '1.0'

    def __init__(self):
        self.logger = logger

    def common_suite_setup_for_pet(self, **kwargs):
        """
        suite setup是为同一个robot文件里面的所有case服务的，只执行一次；

        kw说明：
        -   创建一个目录，专门用来放所有的case输出，目录保存在变量${SUITE_DIRE}里面；
        -   打印基站的版本信息（通过连接fct_ip, 查询/ffs/run/targetBDxxx.xml来实现）
        -   如果带参数 -v INSTALL_BUILD:YES，那么会查询基站的版本是否是${ENB_BUILD}变量指定的版本，如果不是，装包；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | fct_ip | 字符串 | 否 | 192.168.255.129 | fct的ip地址，用来获取基站的版本 |
        | reserve_resource | 字符串 | 否 | 空 | 指定需要reserve的资源，多个资源用逗号隔开 |

        *返回值:* 无

        *示例:*
        | Suite Setup | common_suite_setup_for_pet |
        | Suite Setup | common_suite_setup_for_pet | fct_ip=10.108.231.219 |
        | Suite Setup | common_suite_setup_for_pet | fct_ip=10.108.231.219 | reserve_resource=bts1122,cpc_119 |

        """
        PetShell.common_suite_setup_for_pet(**kwargs)

    def common_suite_teardown_for_pet(self, **kwargs):
        """
        This keyword is common suite teardown for RRM5/RRM6 team.

        Currently it do nothing.

        *Input Param:*  None

        *Return:* None
        """
        PetShell.common_suite_teardown_for_pet(**kwargs)

    def common_case_setup_for_pet(self, **kwargs):
        """
        case的Setup是每个robot case的准备过程，这里的common case setup for pet提供了我们每个robot case都需要的准备动作；

        这个kw可以给2个站提供准备，主要是满足有些场景是需要2个站配合测试的情况；第一个站叫主站，第二个站叫辅站；

        KW说明：
        -   通过admin_ip  fct_ip来指定站是主站；
        -   通过admin_ip2  fct_ip2来指定站是辅站；
        -   通过指定swconfig_file scf_file pm_file来给主站提供swconfig文件，scf文件和产生文件；
        -   基本的顺序是：换swconfig文件；下发scf文件；等基站onAir；根据pm_file文件修改参数；
        -   这3个文件不需要都有，可以根据你的需要进行组合；kw会根据你的参数，判断是不是要重启主站；
        -   通过指定swconfig_file2 scf_file2 pm_file2来给辅站提供swconfig文件，scf文件和产生文件；
        -   这3个文件不需要都有，可以根据你的需要进行组合；kw会根据你的参数，判断是不是要重启辅站；
        -   这个kw还会创建一个目录，用来放置case相关的文件，这个目录保存在变量${CASE_DIRE}里面；
        -   这个kw还会建立一个到主站的AdminAPI的连接，别名是master；你在直接调用AdminAPI的kw的时候可以直接使用；
        -   这个kw还会建立一个到辅站的AdminAPI的连接，别名是salve；你在直接调用AdminAPI的kw的时候可以直接使用；
        -   这个kw还会建立一个到主站的s1的ssh连接，保存在${fct_master}里面，供需要的时候使用
        -   这个kw还会建立一个到辅站的s1的ssh连接，保存在${fct_slave}里面，供需要的时候使用
        -   这个kw还会根据主站信息，查询scfid，从而为case的configuration id做好准备
        -   如果执行的时候带参数：-v DEBUG_MODE:YES，不换scf，不换swconfig，不修改参数；

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | admin_ip | string | N | 192.168.255.129 | ip used for admin |
        | fct_ip | string | N | 192.168.255.1 | ip used for fct connection |
        | pm_file | string | N | None | bts parameter file path, json format |
        | scf_file | string | N | None | scf file path |
        | swconfig_file | string | N | None | swconfig file path |
        | admin_ip2 | string | N | 192.168.255.129 | ip used for admin for bts2 |
        | fct_ip2 | string | N | 192.168.255.1 | ip used for fct connection for bts2 |
        | pm_file2 | string | N | None | bts parameter file path, json format for bts2 |
        | scf_file2 | string | N | None | scf file path for bts2 |
        | swconfig_file2 | string | N | None | swconfig file path for bts2 |

        *Return:* None

        *Examples:*

        | Case Setup | Common case setup for Pet | admin_ip=10.108.231.219 |
        | Case Setup | Common case setup for Pet | swconfig_file=${CURDIR}/swconfig.txt |
        | Case Setup | Common case setup for Pet | swconfig_file=${CURDIR}/swconfig.txt | scf_file=${CURDIR}/a.xml |
        | Case Setup | Common case setup for Pet | pm_file=${CURDIR}/pm.json |

        In specific case, you can use like below when each case has different parameters:
        | [Setup] | Common case setup for Pet | admin_ip=10.108.231.219 |
        | [Setup] | Common case setup for Pet | swconfig_file=${CURDIR}/swconfig.txt | scf_file=${CURDIR}/a.xml |

        """
        PetShell.common_case_setup_for_pet(**kwargs)

    def common_case_teardown_for_pet(self, **kwargs):
        """
        This keyword will:
        -   Try to disconnect admin in ${admin_master};
        -   Try to disconnect admin in ${admin_slave};
        -   Try to disconnect s1 in ${fct_master};
        -   Try to disconnect s1 in ${fct_slave};

        *Input Param:*  None

        *Return:* None

        """
        PetShell.common_case_teardown_for_pet(**kwargs)

    def pet_start_dl_iperf(self, **kwargs):
        """
        This keyword will be used to start iperf from a datadevice to ue

        Datadevice is a linux server which we will used to execute iperf command;

        The host, port, username, password is used for datadevice;

        The dloption is used for iperf command on datadevice

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | Y | None | ip address of datadevice |
        | port | int | N | 22 | port of datadevice |
        | username | string | Y | ute | username to datadevice |
        | password | string | Y | None | password to datadevice |
        | ueip | string | Y | None | ip address of UE, it will be the dest ip of iperf command |
        | dloption | string | Y | None | the dloption will be appended to the iperf command |

        *Return:* None
        """
        PetShell.start_dl_iperf(**kwargs)

    def pet_stop_dl_iperf(self, **kwargs):
        """
        This keyword will be used to stop iperf from a datadevice to ue

        Datadevice is a linux server which we will used to execute iperf command;

        The host, port, username, password is used for datadevice;

        The dloption is used for iperf command on datadevice

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | Y | None | ip address of datadevice |
        | port | int | N | 22 | port of datadevice |
        | username | string | Y | ute | username to datadevice |
        | password | string | Y | None | password to datadevice |
        | ueip | string | Y | None | ip address of UE, it will be the dest ip of iperf command |

        *Return:* None
        """
        PetShell.stop_dl_iperf(**kwargs)

    def pet_pb_operator(self, **kwargs):
        """
        This keyword will take PowerBreak operation.

        For facom PB, there are 2 models: 4001 and 5000; this keyword will detected itself.

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | factory | string | Y | facom | The factory of Powerbreak : facom/apc/nokia |
        | host | string | Y | None | ip address of PowerBreak |
        | port | string | Y | None | the operator port |
        | operation | string | Y | poweron | user operation: poweron/poweroff |

        *Return:* None

        *Examples:*
        | Pet PB Operator | factory=facom | host=10.68.83.23 | port=3 | operation=poweron |
        | Pet PB Operator | factory=facom | host=10.68.83.23 | port=5 | operation=poweroff |

        """
        PetShell.pb_operator(**kwargs)

    def pet_change_pa_signal(self, **kwargs):
        """
        This keyword will change signal of PA/RFMatrix.

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | devicetype | string | Y | switch | The device type : pa/rfswitch |
        | model | string | Y | jx | The device model : jx/jxb/hb |
        | host | string | Y | None | ip address of device |
        | port | string | Y | 23 | the operator port of device |
        | totalinport | int | Y | 8 | The input port count of device |
        | totaloutport | int | Y | 16 | The output port count of device |
        | points | string | Y | None | like: A1B2,A3B4 |
        | signal | string | Y | 93 | expected signal |

        *Return:* None

        *Examples:*
        | Pet Change PA Signal | devicetype=switch | model=hb | host=10.68.83.2 | points=A1B2,A3B4 | signal=10 |

        """

        PetShell.change_pa_signal(**kwargs)

    def pet_ue_setup(self, **kwargs):
        """
        This keyword will add UE for test, this is the first step for ue operation.

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue_type | string | Y | android | specific ue type, current support: android |
        | host | string | Y | None | ue pc ip address |
        | username | string | Y | csv5-tester | username to ue pc |
        | password | string | Y | Nokia123! | password to ue pc |
        | os | string | N | windows | ue pc os |
        | serialno | string | Y | None | Specific UE serial no |
        | model | string | N | None | Specific UE model, for Huawei, it should be huawei |

        *Return:* UE object

        *Example for ue_type == Android:*

        | ${ue1}= | Pet UE Setup | ue_type=android | host=10.106.23.2 | serialno=1234abc | username=csv5 |

        """
        return PetShell.add_ue(**kwargs)

    def pet_ue_reboot(self, ue, **kwargs):
        """
        This keyword will reboot UE

        For different UE type, it will accept different parameters;


        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |

        *Return:* None

        Example for ue_type == Android:

        | Pet UE Reboot | ue=${ue1} |
        """
        PetShell.ue_reboot(ue, **kwargs)

    def pet_ue_attach(self, ue, **kwargs):
        """
        This keyword will attach specific UE

        For different UE type, it will accept different parameters;

        For ue_type == Android, attach means disable airplane:

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |
        | points | string | Y | None | click points, see example |

        *Return:* None

        Example for ue_type == Android:

        | Pet UE Attach | ue=${ue1} | points=网络和互联网;312,765 |
        """
        PetShell.ue_attach(ue, **kwargs)

    def pet_ue_deattach(self, ue, **kwargs):
        """
        This keyword will de-attach specific UE

        For different UE type, it will accept different parameters;

        For ue_type == Android, de-attach means enable airplane:

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |
        | points | string | Y | None | click points, see example |

        *Return:* None

        Example for ue_type == Android:

        | Pet UE DeAttach | ue=${ue1} | points=网络和互联网;312,765 |
        """
        PetShell.ue_deattach(ue, **kwargs)

    def pet_ue_get_ueip(self, ue, intf_name='', mode='normal'):
        """
        This keyword will return ue ipaddress for specific UE

        For different UE type, it will accept different parameters;

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |
        | intf_name | string | N | None | interface name like: rmnet_data1 |
        | mode | string | Y | normal | if is normal, use ifconfig, if mode=special_a, get ip from UI |

        *Return: UEIP, string*

        Example for ue_type == Android:

        | ${UEIP}= | Pet Get UEIP | ue=${ue1} |
        """
        return ue.get_ueip(intf_name=intf_name, mode=mode.lower())

    def pet_ue_start_ul_iperf(self, ue, **kwargs):
        """
        This keyword will start UE upload iperf

        For different UE type, it will accept different parameters;

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |
        | option | string | Y | None | Specific the iperf upload option, like: -c 10.69.9.57 -u -b 1M -t 100 -i 1 |
        | use_cli | string | Y | N | use cli mode, if yes, run iperf in cli mode, else use magic iperf app |
        | point | string | Y | None | position of start button if magic_iperf app, like:970,405 |

        *Return: None*

        Example for ue_type == Android:

        | Pet UE Start UL Iperf| ue=${ue1} | option=-c 10.106.200.66 -u -b 1M -t 100 -i 1 | point=970,405 |
        """
        PetShell.start_ue_ul_iperf(ue, **kwargs)

    def pet_ue_stop_ul_iperf(self, ue, **kwargs):
        """
        This keyword will stop UE upload iperf

        For different UE type, it will accept different parameters;

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |
        | use_cli | string | Y | N | use cli mode, if yes, run iperf in cli mode, else use magic iperf app |
        | point | string | Y | None | position of stop button, like:970,405 |

        *Return:*

        Example for ue_type == Android:

        | Pet UE Stop UL Iperf| ue=${ue1} | point=970,405 |
        """
        PetShell.stop_ue_ul_iperf(ue, **kwargs)

    def pet_start_ping_to_ue(self, ue, **kwargs):
        """
        This keyword will start ping ue from CPC

        For different UE type, it will accept different parameters;

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | Specific ue, return from keyword: Pet Setup UE |
        | in_backgroud | string | N | true | if ping in background |
        | ueip | string | N | None | Specific UE ip, if is empty, inquery ue to get ip |

        *Return: None*

        *Example for ue_type == Android:*

        | Pet Start Ping to UE | ue=${ue1} | in_backgroud=True |
        | Pet Start Ping to UE | ue=${ue1} | in_backgroud=True | ueip=172.24.3.12 |
        """
        PetShell.start_ping_to_ue(ue, **kwargs)

    def pet_stop_ping_to_ue(self, ue, **kwargs):
        """
        This keyword will stop ping ue from CPC

        For different UE type, it will accept different parameters;

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | Specific ue, return from keyword: Pet Setup UE |
        | ueip | string | N | None | Specific UE ip, if is empty, inquery ue to get ip |

        *Return: None*

        *Example for ue_type == Android:*

        | Pet Stop Ping to UE | ue=${ue1} |
        | Pet Stop Ping to UE | ue=${ue1} | ueip=172.24.3.12 |
        """
        PetShell.stop_ping_to_ue(ue, **kwargs)

    def pet_ue_make_voice_call(self, ue, **kwargs):
        """
        This keyword will make a voice call on specific UE

        For different UE type, it will accept different parameters;

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | Specific ue, return from keyword: Pet Setup UE |
        | number | string | Y | None | The dail number for the voice call |

        *Return: None*

        *Example for ue_type == Android:*

        | Pet UE Make Voice Call| ue=${ue1} | number=8888 |
        """
        PetShell.ue_make_voice_call(ue, **kwargs)

    def pet_ue_cancel_voice_call(self, ue):
        """
        This keyword will cancel a voice call on specific UE

        For different UE type, it will accept different parameters;

        *For Android UE, Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | Specific ue, return from keyword: Pet Setup UE |

        *Return: None*

        *Example for ue_type == Android:*

        | Pet UE Cancel Voice Call| ue=${ue1} |
        """
        PetShell.ue_cancel_voice_call(ue)

    def pet_ue_exec_adb_cmd(self, ue, cmd):
        """
        This keyword will execute adb command on specific UE

        For different UE type, it will accept different parameters;

        For ue_type == Android, de-attach means enable airplane:

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | ue | object | Y | None | specific ue, return from keyword: Pet Setup UE |
        | cmd | string | Y | None | adb command for use |

        *Return:* None

        Example for ue_type == Android:

        | Pet UE Exec ADB CMD | ue=${ue1} | cmd='input tap 590 3050' |
        """
        return ue.exec_adb_command(cmd)

    def pet_ue_wakeup(self, ue=None):
        return ue.wakeup()

    def pet_pcf_simulator_setup(self, **kwargs):
        """
        This keyword will Connect to the PCF Simutor server
        PCF Simulator is a linux app that run on a centos PC

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | host | string | Y | None | PCF Simulator ip address |
        | username | string | Y | ute | username to PCF Simulator Server |
        | password | string | Y | qqwweeRR0- | password to PCF Simulator Server |
        | appname  | string | Y | sim-5g-pcf | pcf simulator process name |

        *Return:* PCF Simulator object

        *Example:*
        | ${pcf_simulator}= | Pet PCF Simulator Setup | host=10.69.9.53 | username=ute | passowrd=qqwweeRR0- |

        """
        from lib_devices.pet_pcf_simulator import c_pcf_simulator
        pcf = c_pcf_simulator(**kwargs)
        pcf.setup(kwargs.get('appname', 'sim-5g-pcf'))
        return pcf

    def pet_mcs_setup(self, **kwargs):
        """
        This keyword will setup a mcs object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | mcs_type | string | Y | jx2 | Specific MCS type, default is jx2 |
        | host | string | Y | None | MCS ip address |
        | port | string | Y | 28888 | MCS control port |
        | cpc_ip | string | Y | None | Control PC Ip of MCS |
        | username | string | Y | noklab\\csv5-tester | username for Control PC of MCS |
        | password | string | Y | Nokia123! | password for Control PC of MCS |

        *Return:* command output

        *Example:*
        | ${mcs}= | Pet MCS Setup | mcs_type=jx2 | port=28888 | cpc_ip=10.69.82.47 |

        """
        return PetShell.prepare_mcs(**kwargs)

    def pet_mcs_set_with_csv_file(self, mcs, csv_file):
        """
        This keyword will set mcs attr with given csv_file

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | mcs | object | Y | None | return from keyword: pet_mcs_setup |
        | csv_file | string | Y | None | csv file path |

        *Return:* command output

        *Example:*
        | Pet MCS Set with CSV File | mcs=${mcs} | csv_file=mydata.csv |

        """
        return PetShell.config_mcs_with_csv_file(mcs, csv_file)

    def pet_check_pcap_file(self, pcapfile, filter='', perference='', keyword='', eoption=' -e _ws.col.Info',
                            decode_option='', additional_option=''):
        """
        This keyword will check pcapfile and return lines of fit message

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | pcapfile | string | Y | None | Filename of pcap |
        | filter | string | N | None | filter for tshark, like: ngap.fiveQI == 2 |
        | perference | string | N | None | perfercen setting, like: nas-5gs.null_decipher:TRUE |
        | keyword | string | Y | None | keyword that exist in each output |
        | eoption | string | Y | None | Specific e option |
        | decode_option | string | Y | None | 指定Decode的option，例如：tcp.port==49151,ntrstr |
        | additional_option | string | Y | None | 指定其他选项 |

        *Return:*
        length of lines of tshark command

        *Example:*
        | ${msgcount}= | Pet check Pcap File | pcapfile=case.pcap | filter=ngap.fiveQI == 2 |
        | ... | keyword=PDUSessionResourceModifyRequest |
        | ${msgcount}= | Pet check Pcap File | pcapfile=case.pcap | filter=ngap.fiveQI == 2 |
        | ... | keyword=PDUSessionResourceModifyRequest | eoption=-e _ws.col.Info |

        """
        return PetShell.check_with_tshark(pcapfile, filter, perference, keyword, eoption,
                                          decode_option, additional_option)

    def tl2dict(self, objpath):
        """
        This keyword will retrieve config from tl global object

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | objpath | string | Y | None | path to the object you wish to retrieve |

        *Return:* a dict for the object you retrieve,

        *Example:*
        | ${lmp}= | TL2Dict | enbs,0;airscale;common_units,0;lmp_connection |

        """
        def _getattr(obj, attr_list=[]):
            tmp_obj = obj
            for attr in attr_list:
                if tmp_obj:
                    if ',' in attr:
                        name, index = attr.split(',')
                        if hasattr(tmp_obj, name) and getattr(tmp_obj, name):
                            tmp_obj = getattr(tmp_obj, name)[int(index)]
                        else:
                            tmp_obj = None
                    else:
                        if hasattr(tmp_obj, attr):
                            tmp_obj = getattr(tmp_obj, attr)
                        else:
                            tmp_obj = None
            return tmp_obj if tmp_obj else ''

        aobj = _getattr(gv.tl, objpath.split(';'))
        result = {}
        for attr in [x for x in dir(aobj) if not x.startswith('_')]:
            result[attr] = getattr(aobj, attr)
        return result

    def run_keyword_and_check_later(self, keyword_name, *args):
        gv.keyword_group.append(keyword_name, *args)

    def check_keyword_group(self):
        from lib_devices.common import finish_keyword_group
        finish_keyword_group(gv.keyword_group)

    def create_obj(self, name):
        return taobject(name)

    def pet_setup_iperf_server(self, **kwargs):
        return PetShell.setup_iperf_server(**kwargs)

    def pet_count_keyword_in_file(self, filename, keyword, case_senstive=False):
        """
        This keyword will return the count number of keyword in a file

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | filename | string | Y | None | filename |
        | keyword | string | Y | None | searched keyword |
        | case_sensitive | Boolean | N | False | if check case sensitive |

        *Return:* Count value

        *Example:*
        | ${count}= | Pet Count Keyword in File | filename=btslog.log | keyword=xxxx |
        | ${count}= | Pet Count Keyword in File | filename=btslog.log | keyword=xxxx | case_senstive=${False} |

        """
        lines = open(filename).read()
        if case_senstive:
            return lines.count(keyword)
        else:
            return lines.lower().count(keyword.lower())

    def pet_prepare_mcshark(self):
        """
        This keyword will install mcshark plugin according to bts version
        *Input Param:* None

        *Return:* None

        *Example:*
        | Pet Prepare Gnb log tool |
        """

        return PetShell.prepare_mcshark()

    def load_device_config(self, device_type, device_index):
        """
        This keyword will return the config for some device, such as TM500-27

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | device_type | string | Y | None | device type, like: tm500/shenick |
        | device_index | string | Y | None | device index, like: 27 |

        *Return:* A dict object whit all config of the specific device

        *Example:*
        | ${tm500_config}= | Load Device Config | device_type=tm500 | device_index=27 |

        """
        from lib_devices.common import device_config
        return device_config(device_type, device_index)

    def pet_remove_big_log_files(self, workdire):
        """
        This keyword will remove big log file if needed

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | workdire | string | Y |  | directory that to be search file for deletion |

        *Return:* None

        *Example:*
        | pet_remove_big_log_files | workdire=${CASE_DIRE} |

        """
        for root, dirs, files in os.walk(workdire, topdown=False):
            files.sort()
            for filename in files:
                fullname = os.path.join(root, filename)
                if os.path.getsize(fullname) >= gv.clean_log_size:
                    logger.info(f'clean big file: {fullname}, size: {os.path.getsize(fullname)}')
                    os.remove(fullname)

    def pet_install_build(self, tdd_btsid='', tdd_build='', tdd_customer='A54',
                          fdd_btsid='', fdd_build='', fdd_customer='A54'):
        """
        This keyword will install build for all bts you provided

        *Input Param:*
        | Parameter | Type | Man. | Default | Description |
        | tdd_btsid | string | Y |  | btsid you used in PTC |
        | tdd_build | string | Y |  | build to install for tdd bts |
        | tdd_customer | string | N | A54 | customer for build to install for tdd bts |
        | fdd_btsid | string | Y |  | btsid you used in PTC |
        | fdd_build | string | Y |  | build to install for fdd bts |
        | fdd_customer | string | N | A54 | customer for build to install for fdd bts |

        *Return:* None

        *Example:*
        | pet_install_build | tdd_btsid=1123 |
        | pet_install_build | tdd_btsid=1123 | tdd_build=SBTS00_ENB_9999_230207_000008 |
        | pet_install_build | tdd_btsid=1123,1815 | tdd_build=SBTS00_ENB_9999_230207_000008 |
        | pet_install_build | fdd_btsid=1123 |
        | pet_install_build | fdd_btsid=1123 | fdd_build=SBTS00_ENB_9999_230207_000008 |
        | pet_install_build | fdd_btsid=1123,1815 | fdd_build=SBTS00_ENB_9999_230207_000008 |
        | pet_install_build | fdd_btsid=1123,1815 | fdd_build=SBTS00_ENB_9999_230207_000008 |
        ... tdd_btsid=1123 | tdd_build=SBTS00_ENB_9999_230207_000008 |

        """

        prefix = 'sshpass -p qqwweeRR0- ssh ute@10.106.200.66 '
        options = ''
        tdd_build = tdd_build or gv.pv('${ENB_BUILD}')
        fdd_build = fdd_build or gv.pv('${ENB_BUILD}')
        if tdd_btsid and tdd_build and tdd_customer:
            options += f' -c {tdd_btsid} -t {tdd_build} -a {tdd_customer}'
        if fdd_btsid and fdd_build and fdd_customer:
            options += f' -d {fdd_btsid} -f {tdd_build} -b {tdd_customer}'
        if options:
            cmd = f'{prefix} "python3 /home/work/tacase_dev/Resource/tahelper/nbr.py {options}"'
            import subprocess
            proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
            output = []
            while True:
                line = proc.stderr.readline().decode()
                if not line:
                    break
                else:
                    logger.info(line)
                    output.append(line)
            bts_count = len(tdd_btsid.split(',') + fdd_btsid.split(','))
            logger.info(f'Total bts count: {bts_count}')
            if '\n'.join(output).lower().count('install successfully') != bts_count:
                raise Exception('Not all bts install build successfully.')
        else:
            raise Exception('No right options is provided for build install.')

    def pet_prepare_nsetup_plugin(self):
        """
        根据当前系统的版本，安装wireshark的nsetup和nsetupx插件；
        这两个插件在解析ntstr的时候有用到；

        *输入参数:* 无

        *返回值:* 无

        *示例:*
        | pet_prepare_nsetup_plugin |
        """

        PetShell.prepare_nsetap_plugin()

    def pet_pause(self, timeout=36000, msg=''):
        """
        暂停 case 执行，等到执行特定的命令后再继续;

        在 New Feature Case执行过程中，如果需要暂停 执行，进行人工干预，可以用这个keyword；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | timeout | 整数 | 否 | 36000 | 等待的时间，单位是秒 |
        | msg | 字符串 | 否 | 空白 | 打印的提示 |

        *返回值:* 无

        *示例:*
        | pet_pause |
        | pet_pause | msg=等待pm文件生成 |

        """

        if msg:
            kw('log to console', msg)
        fname = '~/.resume'
        kw('log to console', f'\n暂停执行 case，要恢复执行，可以执行命令：touch {fname} ')
        fname = os.path.expanduser(fname)
        if os.path.exists(fname):
            os.remove(fname)
        for _ in range(timeout):
            if os.path.exists(fname):
                kw('log to console', '\n继续执行case')
                return 0
            else:
                time.sleep(1)

    def pet_load_variables(self, jsonfile):
        if not os.path.exists(jsonfile):
            raise Exception('file not exists: %s' % jsonfile)
        items = json.load(open(jsonfile, encoding='utf-8'))
        for key in items:
            kw('Set Suite Variable', '${' + key.upper() + '}', items[key])
