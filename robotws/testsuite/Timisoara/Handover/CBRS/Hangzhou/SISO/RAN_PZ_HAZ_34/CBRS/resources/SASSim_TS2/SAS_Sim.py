#!/usr/bin/env python
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
import select
import re
import copy

from utils.LoggerHandler import LoggerHandler
from sas.Consts import *
from sas.CbsdManager import CBSDManager
from httpBase.HttpRequestParser import HttpRequestParser


# ############################# DEFAULT CONFIGURATION START ###############
# port number binded to SAS simulator service
PORT_NUM = 443

# True means support IPv6 connection
# False means support IPv4 connection only
IPV6_ENABLE = False

# True means secure connection (TLS) with CBSD
# False means insecure connection (TCP) with CBSD
CONNECT_MODE_TLS = True

# tls mode connected to SAS simulator service
TLS_MODE = ssl.PROTOCOL_SSLv23

SNI_ENABLE = False
# True means TLS mutual authentication
# False means server will not validate peer's certificate
MUTUAL_AUTH = False
# True means sas sim act as Domain Proxy
# False means sas sim act as sas server
DP_MODEL = False

# key file and certificate file
KEY_FILE = "nokia04.key"
CERT_FILE = "nokia04.cert"
CA_FILE = "ca.cert"

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

# True - suspend the grant via heartbeat response with error code of
# SUSPENDED_GRANT
GRANT_SUSPEND = False

# True - terminate the grant via heartbeat response with error code of
# SUSPENDED_GRANT
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
BLOCKED_REQUEST_SEQUENCE = []

# True - extend grantExpireTime in Heartbeat response if
# grantRenew is set to True in a heartbeatRequest
RENEW_GRANT = True

# True - extend transmitExpireTime in Heartbeat response
RENEW_TRANSMIT = True

# supported spectrum in form:
# 'ID': [(LOW_FREQUENCY, HIGH_FREQUENCY), IS_PAL_CHANNEL]
spectrum_table = {
    "3550-10": [[3550000000, 3560000000], False, ""],
    "3560-10": [[3560000000, 3570000000], False, ""],
    "3570-10": [[3570000000, 3580000000], False, ""],
    "3580-10": [[3580000000, 3590000000], False, ""],
    "3590-10": [[3590000000, 3600000000], False, ""],
    "3600-10": [[3600000000, 3610000000], False, ""],
    "3610-10": [[3610000000, 3620000000], False, ""],
    "3620-10": [[3620000000, 3630000000], False, ""],
    "3630-10": [[3630000000, 3640000000], False, ""],
    "3640-10": [[3640000000, 3650000000], False, ""],
    "3650-10": [[3650000000, 3660000000], False, ""],
    "3660-10": [[3660000000, 3670000000], False, ""],
    "3670-10": [[3670000000, 3680000000], False, ""],
    "3680-10": [[3680000000, 3690000000], False, ""],
    "3690-10": [[3690000000, 3700000000], False, ""],
}


spectrum_table_v2 = {
    "3550-5": [[3550000000, 3555000000], False, ""],
    "3555-5": [[3555000000, 3560000000], False, ""],
    "3560-5": [[3560000000, 3565000000], False, ""],
    "3565-5": [[3565000000, 3570000000], False, ""],
    "3570-5": [[3570000000, 3575000000], False, ""],
    "3575-5": [[3575000000, 3580000000], False, ""],
    "3580-5": [[3580000000, 3585000000], False, ""],
    "3585-5": [[3585000000, 3590000000], False, ""],
    "3590-5": [[3590000000, 3595000000], False, ""],
    "3595-5": [[3595000000, 3600000000], False, ""],
    "3600-5": [[3600000000, 3605000000], False, ""],
    "3605-5": [[3605000000, 3610000000], False, ""],
    "3610-5": [[3610000000, 3615000000], False, ""],
    "3615-5": [[3615000000, 3620000000], False, ""],
    "3620-5": [[3620000000, 3625000000], False, ""],
    "3625-5": [[3625000000, 3630000000], False, ""],
    "3630-5": [[3630000000, 3635000000], False, ""],
    "3635-5": [[3635000000, 3640000000], False, ""],
    "3640-5": [[3640000000, 3645000000], False, ""],
    "3645-5": [[3645000000, 3650000000], False, ""],
    "3650-5": [[3650000000, 3655000000], False, ""],
    "3655-5": [[3655000000, 3660000000], False, ""],
    "3660-5": [[3660000000, 3665000000], False, ""],
    "3665-5": [[3665000000, 3670000000], False, ""],
    "3670-5": [[3670000000, 3675000000], False, ""],
    "3675-5": [[3675000000, 3680000000], False, ""],
    "3680-5": [[3680000000, 3685000000], False, ""],
    "3685-5": [[3685000000, 3690000000], False, ""],
    "3690-5": [[3690000000, 3695000000], False, ""],
    "3695-5": [[3695000000, 3700000000], False, ""],
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
RESPONSE_SWITCH_DP = None
RESPONSE_CODE_FORCE = None
RESPONSE_DATA_FORCE = ""
RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
ALL_RESPONSE_SASFEATUREINFO_FORCE = -1
EXCLUDE_PARAM_FORCE = None
UPDATE_PARAM_FORCE = None
UPDATE_PARAM_DATA_FORCE = None
HTTP_RESPONSE_CODE_FORCE = None
HTTP_RESPONSE_SEQUENCES_FORCE = None
SUBSEQUENT_CONN_REJECT = None
MAX_EIRP_FORCE = None
FORCE_RESPONSE_DEREG_IMMEDIATELY = None

# Response encoding
CHUNKED = False
CHUNKSIZE = 40

SAS_FEATURE_CAPABILITY_LIST = None
# ############################# DEFAULT CONFIGURATION END #################


# simulator version
VERSION = "v1.2"
VERSION_INFO = "Compliance with TS1.2 without CPI support"


# socket conf
UN_CONN_NUM = 5
SOCK_BUF_MAX = 32000

CONNECTION_REJECT = False

DOMAIN_CONTEXTS = {}


def logging_init(config_file):
    log_level = logging.DEBUG
    log_file = None
    logHandler = None
    sec = "conf"
    try:
        config = configparser.ConfigParser()
        conPath = config_file
        config.read(conPath)

        print("\nconPath: %s\n" % conPath)

        items = config["conf"]
        log_file = items["log_file_name"]
        level = items["log_level"]
        if level.upper() == "DEBUG":
            log_level = logging.DEBUG
        elif level.upper() == "INFO":
            log_level = logging.INFO
        elif level.upper() == "WARNING":
            log_level = logging.WARNING
        elif level.upper() == "ERROR":
            log_level = logging.ERROR
        elif level.upper() == "CRITICAL":
            log_level = logging.CRITICAL
        else:
            # using default value
            pass
        print("\nlog_file: %s\n" % log_file)
        # log_level = logging.ERROR
        logHandler = LoggerHandler("SAS_Sim", log_file, log_level)
    except configparser.MissingSectionHeaderError:
        print("missing section header in config file. using default configuration.")
    except configparser.Error:
        print("parsing config file failed. using default configuration.")
    except ValueError:
        print("parsing config file failed. could not convert data to a specified type.")
    except BaseException:
        print("parsing config file failed. unexcept error.")
    finally:
        return logHandler


class SASConfig(object):
    def __init__(self, logHandler, config_file):
        self.log = logHandler
        self.config_file = config_file
        self.VERSION = VERSION
        self.enable_compatible_mode = False
        self.VERSION_INFO = VERSION_INFO
        self.PORT_NUM = PORT_NUM
        self.MUTUAL_AUTH = MUTUAL_AUTH
        self.KEY_FILE = KEY_FILE
        self.CERT_FILE = CERT_FILE
        self.CA_FILE = CA_FILE
        self.IPV6_ENABLE = IPV6_ENABLE
        self.DP_MODEL = DP_MODEL
        self.SNI_ENABLE = SNI_ENABLE
        self.CONNECT_MODE_TLS = CONNECT_MODE_TLS
        self.TLS_MODE = TLS_MODE
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
        self.RESPONSE_SWITCH_DP = RESPONSE_SWITCH_DP
        self.RESPONSE_CODE_FORCE = RESPONSE_CODE_FORCE
        self.RESPONSE_DATA_FORCE = RESPONSE_DATA_FORCE
        self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = (
            RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
        )
        self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = (
            ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
        )
        self.ALL_RESPONSE_SASFEATUREINFO_FORCE = ALL_RESPONSE_SASFEATUREINFO_FORCE
        self.EXCLUDE_PARAM_FORCE = EXCLUDE_PARAM_FORCE
        self.UPDATE_PARAM_FORCE = UPDATE_PARAM_FORCE
        self.UPDATE_PARAM_DATA_FORCE = UPDATE_PARAM_DATA_FORCE
        self.HTTP_RESPONSE_CODE_FORCE = HTTP_RESPONSE_CODE_FORCE
        self.HTTP_RESPONSE_SEQUENCES = HTTP_RESPONSE_SEQUENCES_FORCE
        self.SUBSEQUENT_CONN_REJECT = SUBSEQUENT_CONN_REJECT
        self.MAX_EIRP_FORCE = MAX_EIRP_FORCE
        self.FORCE_RESPONSE_DEREG_IMMEDIATELY = FORCE_RESPONSE_DEREG_IMMEDIATELY
        self.CONNECTION_REJECT = CONNECTION_REJECT
        self.CHUNKED = CHUNKED
        self.CHUNKSIZE = CHUNKSIZE
        self.SAS_FEATURE_CAPABILITY_LIST = SAS_FEATURE_CAPABILITY_LIST
        self.sas_feature_capability_sequence = 10
        self.sas_feature_capability_exist = True
        self.force_sas_feature_capability_list_group = {}
        self.force_sas_method_sequences = {}
        self.blocked_request_sequences = {}
        self.operationParamsForGrant = []
        self.operationParamsForHeartbeat = []
        self.force_sas_method_group = []
        self.force_sas_method_times = 0
        self.force_sas_method_group_sequences = {}
        self.force_max_eirp_group = []
        self.force_max_eirp_group_sequences = {}
        self.force_response_group = []
        self.force_response_group_sequences = {}
        self.spectrumInquery_times = -1
        self.force_spectrumInquery_response_group = {}
        self.force_registration_method_group_sequences_error_code = {}
        self.cbrsaVersion = ""
        self.eutraTddConfig = []
        self.force_method_cbrsa_version_group = {}
        self.force_method_eutra_tdd_config_group = {}
        self.cbsdFrequencyGuidance = []
        self.cbsdFrequencyGuidanceGroup = {}
        self.force_spectrum_table = []
        self.cbrsaVersion_change_times = []
        self.eutraTddConfig_change_times = []
        self.force_spectrumInquiry_method_group = []
        self.force_spectrumInquiry_method_group_sequences_error_code = {}
        self.force_spectrumInquiry_method_force_data = []
        self.force_deregistration_method_group = []
        self.restore_registration = None
        self.restore_grant = None
        self.restore_heartbeat = None
        self.sleeptime_sequence = []
        self.sleep_time = 0
        self.multiple_msg_block_group_dict = {}
        self.multiple_msg_block_group = {}
        self.force_sas_method_resp_sequence = []
        self.hex_code = 0
        self.drop_request_enable = 0
        self.drop_request_delay = 1
        self.force_method_feature_exchange_trigger_group = {}
        self.force_method_grouping_config_group_type_group_id_supported_by_sas = {}
        self.recommend_operationParam_heartbeat0 = {}
        self.force_heartbeat_channeltype_group = {}
        sec = "conf"
        try:
            config = configparser.ConfigParser()
            conPath = config_file
            config.read(conPath)

            items = config.items(sec)
            self.log.debug("reading configuration from %s ...", self.config_file)

            if config.has_option(sec, "ts_version"):
                self.VERSION = config.get(sec, "ts_version").lower()
                self.log.debug("self.VERSION is configured to %s" % self.VERSION)

            if config.has_option(sec, "enable_compatible_mode"):
                self.enable_compatible_mode = (
                    config.get(sec, "enable_compatible_mode").lower() == "true"
                )
                self.log.debug(
                    "self.enable_compatible_mode is configured to %s"
                    % self.enable_compatible_mode
                )

            if self.VERSION in sas_version_1_t:
                self.spectrum_table = spectrum_table
            elif self.VERSION in sas_version_2_t:
                self.spectrum_table = spectrum_table_v2

            if config.has_option(sec, "drop_request_enable"):
                self.drop_request_enable = config.getint(sec, "drop_request_enable")
                self.log.debug(
                    "self.drop_request_enable are configged to %s "
                    % self.drop_request_enable
                )
            if config.has_option(sec, "drop_request_delay"):
                self.drop_request_delay = config.getint(sec, "drop_request_delay")
                self.log.debug(
                    "self.drop_request_delay are configged to %s "
                    % self.drop_request_delay
                )

            if config.has_option(sec, "restore_registration"):
                self.restore_registration = config.get(sec, "restore_registration")
            if config.has_option(sec, "restore_grant"):
                self.restore_grant = config.get(sec, "restore_grant")
            if config.has_option(sec, "restore_heartbeat"):
                self.restore_heartbeat = config.get(sec, "restore_heartbeat")
            if config.has_option(sec, "force_all_response_featureDataExchangeConfig"):
                try:
                    self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = config.getint(
                        sec, "force_all_response_featureDataExchangeConfig"
                    )
                    self.log.debug(
                        "force_all_response_featureDataExchangeConfig is configged to %d"
                        % self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                    )
                except BaseException:
                    self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
                    self.log.debug(
                        "catch error: force_all_response_featureDataExchangeConfig is configged to %d"
                        % self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                    )
            else:
                self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
                self.log.debug(
                    "use the default value: force_all_response_featureDataExchangeConfig is configged to %d"
                    % self.ALL_RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                )
            if config.has_option(sec, "force_all_response_sasFeatureInfo"):
                try:
                    self.ALL_RESPONSE_SASFEATUREINFO_FORCE = config.getint(
                        sec, "force_all_response_sasFeatureInfo"
                    )
                    self.log.debug(
                        "force_all_response_sasFeatureInfo is configged to %d"
                        % self.ALL_RESPONSE_SASFEATUREINFO_FORCE
                    )
                except BaseException:
                    self.ALL_RESPONSE_SASFEATUREINFO_FORCE = -1
                    self.log.debug(
                        "catch error: force_all_response_sasFeatureInfo is configged to %d"
                        % self.ALL_RESPONSE_SASFEATUREINFO_FORCE
                    )
            else:
                self.ALL_RESPONSE_SASFEATUREINFO_FORCE = -1
                self.log.debug(
                    "use the default value: force_all_response_sasFeatureInfo is configged to %d"
                    % self.ALL_RESPONSE_SASFEATUREINFO_FORCE
                )
            if config.has_option(sec, "port_number"):
                self.PORT_NUM = config.getint(sec, "port_number")
                self.log.debug("service port is configged to %d" % self.PORT_NUM)
            fileBasePath = os.path.dirname(os.path.realpath(__file__))
            if config.has_option(sec, "key_file_name"):
                keyFile = config.get(sec, "key_file_name")
                if os.path.exists(keyFile):
                    self.KEY_FILE = keyFile
                else:
                    self.KEY_FILE = fileBasePath + "/" + keyFile
                self.log.debug("key file is configged to %s" % self.KEY_FILE)
            if config.has_option(sec, "cert_file_name"):
                certFile = config.get(sec, "cert_file_name")
                if os.path.exists(certFile):
                    self.CERT_FILE = certFile
                else:
                    self.CERT_FILE = fileBasePath + "/" + certFile
                self.log.debug("certificate file is configged to %s" % self.CERT_FILE)
            if config.has_option(sec, "CA_file_name"):
                caFile = config.get(sec, "CA_file_name")
                if os.path.exists(caFile):
                    self.CA_FILE = caFile
                else:
                    self.CA_FILE = fileBasePath + "/" + caFile
                self.log.debug("CA file is configged to %s" % self.CA_FILE)
            if config.has_option(sec, "enable_ipv6"):
                self.IPV6_ENABLE = config.getboolean(sec, "enable_ipv6")
                self.log.debug("enable_ipv6 is configged to %s" % self.IPV6_ENABLE)
            if config.has_option(sec, "dp_model"):
                self.DP_MODEL = config.getboolean(sec, "dp_model")
                self.log.debug("dp_model is configged to %s" % self.DP_MODEL)
            if config.has_option(sec, "tls_connection"):
                self.CONNECT_MODE_TLS = config.getboolean(sec, "tls_connection")
                self.log.debug(
                    "tls_connection is configged to %s" % self.CONNECT_MODE_TLS
                )
            if config.has_option(sec, "tls_mode"):
                tls_mode = config.get(sec, "tls_mode")
                if tls_mode == "Tls1v2Only":
                    self.TLS_MODE = ssl.OP_NO_TLSv1_3
                    self.log.debug(
                        "Tls1v2Only enable, tls_mode is configged to %s" % self.TLS_MODE
                    )
                elif tls_mode == "TlsAll":
                    self.TLS_MODE = ssl.PROTOCOL_SSLv23
                    self.log.debug("tls_mode is configged to %s" % self.TLS_MODE)
                else:
                    self.log.error("not supported tls_mode in config, use default.")
                    self.TLS_MODE = ssl.PROTOCOL_SSLv23
            if config.has_option(sec, "tls_mutual_auth"):
                self.MUTUAL_AUTH = config.getboolean(sec, "tls_mutual_auth")
                self.log.debug("tls_mutual_auth is configged to %s" % self.MUTUAL_AUTH)
            if config.has_option(sec, "tls_sni_enable"):
                self.SNI_ENABLE = config.getboolean(sec, "tls_sni_enable")
                self.log.debug("tls_sni_enable is configged to %s" % self.SNI_ENABLE)
            if config.has_option(sec, "heart_beat"):
                self.HEART_BEAT_DUR = config.getint(sec, "heart_beat")
                self.log.debug(
                    "heartbeat duration is configged to %d" % self.HEART_BEAT_DUR
                )
            if config.has_option(sec, "grant_exp"):
                self.GRANT_EXP_DUR = config.getint(sec, "grant_exp")
                self.log.debug("grant duration is configged to %d" % self.GRANT_EXP_DUR)
            if config.has_option(sec, "transmit_exp"):
                self.TRANSMIT_EXP_DUR = config.getint(sec, "transmit_exp")
                self.log.debug(
                    "transmit duration is configged to %d" % self.TRANSMIT_EXP_DUR
                )
            if config.has_option(sec, "disapprove_grant"):
                self.GRANT_DISAPPROVE_REASSIGN = config.getboolean(
                    sec, "disapprove_grant"
                )
                self.log.debug(
                    "disapprove_grant is configged to %s"
                    % self.GRANT_DISAPPROVE_REASSIGN
                )
            if config.has_option(sec, "suspend_grant"):
                self.GRANT_SUSPEND = config.getboolean(sec, "suspend_grant")
                self.log.debug("suspend_grant is configured to %s" % self.GRANT_SUSPEND)
            if config.has_option(sec, "terminate_grant"):
                self.GRANT_TERMINATE = config.getboolean(sec, "terminate_grant")
                self.log.debug(
                    "terminate_grant is configged to %s" % self.GRANT_TERMINATE
                )
            if config.has_option(sec, "suspended_reassign"):
                self.SUSPENDED_REASSIGN = config.getboolean(sec, "suspended_reassign")
                self.log.debug(
                    "suspended_reassign is configged to %s" % self.SUSPENDED_REASSIGN
                )
            if config.has_option(sec, "terminated_reassign"):
                self.TERMINATED_REASSIGN = config.getboolean(sec, "terminated_reassign")
                self.log.debug(
                    "terminated_reassign is configged to %s" % self.TERMINATED_REASSIGN
                )
            if config.has_option(sec, "renew_grant"):
                self.RENEW_GRANT = config.getboolean(sec, "renew_grant")
                self.log.debug("renew_grant is configged to %s" % self.RENEW_GRANT)
            if config.has_option(sec, "renew_transmit"):
                self.RENEW_TRANSMIT = config.getboolean(sec, "renew_transmit")
                self.log.debug(
                    "renew_transmit is configged to %s" % self.RENEW_TRANSMIT
                )
            if config.has_option(sec, "recommend_max_eirp"):
                try:
                    self.MAX_EIRP_REASSIGN = config.getint(sec, "recommend_max_eirp")
                    self.log.debug(
                        "recommended maxEirp is configged to %d"
                        % self.MAX_EIRP_REASSIGN
                    )
                except BaseException:
                    self.MAX_EIRP_REASSIGN = config.getfloat(sec, "recommend_max_eirp")
                    self.log.debug(
                        "recommended maxEirp is configged to %f"
                        % self.MAX_EIRP_REASSIGN
                    )
            if config.has_option(sec, "recommend_low_freq"):
                self.FREQ_LOW_REASSIGN = config.getint(sec, "recommend_low_freq")
                self.log.debug(
                    "recommended lowFrequency is configged to %d"
                    % self.FREQ_LOW_REASSIGN
                )
            if config.has_option(sec, "recommend_high_freq"):
                self.FREQ_HIGH_REASSIGN = config.getint(sec, "recommend_high_freq")
                self.log.debug(
                    "recommended highFrequency is configged to %d"
                    % self.FREQ_HIGH_REASSIGN
                )
            if config.has_option(sec, "recommend_operationParam_grant"):
                operationParamsForGrant = config.get(
                    sec, "recommend_operationParam_grant"
                )
                self.log.debug(
                    "operationParams are configged to %s for grant"
                    % operationParamsForGrant
                )
                operationParamForGrant_keys = operationParamsForGrant.split(";")
                for operationParamForGrant_key in operationParamForGrant_keys:
                    self.operationParamsForGrant.append(operationParamForGrant_key)
            if config.has_option(sec, "recommend_operationParam_heartbeat"):
                operationParamsForHeartbeat = config.get(
                    sec, "recommend_operationParam_heartbeat"
                )
                self.log.debug(
                    "operationParams are configged to %s for heartbeat"
                    % operationParamsForHeartbeat
                )
                operationParamForHeartbeat_keys = operationParamsForHeartbeat.split(";")
                for operationParamForHeartbeat_key in operationParamForHeartbeat_keys:
                    self.operationParamsForHeartbeat.append(
                        operationParamForHeartbeat_key
                    )

            if config.has_option(sec, "spectrum_table"):
                self.spectrum_table.clear()
                force_spectrum_table = config.get(sec, "spectrum_table")
                force_spectrum_table_items = force_spectrum_table.split(";")
                self.log.debug(
                    "force_spectrum_table is configured to %s" % force_spectrum_table
                )
                spectrum_table_from_config = {}
                for force_spectrum_table_item in force_spectrum_table_items:
                    parent_list = []
                    child_list = []
                    item = force_spectrum_table_item.split(":")
                    available_spectrum_resp = item[1].split(",")
                    child_list.append(int(available_spectrum_resp[0]))
                    child_list.append(int(available_spectrum_resp[1]))
                    parent_list.append(child_list)
                    isPAL = (
                        True if available_spectrum_resp[2].lower() == "true" else False
                    )
                    parent_list.append(isPAL)
                    parent_list.append(available_spectrum_resp[3])
                    try:
                        parent_list.append(int(available_spectrum_resp[4]))
                    except BaseException:
                        parent_list.append(float(available_spectrum_resp[4]))
                    spectrum_table_from_config[item[0]] = parent_list

                self.spectrum_table = self.convertSpectrum(
                    spectrum_table_from_config, self.VERSION
                )

            if config.has_option(sec, "pal_reserved_channel"):
                pals = config.get(sec, "pal_reserved_channel")
                self.log.debug("PAL reserved channels is configged to %s" % pals)
                pal_keys = pals.split(",")
                for pal_key in pal_keys:
                    pal = int(pal_key)
                    pal_set = False
                    if 3550 <= pal <= 3645:
                        for chid in list(self.spectrum_table.keys()):
                            if pal * 1000000 == self.spectrum_table[chid][0][0]:
                                self.spectrum_table[chid][1] = True
                                self.spectrum_table[chid][2] = "DUMMYCBSD"
                                pal_set = True
                                break
                    if pal_set:
                        self.log.debug("PAL reserved channel is configged to %d" % pal)
                    else:
                        self.log.warning("invalid PAL reserved channel %d" % pal)
            if config.has_option(sec, "blocked_request"):
                req = [
                    i.strip(" ") for i in config.get(sec, "blocked_request").split(",")
                ]
                if req[0] not in sas_method_t:
                    self.log.warning("invalid config value for blocked_request")
                elif len(req) == 1:
                    self.BLOCKED_REQUEST = req[0]
                    self.log.debug(
                        "blocked_request is configged to %s" % self.BLOCKED_REQUEST
                    )
                else:
                    self.BLOCKED_REQUEST = req
                if config.has_option(sec, "blocked_request_grantids") and (
                    req[0] == METHOD_GRANT
                    or req[0] == METHOD_HEARTBEAT
                    or req[0] == METHOD_RELINQUISH
                ):
                    self.BLOCKED_REQUEST_GRANTIDS = config.get(
                        sec, "blocked_request_grantids"
                    )
                    self.log.debug(
                        "blocked_request_grantids is configged to %s"
                        % self.BLOCKED_REQUEST_GRANTIDS
                    )
                    if self.BLOCKED_REQUEST_GRANTIDS is not None:
                        grantids = self.BLOCKED_REQUEST_GRANTIDS.split(",")
                        for grantid in grantids:
                            self.blocked_request_sequences[grantid] = 0
                else:
                    self.blocked_request_sequences["DUMMY_GRANT"] = 0
                if config.has_option(sec, "blocked_request_sequence"):
                    self.BLOCKED_REQUEST_SEQUENCE = config.get(
                        sec, "blocked_request_sequence"
                    ).split(",")
                    self.BLOCKED_REQUEST_SEQUENCE = [
                        int(i.strip(" ")) for i in self.BLOCKED_REQUEST_SEQUENCE
                    ]
                    self.log.debug(
                        "blocked_request_sequence is configged to %s"
                        % self.BLOCKED_REQUEST_SEQUENCE
                    )
            if config.has_option(sec, "force_sas_method_group"):
                force_sas_method_group = config.get(sec, "force_sas_method_group")

                self.log.debug(
                    "force_sas_method_group are configged to %s "
                    % force_sas_method_group
                )
                force_sas_method_group_keys = force_sas_method_group.split(";")
                for force_sas_method_key in force_sas_method_group_keys:
                    if force_sas_method_key.find("True") != -1:
                        location = force_sas_method_key.find("True")
                        force_sas_method_key = force_sas_method_key[0: (location - 1)]
                    elif force_sas_method_key.find("False") != -1:
                        location = force_sas_method_key.find("False")
                        force_sas_method_key = force_sas_method_key[0: (location - 1)]
                    self.log.debug("cut to %s " % force_sas_method_key)
                    self.force_sas_method_group.append(force_sas_method_key)
                    force_sas_method = force_sas_method_key.split(",")
                    force_sas_method_id = (
                        str(force_sas_method[0]) + "_" + str(force_sas_method[1])
                    )
                    self.log.debug(
                        "force_sas_method_id for force_sas_method_group  is configged to %s"
                        % force_sas_method_id
                    )
                    self.force_sas_method_group_sequences[force_sas_method_id] = 0
                    self.log.debug(
                        "self.force_sas_method_group to %s "
                        % self.force_sas_method_group
                    )
                    self.log.debug(
                        "self.force_sas_method_group_sequences to %s "
                        % self.force_sas_method_group_sequences
                    )
            if config.has_option(sec, "force_max_eirp_group"):
                force_max_eirp_group = config.get(sec, "force_max_eirp_group")
                self.log.debug(
                    "force_max_eirp_group are configged to %s " % force_max_eirp_group
                )
                force_max_eirp_group_keys = force_max_eirp_group.split(";")
                for force_max_eirp_key in force_max_eirp_group_keys:
                    self.force_max_eirp_group.append(force_max_eirp_key)
                    force_max_eirp = force_max_eirp_key.split(",")
                    force_max_eirp_id = str(force_max_eirp[0])
                    self.log.debug(
                        "force_max_eirp_id for force_max_eirp_group is configged to %s"
                        % force_max_eirp_id
                    )
                    self.force_max_eirp_group_sequences[force_max_eirp_id] = 0
            if config.has_option(sec, "force_sas_method"):
                method = config.get(sec, "force_sas_method")
                if method in sas_method_t:
                    self.SAS_METHOD_FORCE = method
                    self.log.debug(
                        "force_sas_method is configged to %s" % self.SAS_METHOD_FORCE
                    )
                    if config.has_option(sec, "force_sas_method_grantids") and (
                        method == METHOD_GRANT
                        or method == METHOD_HEARTBEAT
                        or method == METHOD_RELINQUISH
                    ):
                        self.SAS_METHOD_FORCE_GRANTIDS = config.get(
                            sec, "force_sas_method_grantids"
                        )
                        self.log.debug(
                            "force_sas_method_grantids is configged to %s"
                            % self.SAS_METHOD_FORCE_GRANTIDS
                        )
                        if self.SAS_METHOD_FORCE_GRANTIDS is not None:
                            grantids = self.SAS_METHOD_FORCE_GRANTIDS.split(",")
                            for grantid in grantids:
                                self.force_sas_method_sequences[grantid] = 0
                    else:
                        self.force_sas_method_sequences["DUMMY_GRANT"] = 0
                        self.force_sas_method_sequences["DUMMY_INQUIRY"] = 0
                    if config.has_option(sec, "force_sas_method_sequence"):
                        self.SAS_METHOD_FORCE_SEQUENCE = config.getint(
                            sec, "force_sas_method_sequence"
                        )
                        self.log.debug(
                            "force_sas_method_sequence is configged to %d"
                            % self.SAS_METHOD_FORCE_SEQUENCE
                        )
                    if config.has_option(sec, "force_response_code"):
                        self.RESPONSE_CODE_FORCE = config.getint(
                            sec, "force_response_code"
                        )
                        self.log.debug(
                            "force_response_code is configged to %d"
                            % self.RESPONSE_CODE_FORCE
                        )
                    if config.has_option(sec, "force_response_switch_dp"):
                        self.RESPONSE_SWITCH_DP = config.getboolean(
                            sec, "force_response_switch_dp"
                        )
                        self.log.debug(
                            "force_response_switch_dp is configged to %s"
                            % self.RESPONSE_SWITCH_DP
                        )
                    if config.has_option(sec, "force_response_data"):
                        self.RESPONSE_DATA_FORCE = config.get(
                            sec, "force_response_data"
                        )
                        self.log.debug(
                            "force_response_data is configged to %s"
                            % self.RESPONSE_DATA_FORCE
                        )
                    if config.has_option(
                        sec, "force_response_featureDataExchangeConfig"
                    ):
                        try:
                            self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = (
                                config.getint(
                                    sec, "force_response_featureDataExchangeConfig"
                                )
                            )
                            self.log.debug(
                                "force_response_featureDataExchangeConfig is configged to %d"
                                % self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                            )
                        except BaseException:
                            self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
                            self.log.debug(
                                "catch error: force_response_featureDataExchangeConfig is configged to %d"
                                % self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                            )
                    else:
                        self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
                        self.log.debug(
                            "use the default value: force_response_featureDataExchangeConfig is configged to %d"
                            % self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                        )
                    if config.has_option(sec, "force_exclude_param"):
                        self.EXCLUDE_PARAM_FORCE = config.get(
                            sec, "force_exclude_param"
                        )
                        self.log.debug(
                            "force_exclude_param is configged to %s"
                            % self.EXCLUDE_PARAM_FORCE
                        )
                    if config.has_option(sec, "force_update_param"):
                        self.UPDATE_PARAM_FORCE = config.get(sec, "force_update_param")
                        self.log.debug(
                            "force_update_param is configged to %s"
                            % self.UPDATE_PARAM_FORCE
                        )
                        if config.has_option(sec, "force_update_param_data"):
                            self.UPDATE_PARAM_DATA_FORCE = config.get(
                                sec, "force_update_param_data"
                            )
                            self.log.debug(
                                "force_update_param_data is configged to %s"
                                % self.UPDATE_PARAM_DATA_FORCE
                            )
                    if config.has_option(sec, "force_http_response_code"):
                        self.HTTP_RESPONSE_CODE_FORCE = config.getint(
                            sec, "force_http_response_code"
                        )
                        self.log.debug(
                            "force_http_response_code is configged to %d"
                            % self.HTTP_RESPONSE_CODE_FORCE
                        )
                    if config.has_option(sec, "force_http_response_sequences"):
                        force_http_response_sequences = config.get(
                            sec, "force_http_response_sequences"
                        )
                        self.log.debug(
                            "force_http_response_sequences is configured to {}".format(
                                force_http_response_sequences
                            )
                        )
                        force_http_response_sequences_content = (
                            force_http_response_sequences.split(",")
                        )
                        self.HTTP_RESPONSE_SEQUENCES = [
                            int(seq) for seq in force_http_response_sequences_content
                        ]
                    if config.has_option(sec, "reject_subsequent_connection"):
                        self.SUBSEQUENT_CONN_REJECT = config.getboolean(
                            sec, "reject_subsequent_connection"
                        )
                        self.log.debug(
                            "reject_subsequent_connection is configged to %s"
                            % self.SUBSEQUENT_CONN_REJECT
                        )
                    if config.has_option(sec, "force_max_eirp"):
                        try:
                            self.MAX_EIRP_FORCE = config.getint(sec, "force_max_eirp")
                            self.log.debug(
                                "force_max_eirp is configged to %d"
                                % self.MAX_EIRP_FORCE
                            )
                        except BaseException:
                            self.MAX_EIRP_FORCE = config.getfloat(sec, "force_max_eirp")
                            self.log.debug(
                                "force_max_eirp is configged to %f"
                                % self.MAX_EIRP_FORCE
                            )
                    if config.has_option(sec, "force_response_dereg_immediately"):
                        self.FORCE_RESPONSE_DEREG_IMMEDIATELY = config.getboolean(
                            sec, "force_response_dereg_immediately"
                        )
                        self.log.debug(
                            "force_response_dereg_immediately is configged to %s"
                            % self.FORCE_RESPONSE_DEREG_IMMEDIATELY
                        )
                else:
                    self.log.warning("invalid config value for force_sas_method")
            if config.has_option(sec, "chunked"):
                self.CHUNKED = config.getboolean(sec, "chunked")
                self.log.debug("chunked encoding is configured to %s" % self.CHUNKED)
                if config.has_option(sec, "chunksize"):
                    self.CHUNKSIZE = config.getint(sec, "chunksize")
                    self.log.debug("chunk size is configured to %d" % self.CHUNKSIZE)
                else:
                    self.CHUNKSIZE = 40
                    self.log.debug(
                        "chunk size is configured to default of %d" % self.CHUNKSIZE
                    )
            if config.has_option(sec, "force_response_group"):
                force_response_group = config.get(sec, "force_response_group")
                self.log.debug(
                    "force_response_group are configged to %s " % force_response_group
                )
                force_response_group_keys = force_response_group.split(";")
                for force_response_group_key in force_response_group_keys:
                    self.force_response_group.append(force_response_group_key)
                    forceResponseMember = force_response_group_key.split(",")
                    forceResponseMemberID = (
                        str(forceResponseMember[0]) + "-" + str(forceResponseMember[2])
                    )
                    self.log.debug(
                        "forceResponseMemberID for force_response_group  is configged to %s"
                        % forceResponseMemberID
                    )
                    self.force_response_group_sequences[forceResponseMemberID] = 0
            if config.has_option(sec, "spectrumInquery_times"):
                self.spectrumInquery_times = config.getint(sec, "spectrumInquery_times")
                self.log.debug(
                    "spectrumInquery_times is configured to %d"
                    % self.spectrumInquery_times
                )
            if config.has_option(sec, "force_spectrumInquery_response"):
                force_spectrumInquery_response = config.get(
                    sec, "force_spectrumInquery_response"
                )
                force_spectrumInquery_response_items = (
                    force_spectrumInquery_response.split(";")
                )
                self.log.debug(
                    "force_spectrumInquery_response is configured to %s"
                    % force_spectrumInquery_response
                )
                force_spectrumInquery_response_group_from_config = {}
                for (
                    force_spectrumInquery_response_item
                ) in force_spectrumInquery_response_items:
                    parent_list = []
                    child_list = []
                    item = force_spectrumInquery_response_item.split(":")
                    available_spectrum_resp = item[1].split(",")
                    child_list.append(int(available_spectrum_resp[0]))
                    child_list.append(int(available_spectrum_resp[1]))
                    parent_list.append(child_list)
                    isPAL = (
                        True if available_spectrum_resp[2].lower() == "true" else False
                    )
                    parent_list.append(isPAL)
                    parent_list.append(available_spectrum_resp[3])
                    try:
                        parent_list.append(int(available_spectrum_resp[4]))
                    except BaseException:
                        parent_list.append(float(available_spectrum_resp[4]))
                    force_spectrumInquery_response_group_from_config[
                        item[0]
                    ] = parent_list
                self.force_spectrumInquery_response_group = self.convertSpectrum(
                    force_spectrumInquery_response_group_from_config, self.VERSION
                )

            if config.has_option(sec, "cbrsaVersion"):
                self.cbrsaVersion = config.get(sec, "cbrsaVersion")
                self.log.debug("cbrsaVersion is %s" % self.cbrsaVersion)
            if config.has_option(sec, "eutra_tdd_config"):
                self.eutraTddConfig = config.get(sec, "eutra_tdd_config")
                self.log.debug(
                    "eutra_tdd_config is configured: %s" % self.eutraTddConfig
                )
            if config.has_option(sec, "force_method_cbrsa_version_group"):
                force_method_cbrsa_version_group = config.get(
                    sec, "force_method_cbrsa_version_group"
                )
                self.log.debug(
                    "force_method_cbrsa_version_group is configured: {}".format(
                        force_method_cbrsa_version_group
                    )
                )
                force_method_cbrsa_version_group_items = (
                    force_method_cbrsa_version_group.split(";")
                )
                for (
                    force_method_cbrsa_version_group_item
                ) in force_method_cbrsa_version_group_items:
                    force_method_cbrsa_version_group_content = (
                        force_method_cbrsa_version_group_item.split(",")
                    )
                    force_method_cbrsa_version_group_method = (
                        force_method_cbrsa_version_group_content[0]
                    )
                    force_method_cbrsa_version_group_seq = (
                        force_method_cbrsa_version_group_content[1]
                    )
                    force_method_cbrsa_version_group_value = (
                        force_method_cbrsa_version_group_content[2]
                    )
                    force_method_cbrsa_version_group_key = (
                        force_method_cbrsa_version_group_method
                        + "_"
                        + force_method_cbrsa_version_group_seq
                    )
                    self.force_method_cbrsa_version_group[
                        force_method_cbrsa_version_group_key
                    ] = force_method_cbrsa_version_group_value

            if config.has_option(sec, "force_method_eutra_tdd_config_group"):
                force_method_eutra_tdd_config_group = config.get(
                    sec, "force_method_eutra_tdd_config_group"
                )
                self.log.debug(
                    "force_method_eutra_tdd_config_group is configured: {}".format(
                        force_method_eutra_tdd_config_group
                    )
                )
                force_method_eutra_tdd_config_group_items = (
                    force_method_eutra_tdd_config_group.split(";")
                )
                for (
                    force_method_eutra_tdd_config_group_item
                ) in force_method_eutra_tdd_config_group_items:
                    force_method_eutra_tdd_config_group_content = (
                        force_method_eutra_tdd_config_group_item.split(",")
                    )
                    force_method_eutra_tdd_config_group_method = (
                        force_method_eutra_tdd_config_group_content[0]
                    )
                    force_method_eutra_tdd_config_group_seq = (
                        force_method_eutra_tdd_config_group_content[1]
                    )
                    force_method_eutra_tdd_config_group_value = (
                        force_method_eutra_tdd_config_group_content[2:]
                    )
                    force_method_eutra_tdd_config_group_key = (
                        force_method_eutra_tdd_config_group_method
                        + "_"
                        + force_method_eutra_tdd_config_group_seq
                    )
                    self.force_method_eutra_tdd_config_group[
                        force_method_eutra_tdd_config_group_key
                    ] = force_method_eutra_tdd_config_group_value

            if config.has_option(sec, "cbsd_frequency_guidance"):
                self.cbsdFrequencyGuidance = config.get(sec, "cbsd_frequency_guidance")
                self.log.debug(
                    "cbsd_frequency_guidance is configured: %s"
                    % self.cbsdFrequencyGuidance
                )
            if config.has_option(sec, "force_registration_method_group"):
                force_registration_method_group = config.get(
                    sec, "force_registration_method_group"
                )
                self.log.debug(
                    "force_registration_method_group are configged to %s "
                    % force_registration_method_group
                )
                force_registration_method_group_keys = (
                    force_registration_method_group.split(";")
                )
                for (
                    force_registration_method_key
                ) in force_registration_method_group_keys:
                    force_registration_content = force_registration_method_key.split(
                        ","
                    )
                    force_registration_sequence = force_registration_content[0]
                    force_registration_error_code = force_registration_content[1]
                    self.log.debug(
                        "force_registration_sequence for force_registration_method_group  is configged to %s"
                        % force_registration_sequence
                    )
                    self.log.debug(
                        "force_registration_error_code for force_registration_method_group  is configged to %s"
                        % force_registration_error_code
                    )
                    self.force_registration_method_group_sequences_error_code[
                        force_registration_sequence
                    ] = int(force_registration_error_code)

            if config.has_option(sec, "cbrsaVersion_change_sequence"):
                cbrsaVersion = config.get(sec, "cbrsaVersion_change_sequence")
                spiltCbrsaVersion = cbrsaVersion.split(",")
                self.cbrsaVersion_change_times.append(int(spiltCbrsaVersion[0]))
                self.cbrsaVersion_change_times.append(spiltCbrsaVersion[1])
                self.log.debug(
                    "self.cbrsaVersion_change_times is configured to %s"
                    % self.cbrsaVersion_change_times
                )

            if config.has_option(sec, "eutraTddConfig_change_sequence"):
                eutraTddConfig = config.get(sec, "eutraTddConfig_change_sequence")
                spiltEutraTddConfig = eutraTddConfig.split(",")
                self.eutraTddConfig_change_times.append(int(spiltEutraTddConfig[0]))
                self.eutraTddConfig_change_times.append(int(spiltEutraTddConfig[1]))
                self.eutraTddConfig_change_times.append(int(spiltEutraTddConfig[2]))
                self.log.debug(
                    "self.eutraTddConfig_change_times is configured to %s"
                    % self.eutraTddConfig_change_times
                )

            if config.has_option(sec, "force_spectrumInquiry_method_group"):
                force_spectrumInquiry_method_group = config.get(
                    sec, "force_spectrumInquiry_method_group"
                )
                self.log.debug(
                    "force_spectrumInquiry_method_group are configged to %s "
                    % force_spectrumInquiry_method_group
                )
                force_spectrumInquiry_method_group_keys = (
                    force_spectrumInquiry_method_group.split(";")
                )
                for (
                    force_spectrumInquiry_method_key
                ) in force_spectrumInquiry_method_group_keys:
                    self.force_spectrumInquiry_method_group.append(
                        force_spectrumInquiry_method_key
                    )
                    force_spectrumInquiry_content = (
                        force_spectrumInquiry_method_key.split(",")
                    )
                    force_spectrumInquiry_sequence = force_spectrumInquiry_content[0]
                    force_spectrumInquiry_error_code = force_spectrumInquiry_content[1]
                    self.force_spectrumInquiry_method_force_data.append(
                        force_spectrumInquiry_content[2]
                    )
                    self.log.debug(
                        "self.force_spectrumInquiry_method_force_data: %s"
                        % self.force_spectrumInquiry_method_force_data
                    )
                    self.log.debug(
                        "force_spectrumInquiry_sequence for force_spectrumInquiry_method_group  is configged to %s"
                        % force_spectrumInquiry_sequence
                    )
                    self.log.debug(
                        "force_spectrumInquiry_error_code for force_spectrumInquiry_method_group  is configged to %s"
                        % force_spectrumInquiry_error_code
                    )
                    self.force_spectrumInquiry_method_group_sequences_error_code[
                        force_spectrumInquiry_sequence
                    ] = force_spectrumInquiry_error_code
            if config.has_option(sec, "sas_feature_capability_list"):
                sas_feature_capability = config.get(sec, "sas_feature_capability_list")
                self.log.debug(
                    "sas_feature_capability is configured to {}".format(
                        sas_feature_capability
                    )
                )
                self.SAS_FEATURE_CAPABILITY_LIST = sas_feature_capability.split(",")
                if config.has_option(sec, "sas_feature_capability_clear"):
                    sas_feature_capability_clear = config.get(
                        sec, "sas_feature_capability_clear"
                    )
                    self.sas_feature_capability_sequence = int(
                        sas_feature_capability_clear.split(",")[0]
                    )
                    self.sas_feature_capability_exist = (
                        str(True) == sas_feature_capability_clear.split(",")[1]
                    )

            if config.has_option(sec, "force_sas_feature_capability_list_group"):
                force_sas_feature_capability_list_group = config.get(
                    sec, "force_sas_feature_capability_list_group"
                )
                force_sas_feature_capability_list_group_items = (
                    force_sas_feature_capability_list_group.split(";")
                )
                for (
                    force_sas_feature_capability_list_group_item
                ) in force_sas_feature_capability_list_group_items:
                    force_sas_feature_capability_list_group_content = (
                        force_sas_feature_capability_list_group_item.split(",")
                    )
                    force_sas_feature_capability_list_group_method = (
                        force_sas_feature_capability_list_group_content[0]
                    )
                    force_sas_feature_capability_list_group_seq = (
                        force_sas_feature_capability_list_group_content[1]
                    )
                    if len(force_sas_feature_capability_list_group_content) >= 3:
                        force_sas_feature_capability_list_group_capability_list = (
                            force_sas_feature_capability_list_group_content[2:]
                        )
                        if (
                            len(force_sas_feature_capability_list_group_capability_list)
                            == 1
                            and force_sas_feature_capability_list_group_capability_list[
                                0
                            ]
                            == ""
                        ):
                            force_sas_feature_capability_list_group_capability_list = []
                    else:
                        force_sas_feature_capability_list_group_capability_list = None
                    force_sas_feature_capability_list_group_key = (
                        force_sas_feature_capability_list_group_method
                        + "_"
                        + force_sas_feature_capability_list_group_seq
                    )
                    self.force_sas_feature_capability_list_group[
                        force_sas_feature_capability_list_group_key
                    ] = force_sas_feature_capability_list_group_capability_list
                self.log.info(
                    "force_sas_feature_capability_list_group: {}".format(
                        self.force_sas_feature_capability_list_group
                    )
                )

            if config.has_option(sec, "force_deregistration_method_group"):
                force_deregistration_method_group = config.get(
                    sec, "force_deregistration_method_group"
                )
                self.log.debug(
                    "force_deregistration_method_group are configged to %s "
                    % force_deregistration_method_group
                )
                force_deregistration_method_group_keys = (
                    force_deregistration_method_group.split(";")
                )
                for (
                    force_deregistration_method_key
                ) in force_deregistration_method_group_keys:
                    force_deregistration_content = (
                        force_deregistration_method_key.split(",")
                    )
                    force_deregistration_sequence = int(force_deregistration_content[0])
                    force_deregistration_error_code = force_deregistration_content[1]
                    force_deregistration_data_force = force_deregistration_content[2]
                    self.force_deregistration_method_group.append(
                        force_deregistration_sequence
                    )
                    self.force_deregistration_method_group.append(
                        force_deregistration_error_code
                    )
                    self.force_deregistration_method_group.append(
                        force_deregistration_data_force
                    )
                self.log.debug(
                    "self.force_deregistration_method_group are configged to %s "
                    % self.force_deregistration_method_group
                )

            if config.has_option(sec, "sas_sleeptime_sequence") and config.has_option(
                sec, "sas_sleep_time"
            ):
                strlist = config.get(sec, "sas_sleeptime_sequence").split(",")
                self.sleeptime_sequence = list(map(int, strlist))
                self.sleep_time = config.getint(sec, "sas_sleep_time")
                self.log.debug(
                    "self.sleeptime_sequence are configged to %s "
                    % self.sleeptime_sequence
                )
                self.log.debug("self.sleep_time are configged to %s " % self.sleep_time)

            if config.has_option(sec, "force_sas_method_resp_sequence"):
                self.force_sas_method_resp_sequence = config.get(
                    sec, "force_sas_method_resp_sequence"
                ).split(",")
                self.force_sas_method_resp_sequence = [
                    int(i) for i in self.force_sas_method_resp_sequence
                ]
                self.log.debug(
                    "self.force_sas_method_resp_sequence are configged to %s "
                    % self.force_sas_method_resp_sequence
                )

            if config.has_option(sec, "multiple_msg_block_group"):
                self.multiple_msg_block_group = config.get(
                    sec, "multiple_msg_block_group"
                )
                self.log.warning(
                    "self.multiple_msg_block_group are configged to %s "
                    % self.multiple_msg_block_group
                )

                def method_filter(item):
                    self.multiple_msg_block_group_dict[item.split(",")[0]] = [
                        int(i.strip(" ")) for i in item.split(",")[1:]
                    ]

                list(
                    map(
                        method_filter,
                        [item for item in self.multiple_msg_block_group.split(";")],
                    )
                )
                self.log.warning(
                    "self.multiple_msg_block_group_dict are configged to %s "
                    % self.multiple_msg_block_group_dict
                )

            if config.has_option(sec, "force_method_feature_exchange_trigger_group"):
                force_method_feature_exchange_trigger_group = config.get(
                    sec, "force_method_feature_exchange_trigger_group"
                )
                self.log.debug(
                    "force_method_feature_exchange_trigger_group is configured to {}".format(
                        force_method_feature_exchange_trigger_group
                    )
                )
                force_method_feature_exchange_trigger_group_item = (
                    force_method_feature_exchange_trigger_group.split(";")
                )
                for trigger_item in force_method_feature_exchange_trigger_group_item:
                    trigger_content = trigger_item.split(",")
                    trigger_method_key = trigger_content[0]
                    trigger_method_and_prefix = trigger_method_key.split("-")
                    trigger_method = trigger_method_key
                    if len(trigger_method_and_prefix) >= 2:
                        trigger_method = trigger_method_and_prefix[1]
                    if (
                        trigger_method
                        not in sas_method_contain_feature_exchange_trigger_t
                    ):
                        self.log.warning(
                            "invalid method_key: %s for force_method_feature_exchange_trigger_group"
                            % trigger_method_key
                        )
                        continue
                    trigger_sequence = [int(seq) for seq in trigger_content[1:]]
                    self.force_method_feature_exchange_trigger_group[
                        trigger_method_key
                    ] = trigger_sequence

            if config.has_option(
                sec, "force_method_grouping_config_group_type_group_id_supported_by_sas"
            ):
                force_method_grouping_config_group_type_group_id_supported_by_sas_str = config.get(
                    sec,
                    "force_method_grouping_config_group_type_group_id_supported_by_sas",
                )
                self.log.debug(
                    "force_method_grouping_config_group_type_group_id_supported_by_sas is configured to {}".format(
                        force_method_grouping_config_group_type_group_id_supported_by_sas_str
                    )
                )
                force_method_grouping_config_group_type_group_id_supported_by_sas_items = \
                    force_method_grouping_config_group_type_group_id_supported_by_sas_str.split(";")

                for force_method_grouping_config_group_type_group_id_supported_by_sas_item in \
                        force_method_grouping_config_group_type_group_id_supported_by_sas_items:

                    force_method_grouping_config_group_type_group_id_supported_by_sas_content = \
                        force_method_grouping_config_group_type_group_id_supported_by_sas_item.split(",")

                    force_method_grouping_config_group_type_group_id_supported_by_sas_key = \
                        force_method_grouping_config_group_type_group_id_supported_by_sas_content[0]

                    force_method_grouping_config_group_type_group_id_supported_by_sas_seq = \
                        force_method_grouping_config_group_type_group_id_supported_by_sas_content[1]

                    force_method_grouping_config_group_type_value = \
                        force_method_grouping_config_group_type_group_id_supported_by_sas_content[2]

                    force_method_grouping_config_group_id_value = \
                        force_method_grouping_config_group_type_group_id_supported_by_sas_content[3]

                    force_method_grouping_config_support_by_sas_value = (
                        force_method_grouping_config_group_type_group_id_supported_by_sas_content[4].lower()
                        == "true")

                    key = (
                        force_method_grouping_config_group_type_group_id_supported_by_sas_key
                        + "_"
                        + force_method_grouping_config_group_type_group_id_supported_by_sas_seq
                    )
                    value = (
                        force_method_grouping_config_group_type_value,
                        force_method_grouping_config_group_id_value,
                        force_method_grouping_config_support_by_sas_value,
                    )
                    self.force_method_grouping_config_group_type_group_id_supported_by_sas[
                        key
                    ] = value

            if config.has_option(sec, "recommend_operationParam_heartbeat0"):
                recommend_operationParam_heartbeat0 = config.get(
                    sec, "recommend_operationParam_heartbeat0"
                )
                self.log.debug(
                    "recommend_operationParam_heartbeat0 is configured to {}".format(
                        recommend_operationParam_heartbeat0
                    )
                )
                recommend_operationParam_heartbeat0_items = (
                    recommend_operationParam_heartbeat0.split(";")
                )
                for (
                    recommend_operationParam_heartbeat0_item
                ) in recommend_operationParam_heartbeat0_items:
                    recommend_operationParam_heartbeat0_content = (
                        recommend_operationParam_heartbeat0_item.split(",")
                    )
                    force_heartbeat_grant_id = (
                        recommend_operationParam_heartbeat0_content[0]
                    )
                    force_heartbeat_seq = recommend_operationParam_heartbeat0_content[1]
                    force_heartbeat_maxeirp = float(
                        recommend_operationParam_heartbeat0_content[2]
                    )
                    force_heartbeat_lowfreq = int(
                        recommend_operationParam_heartbeat0_content[3]
                    )
                    force_heartbeat_highfreq = int(
                        recommend_operationParam_heartbeat0_content[4]
                    )
                    force_heartbeat_key = (
                        force_heartbeat_grant_id + "_" + force_heartbeat_seq
                    )
                    self.recommend_operationParam_heartbeat0[force_heartbeat_key] = (
                        force_heartbeat_maxeirp,
                        force_heartbeat_lowfreq,
                        force_heartbeat_highfreq,
                    )

            if config.has_option(sec, "force_heartbeat_channeltype_group"):
                force_heartbeat_channeltype_group = config.get(
                    sec, "force_heartbeat_channeltype_group"
                )
                self.log.debug(
                    "force_heartbeat_channeltype_group is configured to {}".format(
                        force_heartbeat_channeltype_group
                    )
                )
                force_heartbeat_channeltype_group_items = (
                    force_heartbeat_channeltype_group.split(";")
                )
                for (
                    force_heartbeat_channeltype_group_item
                ) in force_heartbeat_channeltype_group_items:
                    force_heartbeat_channeltype_group_content = (
                        force_heartbeat_channeltype_group_item.split(",")
                    )
                    force_heartbeat_grant_id = (
                        force_heartbeat_channeltype_group_content[0]
                    )
                    force_heartbeat_seq = force_heartbeat_channeltype_group_content[1]
                    force_heartbeat_is_pal = (
                        force_heartbeat_channeltype_group_content[2].lower() == "true"
                    )
                    force_heartbeat_key = (
                        force_heartbeat_grant_id + "_" + force_heartbeat_seq
                    )
                    self.force_heartbeat_channeltype_group[
                        force_heartbeat_key
                    ] = force_heartbeat_is_pal

        except configparser.MissingSectionHeaderError:
            self.log.error(
                "missing section header in config file. using default configuration."
            )
        except configparser.Error:
            self.log.error("parsing config file failed. using default configuration.")
        except ValueError:
            self.log.error(
                "parsing config file failed. could not convert data to a specified type."
            )
        except BaseException:
            self.log.error("parsing config file failed. unexcept error.")

    def getCbsdSpecificConfig(self, cbsdid):
        config = configparser.ConfigParser()
        conPath = self.config_file
        config.read(conPath)
        # self.SAS_METHOD_FORCE = SAS_METHOD_FORCE
        # self.SAS_METHOD_FORCE_SEQUENCE = SAS_METHOD_FORCE_SEQUENCE
        # self.RESPONSE_CODE_FORCE = RESPONSE_CODE_FORCE
        # self.RESPONSE_DATA_FORCE = RESPONSE_DATA_FORCE
        # self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
        # self.EXCLUDE_PARAM_FORCE = EXCLUDE_PARAM_FORCE
        # self.UPDATE_PARAM_FORCE = UPDATE_PARAM_FORCE
        # self.UPDATE_PARAM_DATA_FORCE = UPDATE_PARAM_DATA_FORCE
        # self.HTTP_RESPONSE_CODE_FORCE = HTTP_RESPONSE_CODE_FORCE
        # self.SUBSEQUENT_CONN_REJECT = SUBSEQUENT_CONN_REJECT
        # self.spectrum_table = spectrum_table
        # self.CONNECTION_REJECT = CONNECTION_REJECT
        # self.force_sas_method_sequence = 0

        if config.has_section(cbsdid):
            self.log.info("cbsdId section present")
            if config.has_option(cbsdid, "blocked_request"):
                req = config.get(cbsdid, "blocked_request")
                if req in sas_method_t:
                    self.BLOCKED_REQUEST = req
                    self.log.debug(
                        "blocked_request is configged to %s for cbsdid %s"
                        % (self.BLOCKED_REQUEST, cbsdid)
                    )
                else:
                    self.log.warning("invalid config value for blocked_request")
            if config.has_option(cbsdid, "blocked_request_sequence"):
                self.BLOCKED_REQUEST_SEQUENCE = config.get(
                    cbsdid, "blocked_request_sequence"
                ).split(",")
                self.BLOCKED_REQUEST_SEQUENCE = [
                    int(i) for i in self.BLOCKED_REQUEST_SEQUENCE
                ]
                self.log.debug(
                    "blocked_request_sequence is configged to %s"
                    % self.BLOCKED_REQUEST_SEQUENCE
                )

            if config.has_option(cbsdid, "force_sas_method"):
                method = config.get(cbsdid, "force_sas_method")
                if method in sas_method_t:
                    self.SAS_METHOD_FORCE = method
                    self.log.debug(
                        "force_sas_method is configged to %s for cbsdid %s"
                        % self.SAS_METHOD_FORCE
                    )
                    if config.has_option(cbsdid, "force_sas_method_sequence"):
                        self.SAS_METHOD_FORCE_SEQUENCE = config.getint(
                            cbsdid, "force_sas_method_sequence"
                        )
                        self.log.debug(
                            "force_sas_method_sequence is configged to %d"
                            % self.SAS_METHOD_FORCE_SEQUENCE
                        )
                    if config.has_option(cbsdid, "force_response_code"):
                        self.RESPONSE_CODE_FORCE = config.getint(
                            cbsdid, "force_response_code"
                        )
                        self.log.debug(
                            "force_response_code is configged to %d"
                            % self.RESPONSE_CODE_FORCE
                        )
                    if config.has_option(cbsdid, "force_response_switch_dp"):
                        self.RESPONSE_SWITCH_DP = config.getboolean(
                            cbsdid, "force_response_switch_dp"
                        )
                        self.log.debug(
                            "force_response_switch_dp is configged to %s"
                            % self.RESPONSE_SWITCH_DP
                        )
                    if config.has_option(cbsdid, "force_response_data"):
                        self.RESPONSE_DATA_FORCE = config.get(
                            cbsdid, "force_response_data"
                        )
                        self.log.debug(
                            "force_response_data is configged to %s"
                            % self.RESPONSE_DATA_FORCE
                        )
                    if config.has_option(
                        cbsdid, "force_response_featureDataExchangeConfig"
                    ):
                        try:
                            self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = (
                                config.getint(
                                    cbsdid, "force_response_featureDataExchangeConfig"
                                )
                            )
                            self.log.debug(
                                "force_response_featureDataExchangeConfig is configged to %d"
                                % self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                            )
                        except BaseException:
                            self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
                            self.log.debug(
                                "catch error: force_response_featureDataExchangeConfig is configged to %d"
                                % self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                            )
                    else:
                        self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE = -1
                        self.log.debug(
                            "use the default value: force_response_featureDataExchangeConfig is configged to %d"
                            % self.RESPONSE_FEATUREDATAEXCHANGECONFIG_FORCE
                        )
                    if config.has_option(cbsdid, "force_exclude_param"):
                        self.EXCLUDE_PARAM_FORCE = config.get(
                            cbsdid, "force_exclude_param"
                        )
                        self.log.debug(
                            "force_exclude_param is configged to %s"
                            % self.EXCLUDE_PARAM_FORCE
                        )
                    if config.has_option(cbsdid, "force_update_param"):
                        self.UPDATE_PARAM_FORCE = config.get(
                            cbsdid, "force_update_param"
                        )
                        self.log.debug(
                            "force_update_param is configged to %s"
                            % self.UPDATE_PARAM_FORCE
                        )
                        if config.has_option(cbsdid, "force_update_param_data"):
                            self.UPDATE_PARAM_DATA_FORCE = config.get(
                                cbsdid, "force_update_param_data"
                            )
                            self.log.debug(
                                "force_update_param_data is configged to %s"
                                % self.UPDATE_PARAM_DATA_FORCE
                            )
                    if config.has_option(cbsdid, "force_http_response_code"):
                        self.HTTP_RESPONSE_CODE_FORCE = config.getint(
                            cbsdid, "force_http_response_code"
                        )
                        self.log.debug(
                            "force_http_response_code is configged to %d"
                            % self.HTTP_RESPONSE_CODE_FORCE
                        )
                    if config.has_option(cbsdid, "force_http_response_sequences"):
                        force_http_response_sequences = config.get(
                            cbsdid, "force_http_response_sequences"
                        )
                        self.log.debug(
                            "force_http_response_sequences is configured to {}".format(
                                force_http_response_sequences
                            )
                        )
                        force_http_response_sequences_content = (
                            force_http_response_sequences.split(",")
                        )
                        self.HTTP_RESPONSE_SEQUENCES = [
                            int(seq) for seq in force_http_response_sequences_content
                        ]
                    if config.has_option(cbsdid, "reject_subsequent_connection"):
                        self.SUBSEQUENT_CONN_REJECT = config.getboolean(
                            cbsdid, "reject_subsequent_connection"
                        )
                        self.log.debug(
                            "reject_subsequent_connection is configged to %s"
                            % self.SUBSEQUENT_CONN_REJECT
                        )
                    if config.has_option(cbsdid, "force_max_eirp"):
                        try:
                            self.MAX_EIRP_FORCE = config.getint(
                                cbsdid, "force_max_eirp"
                            )
                            self.log.debug(
                                "force_max_eirp is configged to %d"
                                % self.MAX_EIRP_FORCE
                            )
                        except BaseException:
                            self.MAX_EIRP_FORCE = config.getfloat(
                                cbsdid, "force_max_eirp"
                            )
                            self.log.debug(
                                "force_max_eirp is configged to %f"
                                % self.MAX_EIRP_FORCE
                            )
                    if config.has_option(cbsdid, "force_response_dereg_immediately"):
                        self.FORCE_RESPONSE_DEREG_IMMEDIATELY = config.getboolean(
                            cbsdid, "force_response_dereg_immediately"
                        )
                        self.log.debug(
                            "force_response_dereg_immediately is configged to %s"
                            % self.FORCE_RESPONSE_DEREG_IMMEDIATELY
                        )
                else:
                    self.log.warning("invalid config value for force_sas_method")
            if config.has_option(cbsdid, "pal_reserved_channel"):
                pals = config.get(cbsdid, "pal_reserved_channel")
                self.log.debug("PAL reserved channels is configged to %s" % pals)
                pal_keys = pals.split(",")
                for pal_key in pal_keys:
                    self.log.debug("PAL %s is configged" % pal_key)
                    pal = int(pal_key)
                    pal_set = False
                    if 3550 <= pal <= 3640:
                        for chid in list(self.spectrum_table.keys()):
                            if pal * 1000000 == self.spectrum_table[chid][0][0]:
                                self.spectrum_table[chid][1] = True
                                self.spectrum_table[chid][2] = cbsdid
                                pal_set = True
                                break
                    if pal_set:
                        self.log.debug("PAL reserved channel is configged to %d" % pal)
                    else:
                        self.log.warning("invalid PAL reserved channel %d" % pal)
        self.log.info("Done retrieving values")
        # return cbsdConfig

    def convertSpectrum(self, spectrum_dict, spectrum_version):
        spectrum_dict_converted = {}
        for spectrum_table_key in spectrum_dict.keys():
            if (
                spectrum_table_key.endswith("-5")
                and spectrum_version in sas_version_1_t
            ):
                self.log.info("convert 5M to 10M for sas version 1.x")
                spectrum_table_key_item = spectrum_table_key.split("-")
                spectrum_start = int(spectrum_table_key_item[0])
                if spectrum_start % 10 == 0:
                    spectrum_table_key_high_5M = "{}-5".format(spectrum_start + 5)
                    if spectrum_table_key_high_5M not in spectrum_dict:
                        self.log.error(
                            "missing high 5M spectrum:{} for {}".format(
                                spectrum_start + 5, spectrum_start
                            )
                        )
                    else:
                        spectrum_table_value_low_5M = spectrum_dict[spectrum_table_key]
                        spectrum_table_value_high_5M = spectrum_dict[
                            spectrum_table_key_high_5M
                        ]
                        # check if (channelType,maxErip) from low_5m and
                        # high_5m is same
                        if (
                            spectrum_table_value_low_5M[1]
                            != spectrum_table_value_high_5M[1]
                        ):
                            self.log.error(
                                "channelType from low_5M[{}] and high_5M[{}] not same".format(
                                    spectrum_table_value_low_5M[1],
                                    spectrum_table_value_high_5M[1],
                                )
                            )
                            continue
                        if (
                            len(spectrum_table_value_low_5M) > 3
                            and len(spectrum_table_value_high_5M) > 3
                        ) and spectrum_table_value_low_5M[
                            3
                        ] != spectrum_table_value_high_5M[
                            3
                        ]:
                            self.log.error(
                                "eirp from low_5M[{}] and high_5M[{}] not same".format(
                                    spectrum_table_value_low_5M[3],
                                    spectrum_table_value_high_5M[3],
                                )
                            )
                            continue
                        spectrum_table_key_10M = "{}-10".format(spectrum_start)
                        self.log.info(
                            "merge spectrum {} into {}".format(
                                spectrum_start + 5, spectrum_start
                            )
                        )
                        spectrum_table_value_10M = copy.deepcopy(
                            spectrum_dict[spectrum_table_key]
                        )
                        spectrum_table_value_10M[0][1] += 5000000
                        spectrum_dict_converted[
                            spectrum_table_key_10M
                        ] = spectrum_table_value_10M
                else:
                    spectrum_table_key_10M = "{}-10".format(spectrum_start - 5)
                    if spectrum_table_key_10M not in spectrum_dict_converted:
                        self.log.error(
                            "incorrect spectrum: {} , need spectrum: {}".format(
                                spectrum_start, spectrum_start - 5
                            )
                        )
            elif (
                spectrum_table_key.endswith("-10")
                and spectrum_version in sas_version_2_t
            ):
                self.log.info("convert 10M to 5M for sas version 2.x")
                spectrum_table_key_item = spectrum_table_key.split("-")
                spectrum_start = int(spectrum_table_key_item[0])
                spectrum_table_key_low_5M = "{}-5".format(spectrum_start)
                spectrum_table_value_low_5M = copy.deepcopy(
                    spectrum_dict[spectrum_table_key]
                )
                spectrum_table_value_low_5M[0][1] -= 5000000
                self.log.info(
                    "spectrum_table_value_low_5M: {}".format(
                        spectrum_table_value_low_5M
                    )
                )
                spectrum_table_key_high_5M = "{}-5".format(spectrum_start + 5)
                spectrum_table_value_high_5M = copy.deepcopy(
                    spectrum_dict[spectrum_table_key]
                )
                spectrum_table_value_high_5M[0][0] += 5000000
                self.log.info(
                    "spectrum_table_value_high_5M: {}".format(
                        spectrum_table_value_high_5M
                    )
                )
                spectrum_dict_converted[
                    spectrum_table_key_low_5M
                ] = spectrum_table_value_low_5M
                spectrum_dict_converted[
                    spectrum_table_key_high_5M
                ] = spectrum_table_value_high_5M
            else:
                spectrum_dict_converted[spectrum_table_key] = spectrum_dict[
                    spectrum_table_key
                ]
        return spectrum_dict_converted


def create_ssl_context(log):
    def servername_callback(sock, req_hostname, cb_context, as_callback=True):
        """
        This is a callback function for the SSL Context manager, this is what does the real work of pulling the
        domain name in the original request.
        """
        log.info("Loading certs for hostname {}".format(req_hostname))

    context = ssl.create_default_context(ssl.Purpose.CLIENT_AUTH, cafile=config.CA_FILE)
    context.load_cert_chain(certfile=config.CERT_FILE, keyfile=config.KEY_FILE)
    context.options |= config.TLS_MODE
    if config.SNI_ENABLE:
        context.set_servername_callback(servername_callback)
    if config.MUTUAL_AUTH:
        context.verify_mode = ssl.CERT_REQUIRED
    return context


def receivedExpectHttpData(data):
    http_p = HttpRequestParser(data)
    if http_p.req_parse():
        header = http_p.get_header()
        if "Content-Length" not in header:
            return True
        contentLen = int(header["Content-Length"])
        if contentLen <= len(http_p.get_data()):
            return True
    return False


def sockReceive(socketfd):
    data = ""
    while True:
        data += socketfd.recv(SOCK_BUF_MAX)
        if len(data) == 0:
            break
        if receivedExpectHttpData(data.decode("utf-8")):
            break
    return data


def main_loop(config, logHandler):
    """
    create a listening socket and accept any connection request from client
    process the SAS request and reply with response message one by one
    """
    manager = CBSDManager(config, logHandler)
    log = logHandler
    messageSequency = 0
    if config.restore_registration is not None:
        req = "POST /v2.0/registration HTTP/1.1\r\n\r\n" + config.restore_registration
        log.info("regist req:\r\n%s" % req)
        manager.request_dispatcher(req)
        res = manager.response_builder()
        log.info("regist res:\r\n%s" % res)

        if config.restore_grant is not None:
            req = "POST /v2.0/grant HTTP/1.1\r\n\r\n" + config.restore_grant
            log.info("grant req:\r\n%s" % req)
            manager.request_dispatcher(req)
            res = manager.response_builder()
            log.info("grant res:\r\n%s" % res)

            if config.restore_heartbeat is not None:
                req = "POST /v2.0/heartbeat HTTP/1.1\r\n\r\n" + config.restore_heartbeat
                log.info("heartbeat req:\r\n%s" % req)
                manager.request_dispatcher(req)
                res = manager.response_builder()
                log.info("heartbeat res:\r\n%s" % res)
    try:
        # serversocket = None
        if not config.IPV6_ENABLE:
            serversocket = socket.socket()
        else:
            serversocket = socket.socket(socket.AF_INET6)
        # reuse a local socket in TIME_WAIT state
        serversocket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        # blocking mode
        serversocket.setblocking(1)
        serversocket.settimeout(5)
        serversocket.bind(("", config.PORT_NUM))
        serversocket.listen(UN_CONN_NUM)
        log.info("start listening on port %d" % config.PORT_NUM)
        socketslist = [serversocket]

        while config.CONNECTION_REJECT:
            log.warning("will reject any incoming connection...")
            sleeptime = 3600
            time.sleep(sleeptime)
        while True:
            try:
                readlist, writelist, exceptlist = select.select(
                    socketslist, socketslist, socketslist
                )
                for socketId in readlist:
                    if socketId is serversocket:
                        newsocket, fromaddr = serversocket.accept()
                        log.info(
                            "accepted new connection from %s:%s"
                            % (fromaddr[0], fromaddr[1])
                        )
                        # blocking mode for new socket
                        newsocket.setblocking(1)
                        newsocket.settimeout(5)
                        if config.CONNECT_MODE_TLS:
                            conn = create_ssl_context(log).wrap_socket(
                                newsocket, server_side=True
                            )
                            log.info("tls version %s used." % conn.version())
                            socketslist.append(conn)
                        else:
                            socketslist.append(newsocket)
                    else:
                        req = socketId.recv(SOCK_BUF_MAX)
                        log.debug(
                            "received data from %s:%s\r\n%s"
                            % (fromaddr[0], fromaddr[1], req.decode())
                        )

                        if config.drop_request_enable == 1:
                            time.sleep(config.drop_request_delay)
                            socketId.close()
                            socketslist.remove(socketId)
                            continue

                        if not req:
                            log.info("Peer closed this link!")
                            socketId.close()
                            socketslist.remove(socketId)
                        else:
                            manager.request_dispatcher(req.decode("utf-8"))
                            res = manager.response_builder()
                            if res is not None:
                                messageSequency += 1
                                resb = res.encode("utf-8")
                                if messageSequency in config.sleeptime_sequence:
                                    log.debug(
                                        "sleep message sequence: %s arrive, will sleep %ss"
                                        % (messageSequency, config.sleep_time)
                                    )
                                    time.sleep(config.sleep_time)
                                log.debug(
                                    "sent data to %s:%s\r\n%s"
                                    % (fromaddr[0], fromaddr[1], resb.decode())
                                )
                                time.sleep(1)
                                socketId.sendall(resb)
                            else:
                                log.info("No Data to be sent")

            except socket.error as err:
                log.warning("socket error :%s", err)
                continue
            except ssl.SSLError as err:
                if err.args[0] == ssl.SSL_ERROR_WANT_READ:
                    continue
                elif err.args[0] == ssl.SSL_ERROR_WANT_WRITE:
                    continue
                else:
                    raise
            except KeyboardInterrupt:
                log.info("key board interrupt")
                break
            except Exception as err:
                log.exception(err)
                log.critical("error :%s", err)
                break
                for i in socketslist:
                    if i is serversocket:
                        continue
                    i.close()
                    socketslist.remove(i)
                continue
    finally:
        manager.cbsd_clean()
        serversocket.close()


# main entry
if __name__ == "__main__":
    try:
        if sys.argv[1] == "-c":
            print("\nmain opt is -c\n")
            sas_sim_config_file = sys.argv[2]
            print("\nargv[2] = %s\n" % (sys.argv[2]))
            pass
        else:
            print("\nmain opt is not -c, sas_sim_config_file will set default value\n")
            sas_sim_config_file = (
                os.path.dirname(os.path.realpath(__file__)) + "/SAS_Sim.conf"
            )
    except BaseException:
        print("\nexcept:format:: python /SAS_Sim_persistent.py -c /SAS_Sim.conf\n")
        print("\nsas_sim_config_file will set default value\n")
        sas_sim_config_file = (
            os.path.dirname(os.path.realpath(__file__)) + "/SAS_Sim.conf"
        )

    print("\nmain set sas_sim_config_file = %s\n" % sas_sim_config_file)

    try:
        logHandler = logging_init(sas_sim_config_file)
        logHandler.info("log first print:")
        config = SASConfig(logHandler, sas_sim_config_file)
        logHandler.info("SAS Simulator v2 start...")
        main_loop(config, logHandler)
    except KeyboardInterrupt:
        logHandler.info("key board interrupt")
    except Exception as err:
        logHandler.exception(err)
        logHandler.critical("error :%s", err)
    finally:
        logHandler.info("SAS Simulator terminate...")
