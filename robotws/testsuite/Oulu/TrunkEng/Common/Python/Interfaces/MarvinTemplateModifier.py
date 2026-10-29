import json
from robot.libraries.BuiltIn import BuiltIn
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error, warning
from testsuite.Oulu.TrunkEng.Common.Python.Resources.marvin_template_mod_dict import MARVIN_MOD_DICT
from traceback import format_exception


class MarvinTemplateModifier:
    """
    MarvinTemplateModifier is used for modifying marvin templates before the test run.
    """

    def __init__(self):
        self.alarms = BuiltIn().get_library_instance("ALARMS")
        self.logger = BuiltIn().get_library_instance("LOG")
        self.mod_dict = MARVIN_MOD_DICT

    def modify_common_and_test_file(self, test_name):
        if BuiltIn().get_variable_value("${NO_MARVIN}"):
            self.logger.debug("NO_MARVIN is true, common and test file will not be modified")
        else:
            self.logger.debug("Common and test file will be modified...")
            self.add_allowed_alarms_to_common_template()
            self.change_criteria_for_marvin_rules(test_name)

    def add_allowed_alarms_to_common_template(self):
        """
        Adds allowed alarms to the 'ignore_regex_pattern' field of the COMMON_fault.json file.

        """
        marvin_dir = f"/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/Marvin_templates"
        f = open(f"{marvin_dir}/run_common/COMMON_fault.json", "r+")
        try:
            data = json.load(f)
            for contents in data["rule"]["filters"]:
                ignore_regexp_pattern = contents["ignore_regex_pattern"][:-1]
                allowed_alarm_str = "|"
                for allowed_alarm in self.alarms.allowed_alarms:
                    allowed_alarm_str += f"{allowed_alarm}|"
                contents["ignore_regex_pattern"] = f"{ignore_regexp_pattern}{allowed_alarm_str[:-1]})"
            json.dump(data, f, indent=4)
        finally:
            f.close()

    def change_criteria_for_marvin_rules(self, test_name):
        """
        Change the criteria for failing cases in marvin. Also has the possbility of adding case-specific alarms
        to be ignored. The modification values are found from marvin_template_mod_dict.py file.
        """
        test_modifiers = self.mod_dict[test_name]
        filename = ""
        marvin_dir = f"/home/ute/MN/UTE/robotws/testsuite/Oulu/TrunkEng/Common/Resources/Marvin_templates"
        if "4G" in test_modifiers["technology"]:
            filename = f"{marvin_dir}/case_4G/lte_default_common_syslog.json"
        if "5G" in test_modifiers["technology"]:
            filename = f"{marvin_dir}/case_5G/5g_default_common_syslog.json"
        try:
            with open(filename, "r") as f:
                data = json.load(f)
                for mods in test_modifiers["details"]:
                    for contents in data["rule"]["filters"]:
                        if mods["name"].strip() in contents["name"]:
                            mod_details = mods['modifications']
                            if mod_details.get("ignore_regex_pattern"):
                                ignore_regex_pattern = mod_details["ignore_regex_pattern"]
                                expected_alarm_str = ""
                                ignore_regex_pattern_field = ""
                                if isinstance(ignore_regex_pattern, str):
                                    contents["ignore_regex_pattern"] = ignore_regex_pattern
                                if isinstance(ignore_regex_pattern, list):
                                    for expected_alarm in ignore_regex_pattern:
                                        expected_alarm_str += f"{expected_alarm}|"
                                    contents[
                                        "ignore_regex_pattern"] = (f"({ignore_regex_pattern_field}"
                                                                   f"{expected_alarm_str[:-1]})")
                            if mod_details.get("operator"):
                                operator = mod_details["operator"]
                                if ">" in operator:
                                    contents["criteria"]["operator"] = ">"
                                elif "<" in operator:
                                    contents["criteria"]["operator"] = "<"
                                elif "!=" in operator:
                                    contents["criteria"]["operator"] = "!="
                            if mod_details.get("limit"):
                                contents["criteria"]["limit"] = mod_details["limit"]
                            if mod_details.get("verdict"):
                                if mod_details["verdict"] not in ["fail", "pass", "warning"]:
                                    error(f"Verdict should be fail, pass or warning. "
                                          f"Given value: {mod_details['verdict']}")
                                    raise ValueError
                                contents["criteria"]["verdict"] = mod_details["verdict"]
            with open(filename, "w") as f:
                json.dump(data, f, indent=4)
        except (KeyError, ValueError, IndexError) as e:
            error(f"{e.__class__.__name__}:{e} was raised"
                  f"{''.join(format_exception(type(e), e, e.__traceback__))}")
