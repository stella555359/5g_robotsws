# -*- coding: utf-8 -*-
"""
Author: Yang Mengli
Contacts: mengli.yang@nokia-sbell.com
Description: get promoted build name from wft

"""

import logging
import os
import re
import shutil
import sys
import time
import requests
import bs4

logger = logging.getLogger(__name__)


class WftDownloaderError(Exception):
    pass


class AccessKeyError(WftDownloaderError):
    pass


class JsonQueryError(WftDownloaderError):
    pass


class LatestPackageNotDetected(WftDownloaderError):
    pass


class Get_latest_build_name(object):
    default_build_repository_url = 'http://files.ute.nsn-rdnet.net/'
    json_api_url = 'https://wft.int.net.nokia.com:8091/api/v1/'

    def __init__(self):
        """
        Sets up Ta WFT Downloader.

        :param access_key: access key for json API
                           More info: https://wft.int.net.nokia.com/wiki/generate_an_access_key
        """
        # self.access_key = 'S3roP5dXbVm4tlZnIhigteyuUHNlgt8mxe2566VD'
        self.access_key = 'woIi9KhofNUkh1wToOX217bBUDrqYYOfu4wRJ4CP'
        self.already_downloaded = set()

    def get_name_of_latest_build(self, branch, release_prefix, package_states=None, promotion_tags=None):
        """
        Gets latest build name from WFT JSON API.

        :param string branch: WFT branch (e.g. 'SBTS00', 'SBTS21A')
        :param string release_prefix: build release prefix (e.g. 'CI_ENB')
        :param list package_states: allowed package states (by default: ['released', 'released_with_restrictions'])
        :param list promotion_tags: allowed promotion tags (e.g. ['crt', 'customer'])
        :return string: build name e.g. SBTS00_ENB_9999_201203_000023
        """
        package_states = [package_state.lower() for package_state in package_states] if package_states \
            else ['released', 'released_with_restrictions']
        promotion_tags = promotion_tags if promotion_tags else []
        logger.info('Building request for JSON API...')
        logger.info('- promotion tags: ' + ', '.join(promotion_tags))
        logger.info('- package_states: ' + ', '.join(package_states))
        logger.info('- branch: ' + branch)
        logger.info('- release prefix: ' + release_prefix)
        try:
            if promotion_tags:
                json_request = {
                    "items": "1000",
                    "sorting_field": "created_at",
                    "sorting_direction": "DESC",
                    "columns": ["build.baseline", "build|state"],
                    "view_filters_attributes": {
                        "1": {
                            "column": "promotion_tag.tag",
                            "operation": "eq_any",
                            "value": promotion_tags
                        },
                        "2": {
                            "column": "branch.title",
                            "operation": "eq",
                            "value": branch
                        },
                        "3": {
                            "column": "build.baseline",
                            "operation": "cont",
                            "value": release_prefix
                        }
                    },
                    "access_key": self.access_key
                }
                response = self._post(endpoint='promotion.json', json=json_request)
                items = list(filter(lambda item: item['build|state'] in package_states, response['items']))
                # API responds with items sorted by date.
                # Name of the latest build is in the 'build.baseline' parameter of the first item in this list.
                latest_build_name = items[0]['build.baseline']
            else:
                json_request = {
                    "items": "1",
                    "sorting_field": "created_at",
                    "sorting_direction": "DESC",
                    "columns": ["version"],
                    "view_filters_attributes": {
                        "1": {
                            "column": "branch.title",
                            "operation": "eq",
                            "value": branch
                        },
                        "2": {
                            "column": "version",
                            "operation": "cont",
                            "value": release_prefix
                        },
                        "3": {
                            "column": "state",
                            "operation": "eq_any",
                            "value": package_states
                        }
                    },
                    "access_key": self.access_key
                }
                response = self._post(endpoint='build_branch.json', json=json_request)
                latest_build_name = response['items'][0]['version']
        except ValueError:
            raise JsonQueryError('JSON query failed. Please recheck package_states argument, '
                                 'promotion_tags, branch, release_prefix and access_key')
        except KeyError:
            raise LatestPackageNotDetected('Build not found on branch ' + branch)
        return latest_build_name

    def get_namelist_of_builds(self, branch, release_prefix, package_states=None, promotion_tags=None):
        package_states = [package_state.lower() for package_state in package_states] if package_states \
            else ['released', 'released_with_restrictions']
        promotion_tags = promotion_tags if promotion_tags else []
        logger.info('Building request for JSON API...')
        logger.info('- promotion tags: ' + ', '.join(promotion_tags))
        logger.info('- package_states: ' + ', '.join(package_states))
        logger.info('- branch: ' + branch)
        logger.info('- release prefix: ' + release_prefix)
        try:
            if promotion_tags:
                json_request = {
                    "items": "1000",
                    "sorting_field": "created_at",
                    "sorting_direction": "DESC",
                    "columns": ["build.baseline", "build|state"],
                    "view_filters_attributes": {
                        "1": {
                            "column": "promotion_tag.tag",
                            "operation": "eq_any",
                            "value": promotion_tags
                        },
                        "2": {
                            "column": "branch.title",
                            "operation": "eq",
                            "value": branch
                        },
                        "3": {
                            "column": "build.baseline",
                            "operation": "cont",
                            "value": release_prefix
                        }
                    },
                    "access_key": self.access_key
                }
                response = self._post(endpoint='promotion.json', json=json_request)
                items = list(filter(lambda item: item['build|state'] in package_states, response['items']))
                # API responds with items sorted by date.
                # Name of the latest build is in the 'build.baseline' parameter of the first item in this list.
                build_namelist = []
                build_number = len(items)
                for i in range(build_number):
                    build_namelist.append(items[i]['build.baseline'])
            else:
                json_request = {
                    "items": "30",
                    "sorting_field": "created_at",
                    "sorting_direction": "DESC",
                    "columns": ["version"],
                    "view_filters_attributes": {
                        "1": {
                            "column": "branch.title",
                            "operation": "eq",
                            "value": branch
                        },
                        "2": {
                            "column": "version",
                            "operation": "cont",
                            "value": release_prefix
                        },
                        "3": {
                            "column": "state",
                            "operation": "eq_any",
                            "value": package_states
                        }
                    },
                    "access_key": self.access_key
                }
                response = self._post(endpoint='build_branch.json', json=json_request)
                builds = response['items']
                build_namelist = []
                build_number = len(builds)
                for i in range(build_number):
                    build_namelist.append(builds[i]['version'])
        except ValueError:
            raise JsonQueryError('JSON query failed. Please recheck package_states argument, '
                                 'promotion_tags, branch, release_prefix and access_key')
        except KeyError:
            raise LatestPackageNotDetected('Build not found on branch ' + branch)
        return build_namelist

    def _post(self, endpoint, json):
        url = '{url}{endpoint}'.format(url=self.json_api_url, endpoint=endpoint)
        response = requests.post(url, json=json).json()
        try:
            error_message = response['authentication']['error']
        except KeyError:
            return response
        raise AccessKeyError(error_message)
