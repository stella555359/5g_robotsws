from robot.libraries.BuiltIn import BuiltIn


def run_keyword_and_allow_retest(keyword, max_attempts=3):
    """
    Runs the given keyword multiple times until it passes or the maximum number of attempts is reached.

    :param keyword: The keyword to run.
    :param max_attempts: The maximum number of attempts to run the keyword.
    :return: True if the keyword passes at least once, False otherwise.
    """
    for _ in range(max_attempts):
        status = BuiltIn().run_keyword_and_return_status(keyword)
        if status:
            return True
    raise Exception(f"Test failed after {max_attempts} attempts.")


def check_fault_id(alarms_list: list, fault_id: int | str) -> bool:
    """Checks if a given fault ID exists in a list of alarms.
        The alarm easiest way to provide alarm list is to call admin function -> get alarms

      Args:
          alarms_list: A list of dictionaries, where each dictionary represents an alarm and contains a 'faultId' key.
          fault_id: The fault ID to search for (can be an integer or a string).

      Returns:
          True if the fault ID is found in the alarms list, False otherwise.
      """
    alarms = [alarm for alarm in alarms_list if alarm['faultId'] == int(fault_id)]
    if alarms:
        return True
    return False
