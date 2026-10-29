#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
[restriction] !!! DO NOT MODIFY THIS SCRIPT, IF CHANGES NEEDED CONTACT AUTHOR !!!
[description] script for starting snapshot parsing prototype job via terminal
[author] janiraut (jani.rautio@nokia.com)
[version] 0.1 - 29.08.19 - init
[version] 0.14 - Modified to take input as arguments
"""

import sys
import argparse
from argparse import RawTextHelpFormatter
from requests.api import post
from requests_toolbelt import MultipartEncoder
import requests
import time
import os
import subprocess
import uuid

# Try to import jenkins, install if not available
try:
    import jenkins
except ImportError:
    print("Jenkins library not found. Installing python-jenkins...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "python-jenkins"])
    import jenkins

from download_html import download_html, read_html

os.environ.setdefault("PYTHONHTTPSVERIFY", "0")
timeout_in_sec = 500
jenkins_urls = [
    "https://jenkins-1.ou.nsn-rdnet.net",
    "https://ourdsiciv1.emea.nsn-net.net/",
]
jenkins_remote_auth_token = "DoVhtiN0tB"
valid_filter_presets = ["default", "select all", "runtime aasysinfo analysis only"]
valid_hit_limits = ["10000", "50000", "100000", "500000", "1000000", "999999999"]


def wait_for_build_to_finish(jenkins_server, job_name, build_num, poll_interval=10, timeout=600):
    start_time = time.time()
    while True:
        build_info = jenkins_server.get_build_info(job_name, build_num)
        if not build_info['building']:
            return build_info['result']
        if time.time() - start_time > timeout:
            raise TimeoutError("Timeout waiting for Jenkins build to finish")
        print(f"Waiting for build {build_num} to finish...")
        time.sleep(poll_interval)


def snapshot_parser_launcher(user, key, input_file, mode=None, comment=None, hit_limit=None, filter_preset=None,
                             build=False, custom_filter=None):
    uuid_str = str(uuid.uuid4())
    if comment is None:
        comment = "|snapshot_parser_launcher.py|"
    else:
        comment = comment + " |snapshot_parser_launcher.py|"
    if mode is None:
        jenkins_job = "Snapshot_parsing_prototype"
    elif mode == "debug":
        jenkins_job = "Testing_snapshot_parsing_full_copy"
    else:
        raise ValueError(f"Invalid mode setting '{mode}'")
    if hit_limit is None:
        hit_limit = "10000"
    if filter_preset is None:
        filter_preset = "default"
    if custom_filter is None:
        custom_filters = "{disabled}"
    else:
        filters = ","
        custom_filters = str(filters).join(
            {str(regex.replace("\\", "\\\\")) for regex in custom_filter}
        )

    if filter_preset not in valid_filter_presets:
        raise ValueError(f"Invalid filter preset '{filter_preset}'")
    if hit_limit not in valid_hit_limits:
        raise ValueError(f"Invalid hit limit '{hit_limit}'")

    f = open(input_file, "rb")
    payload = MultipartEncoder(
        fields={
            "json": (
                None,
                "{parameter:["
                '{"name":"SNAPSHOT_ZIP", "file":"file0"},'
                '{"name":"USE_EARLIER_ZIP", "value":"{disabled}"},'
                '{"name":"COMMENT", "value":"' + comment + '"},'
                '{"name":"HIT_LIMIT_PER_SET", "value":"' + hit_limit + '"},'
                '{"name":"FILTER_PRESET", "value":"' + filter_preset + '"},'
                '{name:"UUID", "value":"' + uuid_str + '"},'
                '{"name":"CUSTOM_FILTER", "value":"'
                "<script>," + custom_filters + '"}]}',
            ),
            "file0": (input_file, f),
        }
    )

    success = False
    last_exception = None
    build_id = None
    for jenkins_url in jenkins_urls:
        f = open(input_file, "rb")
        payload = MultipartEncoder(
            fields={
                "json": (
                    None,
                    "{parameter:["
                    '{"name":"SNAPSHOT_ZIP", "file":"file0"},'
                    '{"name":"USE_EARLIER_ZIP", "value":"{disabled}"},'
                    '{"name":"COMMENT", "value":"' + comment + '"},'
                    '{"name":"HIT_LIMIT_PER_SET", "value":"' + hit_limit + '"},'
                    '{"name":"FILTER_PRESET", "value":"' + filter_preset + '"},'
                    '{name:"UUID", "value":"' + uuid_str + '"},'
                    '{"name":"CUSTOM_FILTER", "value":"'
                    "<script>," + custom_filters + '"}]}',
                ),
                "file0": (input_file, f),
            }
        )
        jenkins_job_build_url = (
            jenkins_url
            + "/job/"
            + jenkins_job
            + "/build?token="
            + jenkins_remote_auth_token
        )
        target_server = jenkins.Jenkins(jenkins_url, username=user, password=key)
        try:
            r = requests.post(
                jenkins_job_build_url,
                auth=(user, key),
                data=payload,
                verify=False,
                timeout=timeout_in_sec,
                headers={"Content-Type": payload.content_type},
            )
            lists = target_server.get_queue_info()
            for item in lists:
                try:
                    uuid_env = item.get("actions")[0].get("parameters")[5].get("value")
                    if uuid_env == uuid_str:
                        build_id = item.get("id")
                        break
                except Exception:
                    pass
            r.raise_for_status()
            r.close()
            success = True
            f.close()
            break
        except requests.exceptions.RequestException as e:
            last_exception = e
            f.close()
            continue
    if not success:
        raise RuntimeError("All Jenkins URLs failed.") from last_exception

    if build:
        start = time.time()
        while True:
            if time.time() - start >= timeout_in_sec:
                raise TimeoutError("Timeout reached while waiting for build number")
            try:
                if build_id is None:
                    raise RuntimeError("Build id couldn't be polled")
                job_state = target_server.get_queue_item(build_id)
                build_num = job_state.get("executable").get("number")
                if build_num is None:
                    time.sleep(5)
                else:
                    break
            except Exception:
                time.sleep(10)

    time.sleep(60)
    job_state = target_server.get_queue_item(build_id)
    build_num = job_state.get("executable").get("number")
    jenkins_download = (jenkins_job_build_url.split('/build')[0] + "/" + str(build_num) + "/artifact/report/" +
                        input_file.split("\\")[-1] + ".html")
    output_html_file = "jenkins_job_page.html"
    build_result = wait_for_build_to_finish(target_server, jenkins_job, build_num)
    download_html(url=jenkins_download, output_file=output_html_file)
    time.sleep(10)
    read_html(output_html_file)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Trigger Jenkins job", formatter_class=RawTextHelpFormatter)
    parser.add_argument("-u", "--user", required=True, help="Jenkins username")
    parser.add_argument("-k", "--key", required=True, help="Jenkins API key")
    parser.add_argument("-i", "--input_file", required=True, help="Input file path")
    parser.add_argument("-m", "--mode", help="Run mode (debug or official)")
    parser.add_argument("-c", "--comment", help="Comment for the job")
    parser.add_argument("-hl", "--hit-limit", help="Hit limit")
    parser.add_argument("-fp", "--filter-preset", help="Filter preset")
    parser.add_argument("-b", "--build", action="store_true", help="Request build number")
    parser.add_argument("-cf", "--custom-filter", nargs="+", help="Custom regex filters")
    args = parser.parse_args()

    snapshot_parser_launcher(
        user=args.user,
        key=args.key,
        input_file=args.input_file,
        mode=args.mode,
        comment=args.comment,
        hit_limit=args.hit_limit,
        filter_preset=args.filter_preset,
        build=args.build,
        custom_filter=args.custom_filter,
    )
