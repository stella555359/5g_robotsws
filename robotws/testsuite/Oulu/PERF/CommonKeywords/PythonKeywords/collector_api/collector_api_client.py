import requests
import json


class CollectorApiClientException(Exception):
    """ Generic collector api client exception. """


class CollectorApiClient(object):
    """ Common class for handling collector requests """
    def __init__(self):
        self.host = 'localhost'
        self.port = 8080
        self._url = 'http://{}:{}/api/v1'.format(self.host, self.port)

    def url_for(self, resource_url):
        return '{}/{}/'.format(self._url, resource_url)

    def start(self, run_id=None, case_id=None, step_id=None, phase_name=None):
        """Create start request"""
        if not run_id:
            try:
                response = requests.post(self.url_for('testrun'), data='{}', timeout=60)
                response.raise_for_status()
                if response.ok:
                    return json.loads(response.content)
            except requests.exceptions.HTTPError as err:
                raise CollectorApiClientException(
                    'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
            except requests.exceptions.ConnectionError as err:
                raise CollectorApiClientException(
                    'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
            except requests.exceptions.Timeout as err:
                raise CollectorApiClientException(
                    'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
        else:
            data = {'status': 'start',
                    'test_run_id': str(run_id)}
            if case_id:
                data['test_case_id'] = str(case_id)
            if phase_name:
                data['test_phase_name'] = str(phase_name)
            if step_id:
                data['test_step_id'] = str(step_id)
            try:
                response = requests.put(self.url_for('testrun'), json=data, timeout=60)
                response.raise_for_status()
                if response.ok:
                    return json.loads(response.content)
            except requests.exceptions.HTTPError as err:
                raise CollectorApiClientException(
                    'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
            except requests.exceptions.ConnectionError as err:
                raise CollectorApiClientException(
                    'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
            except requests.exceptions.Timeout as err:
                raise CollectorApiClientException(
                    'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))

    def stop(self, run_id, case_id=None, step_id=None):
        """Create stop request"""
        data = {'status': 'stop',
                'test_run_id': str(run_id)}
        if case_id:
            data['test_case_id'] = str(case_id)
        if step_id:
            data['test_step_id'] = str(step_id)
        try:
            response = requests.put(self.url_for('testrun'), json=data, timeout=60)
            response.raise_for_status()
            if response.ok:
                return json.loads(response.content)
        except requests.exceptions.HTTPError as err:
            raise CollectorApiClientException(
                'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
        except requests.exceptions.ConnectionError as err:
            raise CollectorApiClientException(
                'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
        except requests.exceptions.Timeout as err:
            raise CollectorApiClientException(
                'Error communicating with data collector REST API: CollectorApiClientException, {0} '.format(err))
