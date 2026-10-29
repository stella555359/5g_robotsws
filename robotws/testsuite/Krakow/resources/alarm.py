from taf.rfrl.bts.devices.du.alarm_verification import GnbAlarmVerification as GnbAlarm
from taf.rfrl.bts.devices.du.alarm_verification import EnbAlarmVerification as EnbAlarm
from time import time as tm
from moler.util.moler_test import MolerTest


class Alarm(object):

    def __init__(self):
        self.bts_types = ['GNB', 'ENB']
        self.gnb_alarm = GnbAlarm()
        self.enb_alarm = EnbAlarm()

    @MolerTest.raise_background_exceptions()
    def _verify_alarm(self, fault_name, expected_alarm_status="active", timeout=120, bts_id=0, bts_type='GNB'):
        """
        Verify alarm.

        :param fault_name: full name of fault
        :param expected_alarm_status: active or inactive
        :param timeout: timeout
        :param bts_type: bts type. GNB or ENB
        :param bts_id: ID of BTS
        """

        alarm = self.gnb_alarm if bts_type == self.bts_types[0] else self.enb_alarm if bts_type == self.bts_types[1]\
            else None
        if not alarm:
            MolerTest.error("Wrong bts type - {}. Supported bts types:".format(bts_type), dump=self.bts_types,
                            raise_exception=True)
        timeout = int(timeout)
        start_time = tm()
        elapsed_time = 0
        exception = None
        while elapsed_time < timeout:
            exception = None
            try:
                if expected_alarm_status == "active":
                    alarm.verify_alarm_is_active(fault_name=fault_name, bts_id=bts_id)
                else:
                    alarm.verify_alarm_is_not_active(fault_name=fault_name, bts_id=bts_id)
            except Exception as e:
                exception = e
            if not exception:
                return
            MolerTest.sleep(15)
            elapsed_time = int(tm() - start_time)
        MolerTest.error(exception)

    @MolerTest.raise_background_exceptions()
    def wait_until_alarm_is_active_on_gnb(self, fault_name, timeout=120, bts_id=0):
        """
        Wait until alarm is active on GNB.

        :param fault_name: full name of fault
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        self._verify_alarm(fault_name, "active", timeout, bts_id, self.bts_types[0])

    @MolerTest.raise_background_exceptions()
    def wait_until_alarm_is_not_active_on_gnb(self, fault_name, timeout=120, bts_id=0):
        """
        Wait until alarm is not active on GNB.

        :param fault_name: full name of fault
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        self._verify_alarm(fault_name, "inactive", timeout, bts_id, self.bts_types[0])

    @MolerTest.raise_background_exceptions()
    def wait_until_alarm_is_active_on_enb(self, fault_name, timeout=120, bts_id=0):
        """
        Wait until alarm is active on ENB.

        :param fault_name: full name of fault
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        self._verify_alarm(fault_name, "active", timeout, bts_id, self.bts_types[1])

    @MolerTest.raise_background_exceptions()
    def wait_until_alarm_is_not_active_on_enb(self, fault_name, timeout=120, bts_id=0):
        """
        Wait until alarm is not active on ENB.

        :param fault_name: full name of fault
        :param timeout: timeout
        :param bts_id: ID of BTS
        """
        self._verify_alarm(fault_name, "inactive", timeout, bts_id, self.bts_types[1])
