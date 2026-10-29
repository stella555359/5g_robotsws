# -*- coding: utf-8 -*-
"""
:author: Daniel Kulpa
:contact: daniel.kulpa@nokia.com
:maintainer: I_TADEK_DEVS_GSM
:contact: I_TADEK_DEVS@internal.nsn.com
"""
import requests

BASE_URL = 'https://4g-rep-portal.wroclaw.nsn-rdnet.net'


def _url(resource):
    return "/".join([BASE_URL, 'api', resource])


class Connection(object):
    """Context manager for making API calls to Reporting Portal"""

    def __init__(self, config):
        """

        :param config: dictionary with user/password keys
        """

        self._session = requests.Session()
        self.config = {}
        self.config.update(config)

    def __enter__(self):
        login_url = '/'.join([BASE_URL, 'login/'])

        self._session = requests.session()
        self._session.get(BASE_URL)  # sets cookie
        csrftoken = self._session.cookies.get('csrftoken')

        login_data = dict(
            username=self.config.get('user'),
            password=self.config.get('password'),
            csrfmiddlewaretoken=csrftoken,
            next='/'
        )
        self._session.post(
            login_url,
            data=login_data,
            headers=dict(Referer=login_url)
        )

        # token changes after successful login
        csrftoken = self._session.cookies.get('csrftoken')

        # csrfmiddlewaretoken param won't work for json payload
        # so we need to pass token into header
        self._session.headers.update({'X-CSRFToken': csrftoken})

        return self

    def __exit__(self, *args):
        self._session.close()

    def get(self, resource, **kwargs):
        """Send a GET request

        :param resource: API endpoint, f.e: "qc/instances/report/"
        :param kwargs: Optional arguments that ``request`` takes.
        :return: Deserialized JSON response.
        """
        kwargs.setdefault('params', dict(varnish='nocache'))
        kwargs.setdefault('headers', dict(Accept='application/json'))
        resp = self._session.get(_url(resource), **kwargs)
        resp.raise_for_status()
        return resp.json()

    def post(self, resource, **kwargs):
        """Send a POST request

        :param resource: API endpoint, f.e: "qc-edit/instance/"
        :param kwargs: optional arguments that ``request`` takes.
        :return: deserialized JSON response.
        """
        resp = self._session.post(_url(resource), **kwargs)
        return resp.json()
