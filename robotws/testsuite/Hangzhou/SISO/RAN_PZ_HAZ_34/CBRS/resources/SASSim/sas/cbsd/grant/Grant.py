#!/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import ssl
import time
import datetime
import json
import threading
from httpBase.HttpRequestParser import HttpRequestParser
from sas.Consts import *

INT_EVENT_HEADER = 'POST /uri/v1.0/intEvent ' \
                   'HTTP/1.1\r\nHost:www.Nokia.com\r\nContent-type: ' \
                   'application/json\r\n\r\n'


def hb_timeoutAction(*args):
    # args is a object of Grant
    grant = args[0]
    grant.log.warning('grant %s heartbeat timeout!' % grant.get_ID())
    # sent a internal timeout event
    int_event_send(grant, EVENT_HEARTBEAT_TIMEOUT)


def grant_timeoutAction(*args):
    grant = args[0]
    grant.log.warning('grant %s grant expire timeout!' % grant.get_ID())
    # sent a internal timeout event
    int_event_send(grant, EVENT_GRANT_TIMEOUT)


def transmit_timeoutAction(*args):
    grant = args[0]
    grant.log.warning('grant %s transmit expire timeout!' % grant.get_ID())
    # sent a internal timeout event
    int_event_send(grant, EVENT_TRANSMIT_TIMEOUT)


def int_event_send(grant, eventType):
    if eventType not in sas_int_event_t:
        grant.log.warning('incorrect internal event type %s' % eventType)
    try:
        http_header = INT_EVENT_HEADER
        req_data = {}
        req_data[PAR_EVENT_TYPE] = eventType
        req_data[PAR_CBSD_ID] = grant.get_cbsdID()
        req_data[PAR_GRANT_ID] = grant.get_ID()
        req_data_json = json.dumps(req_data)
        req = http_header.encode('utf-8') + req_data_json.encode('utf-8') + b'\r\n'
        sock = socket.socket(socket.AF_INET)
        sock.setblocking(1)
        sock.settimeout(2)
        if (grant.config.CONNECT_MODE_TLS is not False):
            conn = ssl.wrap_socket(sock, grant.config.KEY_FILE, grant.config.CERT_FILE, cert_reqs=ssl.CERT_NONE,
                                   ssl_version=ssl.PROTOCOL_SSLv23)
            conn.connect(("localhost", grant.config.PORT_NUM))
            conn.sendall(req)
            conn.close()
        else:
            sock.connect(("localhost", grant.config.PORT_NUM))
            sock.sendall(req)
            sock.close()
        grant.log.info("internal event msg was sent out")
    except socket.timeout:
        grant.log.error('fail to send internal event due to socket timeout!')
    except Exception:
        grant.log.error('fail to send internal event due to a error!')


class Grant(object):
    def __init__(self, config, logHandler):
        self.config = config
        self.log = logHandler
        self.cbsdID = ''
        self.opState = GRANT_STATE_IDLE
        self.grantID = ''
        self.MaxEIRP = 0
        self.lowFreq = 0
        self.highFreq = 0
        self.PALChannel = False
        self.grantExp = None
        self.grantRenew = False
        self.transmitExp = None
        self.hbTimer = None
        self.grantTimer = None
        self.transmitTimer = None

    def get_grantExp(self):
        if self.opState != GRANT_STATE_IDLE:
            return self.grantExp
        else:
            return None

    def get_transmitExp(self):
        if self.opState != GRANT_STATE_IDLE:
            return self.transmitExp
        else:
            return None

    def get_transmitExp_ex(self):
        # return transmitExp without state check
        return self.transmitExp

    def get_maxEirp(self):
        if self.opState != GRANT_STATE_IDLE:
            return self.MaxEIRP
        else:
            return None

    def get_lowFreq(self):
        if self.opState != GRANT_STATE_IDLE:
            return self.lowFreq
        else:
            return None

    def get_highFreq(self):
        return self.highFreq
        if self.opState != GRANT_STATE_IDLE:
            return self.highFreq
        else:
            return None

    def get_ID(self, lowFreq=None, highFreq=None):
        if (lowFreq is not None and highFreq is not None):
            return str(lowFreq) + '_' + str(highFreq)
        else:
            if self.opState != GRANT_STATE_IDLE:
                return self.grantID
            else:
                return None

    def get_cbsdID(self):
        return self.cbsdID

    def grantRenew(self):
        return self.grantRenew

    def isPALGrant(self):
        return self.PALChannel

    def grant(self, cbsdID, maxEirp, lowFreq, highFreq, channel_list, tlist, cbsdIsPPA=False, *args):
        if self.opState != GRANT_STATE_IDLE:
            self.log.warning('invalid grant request because grant %s is not in idle state' % self.grantID)
            return [502, '']

        matched = False
        for ch_id in channel_list.keys():
            if (channel_list[ch_id][0][0] <= lowFreq and channel_list[ch_id][0][0] <= highFreq and
                    channel_list[ch_id][0][1] >= lowFreq and channel_list[ch_id][0][1] >= highFreq):
                matched = True
                # If the CBSD is a member of the list of CBSDs associated with a PPA, and if the requested
                # frequency range is within that PPA's PAL reserved portion of the band, the Grant request
                # is considered to be a PAL Grant request.
                if cbsdIsPPA is True and channel_list[ch_id][1] is True:
                    self.PALChannel = True
                    self.log.info('matched PAL channel %s [%d - %d]' %
                                  (ch_id, channel_list[ch_id][0][0], channel_list[ch_id][0][1]))
                else:
                    self.log.info('matched GAA channel %s [%d - %d]' %
                                  (ch_id, channel_list[ch_id][0][0], channel_list[ch_id][0][1]))
                break

        if matched is False:
            # join individaul channel
            join_list = {}
            key_list = list(channel_list.keys())
            key_list.sort()
            for ch_id in key_list:
                joined = False
                for join_id in join_list.keys():
                    if join_list[join_id][0][1] == channel_list[ch_id][0][0]:
                        join_list[join_id][0][1] = channel_list[ch_id][0][1]
                        join_list[join_id][1] = False
                        joined = True
                        break
                    elif join_list[join_id][0][0] == channel_list[ch_id][0][1]:
                        join_list[join_id][0][0] = channel_list[ch_id][0][0]
                        join_list[join_id][1] = False
                        joined = True
                        break
                if joined is False:
                    join_list.setdefault(ch_id, [[channel_list[ch_id][0][0], channel_list[ch_id][0][1]],
                                                 channel_list[ch_id][1]])
            for ch_id in join_list.keys():
                if (join_list[ch_id][0][0] <= lowFreq and join_list[ch_id][0][0] <= highFreq and
                        join_list[ch_id][0][1] >= lowFreq and join_list[ch_id][0][1] >= highFreq):
                    matched = True
                    self.log.info('matched joined channel %s [%d - %d]' %
                                  (ch_id, join_list[ch_id][0][0], join_list[ch_id][0][1]))
                    break

        if matched is False:
            self.log.warning('no matched channel ')
            return [300, '']

        # terminate list check
        # [Lan's comments] If SAS server already decided to TEMINATE a grant and sent a HB response
        # with responseCode 500, make sure within 60 seconds, the SAS server should not accept any
        # grant request for the same freq. If any CBSD requests for the same spectrum within 60
        # seconds, the SAS server should reply with interference. After 60 seconds, if the spectrum
        # is not used by anybody, regardless which CBSD is requesting for this spectrum, it should
        # grant the request.[~Lan's comments]
        # Here we just reject the grant request if the grant is still in terminate list until
        # user free the terminated grant.
        grantID = self.get_ID(lowFreq, highFreq)
        if tlist is not None:
            for item in tlist:
                if item[0] == self.cbsdID and item[1] == grantID:
                    self.log.info('grant %s is terminated' % grantID)
                    return [400, '']
                else:
                    continue

        # handle forced case
        if (grantID not in self.config.force_sas_method_sequences) and self.config.SAS_METHOD_FORCE_GRANTIDS is None:
            self.config.force_sas_method_sequences[grantID] = 0
        if self.config.SAS_METHOD_FORCE == METHOD_GRANT:
            if self.config.SAS_METHOD_FORCE_GRANTIDS is None or \
                    self.config.SAS_METHOD_FORCE_GRANTIDS.find(grantID) != -1:
                self.config.force_sas_method_sequences[grantID] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                        ((self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                          self.config.SAS_METHOD_FORCE_GRANTIDS.find(grantID) != -1) and
                         self.config.force_sas_method_sequences[grantID] == self.config.SAS_METHOD_FORCE_SEQUENCE):
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
        # handle forced group case
        grantIdForEachGroup = str(grantID) + '_' + METHOD_GRANT
        self.log.info('force the value of grantIdForEachGroup to be %s' % grantIdForEachGroup)
        if (grantIdForEachGroup not in self.config.force_sas_method_group_sequences):
            self.log.info('grantIdForEachGroup not in self.config.force_sas_method_group_sequences')
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] = 0
        else:
            self.log.info('grantIdForEachGroup in self.config.force_sas_method_group_sequences')
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] += 1
            if len(self.config.force_sas_method_group) != 0:
                self.log.info('len of force_sas_method_group is %d' % len(self.config.force_sas_method_group))
                for force_sas_method in self.config.force_sas_method_group:
                    force_sas_method_key = force_sas_method.split(',')
                    if (force_sas_method_key[0] == grantID) and force_sas_method_key[1] == METHOD_GRANT:
                        self.log.info('find the grantid')
                        self.log.info('grant id is  %s' % force_sas_method_key[0])
                        self.log.info('method is  %s' % force_sas_method_key[1])
                        sequence = int(force_sas_method_key[2])
                        response_code = force_sas_method_key[3]
                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        if (self.config.force_sas_method_group_sequences[grantIdForEachGroup] == sequence):
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            return [int(response_code), '']

        self.cbsdID = cbsdID
        self.lowFreq = lowFreq
        self.highFreq = highFreq
        self.grantID = self.get_ID(lowFreq, highFreq)
        self.MaxEIRP = maxEirp

        now = datetime.datetime.utcnow()
        dur = datetime.timedelta(seconds=self.config.GRANT_EXP_DUR)
        exp = now + dur
        self.grantExp = exp
        # grant shouldn't be performed if RESPONSE_CODE_FORCE == 0
        # however, we still need grant information to build response message
        # so we will perfrom grant and then stop grant after response is built completely
        self.set_opState(GRANT_STATE_GRANTED, self.config.GRANT_EXP_DUR)
        return [0, '']

    def heartbeat(self, opState, grantRenew=False, blist=None, tlist=None, slist=None):
        if self.opState != opState.capitalize():
            self.log.warning('invalid heartbeat request because grant %s is in %s not in %s' %
                             (self.grantID, self.opState, opState))
            return [502, '']

        if blist is not None:
            if self.cbsdID in blist:
                self.log.info('cbsd %s is blacklisted' % (self.cbsdID))
                now = datetime.datetime.utcnow()
                if (self.transmitExp is not None and now <= self.transmitExp):
                    # change transmitExpireTime to past so that CBSD can terminate the transmition
                    self.transmit_TimerStop()
                    exp = datetime.datetime(1970, 1, 1)
                    self.transmitExp = exp
                    self.log.info('grant %s change transmitExpireTime to %s' %
                                  (self.grantID, self.transmitExp.strftime("%Y-%m-%dT%H:%M:%SZ")))
                return [101, '']

        # terminate list check
        if tlist is not None:
            for item in tlist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.log.info('grant %s is terminated' % self.grantID)
                    if self.get_opState() == GRANT_STATE_AUTHORIZED:
                        self.hb_TimerStart(2*self.config.HEART_BEAT_DUR)
                    # do NOT change op state to idle
                    # just waiting transmitExpireTime expiration
                    # self.set_opState(GRANT_STATE_IDLE)
                    return [500, '']
                else:
                    continue

        # suspend list check
        if slist is not None:
            for item in slist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.log.info('grant %s is suspended' % self.grantID)
                    if self.get_opState() == GRANT_STATE_AUTHORIZED:
                        self.hb_TimerStart(2*self.config.HEART_BEAT_DUR)
                    # do NOT change op state to Granted
                    # just waiting transmitExpireTime expiration
                    # self.set_opState(GRANT_STATE_GRANTED)
                    return [501, '']
                else:
                    continue

        if self.config.GRANT_TERMINATE is True:
            self.log.info('grant is terminated')
            return [500, '']

        if self.config.GRANT_SUSPEND is True:
            self.log.info('grant is suspended')
            return [501, '']

        # handle forced case
        if self.config.SAS_METHOD_FORCE == METHOD_HEARTBEAT:
            if self.config.SAS_METHOD_FORCE_GRANTIDS is None or \
                    self.config.SAS_METHOD_FORCE_GRANTIDS.find(self.grantID) != -1:
                self.config.force_sas_method_sequences[self.grantID] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                    ((self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                      self.config.SAS_METHOD_FORCE_GRANTIDS.find(self.grantID) != -1) and
                     self.config.force_sas_method_sequences[self.grantID] == self.config.SAS_METHOD_FORCE_SEQUENCE):
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    if self.config.RESPONSE_CODE_FORCE == 500:
                        self.set_opState(GRANT_STATE_IDLE)
                    return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
        # handle forced group case
        grantIdForEachGroup = str(self.grantID) + '_' + METHOD_HEARTBEAT
        self.log.info('force the value of grantIdForEachGroup to be %s' % grantIdForEachGroup)
        if (grantIdForEachGroup not in self.config.force_sas_method_group_sequences):
            self.log.info('grantIdForEachGroup not in self.config.force_sas_method_group_sequences')
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] = 0
        else:
            self.log.info('grantIdForEachGroup in self.config.force_sas_method_group_sequences')
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] += 1
            if len(self.config.force_sas_method_group) != 0:
                self.log.info('len of force_sas_method_group is %d' % len(self.config.force_sas_method_group))
                for force_sas_method in self.config.force_sas_method_group:
                    force_sas_method_key = force_sas_method.split(',')
                    if (force_sas_method_key[0] == self.grantID) and force_sas_method_key[1] == METHOD_HEARTBEAT:
                        self.log.info('find the grantid')
                        self.log.info('grant id is  %s' % force_sas_method_key[0])
                        self.log.info('method is  %s' % force_sas_method_key[1])
                        sequence = int(force_sas_method_key[2])
                        response_code = force_sas_method_key[3]
                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        if (self.config.force_sas_method_group_sequences[grantIdForEachGroup] == sequence):
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            if int(response_code) == 500:
                                self.set_opState(GRANT_STATE_IDLE)
                            return [int(response_code), '']
        if grantRenew is True and self.config.RENEW_GRANT is True:
            now = datetime.datetime.utcnow()
            dur = datetime.timedelta(seconds=self.config.GRANT_EXP_DUR)
            exp = now + dur
            self.grantExp = exp
            self.grantRenew = True
            self.grant_TimerStart(self.config.GRANT_EXP_DUR)
            self.log.info('extend grantExpireTime to %s' % self.grantExp.strftime("%Y-%m-%dT%H:%M:%SZ"))
        else:
            self.grantRenew = False

        if self.get_opState() == GRANT_STATE_GRANTED:
            # first heartbeat will be approved even if RENEW_TRANSMIT is disabled
            if self.transmitExp is None or self.config.RENEW_TRANSMIT is True:
                now = datetime.datetime.utcnow()
                delta = datetime.timedelta(seconds=self.config.TRANSMIT_EXP_DUR)
                exp = now + delta
                dur = self.config.TRANSMIT_EXP_DUR
                # The transmitExpireTime value shall be no later than the grantExpireTime
                if exp > self.grantExp:
                    self.transmitExp = self.grantExp
                    delta = self.transmitExp - now
                    dur = delta.days * 3600 * 24 + delta.seconds
                else:
                    self.transmitExp = exp
                self.log.info('set transmitExpireTime to %s' % self.transmitExp.strftime("%Y-%m-%dT%H:%M:%SZ"))
                self.set_opState(GRANT_STATE_AUTHORIZED, dur)
            else:
                # no need to change op state to transmit
                # no need to re-start hb timer
                # a passed transmit expire time will be included in response msg
                self.log.info('keep CBSD in granted state because RENEW_TRANSMIT is disabled')
                return [0, '']
        else:
            if self.config.RENEW_TRANSMIT is True:
                now = datetime.datetime.utcnow()
                delta = datetime.timedelta(seconds=(2*self.config.HEART_BEAT_DUR))
                if ((now + delta) >= self.transmitExp):
                    delta = datetime.timedelta(seconds=self.config.TRANSMIT_EXP_DUR)
                    exp = now + delta
                    dur = self.config.TRANSMIT_EXP_DUR
                    # The transmitExpireTime value shall be no later than the grantExpireTime
                    if exp > self.grantExp:
                        self.transmitExp = self.grantExp
                        delta = self.transmitExp - now
                        dur = delta.days * 3600 * 24 + delta.seconds
                    else:
                        self.transmitExp = exp
                    self.transmit_TimerStart(dur)
                    self.log.info('renew transmitExpireTime to %s' % self.transmitExp.strftime("%Y-%m-%dT%H:%M:%SZ"))

        self.hb_TimerStart(2*self.config.HEART_BEAT_DUR)
        return [0, '']

    def relinquish(self):
        if self.opState != GRANT_STATE_GRANTED and self.opState != GRANT_STATE_AUTHORIZED:
            self.log.warning('invalid relinquishment request because grant %s is not in Granted or Authorized' %
                             self.grantID)
            return [502, '']
        # handle forced case
        if self.config.SAS_METHOD_FORCE == METHOD_RELINQUISH:
            if self.config.SAS_METHOD_FORCE_GRANTIDS is None or \
                    self.config.SAS_METHOD_FORCE_GRANTIDS.find(self.grantID) != -1:
                self.config.force_sas_method_sequences[self.grantID] += 1
            if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or \
                        ((self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                          self.config.SAS_METHOD_FORCE_GRANTIDS.find(self.grantID) != -1) and
                         self.config.force_sas_method_sequences[self.grantID] ==
                         self.config.SAS_METHOD_FORCE_SEQUENCE):
                    self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                    return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
            # do not relinquish a grant if RESPONSE_CODE_FORCE==0 & EXCLUDE_PARAM_FORCE=<a valid value>
            # 'cbsdId'/'grantId'/'response'/'responseCode' are the valid parameters in relinquish response.
            # check if EXCLUDE_PARAM_FORCE equal to these valid parameters instead of checking CBSD.__excludePar
            elif self.config.RESPONSE_CODE_FORCE == 0:
                if self.config.SAS_METHOD_FORCE_SEQUENCE is None or (
                        (self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                         self.config.SAS_METHOD_FORCE_GRANTIDS.find(self.grantID) != -1) and
                        self.config.force_sas_method_sequences[self.grantID] == self.config.SAS_METHOD_FORCE_SEQUENCE):
                    if self.config.EXCLUDE_PARAM_FORCE == PAR_CBSD_ID or \
                            self.config.EXCLUDE_PARAM_FORCE == PAR_GRANT_ID:
                        self.log.info('do not perform relinquish due to config.RESPONSE_CODE_FORCE==0 & '
                                      'config.EXCLUDE_PARAM_FORCE=True')
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
                    elif self.config.EXCLUDE_PARAM_FORCE == PAR_ERROR or \
                            self.config.EXCLUDE_PARAM_FORCE == PAR_ERR_CODE:
                        self.log.info('do not perform relinquish due to config.RESPONSE_CODE_FORCE==0 & '
                                      'config.EXCLUDE_PARAM_FORCE=True')
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]

        self.stop()
        return [0, '']

    def stop(self):
        self.set_opState(GRANT_STATE_IDLE)
        grantID = self.grantID
        self.cbsdID = ''
        self.grantID = ''
        self.MaxEIRP = 0
        self.lowFreq = 0
        self.highFreq = 0
        self.grantExp = None
        self.grantRenew = False
        self.transmitExp = None
        self.log.info('grant %s is stopped' % grantID)

    def get_opState(self):
        return self.opState

    def set_opState(self, state, duration=None):
        if self.opState == state:
            return
        old_state = self.opState
        if state == GRANT_STATE_IDLE:
            self.transmit_TimerStop()
            self.grant_TimerStop()
            self.hb_TimerStop()
            self.opState = state
            self.log.info('grant %s change op state to %s from %s' % (self.grantID, state, old_state))
        elif state == GRANT_STATE_GRANTED:
            if old_state == GRANT_STATE_AUTHORIZED:
                self.transmit_TimerStop()
                self.hb_TimerStop()
            self.opState = state
            if duration is not None:
                # start grant expire timer
                self.grant_TimerStart(duration)
            self.log.info('grant %s change op state to %s from %s' % (self.grantID, state, old_state))
        elif state == GRANT_STATE_AUTHORIZED:
            self.opState = state
            if duration is not None:
                # start transmit expire timer
                # heartbeat expire timer is initiated in heartbeat_handler()
                self.transmit_TimerStart(duration)
            self.log.info('grant %s change op state to %s from %s' % (self.grantID, state, old_state))
        else:
            self.log.warning('invalid grant op state %s' % state)

    def hb_TimerStart(self, duration):
        if self.get_opState() != GRANT_STATE_GRANTED and self.get_opState() != GRANT_STATE_AUTHORIZED:
            self.log.warning('fail to start hb timer due to incorrect op state %s' % self.opState)
            return
        if self.hbTimer is not None:
            self.hbTimer.cancel()
            self.hbTimer = None
        self.hbTimer = threading.Timer(duration, hb_timeoutAction, [self])
        self.hbTimer.start()
        self.log.debug('started a hb timer with %d seconds for grant %s' % (duration, self.grantID))

    def hb_TimerStop(self):
        if self.hbTimer is not None:
            self.hbTimer.cancel()
            self.hbTimer = None
            self.log.debug('stopped the hb timer of grant %s' % self.grantID)

    def grant_TimerStart(self, duration):
        if self.get_opState() != GRANT_STATE_GRANTED and self.get_opState() != GRANT_STATE_AUTHORIZED:
            self.log.warning('fail to start grant timer due to incorrect grant op state %s' % self.get_opState())
            return
        if self.grantTimer is not None:
            self.grantTimer.cancel()
            self.grantTimer = None
        self.grantTimer = threading.Timer(duration, grant_timeoutAction, [self])
        self.grantTimer.start()
        self.log.debug('started a grant timer with %d seconds for grant %s' % (duration, self.grantID))

    def grant_TimerStop(self):
        if self.grantTimer is not None:
            self.grantTimer.cancel()
            self.grantTimer = None
            self.log.debug('stopped the grant timer of grant %s' % self.grantID)

    def transmit_TimerStart(self, duration):
        if self.get_opState() != GRANT_STATE_GRANTED and self.get_opState() != GRANT_STATE_AUTHORIZED:
            self.log.warning('fail to start transmit timer due to incorrect grant op state %s' % self.get_opState())
            return
        if self.transmitTimer is not None:
            self.transmitTimer.cancel()
            self.transmitTimer = None
        self.transmitTimer = threading.Timer(duration, transmit_timeoutAction, [self])
        self.transmitTimer.start()
        self.log.debug('started a transmit timer with %d seconds for grant %s' % (duration, self.grantID))

    def transmit_TimerStop(self):
        if self.transmitTimer is not None:
            self.transmitTimer.cancel()
            self.transmitTimer = None
            self.log.debug('stopped the transmit timer of grant %s' % self.grantID)

    def grant_timeout_handler(self):
        self.log.info('grant %s received grant expire event' % self.grantID)
        if self.get_opState() == GRANT_STATE_GRANTED or self.get_opState() == GRANT_STATE_AUTHORIZED:
            # change op state to idle
            self.set_opState(GRANT_STATE_IDLE)
            self.log.info('grant %s change op state to %s due to grant expire' % (self.grantID, GRANT_STATE_IDLE))
            return 0
        else:
            self.log.warning('invalid grant expire event because grant is not in Granted or Authorized state')
            return -1

    def transmit_timeout_handler(self, tlist=None, slist=None):
        self.log.info('grant %s received transmit expire event' % self.grantID)
        # check if grant is terminated
        if tlist is not None:
            for item in tlist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.set_opState(GRANT_STATE_IDLE)
                    self.log.info('grant %s change op state to %s due to grant termination' %
                                  (self.grantID, GRANT_STATE_IDLE))
                    return 0

        # check if grant is suspended
        if slist is not None:
            for item in slist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.set_opState(GRANT_STATE_GRANTED)
                    self.log.info('grant %s change op state to %s due to grant suspension' %
                                  (self.grantID, GRANT_STATE_GRANTED))
                    return 0

        if self.get_opState() == GRANT_STATE_AUTHORIZED:
            # change op state to granted
            self.set_opState(GRANT_STATE_GRANTED)
            self.log.info('grant %s change op state to %s due to transmit expiration' %
                          (self.grantID, GRANT_STATE_GRANTED))
            return 0
        else:
            self.log.warning('invalid transmit expire event because grant is not in Authorized state')
            return -1

    def heartbeat_timeout_handler(self):
        self.log.info('grant %s received hearbeat expire event' % self.grantID)
        if self.get_opState() == GRANT_STATE_GRANTED or self.get_opState() == GRANT_STATE_AUTHORIZED:
            # change op state to idle
            self.set_opState(GRANT_STATE_IDLE)
            self.log.info('grant %s change op state to %s due to heartbeat expiration' %
                          (self.grantID, GRANT_STATE_IDLE))
            return 0
        else:
            self.log.warning('invalid heartbeat expire event because grant is not in Granted or Authorized state')
            return -1
