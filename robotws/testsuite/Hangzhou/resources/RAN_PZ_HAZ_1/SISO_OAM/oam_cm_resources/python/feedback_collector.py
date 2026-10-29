import logging
import requests
import time

FEEDBACK_COLLECTOR_HOST = "http://cidash.netact.nsn-rdnet.net/fastpass"
FEEDBACK_COLLECTOR_TOKEN = "FPTOKEN"
FEEDBACK_COLLECTOR_JOB_NAME = "Fast_Pass_Feedback_Collector"

PROP_MODE_APPEND = "append"
PROP_MODE_OVERWRITE = "overwrite"

STATUS_SUCCESS = "success"
STATUS_STARTED = "started"
STATUS_FAILED = "failed"

LOGGING_DATE_FORMAT = "%a, %d %b %Y %H:%M:%S"
LOGGING_TEXT_FORMAT = "%(asctime)s [%(levelname)s] [%(threadName)s] %(message)s"
LOGGING_FILE_NAME = "logs_example.log"


class FeedbackData(object):
    def __init__(self, scope, stage_name, stage_status, scope_complete=False, env="", baseline="", props=None, *args,
                 **kwargs):
        self.scope = scope
        self.stage_name = stage_name
        self.stage_status = stage_status
        self.scope_complete = scope_complete
        self.env = env
        self.baseline = baseline
        self.props = props

    def to_param_str(self):
        '''
        http://10.164.197.208:8080/job/fp_collect_feedback/buildWithParameters?token=FPTOKEN&
        &stage=scope:syve|env:clab234|baseline:99.0.1.2|name:create_jira_ticket|status:success
        &props=name:syve_picked|value:yes|mode:overwrite##name:demo_syve_picked|value:yes|mode:overwrite
        '''
        param_str = "scope_complete={}&stage=scope:{}|env:{}|baseline:{}|name:{}|status:{}".format(
            1 if self.scope_complete else 0, self.scope, self.env, self.baseline, self.stage_name, self.stage_status)
        prop_strs = []
        if self.props and len(self.props) > 0:
            for entry in self.props:
                prop_strs.append("name:{}|value:{}|mode:{}".format(entry.name, entry.value, entry.mode))
        return param_str if len(prop_strs) == 0 else "{}&props={}".format(param_str, "##".join(prop_strs))


class FeedbackProperty(object):
    def __init__(self, name, value, mode=PROP_MODE_OVERWRITE, *args, **kwargs):
        self.name = name
        self.value = value
        self.mode = mode

    def __str__(self):
        return "[ name: {}, value: {}, mode: {} ]".format(self.name, self.value, self.mode)


class JenkinsTrigger(object):
    def __init__(self, host, token, delay=3):
        self.token = token
        self.host = host
        self.delay = delay

    def _is_job_succeed(self, job_uri):
        while True:
            uri = "{}/api/json".format(job_uri)
            res = requests.get(uri)
            if res.status_code is 200:
                data = res.json()
                if data['building']:
                    time.sleep(self.delay)
                    continue
                logging.debug("Job result: {}".format(data["result"]))
                return data["result"] == "SUCCESS"
            else:
                return False

    def _get_job_uri_by_queue(self, queue_uri):
        while True:
            uri = "{}/api/json".format(queue_uri)
            res = requests.get(uri)
            if res.status_code is 200:
                data = res.json()
                if "executable" in data:
                    job_url = data["executable"]["url"]
                    # logging.debug("Executable url: {}".format(job_url))
                    return job_url
                else:
                    time.sleep(self.delay)
            else:
                return None

    def build_with_parameters(self, job_name, params):
        uri = "{}/job/{}/buildWithParameters?token={}&{}".format(self.host, job_name, self.token, params)
        res = requests.get(uri)
        if res.status_code is 201:
            queue_url = res.headers['Location']
            # logging.debug("Job queued: {}".format(queue_url))
            job_url = self._get_job_uri_by_queue(queue_url)
            if job_url:
                return self._is_job_succeed(job_url)
        return False


def send_feedback(path, feedback_data):
    client = JenkinsTrigger(FEEDBACK_COLLECTOR_HOST, FEEDBACK_COLLECTOR_TOKEN)
    params = "package_path={}&{}".format(path, feedback_data.to_param_str())
    logging.info("Provide feedback on uri: {}".format(path))
    if client.build_with_parameters(FEEDBACK_COLLECTOR_JOB_NAME, params):
        logging.info("Provided feedback on uri: {}".format(path))
    else:
        logging.error("Failed to provide feedback on uri: {}".format(path))


def init_logging():
    logging.basicConfig(level=logging.DEBUG, format=LOGGING_TEXT_FORMAT, datefmt=LOGGING_DATE_FORMAT,
                        filename=LOGGING_FILE_NAME, filemode='w')
    console = logging.StreamHandler()
    console.setLevel(logging.DEBUG)
    formatter = logging.Formatter(LOGGING_TEXT_FORMAT)
    console.setFormatter(formatter)
    logging.getLogger('').addHandler(console)


mock_data = [
    FeedbackData(
        scope="syve",
        stage_name="sanity testing",
        stage_status=STATUS_SUCCESS,
        env="clab234",
        baseline="99.0.1.2",
        scope_complete=False
    )
]


def send_feedback_keyword(fp_filename, stage, lab, status, complete=0):
    fD = FeedbackData(
               scope="syve",
               stage_name=stage,
               stage_status=status,
               env=lab,
               baseline="",
               scope_complete=complete,
    )
    send_feedback(fp_filename, fD)
