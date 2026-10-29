import os
import sys
import subprocess
import urllib3
import requests
import gerrit_api_rest

GERRIT_HOST = "gerrit.ext.net.nokia.com"
GERRIT_SSH_PORT = "29418"


class Gerrit:
    def __init__(self, send_gerrit_comment=True):
        gerrit_url = f"https://{GERRIT_HOST}/gerrit/"
        login = "ca_perfportal"
        password = "Welcome123"

        auth = requests.auth.HTTPBasicAuth(login, password)
        urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)
        self.rest = gerrit_api_rest.GerritRestAPI(url=gerrit_url, auth=auth, verify=False)
        self.review = gerrit_api_rest.GerritReview()
        self.send_comment_available = send_gerrit_comment
        self.parent_commit_date = None

        if send_gerrit_comment:
            try:
                self.change_id = str(os.environ["ZUUL_CHANGE"])
                self.zuul_patchset = os.environ["ZUUL_PATCHSET"]
                self.jenkins_job = os.environ["BUILD_URL"]

                parent_commit = self.rest.get(
                    f"changes/{self.change_id}/revisions/{self.zuul_patchset}/commit"
                )["parents"][0]["commit"]
                self.parent_commit_date = self.rest.get(f"changes/?q=commit:{parent_commit}")[0][
                    "submitted"
                ]
            except Exception:
                self.send_comment_available = False

    def __del__(self):
        if hasattr(self, "rest"):
            self.rest.session.close()

    def get_commit_date(self, commit_name):
        print("get commit date start...", flush=True)
        commit_info = self.rest.get(f"changes/?q=commit:{commit_name}")
        if len(commit_info) == 1:
            if "submitted" in commit_info[0]:
                return commit_info[0]["submitted"].split(".")[0]
            if "updated" in commit_info[0]:
                return commit_info[0]["updated"].split(".")[0]
            if "created" in commit_info[0]:
                return commit_info[0]["created"].split(".")[0]

        raise ValueError(f"No date found for commit name: {commit_name}")

    @staticmethod
    def git_clone_time_marker():
        print("clone timemarker start...", flush=True)
        try:
            git = f'{os.environ["GIT_HOME"]}/bin/git'
        except Exception:
            git = "git"

        result = subprocess.run(
            f"{git} clone --depth=1 ssh://{GERRIT_HOST}:{GERRIT_SSH_PORT}/MN/5G/COMMON/timeMarker",
            check=False,
            shell=True,
            universal_newlines=True,
            stderr=subprocess.PIPE,
            stdout=sys.stderr.buffer,
        )
        if result.returncode:
            raise SystemError(f"git clone timeMarker message is: {result.stderr}")

    def get_perf_portal_commit(self):
        try:
            return self.rest.get("projects/MN%2F5G%2FUPLANE%2Fci-scripts/branches/master")[
                "revision"
            ]
        except Exception:
            return None

    def send_comments(self, message):
        if self.send_comment_available:
            self.review.set_message(message)
            if os.getenv("ZUUL_PIPELINE") != "post":
                self.review.add_labels({"Code-Review": -1})
            self.rest.review(self.change_id, self.zuul_patchset, self.review)
