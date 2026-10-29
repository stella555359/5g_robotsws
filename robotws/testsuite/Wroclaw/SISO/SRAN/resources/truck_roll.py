from robot.libraries.BuiltIn import BuiltIn
from robot.api import logger
from robot.api.deco import keyword
from taf.sbts.oam.coam.admin import admin
import subprocess
import smtplib
from email.mime.text import MIMEText
import json
import datetime
import re


@keyword("Exec Stop And Fix Action")
def exec_stop_and_fix_action(
        recipients_list,
        reply_list=["I_SRAN_PROD_SISO_WRO_CRTDEV@internal.nsn.com"],
        reason_dict={"lmp": False, "mplane": False, "hw": False, "alarms": False}):
    """Keyword executes 'Stop and Fix' action. KW sends Teams and Email notification if execution is launched by Cloud
    and raises fatal error. Detection is based on file `/opt/ute/execution.context.json` detection. If it is not Cloud
    exectution, KW throws only error message and does not sends notification.

    Arguments:
    - `recipients_list` [mandatory] (list) - contains email adresses (str)"""
    logger.warn("Executing 'Stop and Fix' action due to occurrence of at least one case from Truck Roll list")
    # Checks if execution method is triggered via CM. Assuming it is not CM execution if execution.context.json
    # does not exist
    if not subprocess.call("cat /opt/ute/execution.context.json", shell=True):
        # Prepare Teams notification
        command = 'echo "put /opt/ute/execution.context.json ${CM_EXECUTION_ID}.json" |' \
                  ' cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
        try:
            subprocess.call(command, shell=True)
        except Exception as e:
            logger.warn("Teams notification about Truck Roll couldn't be sent due to error: " + e)
        # Prepare email notification
        try:
            with open("/opt/ute/execution.context.json", "r") as f:
                f_json = json.load(f)
            sleep_time = calculate_delay_to_next_working_hours()
            tl_name = f_json["CM_RESOURCES"][0]["properties"]["name"]
            cm_exec = f_json["CM_EXECUTION_LINK"]
            from_email = "monitor_truck_roll@nokia.com"
            reason_description = build_reason_description(reason_dict)
            cc_tl_owner = [get_email_from_ts_documentation()]
            msg_body = '''Hi,<br><br>
This message has been sent automatically in order to inform you about potential issues on test line <b>{}</b> which may
be related with Truck Roll. Stop and Fix action was triggered therefore entire execution has been stopped.<br><br>{}
<b>Are you TL owner?</b><br>This test line should be put into maintenance mode and <u>log analysis should be performed
immediately</u>. More about this execution is available <a href="{}">here</a>. Bear in mind there is <u>{} seconds Sleep
Keyword running on now</u>. No logs availabe until Sleep Keyword ends! Raise Pronto if needed.<br><br>
<b>Are you CM Maintainer?</b><br>Put TL {} into Maintanance Mode for 24 hours and reply to this message to inform other
CM Maintainers.<br><br>More information about Stop and Fix action can be found below:<ul><li>
<a href="https://nokia.sharepoint.com/sites/uuf4all/SitePages/Stop&Fix-for-Truck-Roll.aspx">SharePoint page</a></li><li>
<a href="https://web.yammer.com/main/org/nokia.com/threads/eyJfdHlwZSI6IlRocmVhZCIsImlkIjoiMjAzNzYyNjI1MDAzNTIwMCJ9">
Viva Engage post</a></li><li>
<a href="https://teams.microsoft.com/l/channel/19%3A7afbba11f27e43989d5d7e83b2e74747%40thread.skype/tab%3A%3Afaa8b972-8e
f0-4e46-a831-16da9b70ddf3?groupId=360ba5a6-9f8f-490f-80b5-37177df1fb82&tenantId=5d471751-9675-428d-917b-70f44f9630b0&all
owXTenantAccess=false">Teams channel: UTE Users > STOP and FIX > README</a></li></ul>
'''.format(tl_name, reason_description, cm_exec, sleep_time, tl_name)
            message = MIMEText(msg_body, "html")
            message["From"] = from_email
            message["To"] = ",".join(recipients_list)
            message["Cc"] = ",".join(cc_tl_owner)
            message["Subject"] = "[Truck Roll] Stop&Fix action execution for TL " + tl_name
            message["Subject"] += generate_additional_subject_info(reason_dict)
            message['Reply-To'] = ",".join(reply_list)
            mail = smtplib.SMTP(host="mailrelay.int.nokia.com", port=25)
            mail.sendmail(from_addr=from_email, to_addrs=recipients_list + cc_tl_owner, msg=message.as_string())
            mail.quit()
        except Exception as e:
            logger.warn("Email notification about Truck Roll couldn't be sent due to error: " + e)
        logger.debug("Calculated time to sleep is: {} seconds".format(sleep_time))
        BuiltIn().log_to_console("Sleeping for {} seconds...".format(sleep_time))
        BuiltIn().sleep("{}s".format(sleep_time))
        BuiltIn().fatal_error("'Stop and Fix' procedure triggered! Aborting test suite execution.")
    BuiltIn().fatal_error("Skipping 'Stop and Fix' action as it is not CM execution. Please investigate on your own")


@keyword("Analyze Truck Roll Alarms")
def analyze_truck_roll_alarms(alias, truck_roll_alarms):
    """Keyword checks if active alarms occurs in provided Truck Roll alarm list.

    Arguments:
    - `alias` [mandatory] (string) - existing alias to use in KW
    - `truck_roll_alarms` [mandatory] (list) - list of FaultIDs (int) should be checked

    Returns:
    - `True` if any of active alarm is NOT in Truck Roll list
    - `None` if any of active alarm is in Truck Roll list"""
    # Receiving Active Fault IDs
    admin_api = admin()
    active_fid_list = [alarm.faultId for alarm in admin_api.get_active_alarms(connection=alias)]
    logger.info("Active alarms ({}): {}".format(len(active_fid_list), active_fid_list))

    # Comparing if any Truck Roll alarm is active
    logger.info("truck_roll_alarms ({}): {}".format(len(truck_roll_alarms), truck_roll_alarms))
    trigger_fid_list = [fid for fid in active_fid_list if fid in truck_roll_alarms]
    logger.info("trigger_alarms ({}): {}".format(len(trigger_fid_list), trigger_fid_list))

    if trigger_fid_list:
        BuiltIn().fail("Detected active alarms from Truck Roll list: {}".format(trigger_fid_list))
    return True


@keyword("Analyze Truck Roll HW Detection")
def analyze_truck_roll_hw_detection(alias, smod_list, bbmod_list=None, rmod_list=None):
    """Keyword checks if provided seral number lists of SMOD, BBMOD and RMOD are equal to detected HW.

    Arguments:
    - `alias` [mandatory] (string) - existing alias to use in KW
    - `smod_list` [mandatory] (list) - list of serial numbers as strings of all SMODs
    - `bbmod_list` [optional] (list) - list of serial numbers as strings of all BBMODs
    - `rmod_list` [optional] (list) - list of serial numbers as strings of all RMODs

    Returns:
    - `True` if provided SN lists are the same as detected HW
    - `None` if provided SN lists are NOT the same as detected HW"""
    trigger_hw = list()
    admin_api = admin()
    get_detected_hw_info = admin_api.get_detected_hw_info(connection=alias)

    current_smod_list = [str(smod["serialNumber"]) for smod in get_detected_hw_info["systemModules"]]
    logger.info("current_smod_list: {}".format(sorted(current_smod_list)))
    logger.info("smod_list: {}".format(smod_list))
    if set(current_smod_list) != set(smod_list):
        trigger_hw += list(set(current_smod_list) - set(smod_list)) + list(set(smod_list) - set(current_smod_list))

    current_bbmod_list = [str(bbmod["serialNumber"]) for bbmod in get_detected_hw_info["basebandModules"]]
    logger.info("current_bbmod_list: {}".format(sorted(current_bbmod_list)))
    logger.info("bbmod_list: {}".format(bbmod_list))
    if set(current_bbmod_list) != set(bbmod_list):
        trigger_hw += list(set(current_bbmod_list) - set(bbmod_list)) + list(set(bbmod_list) - set(current_bbmod_list))

    current_rmod_list = [str(rmod["serialNumber"]) for rmod in get_detected_hw_info["radioModules"]["rmod"]]
    logger.info("current_rmod_list: {}".format(sorted(current_rmod_list)))
    logger.info("rmod_list: {}".format(rmod_list))
    if set(current_rmod_list) != set(rmod_list):
        trigger_hw += list(set(current_rmod_list) - set(rmod_list)) + list(set(rmod_list) - set(current_rmod_list))

    if trigger_hw:
        BuiltIn().fail("Detected HW does not match HW from test begin: {}".format(trigger_hw))
    return True


@keyword("Analyze Truck Roll LMP Connectivity")
def analyze_truck_roll_lmp_connectivity(lmp_addr, attempts=3, delay=30, log_path="."):
    """Keyword checks if it is possible to establish connection to WebEM using LMP address. Allowed to set number of
    attempts and delay between.

    Arguments:
    - `lmp_addr` [mandatory] (string) - IP address of VM able to set up LMP connection to BTS
    - `attempts` [optional] (int) - number of attempts to reconect before failure
    - `delay` [optional] (int) - time in seconds to wait before next attempt

    Returns:
    - `True` if connection has been established
    - `None` if connection any could not be established"""
    admin_api = admin()
    attempt = 1
    while attempt <= attempts:
        try:
            # Attempting to connect with WebEM via LMP and receive M-Plane address
            alias = admin_api.setup_admin(remote_host=lmp_addr, name="truck_roll", admin_api_log_dir=log_path)
            mplane_ip = alias.get_parameters_for_all("BTS")[0]["btsMplaneIp4V"]
            logger.info("BTS M-Plane IPv4: {}".format(mplane_ip))
            alias.disconnect()
            admin_api.teardown_admin("truck_roll")
            break
        except Exception:
            if attempt == attempts:
                BuiltIn().fail("Connection to Admin via LMP (VM: {}) failed".format(lmp_addr))
            else:
                logger.info("Attempt {} to connect with Admin via LMP (VM: {}) failed - {} more left".format(
                        attempt, lmp_addr, attempts-attempt
                    ))
                BuiltIn().log_to_console(
                    "Attempt {} to connect with Admin via LMP (VM: {}) failed - {} more left".format(
                        attempt, lmp_addr, attempts-attempt
                    )
                )
                attempt += 1
                BuiltIn().sleep("{}s".format(delay))
    return (True, mplane_ip)


@keyword("Analyze Truck Roll MPlane Connectivity")
def analyze_truck_roll_mplane_connectivity(mplane_addr, attempts=3, delay=30, log_path="."):
    """Keyword checks if it is possible to establish connection to WebEM using M-Plane address. Allowed to set number of
    attempts and delay between.

    Arguments:
    - `mplane_addr` [mandatory] (string) - IP address of M-Plane
    - `attempts` [optional] (int) - number of attempts to reconect before failure
    - `delay` [optional] (int) - time in seconds to wait before next attempt

    Returns:
    - `True` if connection has been established
    - `None` if connection any could not be established"""
    admin_api = admin()
    attempt = 1
    while attempt <= attempts:
        try:
            # Attempting to connect with WebEM via M-Plane read by LMP query
            alias = admin_api.setup_admin(bts_host=mplane_addr, name="truck_roll", admin_api_log_dir=log_path)
            alias.get_parameters_for_all("BTS")
            alias.disconnect()
            admin_api.teardown_admin("truck_roll")
            break
        except Exception:
            if attempt == attempts:
                BuiltIn().fail("Connection to Admin via M-Plane ({}) failed".format(mplane_addr))
            else:
                logger.info("Attempt {} to connect with Admin via M-Plane ({}) failed - {} more left".format(
                    attempt, mplane_addr, attempts-attempt
                ))
                BuiltIn().log_to_console(
                    "Attempt {} to connect with Admin via M-Plane ({}) failed - {} more left".format(
                        attempt, mplane_addr, attempts-attempt
                    )
                )
                attempt += 1
                BuiltIn().sleep("{}s".format(delay))
    return True


def calculate_delay_to_next_working_hours():
    """Method checks actual time and calculates custom delay. Purpose is to allow CM Maintainer to put TL in Maintenance
    Mode even after working hours.

    Returns:
    - `time_difference` (int) - time in seconds to next working day"""
    current_time = datetime.datetime.now()
    target_time = current_time.replace(hour=7, minute=0, second=0, microsecond=0)

    if current_time.hour >= 16:
        target_time += datetime.timedelta(days=1)
        time_difference = target_time - current_time
        return int(time_difference.total_seconds())
    else:
        return 60*60


def build_reason_description(reasons_dict):
    """Method returns user list html code to attach to Stop&Fix email notification. It is required to provide proper
    dictionary as argument

    Arguments:
    - `reasons_dict` (dict of bool) must contain keys: `["lmp", "mplane", "hw", "alarms"]`

    Returns:
    - `html user list` (str) with issue description if provided proper dict with at least one True value
    - empty `str()` otherwise"""
    try:
        if reasons_dict == {} or True not in reasons_dict.values():
            return ""
        msg = "<b style='color:red'>Reasons for triggering Stop&Fix action:</b><ul>"
        if reasons_dict["lmp"]:
            msg += "<li>connection to Admin via LMP failed</li>"
        if reasons_dict["mplane"]:
            msg += "<li>connection to Admin via M-Plane failed</li>"
        if reasons_dict["hw"]:
            msg += "<li>detected HW does not match HW from test begin</li>"
        if reasons_dict["alarms"]:
            msg += "<li>detected active alarms from Truck Roll list</li>"
        msg += "<br></ul>"
    except Exception:
        return ""


def generate_additional_subject_info(reason_dict):
    """Method returns additional subject information to be included in an email notification. It is required to provide
    a proper dictionary as an argument.

    Arguments:
    - `reason_dict` (dict of bool) must contain keys: `["lmp", "mplane", "hw", "alarms"]`

    Returns:
    - `additional_info` (str) with additional subject information if provided a proper dict with at least one True value
    - empty `str()` otherwise"""
    try:
        response = " [" + "|".join(str(int(reason_dict[key])) for key in ["lmp", "mplane", "hw", "alarms"]) + "]"
        return response
    except Exception:
        return ""


def get_email_from_ts_documentation():
    """Method retrieves the email address from the test suite documentation. It searches for the responsible tester,
    maintainer, and author email addresses in the documentation and returns the first match found.

    Returns:
    - `email_address` (str) if a match is found for the responsible tester, maintainer, or author email address
    - empty `str()` if no match is found or an exception occurs"""
    try:
        ts_docs = BuiltIn().get_variable_value("${SUITE_DOCUMENTATION}")
        pattern = r"([A-Za-z0-9._%+-]+@(nokia\.com|internal\.nsn\.com))"
        logger.info("Variable ${SUITE_DOCUMENTATION} contains:\n" + ts_docs)

        logger.info("Looking for responsible tester.")
        responsible_tester = re.search(r"Responsible tester:\s*" + pattern, ts_docs, re.IGNORECASE)
        if responsible_tester:
            logger.info("Found responsible tester's address email: " + responsible_tester.group(1))
            return responsible_tester.group(1)
        logger.info("Responsible tester's address email not found. Looking for maintainer.")

        maintainer = re.search(r"Maintainer:\s*" + pattern, ts_docs, re.IGNORECASE)
        if maintainer:
            logger.info("Found maintainers's address email: " + maintainer.group(1))
            return maintainer.group(1)
        logger.info("Maintainer's address email not found. Looking for author.")

        author = re.search(r"Author:\s*" + pattern, ts_docs, re.IGNORECASE)
        if author:
            logger.info("Found authors's address email: " + author.group(1))
            return author.group(1)
    except Exception:
        return ""
