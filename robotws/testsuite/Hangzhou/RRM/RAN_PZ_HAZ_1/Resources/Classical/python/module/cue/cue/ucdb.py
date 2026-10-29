# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import logging
import json
from pprint import pprint
from types import SimpleNamespace

try:
    from rethinkdb import RethinkDB
except Exception as E:
    print('Install Rethink DB ...')
    os.system('python -m pip install rethinkdb')
    from rethinkdb import RethinkDB

PHASE_RUNNING = ['running']
PHASE_COMPLETED = ['completed']


class UcDB(object):

    def __init__(self, host: str = '10.69.69.234', logger: logging.Logger = None) -> None:
        self.logger = logger or logging.getLogger(__name__)
        from rethinkdb import RethinkDB
        self.rdb = RethinkDB()
        self.connection = self.rdb.connect(host=host, port=28015)
        self.db = self.rdb.db('uc')

    def _aobj(self, p: list) -> object:
        if p:
            return p[0]
        else:
            return None

    def table(self, tablename: str) -> list:
        return list(self.db.table(tablename).run(self.connection))

    def ueinfo(self, serialno: str = '', imei: str = '') -> dict:
        ues = self.table('ues')
        if serialno:
            ues = [x for x in ues if x['deviceId'].lower() == serialno.lower()]
        if imei:
            ues = [x for x in ues if x['imei'].lower() == imei.lower()]
        return self._aobj(ues)

    def test(self, testname: str) -> dict:
        test = [x for x in self.table('single_tests') if x['name'] == testname]
        return self._aobj(test)

    def test_exists(self, testname: str) -> bool:
        return len(list(self.test(testname))) > 0

    def test_status(self, testname: str = '', imei: str = '', testId: str = '') -> list:
        rows = [x for x in self.table('single_test_status')]
        if testname:
            rows = [x for x in rows if x['name'].lower() == testname.lower()]
        if imei:
            rows = [x for x in rows if x['ue']['imei'] == imei]
        if testId:
            rows = [x for x in rows if x['testId'] == testId]
        return rows

    def _test_is_running(self, test: dict) -> bool:
        return test['phase'] in PHASE_RUNNING

    def _test_is_completed(self, test: dict) -> bool:
        return test['phase'] in PHASE_COMPLETED

    def running_test(self, imei: str, testname: str = '') -> list:
        tests = [x for x in self.test_status(imei=imei) if self._test_is_running(x)]
        if testname:
            tests = [x for x in tests if x['name'].lower() == testname.lower()]
        return tests

    def non_completed_test(self, imei: str, testname: str = '') -> list:
        tests = [x for x in self.test_status(imei=imei) if not self._test_is_completed(x)]
        if testname:
            tests = [x for x in tests if x['name'].lower() == testname.lower()]
        return tests

    def wait_until_test_started(self, testId: str, timeout: int = 120) -> None:
        start_time = time.time()
        while time.time() - start_time < timeout:
            test = self.test_status(testId=testId)[0]
            self.logger.info(f'Test: {test["name"]}, Phase: {test["phase"]}, Expected: running')
            if self._test_is_running(test):
                return
            time.sleep(2)
        raise Exception(f'Test {testId} is not running after {timeout} seconds')

    def wait_until_test_stopped(self, testId: str, timeout: int = 120) -> None:
        start_time = time.time()
        while time.time() - start_time < timeout:
            test = self.test_status(testId=testId)[0]
            self.logger.info(f'Test: {test["name"]}, Phase: {test["phase"]}, Expected: completed')
            if self._test_is_completed(test):
                return
            time.sleep(2)
        raise Exception(f'Test {testId} is not completed after {timeout} seconds')

    def test_result(self, testId: str = '') -> list:
        rows = [x for x in self.table('single_test_results')]
        if testId:
            rows = [x for x in rows if x['testId'] == testId]
        return rows

    def delete_test_result(self, testId: str) -> None:
        result = self.db.table('single_test_results').filter({'testId': testId}).delete().run(self.connection)
        self.logger.info('Deleted test result records:', result)
        result = self.db.table('single_test_status').filter({'testId': testId}).delete().run(self.connection)
        self.logger.info('Deleted test status records:', result)

    def sequence(self, sequence_name: str) -> dict:
        seq = [x for x in self.table('test_sequences') if x['name'].lower() == sequence_name.lower()]
        return self._aobj(seq)

    def sequence_status(self, sequence_name: str = '', imei: str = '', testSequenceId: str = '') -> dict:
        status = [x for x in self.table('seq_status')]
        if sequence_name:
            status = [x for x in status if x['name'].lower() == sequence_name.lower()]
        if imei:
            status = [x for x in status if x['ue']['imei'] == imei]
        if testSequenceId:
            status = [x for x in status if x['testSequenceId'] == testSequenceId]
        return status

    def _sequence_is_completed(self, sequence):
        return sequence['status'] in PHASE_COMPLETED

    def _sequence_is_running(self, sequence):
        return sequence['status'] in PHASE_RUNNING

    def running_sequence(self, imei: str = '', sequence_name: str = '') -> list:
        seqs = [x for x in self.sequence_status(imei=imei, sequence_name=sequence_name)
                if self._sequence_is_running(x)]
        return seqs

    def non_completed_sequence(self, imei: str = '', sequence_name: str = '') -> list:
        seqs = [x for x in self.sequence_status(imei=imei, sequence_name=sequence_name)
                if not self._sequence_is_completed(x)]
        return seqs

    def wait_until_sequence_started(self, testSequenceId: str, timeout: int = 120) -> None:
        start_time = time.time()
        while time.time() - start_time < timeout:
            seq = self.sequence_status(testSequenceId=testSequenceId)[0]
            self.logger.info(f'Sequence: {seq["name"]}, Phase: {seq["status"]}')
            if self._sequence_is_running(seq):
                return
            time.sleep(2)
        raise Exception(f'Sequence {testSequenceId} is not running after {timeout} seconds')

    def wait_until_sequence_completed(self, testSequenceId: str, timeout: int = 120) -> None:
        start_time = time.time()
        while time.time() - start_time < timeout:
            seq = self.sequence_status(testSequenceId=testSequenceId)[0]
            self.logger.info(f'Sequence: {seq["name"]}, Phase: {seq["status"]}')
            if self._sequence_is_completed(seq):
                return
            time.sleep(2)
        raise Exception(f'Sequence {testSequenceId} is not completed after {timeout} seconds')


if __name__ == '__main__':
    logging.basicConfig(format='%(asctime)s [%(levelname)5s] %(message)s', datefmt='%Y-%m-%d %H:%M:%S',
                        level=logging.DEBUG)
    logger = logging.getLogger('ucdb')
    logger.setLevel(logging.DEBUG)
    host = '10.69.69.234'
    udb = UcDB(host, logger)
    ues = udb.table('ues')
    # pprint(udb.ueinfo('8885dec7'))
    # pprint(udb.sequence('tq1'))
    pprint(udb.sequence_status(imei='863561060096804'))
    # pprint(udb.test_status(imei='863561060096804'))
    # pprint(udb.running_test(imei='863561060096804'))
    # pprint(udb.wait_until_test_is_running(testId='a8711199-4018-4cf8-8f60-30e0f8270685'))
    # pprint(udb.wait_until_test_is_completed(testId='5799ae66-b2ca-4728-a9b4-75ce2d74b032'))
