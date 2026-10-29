"""
:copyright: Nokia Networks
:author: 'Mikolaj Kasian'
:maintainer: 'Mikolaj Kasian'
:contact: 'mikolaj.kasian@nokia.com'
:version: 0.1
"""

from prettytable import PrettyTable
from robot.api import logger


class Reporter:
    """ This class reports counters to log.html in readable table"""

    COUNTERS_STYLE = """
    <style type="text/css">
    table.countersTable {
      background-color: #ECEBFF;
      text-align: left;
      border-collapse: collapse;
    }
    table.countersTable td, table.countersTable th {
      padding: 1px 10px;
    }
    table.countersTable tr.header {
      background: #A88AFF;
    }
    table.countersTable tr.header th {
      font-weight: bold;
      color: #FFFFFF;
    }
    </style>
            """

    def __init__(self, nrpmqap_number=64):
        self._nrpmqap_number = nrpmqap_number

    def table_counter_logger(self, counters):
        styled_table = self.COUNTERS_STYLE + self._build_counters_html_table(counters, classes='countersTable')
        logger.info(styled_table, html=True)

    def _build_counters_html_table(self, counters, classes):
        html_table = PrettyTable()
        nrpmqap_columns = [str(n) for n in range(1, self._nrpmqap_number + 1)]
        html_table.field_names = ['counter id', 'counter name', 'NRPMQAP IDs', ' '] + nrpmqap_columns
        html_table.header = True
        for counter in counters:
            html_table.add_row(self._actual_values_row(counter))
            html_table.add_row(self._expectations_row(counter))
            html_table.add_row(self._evaluation_row(counter))
            html_table.add_row(self._separator_row(counter))
        html_ = html_table.get_html_string(**{'attributes': {'class': classes}} if classes else {})
        return html_

    def _actual_values_row(self, counter):
        return [counter.id_name, counter.name, 'actual_values', ' '] + counter.actual_values

    def _expectations_row(self, counter):
        return [' ', ' ', 'expectations', self._row_expectations_state(counter)] \
            + [counter.expectations if check else ' ' for check in counter.ids_to_check_true_list]

    def _evaluation_row(self, counter):
        return [' ', ' ', 'evaluation', ' '] + [self._value_state(result) for result in counter.evaluation_results]

    def _separator_row(self, counter):
        return [' ' for _ in range(4 + len(counter.actual_values))]

    def _row_expectations_state(self, counter):
        if counter.expectations_met:
            return ' '
        return '✖'

    def _value_state(self, value):
        if value is None or value:
            return ' '
        return '✖'
