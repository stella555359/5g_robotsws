"""
Attach structures to hold information gathered from particular log about particular attach. Each structure
can determine attach outcome based on current internal state and can be conveniently printed.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""


class L3Call(object):
    def __init__(self):
        self.ra_rnti = None
        self.msg1 = {'sfn': None, 'slot': None}
        self.msg2 = {'t_rnti': None, 'timing_advance': None, 'rapid_match': None, 'sfn': None, 'slot': None}
        self.msg3 = {'harq_fb': None, 'sfn': None, 'slot': None}
        self.outcome = 'Undetermined'
        self.reason = ''

    def determine_outcome(self):
        self.outcome = 'FAIL'
        if None in self.msg1.values():
            self.reason = 'Attach structure is empty'
            return False
        if None in self.msg2.values():
            self.reason = 'No corresponding msg2 found'
            return False
        if None in self.msg3.values():
            self.reason = 'No coresponding msg3 found'
            return False
        if self.msg3['harq_fb'] == 'FAIL':
            self.reason = 'Msg3 has negative harq feedback'
            return False
        self.outcome = 'SUCCESS'
        return True

    def apply_timing_advance_condition(self, max_ta):
        if self.msg2['timing_advance'] is not None and self.msg2['timing_advance'] > int(max_ta):
            self.outcome = 'GHOST'
            self.reason = 'Timing Advance ({}) exceeds limit of maximum {} for legit attach'.format(
                self.msg2['timing_advance'], max_ta)
            return False
        return True

    def __str__(self):
        color = '\033[92m' if self.outcome == 'SUCCESS' else '\033[91m'
        outcome = '{}{}{}'.format(color, self.outcome, '\033[0m')
        reason = '{}{}{}'.format(color, self.reason, '\033[0m')
        return "Outcome: {}\nReason: {}\nRA_RNTI: {}\nMsg1: {}\nMsg2: {}\nMsg3: {}".format(outcome, reason,
                                                                                           self.ra_rnti, self.msg1,
                                                                                           self.msg2, self.msg3)

    def __repr__(self):
        return self.__str__()

    def __eq__(self, other):
        result = self.ra_rnti == other.ra_rnti
        result = result and self.msg2['rapid_match'] == other.msg2['rapid_match']
        result = result and self.msg3['harq_fb'] == other.msg3['harq_fb']
        return result and self._compare_sfns(other)

    def _compare_sfns(self, other):
        result = abs(self.msg1['sfn'] - other.msg1['sfn']) < 2 or abs(self.msg1['sfn'] - other.msg1['sfn']) > 1022
        result = result and (abs(self.msg2['sfn'] - other.msg2['sfn']) < 2 or abs(self.msg2['sfn'] -
                                                                                  other.msg2['sfn']) > 1022)
        result = result and (abs(self.msg3['sfn'] - other.msg3['sfn']) < 2 or abs(self.msg3['sfn'] -
                                                                                  other.msg3['sfn']) > 1022)
        return result


class BIPAttach(L3Call):
    def __init__(self):
        super(BIPAttach, self).__init__()
        self.msg1['rapid'] = None
        self.msg1['peak_metric'] = None
        self.msg1['initial_ta'] = None
        self.msg3['crc'] = None
        self.msg3['dtx'] = None

    def apply_peak_metric_condition(self, min_peak_metric):
        if self.msg1['peak_metric'] is None:
            self.outcome = 'FAIL'
            self.reason = 'No peak metric found'
            return False
        if self.msg1['peak_metric'] < float(min_peak_metric):
            self.outcome = 'GHOST'
            self.reason = 'Peak metric ({}) is lower than minimum ({})'.format(self.msg1['peak_metric'],
                                                                               min_peak_metric)
            return False
        return True


class UELogAttach(L3Call):
    def __init__(self):
        super(UELogAttach, self).__init__()
        self.msg1['preamble_format'] = None
        self.msg1['prach_config'] = None
        self.msg1['pathloss'] = None
        self.msg1['mtpl'] = None
        self.msg3['harq_id'] = None
        self.msg3['pathloss'] = None
        self.msg3['mtpl'] = None
        self.msg4 = {'sfn': None, 'slot': None}
        self.rsrp = None
        self.rsrq = None
        self.num_attempt = None
        self.pci = None

    def apply_num_attempt_condition(self, max_attempt):
        if self.num_attempt > max_attempt:
            self.outcome = 'FAIL'
            self.reason = 'Num. Attempt ({}) exceeds limit of maximum {} attempts'.format(self.num_attempt,
                                                                                          max_attempt)
            return False
        return True

    def __str__(self):
        return super(UELogAttach, self).__str__() + \
               "\nMsg4: {}\nRSRP: {}\nRSRQ: {}\nPhysical Cell ID: {}".format(self.msg4, self.rsrp, self.rsrq, self.pci)


class QXDMAttach(UELogAttach):
    def __init__(self):
        super(QXDMAttach, self).__init__()
        self.msg1['ra_rnti'] = None
        self.msg1['rapid'] = None
        self.msg4['c_rnti'] = None
        self.rach_outcome = None
        self.contention_type = None

    def determine_outcome(self):
        if self.rach_outcome == 'SUCCESS':
            self.outcome = 'SUCCESS'
            return True
        self.outcome = 'FAIL'
        self.reason = self.rach_outcome
        return False


class ELTAttach(UELogAttach):
    def __init__(self):
        super(ELTAttach, self).__init__()
        self.msg3['tx_power'] = None
        self.msg3['mcs'] = None
        self.is_valid = {'msg1': False, 'msg2': False, 'msg3': False, 'msg4': False}

    def determine_outcome(self):
        self.outcome = 'FAIL'
        if not self.is_valid['msg1']:
            self.reason = 'Invalid msg1'
            return False
        if not self.is_valid['msg2']:
            self.reason = 'Invalid msg2'
            return False
        if not self.is_valid['msg3']:
            self.reason = 'Invalid msg3'
            return False
        if not self.is_valid['msg4']:
            self.reason = 'Invalid msg4'
            return False
        self.outcome = 'SUCCESS'
        return True

    def apply_nsa_specific_conditions(self):
        self.is_valid['msg4'] = True
        self.msg4 = {"N/A (NSA)": "N/A (NSA)"}
        self.msg3['harq_fb'] = 'PASS'
        if self.outcome == 'FAIL' and self.reason == 'Invalid msg4':
            self.outcome = 'SUCCESS'
            self.reason = 'N/A'


class X2APAttach:
    def __init__(self):
        self.sgnb_add_req = False
        self.sgnb_add_req_ack = False
        self.sgnb_rec_comp = False
        self.sn_status_trans = False
        self.rsrp = -1
        self.state = False
        self.state_info = 'Undetermined state'

    def determine_state(self):
        self.state = False
        if not self.sgnb_add_req:
            self.state_info = 'No SgNBAdditionRequest in logs'
            return False
        if not self.sgnb_add_req_ack:
            self.state_info = 'No SgNBAdditionRequestAcknowledge in logs'
            return False
        if not self.sgnb_rec_comp:
            self.state_info = 'No SgNBReconfigurationComplete in logs'
            return False
        if not self.sn_status_trans:
            self.state_info = 'No SNStatusTransfer in logs'
            return False
        self.state = True
        self.state_info = 'RSRP = {}'.format(self.rsrp)
        return True

    def __str__(self):
        return "Status: {} \nInfo: {} \n\nSgNBAdditionRequest: {} \nSgNBAdditionRequestAcknowledge: {} \n" \
               "SgNBReconfigurationComplete: {} \nSNStatusTransfer: {} \n\n RSRP: {}\n"\
            .format(self.state, self.state_info, self.sgnb_add_req, self.sgnb_add_req_ack, self.sgnb_rec_comp,
                    self.sn_status_trans, self.rsrp)

    def __repr__(self):
        return self.__str__()


class NGAPAttach:
    def __init__(self):
        self.init_ue_msg = False
        self.init_context_setup_req = False
        self.init_context_setup_resp = False
        self.state = False
        self.state_info = 'Undetermined state'

    def determine_state(self):
        self.state = False
        if not self.init_ue_msg:
            self.state_info = 'No InitialUEMessage in logs'
            return False
        if not self.init_context_setup_req:
            self.state_info = 'No InitialContextSetupRequest in logs'
            return False
        if not self.init_context_setup_resp:
            self.state_info = 'No InitialContextSetupResponse in logs'
            return False
        self.state = True
        self.state_info = 'N/A'
        return True

    def __str__(self):
        return "Status: {} \nInfo: {} \n\nInitialUEMessage: {} \nInitialContextSetupRequest: {} \n" \
               "InitialContextSetupResponse: {} \n"\
            .format(self.state, self.state_info, self.init_ue_msg, self.init_context_setup_req,
                    self.init_context_setup_resp)

    def __repr__(self):
        return self.__str__()
