#!/usr/bin/env python
# -*- coding: utf-8 -*-


import socket
import ssl
import time
import datetime
import json
import logging
import ConfigParser
import threading
import os
import sys
from utils.LoggerHandler import LoggerHandler
from sas.Consts import *
from sas.CbsdManager import CBSDManager
from httpBase.HttpRequestParser import HttpRequestParser

# DEFAULT CONFIGURATION START
# port number binded to SAS simulator service
PORT_NUM = 443

# True means support IPv6 connection
# False means support IPv4 connection only
IPV6_ENABLE = False

# True means secure connection (TLS) with CBSD
# False means insecure connection (TCP) with CBSD
CONNECT_MODE_TLS = True

# True means TLS mutual authentication
# False means server will not validate peer's certificate
MUTUAL_AUTH = False

# True means sas sim act as Domain Proxy
# False means sas sim act as sas server
DP_MODEL = False

# key file and certificate file
KEY_FILE = 'nokia04.key'
CERT_FILE = 'nokia04.cert'
CA_FILE = 'ca.cert'

# log file, should be None or str of file name. None means standard output
LOG_FILE = None

# log level, should be one of following (in increasing order of severity):
# logging.DEBUG, logging.INFO, logging.WARNING, logging.ERROR, logging.CRITICAL
LOG_LEVEL = logging.DEBUG

# heartbeat duration in second
HEART_BEAT_DUR = 600

# grant duration until expiry in second
GRANT_EXP_DUR = 360000

# transmit duration until expiry in second
TRANSMIT_EXP_DUR = 36000

# time in second before transmit expiry to renew grantExpireTime in heartbeat response
# this time value should greater than HEART_BEAT_DUR and less than TRANSMIT_EXP_DUR
# precondition: RENEW_TRANSMIT equal to True
# RENEW_TRANSMIT_BEFORE_EXP_TIME = 70

# True - suspend the grant via heartbeat response with error code of SUSPENDED_GRANT
GRANT_SUSPEND = False

# True - terminate the grant via heartbeat response with error code of SUSPENDED_GRANT
GRANT_TERMINATE = False

# True - include the operational parameters in heartbeat response if a grant is suspended
# the CBSD interprets the values as a spectrum reassignment
SUSPENDED_REASSIGN = False

# True - include the operational parameters in heartbeat response if a grant is terminated
# the CBSD interprets the values as a spectrum reassignment
TERMINATED_REASSIGN = False

# True - disapprove the grant request with a frequency or
# peak power different from the values sent in the request
GRANT_DISAPPROVE_REASSIGN = False

# do NOT respond the specified request to make
# CBSD stay in a certain state
BLOCKED_REQUEST = None
BLOCKED_REQUEST_GRANTIDS = None
BLOCKED_REQUEST_SEQUENCE = None

# True - extend grantExpireTime in Heartbeat response if
# grantRenew is set to True in a heartbeatRequest
RENEW_GRANT = True

# True - extend transmitExpireTime in Heartbeat response
RENEW_TRANSMIT = True

# supported spectrum in form:
# 'ID': [(LOW_FREQUENCY, HIGH_FREQUENCY), IS_PAL_CHANNEL]
spectrum_table = {
    '3550-10': [(3550000000, 3560000000), False, ''],
    '3560-10': [(3560000000, 3570000000), False, ''],
    '3570-10': [(3570000000, 3580000000), False, ''],
    '3580-10': [(3580000000, 3590000000), False, ''],
    '3590-10': [(3590000000, 3600000000), False, ''],
    '3600-10': [(3600000000, 3610000000), False, ''],
    '3610-10': [(3610000000, 3620000000), False, ''],
    '3620-10': [(3620000000, 3630000000), False, ''],
    '3630-10': [(3630000000, 3640000000), False, ''],
    '3640-10': [(3640000000, 3650000000), False, ''],
    '3650-10': [(3650000000, 3660000000), False, ''],
    '3660-10': [(3660000000, 3670000000), False, ''],
    '3670-10': [(3670000000, 3680000000), False, ''],
    '3680-10': [(3680000000, 3690000000), False, ''],
    '3690-10': [(3690000000, 3700000000), False, ''],
}

# The low frequency value included in grant response if
# GRANT_DISAPPROVE_REASSIGN is True or in heartbeat response if
# SUSPENDED_REASSIGN/TERMINATED_REASSIGN is True
FREQ_LOW_REASSIGN = 3690000000

# The high frequency value included in grant response if
# GRANT_DISAPPROVE_REASSIGN is True or in heartbeat response if
# SUSPENDED_REASSIGN/TERMINATED_REASSIGN is True
FREQ_HIGH_REASSIGN = 3700000000

# The max EIRP value included in grant response if
# GRANT_DISAPPROVE_REASSIGN is True or in heartbeat response if
# SUSPENDED_REASSIGN/TERMINATED_REASSIGN is True
MAX_EIRP_REASSIGN = 26

# force corresponding response message to include specified
# value of responseCode and/or responseData
# following sas methods are valid:
# registration, deregistration, spectrumInquiry, grant
# heartbeat, relinquishment
SAS_METHOD_FORCE = None
SAS_METHOD_FORCE_GRANTIDS = None
SAS_METHOD_FORCE_SEQUENCE = None
RESPONSE_CODE_FORCE = None
RESPONSE_DATA_FORCE = None
EXCLUDE_PARAM_FORCE = None
UPDATE_PARAM_FORCE = None
UPDATE_PARAM_DATA_FORCE = None
HTTP_RESPONSE_CODE_FORCE = None
SUBSEQUENT_CONN_REJECT = None
MAX_EIRP_FORCE = None
FORCE_RESPONSE_DEREG_IMMEDIATELY = None

# Response encoding
CHUNKED = False
CHUNKSIZE = 40

# DEFAULT CONFIGURATION END

# simulator version
VERSION = 'V1.0.5'
VERSION_INFO = 'Compliance with TS1.2 without CPI support'

# socket conf
UN_CONN_NUM = 5
SOCK_BUF_MAX = 8192

CONNECTION_REJECT = False


def logging_init():
    log_level = logging.DEBUG
    log_file = None
    logHandler = None
    sec = 'conf'
    try:
        config = ConfigParser.ConfigParser()
        conPath = os.path.dirname(os.path.realpath(__file__)) + '/SAS_Sim.conf'
        config.read(conPath)

        items = config.items('conf')
        if config.has_option(sec, 'log_file_name'):
            log_file = config.get(sec, 'log_file_name')
        if config.has_option(sec, 'log_level'):
            level = config.get(sec, 'log_level')
            if level.upper() == 'DEBUG':
                log_level = logging.DEBUG
            elif level.upper() == 'INFO':
                log_level = logging.INFO
            elif level.upper() == 'WARNING':
                log_level = logging.WARNING
            elif level.upper() == 'ERROR':
                log_level = logging.ERROR
            elif level.upper() == 'CRITICAL':
                log_level = logging.CRITICAL
            else:
                # using default value
                pass
        logHandler = LoggerHandler('SAS_Sim', log_file, log_level)
    except ConfigParser.MissingSectionHeaderError:
        print('missing section header in config file. using default configuration.')
    except ConfigParser.Error:
        print('parsing config file failed. using default configuration.')
    except ValueError:
        print('parsing config file failed. could not convert data to a specified type.')
    except Exception:
        print('parsing config file failed. unexcept error.')
    finally:
        return logHandler


class SASConfig(object):

    def __init__(self, logHandler):
        self.log = logHandler
        self.VERSION = VERSION
        self.VERSION_INFO = VERSION_INFO
        self.PORT_NUM = PORT_NUM
        self.MUTUAL_AUTH = MUTUAL_AUTH
        self.KEY_FILE = KEY_FILE
        self.CERT_FILE = CERT_FILE
        self.CA_FILE = CA_FILE
        self.IPV6_ENABLE = IPV6_ENABLE
        self.DP_MODEL = DP_MODEL
        self.CONNECT_MODE_TLS = CONNECT_MODE_TLS
        self.HEART_BEAT_DUR = HEART_BEAT_DUR
        self.GRANT_EXP_DUR = GRANT_EXP_DUR
        self.TRANSMIT_EXP_DUR = TRANSMIT_EXP_DUR
        self.GRANT_DISAPPROVE_REASSIGN = GRANT_DISAPPROVE_REASSIGN
        self.GRANT_SUSPEND = GRANT_SUSPEND
        self.GRANT_TERMINATE = GRANT_TERMINATE
        self.SUSPENDED_REASSIGN = SUSPENDED_REASSIGN
        self.TERMINATED_REASSIGN = TERMINATED_REASSIGN
        self.BLOCKED_REQUEST = BLOCKED_REQUEST
        self.BLOCKED_REQUEST_GRANTIDS = BLOCKED_REQUEST_GRANTIDS
        self.BLOCKED_REQUEST_SEQUENCE = BLOCKED_REQUEST_SEQUENCE
        self.RENEW_GRANT = RENEW_GRANT
        self.RENEW_TRANSMIT = RENEW_TRANSMIT
        self.MAX_EIRP_REASSIGN = MAX_EIRP_REASSIGN
        self.FREQ_LOW_REASSIGN = FREQ_LOW_REASSIGN
        self.FREQ_HIGH_REASSIGN = FREQ_HIGH_REASSIGN
        self.SAS_METHOD_FORCE = SAS_METHOD_FORCE
        self.SAS_METHOD_FORCE_GRANTIDS = SAS_METHOD_FORCE_GRANTIDS
        self.SAS_METHOD_FORCE_SEQUENCE = SAS_METHOD_FORCE_SEQUENCE
        self.RESPONSE_CODE_FORCE = RESPONSE_CODE_FORCE
        self.RESPONSE_DATA_FORCE = RESPONSE_DATA_FORCE
        self.EXCLUDE_PARAM_FORCE = EXCLUDE_PARAM_FORCE
        self.UPDATE_PARAM_FORCE = UPDATE_PARAM_FORCE
        self.UPDATE_PARAM_DATA_FORCE = UPDATE_PARAM_DATA_FORCE
        self.HTTP_RESPONSE_CODE_FORCE = HTTP_RESPONSE_CODE_FORCE
        self.SUBSEQUENT_CONN_REJECT = SUBSEQUENT_CONN_REJECT
        self.FORCE_RESPONSE_DEREG_IMMEDIATELY = FORCE_RESPONSE_DEREG_IMMEDIATELY
        self.MAX_EIRP_FORCE = MAX_EIRP_FORCE
        self.spectrum_table = spectrum_table
        self.CONNECTION_REJECT = CONNECTION_REJECT
        self.CHUNKED = CHUNKED
        self.CHUNKSIZE = CHUNKSIZE
        self.force_sas_method_sequences = {}
        self.blocked_request_sequences = {}
        self.operationParamsForGrant = []
        self.operationParamsForHeartbeat = []
        self.force_sas_method_group = []
        self.force_sas_method_group_sequences = {}
        self.force_max_eirp_group = []
        self.force_max_eirp_group_sequences = {}
        self.force_response_group = []
        self.force_response_group_sequences = {}
        sec = 'conf'
        try:
            config = ConfigParser.ConfigParser()
            conPath = os.path.dirname(os.path.realpath(__file__)) + '/SAS_Sim.conf'
            config.read(conPath)

            items = config.items(sec)
            self.log.debug('reading configuration from SAS_Sim.conf ...')
            if config.has_option(sec, 'port_number'):
                self.PORT_NUM = config.getint(sec, 'port_number')
                self.log.debug('service port is configed to %d' % self.PORT_NUM)
            if config.has_option(sec, 'key_file_name'):
                self.KEY_FILE = os.path.dirname(os.path.realpath(__file__)) + '/' + config.get(sec, 'key_file_name')
                self.log.debug('key file is configed to %s' % self.KEY_FILE)
            if config.has_option(sec, 'cert_file_name'):
                self.CERT_FILE = os.path.dirname(os.path.realpath(__file__)) + '/' + config.get(sec, 'cert_file_name')
                self.log.debug('certificate file is configed to %s' % self.CERT_FILE)
            if config.has_option(sec, 'CA_file_name'):
                self.CA_FILE = os.path.dirname(os.path.realpath(__file__)) + '/' + config.get(sec, 'CA_file_name')
                self.log.debug('CA file is configed to %s' % self.CA_FILE)
            if config.has_option(sec, 'enable_ipv6'):
                self.IPV6_ENABLE = config.getboolean(sec, 'enable_ipv6')
                self.log.debug('enable_ipv6 is configed to %s' % self.IPV6_ENABLE)
            if config.has_option(sec, 'dp_model'):
                self.DP_MODEL = config.getboolean(sec, 'dp_model')
                self.log.debug('dp_model is configed to %s' % self.DP_MODEL)
            if config.has_option(sec, 'tls_connection'):
                self.CONNECT_MODE_TLS = config.getboolean(sec, 'tls_connection')
                self.log.debug('tls_connection is configed to %s' % self.CONNECT_MODE_TLS)
            if config.has_option(sec, 'tls_mutual_auth'):
                self.MUTUAL_AUTH = config.getboolean(sec, 'tls_mutual_auth')
                self.log.debug('tls_mutual_auth is configed to %s' % self.MUTUAL_AUTH)
            if config.has_option(sec, 'heart_beat'):
                self.HEART_BEAT_DUR = config.getint(sec, 'heart_beat')
                self.log.debug('heartbeat duration is configed to %d' % self.HEART_BEAT_DUR)
            if config.has_option(sec, 'grant_exp'):
                self.GRANT_EXP_DUR = config.getint(sec, 'grant_exp')
                self.log.debug('grant duration is configed to %d' % self.GRANT_EXP_DUR)
            if config.has_option(sec, 'transmit_exp'):
                self.TRANSMIT_EXP_DUR = config.getint(sec, 'transmit_exp')
                self.log.debug('transmit duration is configed to %d' % self.TRANSMIT_EXP_DUR)
            if config.has_option(sec, 'disapprove_grant'):
                self.GRANT_DISAPPROVE_REASSIGN = config.getboolean(sec, 'disapprove_grant')
                self.log.debug('disapprove_grant is configed to %s' % self.GRANT_DISAPPROVE_REASSIGN)
            if config.has_option(sec, 'suspend_grant'):
                self.GRANT_SUSPEND = config.getboolean(sec, 'suspend_grant')
                self.log.debug('suspend_grant is configured to %s' % self.GRANT_SUSPEND)
            if config.has_option(sec, 'terminate_grant'):
                self.GRANT_TERMINATE = config.getboolean(sec, 'terminate_grant')
                self.log.debug('terminate_grant is configed to %s' % self.GRANT_TERMINATE)
            if config.has_option(sec, 'suspended_reassign'):
                self.SUSPENDED_REASSIGN = config.getboolean(sec, 'suspended_reassign')
                self.log.debug('suspended_reassign is configed to %s' % self.SUSPENDED_REASSIGN)
            if config.has_option(sec, 'terminated_reassign'):
                self.TERMINATED_REASSIGN = config.getboolean(sec, 'terminated_reassign')
                self.log.debug('terminated_reassign is configed to %s' % self.TERMINATED_REASSIGN)
            if config.has_option(sec, 'renew_grant'):
                self.RENEW_GRANT = config.getboolean(sec, 'renew_grant')
                self.log.debug('renew_grant is configed to %s' % self.RENEW_GRANT)
            if config.has_option(sec, 'renew_transmit'):
                self.RENEW_TRANSMIT = config.getboolean(sec, 'renew_transmit')
                self.log.debug('renew_transmit is configed to %s' % self.RENEW_TRANSMIT)
            if config.has_option(sec, 'recommend_max_eirp'):
                self.MAX_EIRP_REASSIGN = config.getint(sec, 'recommend_max_eirp')
                self.log.debug('recommended maxEirp is configed to %d' % self.MAX_EIRP_REASSIGN)
            if config.has_option(sec, 'recommend_low_freq'):
                self.FREQ_LOW_REASSIGN = config.getint(sec, 'recommend_low_freq')
                self.log.debug('recommended lowFrequency is configed to %d' % self.FREQ_LOW_REASSIGN)
            if config.has_option(sec, 'recommend_high_freq'):
                self.FREQ_HIGH_REASSIGN = config.getint(sec, 'recommend_high_freq')
                self.log.debug('recommended highFrequency is configed to %d' % self.FREQ_HIGH_REASSIGN)
            if config.has_option(sec, 'recommend_operationParam_grant'):
                operationParamsForGrant = config.get(sec, 'recommend_operationParam_grant')
                self.log.debug('operationParams are configed to %s for grant' % operationParamsForGrant)
                operationParamForGrant_keys = operationParamsForGrant.split(';')
                for operationParamForGrant_key in operationParamForGrant_keys:
                    self.operationParamsForGrant.append(operationParamForGrant_key)
            if config.has_option(sec, 'recommend_operationParam_heartbeat'):
                operationParamsForHeartbeat = config.get(sec, 'recommend_operationParam_heartbeat')
                self.log.debug('operationParams are configed to %s for heartbeat' % operationParamsForHeartbeat)
                operationParamForHeartbeat_keys = operationParamsForHeartbeat.split(';')
                for operationParamForHeartbeat_key in operationParamForHeartbeat_keys:
                    self.operationParamsForHeartbeat.append(operationParamForHeartbeat_key)
            if config.has_option(sec, 'pal_reserved_channel'):
                pals = config.get(sec, 'pal_reserved_channel')
                self.log.debug('PAL reserved channels is configed to %s' % pals)
                pal_keys = pals.split(',')
                for pal_key in pal_keys:
                    pal = int(pal_key)
                    pal_set = False
                    if (pal >= 3550 and pal <= 3640):
                        for chid in list(self.spectrum_table.keys()):
                            if pal * 1000000 == self.spectrum_table[chid][0][0]:
                                self.spectrum_table[chid][1] = True
                                self.spectrum_table[chid][2] = 'DUMMYCBSD'
                                pal_set = True
                                break
                    if pal_set is True:
                        self.log.debug('PAL reserved channel is configed to %d' % pal)
                    else:
                        self.log.warning('invalid PAL reserved channel %d' % pal)
            if config.has_option(sec, 'blocked_request'):
                req = config.get(sec, 'blocked_request')
                if req in sas_method_t:
                    self.BLOCKED_REQUEST = req
                    self.log.debug('blocked_request is configed to %s' % self.BLOCKED_REQUEST)
                else:
                    self.log.warning('invalid config value for blocked_request')
                if config.has_option(sec, 'blocked_request_grantids') and (method == METHOD_GRANT or
                                                                           method == METHOD_HEARTBEAT or
                                                                           method == METHOD_RELINQUISH):
                    self.BLOCKED_REQUEST_GRANTIDS = config.get(sec, 'blocked_request_grantids')
                    self.log.debug('blocked_request_grantids is configed to %s' % self.BLOCKED_REQUEST_GRANTIDS)
                    if self.BLOCKED_REQUEST_GRANTIDS is not None:
                        grantids = self.BLOCKED_REQUEST_GRANTIDS.split(',')
                        for grantid in grantids:
                            self.blocked_request_sequences[grantid] = 0
                else:
                    self.blocked_request_sequences['DUMMY_GRANT'] = 0
                if config.has_option(sec, 'blocked_request_sequence'):
                    self.BLOCKED_REQUEST_SEQUENCE = config.getint(sec, 'blocked_request_sequence')
                    self.log.debug('blocked_request_sequence is configed to %d' % self.BLOCKED_REQUEST_SEQUENCE)
            if config.has_option(sec, 'force_sas_method_group'):
                force_sas_method_group = config.get(sec, 'force_sas_method_group')
                self.log.debug('force_sas_method_group are configed to %s ' % force_sas_method_group)
                force_sas_method_group_keys = force_sas_method_group.split(';')
                for force_sas_method_key in force_sas_method_group_keys:
                    self.force_sas_method_group.append(force_sas_method_key)
                    force_sas_method = force_sas_method_key.split(',')
                    force_sas_method_id = str(force_sas_method[0]) + '_' + str(force_sas_method[1])
                    self.log.debug('force_sas_method_id for force_sas_method_group  is configed to %s'
                                   % force_sas_method_id)
                    self.force_sas_method_group_sequences[force_sas_method_id] = 0
            if config.has_option(sec, 'force_max_eirp_group'):
                force_max_eirp_group = config.get(sec, 'force_max_eirp_group')
                self.log.debug('force_max_eirp_group are configed to %s ' % force_max_eirp_group)
                force_max_eirp_group_keys = force_max_eirp_group.split(';')
                for force_max_eirp_key in force_max_eirp_group_keys:
                    self.force_max_eirp_group.append(force_max_eirp_key)
                    force_max_eirp = force_max_eirp_key.split(',')
                    force_max_eirp_id = str(force_max_eirp[0])
                    self.log.debug('force_max_eirp_id for force_max_eirp_group is configed to %s' % force_max_eirp_id)
                    self.force_max_eirp_group_sequences[force_max_eirp_id] = 0
            if config.has_option(sec, 'force_sas_method'):
                method = config.get(sec, 'force_sas_method')
                if method in sas_method_t:
                    self.SAS_METHOD_FORCE = method
                    self.log.debug('force_sas_method is configed to %s' % self.SAS_METHOD_FORCE)
                    if config.has_option(sec, 'force_sas_method_grantids') and (method == METHOD_GRANT
                                                                                or method == METHOD_HEARTBEAT
                                                                                or method == METHOD_RELINQUISH):
                        self.SAS_METHOD_FORCE_GRANTIDS = config.get(sec, 'force_sas_method_grantids')
                        self.log.debug('force_sas_method_grantids is configed to %s' % self.SAS_METHOD_FORCE_GRANTIDS)
                        if self.SAS_METHOD_FORCE_GRANTIDS is not None:
                            grantids = self.SAS_METHOD_FORCE_GRANTIDS.split(',')
                            for grantid in grantids:
                                self.force_sas_method_sequences[grantid] = 0
                    else:
                        self.force_sas_method_sequences['DUMMY_GRANT'] = 0
                        self.force_sas_method_sequences['DUMMY_INQUIRY'] = 0
                    if config.has_option(sec, 'force_sas_method_sequence'):
                        self.SAS_METHOD_FORCE_SEQUENCE = config.getint(sec, 'force_sas_method_sequence')
                        self.log.debug('force_sas_method_sequence is configed to %d' % self.SAS_METHOD_FORCE_SEQUENCE)
                    if config.has_option(sec, 'force_response_code'):
                        self.RESPONSE_CODE_FORCE = config.getint(sec, 'force_response_code')
                        self.log.debug('force_response_code is configed to %d' % self.RESPONSE_CODE_FORCE)
                    if config.has_option(sec, 'force_response_data'):
                        self.RESPONSE_DATA_FORCE = config.get(sec, 'force_response_data')
                        self.log.debug('force_response_data is configed to %s' % self.RESPONSE_DATA_FORCE)
                    if config.has_option(sec, 'force_exclude_param'):
                        self.EXCLUDE_PARAM_FORCE = config.get(sec, 'force_exclude_param')
                        self.log.debug('force_exclude_param is configed to %s' % self.EXCLUDE_PARAM_FORCE)
                    if config.has_option(sec, 'force_update_param'):
                        self.UPDATE_PARAM_FORCE = config.get(sec, 'force_update_param')
                        self.log.debug('force_update_param is configed to %s' % self.UPDATE_PARAM_FORCE)
                        if config.has_option(sec, 'force_update_param_data'):
                            self.UPDATE_PARAM_DATA_FORCE = config.get(sec, 'force_update_param_data')
                            self.log.debug('force_update_param_data is configed to %s' % self.UPDATE_PARAM_DATA_FORCE)
                    if config.has_option(sec, 'force_http_response_code'):
                        self.HTTP_RESPONSE_CODE_FORCE = config.getint(sec, 'force_http_response_code')
                        self.log.debug('force_http_response_code is configed to %d' % self.HTTP_RESPONSE_CODE_FORCE)
                    if config.has_option(sec, 'reject_subsequent_connection'):
                        self.SUBSEQUENT_CONN_REJECT = config.getboolean(sec, 'reject_subsequent_connection')
                        self.log.debug('reject_subsequent_connection is configed to %s' % self.SUBSEQUENT_CONN_REJECT)
                    if config.has_option(sec, 'force_max_eirp'):
                        self.MAX_EIRP_FORCE = config.getint(sec, 'force_max_eirp')
                        self.log.debug('force_max_eirp is configed to %d' % self.MAX_EIRP_FORCE)
                    if config.has_option(sec, 'force_response_dereg_immediately'):
                        self.FORCE_RESPONSE_DEREG_IMMEDIATELY = config.getboolean(sec,
                                                                                  'force_response_dereg_immediately')
                        self.log.debug('force_response_dereg_immediately is configed to %s'
                                       % self.FORCE_RESPONSE_DEREG_IMMEDIATELY)
                else:
                    self.log.warning('invalid config value for force_sas_method')
            if config.has_option(sec, 'chunked'):
                self.CHUNKED = config.getboolean(sec, 'chunked')
                self.log.debug('chunked encoding is configured to %s' % self.CHUNKED)
                if config.has_option(sec, 'chunksize'):
                    self.CHUNKSIZE = config.getint(sec, 'chunksize')
                    self.log.debug('chunk size is configured to %d' % self.CHUNKSIZE)
                else:
                    self.CHUNKSIZE = 40
                    self.log.debug('chunk size is configured to default of %d' % self.CHUNKSIZE)
            if config.has_option(sec, 'force_response_group'):
                force_response_group = config.get(sec, 'force_response_group')
                self.log.debug('force_response_group are configed to %s ' % force_response_group)
                force_response_group_keys = force_response_group.split(';')
                for force_response_group_key in force_response_group_keys:
                    self.force_response_group.append(force_response_group_key)
                    forceResponseMember = force_response_group_key.split(',')
                    forceResponseMemberID = str(forceResponseMember[0]) + '-' + str(forceResponseMember[2])
                    self.log.debug('forceResponseMemberID for force_response_group  is configed to %s'
                                   % forceResponseMemberID)
                    self.force_response_group_sequences[forceResponseMemberID] = 0
        except ConfigParser.MissingSectionHeaderError:
            self.log.error('missing section header in config file. using default configuration.')
        except ConfigParser.Error:
            self.log.error('parsing config file failed. using default configuration.')
        except ValueError:
            self.log.error('parsing config file failed. could not convert data to a specified type.')
        except Exception:
            self.log.error('parsing config file failed. unexcept error.')

    def getCbsdSpecificConfig(self, cbsdid):
        config = ConfigParser.ConfigParser()
        conPath = os.path.dirname(os.path.realpath(__file__)) + '/SAS_Sim.conf'
        config.read(conPath)
        # self.SAS_METHOD_FORCE = SAS_METHOD_FORCE
        # self.SAS_METHOD_FORCE_SEQUENCE = SAS_METHOD_FORCE_SEQUENCE
        # self.RESPONSE_CODE_FORCE = RESPONSE_CODE_FORCE
        # self.RESPONSE_DATA_FORCE = RESPONSE_DATA_FORCE
        # self.EXCLUDE_PARAM_FORCE = EXCLUDE_PARAM_FORCE
        # self.UPDATE_PARAM_FORCE = UPDATE_PARAM_FORCE
        # self.UPDATE_PARAM_DATA_FORCE = UPDATE_PARAM_DATA_FORCE
        # self.HTTP_RESPONSE_CODE_FORCE = HTTP_RESPONSE_CODE_FORCE
        # self.SUBSEQUENT_CONN_REJECT = SUBSEQUENT_CONN_REJECT
        # self.spectrum_table = spectrum_table
        # self.CONNECTION_REJECT = CONNECTION_REJECT
        # self.force_sas_method_sequence = 0

        if config.has_section(cbsdid):
            self.log.info('cbsdId section present')
            if config.has_option(cbsdid, 'blocked_request'):
                req = config.get(cbsdid, 'blocked_request')
                if req in sas_method_t:
                    self.BLOCKED_REQUEST = req
                    self.log.debug('blocked_request is configed to %s for cbsdid %s' % (self.BLOCKED_REQUEST, cbsdid))
                else:
                    self.log.warning('invalid config value for blocked_request')
            if config.has_option(cbsdid, 'blocked_request_sequence'):
                self.BLOCKED_REQUEST_SEQUENCE = config.getint(cbsdid, 'blocked_request_sequence')
                self.log.debug('blocked_request_sequence is configed to %d' % self.BLOCKED_REQUEST_SEQUENCE)

            if config.has_option(cbsdid, 'force_sas_method'):
                method = config.get(cbsdid, 'force_sas_method')
                if method in sas_method_t:
                    self.SAS_METHOD_FORCE = method
                    self.log.debug('force_sas_method is configed to %s for cbsdid %s' % self.SAS_METHOD_FORCE)
                    if config.has_option(cbsdid, 'force_sas_method_sequence'):
                        self.SAS_METHOD_FORCE_SEQUENCE = config.getint(cbsdid, 'force_sas_method_sequence')
                        self.log.debug('force_sas_method_sequence is configed to %d' % self.SAS_METHOD_FORCE_SEQUENCE)
                    if config.has_option(cbsdid, 'force_response_code'):
                        self.RESPONSE_CODE_FORCE = config.getint(cbsdid, 'force_response_code')
                        self.log.debug('force_response_code is configed to %d' % self.RESPONSE_CODE_FORCE)
                    if config.has_option(cbsdid, 'force_response_data'):
                        self.RESPONSE_DATA_FORCE = config.get(cbsdid, 'force_response_data')
                        self.log.debug('force_response_data is configed to %s' % self.RESPONSE_DATA_FORCE)
                    if config.has_option(cbsdid, 'force_exclude_param'):
                        self.EXCLUDE_PARAM_FORCE = config.get(cbsdid, 'force_exclude_param')
                        self.log.debug('force_exclude_param is configed to %s' % self.EXCLUDE_PARAM_FORCE)
                    if config.has_option(cbsdid, 'force_update_param'):
                        self.UPDATE_PARAM_FORCE = config.get(cbsdid, 'force_update_param')
                        self.log.debug('force_update_param is configed to %s' % self.UPDATE_PARAM_FORCE)
                        if config.has_option(cbsdid, 'force_update_param_data'):
                            self.UPDATE_PARAM_DATA_FORCE = config.get(cbsdid, 'force_update_param_data')
                            self.log.debug('force_update_param_data is configed to %s' % self.UPDATE_PARAM_DATA_FORCE)
                    if config.has_option(cbsdid, 'force_http_response_code'):
                        self.HTTP_RESPONSE_CODE_FORCE = config.getint(cbsdid, 'force_http_response_code')
                        self.log.debug('force_http_response_code is configed to %d' % self.HTTP_RESPONSE_CODE_FORCE)
                    if config.has_option(cbsdid, 'reject_subsequent_connection'):
                        self.SUBSEQUENT_CONN_REJECT = config.getboolean(cbsdid, 'reject_subsequent_connection')
                        self.log.debug('reject_subsequent_connection is configed to %s' % self.SUBSEQUENT_CONN_REJECT)
                    if config.has_option(cbsdid, 'force_max_eirp'):
                        self.MAX_EIRP_FORCE = config.getint(cbsdid, 'force_max_eirp')
                        self.log.debug('force_max_eirp is configed to %d' % self.MAX_EIRP_FORCE)
                    if config.has_option(sec, 'force_response_dereg_immediately'):
                        self.FORCE_RESPONSE_DEREG_IMMEDIATELY = config.getboolean(cbsdid,
                                                                                  'force_response_dereg_immediately')
                        self.log.debug('force_response_dereg_immediately is configed to %s'
                                       % self.FORCE_RESPONSE_DEREG_IMMEDIATELY)
                else:
                    self.log.warning('invalid config value for force_sas_method')
            if config.has_option(cbsdid, 'pal_reserved_channel'):
                pals = config.get(cbsdid, 'pal_reserved_channel')
                self.log.debug('PAL reserved channels is configed to %s' % pals)
                pal_keys = pals.split(',')
                for pal_key in pal_keys:
                    self.log.debug('PAL %s is configed' % pal_key)
                    pal = int(pal_key)
                    pal_set = False
                    if (pal >= 3550 and pal <= 3640):
                        for chid in list(self.spectrum_table.keys()):
                            if pal * 1000000 == self.spectrum_table[chid][0][0]:
                                self.spectrum_table[chid][1] = True
                                self.spectrum_table[chid][2] = cbsdid
                                pal_set = True
                                break
                    if pal_set is True:
                        self.log.debug('PAL reserved channel is configed to %d' % pal)
                    else:
                        self.log.warning('invalid PAL reserved channel %d' % pal)
        self.log.info('Done retrieving values')
        # return cbsdConfig


def receivedExpectHttpData(data):
    http_p = HttpRequestParser(data)
    if http_p.req_parse():
        header = http_p.get_header()
        if 'Content-Length' not in header:
            return True
        contentLen = int(header['Content-Length'])
        if contentLen <= len(http_p.get_data()):
            return True
    return False


def sockReceive(socketfd):
    data = ''
    while True:
        data += socketfd.recv(SOCK_BUF_MAX)
        if len(data) == 0:
            break
        if receivedExpectHttpData(data.decode('utf-8')) is True:
            break
    return data


def main_loop(config, logHandler):
    """
    create a listening socket and accept any connection request from client
    process the SAS request and reply with response message one by one
    """
    manager = CBSDManager(config, logHandler)
    log = logHandler
    try:
        # bindsocket = None
        if config.IPV6_ENABLE is False:
            bindsocket = socket.socket()
        else:
            bindsocket = socket.socket(socket.AF_INET6)
        # reuse a local socket in TIME_WAIT state
        bindsocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # blocking mode
        bindsocket.setblocking(1)
        bindsocket.settimeout(5)
        bindsocket.bind(('', config.PORT_NUM))
        bindsocket.listen(UN_CONN_NUM)
        log.info('start listening on port %d' % config.PORT_NUM)
        while True:
            if (config.CONNECTION_REJECT):
                log.warning('reject any incoming connection...')
                time.sleep(3600)
            else:
                newsocket = None
                try:
                    newsocket, fromaddr = bindsocket.accept()
                    log.info('accepted new connection from %s:%s' % (fromaddr[0], fromaddr[1]))
                    # blocking mode for new socket
                    newsocket.setblocking(1)
                    newsocket.settimeout(5)
                    if config.CONNECT_MODE_TLS:
                        if (config.MUTUAL_AUTH is True):
                            conn = ssl.wrap_socket(newsocket, config.KEY_FILE, config.CERT_FILE,
                                                   True, ssl.CERT_REQUIRED, ssl.PROTOCOL_SSLv23, config.CA_FILE)
                        else:
                            conn = ssl.wrap_socket(newsocket, config.KEY_FILE, config.CERT_FILE,
                                                   True, ssl.CERT_NONE, ssl.PROTOCOL_SSLv23)
                        # receive data only one time, the received msg may be incompleted
                        req = sockReceive(conn)
                    else:
                        req = sockReceive(newsocket)
                    log.debug('received data from %s:%s\r\n%s' % (fromaddr[0], fromaddr[1], req))
                    manager.request_dispatcher(req.decode('utf-8'))
                    res = manager.response_builder()
                    if config.CONNECT_MODE_TLS:
                        if res is not None:
                            resb = res.encode('utf-8')
                            conn.sendall(resb)
                            conn.shutdown(socket.SHUT_RDWR)
                            conn.close()
                            log.debug('sent data to %s:%s\r\n%s' % (fromaddr[0], fromaddr[1], resb))
                        else:
                            conn.shutdown(socket.SHUT_RDWR)
                            conn.close()
                    else:
                        if res is not None:
                            resb = res.encode('utf-8')
                            newsocket.sendall(resb)
                            newsocket.close()
                            log.debug('sent data to %s:%s\r\n%s' % (fromaddr[0], fromaddr[1], resb))
                        else:
                            newsocket.close()
                    log.info('closed connection from %s:%s' % (fromaddr[0], fromaddr[1]))
                except socket.timeout:
                    log.warning('socket timeout')
                    continue
                except socket.error as err:
                    log.warning('socket error :%s', err)
                    if config.CONNECT_MODE_TLS:
                        conn.shutdown(socket.SHUT_RDWR)
                        conn.close()
                    else:
                        newsocket.close()
                    continue
                except KeyboardInterrupt:
                    log.info('key board interrupt')
                    break
                except Exception as err:
                    log.critical('error :%s', err)
                    continue
        bindsocket.close()
    except socket.error as err:
        log.error('socket err :%s', err)
    finally:
        manager.cbsd_clean()
        bindsocket.close()


# main entry
if __name__ == '__main__':
    try:
        logHandler = logging_init()
        config = SASConfig(logHandler)
        logHandler.info('SAS Simulator start...')
        logHandler.debug('version: %s' % VERSION)
        logHandler.debug('version info: %s' % VERSION_INFO)
        main_loop(config, logHandler)
    except KeyboardInterrupt:
        logHandler.info('key board interrupt')
    except Exception as err:
        logHandler.critical('error :%s', err)
    finally:
        logHandler.info('SAS Simulator terminate...')
