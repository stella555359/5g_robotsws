import taf.sw.scout as scout
import re
import time


def request_scf_from_scout(hostname, use_internal_id):
    scout_api = scout.scout()
    scout_api.setup_scout(hostname)
    scf_id = None
    try:
        scf_id = scout_api.request_scf(use_scout_internal_id=use_internal_id)
    except Exception as error:
        error_message = str(error)
        status_code = re.search('[Ss]tatus\\scode:\\s"(.*)"', error_message).group(0)
        if status_code == '429':
            seconds_to_wait = re.search('[Ee]xpected\\savailable\\sin\\s(\\d*).\\d\\sseconds', error_message).group(0)
            time.sleep(int(seconds_to_wait))
    scout_api.teardown_scout_api()
    return scf_id
