"""
:copyright: Nokia Networks
:author: Marek Kieltyka <marek.kieltyka@nokia.com>
:maintainer: Marek Kieltyka <marek.kieltyka@nokia.com>
"""

from collections import namedtuple

RandDParametersFile = namedtuple('RandDParametersFile',
                                 'file_name file_path compressed_file_name_regex compressed_file_path tmp_file_path')
RandDFlag = namedtuple('RandDFlag',
                       'name file_path file_name')

CPUE_addons = RandDParametersFile('cp_ue.enb_conf.ini', '/opt/nokia/SS_CPLANE/etc/', 'cp[-_]ue*.txz',
                                  '/ffs/run/swpool/5G/CPUENODE/addons/', '/tmp/cp-ue/')

CPUE_addons_ABIO = RandDParametersFile('cp_ue.enb_conf.ini', '/opt/nokia/SS_CPLANE/etc/', 'cp[-_]ue*.txz',
                                       '/ffs/run/swpool/5G/CPUENODE_ABINO/addons/', '/tmp/cp-ue/')

CPUE_addons_xeon = RandDParametersFile('cp_ue.enb_conf.ini', '/opt/nokia/SS_CPLANE/etc/', 'cp[-_]ue*.txz',
                                       '/ffs/run/swpool/CPLANE-5G/airscale5g-xeon/', '/tmp/cp-ue/')

CPUE_addons_snowfish = RandDParametersFile('cp_ue.enb_conf.ini', '/opt/nokia/SS_CPLANE/etc/', 'cp[-_]ue*.txz',
                                           '/ffs/run/swpool/CPLANE-5G/sm6-snowfish/', '/tmp/cp-ue/')

CPUE_addons_marlin = RandDParametersFile('cp_ue.enb_conf.ini', '/opt/nokia/SS_CPLANE/etc/', 'cp[-_]ue*.txz',
                                         '/ffs/run/swpool/CPLANE-5G/sm7-marlin/', '/tmp/cp-ue/')

CP_UE_INI_PATH = '/tmp/cp-ue/opt/nokia/SS_CPLANE/etc/'

rdSktSpId = RandDFlag('rdSktSpId', CP_UE_INI_PATH, 'cp_ue.enb_conf.ini')
rdSktPlmnId = RandDFlag('rdSktPlmnId', CP_UE_INI_PATH, 'cp_ue.enb_conf.ini')
rdUlPowerControl = RandDFlag('rdUlPowerControl', CP_UE_INI_PATH, 'cp_ue.enb_conf.ini')
rdNsaInactivityTimer = RandDFlag('rdNsaInactivityTimer', CP_UE_INI_PATH, 'cp_ue.enb_conf.ini')
rdActInactDetNSAUe = RandDFlag('rdActInactDetNSAUe', CP_UE_INI_PATH, 'cp_ue.enb_conf.ini')
rdActProactULScheduling = RandDFlag('rdActProactULScheduling', CP_UE_INI_PATH, 'cp_ue.enb_conf.ini')
