"""
:copyright: Nokia Networks
:author: Mateusz Plinta
:maintainer: Mateusz Plinta
:contact: mateusz.plinta@nokia.com
"""

import requests
from urllib.parse import urljoin, quote, urlencode, urlparse, urlunparse
from functools import wraps


class NoSessionEstablishedError(Exception):
    pass


class EmilJsonDecoderClient:
    """
        Library    testsuite.Paris.RRM.ET.resources_KRK.python.dcap_emil_json_decoder.EmilJsonDecoderClient
        ...    WITH NAME   <your alias>

    """
    def __init__(self, dcap_ip="127.0.0.1", dcap_port=9443, session=None):
        self.dcap_ip = dcap_ip
        self.dcap_port = dcap_port
        self._session = session

    def extract_session_if_none(func):
        """Decorator function. If used, extracts session info from class instance if it can be obtained.
           Does nothing if session kwarg is specified explicitly in a function call.
        """
        @wraps(func)
        def wrapper(self, *args, **kwargs):
            if ("session" not in kwargs) or ("session" in kwargs and kwargs["session"] is None):
                kwargs["session"] = self.current_session
            return func(self, *args, **kwargs)

        return wrapper

    @staticmethod
    def __prepare_url(url, query_params):
        if query_params:
            query_string = urlencode(query_params, quote_via=quote, safe="/&")
            parsed_url = urlparse(url)
            url = urlunparse((parsed_url.scheme, parsed_url.netloc, parsed_url.path,
                              parsed_url.params, query_string, parsed_url.fragment))
        return url

    @property
    def base_url(self):
        return f'https://{self.dcap_ip}:{self.dcap_port}/emil-decoder/'

    @property
    def current_session(self):
        if self._session is None:
            self._session = self.get_latest_session_name()
        return self._session

    @current_session.setter
    def current_session(self, value):
        self._session = value

    def upload_log_file(self, log_filepath, username='testuser', extract_session_info=True):
        """
        :param log_filepath: (str) Complete path to the file 5gm
        :param username: (str) (optional) Username for the session; currently unused by the emil-json-decorer
        :param extract_session_info: (bool) (optional) If set, will extract sessionId from the response
                                     for future reference for other instance methods. Defaults to True
        :return: dict(json) response, example:
            {"operationStatus":"Success","sessionId":"session2","gridIds":[1001],"fileIds":[3],
                "sourceIds":[2],"fileNames":["emil_traces.5gm"],"fileStatuses":["Decoded"]}
        """
        url = urljoin(self.base_url, 'api/files/v1')
        data = {'userName': username}
        files = {'data': open(log_filepath, 'rb')}
        response = requests.post(url, data=data, files=files, verify=False)
        response.raise_for_status()
        json_response = response.json()
        if extract_session_info:
            self.current_session = json_response.get("sessionId")
        return json_response

    def get_sessions(self):
        """
        :return: response (dict), example:
            [
                {'sessionName': 'session1', 'userName': None},
                {'sessionName': 'session2', 'userName': 'testuser'}
            ]
        """
        url = urljoin(self.base_url, 'api/files/v1')
        response = requests.get(url, verify=False)
        response.raise_for_status()
        return response.json()

    def get_latest_session_name(self):
        sessions = self.get_sessions()
        if sessions:
            return sessions.pop().get('sessionName', None)
        else:
            raise NoSessionEstablishedError()

    @extract_session_if_none
    def get_session_info(self, *args, **kwargs):
        """
        :param session: (str) sessionId
        :return: (dict) response, example:
            {'sessionName': 'session2', 'sessionFiles': [{'fileindex': 3, 'filename': 'emil_traces.5gm',
            'filesize': 1089270, 'uploadTime': '2023-10-23 09:25', 'userName': 'testuser', 'fileStatus': 'Decoded',
            'swVersion': '(5G) SBTS24R1_ENB_9999_231022_000003', 'messageCount': 1239, 'gridId': 1001, 'sourceId': 2}],
            'sessionGrids': [{'gridId': 1001, 'profileName': '5G L3',
            'swVersion': '(5G) SBTS24R1_ENB_9999_231022_000003',
            'traceCount': 3}], 'allFiles': ['emil_traces.5gm'], 'expirationTime': '2023-10-26 14:52'}
        """
        session = kwargs.pop("session")
        url = urljoin(self.base_url, f'api/files/v1/{session}')
        response = requests.get(url, verify=False)
        response.raise_for_status()
        return response.json()

    @extract_session_if_none
    def get_session_grid_ids(self, *args, **kwargs):
        """
        :param session: (str) sessionId
        :return: response (dict)
        """
        session = kwargs.pop("session")
        session_info = self.get_session_info(session=session)
        return [grid["gridId"] for grid in session_info['sessionGrids']]

    @extract_session_if_none
    def remove_session(self, *args, **kwargs):
        """
        :param session: (str) sessionId
        :return: response (dict)
        """
        session = kwargs.pop("session")
        url = urljoin(urljoin(self.base_url, 'api/files/v1/'), session)
        response = requests.delete(url, verify=False)
        response.raise_for_status()
        return response

    def remove_file(self, file_index, session="session1"):
        """
        :param file_index: (int) file_index
        :param session: (str) sessionId
        :return: response (dict)
        """
        url = urljoin(self.base_url, f'api/files/v1/{session}/{file_index}')
        response = requests.delete(url, verify=False)
        response.raise_for_status()
        return response

    @extract_session_if_none
    def get_call_grid_data(self, grid, *args, **kwargs):
        """
        :param grid: (int) gridId
        :param session: (str) sessionId
        :param filter: (str) (optional)
        :param sortby: (str) (optional)
        :param tree: (str) (optional)
        :param column: (str) (optional)
        :param view: (str) (optional)
        :return: dict(json) or str(csv)

        """
        session = kwargs.pop("session")
        query_params = kwargs
        url = urljoin(self.base_url, f'api/files/v1/{session}/{grid}/calls')
        url = self.__prepare_url(url, query_params)
        response = requests.get(url, verify=False)
        response.raise_for_status()
        return response.json() if "view" not in kwargs else response.text

    @extract_session_if_none
    def get_call_trace_data(self, grid, call_trace_no, *args, **kwargs):
        """
        :param grid: (int) gridId
        :param call_trace_no: (int)
        :param session: (str) sessionId
        :param filter: (str) (optional)
        :param sortby: (str) (optional)
        :param tree: (str) (optional)
        :param column: (str) (optional)
        :param view: (str) (optional)
        :return: dict(json) or str(csv)

        """
        session = kwargs.pop("session")
        query_params = kwargs
        url = urljoin(self.base_url, f'api/files/v1/{session}/{grid}')
        if call_trace_no is not None:
            url += f'/{call_trace_no}'
        url = self.__prepare_url(url, query_params)
        response = requests.get(url, verify=False)
        response.raise_for_status()
        return response.text if "view" in kwargs and kwargs["view"] == "tracecsv" else response.json()

    @extract_session_if_none
    def get_source_data(self, file_id, *args, **kwargs):
        """
        :param file_id: (int) fileId
        :param session: (str) sessionId
        :param filter: (str) (optional)
        :param sortby: (str) (optional)
        :param tree: (str) (optional)
        :param column: (str) (optional)
        :param view: (str) (optional)
        :param count: (str) (optional)
        :param rows: (str) (optional)
        :return: dict(json)

        """
        session = kwargs.pop("session")
        query_params = kwargs
        url = urljoin(self.base_url, f'api/files/v1/{session}/{file_id}/source')
        url = self.__prepare_url(url, query_params)
        response = requests.get(url, verify=False)
        response.raise_for_status()
        return response.json()

    @extract_session_if_none
    def get_graphinfos(self, grid, *args, **kwargs):
        """
        :param grid: (int) gridId
        :param session: (str) sessionId
        :return: response (dict)

        """
        session = kwargs.pop("session")
        url = urljoin(self.base_url, f'api/files/v1/{session}/{grid}/graphinfos')
        response = requests.get(url, verify=False)
        response.raise_for_status()
        return response.json()
