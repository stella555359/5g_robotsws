# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
:maintainer: I_MN_RAN_1_HAZ_TAWG@internal.nsn.com
"""

import logging
import sys
import json
import os
import re
import time

from robot.libraries.Telnet import Telnet
from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from robot.api.deco import keyword
import traceback
from ute_fsmaccess import ute_fsmaccess

robot_obj = BuiltIn()
kw = robot_obj.run_keyword
pv = robot_obj.get_variable_value
log_console = robot_obj.log_to_console


class pkw_ap(object):

    """

    =  基本说明  =

    本库主要提供针对 ``AirPhone``,  ``CUS`` 的 keyword
    依赖下面这些库提供的keyword，因此你需要在你的robot里面引用这些库：

        --   OperatingSystem,
        --   ute_wtssim,
        --   ute_fsmaccess,
        --   taf.sbts.oam.coam.admin,

    """

    def __init__(self):
        self.ap_addr = '192.168.200.1'
        self.bts_addr = '192.168.255.129'
        self.vm_addr = '127.0.0.1'
        self.edaemon_port = 22222
        self.egate_port = 20000
        self.cus_port = 1234
        self._cus = Telnet()
        self._cus_connected = False
        self._conn_bts = False
        self._conn_ap = False
        self.alias_bts = 'BTS_' + self.bts_addr
        self.alias_ap = 'AirPhone_' + self.ap_addr
        self._import_robot_libs()

    def _import_robot_libs(self):
        robot_obj.import_library('ute_fsmaccess', 'WITH NAME', 'fsmaccess')
        robot_obj.import_library('ute_wtssim', 'WITH NAME', 'wts')
        robot_obj.import_library('taf.sbts.oam.coam.admin', 'WITH NAME', 'coam')

    def _setup_ap_conn(self):
        if not self._conn_ap:
            kw('run keyword and ignore error', 'fsmaccess.teardown_wts_fsm_access', f'alias={self.ap_addr}')
            kw('fsmaccess.setup_wts_fsm_access', f'host={self.ap_addr}', f'alias={self.ap_addr}')
            self._conn_ap = True

    def _setup_bts_conn(self):
        if not self._conn_bts:
            kw('run keyword and ignore error', 'fsmaccess.teardown_enb_fsm_access', f'alias={self.bts_addr}')
            kw('fsmaccess.Setup Enb Fsm Access', f'host={self.bts_addr}', f'alias={self.bts_addr}')
            self._conn_bts = True

    def _kill_edaemon_and_egate(self):
        log_console('Kill EGate')
        cmds = [
            "sudo pkill edaemon",
            "sudo pkill egate",
            # "sudo pkill sim_uec",
            # "sudo pkill sim_enb",
            # "sudo pkill sim_amf",
            # "sudo pkill sim_upf",
            # "sudo pkill sim_sgw",
            # "sudo pkill sim_pgw",
            "ps -ef | grep -e edaemon -e egate",
            "sudo rm -rf /opt/iphy/latest/*.log*",
            "sudo rm -rf /opt/iphy/latest/SosReport*.tgz",
        ]
        for cmd in cmds:
            kw('run', cmd)

    def _start_edaemon_and_egate(self):
        log_console('Start EGate')
        kw('run', f"cd /opt/iphy/latest && sudo ./edaemon --port {self.edaemon_port}")
        kw('sleep', '3s')
        kw('run', f"cd /opt/iphy/latest && ./egate --port {self.egate_port}")
        kw('sleep', '3s')

    def _setup_egate(self):
        log_console('Setup Egate')
        kw('run keyword and ignore error', 'wts.Teardown All Aliases For Edaemon')
        kw('run keyword and ignore error', 'wts.Teardown All Aliases For Egate')
        kw('run keyword and ignore error', 'wts.setup_egate', f'egate_port={self.egate_port}')
        kw('run keyword and ignore error', 'wts.setup_edaemon', self.edaemon_port)
        kw('run keyword and ignore error', 'wts.link_edaemons_to_egate')

    def __get_ip_for_intf(self, intf='eth3'):
        output = os.popen(f'ip addr show {intf}').read()
        return re.findall(r'([\d]{1,3}[.][\d]{1,3}[.][\d]{1,3}[.][\d]{1,3})', output)

    def _setup_ips_on_vm(self):
        log_console('Add ip address on VM:')
        ip3 = list(range(9, 16)) + list(range(100, 101)) + list(range(121, 156))
        ip3 = [f'10.0.1.{i}' for i in ip3]

        ip4 = list(range(90, 101)) + [1]
        ip4 = [f'10.0.2.{i}' for i in ip4]

        exist_ip3 = self.__get_ip_for_intf('eth3')
        exist_ip4 = self.__get_ip_for_intf('eth4')
        for ip in ip3:
            if ip not in exist_ip3:
                kw('run', f'sudo ip addr add {ip}/24 dev eth3')

        for ip in ip4:
            if ip not in exist_ip4:
                kw('run', f'sudo ip addr add {ip}/24 dev eth4')

        kw('run', 'ip addr show eth3')
        kw('run', 'ip addr show eth4')

    def _set_os_core_params_on_vm(self):
        log_console('Configure SCTP on WTS')
        cmds = [
            'sudo sysctl -w net.sctp.sack_timeout=20',
            'sudo sysctl -w net.sctp.rto_min=100',
            'sudo sysctl -w net.sctp.rto_initial=200',
            'sudo sysctl -w net.sctp.rto_max=800',
        ]
        for cmd in cmds:
            kw('run', cmd)

    def _wait_for_ip_reachable(self, ip, timeout=200):
        log_console(f'Wait for {ip} reachable')
        for _ in range(timeout):
            if os.system(f'ping -c 1 -W 2 {ip} >/dev/null') == 0:
                logger.info(f'{ip} is reachable')
                return 0
            else:
                time.sleep(1)
        raise Exception(f'{ip} could not reachable in {timeout} seconds')

    @keyword
    def setup_for_ap(self, **kwargs):
        '''
        这个 keyword 主要给需要使用AipPhone的case准备环境，

        通常在Common Suite Setup之后，调用此keyword

        基本逻辑是：准备好 wts，BTS 和 AP，

        要注意：这里提供了机会来换基站的scf；如果这里换了，case里面可以酌情不换scf；

        主要工作：
        -   在VM上配置各种需要的ip地址；
        -   在VM上设置 os 内核相关的参数；
        -   在VM上杀掉 egate 相关的进程；
        -   在VM上启动 egate 相关的进程；
        -   连接到egate，然后载入指定的wts_cfg文件
        -   根据给定的参数，换AP的iphy.xml, AP的swconfig, 重启AP
        -   根据给定的参数，换基站的 scf 和 swconfig，重启基站；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | wts_cfg | 字符串 | 否 |  | wts的配置文件的路径，如果设置了，会到egate里面载入这个配置文件 |
        | cus_yaml | 字符串 | 否 |  | CUS 的配置文件, 如果使用了CUS，开始的时候可以load这个文件 |
        | egate_log_level | 整数 | 否 | 2 | 设置 Egate的log level |
        | iphy_xml | 字符串 | 否 |  | 给 AP 准备的iphy.xml文件的路径，如果提供了这个文件，会传送到 AP 上，然后重启 AP |
        | iphy_swconfig | 字符串 | 否 |  | 给 AP 准备的 swconfig 文件的路径，如果提供了这个文件，会传送到 AP 上，然后重启 AP |
        | scf_file | 字符串 | 否 |  | 给基站准备的scf文件路径，如果指定了这个文件，会做 FullCommission |
        | swconfig | 字符串 | 否 |  | 给基站准备的swconfig文件路径，如果指定了，会传送到基站上，然后重启基站 |
        | vcu_0_scf | 字符串 | 否 |  | 给 vcu_0 准备的 scf 文件路径，如果指定了这个文件，会做 vcu_0 的 FullCommission,缺省无 |
        | vdu_0_scf | 字符串 | 否 |  | 给 vdu_0 准备的 scf 文件路径，如果指定了这个文件，会做 vdu_0 的 FullCommission,缺省无 |
        | vdu_1_scf | 字符串 | 否 |  | 给 vdu_1 准备的 scf 文件路径，如果指定了这个文件，会做 vdu_1 的 FullCommission,缺省无 |
        | reset_vcu_0 | 字符串 | 否 |  | 是否要重启 vcu_0, 缺省 NO |
        | reset_vdu_0 | 字符串 | 否 |  | 是否要重启 vdu_0, 缺省 NO |
        | reset_vdu_1 | 字符串 | 否 |  | 是否要重启 vdu_1, 缺省 NO |
        | restart_ap | 字符串 | 否 |  | 是否要重启 Airphone, 缺省 NO |

        *特别说明*
        -   如果只指定了swconfig文件，没有scf_file，只会上传swconfig, 重启基站；这里没有等待onAir
        -   如果只指定了scf_file, 没有swconfig, 只会做full commission; full commission后基站会重启，但是状态未知；
        -   如果既指定了swconfig, 又指定了scf_file，那么会先上传swconfig，然后做full commission
        -   如果是debug模式 ${DEBUG_MODE}==YES, 那么既不上传swconfig，也不做full commission
        -   这里基站和AP的重启，会自动判断是否有 ${tl} 这个变量，如果有，从${tl}中获取相应的PDU的信息，从而实现重启；否则 reboot 命令重启；

        *返回值:* 无

        '''

        if not self._use_ap:
            return 0
        # self._wait_for_ip_reachable(self.bts_addr, 200)
        self._wait_for_ip_reachable(self.ap_addr, 200)
        self._setup_ap_conn()
        self._setup_bts_conn()
        wts_cfg = kwargs.get('wts_cfg')
        egate_log_level = kwargs.get('egate_log_level', '2')
        iphy_xml = kwargs.get('iphy_xml', '')
        cus_yaml = kwargs.get('cus_yaml', '')
        iphy_swconfig = kwargs.get('iphy_swconfig', '')
        scf_file = kwargs.get('scf_file', '')
        swconfig = kwargs.get('swconfig', '')
        expect_wts_state = kwargs.get('expect_wts_state', 'CONFIGURED')
        force_restart_ap = kwargs.get('restart_ap', 'NO')
        force_restart_ap = force_restart_ap.upper() in ['Y', 'YES', 'TRUE']
        init_wts = kwargs.get('init_wts', 'N').upper() in ['Y', 'YES', 'TRUE']
        vcu_0_scf = kwargs.get('vcu_0_scf', '')
        vdu_0_scf = kwargs.get('vdu_0_scf', '')
        vdu_1_scf = kwargs.get('vdu_1_scf', '')

        reset_vcu_0 = kwargs.get('reset_vcu_0', 'NO').upper() in ['Y', 'YES', 'TRUE']
        reset_vdu_0 = kwargs.get('reset_vdu_0', 'NO').upper() in ['Y', 'YES', 'TRUE']
        reset_vdu_1 = kwargs.get('reset_vdu_1', 'NO').upper() in ['Y', 'YES', 'TRUE']

        if self._use_cus:
            log_console('CUS TA Environment')
            self._prepare_for_cus()
            self._setup_egate()
            if cus_yaml:
                self._wait_for_ip_reachable('192.168.255.129', 200)
                self._wait_for_ip_reachable('192.168.200.1', 200)
                kw('pet_execute_cus_cmd', f'cmd=config update {cus_yaml}')
                kw('sleep', '10s')
                kw('pet_execute_cus_cmd', f'cmd=config remote update')
                kw('sleep', '10s')
                self._wait_for_ip_reachable('192.168.255.129', 200)
                self._wait_for_ip_reachable('192.168.200.1', 200)
                kw('wts.execute_egate_command', "start")
                self._wait_for_ip_reachable('192.168.255.129', 200)
                self._wait_for_ip_reachable('192.168.200.1', 200)
                kw('sleep', '10s')
        else:
            log_console('AP Environment')
            self._setup_ips_on_vm()
            self._set_os_core_params_on_vm()
            self._kill_edaemon_and_egate()
            self._start_edaemon_and_egate()
            self._setup_egate()

            if wts_cfg:
                log_console(f'Load WTS config: {wts_cfg}')
                kw('wts.execute_egate_command', f'cmd=cfg file={wts_cfg}',
                   f'pass_regexp=CHANGE STATE: {expect_wts_state}', 'timeout=120')
            kw('wts.execute_egate_command', f'cmd=debug_log level={egate_log_level}')
            kw('wts.execute_egate_command', "cmd=uec_param id=1 srb_reordering_enabled=on")
            kw('wts.execute_egate_command', "cmd=debug_log")

        # #  如果有iphy.xml文件，那么把这个文件放到ap上，然后重启ap

        self._wait_for_ip_reachable(self.ap_addr, 200)
        if iphy_xml:
            log_console(f'Replace iphy file: {iphy_xml}')
            kw('fsmaccess.put_wts_config_file', iphy_xml, f'alias={self.ap_addr}')
        if iphy_swconfig:
            log_console(f'Replace iphy swconfig file: {iphy_swconfig}')
            kw('fsmaccess.put_wts_file', iphy_swconfig, '/ffs/run/swconfig.txt', f'alias={self.ap_addr}')
        if not self._use_cus:
            if iphy_xml or iphy_swconfig or force_restart_ap:
                log_console('Restart AP')
                kw('fsmaccess.execute_command_on_wts', 'reboot', f'alias={self.ap_addr}')
                kw('sleep', '30s')
                self._wait_for_ip_reachable('192.168.200.1', 200)

        #  如果有swconfig，传到基站上；
        #  如果有scf_file, 做full commission
        if not pv('${DEBUG_MODE}', 'N').upper() in ['Y', 'YES', 'TRUE']:
            bts_restarted = False
            if swconfig:
                log_console(f'Replace Bts swconfig: {swconfig}')
                kw('fsmaccess.put_enb_file', swconfig, '/ffs/run/swconfig.txt', f'alias={self.bts_addr}')
            if scf_file:
                log_console(f'Apply SCF: {scf_file}')
                kw('Run keyword and ignore error', 'coam.teardown_admin', 'master')
                try:
                    kw('coam.setup_admin', f'bts_host={self.bts_addr}', 'name=master', 'use_ssl=True', 'timeout=60')
                    kw('coam.perform_commissioning', 'scf_file=' + scf_file, 'connection=master', 'timeout=900')
                    bts_restarted = True
                finally:
                    kw('Run keyword and ignore error', 'coam.teardown_admin', 'master')

            if not bts_restarted and bool(swconfig):
                log_console('\nRestart GNB')
                kw('Run keyword and ignore error', 'coam.teardown_admin', 'master')
                try:
                    kw('coam.setup_admin', f'bts_host={self.bts_addr}', 'name=master', 'use_ssl=True', 'timeout=60')
                    kw('coam.reset_site', 'connection=master')
                    bts_restarted = True
                finally:
                    kw('Run keyword and ignore error', 'coam.teardown_admin', 'master')
                log_console('\nRestart GNB Done.')
        else:
            log_console('It is debug mode, does not operate on bts')

        if vcu_0_scf:
            log_console(f'Apply VCU0 SCF: {vcu_0_scf}')
            kw('paic_perform_full_commission', 'vcu_0', vcu_0_scf)

        if vdu_0_scf:
            log_console(f'Apply VDU0 SCF: {vdu_0_scf}')
            kw('paic_perform_full_commission', 'vdu_0', vdu_0_scf)

        if vdu_1_scf:
            log_console(f'Apply VDU1 SCF: {vdu_1_scf}')
            kw('paic_perform_full_commission', 'vdu_1', vdu_1_scf)

        if reset_vcu_0:
            log_console('Reset VCU0')
            kw('paic_reset_unit', 'vcu_0')

        if reset_vdu_0:
            log_console('Reset VDU0')
            kw('paic_reset_unit', 'vdu_0')

        if reset_vdu_1:
            log_console('Reset VDU1')
            kw('paic_reset_unit', 'vdu_1')

    @keyword
    def pet_execute_uex_command(self, cmd):
        '''
        这个 keyword 在UExGate上执行命令；
        --   UExGate是一个tool，安装在CUS的vm上，要启动它，执行：uexgate 命令就会启动；
        --   示例命令：sib_status
        --   官方文档：https://confluence.ext.net.nokia.com/display/RTG/UExGate+Commands+Reference

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | cmd | 字符串  | 是 |  | 执行的命令 |
        | delay | 浮点数  | 否 | 0.2 | 等待多久后读取输出，缺省是0.2秒，如果命令等待时间长，加大这个值即可 |

        *返回值:* 命令的输出；

        *示例:*

        | ${output} | pet_execute_cus_cmd | help |

        '''
        robot_obj.log("Execute UEx command:{}".format(cmd))
        uexgate_obj = robot_obj.get_library_instance("ta_uexgate")
        out = uexgate_obj.run_uex_command(cmd)
        if cmd.startswith("get"):
            pretty_json = json.dumps(out, indent=4)
            robot_obj.log("Uex command output:")
            robot_obj.log(pretty_json)
        else:
            robot_obj.log("Uex command output:{}".format(out))
        return out

    @property
    def _use_cus(self):
        return os.path.exists('/opt/cus/bin')

    @property
    def _use_ap(self):
        return os.path.exists('/opt/iphy/latest')

    def _sync_ue_sim_dump(self):
        log_console('Sync ue sim dump')
        kw('run', 'ls -l /opt/cus/bin/uesim-dump')
        kw('run', 'ls -l /opt/emssim/util/uesim-dump*')
        kw('run', 'sudo rm -f /opt/emssim/util/uesim-dump')
        kw('run', 'sudo cp -f /opt/cus/bin/uesim-dump /opt/emssim/util/uesim-dump')
        kw('run', 'sudo chmod 777 /opt/emssim/util/uesim-dump')

    def _remove_ue_setup_log(self):
        path = pv('${RESULT_DIR}')
        if path:
            kw('run', f'rm -rf {path}/taf.ul.ue.sim.env_setup*.log')

    def _prepare_for_cus(self):
        self._sync_ue_sim_dump()
        self._remove_ue_setup_log()

    @keyword
    def pet_execute_cus_cmd(self, cmd, delay=0.2):
        '''
        这个 keyword 在 CUS 上执行命令，等效的效果是在 VM 上 telnet 0 1234, 然后执行命令；

        例如：如果要载入 cus 的yaml 配置文件，可以用命令 config update cus_xxx.yaml

        这个 CUS 的进程是 VM 开机就会启动的，不需要命令来启动；

        *输入参数:*
        | 参数名称 | 类型 | 是否必须 | 缺省值 | 参数描述 |
        | cmd | 字符串  | 是 |  | 执行的命令 |
        | delay | 浮点数  | 否 | 0.2 | 等待多久后读取输出，缺省是0.2秒，如果命令等待时间长，加大这个值即可 |

        *返回值:* 命令的输出；

        *示例:*

        | ${output} | pet_execute_cus_cmd | help |

        '''
        if not self._cus_connected:
            self._cus.open_connection(host=self.vm_addr, port=self.cus_port,
                                      prompt='CUS>', window_size='300x24', timeout=60,
                                      alias='cus')
            lines = self._cus.read().splitlines()
            for line in lines:
                print(line)
            self._cus_connected = True
        else:
            self._cus.switch_connection('cus')
        logger.info(f'Run CUS command: {cmd}')
        self._cus.write(cmd)
        time.sleep(delay)
        output = self._cus.read_until_prompt()
        logger.info('CUS Command Response:')
        for line in output.splitlines():
            print(line)
            # logger.debug('<===    ' + line)
        return output

    def _release_ues(self):
        out = kw('pet_execute_uex_command', 'get_ue_summary')
        for ue_id in out.get("active", []) + out.get("idle", []):
            kw('Run keyword and ignore error', 'pet_execute_uex_command', f'detach id={ue_id}')

    @keyword
    def release_all_cus_ues(self):
        '''
        释放所有 cus 的 case 中 attach 过的 ue

        *输入参数:* 无

        *返回值:* 无；

        *示例:*

        | release_all_cus_ues |
        '''

        self._release_ues()
        self._release_ues()

    @keyword
    def teardown_ap(self):
        '''
        给 Airphone 的case准备的Teardown，主要包括：

        ---  所有 UE 的解注册

        *输入参数:* 无

        *返回值:* 无；

        *示例:*

        | teardown_ap |
        '''

        if self._use_cus:
            kw('release_all_cus_ues')

    def wait_until_found_expect_msg_in_egate_console_log(self, regstr, timeout=90, interval=1, expect_times=2):
        '''
            regstr, 如果是广播消息,应该是: SystemInformationBlockType[1-6]-NR
        '''
        fname = '/opt/iphy/latest/egate_console.log'
        ctime = time.time()
        while time.time() < ctime + int(timeout):
            kw('wts.execute_egate_command', "cmd=set_log flush")
            if os.path.exists(fname):
                lines = open(fname).read().lower()
                found_times = len(re.findall(regstr, lines, re.IGNORECASE))
                logger.info(f'Found [{regstr}] {found_times} times.')
                if found_times >= expect_times:
                    return 0
            time.sleep(int(interval))
        raise Exception(f'Could not find {regstr} {expect_times} times in {timeout}s.')

    def load_lib_for_cus(self):
        kw('Import Library', 'ta_messaging')
        kw('Import Library', 'ta_uexgate')
        kw('Import Library', 'ute_wtssim')


if __name__ == '__main__':
    import logging
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    logging.info('OK')
    ap = pkw_ap()
