"""
:copyright: Nokia Networks
:author: 'Mikolaj Kasian'
:maintainer: 'Mikolaj Kasian'
:contact: 'mikolaj.kasian@nokia.com'
:version: 0.1
"""

from itertools import count, groupby
from dataclasses import dataclass


@dataclass
class Counter:
    """ This class keeps all counter data for  collecting, evaluating and logging purposes """

    id_name: str
    name: str
    ids_to_check: str
    expectations: str
    actual_values: list
    evaluation_results: list

    @property
    def expectations_met(self):
        return all(self.evaluation_results)

    @property
    def ids_to_check_true_list(self):
        true_indexes = list(self.indexes_generator(self.ids_to_check))
        return [True if nrpmqap_idx in true_indexes else False for nrpmqap_idx in range(1, len(self.actual_values) + 1)]

    @staticmethod
    def indexes_generator(indexes):
        for item in indexes.split(','):
            if '-' not in item:
                yield int(item)
                continue

            start, stop = item.split('-')
            for i in range(int(start), int(stop) + 1):
                yield i


class DataKeeper:
    """ This class purposes are to prepare user expectation and keep all counters data"""

    def __init__(self, data, values_number):
        self._values_number = values_number
        self._counters_data = []
        self._prepare_counters_data(data)

    @property
    def counters(self):
        return self._counters_data

    def _prepare_counters_data(self, data):
        for raw_counter_data in self._chunks(data, self._values_number):
            self._counters_data.append(self._prepare_counter(raw_counter_data))

    def _chunks(self, values, size):
        c = count()
        for _, g in groupby(values, lambda _: next(c) // size):
            yield g

    def _prepare_counter(self, raw):
        list_data = list(raw)
        return Counter(
            id_name=list_data[0],
            ids_to_check=list_data[1],
            expectations=list_data[2],
            name=list_data[3],
            actual_values=[],
            evaluation_results=[],

        )
