
class ScenarioIterator:
    def __init__(self, expected_scenario):
        """
        Initialize the ScenarioIterator with a list of scenarios.

        :param expected_scenario: List of scenarios to iterate over.
        """
        self.expected_scenario = expected_scenario
        self.index = 0

    def __iter__(self):
        """
        Return the iterator object itself.
        """
        return self

    def __next__(self):
        """
        Return the next scenario in the list.
        """
        if self.index < len(self.expected_scenario):
            scenario = self.expected_scenario[self.index]
            self.index += 1
            return scenario
        else:
            raise StopIteration

    def _check_scenario(self, _values):
        """
        Check if the given scenario matches the current expected values.

        :param expected_values: Dictionary with keys 'administrativeState', 'operationalState', 'proceduralStatus',
        'usageState'.
        :return: True if the scenario matches the current expected values, False otherwise.
        """
        if self.index >= len(self.expected_scenario):
            return False
        expected_scenario = self.expected_scenario[self.index]
        for key, val in expected_scenario.items():
            if _values.get(key, None) != val:
                return False
        return True

    def check_scenario(self, _values_list):
        """
        Check if the given scenario matches the current expected values.

        :param scenario: Dictionary with keys 'administrativeState', 'operationalState', 'proceduralStatus',
        'usageState'.
        :return: True if the scenario matches the current expected values, False otherwise.
        """
        if not self._check_scenario(_values_list[0]):
            raise ValueError(
                f"First cell status scenario does not expected, please check ims file")

        for _values in _values_list[1:]:
            if not self._check_scenario(_values):
                self.__next__()
                if not self._check_scenario(_values):
                    raise ValueError(
                        f"Cell status scenario does not expected, please check ims file {_values}")
        return True


class ScenarioList(object):
    # CELL_UP
    always_active = [
        {
            "administrativeState": "Unlocked",
            "barringStatus": "unbarred",
            "blockingState": "Unblocked",
            "operationalState": "enabled",
            "proceduralStatus": "configured",
            "usageState": "Active"
        }
    ]
    # CELL_INIT_TO_ONLINE
    active_to_initialized_to_active = [{'administrativeState': 'Unlocked',
                                        'barringStatus': 'unbarred',
                                        'blockingState': 'Unblocked',
                                        'operationalState': 'enabled',
                                        'proceduralStatus': 'configured',
                                        'usageState': 'Idle'},
                                       {'administrativeState': 'Unlocked',
                                        'barringStatus': 'unbarred',
                                        'blockingState': 'Unblocked',
                                        'operationalState': 'disabled',
                                        'proceduralStatus': 'configured',
                                        'usageState': 'Idle'},
                                       {'administrativeState': 'Unlocked',
                                        'barringStatus': 'unbarred',
                                        'blockingState': 'Unblocked',
                                        'operationalState': 'disabled',
                                        'proceduralStatus': 'initializing',
                                        'usageState': 'Idle'},
                                       {'administrativeState': 'Unlocked',
                                        'barringStatus': 'unbarred',
                                        'blockingState': 'Unblocked',
                                        'operationalState': 'disabled',
                                        'proceduralStatus': 'configured',
                                        'usageState': 'Idle'},
                                       {'administrativeState': 'Unlocked',
                                        'barringStatus': 'unbarred',
                                        'blockingState': 'Unblocked',
                                        'operationalState': 'enabled',
                                        'proceduralStatus': 'configured',
                                        'usageState': 'Active'}]

    not_initialized_to_active = [
        {
            "administrativeState": "Unlocked",
            "barringStatus": "unbarred",
            "blockingState": "Unblocked",
            "operationalState": "disabled",
            "proceduralStatus": "not__Space__initialized",
            "usageState": "Idle"
        },
        {
            "administrativeState": "Unlocked",
            "barringStatus": "unbarred",
            "blockingState": "Unblocked",
            "operationalState": "disabled",
            "proceduralStatus": "initializing",
            "usageState": "Idle"
        },
        {
            "administrativeState": "Unlocked",
            "barringStatus": "unbarred",
            "blockingState": "Unblocked",
            "operationalState": "disabled",
            "proceduralStatus": "configured",
            "usageState": "Idle"
        },
        {
            "administrativeState": "Unlocked",
            "barringStatus": "unbarred",
            "blockingState": "Unblocked",
            "operationalState": "enabled",
            "proceduralStatus": "configured",
            "usageState": "Active"
        }
    ]
