import os
import socket
from time import sleep
from datetime import datetime, timedelta
from robot.libraries.BuiltIn import BuiltIn
from taf.sbts.oam.coam.admin import admin
from taf.rfrl.utilities.tl_config import tl
from taf.ul.sc.perf.messenger.messenger import Messenger, Message
from taf.rfrl.utilities.robot.general import get_builtin_value
from taf.rfrl.procedures.resources.python.logger import log_warning, log_exception, log_operation, log_input_and_output


class StopAndFix:
    def __init__(self):
        self._truck_roll_fault_ids = [10, 1806, 4341, 4383, 4352]
        self._stop_time = 0
        self._logs_path = '/tmp/stop_and_fix_logs'
        self._admin_alias = 'stop_and_fix'
        self._bts_type = None
        self._current_alarms = {}
        self._stop_reason = {}
        self._bts_mplane_ip = {}
        self._admin_client = admin()

    @log_input_and_output
    def stop_and_fix(self, bts_type='all', stop_time=60, logs_path=None):
        """
        Stops test execution and collects proper logs if meet any of the truck roll conditions.

        :param bts_type: gnb or enb or all
        :type bts_type: str
        :param stop_time: time (in seconds) for which test execution will be stopped;
                          defaults to 24 hours.
        :type stop_time: int
        :param logs_path: absolute path of directory to which logs will be collected
                          i.e. '/home/ute/stop_and_fix_logs';
                          defaults to None (default path in /tmp dir will be used).
        :type logs_path: str
        """
        self._stop_time = stop_time
        self._logs_path = logs_path if logs_path is not None else self._logs_path
        self._bts_type = bts_type.lower()
        self._current_alarms = {}
        self._stop_reason["need_stop"] = False
        self._stop_reason["stop_reason"] = []
        self._bts_mplane_ip = {}

        self._check_bts_is_pingable()
        self._check_bts_alarms()
        self._need_stop_and_fix()

    @log_input_and_output
    def _check_bts_is_pingable(self):
        if not self._ip_is_reachable("192.168.255.1"):
            log_exception("[192.168.255.1] LMP address is not pingable from Workstation")
            self._stop_reason["need_stop"] = True
            self._stop_reason["stop_reason"].append("[192.168.255.1] LMP address is not pingable from Workstation")
        else:
            log_operation("[192.168.255.1] LMP address is pingable from Workstation")

        gnb_mplane_ip_dict = {}
        enb_mplace_ip_dict = {}
        if self._bts_type.lower() == "gnb":
            if tl.gnbs:
                for gnb_id, gnb in enumerate(tl.gnbs):
                    gnb_mplane_ip_dict[gnb_id] = gnb.cu.oam_http_connection_details.addr
                self._bts_mplane_ip["gnb"] = gnb_mplane_ip_dict
            else:
                log_exception("Haven't config gnbs in __init__.py, please confirm configuration is right!!!")
        elif self._bts_type.lower() == "enb":
            if tl.enbs:
                for enb_id, enb in enumerate(tl.enbs):
                    try:
                        enb_mplace_ip_dict[enb_id] = enb.oam_ip.v4
                    except Exception as e:
                        enb_mplace_ip_dict[enb_id] = enb.x2_link_addr.v4
                self._bts_mplane_ip["enb"] = enb_mplace_ip_dict
            else:
                log_exception("Haven't config enbs in __init__.py, please confirm configuration is right!!!")
        else:
            if tl.gnbs:
                for gnb_id, gnb in enumerate(tl.gnbs):
                    gnb_mplane_ip_dict[gnb_id] = gnb.cu.oam_http_connection_details.addr
                self._bts_mplane_ip["gnb"] = gnb_mplane_ip_dict
            if tl.enbs:
                for enb_id, enb in enumerate(tl.enbs):
                    try:
                        enb_mplace_ip_dict[enb_id] = enb.oam_ip.v4
                    except Exception as e:
                        enb_mplace_ip_dict[enb_id] = enb.x2_link_addr.v4
                self._bts_mplane_ip["enb"] = enb_mplace_ip_dict

        for bts_type, btss_mplane in self._bts_mplane_ip.items():
            for bts_id, mplane in btss_mplane.items():
                if not self._ip_is_reachable(mplane):
                    log_exception("[{}{}:{}] Mplane address is not pingable from Workstation".
                                  format(bts_type, bts_id, mplane))
                    self._stop_reason["need_stop"] = True
                    self._stop_reason["stop_reason"].append(
                        "[{}{}:{}] Mplane address is not pingable from Workstation".format(bts_type, bts_id, mplane))
                else:
                    log_operation("[{}{}:{}] Mplane address is pingable from Workstation".
                                  format(bts_type, bts_id, mplane))

    @log_input_and_output
    def _check_bts_alarms(self):
        for bts_type, btss_mplane in self._bts_mplane_ip.items():
            bts_active_alarms = {}
            for bts_id, mplane in btss_mplane.items():
                if self._ip_is_reachable(mplane):
                    connection = self._admin_alias + '_{}_'.format(bts_type) + str(bts_id)
                    self._admin_client.setup_admin(bts_host=mplane, name=connection)
                    try:
                        bts_active_alarms[bts_id] = self._admin_client.get_active_alarms(connection=connection)
                    finally:
                        self._admin_client.teardown_admin(connection=connection)
                else:
                    log_warning("[{}{}:{}] Mplane address is not pingable from Workstation, "
                                "wont check this tesline's alarm".format(bts_type, bts_id, mplane))
            self._current_alarms[bts_type] = bts_active_alarms

        for bts_type, btss_alarms in self._current_alarms.items():
            for btsid, alarms in btss_alarms.items():
                current_fault_ids = [alarm['faultId'] for alarm in alarms]
                for truck_roll_fault_id in self._truck_roll_fault_ids:
                    if truck_roll_fault_id in current_fault_ids:
                        log_exception('Truck roll alarm with fault ID {} detected on {}{}.'.format(truck_roll_fault_id,
                                                                                                   bts_type, btsid))
                        self._stop_reason["need_stop"] = True
                        self._stop_reason["stop_reason"].append(
                            "[{}{}] Truck roll alarm with fault ID {} detected".format(bts_type, btsid,
                                                                                       truck_roll_fault_id))

    @log_input_and_output
    def _need_stop_and_fix(self):
        need_stop = self._stop_reason.get("need_stop")
        if need_stop:
            try:
                pass  # Maybe auto recovery
            finally:
                self._send_email_notification()
                self._pause_test_execution()

    @log_input_and_output
    def _ip_is_reachable(self, ipaddr):
        return os.system('ping -c 1 -W 5 {} >/dev/null'.format(ipaddr)) == 0

    @staticmethod
    def _ensure_path_will_exist(path):
        if not os.path.exists(path):
            os.makedirs(path)

    @log_input_and_output
    def _pause_test_execution(self):
        pause_start = datetime.now()
        pause_end = pause_start + timedelta(seconds=self._stop_time)
        log_exception("Stop and Fix error detected. Triggering {}s sleep then aborting test execution. "
                      "Start time: {}, End time: {}".format(self._stop_time, pause_start, pause_end))
        sleep(self._stop_time)
        BuiltIn().fatal_error("Stop and Fix procedure triggered! Aborting test execution.")

    @log_input_and_output
    def _send_email_notification(self, files=None):
        suite_name = get_builtin_value('SUITE SOURCE')
        test_case = get_builtin_value(param_name="TEST NAME")

        sender = "StopAndFix@nokia-sbell.com"
        # receivers = ['cuicui.wang@nokia-sbell.com']
        # cc = ['cuicui.wang@nokia-sbell.com']
        receivers = ['i_ext_nj_5g_ci@internal.nsn.com']
        cc = ['hua.c.chen@nokia-sbell.com']

        subject = '[Action Required] Potential Truck Roll'
        msg_content = r"""
        <html>
        <body>
        <p>Hi,</p>
        <p>Potential Truck Roll was detected. If you are owner of testline please check execution:</p>
        <ul>
          <li>TEST_SUITE: {}</li>
          <li>TEST_NAME: {}</li>
          <li>ENB_BUILD: {}</li>
          <li>TESTLINE: {}</li>
          <li>REASON: {}</li>
          <li>TRUCK ROLL FAULTS LIST: {}</li>""".format(suite_name, test_case, self._get_sw_version(),
                                                        self._get_tl_name(),
                                                        self._stop_reason.get("stop_reason"),
                                                        self._truck_roll_fault_ids)

        msg_content = msg_content + "</ul>" + "<br>" + """More details about Truck Roll Pronto
        under <a href='https://nokia.sharepoint.com/sites/uuf4all/SitePages/Stop%26Fix-for-Truck-Roll.aspx'> Link </a>
        <p>Regards<br> Automation Team </p>
        </body>
        </html>
        """

        message = Message(
            From=sender,
            To=receivers,
            CC=cc,
            Subject=subject,
            Html=msg_content,
            Body=None,
            attachments=files,
            charset="utf-8")
        Messenger.send_message(message)

    @log_input_and_output
    def _get_tl_name(self):
        return socket.gethostname().replace('-', '_')

    @log_input_and_output
    def _get_sw_version(self, bts_host="192.168.255.1", connection="get_sw_version"):
        sw_version = None
        if self._ip_is_reachable(bts_host):
            try:
                self._admin_client.setup_admin(bts_host=bts_host, name=connection)
                sw_version = self._admin_client.get_sw_version(connection=connection)
                self._admin_client.teardown_admin(connection=connection)
            except Exception:
                pass
        return sw_version
