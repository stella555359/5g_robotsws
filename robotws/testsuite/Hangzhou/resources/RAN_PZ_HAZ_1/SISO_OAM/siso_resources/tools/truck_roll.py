import json
import subprocess


class truck_roll(object):
    """
    This library will provide keywords to stop and fix.

    """

    ROBOT_LIBRARY_SCOPE = 'TEST SUITE'
    __version__ = '0.1'

    def __init__(self):
        self.receiver = ""

    def stop_fix_notification(self):
        with open('/opt/ute/execution.context.json') as json_file:
            result = json.load(json_file)
        cm_execution_id = result['CM_EXECUTION_ID']
        cmd = r'echo "put /opt/ute/execution.context.json %s.json"' % cm_execution_id \
              + r' | cadaver http://webdav.ute.nsn-rdnet.net/tmp/stop_and_fix/'
        p = subprocess.check_output(cmd, shell=True)
        print(p)

    def mkw(self, kwname, *args):
        from robot.libraries import BuiltIn
        builtin = BuiltIn.BuiltIn()
        return builtin.run_keyword(kwname, *args)

    def send_email(self, receiver="",
                   cc_list="",
                   subject="stop and fix for ",
                   content="",
                   tlname=None):
        self.mkw('log to console', 'Send email to {}'.format(receiver))
        import json
        import os
        import traceback
        if content == "" or content is None:
            if os.path.exists("/opt/ute/execution.context.json"):
                try:
                    msg_file = "/opt/ute/execution.context.json"
                    with open(msg_file) as json_file:
                        f_content = json.dumps(json.load(json_file))
                        content = f_content["CM_EXECUTION_LINK"] + "/r/n"
                        content += f_content
                except Exception as e:
                    self.mkw("log to console", "get content failed")
                    print(traceback.format_exc())
        if tlname is None:
            subject += self.mkw("Get Scout Testline Name").replace("_1", "")
        if not receiver:
            receiver, team = self.get_tl_owner(tlname)
        api = MongooseApi()
        api.request_stop_fix(params={"reciever": receiver,
                                     "cc_list": cc_list,
                                     "subject": subject,
                                     "content": content})

    def get_tl_owner(self, tlname):
        import traceback
        if tlname is None:
            tlname = self.mkw("Get Scout Testline Name")
        try:
            api = MongooseApi()
            user, team = api.request_scout_tl_owner(tlname=tlname)
            if user and team:
                return user, team
            else:
                return "", None
        except Exception as e:
            self.mkw("Log to console", "failed to get test line owner, will use default TA email")
            print(traceback.format_exc())
            return "", None


class MongooseApi(object):
    """use to send request to mongoose or other RRM7 server"""

    def __init__(self):
        # self.url = "http://dev5.eecloud.dynamic.nsn-net.net"
        self.url = "http://10.109.1.216"
        self.__header = {
            "Content-Type": "application/json",
            "Accept": "application/json"
            # to do : add token
        }

    def add_token(self, token):
        self.__header["Authorization"] = token

    def request_stop_fix(self,
                         url_append="apis/stop_and_fix",
                         m="POST",
                         params={}):
        import requests
        params.setdefault("reciever", "i_nsb_mn_ran_pz1_haz_ta_aic_gms@internal.nsn.com")
        params.setdefault("cc_list", [])
        params.setdefault("subject", "stop and fix")
        params.setdefault("content", "no msg")
        reponse = requests.request(url="{}/{}".format(self.url, url_append),
                                   method=m,
                                   data=params)
        if reponse.status_code == 200:
            return "success"
        else:
            raise Exception("Can't send email to {}".format(params["reciever"]))

    def request_scout_tl_owner(self, tlname):
        import requests
        token = "779b67c1f076465dbd0375cf51e39f87"
        url = 'https://scout.nsn-rdnet.net/api/v1/testlines/{}/'.format(tlname)
        params = {"fields[testline]": "name,user,team", 'include': "user,team.user", "apitoken": token}
        reponse = requests.request(url=url, params=params, method='GET')
        import pprint
        pprint.pprint(reponse.json())
        pprint.pprint(reponse.status_code)
        if reponse.status_code == 200:
            users = []
            team = None
            for x in reponse.json()['included']:
                if x["type"] == "user":
                    users.append(x['attributes']["email"])
                if x["type"] == "team":
                    team = x['attributes']["name"]
            if len(users) and team:
                return ";".join(users), team
        raise Exception("Can't get the user form scout of tl {}".format(tlname))
