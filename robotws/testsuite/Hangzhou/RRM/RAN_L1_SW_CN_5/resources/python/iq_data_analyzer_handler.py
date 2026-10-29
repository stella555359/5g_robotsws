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
        output = os.popen("pip install api4jenkins").readlines()
        logger.console(output)
        check_api4jenkins -= 1
        continue

# Global parameters
JENKINS_URL = 'https://jenkins-dev2.loki.devops-fwk.dynamic.nsn-net.net'
JENKINS_TOKEN = '11d92160b312e7ad911a0dba6db522d841'
JENKINS_USER = 'yughou'
JOB_NAME = 'IQ_data_analyzer'

# Input parameters for iq_data_analyzer job
DEFAULT_PARAMS = {
    'target_board': 'DU',
    'is_blind': False,
    # 'rotta_link': '',
    # 'local_iq_data_files': '',
    'l1sw_build': '',
    'carrier_frequency': '',
    'prach_config_index': '-1',
    'slots_to_decode': '',
    'is_72e_dl': False,
    'is_72e_ul': True,
    'event_trigger_only': True,
    'draw_figures_crc_ok': False,
    'fxp': '',
    'is_ml': False,
    'branch_common': 'master',
    'branch_l1sw': 'master',
    'branch_5gmax': 'master',
    'user_defined_file': ''
}


def get_api_json_with_retry(api_object, object_name, retry_count=3, retry_interval=10):
    last_exception = None
    for attempt in range(1, retry_count + 1):
        try:
            return api_object.api_json()
        except Exception as error:
            last_exception = error
            if 'timed out' not in str(error).lower():
                raise

            logger.console(
                "[ WARN ] Timeout when retrieving {} status (attempt {}/{}): {}".format(
                    object_name, attempt, retry_count, error
                )
            )
            if attempt < retry_count:
                time.sleep(retry_interval)

    raise Exception(
        "[ ERROR ] Failed to retrieve {} status after {} attempts: {}".format(
            object_name, retry_count, last_exception
        )
    )


def iq_data_analyzer(l1iq_log_path, local_file, **kwargs):
    try:
        if os.path.exists(l1iq_log_path):
            job_build = iq_data_analyzer_from_local(l1iq_log_path, **kwargs)
        else:
            job_build = iq_data_analyzer_from_rotta(l1iq_log_path, **kwargs)
        print(job_build)
        wait_for_building_is_done(job_build)
        get_build_artifacts(job_build, local_file)
    except Exception as e:
        raise Exception(e)


def iq_data_analyzer_from_local(local_iq_data_files, **kwargs):
    build = None
    # Merge default parameters and input parameters
    params = {**DEFAULT_PARAMS, **kwargs}

    # Check if files exist
    user_defined_file = params['user_defined_file']
    if not os.path.exists(local_iq_data_files):
        raise FileNotFoundError(f"[ ERROR ] The file '{local_iq_data_files}' does not exist.")
    if user_defined_file:
        if not os.path.exists(user_defined_file):
            raise FileNotFoundError(f"[ ERROR ] The file '{user_defined_file}' does not exist.")

    # Build file upload parameters
    files = {
        'local_iq_data_files': open(local_iq_data_files, 'rb')
    }
    if user_defined_file:
        files['user_defined_file'] = open(user_defined_file, 'rb')

    # Build Jenkins Job URL
    job_url = f'{JENKINS_URL}/job/{JOB_NAME}/buildWithParameters'

    logger.console(f"[ INFO ] {JOB_NAME} building with ==>")
    logger.console(f"local_iq_data_files: {local_iq_data_files}")
    for key, value in params.items():
        logger.console(f"{key}: {value}")

    # Send POST request
    try:
        start_build = requests.post(
            job_url,
            auth=(JENKINS_USER, JENKINS_TOKEN),
            data=params,
            files=files,
            verify=False  # Set to True if you have the CA certificate
        )
        if start_build.status_code == 201:
            logger.console("[ INFO ] Job is triggered successfully!")
        else:
            logger.console(f"[ ERROR ] Failed to trigger job. Status code: {start_build.status_code}")
            logger.console(start_build.text)
        time.sleep(20)
        queue_url = start_build.headers['Location']
        if queue_url:
            queue_id = queue_url.strip('/').rsplit('/', 1)[-1]
            build = get_build_id_by_queue_id(queue_id)
    finally:
        # Ensure file handles are closed
        for file in files.values():
            file.close()
        if build:
            return build
        else:
            raise Exception(f'[ ERROR ] Failed to build job {start_build.headers}')


def iq_data_analyzer_from_rotta(l1iq_log_path, **kwargs):
    params = {**DEFAULT_PARAMS, **kwargs}
    target_board = params['target_board']
    slots_to_decode = params['slots_to_decode']
    timeout_counter = 0
    assert target_board in ('DU', 'rfsrm7-thor'), (
        '[ ERROR ] {} should be DU | rfsrm7-thor.'.format(target_board)
    )

    if slots_to_decode:
        assert int(slots_to_decode) in range(10, 751), (
            "[ ERROR ] 'slots_to_decode' should be in [10, 750]."
        )

    rotta_link = r'{}'.format(l1iq_log_path)

    server = connect_to_jenkins()
    job = server.get_job(JOB_NAME)
    job_url = job.url
    logger.console("[ INFO ] {} url is [ {} ]".format(JOB_NAME, job_url))

    logger.console(f"[ INFO ] {JOB_NAME} building with ==>")
    logger.console(f"rotta_link: {rotta_link}")
    for key, value in params.items():
        logger.console(f"{key}: {value}")

    job_build = server.build_job(
        JOB_NAME,
        target_board=params['target_board'],
        is_blind=params['is_blind'],
        rotta_link=rotta_link,
        local_iq_data_files='',
        l1sw_build=params['l1sw_build'],
        carrier_frequency=params['carrier_frequency'],
        prach_config_index=params['prach_config_index'],
        slots_to_decode=params['slots_to_decode'],
        is_72e_dl=params['is_72e_dl'],
        is_72e_ul=params['is_72e_ul'],
        event_trigger_only=params['event_trigger_only'],
        draw_figures_crc_ok=params['draw_figures_crc_ok'],
        fxp=params['fxp'],
        is_ml=params['is_ml'],
        branch_common=params['branch_common'],
        branch_l1sw=params['branch_l1sw'],
        branch_5gmax=params['branch_5gmax'],
        user_defined_file=params['user_defined_file'],
    )
    time.sleep(20)
    build_info = job_build.get_build()
    while True:
        time.sleep(10)
        build_status = get_api_json_with_retry(build_info, 'build')
        if build_status['building']:
            logger.console("[ INFO ] The building url is [ {} ]".format(build_info.url))
            return build_info
        elif build_status['result'] == 'FAILURE':
            logger.console('[ ERROR ] Build is failed with {}'.format(build_status['description']))
            raise Exception("[ ERROR ] Building is FAILURE: {}".format(build_info.url))
        else:
            logger.console('[ WARN ] Pending - in queue : {}'.format(job_build.url))
            timeout_counter += 1
            if timeout_counter > 10:  # Wait for max 10*10=100 seconds
                raise Exception("[ ERROR ] Building is pending for too long: {}".format(build_info.url))


def connect_to_jenkins():
    try:
        # Jenkins server instance
        server = Jenkins(JENKINS_URL, auth=(JENKINS_USER, JENKINS_TOKEN), verify=False)
        user = server.user.api_json()['fullName']
        version = server.version
    except Exception as e:
        if 'The read operation timed out' in str(e):
            try:
                server = Jenkins(JENKINS_URL, auth=(JENKINS_USER, JENKINS_TOKEN), verify=False)
                user = server.user.api_json()['fullName']
                version = server.version
            except Exception as inner_e:
                logger.console("[ ERROR ] Failed to retrieve user and version information: {}".format(inner_e))
                user = "Unknown"
                version = "Unknown"
        else:
            user = "Unknown"
            version = "Unknown"
            raise Exception("[ ERROR ] Failed to retrieve user and version information: {}".format(e))
    finally:
        logger.console("[ INFO ] Jenkins version is [ {} ]".format(version))
        logger.console("[ INFO ] Started by [ {} ]".format(user))
        return server


def get_build_id_by_queue_id(queue_id):
    queue_id = int(queue_id)
    server = connect_to_jenkins()
    job = server.get_job(JOB_NAME)
    job_url = job.url
    logger.console("[ INFO ] {} url is [ {} ]".format(JOB_NAME, job_url))
    build_json = get_api_json_with_retry(job, JOB_NAME)
    builds_list = build_json.get('builds')
    build_id_list = [build.get('number') for build in builds_list]

    # Sort build_id_list in descending order and check the first 5 for correct queue_id
    for build_id in sorted(build_id_list[:5], reverse=True):
        build = job.get(build_id)
        build_queue_id = get_api_json_with_retry(build, 'build').get('queueId')
        if build_queue_id != queue_id:
            continue
        else:
            logger.console("[ INFO ] The building url is [ {} ]".format(build.url))
            return build


def wait_for_building_is_done(job_build):
    while True:
        time.sleep(20)
        build_status = get_api_json_with_retry(job_build, 'build')
        building = build_status['building']
        if not building:
            result = build_status['result']
            logger.console("[ INFO ] Building result is [ {} ]".format(result))
            break
        else:
            logger.console("[ INFO ] Building is ongoing: [ {} ]".format(building))


def get_build_artifacts(job_build, local_file):
    job_url = job_build.url
    api_json = get_api_json_with_retry(job_build, 'build')
    if api_json['result'] == 'FAILURE':
        logger.console('[ ERROR ] Build is failed with {}'.format(api_json['description']))
        raise Exception(f"[ ERROR ] [ {job_url} ] is [ {api_json['result']} ].")
    else:
        artifact = job_url + 'artifact/*zip*/archive.zip'
        logger.console("[ INFO ] Downloading artifacts(archive.zip) : \n{} -> {}".format(artifact, local_file))
        get_response = requests.get(
            artifact,
            auth=(JENKINS_USER, JENKINS_TOKEN),
            stream=True,
            verify=False
        )
        if get_response.status_code == 200:
            with open(local_file, 'wb') as f:
                for chunk in get_response.iter_content(chunk_size=1024):
                    if chunk:
                        f.write(chunk)
                    else:
                        logger.console(f'[ ERROR ] chunk is {chunk}')
            if os.path.exists(local_file):
                logger.console("[ INFO ] Downloaded artifacts(archive.zip) : {}".format(local_file))
            else:
                logger.console("[ ERROR ] {} is NOT existed.".format(local_file))
                logger.console("[ ERROR ] Failed to download artifacts(archive.zip).")
        else:
            raise Exception("[ ERROR ] Failed to download artifacts. Status code: {}".format(get_response.status_code))


if __name__ == '__main__':
    pass
