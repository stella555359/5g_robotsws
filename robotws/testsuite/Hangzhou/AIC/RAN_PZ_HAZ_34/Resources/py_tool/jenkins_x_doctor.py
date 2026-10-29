# -*- coding: utf-8 -*-
import requests
import time
from requests.auth import HTTPBasicAuth
import os
import logging
logger = logging.getLogger(__name__)
logger.addHandler(logging.NullHandler())
log_format = "%(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.DEBUG, format=log_format)


class jenkins_x_doctor:
    """
    author: Rao Hongping
    contact: hongping.rao@nokia-sbell.com

    Documentation: Jenkins interface for x doctor:
    1. fhgw scf commision

    Note:
    x doctor a tool set developed by Zhang Xiaomian(xiaomian.zhang@nokia-sbell.com)
    usage refer to:  http://x-doctor.int.nokia-sbell.com:8080
    support contact: xiaomian.zhang@nokia-sbell.com
    """
    def __init__(self):
        self.jenkins_url = r'http://x-doctor.int.nokia-sbell.com:8080'
        self.job_name = 'view/FHGW_Installation_Commision/job/02_FHGW_SCF_Commision'
        self.auth = HTTPBasicAuth("horao", "11e0ec92524dea0e45ce5bc973005ae64b")

    def get_next_build_number(self):
        logger.info("get next build number")
        res = requests.get("{}/{}/api/json".format(self.jenkins_url, self.job_name), auth=self.auth)
        next_build = res.json()['nextBuildNumber']
        logger.info("next build number: {}".format(next_build))
        return next_build

    def get_console_log(self, build_num):
        logger.info("get console log for build {}:".format(build_num))
        res = requests.get("{}/{}/{}/consoleText".format(self.jenkins_url, self.job_name, build_num), auth=self.auth)
        return res.text

    def get_crumb_data(self):
        logger.info("get crumb data")
        res = requests.get("{}/crumbIssuer/api/json".format(self.jenkins_url), auth=self.auth)
        crumb_data = res.json()['crumb']
        logger.info("crumb data: {}".format(crumb_data))
        return crumb_data

    def trigger_build_for_fhgw_scf_commision(self, scf_file_path, fhgw_id, fhgw_ip):
        if not os.path.exists(scf_file_path):
            raise "scf file path not exists: {}".format(scf_file_path)
        next_build = self.get_next_build_number()
        build_url = "{}/{}/{}/api/json".format(self.jenkins_url, self.job_name, next_build)
        crumb_data = self.get_crumb_data()
        header = {'Jenkins-Crumb': crumb_data}
        # params = {"FHGW_ID": fhgw_id, "FHGW_IP": fhgw_ip}
        params = {"FHGW_ID": fhgw_id, "FHGW_IP": fhgw_ip, "fhgw_scf_operation": 'commision'}
        files = {'fhgw_scf.xml': open(scf_file_path, 'rb')}
        res = requests.post("{}/{}/buildWithParameters".format(self.jenkins_url, self.job_name),
                            data=params, files=files, auth=self.auth, headers=header)
        res.raise_for_status()
        time.sleep(5)
        logger.info("Job triggered: {}".format(next_build))
        logger.info("post res: {}".format(res.content))
        update_build_num_flag = False

        while True:
            logger.info("Checking job status")
            try:
                build_status = requests.get(build_url, auth=self.auth).json()
            except ValueError:
                logger.warning("build is pending in queue, waiting 10 seconds...")
                time.sleep(10)
                continue

            if not update_build_num_flag:
                target = [i['parameters'] for i in build_status['actions'] if 'parameters' in i]
                logger.info("target: {}".format(target))
                para_list = []
                if target:
                    para_list = [i for i in target[0] if 'name' in i and 'value' in i and i['name'] == "FHGW_ID"]
                logger.info("target1: {}".format(para_list))
                if para_list:
                    parameters = para_list[0]
                    if str(parameters['value']) != str(fhgw_id):
                        next_build = next_build + 1
                        logger.warning("update build num: {}".format(next_build))
                        build_url = "{}/{}/{}/api/json".format(self.jenkins_url, self.job_name, next_build)
                        try:
                            build_status = requests.get(build_url, auth=self.auth).json()
                        except ValueError:
                            logger.warning("build is pending in queue, waiting 10 seconds...")
                            time.sleep(10)
                            continue
                    else:
                        logger.info("fhgw id is: {}".format(fhgw_id))
                        update_build_num_flag = True

            if not build_status['building']:
                break
            else:
                logger.info("build is ongoing: waiting 10 seconds")
                time.sleep(10)
        if build_status['result'] == 'SUCCESS':
            logger.info("build finished: {}".format(build_status['result']))
        else:
            logger.warning("build finished: {}".format(build_status['result']))
        logger.info(build_status)
        return (build_status['result'], next_build)
