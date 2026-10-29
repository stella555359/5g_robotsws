"""
:copyright: Nokia Networks
:author: 'Mikolaj Kasian'
:maintainer: 'Mikolaj Kasian'
:contact: 'mikolaj.kasian@nokia.com'
:version: 0.1
"""

import re


class NRPMQAPEvaluator:
    """ This class evaluates one counter all values against it's expectations """

    def evaluate_one_counter(self, counter):
        operator, expected_value = self._parse_expectations(counter.expectations)
        return self._evaluate_expression_for_list(counter.actual_values, operator, int(expected_value))

    def _parse_expectations(self, expectations):
        number_or_symbol_regex = re.compile(r'\d+|\D+')
        parsed_expectations = re.findall(number_or_symbol_regex, expectations)
        return self._get_operator_and_expectations(parsed_expectations)

    @staticmethod
    def _get_operator_and_expectations(expectations):
        operators = ['==', '>=', '<=', '!=', '<>', '<', '>', '+']
        expectations_len = len(expectations)
        if expectations_len == 3 and expectations[1] == '-':
            return [expectations.pop(1), [int(i) for i in expectations]]
        elif expectations_len == 2 and expectations[0].strip(' ') in operators:
            return [expectations[0].strip(' '), int(expectations[1])]
        elif expectations_len == 1:
            return [operators[0], int(expectations[0])]
        else:
            raise ValueError('Wrong or unavailable expectations value')

    @staticmethod
    def _evaluate_expression_for_list(counters_values, operator, expectations):
        evaluations = {
            '==': lambda values, expected: [None if value is None else value == expected for value in values],
            '>=': lambda values, expected: [None if value is None else value >= expected for value in values],
            '<=': lambda values, expected: [None if value is None else value <= expected for value in values],
            '!=': lambda values, expected: [None if value is None else value != expected for value in values],
            '<>': lambda values, expected: [None if value is None else value != expected for value in values],
            '<': lambda values, expected: [None if value is None else value < expected for value in values],
            '>': lambda values, expected: [None if value is None else value > expected for value in values],
            '-': lambda values, expected: [None if value is None else expected[0] <= value < expected[1]
                                           for value in values],
            '+': lambda values, expected: None if values is None else sum(values) == expected,
        }
        return evaluations[operator](counters_values, expectations)


class CountersChecker:
    """ This class parse all counters with NRPMQAPEvaluator to check all values in all counters"""

    def __init__(self, nrpmqap_number):
        self.nrpmqap_number = nrpmqap_number
        self._evaluator = NRPMQAPEvaluator()

    def check_values(self, counters):
        return all([all(self._check_counter_values(counter)) for counter in counters])

    def _check_counter_values(self, counter):
        bald_results = self._evaluator.evaluate_one_counter(counter)
        counter.evaluation_results = [self._check(to_check_values) for to_check_values
                                      in zip(counter.ids_to_check_true_list, bald_results)]
        return counter.evaluation_results

    def _check(self, to_check_values):
        check_index, actual_index_state = to_check_values
        if not check_index:
            return True
        if actual_index_state is None:
            return False
        return actual_index_state
