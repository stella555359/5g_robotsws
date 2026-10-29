import re
from robot.libraries.BuiltIn import BuiltIn, register_run_keyword


class Counter(object):

    id = None
    value = None
    result = None

    def __init__(self):
        self.id = None
        self.value = None
        self.result = None

    def set(self, value, counter_id, result):
        """
        :param value: str
        :param counter_id: str
        :param result: str
        """
        self.value = value
        self.id = counter_id
        self.result = result


class ReportCounters(object):

    def __init__(self, log=None):
        self.log = log

    def collect_counters_from_log(self):
        """
        :return: list of tuples e.g. [('0', 'M8020C0', 'passed'), ('0', 'M8020C1', 'passed'), ('0', 'M8020C2',
        'passed')]
        """
        counter_regex = r"'value': '(?P<value>\d+)', 'id': '(?P<id>M\d+C\d+)', 'result': '(?P<result>\w+)'"
        return re.findall(counter_regex, self.log)

    @staticmethod
    def set_counters_from_tuple(counters_list):
        counters = []
        if counters_list:
            for counter_tuple in counters_list:
                counter = Counter()
                counter.set(int(counter_tuple[0]), counter_tuple[1],
                            'Passed' if 'passed' in counter_tuple[2] else 'Failed')
                counters.append(counter)
        return counters

    def report_counters(self, counters=None):
        """
        :param counters: list of Counter objects
        """
        if self.log:
            counters_list = self.collect_counters_from_log()
            counters = self.set_counters_from_tuple(counters_list)
        if counters:
            register_run_keyword('taf.sw.reporting_portal', 'report_pm_counter', 3)
            for counter in counters:
                # print (counter.id, counter.value, counter.result)
                BuiltIn().run_keyword('report_pm_counter', counter.id, counter.value, counter.result)
