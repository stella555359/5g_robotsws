import os
import json
import datetime
import time


class QTListener(object):
    """Used for creating json object with QT results for automatic Release Notes."""

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    ROBOT_LISTENER_API_VERSION = 2
    ARTIFACTS = 'artifact/quicktest'
    RESULTS_FILE = 'qt_test_results.json'

    def __init__(self):
        self.ROBOT_LIBRARY_LISTENER = self
        self.test_results = []
        self.results_path = os.path.join(self.ARTIFACTS, self.RESULTS_FILE)

    @staticmethod
    def _parse_test_duration_to_ms(test_time):
        return str(datetime.timedelta(milliseconds=test_time)).split('.')[0]

    @staticmethod
    def _get_time_since_epoch(test_time):
        return int(time.mktime(time.strptime(test_time, '%Y%m%d %H:%M:%S.%f')))

    def _end_test(self, name, attrs):
        test_start = self._get_time_since_epoch(attrs['starttime'])
        test_end = self._get_time_since_epoch(attrs['endtime'])
        tags = attrs['tags']

        data = dict(name=name, duration=self._parse_test_duration_to_ms(attrs['elapsedtime']), result=attrs['status'],
                    id=attrs['id'], test_start=test_start, test_end=test_end, tags=tags)
        self.test_results.append(data)

    def _end_suite(self, name, attrs):
        suite_start = self._get_time_since_epoch(attrs['starttime'])
        suite_end = self._get_time_since_epoch(attrs['endtime'])
        test_duration = self._parse_test_duration_to_ms(attrs['elapsedtime'])

        data = dict(suiteDuration=test_duration, results=self.test_results,
                    suite_start=suite_start, suite_end=suite_end)

        if not os.path.exists(self.ARTIFACTS):
            os.makedirs(self.ARTIFACTS)

        with open(self.results_path, 'w') as f:
            json.dump(data, f, indent=4)

    # WA for RF issue, empty KW added to listener library https://github.com/robotframework/robotframework/issues/3772
    def do_nth(self):
        pass
