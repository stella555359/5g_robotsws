import logging
from dateutil import parser
from moler.device import DeviceFactory
from taf.rfrl.bts.devices.du.logs_collecting.btslog_collector import GnbBtslogCollector


class UeAttachDetachObserver(object):
    _time_regex = r'<(?P<SYSLOG_TIME>[T\d:\-\.]+Z)>'

    # ... <2024-04-24T11:12:09.264123Z> ... /ul/sch/pre/rach/RaProcedure.cpp:1447 Rnti:1171 UE attached: xsfn=166.36
    _re_attach = _time_regex + r'.*Rnti:\d+ UE attached: xsfn=\d+'

    # ... <2024-04-24T11:13:08.855877Z> ... /client/UserStop.hpp:105 UserStop msg:ueIdDu:50003,
    # nrCellIdentity:1248657819, scellToStopList:[], remoteScellToStopList:[], cause:RELEASE
    # PsUserResponseUserStopResp.cpp:36 msgId:0xd273 PsUserResponse::handle: Send resp to C-plane: ueIdDu=1
    _re_detach1 = r'.*UserStop.*nrCellIdentity.*cause:RELEASE$'
    _re_detach2 = r'.*UserStopResp.*Send resp to C-plane: ueIdDu=\d+$'
    # [NRCELL:1248657819 RNTI:61] PsUser::UserStopInd ueIdDu:1, cause:RELEASE,
    _re_detach3 = r'.*\[NRCELL:\d+ RNTI:\d+\] PsUser::UserStopInd ueIdDu:\d+, cause:RELEASE'
    _re_detach = _time_regex + r'(({})|({})|({}))'.format(_re_detach1, _re_detach2, _re_detach3)

    def __init__(self):
        self.btslog = GnbBtslogCollector()
        self.attach_observer = None
        self.detach_observer = None

    def start_ue_attach_and_detach_observer(self, bts_id=0, du_id=0):
        self.btslog.start_collecting_syslog()
        syslog = DeviceFactory.get_device(name=self.btslog.syslog_alias.format(bts_id, du_id))
        syslog.goto_state('SYSLOG', keep_state=False)

        self.attach_observer = syslog.get_event(event_name="wait4",
                                                event_params={
                                                    "detect_patterns": [UeAttachDetachObserver._re_attach],
                                                    "till_occurs_times": 1})

        self.detach_observer = syslog.get_event(event_name="wait4",
                                                event_params={
                                                    "detect_patterns": [UeAttachDetachObserver._re_detach],
                                                    "till_occurs_times": 1})

        self.attach_observer.start()
        self.detach_observer.start()

    def get_attach_detach_diff_time_in_seconds(self):
        attach_results = self.attach_observer.await_done(timeout=10)[0]
        logging.debug("Detected attach event: {}".format(attach_results))
        string_attach_time = attach_results['named_groups']['SYSLOG_TIME']
        logging.debug("Attach time: {}".format(string_attach_time))
        attach_time = parser.parse(string_attach_time)

        detach_results = self.detach_observer.await_done(timeout=100)[0]
        logging.debug("Detected detach event: {}".format(detach_results))
        string_detach_time = detach_results['named_groups']['SYSLOG_TIME']
        detach_time = parser.parse(string_detach_time)
        logging.debug("Detach time: {}".format(string_detach_time))

        diff_time = detach_time - attach_time
        logging.debug("Diff time between detach and attach: {}".format(diff_time))

        self.btslog.stop_collecting_syslog()

        return round(diff_time.total_seconds())
