import os
import re
import time
from taf.ul.alarms_watchdog import alarms_watchdog


almw = alarms_watchdog()
# almw = BuiltIn().get_library_instance("alarms_watchdog")


def allowed_alarms_before_precondition():
    # To be allow anytime
    # ------------------------------------------------------------------------------------------------------ #
    almw.allow_alarm(alarm_id="7220", fault_id="61524", fault_name="SSH enabled")
    almw.allow_alarm(alarm_id="7220", fault_id="61649", fault_name="LMP access via port 443")
    almw.allow_alarm(alarm_id="7220", fault_id="61652", fault_name="R&D Service Port enabled")
    almw.allow_alarm(alarm_id="7220", fault_id="4654", fault_name="Ethernet port security is disabled")
    almw.allow_alarm(alarm_id="7220", fault_id="4655", fault_name="Service account root access is enabled")
    almw.allow_alarm(alarm_id="61641", fault_id="61641")
    almw.allow_alarm(alarm_id="7115", fault_id="4681", fault_name="Diagnostic Check Error")
    # almw.allow_alarm(alarm_id="7115", fault_id="6450", fault_name="Diagnostic Files collected")
    almw.allow_alarm(alarm_id="7115", fault_id="6450", fault_name="Diagnostic files collected")

    # BHR begin 02/03/2025: DEBUG PURPOSE New alarms filtered detection added, but to be investigated
    almw.allow_alarm(alarm_id="7220", fault_id="4459", fault_name="User Account has Default Password")
    almw.allow_alarm(alarm_id="7220", fault_id="61510",
                     fault_name="Automatic BTS Operator Certificate retrieval unsuccessful")
    almw.allow_alarm(alarm_id="7220", fault_id="61616", fault_name="Vendor BTS certificate has expired")
    almw.allow_alarm(alarm_id="7115", fault_id="8000",
                     fault_name="Failure in connection between BTS and 3rd party tool")

    # To be disallow after precondition
    # ------------------------------------------------------------------------------------------------------ #
    almw.allow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    almw.allow_alarm(alarm_id="7115", fault_id="7523", fault_name="Cell Activation timeout at gNB-DU")
    almw.allow_alarm(alarm_id="7107", fault_id="7305", fault_name="NG SCTP setup fail")
    almw.allow_alarm(alarm_id="7107", fault_id="7308",
                     fault_name="Transport layer connection failure in X2 interface")
    almw.allow_alarm(alarm_id="7107", fault_id="7319",
                     fault_name="No X2 link available for a specific LTEENB")
    almw.allow_alarm(alarm_id="7107", fault_id="7300", fault_name="No X2 link available")
    almw.allow_alarm(alarm_id="7114", fault_id="7107", fault_name="Cell problem due to associated X2 links "
                     "and/or NG links and/or E1 link unavailability")
    # almw.allow_alarm(alarm_id="7115", fault_id="4590", fault_name="Fault signature for crash or failure")

    # Youssef 03/12/2025
    almw.allow_alarm(alarm_id="7107", fault_id="7307", fault_name="Xn SCTP setup fail")


def disallow_alarms_after_precondition():
    almw.disallow_alarm(alarm_id="7115", fault_id="4592", fault_name="BTS Reset Cause")
    almw.disallow_alarm(alarm_id="7115", fault_id="7523", fault_name="Cell Activation timeout at gNB-DU")
    almw.disallow_alarm(alarm_id="7107", fault_id="7305", fault_name="NG SCTP setup fail")
    almw.disallow_alarm(alarm_id="7107", fault_id="7308",
                        fault_name="Transport layer connection failure in X2 interface")
    almw.disallow_alarm(alarm_id="7107", fault_id="7319",
                        fault_name="No X2 link available for a specific LTEENB")
    almw.disallow_alarm(alarm_id="7107", fault_id="7300", fault_name="No X2 link available")
    almw.disallow_alarm(alarm_id="7114", fault_id="7107", fault_name="Cell problem due to associated X2 links "
                        "and/or NG links and/or E1 link unavailability")
    # almw.disallow_alarm(alarm_id="7115", fault_id="4590",
    #                     fault_name="Fault signature for crash or failure")


def allowed_alarms_after_precondition():
    # To be allow anytime
    # ------------------------------------------------------------------------------------------------------ #
    almw.allow_alarm(alarm_id="7220", fault_id="61524", fault_name="SSH enabled")
    almw.allow_alarm(alarm_id="7220", fault_id="61649", fault_name="LMP access via port 443")
    almw.allow_alarm(alarm_id="7220", fault_id="61652", fault_name="R&D Service Port enabled")
    almw.allow_alarm(alarm_id="7220", fault_id="4654", fault_name="Ethernet port security is disabled")
    almw.allow_alarm(alarm_id="7220", fault_id="4655", fault_name="Service account root access is enabled")
    almw.allow_alarm(alarm_id="61641", fault_id="61641")
    almw.allow_alarm(alarm_id="7115", fault_id="4681", fault_name="Diagnostic Check Error")
    # almw.allow_alarm(alarm_id="7115", fault_id="6450", fault_name="Diagnostic Files collected")
    almw.allow_alarm(alarm_id="7115", fault_id="6450", fault_name="Diagnostic files collected")

    # BHR begin 02/03/2025: DEBUG PURPOSE New alarms filtered detection added, but to be investigated
    almw.allow_alarm(alarm_id="7220", fault_id="4459", fault_name="User Account has Default Password")
    almw.allow_alarm(alarm_id="7220", fault_id="61510",
                     fault_name="Automatic BTS Operator Certificate retrieval unsuccessful")
    almw.allow_alarm(alarm_id="7220", fault_id="61616", fault_name="Vendor BTS certificate has expired")
    almw.allow_alarm(alarm_id="7115", fault_id="8000",
                     fault_name="Failure in connection between BTS and 3rd party tool")

    # Youssef 03/12/2025
    almw.allow_alarm(alarm_id="7107", fault_id="7307", fault_name="Xn SCTP setup fail")


def parse_alarm_message(alarm_msg):
    """
    Parse alarm error message to extract simplified information.
    Args:
        alarm_msg (str): Raw alarm message from step
    Returns:
        list: List of simplified alarm info dictionaries
    """
    if not alarm_msg or not isinstance(alarm_msg, str):
        return []
    # Pattern to match alarm information
    # Format: YYYY-MM-DD HH:MM:SS.microseconds DETECTED ... alarm_id: XXXX, fault_id: YYYY
    alarm_pattern = r'(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}\.\d+).*?alarm_id:\s*(\d+).*?fault_id:\s*(\d+)'
    alarms = []
    matches = re.finditer(alarm_pattern, alarm_msg)
    for match in matches:
        timestamp = match.group(1)
        alarm_id = match.group(2)
        fault_id = match.group(3)
        alarms.append({
            'timestamp': timestamp,
            'alarm_id': alarm_id,
            'fault_id': fault_id
        })
    return alarms


def format_parsed_alarms(alarms_list):
    """
    Format parsed alarms into a readable string.
    Args:
        alarms_list (list): List of alarm dictionaries from parse_alarm_message
    Returns:
        str: Formatted alarm information
    """
    if not alarms_list:
        return "No alarms found"
    formatted_lines = []
    for i, alarm in enumerate(alarms_list, 1):
        alarm_line = (f"  Alarm {i}: {alarm['timestamp']} - "
                      f"alarm_id:{alarm['alarm_id']} - "
                      f"Fault_id:{alarm['fault_id']}")
        formatted_lines.append(alarm_line)
    return "\n".join(formatted_lines)


def get_alarms_check_failed_summary(list_steps):
    """
     Filter and analyze failed 'alms_hdlr.check_detected_alarms' steps with simplified alarm info.
    Args:
        list_steps (list): List of step dictionaries from @{ListStep}
    Returns:
        str: Formatted summary with parsed alarm information
    """
    if not list_steps:
        return "No steps provided"
    # Filter only failed check_detected_alarms steps
    alarm_check_failures = [
        step for step in list_steps
        if (step.get('status') == 'FAIL' and
            'alms_hdlr.check_detected_alarms' in step.get('name', ''))
    ]
    if not alarm_check_failures:
        return "No failures detected for alarm checks (alms_hdlr.check_detected_alarms)"
    # Create enhanced summary
    summary_lines = ["=" * 70]
    summary_lines.append("  ALARM CONTROL CHECKS FAILURE SUMMARY")
    summary_lines.append("=" * 70)
    summary_lines.append(f"Number of failed alarm control checks: {len(alarm_check_failures)}")
    summary_lines.append("-" * 70)
    for step in alarm_check_failures:
        step_nb = step.get('nb', 'N/A')
        step_name = step.get('name', 'Unknown name')
        step_msg = step.get('msg', 'No error message')
        summary_lines.append(f"STEP {step_nb}: Alarm control check FAILED")
        # Parse and format alarm information
        parsed_alarms = parse_alarm_message(step_msg)
        if parsed_alarms:
            summary_lines.append(f"  Detected alarms ({len(parsed_alarms)}):")
            summary_lines.append(format_parsed_alarms(parsed_alarms))
        else:
            summary_lines.append(f"  Raw error message: {step_msg}")
        # summary_lines.append(f"  Status: {step.get('status', 'UNKNOWN')}")
        summary_lines.append("-" * 50)
    summary_lines.append("=" * 70)
    return "\n".join(summary_lines)


def start_watchdog_alarms():
    almw.watch_alarms()


def check_detected_alarms():
    almw.check_detected_alarms()


def stop_watchdog_alarms():
    almw.stop_watching_alarms()


def get_list_of_alarms_allowed_and_detected():
    allowed_alarms = almw.get_allowed_alarms()
    detected_alarms = almw.get_detected_alarms()
    return allowed_alarms, detected_alarms
