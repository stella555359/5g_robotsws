import re
from testsuite.Oulu.TrunkEng.Common.Python.Interfaces.Logger import info, error


class NetActChecks:

    @staticmethod
    def check_amount_of_ne3s_messages(ne3s_messages):
        """
        Checks that the amount of NE3S messages is correct.
        :param list ne3s_messages: List of NE3S messages.

        :return: True if amount of NE3S messages is correct, False otherwise.
        """

        if len(ne3s_messages) < 3:
            error("Some of the ne3s connection establishment messages are missing. Found messages: {}".format(
                ne3s_messages))
            error("At least 3 messages are needed which shows the connection establishment procedure. "
                  "Check found messages")
            return False
        elif len(ne3s_messages) > 7:
            info(f"Number of messages: {ne3s_messages}")
            error("Extra ne3s connection establishment messages is found. Found messages: {}".format(
                ne3s_messages))
            error(
                "Last message should contain 'OperationalState(0:DISABLED,1:ENABLED): 1 proceduralState(0:INITIALIZING,"
                "1:DISCONNECTED,2:SECURECONNECTED,3:UNSECURECONNECTED): 0 downlinkState: 0 uplinkState: 3'")
            return False
        else:
            return True

    @staticmethod
    def find_correct_element(message, correct_element):
        pattern = re.compile(
            r".*?(?:OperationalState\(.*\):\s+(?P<operational>\d+))?\s+proceduralState\(.*\):\s+(?P<procedural>\d+)\s"
            r"downlinkState:\s+(?P<downlink>\d+)\s+uplinkState:\s+(?P<uplink>\d+)")
        match = pattern.match(message)
        if match:
            return match.group(correct_element)
        else:
            return ""

    @staticmethod
    def check_amount_of_states(dictionary, message):
        if len([i for i in dictionary.values() if i != ""]) != 4:
            error("All needed states were not caught from {}. Caught values: {}".format(message, dictionary))
            return False
        return True

    @staticmethod
    def check_and_report_states(correct_states, states_in_message, number):
        diff = set(states_in_message.items()) - set(correct_states.items())
        if diff:
            error("States in {} ne3s-message in syslog were: {}. "
                  "Correct states are: {}. Incorrect values: {}".format(number, states_in_message, correct_states,
                                                                        diff))
            return False
        return True

    def check_ne3s_message(self, message, procedural="", operational="", downlink="", uplink="", number="", warn=False):
        correct_states = {
            "procedural": procedural,
            "operational": operational,
            "downlink": downlink,
            "uplink": uplink
        }
        states_in_message = {
            "procedural": self.find_correct_element(message, "procedural"),
            "operational": self.find_correct_element(message, "operational"),
            "downlink": self.find_correct_element(message, "downlink"),
            "uplink": self.find_correct_element(message, "uplink")
        }
        success = self.check_amount_of_states(states_in_message, message)
        if not downlink and not uplink:
            del correct_states["downlink"]
            del states_in_message["downlink"]
            del correct_states["uplink"]
            del states_in_message["uplink"]
        if not warn:
            success = self.check_and_report_states(correct_states, states_in_message, number) and success
        else:
            self.check_and_report_states(correct_states, states_in_message, number)
            success = True
        return success

    def check_correct_ne3s_procedure(self, ne3s_messages):
        success = self.check_ne3s_message(ne3s_messages[0], procedural="0", operational="1", downlink="",
                                          uplink="", number="first", warn=True)
        success = self.check_ne3s_message(ne3s_messages[-1], procedural="3", operational="1", downlink="3",
                                          uplink="3", number="second") and success
        return success

    @staticmethod
    def _parse_file(messages, regex, match_name):
        file_names = []
        for message in messages:
            info(f"Parsing message: {message}")
            file_pattern = re.compile(regex)
            file_match = file_pattern.match(str(message))
            if file_match:
                file_names.append(file_match.group(match_name))
        return file_names

    def parse_ne3s_file_transfer_notification(self, messages):
        info(f"Parsing NE3S file transfer notification messages")
        regex = re.compile(r".*(?P<file_name>PM\.BTS-.*)\s+to\s+COMA\s+successfully.*")
        return self._parse_file(messages, regex, "file_name")

    def parse_ne3s_file_transfer_result(self, messages, notifications):
        info(f"Parsing NE3S file transfer result messages")
        regex = re.compile(r".*(?P<file_name>PM\.BTS-.*)\s+transfer\s+success.*")
        files = self._parse_file(messages, regex, "file_name")
        for result_file in files:
            if result_file not in notifications:
                error(f"File {result_file} was not found from NE3S notifications")
        return files

    @staticmethod
    def _regex_for_list(list_of_strings, pattern, groups):
        regexd_list = []
        for string in list_of_strings:
            match = pattern.match(string)
            if match:
                regexd_list.append(match.group(groups))
            else:
                error(r"Regex '.*PM\.BTS-(?P<bts_and_date>.*)\.(ANY|LTE).*' doesn't match to {}".format(string))
        return regexd_list

    def check_pm_file_list(self, correct_filenames, filenames):
        compiled_regex = re.compile(r".*PM\.BTS-(?P<bts_and_date>.*)\.(ANY|LTE).*")
        group = "bts_and_date"
        correct_dates = self._regex_for_list(correct_filenames, compiled_regex, group)
        dates = self._regex_for_list(filenames, compiled_regex, group)
        if len(correct_filenames) == 1:  # If only the latest file is checked
            dates = [max(dates)]
        if correct_dates and dates and (set(correct_dates) == set(dates)):
            info(f"NE3S file names are correctly found from syslog and formatted")
            return True
        else:
            difference = list(set(correct_dates) - set(dates)) + list(set(dates) - set(correct_dates))
            error(
                f"NE3S file names ({filenames}) and correct PM file names ({correct_filenames}) don't match. "
                f"Difference: {difference}")
            return False
