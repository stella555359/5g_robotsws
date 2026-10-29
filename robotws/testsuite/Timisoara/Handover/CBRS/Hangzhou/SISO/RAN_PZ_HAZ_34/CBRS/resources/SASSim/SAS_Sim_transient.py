# !/usr/bin/env python
# -*- coding: utf-8 -*-

import socket
import ssl
import time
import datetime
import json
import logging
import configparser
import threading
import os
import sys
from utils.LoggerHandler import LoggerHandler
from sas.Consts import *
from sas.CbsdManager import CBSDManager

# port number binded to SAS simulator service
PORT_NUM = 44333

# True means secure connection (TLS) with CBSD
# False means insecure connection (TCP) with CBSD
CONNECT_MODE_TLS = True

# key file and certificate file
KEY_FILE = 'nokia04.key'
CERT_FILE = 'nokia04.cert'

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
BLOCKED_REQUEST_SEQUENCE = None

# True - extend grantExpireTime in Heartbeat response if
# grantRenew is set to True in a heartbeatRequest
RENEW_GRANT = True

# True - extend transmitExpireTime in Heartbeat response
RENEW_TRANSMIT = True

# supported spectrum in form:
# 'ID': [(LOW_FREQUENCY, HIGH_FREQUENCY), IS_PAL_CHANNEL]
spectrum_table = {
    '2585-20': [(2585000000, 2605000000), False],
    '3550-10': [(3550000000, 3560000000), False],
    '3560-10': [(3560000000, 3570000000), False],
    '3570-10': [(3570000000, 3580000000), False],
    '3580-10': [(3580000000, 3590000000), False],
    '3590-10': [(3590000000, 3600000000), False],
    '3600-10': [(3600000000, 3610000000), False],
    '3610-10': [(3610000000, 3620000000), False],
    '3620-10': [(3620000000, 3630000000), False],
    '3630-10': [(3630000000, 3640000000), False],
    '3640-10': [(3640000000, 3650000000), False],
    '3650-10': [(3650000000, 3660000000), False],
    '3660-10': [(3660000000, 3670000000), False],
    '3670-10': [(3670000000, 3680000000), False],
    '3680-10': [(3680000000, 3690000000), False],
    '3690-10': [(3690000000, 3700000000), False],
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
RESPONSE_CODE_FORCE = None
RESPONSE_DATA_FORCE = None
EXCLUDE_PARAM_FORCE = None
UPDATE_PARAM_FORCE = None
UPDATE_PARAM_DATA_FORCE = None
HTTP_RESPONSE_CODE_FORCE = None
SUBSEQUENT_CONN_REJECT = None

# simulator version
VERSION = 'V1.0.0'
VERSION_INFO = 'Compliance with TS1.1 without CPI support'

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
        config = configparser.ConfigParser()
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
    except configparser.MissingSectionHeaderError:
        print('missing section header in config file. using default configuration.')
    except configparser.Error:
        print('parsing config file failed. using default configuration.')
    except ValueError:
        print('parsing config file failed. could not convert data to a specified type.')
    except Exception as e:
        print('parsing config file failed. unexcept error.')
    finally:
        return logHandler


class SASConfig(object):

    def __init__(self, logHandler):
        self.log = logHandler
        self.VERSION = VERSION
        self.VERSION_INFO = VERSION_INFO
        self.PORT_NUM = PORT_NUM
        self.KEY_FILE = KEY_FILE
        self.CERT_FILE = CERT_FILE
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
        self.BLOCKED_REQUEST_SEQUENCE = BLOCKED_REQUEST_SEQUENCE
        self.RENEW_GRANT = RENEW_GRANT
        self.RENEW_TRANSMIT = RENEW_TRANSMIT
        self.MAX_EIRP_REASSIGN = MAX_EIRP_REASSIGN
        self.FREQ_LOW_REASSIGN = FREQ_LOW_REASSIGN
        self.FREQ_HIGH_REASSIGN = FREQ_HIGH_REASSIGN
        self.SAS_METHOD_FORCE = SAS_METHOD_FORCE
        self.RESPONSE_CODE_FORCE = RESPONSE_CODE_FORCE
        self.RESPONSE_DATA_FORCE = RESPONSE_DATA_FORCE
        self.EXCLUDE_PARAM_FORCE = EXCLUDE_PARAM_FORCE
        self.UPDATE_PARAM_FORCE = UPDATE_PARAM_FORCE
        self.UPDATE_PARAM_DATA_FORCE = UPDATE_PARAM_DATA_FORCE
        self.HTTP_RESPONSE_CODE_FORCE = HTTP_RESPONSE_CODE_FORCE
        self.SUBSEQUENT_CONN_REJECT = SUBSEQUENT_CONN_REJECT
        self.spectrum_table = spectrum_table
        self.CONNECTION_REJECT = CONNECTION_REJECT
        self.blocked_request_sequence = 0

        sec = 'conf'
        try:
            config = configparser.ConfigParser()
            conPath = os.path.dirname(os.path.realpath(__file__)) + '/SAS_Sim.conf'
            config.read(conPath)

            items = config.items(sec)
            self.log.debug('reading configuration from SAS_Sim.conf ...')
            if config.has_option(sec, 'port_number'):
                self.PORT_NUM = config.getint(sec, 'port_number')
                self.log.debug('service port is configed to %d' % self.PORT_NUM)
            if config.has_option(sec, 'key_file_name'):
                self.KEY_FILE = config.get(sec, 'key_file_name')
                self.log.debug('key file is configed to %s' % self.KEY_FILE)
            if config.has_option(sec, 'cert_file_name'):
                self.CERT_FILE = config.get(sec, 'cert_file_name')
                self.log.debug('certificate file is configed to %s' % self.CERT_FILE)
            if config.has_option(sec, 'tls_connection'):
                self.CONNECT_MODE_TLS = config.getboolean(sec, 'tls_connection')
                self.log.debug('tls_connection is configed to %s' % self.CONNECT_MODE_TLS)
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
            if config.has_option(sec, 'pal_reserved_channel'):
                pal = config.getint(sec, 'pal_reserved_channel')
                pal_set = False
                if 3550 <= pal <= 3650:
                    for chid in list(self.spectrum_table.keys()):
                        if pal * 1000000 == self.spectrum_table[chid][0][0]:
                            self.spectrum_table[chid][1] = True
                            pal_set = True
                            break
                if pal_set:
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
            if config.has_option(sec, 'blocked_request_sequence'):
                self.BLOCKED_REQUEST_SEQUENCE = config.getint(sec, 'blocked_request_sequence')
                self.log.debug('blocked_request_sequence is configed to %d' % self.BLOCKED_REQUEST_SEQUENCE)
            if config.has_option(sec, 'force_sas_method'):
                method = config.get(sec, 'force_sas_method')
                if method in sas_method_t:
                    self.SAS_METHOD_FORCE = method
                    self.log.debug('force_sas_method is configed to %s' % self.SAS_METHOD_FORCE)
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
                else:
                    self.log.warning('invalid config value for force_sas_method')
        except configparser.MissingSectionHeaderError:
            self.log.error('missing section header in config file. using default configuration.')
        except configparser.Error:
            self.log.error('parsing config file failed. using default configuration.')
        except ValueError:
            self.log.error('parsing config file failed. could not convert data to a specified type.')
        except Exception as e:
            self.log.error('parsing config file failed. unexcept error.')


def main_loop(config, logHandler):
    """
    create a listening socket and accept any connection request from client
    process the SAS request and reply with response message one by one
    """
    manager = CBSDManager(config, logHandler)
    log = logHandler
    try:
        bindsocket = socket.socket()
        # reuse a local socket in TIME_WAIT state
        bindsocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # blocking mode
        bindsocket.setblocking(1)
        bindsocket.settimeout(5)
        bindsocket.bind(('', config.PORT_NUM))
        bindsocket.listen(UN_CONN_NUM)
        while True:
            if config.CONNECTION_REJECT:
                log.warning('reject any incoming connection...')
                # waiting for ever
                # (1073741824 seconds = 12427 days) is enough ?
                time.sleep(1073741824)
            else:
                try:
                    log.info('start listening on port %d' % config.PORT_NUM)
                    newsocket, fromaddr = bindsocket.accept()
                    log.info('accepted new connection from %s:%s' % (fromaddr[0], fromaddr[1]))
                    # blocking mode for new socket
                    newsocket.setblocking(1)
                    newsocket.settimeout(5)

                    if config.CONNECT_MODE_TLS is not False:
                        conn = ssl.wrap_socket(newsocket, config.KEY_FILE, config.CERT_FILE,
                                               True, ssl.CERT_NONE, ssl.PROTOCOL_SSLv23)
                        # receive data only one time, the received msg may be incompleted
                        req = conn.recv(SOCK_BUF_MAX)
                    else:
                        req = newsocket.recv(SOCK_BUF_MAX)
                    log.debug('received data from %s:%s\r\n%s' % (fromaddr[0], fromaddr[1], req))
                    manager.request_dispatcher(req.decode('utf-8'))
                    res = manager.response_builder()
                    if config.CONNECT_MODE_TLS is not False:
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
                    continue
                except socket.error as err:
                    log.warning('socket error :%s', err)
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
