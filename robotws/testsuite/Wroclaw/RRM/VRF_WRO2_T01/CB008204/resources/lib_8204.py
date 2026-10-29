from taf.analyzer.pdml import PdmlReader


def check_disbcb_and_disbcp_values(path: str) -> bool:
    """
    Used in tc 8204_b104. Checks 'disBcB' and 'disBcP' prints in syslog file.
    Returns true only if both values equals zero.
    :param path: path to syslog file
    :return: result of checking logs values
    """
    disbcb_str = "disBcB:"
    disbcp_str = "disBcP:"
    disbcb = 0
    disbcp = 0
    with open(path, "r") as f:
        for line in f:
            if "RlcDlDrbQ" in line and disbcb_str in line and disbcp_str in line:  # instead of grep
                disbcb_index = line.find(disbcb_str)
                disbcp_index = line.find(disbcp_str)
                disbcb += int(line[disbcb_index + len(disbcb_str):line.find(',', line.find(disbcb_str))])
                disbcp += int(line[disbcp_index + len(disbcp_str):line.find(',', line.find(disbcp_str))])

    return not (disbcb or disbcp)


BEARER_SETUP = "BearerContextSetupRequest"
BEARER_MODIFICATION = "BearerContextModificationConfirm"
RELEASE_REQUIRED = "SgNBReleaseRequired"


def estimate_counter_values_form_cplane(cplane_pdml_path: str) -> dict:
    """
    This function checks cplane mesages flow. Here is a order of checks with timestamps:
    1. BearerContextSetupRequest ->        t1
    2. BearerContextModificationConfirm -> t2
    3. SgNBReleaseRequired ->              t3

    M55146C00001: t3 - t2
    M55146C00003: t2 - t1

    :param cplane_pdml_path:
    :return: dict with esimated counter values based on cplane events
    """

    to_found = [BEARER_SETUP, BEARER_MODIFICATION, RELEASE_REQUIRED]

    t1 = t2 = t3 = None

    class GotAMessage(Exception):
        pass

    for log_entry in PdmlReader.from_file(cplane_pdml_path):
        try:
            if BEARER_SETUP in to_found:
                for key in log_entry.packet.keys():
                    if BEARER_SETUP in key:
                        t1 = log_entry.timestamp
                        to_found.remove(BEARER_SETUP)
                        raise GotAMessage
            if BEARER_MODIFICATION in to_found:
                for key in log_entry.packet.keys():
                    if BEARER_MODIFICATION in key:
                        t2 = log_entry.timestamp
                        to_found.remove(BEARER_MODIFICATION)
                        raise GotAMessage
            if RELEASE_REQUIRED in to_found:
                for key in log_entry.packet.keys():
                    if RELEASE_REQUIRED in key:
                        t3 = log_entry.timestamp
                        to_found.remove(RELEASE_REQUIRED)
                        raise GotAMessage
        except GotAMessage:
            continue
        if not to_found:
            break

    if (t1 or t2 or t3) is None:
        raise ValueError("Can't read cplane messages timestamps")

    return {
        "M55146C00001": int((t3 - t2).total_seconds() * 1000),
        "M55146C00003": int((t2 - t1).total_seconds() * 1000)
    }


def compare_counter_time(cplane_values: dict, webem_values: dict):
    """
    Both parameters should containd dict with M55146C00001 and M55146C00003 counters values.
    Function compare values and raise an Exception when values don't match.

    :param cplane_values: dict output from estimate_counter_values_form_cplane from this module
    :param webem_values: dict  last webem counters vlaues
    :raise Exception when times don't match
    """

    class WrongCounterValue(Exception):
        pass

    max_sec_diff = 1500
    if abs(cplane_values['M55146C00001'] - webem_values['M55146C00001']) > max_sec_diff:
        raise WrongCounterValue("Missmatch between cplane and webem counter M55146C00001")
    if abs(cplane_values['M55146C00003'] - webem_values['M55146C00003']) > max_sec_diff:
        raise WrongCounterValue("Missmatch between cplane and webem counter M55146C00003")
