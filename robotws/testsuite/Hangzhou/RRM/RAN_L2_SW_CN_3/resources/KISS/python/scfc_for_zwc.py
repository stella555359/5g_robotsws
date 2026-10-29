# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author:
:contact:
"""

import logging
import re
import os
from enb_access import get_bbu_type
from robot.libraries.XML import XML
xml = XML()
try:
    import xml.etree.cElementTree as ET
except ImportError:
    import xml.etree.ElementTree as ET


def _get_elements_values_from_xml(xml_path, parameter):
    values = xml.get_elements_texts(source=xml_path, xpath='.//p[@name="{}"]'.format(parameter))
    return values


def _get_element_value_from_xml(xml_path, mo_distname, parameter):
    value = xml.get_element_text(source=xml_path, xpath='.//managedObject[@distName="{}"]/p[@name="{}"]'
                                 .format(mo_distname, parameter))
    return value


def _check_elements_exist_from_xml(xml_path, parameter):
    try:
        temp_elements = xml.get_elements(source=xml_path, xpath='.//p[@name="{}"]'.format(parameter))
    except temp_elements:
        pass
    if len(temp_elements) != 0:
        return True
    else:
        return False


def _check_mo_element_exist_from_xml(xml_path, mo, parameter):
    if xml.get_element_count(source=xml_path, xpath='.//managedObject[@distName="{}"]/p[@name="{}"]'
                             .format(mo, parameter)) != 0:
        return True
    else:
        return False


def _modify_element_value_from_xml(xml_path, parameter, value, mo_distname=None):
    parse_file = xml.parse_xml(xml_path)
    if mo_distname is not None:
        object = xml.get_element(source=parse_file, xpath='.//managedObject[@distName="{}"]'.format(mo_distname))
        xml.set_element_text(source=object, text=value, xpath='.//p[@name="{}"]'.format(parameter))
    else:
        xml.set_elements_text(source=parse_file, text=value, xpath='.//p[@name="{}"]'.format(parameter))
    xml.save_xml(source=parse_file, path=xml_path)


def _get_mo_list(xml_path):
    tree = ET.ElementTree(file=xml_path)
    mo_list = []
    for elem in tree.iter():
        dic_temp = elem.attrib
        for i in dic_temp.keys():
            if i == 'distName':
                # print(list(dic_temp.values())[1])
                mo_list.append(list(dic_temp.values())[1])
    return mo_list


def get_distname_from_classname(xml_path, classname):
    tree = ET.ElementTree(file=xml_path)
    mo_list = []
    for elem in tree.iter():
        dic_temp = elem.attrib
        for i in dic_temp.keys():
            if i == 'class':
                if dic_temp['class'] == 'NOKLTE:{}'.format(classname):
                    mo_list.append(dic_temp['distName'])
    return mo_list


def _get_mo_via_element_and_value(xml_path, parameter, value):
    mo_list = _get_mo_list(xml_path)
    target_values = {}
    keys = []
    for mo in mo_list:
        try:
            target_value = _get_element_value_from_xml(xml_path=xml_path, mo_distname=mo, parameter=parameter)
            target_values[mo] = target_value
        except target_value:
            pass
    for key, text in target_values.iteritems():
        if text == value:
            keys.append(key)
    return keys


def _del_mo_from_xml(xml_path, del_mo):
    mo_list = _get_mo_list(xml_path)
    if del_mo in mo_list:
        logging.info(del_mo)
        parse_file = xml.parse_xml(xml_path)
        xml.remove_element(source=parse_file, xpath='.//managedObject[@distName="{}"]'.format(del_mo), remove_tail=True)
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        logging.info("xml file not exist this del mo !")


def _del_elements_from_xml(xml_path, parameter):
    if _check_elements_exist_from_xml(xml_path, parameter) is True:
        parse_file = xml.parse_xml(xml_path)
        xml.remove_elements(source=parse_file, xpath='.//p[@name="{}"]'.format(parameter))
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        logging.info("xml file not exist this del parameter !")


def del_elements_from_xml(xml_path, parameter):
    _del_elements_from_xml(xml_path, parameter)


def _add_element_from_xml(xml_path, mo, parameter, value):
    if _check_mo_element_exist_from_xml(xml_path, mo, parameter) is not True:
        parse_file = xml.parse_xml(xml_path)
        object = xml.get_element(source=parse_file, xpath='.//managedObject[@distName="{}"]'.format(mo))
        element = '<p name="{}">{}</p>'.format(parameter, value)
        logging.info(element)
        xml.add_element(source=object, element=element, index=0)
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        _modify_element_value_from_xml(xml_path, parameter, value, mo_distname=mo)


def add_element_tolist_from_xml(xml_path, mo, list_name, parameter, value):
    mo_list = _get_mo_list(xml_path)
    for mo1 in mo_list:
        if re.findall('MRBTS-\\d+/LNBTS-\\d+', mo1):
            key_mo = re.findall('MRBTS-(\\d+)/LNBTS-(\\d+)', mo1)
            break
    if re.findall('MRBTS-\\d+/LNBTS-\\d+', mo):
        mo = re.sub('MRBTS-\\d+/LNBTS-\\d+', 'MRBTS-{}/LNBTS-{}'.format(key_mo[0][0], key_mo[0][1]), mo)
    elif re.findall('MRBTS-\\d+', mo):
        mo = re.sub('MRBTS-\\d+/LNBTS-\\d+', 'MRBTS-{}'.format(key_mo[0][0]), mo)
    if xml.get_element_count(source=xml_path,
                             xpath='.//managedObject[@distName="{}"]/list[@name="{}"]/item/p[@name="{}"]'
                             .format(mo, list_name, parameter)) == 0:
        parse_file = xml.parse_xml(xml_path)
        object = xml.get_element(source=parse_file, xpath='.//managedObject[@distName="{}"]/list[@name="{}"]/item'
                                 .format(mo, list_name))
        element = '<p name="{}">{}</p>'.format(parameter, value)
        logging.info(element)
        xml.add_element(source=object, element=element, index=0)
        xml.save_xml(source=parse_file, path=xml_path)
    else:
        _modify_element_value_from_xml(xml_path, parameter, value, mo_distname=mo)


def _get_cellnumid_list_from_scfc(xml_path):
    mo_list = _get_mo_list(xml_path)
    id_list = []
    pattern = 'LNCEL-\\d+'
    for mo in mo_list:
        id = re.search(pattern, mo)
        if id is not None:
            id_num = re.search('\\d+', id.group())
            id_list.append(id_num.group())
    id_lists = list(set(id_list))
    return id_lists


def change_8pipe_to_4pipe_from_scfc(xml_path):
    del_pipe_list = ['ANTL-5', 'ANTL-6', 'ANTL-7', 'ANTL-8']
    del_mo_list = []
    value_list = _get_elements_values_from_xml(xml_path, parameter='antlDN')
    for value in set(value_list):
        for del_pipe in del_pipe_list:
            if del_pipe in value:
                del_mos = _get_mo_via_element_and_value(xml_path, parameter='antlDN', value=value)
                for del_mo in del_mos:
                    del_mo_list.append(del_mo)
    for del_mo in del_mo_list:
        _del_mo_from_xml(xml_path, del_mo)
    _del_elements_from_xml(xml_path, parameter='dlSectorBeamformingMode')
    _modify_element_value_from_xml(xml_path, parameter='dlMimoMode', value='Closed Loop MIMO (4x2)', mo_distname=None)
    _modify_element_value_from_xml(xml_path, parameter='actFastMimoSwitch', value='true', mo_distname=None)
    id_list = _get_cellnumid_list_from_scfc(xml_path)
    for id in id_list:
        mo = 'MRBTS-1/LNBTS-1/LNCEL-{}/LNCEL_TDD-0'.format(id)
        _add_element_from_xml(xml_path, mo, parameter='activatedMimoTM', value='TM4')


def remove_beamforming_from_beamformingType(xml_path):
    parse_file = xml.parse_xml(xml_path)
    xml.remove_elements(source=parse_file, xpath='.//list[@name="srsDlMimoModeDepConf"]', remove_tail=True)
    objects = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="NOKLTE:LNCEL_TDD"]')
    for object in objects:
        xml.add_element(source=object, element='<list name="srsDlMimoModeDepConf"><item> \
                        <p name="beamformingType">nonBeamforming</p> \
                        <p name="srsBandwidth">3hbw</p><p name="srsUePeriodicity">20ms</p></item></list>', index=0)
    xml.save_xml(source=parse_file, path=xml_path)


sibSchedulingList = '<list name="sibSchedulingList">' \
                    '</list>'


def add_sibSchedulingList(xml_path):
    parse_file = xml.parse_xml(xml_path)
    objects = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="NOKLTE:SIB"]')
    for object in objects:
        xml.add_element(source=object, element=sibSchedulingList)
    xml.save_xml(source=parse_file, path=xml_path)


def add_sibtype_item(xml_path, sibtype='SIB10'):
    parse_file = xml.parse_xml(xml_path)
    objects = xml.get_elements(source=parse_file, xpath='.//list[@name="sibSchedulingList"]')
    for object in objects:
        xml.add_element(source=object, element='<item>'
                                               '<p name="siMessagePeriodicity">80ms</p>'
                                               '<p name="siMessageRepetition">1</p>'
                                               '<p name="siMessageSibType">{}</p>'
                                               '</item>'.format(sibtype))
    xml.save_xml(source=parse_file, path=xml_path)


def get_rru_product_id(type):
    import os
    os.system('sshpass -p oZPS0POrRieRtu scp toor4nsn@192.168.255.129:/rom/swpool/OAM/FlexiBTSProperties_*.xml \
              /tmp/FlexiBTSProperties.xml')
    os.system('mv /tmp/FlexiBTSProperties.xml /tmp/FlexiBTSProperties.xml.gz')
    os.system('gunzip /tmp/FlexiBTSProperties.xml.gz')
    from lxml import etree
    root = etree.parse('/tmp/FlexiBTSProperties.xml')
    lists = root.xpath('//text()')
    for elem in lists:
        if type == '{}'.format(elem):
            return elem.getparent().getparent().getprevious().attrib['ProductCode']


def get_env_variable_value(option):
    import socket
    # import ConfigParser
    import configparser
    hostname = socket.gethostname()
    # config=ConfigParser.ConfigParser()
    config = configparser.ConfigParser()
    file_dir = os.path.dirname(os.path.abspath(__file__))
    config.read(os.path.join(file_dir, 'env.ini'))
    value = config.get(hostname, option)
    return value


def initialize_scfc_via_env_variable(source_file, dst_file):
    mrbts = get_env_variable_value('MRBTS')
    lnbts = get_env_variable_value('LNBTS')
    new_lines = ''
    with open(source_file, 'r') as file:
        lines = file.readlines()
        for line in lines:
            if line.find('MRBTS\\-\\d+'):
                line = re.sub('MRBTS\\-\\d+', '{}'.format(mrbts), line)
                line = re.sub('MRBTS\\-\\d+\\/LNBTS\\-\\d+', '{}/{}'.format(mrbts, lnbts), line)
                new_lines += line
            else:
                new_lines += line
    with open(dst_file, 'w') as f:
        f.write(new_lines)
    btsname = get_env_variable_value('BTSNAME')
    _modify_element_value_from_xml(xml_path=dst_file, parameter='btsName', value=btsname)
    rru_type = get_env_variable_value('RRU_type')
    prodCode = get_rru_product_id(rru_type)
    _modify_element_value_from_xml(xml_path=dst_file, parameter='prodCodePlanned', value=prodCode,
                                   mo_distname='{}/EQM-1/APEQM-1/RMOD-1'.format(mrbts))
    ipAddrPrim = get_env_variable_value('ipAddrPrim')
    _modify_element_value_from_xml(xml_path=dst_file, parameter='ipAddrPrim', value=ipAddrPrim)
    localIpAddr = get_env_variable_value('localIpAddr')
    _modify_element_value_from_xml(xml_path=dst_file, parameter='localIpAddr', value=localIpAddr)
    gateway = get_env_variable_value('gateway')
    _modify_element_value_from_xml(xml_path=dst_file, parameter='gateway', value=gateway)
    localIpPrefixLength = get_env_variable_value('localIpPrefixLength')
    _modify_element_value_from_xml(xml_path=dst_file, parameter='localIpPrefixLength', value=localIpPrefixLength)
    connectorLabel = get_env_variable_value('connectorLabel')
    _modify_element_value_from_xml(xml_path=dst_file, parameter='connectorLabel', value=connectorLabel,
                                   mo_distname='{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHLK-1'.format(mrbts))
    earfcn_list = get_env_variable_value('earfcn_list').split(',')
    try:
        for i, earfcn in enumerate(earfcn_list, start=1):
            _modify_element_value_from_xml(xml_path=dst_file, parameter='earfcn', value=earfcn,
                                           mo_distname='{}/{}/LNCEL-{}/LNCEL_TDD-0'.format(mrbts, lnbts, i))
    except Exception as result:
        pass
    pci_list = get_env_variable_value('phyCellId_list')
    try:
        for i, pci in enumerate(pci_list.split(','), start=1):
            _modify_element_value_from_xml(xml_path=dst_file, parameter='phyCellId', value=pci,
                                           mo_distname='{}/{}/LNCEL-{}'.format(mrbts, lnbts, i))
    except Exception as result:
        pass
    try:
        btsid = re.findall('LNBTS-(\\d+)', lnbts)[0]
        _modify_element_value_from_xml(xml_path=dst_file, parameter='lnBtsId', value=btsid)
    except btsid:
        pass


def change_64pipe_to_32pipe_from_scfc(xml_path):
    bts_id = ''
    mo_list = _get_mo_list(xml_path)
    cell_ids = set()
    for mo1 in mo_list:
        if re.findall('MRBTS-\\d+/LNBTS\\-\\d+', mo1):
            key_mo = re.findall('MRBTS-(\\d+)/LNBTS-(\\d+)', mo1)
            bts_id = key_mo[0][0]
            break
    for mo1 in mo_list:
        if re.findall('LNCEL-([0-9]*$)', mo1):
            key_mo = re.findall('LNCEL-([0-9]*$)', mo1)
            cell_id = key_mo[0]
            cell_ids.add(cell_id)
    if bts_id is not None:
        bbu_type = get_bbu_type
        if bbu_type == 'ASIB':
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-2'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-7'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-8'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-9'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-11'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-12'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-13'.format(bts_id))
            _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-22'.format(bts_id))
        for cell_id in cell_ids:
            for channel in range(1, 129):
                if channel % 2 == 1:
                    _modify_element_value_from_xml(xml_path, parameter='direction', value='TX',
                                                   mo_distname='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}/CHANNEL \
                                                   GROUP-1/CHANNEL-{}'.format(bts_id, cell_id, channel))
                else:
                    _modify_element_value_from_xml(xml_path, parameter='direction', value='RX',
                                                   mo_distname='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}/CHANNEL \
                                                   GROUP-1/CHANNEL-{}'.format(bts_id, cell_id, channel))
            for channel in range(65, 129):
                # print(channel)
                _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}/CHANNEL \
                                 GROUP-1/CHANNEL-{}'.format(bts_id, cell_id, channel))
        _modify_element_value_from_xml(xml_path, parameter='mMimoAntArrayMode', value='Right 32TRX Array (4x4x2)')
        _modify_element_value_from_xml(xml_path, parameter='dlMaxNumLayerPerMuRBG', value='8')
        _modify_element_value_from_xml(xml_path, parameter='ulMaxNumLayerPerMuPRB', value='4')


def get_scfc_path():
    bbu_type = get_bbu_type().lower()
    scfc_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'configuration_file',
                             'scfc_{}.xml'.format(bbu_type))
    return scfc_path


TNL = '<managedObject class="com.nokia.srbts.tnl:TNL" distName="MRBTS-1/TNLSVC-1/TNL-2" \
        operation="create" version="TNL20C_2007_002"/>'

ETHSVC = '<managedObject class="com.nokia.srbts.tnl:ETHSVC" distName="MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1" \
         operation="create" version="TNL20C_2007_002">'\
         '<p name="utilMeasSampInt">15sec</p></managedObject>'

ETHIF = '<managedObject class="com.nokia.srbts.tnl:ETHIF" distName="MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3" \
         version="TNL20C_2007_002" operation="create">' \
        '<p name="linkSelectorDN">MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2</p> \
        <p name="shapingOverhead">Ethernet frame</p>' \
        '<p name="txPriorityTagging">false</p></managedObject>'

ETHLK = '<managedObject class="com.nokia.srbts.tnl:ETHLK" distName="MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHLK-2" \
         version="TNL20C_2007_002" operation="create">' \
        '<p name="administrativeState">unlocked</p><p name="connectorLabel">S-RF6</p> \
        <p name="l2IngressRate">1000000</p>' \
        '<p name="modDN">MRBTS-1/EQM-1/APEQM-1/CABINET-1/BBMOD-1</p> \
        <p name="speedAndDuplex">AUTODETECT</p></managedObject>'

VLANIF = '<managedObject class="com.nokia.srbts.tnl:VLANIF" distName="MRBTS-1/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3/VLAN \
          IF-1" version="TNL20C_2007_002" operation="create"><p name="vlanId">1</p></managedObject>'

CABLINK_5G = '<managedObject class="com.nokia.srbts.eqm:CABLINK" distName="MRBTS-1/EQM-1/HWTOP-1/CABLINK-111" \
              version="EQM20B_2007_002" operation="create">' \
             '<p name="firstEndpointDN">MRBTS-1/EQM-1/SMOD_EXT-1</p><p name="firstEndpointLabel">OPT</p>' \
             '<p name="firstEndpointPortId">1</p><p name="linkSpeed">eCpri25</p> \
             <p name="radioProtocolType">25eCPRI</p>' '<p name="secondEndpointDN">MRBTS-1/EQM-1/APEQM-1/RMOD-1</p> \
             <p name="secondEndpointLabel">OPT</p>' \
             '<p name="secondEndpointPortId">3</p>'

SMOD_EXT = '<managedObject class="com.nokia.srbts.eqm:SMOD_EXT" distName="MRBTS-1/EQM-1/SMOD_EXT-1" \
           version="EQM20B_2007_002" operation="create">' \
           '<p name="eutraSupport">false</p><p name="eutraTDDSupport">false</p><p name="geranSupport">false</p>' \
           '<p name="nrSupport">true</p><p name="sranSupport">false</p><p name="syncMaster">true</p>' \
           '<p name="utranSupport">false</p></managedObject>'

LNADJGNB_5G = '<managedObject class="NOKLTE:LNADJGNB" distName="MRBTS-1/LNBTS-1/LNADJGNB-0" \
              version="xL20C_2007_003" operation="create">' \
              '<p name="adjGnbId">50</p><p name="adjGnbIdLength">22</p><p name="administrativeState">unlocked</p>' \
              '<p name="cPlaneIpAddr">10.0.1.1</p><p name="cPlaneIpAddrCtrl">oamControlled</p><list name="plmnId">' \
              '<item><p name="mcc">262</p><p name="mnc">3</p><p name="mncLength">2</p></item></list></managedObject>'


def configuration_ecpri(xml_path):
    bts_id = ''
    mo_list = _get_mo_list(xml_path)
    for mo1 in mo_list:
        if re.findall('MRBTS-\\d+/LNBTS-\\d+', mo1):
            key_mo = re.findall('MRBTS-(\\d+)/LNBTS-(\\d+)', mo1)
            bts_id = key_mo[0][0]
            break
    if bts_id is not None:
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-2'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-3'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-4'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-5'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-6'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-7'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-8'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-9'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-11'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-12'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-13'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-21'.format(bts_id))
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-22'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='firstEndpointDN',
                                       value='MRBTS-{}/EQM-1/APEQM-1/CABINET-1/SMOD-1'.format(bts_id),
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-1'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='firstEndpointLabel',
                                       value='BACKPLANE',
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-1'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='secondEndpointDN',
                                       value='MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-1'.format(bts_id),
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-1'.format(bts_id))
        _del_elements_from_xml(xml_path, parameter='iqCompression')
        _del_elements_from_xml(xml_path, parameter='radioProtocolType')
        _del_mo_from_xml(xml_path, del_mo='MRBTS-{}/TNLSVC-1/TNL-1/ETHSVC-1/ETHIF-1/VLANIF-1'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='firstEndpointPortId',
                                       value='6',
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='linkSpeed',
                                       value='eCpri25',
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='secondEndpointLabel',
                                       value='SFP',
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='secondEndpointPortId',
                                       value='4',
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(bts_id))
        _add_element_from_xml(xml_path, mo='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(bts_id),
                              parameter='radioProtocolType', value='25eCPRI')
        _modify_element_value_from_xml(xml_path, parameter='actEcpriMasterClock', value='true')
        cell_ids = set()
        for mo1 in mo_list:
            if re.findall('LNCEL-([0-9]*$)', mo1):
                key_mo = re.findall('LNCEL-([0-9]*$)', mo1)
                cell_id = key_mo[0]
                cell_ids.add(cell_id)
        for cell_id in cell_ids:
            for channel in range(1, 129):
                if channel % 2 == 1:
                    _modify_element_value_from_xml(xml_path, parameter='direction', value='TX',
                                                   mo_distname='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}/CHANNEL \
                                                   GROUP-1/CHANNEL-{}'.format(bts_id, cell_id, channel))
                else:
                    _modify_element_value_from_xml(xml_path, parameter='direction', value='RX',
                                                   mo_distname='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}/CHANNEL \
                                                   GROUP-1/CHANNEL-{}'.format(bts_id, cell_id, channel))
            for channel in range(3, 129):
                _del_mo_from_xml(xml_path,
                                 del_mo='MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELL-{}/CHANNELGROUP-1/CHANNEL-{}'
                                 .format(bts_id, cell_id, channel))
        parse_file = xml.parse_xml(xml_path)
        object1 = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=object1, element=TNL.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
        xml.add_element(source=object1, element=ETHSVC.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
        xml.add_element(source=object1, element=ETHIF.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
        xml.add_element(source=object1, element=ETHLK.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
        xml.add_element(source=object1, element=VLANIF.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
        xml.save_xml(source=parse_file, path=xml_path)


def get_cell_earfcn_and_pci(cell_id):
    earfcn_dict = {}
    pci_dict = {}
    pci_list = get_env_variable_value('phyCellId_list').split(',')
    earfcn_list = get_env_variable_value('earfcn_list').split(',')
    for i, value in enumerate(earfcn_list, start=1):
        earfcn_dict['{}'.format(i)] = value
    for i, value in enumerate(pci_list, start=1):
        pci_dict['{}'.format(i)] = value
    cell_str = '{},{}'.format(earfcn_dict[cell_id], pci_dict[cell_id])
    return cell_str


def modify_scfc_to_concurrent_mode(xml_path):
    """
    use after kw of configuration ecpri
    """
    bts_id = ''
    mo_list = _get_mo_list(xml_path)
    cplaneipaddr = get_env_variable_value('5g_cplaneipaddr')
    for mo1 in mo_list:
        if re.findall('MRBTS-\\d+/LNBTS-\\d+', mo1):
            key_mo = re.findall('MRBTS-(\\d+)/LNBTS-(\\d+)', mo1)
            bts_id = key_mo[0][0]
            break
    if bts_id is not None:
        _modify_element_value_from_xml(xml_path, parameter='firstEndpointPortId',
                                       value='5',
                                       mo_distname='MRBTS-{}/EQM-1/HWTOP-1/CABLINK-2'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='rfSharingEnabled',
                                       value='true',
                                       mo_distname='MRBTS-{}/MNL-1/MNLENT-1/FEATCADM-1'.format(bts_id))
        _modify_element_value_from_xml(xml_path, parameter='vlanId',
                                       value='3',
                                       mo_distname='MRBTS-{}/TNLSVC-1/TNL-2/ETHSVC-1/ETHIF-3/VLANIF-1'.format(bts_id))
        _add_element_from_xml(xml_path, mo='MRBTS-{}/EQM-1/APEQM-1/RMOD-1'.format(bts_id),
                              parameter='radioMasterDN',
                              value='MRBTS-{}/EQM-1/APEQM-1/CABINET-1/BBMOD-1'.format(bts_id))
    parse_file = xml.parse_xml(xml_path)
    object1 = xml.get_element(source=parse_file, xpath='.//cmData[1]')
    xml.add_element(source=object1, element=CABLINK_5G.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
    xml.add_element(source=object1, element=SMOD_EXT.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)))
    xml.add_element(source=object1, element=LNADJGNB_5G.replace('LNBTS-1', 'LNBTS-{}'.format(bts_id))
                    .replace('MRBTS-1', 'MRBTS-{}'.format(bts_id)).replace('10.0.1.1', cplaneipaddr))
    xml.add_element(source=object1, element=ETHIF.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id))
                    .replace('ETHIF-3', 'ETHIF-4').replace('ETHLK-2', ETHLK-3))
    xml.add_element(source=object1, element=ETHLK.replace('MRBTS-1', 'MRBTS-{}'.format(bts_id))
                    .replace('ETHLK-2', 'ETHLK-3').replace('S-RF6', 'S-RF5'))
    xml.save_xml(source=parse_file, path=xml_path)


if __name__ == '__main__':
    change_64pipe_to_32pipe_from_scfc('/home/ute/test/scfc_asib.xml')
