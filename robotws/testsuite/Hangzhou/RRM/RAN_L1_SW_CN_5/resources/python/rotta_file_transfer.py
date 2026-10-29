# jenkins_library.py

import time
import os
import requests
from requests.auth import HTTPBasicAuth
from robot.api import logger

# Check and install needed libraries
check_api4jenkins = 2
while check_api4jenkins:
    try:
        from api4jenkins import Jenkins
        print('api4jenkins has been installed')
        break
    except Exception:
        print('api4jenkins is not installed.')
        os.popen("pip install api4jenkins")
        check_api4jenkins -= 1
        continue

# Jenkins configuration
BASE_URL = 'https://clutch-hz.dynamic.nsn-net.net/jenkins'
DOWNLOAD_JOB_NAME = 'Tools.rotta.download_file'
UPLOAD_JOB_NAME = 'Tools.rotta.upload_file'
JENKINS_USER = 'yughou'
JENKINS_TOKEN = '113f95afa68deacdf8ccee17376841ec16'

server = Jenkins(BASE_URL, auth=(JENKINS_USER, JENKINS_TOKEN), verify=False)


def jenkins_upload_file_to_ROTTA(file_path, rotta_path):
    job_url = f'{BASE_URL}/view/Tools/job/{UPLOAD_JOB_NAME}/buildWithParameters'
    trigger_job(job_url, file_path, rotta_path)


def trigger_job(job_url, file_path, rotta_path):
    file_parameter_name = 'upload_file'
    params = {
        "rotta_path": rotta_path,
        "unzip_uploadfile": False
    }
    with open(file_path, 'rb') as file:
        files = {file_parameter_name: file}
        response = requests.post(
            job_url,
            auth=HTTPBasicAuth(JENKINS_USER, JENKINS_TOKEN),
            data=params,
            files=files,
            verify=False  # Set to True if you have the CA certificate
        )
        print_response(response)
    last_build = job_is_building(UPLOAD_JOB_NAME)
    job_is_complated(last_build)


def print_response(response):
    if response.status_code == 201:
        logger.console("[ INFO ] Job is triggered successfully!")
    else:
        logger.console(f"[ ERROR ] Failed to trigger job. Status code: {response.status_code}")
        logger.console(response.text)


def job_is_building(job_name):
    logger.console('[ INFO ] Start to check jenkins job status ... ')
    while True:
        time.sleep(10)
        job = server.get_job(job_name)
        if job.building:
            last_build = job.get_last_build()
            if JENKINS_USER in last_build.jenkins.me.url:
                logger.console(f'[ INFO ] The building is [ {last_build.url} ]')
                return last_build
            else:
                pass
        else:
            logger.console('[ WARN ] Pending - in queue : {}'.format(job.url))


def job_is_complated(last_build):
    assert last_build, f'[ ERROR ] The last_build should NOT be None: {last_build}.'
    while True:
        time.sleep(30)
        if last_build.api_json()['building']:
            logger.console('[ INFO ] The building is ongoing.')
        else:
            logger.console('[ INFO ] The building is complete.')
            if last_build.api_json()['result'] == 'FAILURE':
                raise Exception('[ ERROR ] build is FAILURE.')
            else:
                logger.console('[ INFO ] build result is [ SUCCESS ].')
                break
