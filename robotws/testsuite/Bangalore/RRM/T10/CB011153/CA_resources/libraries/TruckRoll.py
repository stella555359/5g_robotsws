import datetime
import json
import logging
import os
import smtplib
import socket
import subprocess
import sys
import time
import traceback

from robot.libraries.BuiltIn import BuiltIn
from robot.utils import is_truthy, secs_to_timestr, timestr_to_secs
from taf.config.scf.scf_operations import SCFOperations
from taf.sbts.oam.coam.admin import AdminConnection

BANNER = r"""
 ____ _____ ___  ____                    _   _____ _
/ ___|_   _/ _ \|  _ \    __ _ _ __   __| | |  ___(_)_  __
\___ \ | || | | | |_) |  / _` | '_ \ / _` | | |_  | \ \/ /
 ___) || || |_| |  __/  | (_| | | | | (_| | |  _| | |>  <
|____/ |_| \___/|_|      \__,_|_| |_|\__,_| |_|   |_/_/\_\
"""


def host_unreachable(host):
    command = "ping -c 1 -w 10 {}".format(host)
    logging.debug("Executing command: %s" % command)
    process = subprocess.Popen(command, shell=True, stdout=subprocess.PIPE)
    return_code = process.wait()
    logging.debug("RC: %d" % return_code)
    if return_code == 0:
        return False
    return True


def get_mplane_addr_from_scf(scf):
    scf_reader = SCFOperations()
    scf_reader.load_scf(scf)

    # M-Plane address is stored in LocalIpAddr param of IPADDRESSV4 object
    # but there might be many objects, so we need to find its distName first
    param_dist_name = "mPlaneIpv4AddressDN"
    logging.debug("Reading %s value" % param_dist_name)
    dist_name = scf_reader.get_value_from_scf(p_name=param_dist_name)

    p_name = "localIpAddr"
    logging.debug("Reading %s value from %s" % (p_name, dist_name))
    value = scf_reader.get_value_from_scf(dist_name=dist_name, p_name=p_name)
    logging.debug("Resolved M-Plane address to %s" % value)
    return value


def file_guarded_sleep(secs, file_):
    """
    Suspends execution as long as file_ exists, but no longer than secs seconds.
    File will be created initially, then checked every second if it still exists.
    It is assumed that file_ is being removed by another thread/process at some time.
    """
    if not os.path.isfile(file_):
        f = open(file_, "a")
        f.close()

    endtime = time.time() + float(secs)
    while os.path.isfile(file_):
        remaining = endtime - time.time()
        if remaining <= 0:
            break
        time.sleep(min(remaining, 1.0))


def sendmail(fromaddr, toaddrs, subject, message):
    msg = "From: {}\nTo: {}\n" "Subject: {}\n\n{}".format(
        fromaddr, ",".join(toaddrs), subject, message
    )
    server = smtplib.SMTP("dhn-mailrelay.emea.nsn-intra.net", 25)
    server.set_debuglevel(1)
    server.sendmail(fromaddr, toaddrs, msg)
    server.quit()


class TruckRoll:
    """
    Robotframework interface for checking and reporting potental Truck Roll problems

    For rationale, see:
    https://nokia.sharepoint.com/sites/uuf4all/SitePages/Stop&Fix-for-Truck-Roll.aspx

    Example:
    | ${SITE CONFIGURATION} =  | Get Current Scf File          | /tmp | SCF.xml |
    | setup truck roll checker | ${SITE CONFIGURATION}         |      |         |
    | # at test teardown:      |                               |      |         |
    | @{errors} =              | check for truck roll symptoms | 20m  |         |
    """

    ROBOT_LIBRARY_SCOPE = "TEST SUITE"

    def __init__(self):
        self.checklist = CheckRegistry()
        self.checklist.register(ping_check)
        self.checklist.register(active_alarms_check)

        self.scf = None

    def setup_truck_roll_checker(self, scf):
        self.scf = scf

    def check_for_truck_roll_symptoms(self, recovery_wait_time="20 minutes"):
        seconds = timestr_to_secs(recovery_wait_time)
        errors = self.checklist.run_checks(scf=self.scf)
        if errors:
            logging.warning(
                "Found Truck Roll symptoms: %r"
                "\nWaiting %s before running re-checks"
                % (errors, secs_to_timestr(seconds))
            )
            time.sleep(seconds)
            errors = self.checklist.run_checks(scf=self.scf)
        if errors:
            logging.error(
                "Truck Roll symptoms still present:\n- " + "\n- ".join(errors)
            )
        else:
            logging.info("No Truck Roll symptoms detected")
        return errors

    def stop_and_fix(self, reason=None, send_notification=True, wait_time="20 hours"):
        logging.error(BANNER)
        notify = is_truthy(send_notification)
        seconds = timestr_to_secs(wait_time)
        testline = socket.gethostname()
        execution_link = None

        notify_ute = notify
        contextfile = "/opt/ute/execution.context.json"
        try:
            with open(contextfile, "r") as f:
                context = json.load(f)
            execution_id = context["CM_EXECUTION_ID"]
            execution_link = context["CM_EXECUTION_LINK"]
            testline = context["CM_RESOURCES"][0]["properties"]["name"]
        except (IOError, ValueError):
            logging.warning(
                "Unable to read execution context (either invalid or not existing)."
                " Stop&Fix notifications will not be send."
            )
            notify_ute = False

        # notify UTE team by pushing execution context to webdav server
        if notify_ute:
            ute_url = "http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/"
            ute_cmd = 'echo "put {} {}.json" | cadaver {}'.format(
                contextfile, execution_id, ute_url
            )
            subprocess.call(ute_cmd, shell=True)

        msg = (
            "Found potential Truck Roll problem on {}:\n\n    {}\n\n"
            "You have {} to schedule a maintenace window, starting at {}."
            "\nGood luck!"
            "\n\n---\n"
            "This notification was triggered by {} event(s)"
        )
        if notify:
            sendmail(
                fromaddr="cacnsn@nokia.com",
                toaddrs=["I_TRUNK_ENG_WRO_CITTA@internal.nsn.com"],
                subject="Stop&Fix",
                message=msg.format(
                    testline,
                    execution_link,
                    secs_to_timestr(seconds),
                    datetime.datetime.now(),
                    reason,
                ),
            )

        guard_file = "/tmp/stop_and_fix"
        logging.error(
            "Test run suspended for {}. To resume earlier, remove {}".format(
                secs_to_timestr(seconds), guard_file
            )
        )
        file_guarded_sleep(seconds, guard_file)
        if os.path.isfile(guard_file):
            logging.warning("Timeout reached. Test run will resume.")
        else:
            logging.warning("Test run resumed manually.")


class CheckRegistry:
    def __init__(self):
        self.checks = set()

    @staticmethod
    def log_exception(message):
        tb_lines = traceback.format_exception(*sys.exc_info())
        message = "".join([message, "\n"] + tb_lines).rstrip()
        logging.error(message)

    def register(self, check=None):
        def inner(check):
            self.checks.add(check)
            return check

        if callable(check):
            return inner(check)
        else:
            return inner

    def run_checks(self, scf=None):
        errors = []
        for check in self.checks:
            try:
                new_errors = check(scf=scf)
                errors.extend(new_errors)
            except Exception as e:
                # TODO: replace with logging.exception when upgraded robot to v4.0
                self.log_exception("%r raised %r" % (check.__name__, e))
        return errors


def ping_check(scf, **kwargs):
    errors = []
    logging.info("Running ping check")

    if host_unreachable("192.168.255.129"):
        errors.append("BTS is not reachable via LMP")

    mplane_addr = get_mplane_addr_from_scf(scf)
    if host_unreachable(mplane_addr):
        errors.append("BTS is not reachable via M-Plane (%s)" % mplane_addr)

    logging.info("ping check completed successfully")
    return errors


def active_alarms_check(scf, **kwargs):
    errors = []
    logging.info("Running active alarms check")

    critical_alarm_fids = (10, 1806, 4341, 4352, 4383)
    admin = AdminConnection()
    alarms = admin.get_active_alarms()
    for alarm in alarms:
        if alarm["faultId"] in critical_alarm_fids:
            alarm_short = "[A:{}|FID:{}] {} - {}".format(
                alarm.get("alarmId"),
                alarm.get("faultId"),
                alarm.get("alarmName"),
                alarm.get("alarmDetail"),
            )
            errors.append("Critical alarm active: %s" % alarm_short)

    logging.info("active alarms check completed successfully")
    return errors
