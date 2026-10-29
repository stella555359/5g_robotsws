import os
import re
import sys
import traceback
import send_email

MAIL_LEVEL = ["Critical"]
STDERR_LEVEL = ["Critical", "Major", "Minor"]


class Report:
    def __init__(self):
        self.in_production_mode = True
        try:
            url = (
                f'https://gerrit.ext.net.nokia.com/gerrit/#/c/{os.environ["ZUUL_CHANGE"]}/'
                f'{os.environ["ZUUL_PATCHSET"]}'
            )
            self.gerrit_url = f"<a href='{url}'>{url}</a>"

        except Exception:
            self.gerrit_url = "Undefined ZUUL_CHANGE variable"

        self.job = os.getenv("BUILD_URL")
        if self.job:
            self.jenkins = f"<a href='{self.job}'>{self.job}</a>"
        else:
            self.jenkins = "Undefined BUILD_URL variable"

        mode = os.environ.get("PERF_PORTAL_DEV_MODE")
        if (mode and mode == "True") or not self.job:
            self.in_production_mode = False

        self.script = os.path.basename(sys.argv[0])

    @staticmethod
    def format_alarm_msg(level, message, is_gerrit_msg):
        msg = f"\n<b>{level} alarms:</b>\n\n{message}\n"
        if is_gerrit_msg:
            return f"Alarm(s):\n{Report.remove_tags_and_urls(message)}\n"
        return msg

    @staticmethod
    def remove_tags_and_urls(string):
        no_bold = re.sub("<.?b>", "", string)
        return re.sub("<.?a.*>", "", no_bold)

    @staticmethod
    def _add_messages_into_body(level_array, message_dict, is_gerrit_msg=False):
        return_message = ""

        for level in level_array:
            message = message_dict.get(level)
            if message:
                return_message += Report.format_alarm_msg(level, message, is_gerrit_msg)

        return return_message

    def alarm(self, messages_dict, th_file=None, perf_portal_short_commit=None):
        email = "i_mn_5gsc_sw_eng_perf_portal_alarm@groups.nokia.com"
        subject = f"Alarm provided by {self.script}"
        body_mail = f"Gerrit link: {self.gerrit_url}\n"
        body_mail += f"Job: {self.jenkins}\n"

        ger_msg = f"- Job: {self.job}\n"

        if th_file:
            perf_commit = perf_portal_short_commit if perf_portal_short_commit else "HEAD"
            th_file_url = (
                "https://gerrit.ext.net.nokia.com/gerrit/gitweb?p=MN/5G/UPLANE/"
                f"ci-scripts.git;a=blob;hb={perf_commit};f=perf_portal/threshold/"
            )
            th_path = f"{th_file_url}{th_file}"
            body_mail += (
                f"Threshold file used as reference : <a href='{th_file_url}{th_file}'>"
                f"{th_file_url}{th_file}</a>\n"
            )
            ger_msg += f"- Threshold file used as reference: {th_path}\n"

        ger_msg += "- Support: I_NPS_SQUAD14_RAVEL@internal.nsn.com"

        body_stderr = body_mail + Report._add_messages_into_body(STDERR_LEVEL, messages_dict)
        mail_message = Report._add_messages_into_body(MAIL_LEVEL, messages_dict)
        ger_msg = (
            Report._add_messages_into_body(MAIL_LEVEL, messages_dict, is_gerrit_msg=True)
            + f"\n{ger_msg}"
        )

        print(f"{subject}\n{body_stderr}", file=sys.stderr, flush=True)
        if self.in_production_mode and mail_message:
            body_mail += mail_message
            try:
                send_email.Email().send(email, subject, body_mail)
            except Exception:
                print("Warning: email not sent")
        else:
            ger_msg = ""

        return ger_msg

    def error(self, message=""):
        email = "i_mn_5gsc_sw_eng_perf_portal_error@groups.nokia.com"
        subject = f"Error provided by {self.script}"
        body = f"Gerrit link: {self.gerrit_url}\n"
        body += f"Job: {self.jenkins}\n\n{traceback.format_exc()}\n{message}"
        print(f"{subject}\n{body}", file=sys.stderr, flush=True)
        if self.in_production_mode:
            send_email.Email().send(email, subject, body)
