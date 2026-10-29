# -*- coding: utf-8 -*-

"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import time
import logging
import requests
import json
import urllib3
import base64
from lxml import html
from pprint import pprint
urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)


class Jenkins(object):

    headers = {
        "User-Agent": ("Mozilla/5.0 (Windows NT 6.1; Win64; x64)"
                       "AppleWebKit/537.36 (KHTML, like Gecko)"
                       "Chrome/51.0.2704.103 Safari/537.36"),
        'Content-Type': 'application/json'
    }

    server_ip = '10.106.200.66'

    def __init__(self, logger=None):
        self.username = 'admin'
        self.password = 'admin123'
        self.username = 'ute'
        self.password = 'ute'
        auth_str = f"{self.username}:{self.password}"
        import base64
        self.auth_data = base64.b64encode(bytes(auth_str.encode('ascii'))).decode()
        self.headers.update(dict(Authorization=f"Basic {self.auth_data}"))

        self.logger = logger or logging.getLogger('JENKINS')
        self.baseurl = f'http://{self.username}:{self.password}@{self.server_ip}'
        self.baseurl = f'http://{self.server_ip}'
        self.session = requests.Session()
        self.session.headers = self.headers

    def _get(self, endpoint):
        url = f'{self.baseurl}/{endpoint}'
        self.logger.debug(url)
        resp = self.session.get(url, timeout=60)
        if resp.status_code not in [200, 201]:
            raise Exception(f'HTTP ERROR, code: {resp.status_code}')
        return resp

    def _post(self, endpoint):
        url = f'{self.baseurl}/{endpoint}'
        self.logger.debug(url)
        resp = self.session.post(url)
        if resp.status_code not in [200, 201]:
            raise Exception(f'HTTP ERROR, code: {resp.status_code}')
        return resp

    def resource_is_free(self, resource_name):
        resp = self._get('lockable-resources/')
        tree = html.fromstring(resp.content)
        node = tree.xpath(f'//tr[@data-resource-name="{resource_name}"]')
        if node:
            lines = tree.xpath(f'//tr[@data-resource-name="{resource_name}"]/td/strong/text()')
            self.logger.info(f'Resource status: {str(lines)}')
            return 'FREE' in lines
        else:
            raise Exception(f'Could not find the resource with name [{resource_name}] in jenkins')

    def lock_resource(self, resource_name):
        if self.resource_is_free(resource_name):
            resp = self._get(f'lockable-resources/reserve?resource={resource_name}')
            if self.resource_is_free(resource_name):
                raise Exception(f'Lock Resource {resource_name} failed.')
            else:
                self.logger.info(f'Lock resource {resource_name} successfully!')
        else:
            self.logger.info(f'Resource [{resource_name}] already locked')

    def unlock_resource(self, resource_name):
        if not self.resource_is_free(resource_name):
            resp = self._get(f'lockable-resources/unreserve?resource={resource_name}')
            if self.resource_is_free(resource_name):
                self.logger.info(f'Release resource {resource_name} successfully!')
            else:
                raise Exception(f'unlock resource {resource_name} failed')
        else:
            self.logger.info(f'Resource [{resource_name}] is already free')

    # 启动某个project, kwargs用来表示它的各个参数，返回新建的job的id
    def start_job_for_project(self, project, **kwargs):
        endpoint = f'job/{project}/build'
        if kwargs:
            endpoint += 'WithParameters'
            url = f'{self.baseurl}/{endpoint}'
            resp = self.session.post(url, params=kwargs)
        else:
            endpoint = f'job/{project}/build?delay=0sec'
            resp = self._post(endpoint)

        # headers.location is like: http://10.56.17.117/queue/item/608920/
        locationid = [x for x in resp.headers['Location'].split('/') if x.strip()][-1]
        endpoint = f'queue/item/{locationid}/api/json'
        while True:
            resp = self._get(endpoint)
            data = resp.json()
            pprint(data)
            if 'executable' in data and data['executable'] and 'number' in data['executable']:
                jobid = resp.json()['executable']['number']
                self.logger.info(f'New job id: {jobid}')
                return jobid
            else:
                time.sleep(1)

    def get_job_status(self, project, id):
        resp = self._get(f'job/{project}/{id}/api/json')
        status = resp.json()['result']
        return status

    def job_is_succeed(self, project, id):
        return self.get_job_status(project, id) == 'SUCCESS'

    def job_is_done(self, project, id):
        return self.get_job_status(project, id) is not None

    def get_project_status(self, project):
        resp = self._get(endpoint=f'job/{project}/api/json')
        data = resp.json()
        result = dict(lastBuild=data['lastBuild']['number'],
                      lastSuccessfulBuild=data['lastSuccessfulBuild']['number'])
        return result


jenkins = Jenkins()

if __name__ == '__main__':
    log_level = logging.DEBUG
    FORMAT = '%(name)s-%(asctime)s [%(levelname)s] %(message)s'
    logging.basicConfig(format=FORMAT, datefmt="%Y-%m-%d %H:%M:%S", level=log_level)

    jenkins = Jenkins()
    # jenkins.resource_is_free('22R1_TIM')
    # print(jenkins.get_project_status('UTE_5396_CB009169_trunk'))
    # jobid = jenkins.start_job_for_project('test', buildname='SBTS000')
    # print(jenkins.job_is_done('test', 103))
    # pprint(jenkins.get_project_status('test'))
