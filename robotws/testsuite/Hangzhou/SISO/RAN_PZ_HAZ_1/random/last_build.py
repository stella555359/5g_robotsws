import os
import requests
import json
import subprocess
from taf.sbts.oam.coam.admin import admin

ACCESS_KEY = "a4zS8OqgORdbgBcPl1zeARszoMOkWBdq3XwsFGl5"


class LastBuild(object):

    @classmethod
    def get_last_build(cls, branch="SBTS00", access_key=ACCESS_KEY):
        url = "https://wft.int.net.nokia.com:8091/api/v1/build.json"
        params = {
            "page": 1,
            "items": 1,
            "sorting_field": "created_at",
            "sorting_direction": "DESC",
            "group_by": "branch.title",
            "group_by_processor": "",
            "columns": {
                "0": {
                    "id": "deliverer.project.full_path"
                },
                "1": {
                    "id": "deliverer.title"
                },
                "2": {
                    "id": "version"
                },
                "3": {
                    "id": "branch.title"
                },
                "4": {
                    "id": "state"
                },
                "5": {
                    "id": "planned_delivery_date"
                },
                "6": {
                    "id": "common_links"
                },
                "7": {
                    "id": "compare_link"
                }
            },
            "projects": [
                "ALL"
            ],
            "view_filters_attributes": {
                "0": {
                    "column": "branch.title",
                    "operation": "eq",
                    "value": branch,
                    "parameter": ""
                },
                "1": {
                    "column": "state",
                    "operation": "eq",
                    "value": "RELEASED",
                    "parameter": ""
                },
                "2": {
                    "column": "component",
                    "operation": "cont",
                    "value": "CI_ENB",
                    "parameter": ""
                },
                "3": {
                    "column": "deliverer.project.full_path",
                    "operation": "cont",
                    "value": "SBTS",
                    "parameter": ""
                },
                "4": {
                    "column": "state",
                    "operation": "eq",
                    "value": "RELEASED_WITH_RESTRICTIONS",
                    "parameter": ""
                }
            },
            "access_key": access_key
        }

        headers = {'content-type': "application/json"}
        res = requests.post(url, data=json.dumps(params), headers=headers, verify=False).json()
        return res["items"][branch][0]["version"]

    @classmethod
    def sw_download(cls, sw_version, target_dir="/home/ute/Downloads", package_type="Normal", package_variant="A54",
                    timeout=3600):
        # url = "http://files.ute.nsn-rdnet.net/builds/enb/base/{}/{}_release_BTSSM_downloadable{}.zip"
        arti_hz = "https://artifactory-hz1.int.net.nokia.com/artifactory/mn-cosi-sran-central-public-remote/build/"
        url_wft = "{base}/{release}/{build}/{build}_release_BTSSM_downloadable{pack_type}_{pack_variant}.zip"
        release = sw_version.split("_")[0]
        suffix = ""
        if package_type == "T1":
            suffix = "_testpackage_T1"
        if package_type == "T2":
            suffix = "_testpackage_T2"

        if package_type == "CMCC":
            suffix = "_CMCC"
            package_variant = "A50"
        elif package_type == "E":
            package_variant += "E"

        # if package_type == "Normal" and package_variant == "A54":
        #     package_url = url.format(sw_version, sw_version, suffix)
        # else:
        package_url = url_wft.format(base=arti_hz,
                                     release=release,
                                     build=sw_version,
                                     pack_type=suffix,
                                     pack_variant=package_variant)
        print(package_url)
        wget_cmd = ['timeout', str(timeout), 'wget', '-P', str(target_dir), str(package_url)]
        proc = subprocess.Popen(wget_cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        out, err = proc.communicate()
        if proc.returncode != 0:
            raise Exception('Software package has not been downloaded.\n STDOUT: {}\n STDERR: {}\n RETURN_CODE: {}'.
                            format(out, err, proc.returncode))

        return os.path.join(target_dir, package_url.split("/")[-1])

    @classmethod
    def upload_last_build(cls, branch="SBTS00", target_dir="/home/ute/Downloads", package_type="Normal",
                          package_variant="A54", timeout=3600, access_key=ACCESS_KEY):
        version = cls.get_last_build(branch, access_key)
        files = [file for file in os.listdir(target_dir) if version in file]
        if not bool(files):
            sw_path = cls.sw_download(version, target_dir, package_type, package_variant, timeout)
        else:
            sw_path = os.path.join(target_dir, files[0])
        coam = admin()
        coam.setup_admin()
        coam.update_software(sw_path, timeout=4200)
        coam.teardown()


if __name__ == "__main__":
    LastBuild.upload_last_build()
