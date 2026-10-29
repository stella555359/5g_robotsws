#!/usr/bin/env python
# -*- coding: utf-8 -*-


import datetime
import json
import socket
import threading

import OpenSSL.SSL as ssl
from httpBase.HttpRequestParser import HttpRequestParser
from sas.Consts import *
from utils.LoggerHandler import LoggerHandler

INT_EVENT_HEADER = 'POST /uri/v1.0/intEvent HTTP/1.1\r\nHost:www.Nokia.com\r\nContent-type: application/json\r\n\r\n'


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
        req_data = {PAR_EVENT_TYPE: eventType, PAR_CBSD_ID: grant.get_cbsdID(), PAR_GRANT_ID: grant.get_ID()}
        req_data_json = json.dumps(req_data)
        req = http_header.encode('utf-8') + req_data_json.encode('utf-8') + b'\r\n'
        sock = socket.socket(socket.AF_INET)

        def verify_cb(conn, cert, errnum, depth, ok):
            return 1

        context = ssl.Context(ssl.TLS_CLIENT_METHOD)
        context.load_verify_locations(grant.config.CA_FILE)
        context.set_verify(ssl.VERIFY_NONE, verify_cb)
        context.check_hostname = False
        context.use_certificate_chain_file(grant.config.CERT_FILE)
        context.use_privatekey_file(grant.config.KEY_FILE)

        conn = ssl.Connection(context, sock)
        conn.connect(("localhost", grant.config.PORT_NUM))
        conn.settimeout(3)
        conn.set_tlsext_host_name("localhost".encode("utf-8"))
        conn.setblocking(1)
        conn.set_connect_state()
        conn.do_handshake()
        conn.sendall(req)
        conn.shutdown()

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
        self.channelType = ChannelType.GAA
        self.grantExp = None
        self.grantRenew = False
        self.transmitExp = None
        self.hbTimer = None
        self.grantTimer = None
        self.transmitTimer = None

    def get_grantExp(self):
        if self.opState != GRANT_STATE_IDLE:
            self.log.info("grantExp: {}".format(self.grantExp))
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
        if lowFreq is not None and highFreq is not None:
            return str(lowFreq) + '_' + str(highFreq)
        else:
            if self.opState != GRANT_STATE_IDLE:
                return self.grantID
            else:
                return None

    def get_cbsdID(self):
        return self.cbsdID

    def get_channelType(self):
        return self.channelType

    def should_proceed_with_force_response_per_cbsd(self, cbsdId):
        return cbsdId in self.config.cbsd_force_sas_method_set

    def handle_forced_case_for_cbsd(self, method, cbsdId, grantId):
        if cbsdId in self.config.cbsd_force_sas_method_set:
            if cbsdId not in self.config.cbsd_force_sas_method_sequences:
                self.config.cbsd_force_sas_method_sequences[cbsdId] = {}
            if cbsdId not in self.config.CBSD_RESPONSE_DATA_FORCE:
                self.config.CBSD_RESPONSE_DATA_FORCE[cbsdId] = {}
            if grantId not in self.config.cbsd_force_sas_method_sequences[cbsdId]:
                self.config.cbsd_force_sas_method_sequences[cbsdId][grantId] = 0
            if self.config.SAS_METHOD_FORCE == method:
                if cbsdId not in self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS or \
                        self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS[cbsdId].find(grantId) != -1:
                    self.config.cbsd_force_sas_method_sequences[cbsdId][grantId] += 1
                if (cbsdId in self.config.CBSD_RESPONSE_CODE_FORCE and self.config.CBSD_RESPONSE_CODE_FORCE[cbsdId] !=
                        0):
                    if cbsdId not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or (
                            (cbsdId not in self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS
                             or self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS[cbsdId].find(
                                        grantId) != -1)
                            and self.config.cbsd_force_sas_method_sequences[cbsdId][
                                grantId] in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[
                                cbsdId]):
                        self.log.info(
                            'force the value of resonseCode to be %d' % self.config.CBSD_RESPONSE_CODE_FORCE[cbsdId])
                        if method == METHOD_HEARTBEAT and self.config.CBSD_RESPONSE_CODE_FORCE[cbsdId] == 500:
                            self.set_opState(GRANT_STATE_IDLE)
                        return [self.config.CBSD_RESPONSE_CODE_FORCE[cbsdId],
                                self.config.CBSD_RESPONSE_DATA_FORCE[cbsdId]]

    def handle_forced_group_case_for_cbsd(self, method, cbsdID, grantID, lowFreq=None, highFreq=None, maxEirp=None,
                                          grantRenew=None):
        grantIdForEachGroup = str(grantID) + '_' + method
        self.log.info('force the value of grantId to be %s' % grantIdForEachGroup)
        if (cbsdID not in self.config.cbsd_force_sas_method_group or
                cbsdID not in self.config.cbsd_force_sas_method_group_sequences or
                grantIdForEachGroup not in self.config.cbsd_force_sas_method_group_sequences[cbsdID]):
            self.log.info(f'{grantIdForEachGroup} is not configured by cbsd_force_sas_method_group')
            return None
        else:
            self.config.cbsd_force_sas_method_group_sequences[cbsdID][grantIdForEachGroup] += 1
            self.log.info('grantId in self.config.cbsd_force_sas_method_group_sequences[' + cbsdID + ']: %d' % (
                self.config.cbsd_force_sas_method_group_sequences[cbsdID][grantIdForEachGroup]))
            if len(self.config.cbsd_force_sas_method_group[cbsdID]) != 0:
                for force_sas_method in self.config.cbsd_force_sas_method_group[cbsdID]:
                    cbsd_force_sas_method_key = force_sas_method.split(',')
                    if (cbsd_force_sas_method_key[0] == grantID) and cbsd_force_sas_method_key[1] == method:
                        self.log.info('find the grantid')
                        sequence = int(cbsd_force_sas_method_key[2])
                        response_code = cbsd_force_sas_method_key[3]
                        featureDataExchangeConfigFlg = -1
                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        if self.config.cbsd_force_sas_method_group_sequences[cbsdID][grantIdForEachGroup] == sequence:
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            if method == METHOD_GRANT:
                                if int(response_code) == 0:
                                    self.cbsdID = cbsdID
                                    self.lowFreq = lowFreq
                                    self.highFreq = highFreq
                                    self.grantID = grantID
                                    self.MaxEIRP = maxEirp

                                    now = datetime.datetime.utcnow()
                                    dur = datetime.timedelta(
                                        seconds=self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                        self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                        self.config.GRANT_EXP_DUR)
                                    exp = now + dur
                                    self.grantExp = exp
                                    self.set_opState(GRANT_STATE_GRANTED,
                                                     self.config.CBSD_GRANT_EXP_DUR[self.cbsdID]
                                                     if self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                                     self.config.GRANT_EXP_DUR)
                            if method == METHOD_HEARTBEAT:
                                if int(response_code) == 500:
                                    self.set_opState(GRANT_STATE_IDLE)
                                if int(response_code) == 501:
                                    if grantRenew is True and self.config.RENEW_GRANT is True:
                                        now = datetime.datetime.utcnow()
                                        dur = datetime.timedelta(
                                            seconds=self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                            self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                            self.config.GRANT_EXP_DUR)
                                        exp = now + dur
                                        self.grantExp = exp
                                        self.grantRenew = True
                                        self.grant_TimerStart(self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                                              self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                                              self.config.GRANT_EXP_DUR)
                                        self.log.info('extend grantExpireTime to %s' % self.grantExp.strftime(
                                            "%Y-%m-%dT%H:%M:%SZ"))
                                    else:
                                        self.grantRenew = False
                            return [int(response_code), '', featureDataExchangeConfigFlg]

    def grant(self, cbsdID, maxEirp, lowFreq, highFreq, channel_list, tlist, cbsdIsPPA=False,
              channelType=ChannelType.GAA, *args):
        matched = False
        for ch_id in channel_list.keys():
            if (channel_list[ch_id][0][0] <= lowFreq <= channel_list[ch_id][0][1]
                    and channel_list[ch_id][0][0] <= highFreq <= channel_list[ch_id][0][1]):
                matched = True
                # If the CBSD is a member of the list of CBSDs associated with a PPA, and if the requested
                # frequency range is within that PPA's PAL reserved portion of the band, the Grant request
                # is considered to be a PAL Grant request.
                if cbsdIsPPA is True and channel_list[ch_id][1] is True:
                    self.channelType = ChannelType.PAL
                    self.log.info('matched PAL channel %s [%d - %d]'
                                  % (ch_id, channel_list[ch_id][0][0], channel_list[ch_id][0][1]))
                else:
                    self.log.info('matched GAA channel %s [%d - %d]'
                                  % (ch_id, channel_list[ch_id][0][0], channel_list[ch_id][0][1]))
                break
        if not matched:
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
                if not joined:
                    join_list.setdefault(ch_id, [[channel_list[ch_id][0][0], channel_list[ch_id][0][1]],
                                                 channel_list[ch_id][1]])
            for ch_id in join_list.keys():
                if (join_list[ch_id][0][0] <= lowFreq <= join_list[ch_id][0][1]
                        and join_list[ch_id][0][0] <= highFreq <= join_list[ch_id][0][1]):
                    matched = True
                    self.log.info('matched joined channel %s [%d - %d]'
                                  % (ch_id, join_list[ch_id][0][0], join_list[ch_id][0][1]))
                    break
        if not matched:
            self.log.warning('no matched channel ')
            return [300, '']
        if channelType is not None:
            self.channelType = channelType

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
        if self.should_proceed_with_force_response_per_cbsd(cbsdID):
            response = self.handle_forced_case_for_cbsd(METHOD_GRANT, cbsdID, grantID)
            if response:
                return response
        else:
            if ((
                    grantID not in self.config.force_sas_method_sequences) and self.config.SAS_METHOD_FORCE_GRANTIDS
                    is None):
                self.config.force_sas_method_sequences[grantID] = 0
            if self.config.SAS_METHOD_FORCE == METHOD_GRANT:
                if self.config.SAS_METHOD_FORCE_GRANTIDS is None or self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                        grantID) != -1:
                    self.config.force_sas_method_sequences[grantID] += 1
                if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or (
                            (
                                    self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                                    self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                                        grantID) != -1) and
                            self.config.force_sas_method_sequences[grantID] in self.config.SAS_METHOD_FORCE_SEQUENCE):
                        self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                        return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]

        # handle forced group case
        grantIdForEachGroup = str(grantID) + '_' + METHOD_GRANT
        self.log.info('force the value of grantIdForEachGroup to be %s' % grantIdForEachGroup)
        if grantIdForEachGroup not in self.config.force_sas_method_group_sequences:
            self.log.info(f'{grantIdForEachGroup} is not configured by force_sas_method_group')
        else:
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] += 1
            self.log.info('grantIdForEachGroup in self.config.force_sas_method_group_sequences: %d' % (
                self.config.force_sas_method_group_sequences[grantIdForEachGroup]))
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

                        featureDataExchangeConfigFlg = -1
                        if len(force_sas_method_key) >= 5:
                            self.log.info("featureDataExchangeConfigFlg: %s" % featureDataExchangeConfigFlg)
                            featureDataExchangeConfigFlg = int(force_sas_method_key[4])

                        reponse_force_data = 0
                        if len(force_sas_method_key) >= 6:
                            reponse_force_data = force_sas_method_key[5]
                            self.log.info('reponse_force_data is  %s' % reponse_force_data)

                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        if self.config.force_sas_method_group_sequences[grantIdForEachGroup] == sequence:
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            if int(response_code) == 0:
                                self.cbsdID = cbsdID
                                self.lowFreq = lowFreq
                                self.highFreq = highFreq
                                self.grantID = grantID
                                self.MaxEIRP = maxEirp

                                now = datetime.datetime.utcnow()
                                dur = datetime.timedelta(
                                    seconds=self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                    self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                    self.config.GRANT_EXP_DUR)
                                exp = now + dur
                                self.grantExp = exp
                                # grant shouldn't be performed if RESPONSE_CODE_FORCE == 0
                                # however, we still need grant information to build response message
                                # so we will perfrom grant and then stop grant after response is built completely
                                self.set_opState(GRANT_STATE_GRANTED,
                                                 self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                                 self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                                 self.config.GRANT_EXP_DUR)
                                return [int(response_code), '', featureDataExchangeConfigFlg]
                            if reponse_force_data:
                                self.log.info(
                                    "if reponse_force_data is empty, reponse_force_data %s" % reponse_force_data)
                                return [int(response_code), reponse_force_data, featureDataExchangeConfigFlg]
                            return [int(response_code), '', featureDataExchangeConfigFlg]
        # handle forced group case for cbsd
        result = self.handle_forced_group_case_for_cbsd(METHOD_GRANT, cbsdID, grantID, lowFreq, highFreq, maxEirp)
        if result is not None:
            return result

        self.cbsdID = cbsdID
        self.lowFreq = lowFreq
        self.highFreq = highFreq
        self.grantID = grantID
        self.MaxEIRP = maxEirp

        now = datetime.datetime.utcnow()
        dur = datetime.timedelta(
            seconds=self.config.CBSD_GRANT_EXP_DUR[
                self.cbsdID] if self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else self.config.GRANT_EXP_DUR)
        exp = now + dur
        self.grantExp = exp
        # grant shouldn't be performed if RESPONSE_CODE_FORCE == 0
        # however, we still need grant information to build response message
        # so we will perfrom grant and then stop grant after response is built completely
        self.set_opState(GRANT_STATE_GRANTED,
                         self.config.CBSD_GRANT_EXP_DUR[
                             self.cbsdID] if self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                         self.config.GRANT_EXP_DUR)
        return [0, '']

    def heartbeat(self, opState, grantRenew=False, blist=None, tlist=None, slist=None):
        if self.opState != opState.capitalize() and not (
                self.opState == GRANT_STATE_AUTHORIZED and opState.capitalize() == GRANT_STATE_GRANTED and
                not grantRenew):
            self.log.warning(
                'invalid heartbeat request because grant %s is in %s not in %s' % (self.grantID, self.opState,
                                                                                   opState))
            return [502, '']

        featureDataExchangeConfigFlg = -1

        if blist is not None:
            if self.cbsdID in blist:
                self.log.info('cbsd %s is blacklisted' % self.cbsdID)
                now = datetime.datetime.utcnow()
                if self.transmitExp is not None and now <= self.transmitExp:
                    # change transmitExpireTime to past so that CBSD can terminate the transmition
                    self.transmit_TimerStop()
                    exp = datetime.datetime.utcnow()
                    self.transmitExp = exp
                    self.log.info('grant %s change transmitExpireTime to %s' % (self.grantID,
                                                                                self.transmitExp.strftime(
                                                                                    "%Y-%m-%dT%H:%M:%SZ")))
                return [101, '']

        # terminate list check
        if tlist is not None:
            for item in tlist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.log.info('grant %s is terminated' % self.grantID)
                    if self.get_opState() == GRANT_STATE_AUTHORIZED:
                        self.hb_TimerStart(2 * self.config.CBSD_HEART_BEAT_DUR[
                            self.cbsdID] if self.cbsdID in self.config.CBSD_HEART_BEAT_DUR else
                                           2 * self.config.HEART_BEAT_DUR)
                    self.set_opState(GRANT_STATE_IDLE)
                    return [500, '']
                else:
                    continue

        # suspend list check
        if slist is not None:
            for item in slist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.log.info('grant %s is suspended' % self.grantID)
                    if self.get_opState() == GRANT_STATE_AUTHORIZED:
                        self.hb_TimerStart(2 * self.config.CBSD_HEART_BEAT_DUR[
                            self.cbsdID] if self.cbsdID in self.config.CBSD_HEART_BEAT_DUR else
                                           2 * self.config.HEART_BEAT_DUR)
                    # do NOT change op state to Granted
                    # just waiting transmitExpireTime expiration
                    # self.set_opState(GRANT_STATE_GRANTED)
                    return [501, '']
                else:
                    continue

        if self.config.GRANT_TERMINATE:
            self.log.info('grant is terminated')
            self.set_opState(GRANT_STATE_IDLE)
            return [500, '']

        if self.config.GRANT_SUSPEND:
            self.log.info('grant is suspended')
            return [501, '']

        # handle forced case
        if self.should_proceed_with_force_response_per_cbsd(self.cbsdID):
            response = self.handle_forced_case_for_cbsd(METHOD_HEARTBEAT, self.cbsdID, self.grantID)
            if response:
                return response
        else:
            if self.config.SAS_METHOD_FORCE == METHOD_HEARTBEAT:
                if self.config.SAS_METHOD_FORCE_GRANTIDS is None or self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                        self.grantID) != -1:
                    self.config.force_sas_method_sequences[self.grantID] += 1
                if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or ((self.config.SAS_METHOD_FORCE_GRANTIDS is None
                                                                          or
                                                                          self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                                                                              self.grantID) != -1)
                                                                         and self.config.force_sas_method_sequences[
                                                                             self.grantID] in
                                                                         self.config.SAS_METHOD_FORCE_SEQUENCE):
                        if (len(self.config.cbsd_force_sas_method_set) == 0 or (
                                len(self.config.cbsd_force_sas_method_set) != 0 and self.cbsdID in
                                self.config.cbsd_force_sas_method_set)):
                            self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                            if self.config.RESPONSE_CODE_FORCE == 500:
                                self.set_opState(GRANT_STATE_IDLE)
                            return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]

        # handle force_heartbeat_transmit_expire_duration_group
        heartbeat_transmit_expire_duration = self.config.CBSD_TRANSMIT_EXP_DUR[
            self.cbsdID] if self.cbsdID in self.config.CBSD_TRANSMIT_EXP_DUR else self.config.TRANSMIT_EXP_DUR
        heartbeat_grantId = str(self.grantID)
        self.log.info('force the value of heartbeat_grantId to be %s' % heartbeat_grantId)
        if heartbeat_grantId not in self.config.force_heartbeat_transmit_expire_duration_group_sequences:
            self.log.info(
                f'{heartbeat_grantId} is not configured by force_heartbeat_transmit_expire_duration_group_sequences')
        else:
            self.config.force_heartbeat_transmit_expire_duration_group_sequences[heartbeat_grantId] += 1
            self.log.info(
                'heartbeat_grantId in self.config.force_heartbeat_transmit_expire_duration_group_sequences: %d' % (
                    self.config.force_heartbeat_transmit_expire_duration_group_sequences[heartbeat_grantId]))
            if len(self.config.force_heartbeat_transmit_expire_duration_group) != 0:
                self.log.info('len of force_heartbeat_transmit_expire_duration_group is %d' % len(
                    self.config.force_heartbeat_transmit_expire_duration_group))
                for force_heartbeat_transmit_expire_duration_content in (
                        self.config.force_heartbeat_transmit_expire_duration_group):
                    force_heartbeat_transmit_expire_duration_values = (
                        force_heartbeat_transmit_expire_duration_content.split(
                            ','))
                    if force_heartbeat_transmit_expire_duration_values[0] == heartbeat_grantId:
                        self.log.info('find the grantid')
                        self.log.info('grant id is  %s' % force_heartbeat_transmit_expire_duration_values[0])
                        sequence = int(force_heartbeat_transmit_expire_duration_values[1])
                        self.log.info('sequence is  %d' % sequence)
                        if (self.config.force_heartbeat_transmit_expire_duration_group_sequences[heartbeat_grantId] ==
                                sequence):
                            self.log.info('find the sequence')
                            transmite_expire_duration = int(force_heartbeat_transmit_expire_duration_values[2])
                            self.log.info(
                                'force the value of transmite expire duration to be %s' % transmite_expire_duration)
                            heartbeat_transmit_expire_duration = transmite_expire_duration

        # handle forced group case
        grantIdForEachGroup = str(self.grantID) + '_' + METHOD_HEARTBEAT
        self.log.info('force the value of grantIdForEachGroup to be %s' % grantIdForEachGroup)
        if grantIdForEachGroup not in self.config.force_sas_method_group_sequences:
            self.log.info(f'{grantIdForEachGroup} is not configured by force_sas_method_group')
        else:
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] += 1
            self.log.info('grantIdForEachGroup in self.config.force_sas_method_group_sequences: %d' % (
                self.config.force_sas_method_group_sequences[grantIdForEachGroup]))
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

                        featureDataExchangeConfigFlg = -1
                        reponse_force_data = 0

                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        if self.config.force_sas_method_group_sequences[grantIdForEachGroup] == sequence:
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            if len(force_sas_method_key) >= 5:
                                featureDataExchangeConfigFlg = int(force_sas_method_key[4])
                            if len(force_sas_method_key) >= 6:
                                reponse_force_data = force_sas_method_key[5]
                                self.log.info('reponse_force_data is  %s' % reponse_force_data)

                            if int(response_code) == 500:
                                self.set_opState(GRANT_STATE_IDLE)
                            if int(response_code) == 501:
                                if self.config.enable_force_heartbeat_transmit_expire_duration_group_for_exception:
                                    now = datetime.datetime.utcnow()
                                    delta = datetime.timedelta(seconds=heartbeat_transmit_expire_duration)
                                    exp = now + delta
                                    self.transmitExp = exp
                                if grantRenew is True and self.config.RENEW_GRANT is True:
                                    now = datetime.datetime.utcnow()
                                    dur = datetime.timedelta(
                                        seconds=self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                        self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                        self.config.GRANT_EXP_DUR)
                                    exp = now + dur
                                    self.grantExp = exp
                                    self.grantRenew = True
                                    self.grant_TimerStart(self.config.CBSD_GRANT_EXP_DUR[self.cbsdID] if
                                                          self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else
                                                          self.config.GRANT_EXP_DUR)
                                    self.log.info(
                                        'extend grantExpireTime to %s' % self.grantExp.strftime("%Y-%m-%dT%H:%M:%SZ"))
                                else:
                                    self.grantRenew = False

                            if int(response_code) == 0:
                                break
                            if reponse_force_data:
                                return [int(response_code), reponse_force_data, featureDataExchangeConfigFlg]
                            return [int(response_code), '', featureDataExchangeConfigFlg]

        # handle forced group case for cbsd
        result = self.handle_forced_group_case_for_cbsd(METHOD_HEARTBEAT, self.cbsdID, self.grantID,
                                                        grantRenew=grantRenew)
        if result is not None:
            return result

        if grantRenew is True and self.config.RENEW_GRANT is True:
            now = datetime.datetime.utcnow()
            dur = datetime.timedelta(
                seconds=self.config.CBSD_GRANT_EXP_DUR[
                    self.cbsdID] if self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else self.config.GRANT_EXP_DUR)
            exp = now + dur
            self.grantExp = exp
            self.grantRenew = True
            self.grant_TimerStart(
                self.config.CBSD_GRANT_EXP_DUR[
                    self.cbsdID] if self.cbsdID in self.config.CBSD_GRANT_EXP_DUR else self.config.GRANT_EXP_DUR)
            self.log.info('extend grantExpireTime to %s' % self.grantExp.strftime("%Y-%m-%dT%H:%M:%SZ"))
        else:
            self.grantRenew = False

        if self.get_opState() == GRANT_STATE_GRANTED:
            # first heartbeat will be approved even if RENEW_TRANSMIT is disabled
            if self.transmitExp is None or self.config.RENEW_TRANSMIT is True:
                now = datetime.datetime.utcnow()
                delta = datetime.timedelta(seconds=heartbeat_transmit_expire_duration)
                exp = now + delta
                dur = heartbeat_transmit_expire_duration
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
                return [0, '', featureDataExchangeConfigFlg]
        else:
            if self.config.RENEW_TRANSMIT:
                now = datetime.datetime.utcnow()
                delta = datetime.timedelta(seconds=(2 * self.config.CBSD_HEART_BEAT_DUR[
                    self.cbsdID] if self.cbsdID in self.config.CBSD_HEART_BEAT_DUR else
                                                    2 * self.config.HEART_BEAT_DUR))
                if (now + delta) >= self.transmitExp:
                    delta = datetime.timedelta(seconds=heartbeat_transmit_expire_duration)
                    exp = now + delta
                    dur = heartbeat_transmit_expire_duration
                    # The transmitExpireTime value shall be no later than the grantExpireTime
                    if exp > self.grantExp:
                        self.transmitExp = self.grantExp
                        delta = self.transmitExp - now
                        dur = delta.days * 3600 * 24 + delta.seconds
                    else:
                        self.transmitExp = exp
                    self.transmit_TimerStart(dur)
                    self.log.info('renew transmitExpireTime to %s' % self.transmitExp.strftime("%Y-%m-%dT%H:%M:%SZ"))

        self.hb_TimerStart(
            2 * self.config.CBSD_HEART_BEAT_DUR[
                self.cbsdID] if self.cbsdID in self.config.CBSD_HEART_BEAT_DUR else 2 * self.config.HEART_BEAT_DUR)
        return [0, '', featureDataExchangeConfigFlg]

    def relinquish(self):
        if self.opState != GRANT_STATE_GRANTED and self.opState != GRANT_STATE_AUTHORIZED:
            self.log.warning(
                'invalid relinquishment request because grant %s is not in Granted or Authorized' % self.grantID)
            return [502, '']

        # handle forced case
        if self.should_proceed_with_force_response_per_cbsd(self.cbsdID):
            if self.cbsdID not in self.config.cbsd_force_sas_method_sequences:
                self.config.cbsd_force_sas_method_sequences[self.cbsdID] = {}
            if self.cbsdID not in self.config.CBSD_RESPONSE_DATA_FORCE:
                self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID] = {}
            if self.config.SAS_METHOD_FORCE == METHOD_RELINQUISH:
                if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS or \
                        self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS[self.cbsdID].find(
                            self.grantID) != -1:
                    self.config.cbsd_force_sas_method_sequences[self.cbsdID][self.grantID] += 1
                if (self.cbsdID in self.config.CBSD_RESPONSE_CODE_FORCE and
                        self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID] != 0):
                    if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or (
                            (self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS
                             or self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS[self.cbsdID].find(self.grantID) != -1)
                            and self.config.cbsd_force_sas_method_sequences[self.cbsdID][self.grantID] in
                            self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[
                                self.cbsdID]):
                        self.log.info('force the value of resonseCode to be %d' % self.config.CBSD_RESPONSE_CODE_FORCE[
                            self.cbsdID])
                        return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]]
                # For test purpose, do not relinquish a grant if CBSD_RESPONSE_CODE_FORCE[self.cbsdID]==0 &
                # CBSD_EXCLUDE_PARAM_FORCE[
                # self.cbsdID]=<a valid value>
                # 'cbsdId'/'grantId'/'response'/'responseCode' are the valid parameters in relinquish response.
                # so here check if CBSD_EXCLUDE_PARAM_FORCE equal to these valid parameters instead of checking
                # CBSD.__excludePar
                elif self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID] == 0:
                    if self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE or (
                            (self.cbsdID not in self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS
                             or self.config.CBSD_SAS_METHOD_FORCE_GRANTIDS[self.cbsdID].find(self.grantID) != -1)
                            and self.config.cbsd_force_sas_method_sequences[self.cbsdID][self.grantID] in
                            self.config.CBSD_SAS_METHOD_FORCE_SEQUENCE[
                                self.cbsdID]):
                        if self.config.CBSD_EXCLUDE_PARAM_FORCE[self.cbsdID] == PAR_CBSD_ID or \
                                self.config.CBSD_EXCLUDE_PARAM_FORCE[
                                    self.cbsdID] == PAR_GRANT_ID:
                            self.log.info(
                                'do not perform relinquish due to config.CBSD_RESPONSE_CODE_FORCE==0 & '
                                'config.CBSD_EXCLUDE_PARAM_FORCE=True')
                            return [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                    self.config.CBSD_RESPONSE_DATA_FORCE[self.cbsdID]]
                        elif self.config.CBSD_EXCLUDE_PARAM_FORCE[self.cbsdID] == PAR_ERROR or \
                                self.config.CBSD_EXCLUDE_PARAM_FORCE[
                                    self.cbsdID] == PAR_ERR_CODE:
                            self.log.info(
                                'do not perform relinquish due to config.CBSD_RESPONSE_CODE_FORCE==0 & '
                                'config.CBSD_EXCLUDE_PARAM_FORCE=True')
                            return \
                                [self.config.CBSD_RESPONSE_CODE_FORCE[self.cbsdID],
                                 self.config.CBSD_RESPONSE_DATA_FORCE][
                                    self.cbsdID]
        else:
            if self.config.SAS_METHOD_FORCE == METHOD_RELINQUISH:
                if self.config.SAS_METHOD_FORCE_GRANTIDS is None or self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                        self.grantID) != -1:
                    self.config.force_sas_method_sequences[self.grantID] += 1
                if self.config.RESPONSE_CODE_FORCE is not None and self.config.RESPONSE_CODE_FORCE != 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or (
                            (
                                    self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                                    self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                                        self.grantID) != -1) and
                            self.config.force_sas_method_sequences[
                                self.grantID] in self.config.SAS_METHOD_FORCE_SEQUENCE):
                        if (len(self.config.cbsd_force_sas_method_set) == 0 or (
                                len(self.config.cbsd_force_sas_method_set) != 0 and self.cbsdID in
                                self.config.cbsd_force_sas_method_set)):
                            self.log.info('force the value of resonseCode to be %d' % self.config.RESPONSE_CODE_FORCE)
                            return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
                # For test purpose, do not relinquish a grant if RESPONSE_CODE_FORCE==0 & EXCLUDE_PARAM_FORCE=<a
                # valid value>
                # 'cbsdId'/'grantId'/'response'/'responseCode' are the valid parameters in relinquish response.
                # so here check if EXCLUDE_PARAM_FORCE equal to these valid parameters instead of checking
                # CBSD.__excludePar
                elif self.config.RESPONSE_CODE_FORCE == 0:
                    if self.config.SAS_METHOD_FORCE_SEQUENCE is None or (
                            (
                                    self.config.SAS_METHOD_FORCE_GRANTIDS is None or
                                    self.config.SAS_METHOD_FORCE_GRANTIDS.find(
                                        self.grantID) != -1) and
                            self.config.force_sas_method_sequences[
                                self.grantID] in self.config.SAS_METHOD_FORCE_SEQUENCE):
                        if (self.config.EXCLUDE_PARAM_FORCE == PAR_CBSD_ID or self.config.EXCLUDE_PARAM_FORCE ==
                                PAR_GRANT_ID):
                            self.log.info(
                                'do not perform relinquish due to config.RESPONSE_CODE_FORCE==0 & '
                                'config.EXCLUDE_PARAM_FORCE=True')
                            return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]
                        elif (self.config.EXCLUDE_PARAM_FORCE == PAR_ERROR or self.config.EXCLUDE_PARAM_FORCE ==
                              PAR_ERR_CODE):
                            self.log.info(
                                'do not perform relinquish due to config.RESPONSE_CODE_FORCE==0 & '
                                'config.EXCLUDE_PARAM_FORCE=True')
                            return [self.config.RESPONSE_CODE_FORCE, self.config.RESPONSE_DATA_FORCE]

        # handle forced group case
        grantIdForEachGroup = str(self.grantID) + '_' + METHOD_RELINQUISH
        self.log.info('force the value of grantIdForEachGroup to be %s' % grantIdForEachGroup)
        if grantIdForEachGroup not in self.config.force_sas_method_group_sequences:
            self.log.info(f'{grantIdForEachGroup} is not configured by force_sas_method_group')
        else:
            self.config.force_sas_method_group_sequences[grantIdForEachGroup] += 1
            self.log.info('grantIdForEachGroup in self.config.force_sas_method_group_sequences: %d' % (
                self.config.force_sas_method_group_sequences[grantIdForEachGroup]))
            if len(self.config.force_sas_method_group) != 0:
                self.log.info('len of force_sas_method_group is %d' % len(self.config.force_sas_method_group))
                for force_sas_method in self.config.force_sas_method_group:
                    force_sas_method_key = force_sas_method.split(',')
                    if (force_sas_method_key[0] == self.grantID) and force_sas_method_key[1] == METHOD_RELINQUISH:
                        self.log.info('find the grantid')
                        self.log.info('grant id is %s' % force_sas_method_key[0])
                        self.log.info('method is %s' % force_sas_method_key[1])
                        sequence = int(force_sas_method_key[2])
                        response_code = force_sas_method_key[3]
                        self.log.info('sequence is  %d' % sequence)
                        self.log.info('response_code is  %s' % response_code)
                        featureDataExchangeConfigFlg = -1
                        if len(force_sas_method_key) >= 5:
                            featureDataExchangeConfigFlg = int(force_sas_method_key[4])
                        reponse_force_data = 0
                        if len(force_sas_method_key) >= 6:
                            reponse_force_data = force_sas_method_key[5]
                            self.log.info('reponse_force_data is  %s' % reponse_force_data)
                        if self.config.force_sas_method_group_sequences[grantIdForEachGroup] == sequence:
                            self.log.info('find the sequence')
                            self.log.info('force the value of resonseCode to be %s' % response_code)
                            if int(response_code) == 0:
                                self.stop()
                                return [int(response_code), '', featureDataExchangeConfigFlg]
                            if reponse_force_data:
                                return [int(response_code), reponse_force_data, featureDataExchangeConfigFlg]
                            return [int(response_code), '', featureDataExchangeConfigFlg]
        # handle forced group case for cbsd
        result = self.handle_forced_group_case_for_cbsd(METHOD_RELINQUISH, self.cbsdID, self.grantID)
        if result is not None:
            return result

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
                    self.log.info(
                        'grant %s change op state to %s due to grant termination' % (self.grantID, GRANT_STATE_IDLE))
                    return 0

        # check if grant is suspended
        if slist is not None:
            for item in slist:
                if item[0] == self.cbsdID and item[1] == self.grantID:
                    self.set_opState(GRANT_STATE_GRANTED)
                    self.log.info(
                        'grant %s change op state to %s due to grant suspension' % (self.grantID, GRANT_STATE_GRANTED))
                    return 0

        if self.get_opState() == GRANT_STATE_AUTHORIZED:
            # change op state to granted
            self.set_opState(GRANT_STATE_GRANTED)
            self.log.info(
                'grant %s change op state to %s due to transmit expiration' % (self.grantID, GRANT_STATE_GRANTED))
            return 0
        else:
            self.log.warning('invalid transmit expire event because grant is not in Authorized state')
            return -1

    def heartbeat_timeout_handler(self):
        self.log.info('grant %s received hearbeat expire event' % self.grantID)
        if self.get_opState() == GRANT_STATE_GRANTED or self.get_opState() == GRANT_STATE_AUTHORIZED:
            # change op state to idle
            # self.set_opState(GRANT_STATE_IDLE)
            # self.log.info('grant %s change op state to %s due to heartbeat expiration' % (self.grantID,
            # GRANT_STATE_IDLE))
            self.log.info('grant %s state is %s when heartbeat expiration' % (self.grantID, self.get_opState()))
            return 0
        else:
            self.log.warning('invalid heartbeat expire event because grant is not in Granted or Authorized state')
            return -1
