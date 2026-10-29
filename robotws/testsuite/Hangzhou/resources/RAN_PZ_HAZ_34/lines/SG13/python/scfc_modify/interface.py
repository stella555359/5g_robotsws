# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Zhang wen chao
:contact:
:history:
1. 2021-6-25 create
"""
from .scfc_modification import *
from .parameter_variable import *
# from robot.libraries.XML import XML
from .localxml import XML as LOCALXML

xml = LOCALXML()


def add_nrrel_extend_parameter_on_cell(xml_path, cellid, lcrid, ca_relation='enable', gnbid='', nrrelid=""):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if gnbid == '':
        gnb_id = nrbts
    else:
        gnb_id = gnbid
    if nrrelid == "":
        nrrelid = lcrid
    if 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(mrbts, nrbts, cellid, nrrelid) not in mo_list:
        print("MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{} not exist, will add!".format(mrbts, nrbts, cellid, nrrelid))
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=nr_rel
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRCELL-1', 'NRCELL-{}'.format(cellid))
                        .replace('NRREL-2', 'NRREL-{}'.format(nrrelid))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='gNbId',
                                  value=gnb_id,
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(mrbts,
                                                                                             nrbts,
                                                                                             cellid,
                                                                                             nrrelid))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='lcrId',
                                  value=lcrid,
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(mrbts,
                                                                                             nrbts,
                                                                                             cellid,
                                                                                             nrrelid))
    if ca_relation == 'disable':
        del_element_from_xml(xml_path=xml_path,
                             mo='MRBTS-{}/NRBTS-{}/NRCELL-{}/NRREL-{}'.format(mrbts, nrbts, cellid, nrrelid),
                             parameter='sCellAdditionMethod')


def add_a2measscellrelssbrsrp_list_in_cells(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=a2measscellrelssbrsrp_add)
    xml.save_xml(source=parse_file, path=xml_path)


def add_a3measssbrsrp_list_in_cells(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=a3measssbrsrp_add)
        xml.add_element(source=ob, element='<p name="absThreshSsbRsrpConsolidation">1</p>')
        xml.add_element(source=ob, element='<p name="sMeasConfigSsbRsrp">10</p>')
    xml.save_xml(source=parse_file, path=xml_path)


def add_a1meashossbrsrpsa_list_in_cells(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=a1meashossbrsrpsa_add)
    xml.save_xml(source=parse_file, path=xml_path)
    modify_element_value_from_xml(xml_path=xml_path, parameter='a1MeashoEnabledSA', value='rsrp')


def add_a2meashossbrsrpsa_list_in_cells(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=a2meashossbrsrpsa_add)
    xml.save_xml(source=parse_file, path=xml_path)
    modify_element_value_from_xml(xml_path=xml_path, parameter='a2MeashoEnabledSA', value='rsrp')


def add_drxprofile_list_in_cells(xml_path, profile_id='1', **kwargs):
    RttTimerDl = kwargs.get("drxHarqRttTimerDl", "0symbols")
    RttTimerUl = kwargs.get("drxHarqRttTimerUl", "0symbols")
    timer = kwargs.get("drxInactivityTimer", "80ms")
    long_cycle = kwargs.get("drxLongCycle", "160ms")
    duration_timer = kwargs.get("drxOnDurationTimer", "10ms")
    retrans_time_dl = kwargs.get("drxRetransTimerDl", "0slot")
    retrans_time_ul = kwargs.get("drxRetransTimerUl", "0slot")
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'drxProfile{}'.format(profile_id))
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    drx_ele = drx_profile.format(profile_id=profile_id, drxHarqRttTimerDl=RttTimerDl, drxHarqRttTimerUl=RttTimerUl,
                                 drxInactivityTimer=timer, drxLongCycle=long_cycle,
                                 drxOnDurationTimer=duration_timer, drxRetransTimerDl=retrans_time_dl,
                                 drxRetransTimerUl=retrans_time_ul)
    for ob in obs:
        xml.add_element(source=ob, element=drx_ele)
    xml.save_xml(source=parse_file, path=xml_path)


# dlMimoMode = 8x4 Closed Loop Spatial Multiplexing
def add_periodiccsiacquisition_list_in_cells(xml_path, **kwargs):
    periodicity = kwargs.get("csiReportPeriodicity", "slots320")
    reportperiod_set1 = kwargs.get("csirsNumberWithinReportPeriod_Set1", "3")
    power = kwargs.get("csirsPower", "5")
    number = kwargs.get("maxCsirsNumber", "4")
    scramblingId = kwargs.get("scramblingIdStep", "3")
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'periodicCsiAcquisition')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    periodiccsiacquisition_ele = periodicCsi.format(csiReportPeriodicity=periodicity,
                                                    csirsNumberWithinReportPeriod_Set1=reportperiod_set1,
                                                    csirsPower=power,
                                                    maxCsirsNumber=number,
                                                    scramblingIdStep=scramblingId)
    for ob in obs:
        xml.add_element(source=ob, element=periodiccsiacquisition_ele)
    xml.save_xml(source=parse_file, path=xml_path)


# prachConfigurationIndex=98
def add_tddframestructure_list_in_cells(xml_path, **kwargs):
    framestructure_type = kwargs.get("frameStructureType", "semiStatic")
    guardperiod_length = kwargs.get("guardPeriodLength", "2Symbols")
    ltetonrframe_shift = kwargs.get("lteToNrFrameShift", "0ms")
    tdlteuldl_config = kwargs.get("tdLteUlDlConfig", "tdLteConfig2")
    uldldataslot_ratio = kwargs.get("ulDlDataSlotRatio", "3/7")
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'tddFrameStructure')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    tddframestructure_ele = tddFrameStructure.format(frameStructureType=framestructure_type,
                                                     guardPeriodLength=guardperiod_length,
                                                     tdLteUlDlConfig=tdlteuldl_config,
                                                     ulDlDataSlotRatio=uldldataslot_ratio)
    for ob in obs:
        xml.add_element(source=ob, element=tddframestructure_ele)
    xml.save_xml(source=parse_file, path=xml_path)


def add_csirsBeamMgmt_list_in_cells(xml_path, **kwargs):
    bmmgmtdensity = kwargs.get("csirsBmMgmtDensity", "density3")
    bmmgmtreindex = kwargs.get("csirsBmMgmtReIndex", "0")
    bmmgmtsubband = kwargs.get("csirsBmMgmtSubband", "aboveSSPBCHBlock")
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'csirsBeamMgmt')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    csirsbeammgmt_ele = csirsbeammgmt.format(csirsBmMgmtDensity=bmmgmtdensity,
                                             csirsBmMgmtReIndex=bmmgmtreindex,
                                             csirsBmMgmtSubband=bmmgmtsubband)
    for ob in obs:
        xml.add_element(source=ob, element=csirsbeammgmt_ele)
    xml.save_xml(source=parse_file, path=xml_path)


def add_all_elements(xml_path, class_name, parameter, value):
    mo_list = get_dist_from_class(xml_path, class_name)
    for mo in mo_list:
        add_element_from_xml(xml_path, mo, parameter, value)


def add_nrhoif_extend_parameter_on_cell(xml_path, cellid, ho_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRHOIF-{}'.format(mrbts, nrbts, cellid, ho_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=nr_hoif
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRCELL-1', 'NRCELL-{}'.format(cellid))
                        .replace('NRHOIF-1', 'NRHOIF-{}'.format(ho_id))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)
    add_element_from_xml(xml_path=xml_path, mo='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(mrbts, nrbts, cellid),
                         parameter='measGapSelectionSA', value='balancedChoice')


def add_nradjnrcell_extend_parameter_on_cell(xml_path, index_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRADJNRCELL-{}'.format(mrbts, nrbts, index_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=nradjnrcell
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRADJNRCELL-1', 'NRADJNRCELL-{}'.format(index_id))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_nradjgnb_extend_parameter_on_cell(xml_path, index_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRADJGNB-{}'.format(mrbts, nrbts, index_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=nradjgnb
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRADJGNB-1', 'NRADJGNB-{}'.format(index_id))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_vonr_extend_parameter_on_bts(xml_path):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    parse_file = xml.parse_xml(xml_path)
    ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
    if 'MRBTS-{}/NRBTS-{}/NRDRB-15'.format(mrbts, nrbts) not in mo_list:
        xml.add_element(source=ob, element=nrdrb_15
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
    if 'MRBTS-{}/NRBTS-{}/NRDRB_5QI-6'.format(mrbts, nrbts) not in mo_list:
        xml.add_element(source=ob, element=nrdrb_5qi_6
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
    if 'MRBTS-{}/NRBTS-{}/NRDRB_MAC-3'.format(mrbts, nrbts) not in mo_list:
        xml.add_element(source=ob, element=nrdrb_mac
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRDRB_MAC-1', 'NRDRB_MAC-3')
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
    if 'MRBTS-{}/NRBTS-{}/NRDRB_MAC-4'.format(mrbts, nrbts) not in mo_list:
        xml.add_element(source=ob, element=nrdrb_mac
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRDRB_MAC-1', 'NRDRB_MAC-4')
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
    if 'MRBTS-{}/NRBTS-{}/NRDRB_PDCP-3'.format(mrbts, nrbts) not in mo_list:
        xml.add_element(source=ob, element=nrdrb_pdcp_3
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
    if 'MRBTS-1/NRBTS-2/NRDRB_RLC_UM-1'.format(mrbts, nrbts) not in mo_list:
        xml.add_element(source=ob, element=nrdrb_rlc_um_1
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
    xml.save_xml(source=parse_file, path=xml_path)
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='lcgid',
                                  value='4',
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB_MAC-3'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='lcgid',
                                  value='0',
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB_MAC-4'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='schedulPrio',
                                  value='5',
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB_MAC-3'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='schedulPrio',
                                  value='4',
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB_MAC-4'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='actVoNR',
                                  value='true')
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='dscp',
                                  value='40',
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB-10'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='nrDrbMacDN',
                                  value='MRBTS-{}/NRBTS-{}/NRDRB_MAC-4'.format(mrbts, nrbts),
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB-10'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path,
                                  parameter='resType',
                                  value='nonGBR_Signaling',
                                  mo_dist_name='MRBTS-{}/NRBTS-{}/NRDRB-10'.format(mrbts, nrbts))
    modify_element_value_from_xml(xml_path=xml_path, parameter='nea0', value='9')
    modify_element_value_from_xml(xml_path=xml_path, parameter='nea3_128', value='0')


def add_parameter_from_xml(xml_path, class_name, parameter, value):
    mo_list = get_dist_from_class(xml_path=xml_path, class_name=class_name)
    for mo in mo_list:
        add_element_from_xml(xml_path, mo, parameter, value)


def add_nradjecell_extend_parameter_on_cell(xml_path, index_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRADJECELL-{}'.format(mrbts, nrbts, index_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=NRADJECELL
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRADJECELL-1', 'NRADJECELL-{}'.format(index_id))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_nrrele_extend_parameter_on_cell(xml_path, cell_id, nrReleId):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRRELE-{}'.format(mrbts, nrbts, cell_id, nrReleId) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=NRRELE
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRCELL-1', 'NRCELL-{}'.format(cell_id))
                        .replace('NRRELE-1', 'NRRELE-{}'.format(nrReleId))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_nrhoir_extend_parameter_on_cell(xml_path, nrHoirId):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRHOIR-{}'.format(mrbts, nrbts, nrHoirId) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=NRHOIR
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-2', 'NRBTS-{}'.format(nrbts))
                        .replace('NRHOIR-1', 'NRHOIR-{}'.format(nrHoirId))
                        .replace('NRBTSCL22R1_2106_100', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_nrhoirDNList_in_cells(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=nrhoirDNList_add)
    xml.save_xml(source=parse_file, path=xml_path)


def raTypeList_add(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=raTypeList_add)
    xml.save_xml(source=parse_file, path=xml_path)


def add_srsForBeamMgmt_list_in_cells(xml_path, **kwargs):
    b_SRS = kwargs.get("bSRS", "2")
    c_SRS = kwargs.get("cSRS", "63")
    periodicity = kwargs.get("srsUePeriodicity", "slots40")
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'srsForBeamMgmt')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    srs_ele = srsForBeamMgmt_add.format(bSRS=b_SRS, cSRS=c_SRS, srsUePeriodicity=periodicity)
    for ob in obs:
        xml.add_element(source=ob, element=srs_ele)
    xml.save_xml(source=parse_file, path=xml_path)


def add_bwplist_list_in_cells(xml_path):
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'cellBwpList')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=bwpdnlist_add)
    xml.save_xml(source=parse_file, path=xml_path)


def add_bwplist_list_in_cells_new(xml_path, keyid):
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'cellBwpList')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=bwpdnlist_add_dict[keyid])
    xml.save_xml(source=parse_file, path=xml_path)


def add_eirpControl_list_in_cells(xml_path, **kwargs):
    minGuaranteedBudgetRatio_ele = kwargs.get("minGuaranteedBudgetRatio", "50")
    minGuaranteedBudgetRatioMode_ele = kwargs.get("minGuaranteedBudgetRatioMode", "actualEirpBudgetRatio")
    minSignificantNormalizedBeamGain_ele = kwargs.get("minSignificantNormalizedBeamGain", "-20")
    numOfSegmentAzimuthEdges_ele = kwargs.get("numOfSegmentAzimuthEdges", "0")
    numOfSegmentElevationEdges_ele = kwargs.get("numOfSegmentElevationEdges", "0")
    schedulWeightFactorEnabled_ele = kwargs.get("schedulWeightFactorEnabled", "false")
    mo_list = get_dist_from_class(xml_path=xml_path, class_name='NRCELL')
    for mo in mo_list:
        del_list_from_xml(xml_path, mo, 'eirpControl')
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    eirpControl_ele = eirpControlList_add.format(minGuaranteedBudgetRatio=minGuaranteedBudgetRatio_ele,
                                                 minGuaranteedBudgetRatioMode=minGuaranteedBudgetRatioMode_ele,
                                                 minSignificantNormalizedBeamGain=minSignificantNormalizedBeamGain_ele,
                                                 numOfSegmentAzimuthEdges=numOfSegmentAzimuthEdges_ele,
                                                 numOfSegmentElevationEdges=numOfSegmentElevationEdges_ele,
                                                 schedulWeightFactorEnabled=schedulWeightFactorEnabled_ele)
    for ob in obs:
        xml.add_element(source=ob, element=eirpControl_ele)
    xml.save_xml(source=parse_file, path=xml_path)


def add_nrulclpc_profile_obj_on_nrbts(xml_path, profile_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRULCLPC_PROFILE-{}'.format(mrbts, nrbts, profile_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=NRULCLPC_PROFILE
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-1', 'NRBTS-{}'.format(nrbts))
                        .replace('NRULCLPC_PROFILE-0', 'NRULCLPC_PROFILE-{}'.format(profile_id))
                        .replace('NRBTSCL24R1_2317_101', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_nrrim_profile_obj_on_cell(xml_path, cellid, profile_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRCELL-{}/NRRIM_PROFILE-{}'.format(mrbts, nrbts, cellid, profile_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=NRRIM_PROFILE
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-1', 'NRBTS-{}'.format(nrbts))
                        .replace('NRCELL-1', 'NRCELL-{}'.format(cellid))
                        .replace('NRRIM_PROFILE-1', 'NRRIM_PROFILE-{}'.format(profile_id))
                        .replace('NRBTSCL24R1_2317_101', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_nrpgrp_obj_on_nrbts(xml_path, nrpgrp_id):
    mo_list = get_mo_list(xml_path)
    mrbts = get_mrbts_id_from_scfc(xml_path)
    nrbts = get_nrbts_id_from_scfc(xml_path)
    version = get_version(xml_path)
    if 'MRBTS-{}/NRBTS-{}/NRPGRP-{}'.format(mrbts, nrbts, nrpgrp_id) not in mo_list:
        parse_file = xml.parse_xml(xml_path)
        ob = xml.get_element(source=parse_file, xpath='.//cmData[1]')
        xml.add_element(source=ob, element=NRPGRP
                        .replace('MRBTS-1', 'MRBTS-{}'.format(mrbts))
                        .replace('NRBTS-1', 'NRBTS-{}'.format(nrbts))
                        .replace('NRPGRP-0', 'NRPGRP-{}'.format(nrpgrp_id))
                        .replace('NRBTSCL24R1_2318_101', '{}'.format(version)))
        xml.save_xml(source=parse_file, path=xml_path)


def add_lcsToGcsTranslate_list_in_cell(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=LCSToGcsT_add)
    xml.save_xml(source=parse_file, path=xml_path)


def add_srsForSubbandBm_in_cell(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=subbandBm_add)
    xml.save_xml(source=parse_file, path=xml_path)


def add_wbSbSrsSwitch_in_cell(xml_path):
    parse_file = xml.parse_xml(xml_path)
    obs = xml.get_elements(source=parse_file, xpath='.//managedObject[@class="com.nokia.srbts.nrbts:NRCELL"]')
    for ob in obs:
        xml.add_element(source=ob, element=wbSbSrsSwitch_add)
    xml.save_xml(source=parse_file, path=xml_path)


if __name__ == "__main__":
    add_nrrel_extend_parameter_on_cell("scfc_ASIK_ABIL_Cpri.xml", cellid=4, lcrid=1, ca_relation="enable", gnbid=3)
    add_drxprofile_list_in_cells("scfc_ASIK_ABIL_Cpri.xml")
    add_drxprofile_list_in_cells("scfc_ASIK_ABIL_Cpri.xml", 2, drxInactivityTimer='200ms', drxLongCycle='10ms')
