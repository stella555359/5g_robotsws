from moler.util.moler_test import MolerTest
from taf.gnb.oam.coam.admin import admin
from testsuite.Krakow.resources.linux_accounts.system_account_permissions\
    import load_moler_configuration_from_tl
from testsuite.Krakow.resources.linux_accounts.logging.auth_logs import AuthLogs
from moler.cmd import RegexHelper

expected = [
    [{"operation": "SSH Login operation",
      "procedureResult": "Succeeded",
      "userName": "serviceuser"},
     {"operation": "SSH Login operation",
      "procedureResult": "Succeeded",
      "userName": "toor4nsn"},
     {"operation": "SSH Logout Operation",
      "procedureResult": "Succeeded",
      "userName": "toor4nsn"},
     {"operation": "SSH Logout Operation",
      "procedureResult": "Succeeded",
      "userName": "serviceuser"},
     {"operation": "SSH Login operation",
      "procedureResult": "Failed",
      "userName": "illegal user toor4nsn"},
     {"operation": "SSH Login operation",
      "procedureResult": "Failed",
      "userName": "toor4nsn"},
     {"operation": "SSH Login operation",
      "procedureResult": "Failed",
      "userName": "serviceuser"}],
    [{"operation": "SSH Login operation",
      "procedureResult": "Succeeded",
      "userName": "serviceuser"},
     {"operation": "SSH Login operation",
      "procedureResult": "Succeeded",
      "userName": "toor4nsn"},
     {"operation": "SSH Logout Operation",
      "procedureResult": "Succeeded",
      "userName": "toor4nsn"},
     {"operation": "SSH Logout Operation",
      "procedureResult": "Succeeded",
      "userName": "serviceuser"}],
    [{"operation": "SSH Login operation",
      "procedureResult": "Failed",
      "userName": "toor4nsn"}],
    [{"operation": "SSH Login operation",
      "procedureResult": "Succeeded",
      "userName": "toor4nsn"}],
    [{"operation": "SSH Login operation",
      "procedureResult": "Failed",
      "userName": "toor4ns"}],
    [{"operation": "SSH Logout Operation",
      "procedureResult": "Succeeded",
      "userName": "toor4nsn"}],
    [  # 5GC001576-GA_23
        {"operation": "SSH Login operation",
         "procedureResult": "Succeeded",
         "userName": "toor4nsn"},
        {"operation": "SSH Login operation",
         "procedureResult": "Succeeded",
         "userName": "serviceuser"},
    ],
    [  # 5GC001576-GA_24
        {"operation": "SSH Login operation",
         "procedureResult": "Succeeded",
         "userName": "toor4nsn"},
        {"additionalText": 'SM-1011 export PS1="${PS1::-5} $ ";ls -l;exit;',
         "operation": "SSH Logout Operation",
         "procedureResult": "Succeeded",
         "userName": "toor4nsn"},
        {"operation": "SSH Login operation",
         "procedureResult": "Succeeded",
         "userName": "serviceuser"},
        {"additionalText": r'SM-1011 export PS1="${PS1::-5} $ ";ls -l;exit;',
         "operation": "SSH Logout Operation",
         "procedureResult": "Succeeded",
         "userName": "serviceuser"}
    ],
    [  # 5GC001576-GA_25
        {"operation": "SSH Login operation",
         "procedureResult": "Failed",
         "userName": "toor4nsn"},
        {"operation": "SSH Login operation",
         "procedureResult": "Failed",
         "userName": "serviceuser"},
    ],
    [  # 5GC001576-GA_26
        {"errorCode": "MaxLoginAttemptsExceeded",
         "operation": "SSH Login operation",
         "procedureResult": "Failed",
         "userName": "toor4nsn"},
        {"errorCode": "MaxLoginAttemptsExceeded",
         "operation": "SSH Login operation",
         "procedureResult": "Failed",
         "userName": "serviceuser"}
    ],
]


class RuemLog(AuthLogs):

    def __init__(self):
        AuthLogs.__init__(self)
        self._regex_helper = RegexHelper()
        self.time = None

    @load_moler_configuration_from_tl()
    @MolerTest.raise_background_exceptions(check_steps_end=True)
    def check_system_log_events(self, tc_number):
        """
        Check EVENTS in SYSTEM_LOG object

        :return: None
        """
        log = self.get_system_log_events_content()
        _expected = expected[int(tc_number)]
        checked = []
        MolerTest.info("Log", dump=log)
        for item in log:
            if self._compare_log_time(item['procedureStartDate']):
                for _dict in _expected:
                    if set(_dict.keys()) <= set(item.keys()) and set(_dict.values()) <= set(item.values()):
                        checked.append(_dict)
                        break
        ret = [item for item in _expected if item not in checked]
        if ret:
            MolerTest.error("Missing items in ruemlog_has.json", dump=ret)
        MolerTest.steps_end()

    def cat_auditlogserver(self, args):
        """
        Check if auditlogserver.db can be read

        :return: None
        """
        user = args[0]
        cmd_cat = self.moler_device.get_cmd(cmd_name="cat", cmd_params={"path": "/ffs/fs1/config/auditlogserver.db"})
        res = cmd_cat()
        if not res:
            if user == "toor4nsn":
                MolerTest.error("unable to read auditlogserver.db file")
            else:
                return
        if user != "toor4nsn":
            MolerTest.error("auditlogserver.db can be read")

    @staticmethod
    def get_system_log_events_content():
        """
        Get content of EVENTS in SYSTEM_LOG object

        :return: None
        """
        event_list = []
        api = admin()
        connection = api.connect_to()
        result = connection.get_managed_objects(class_name="EVENT", timeout=30)
        connection.disconnect()
        for event in result:
            if "SYSTEM_LOG" in event["distName"]:
                if event["parameters"].pop("changedObjectDetails", None):
                    del event["parameters"]["changedObjectDetails"]
                event_list.append(event["parameters"])

        return event_list
