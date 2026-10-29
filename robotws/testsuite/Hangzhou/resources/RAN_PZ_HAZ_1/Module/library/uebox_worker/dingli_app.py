# -*- coding: utf-8 -*-

"""
:copyright: Nokia
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
:maintainer: fei.ju@nokia-sbell.com
"""

import time
import logging
import os
from pprint import pformat
from robot.libraries.OperatingSystem import OperatingSystem
from library.uebox_worker.spark_app import SparkApp

os_obj = OperatingSystem()


class DingliApp(SparkApp):

    def __init__(self, hostname: str, port: int = 30999, logger: logging.Logger = None) -> None:
        super().__init__(hostname, port, logger)
        self.logged = False

    def __repr__(self) -> str:
        return f'UeBoxApp(Dingli, {self.hostname}, {self.port})'

    def setup(self):
        if not self.setuped:
            self.logger.info(f'Setup for {self}')
            try:
                if self.cpc.find_process(['Pioneer.exe']):
                    self.logger.info('pioneer exist')
                    self._disconnect_ue()
                else:
                    self.logger.info('pioneer not exist')
            except Exception:
                pass
            self._shutdown()
            self.wait(5, 'Startup APP...')
            self._startup()
            self.wait(60, 'APP ready...')
            self._wait_until_app_started()
            # self.ue_count = self._auto_check()['Param']['Count']
            self.ue_count = int(self._auto_check_hard())
            time.sleep(5)
            try:
                self._disconnect_ue()
            except Exception:
                pass
            time.sleep(5)
            self._connect_ue()
            time.sleep(5)
            self._poweroff()
            time.sleep(5)
            self._poweron()
            if len(self.ues) == 0:
                for ueindex in range(1, self.ue_count+1):
                    imsi = self._get_imsi(ueindex)
                    self.ues[imsi] = ueindex
            self.logger.info(f'Total {self.ue_count} UEs connected.')
            self.logger.info(f'UEs: {pformat(self.ues)}')
            self.setuped = True
        else:
            self.logger.info(f'UEBox {self} already setuped.')

    def _wait_until_app_started(self):
        self.logger.info('Wait until Dingli APP started')
        for _ in range(60 * 4):
            try:
                resp = self._auto_check(timeout=60)
                if self._resp_state(resp) == 0 and resp.get('Param', {}).get('Count', -1) > 0:
                    break
            except Exception as E:
                pass
            time.sleep(1)
        self.logger.info('Dingli APP started')

    def _poweroff(self, EQIndex: int = -1) -> None:
        if EQIndex == -1:
            self.logger.info('Poweroff All UE')
            for ueindex in range(1, self.ue_count+1):
                self.exec_at_cmd(ueindex, self.AT_SIM_PLUGOUT.lower(), retry_times=3)
        else:
            self.logger.info(f'Poweroff UE: {EQIndex}')
            self.exec_at_cmd(EQIndex, self.AT_SIM_PLUGOUT.lower(), retry_times=3)

    def _poweron(self, EQIndex: int = -1) -> None:
        if EQIndex == -1:
            self.logger.info('PowerOn All UE')
            for ueindex in range(1, self.ue_count+1):
                self.exec_at_cmd(ueindex, self.AT_SIM_PLUGIN.lower(), retry_times=3)
        else:
            self.logger.info(f'Poweron UE: {EQIndex}')
            self.exec_at_cmd(EQIndex, self.AT_SIM_PLUGIN.lower(), retry_times=3)

    def _shutdown(self):
        self.logger.info('Shutdown APP')
        # self.cpc.exec_psexec('/s taskkill /f /im Pioneer.exe')
        return self.exec_cmd({"CMD": "Shutdown"})

    def _startup(self):
        self.logger.info('Startup APP')
        # self.cpc.exec_psexec(f' -s "{self.config.app_path}"')
        return self.exec_cmd({"CMD": "Startup"})

    def _attached(self, EQIndex: int) -> bool:
        self.logger.debug(f'Check {self._eqindex2imsi(EQIndex)} Status')
        status = self._get_status(EQIndex)
        return status['AttachStatus'].lower() == 'Attached'.lower()

    def detach(self, EQIndex: int) -> dict:
        self.logger.info(f'Detach UE: {self._eqindex2imsi(EQIndex)}')
        if self._attached(EQIndex):
            resp = self.exec_at_cmd(EQIndex, 'AT+CFUN=0')
            self._wait_until_ue_detached(EQIndex)
            self.logger.info(f'UE {self._eqindex2imsi(EQIndex)} is detached')
            return resp
        else:
            self.logger.info(f'UE {self._eqindex2imsi(EQIndex)} is already detached')

    def _create_testplan(self, EQIndex: int, TestPlansLocation: str) -> dict:
        self.logger.info(f'Create Test plan for {EQIndex} with {TestPlansLocation}')
        return self.exec_cmd(
            {"CMD": "CreateTestPlan",
             "EQIndex": EQIndex,
             "Param": {
                 "TestPlansLocation": TestPlansLocation}})

    def start_testplan(self, EQIndex: int, TestPlansLocation: str) -> dict:
        resp = self._create_testplan(EQIndex, TestPlansLocation)
        if resp.get('Param', {}).get('State', -1) == 0:
            return self._start_test(EQIndex)
        else:
            raise Exception(f'Create Test Plan failed, {resp} ')

    def stop_testplan(self, EQIndex: int) -> dict:
        self.logger.info(f'Stop test for {EQIndex}')
        return self._stop_test(EQIndex)

    def get_throughput(self, EQIndex: int, direction: str) -> dict:
        self.logger.info(f'Get throughput for {EQIndex}')
        resp = self.exec_cmd(
            {
                "CMD": "GetParamMAC",
                "EQIndex": EQIndex
            })
        if self._resp_state(resp) == 0:
            if direction.upper() == 'UL':
                return resp['Param']['MACUL']/1000/1000
            elif direction.upper() == 'DL':
                return resp['Param']['MACDL']/1000/1000
            else:
                raise Exception(f'Invalid direction {direction}')

    def start_log(self, EQIndex: int = -1, LogPath: str = 'c:\\uelog', LogName: str = 'Auto') -> dict:
        if not self.logged:
            resp = self.exec_cmd(
                {"CMD": "StartLog",
                 "Param": {
                     "LogPath": LogPath,
                     "LogName": LogName}})
            if self._resp_state(resp) == 0:
                self.logged = True
                self.logger.info(f'UE log started, {resp}')
            else:
                raise Exception(f'Start UE log failed, {resp}')

    def stop_log(self, EQIndex: int = -1) -> dict:
        if self.logged:
            resp = self.exec_cmd({"CMD": "StopLog"})
            if self._resp_state(resp) == 0:
                self.logged = False
                self.logger.info(f'UE log stopped, {resp}')
            else:
                raise Exception(f'Stop UE log failed, {resp}')

    def _get_status(self, EQIndex: int) -> dict:
        resp = self.exec_cmd({"CMD": "GetAttachStatus", "EQIndex": EQIndex})
        if self._resp_state(resp) == 0:
            return resp.get('Param', {})
        else:
            raise Exception(f'Get Attach Status failed, {resp}')

    def get_cell_info(self, EQIndex: int):
        '''
        2024-06-04 14:33:37 [DEBUG] API RECV: <==== {'CMD': 'GetAttachStatus',
        'EQIndex': 1,
        'Param': {'AttachStatus': 'Attached',
                'CellInfoList': [{'BTSId': '16777215',
                                    'Bandwidth': '100MHz',
                                    'CellType': '5G_SA',
                                    'Earfcn': '645984',
                                    'PCI': '1007',
                                    'RSRP0': '-85.11dBm',
                                    'RSRP1': '-53.22dBm',
                                    'SINR0': '31.70dB',
                                    'SINR1': '36.36dB'}],
                'State': 0}}
        '''
        resp = self.exec_cmd({"CMD": "GetAttachStatus", "EQIndex": EQIndex})
        if self._resp_state(resp) == 1:
            cellinfo = resp['Param']['CellInfoList']
            if cellinfo:
                return cellinfo[0]
            else:
                raise Exception(f'No cell info found for {EQIndex}')
        else:
            raise Exception(f'Get Attach Status failed, {resp}')

    def _attach(self, EQIndex: int) -> dict:
        self.logger.info(f'Attach UE: {self._eqindex2imsi(EQIndex)}')
        resp = self.exec_at_cmd(EQIndex, 'AT+CFUN=1')
        time.sleep(5)
        self._wait_until_ue_attached(EQIndex)
        self.logger.info(f'UE {self._eqindex2imsi(EQIndex)} is attached')
        return resp

    def attach(self, EQIndex: int, forced: bool = False, expected_pci: str = '-1') -> dict:
        attached = self._attached(EQIndex)
        resp = None
        if forced and attached:
            self.logger.info('UE is already attached, detach first.')
            self.detach(EQIndex)
            resp = self._attach(EQIndex)
        if not attached:
            resp = self._attach(EQIndex)
        if expected_pci != '-1':
            pcis = [x['PCI'] for x in self._get_status(EQIndex).get('CellInfoList', [])]
            if expected_pci not in pcis:
                raise Exception(f'UE {EQIndex} attach failed, expected PCI {expected_pci} not found, found {pcis}')
            else:
                self.logger.info(f'UE {EQIndex} attach success, expected PCI {expected_pci} found')
        return resp

    def fetch_log(self, EQIndex: int, LogPath: str, LogName: str, LocalDire: str) -> None:
        LocalDire = os.path.abspath(os.path.expanduser(LocalDire))
        os.makedirs(LocalDire, exist_ok=True)
        # self.cpc.execute(f'dir {LogPath}')
        username = self.cpc.username.replace('\\', '\\\\')
        LogPath = LogPath.replace('\\', '/')
        cmd = (f'sshpass -p {self.cpc.password} scp -P {self.cpc.port} -o StrictHostKeyChecking=no '
               '-o UserKnownHostsFile=/dev/null '
               f'{username}@{self.cpc.hostname}:{LogPath}/UE{EQIndex}_{LogName}*.ddib {LocalDire}/')
        os_obj.run(cmd)
