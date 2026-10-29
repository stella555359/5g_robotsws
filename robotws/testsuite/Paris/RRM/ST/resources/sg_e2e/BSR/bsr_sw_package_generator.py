#!/bin/python -B
# -*- coding: utf-8 -*-
"""
:copyright: Nokia
:author: Abdrrahmane NEZROUK (Paris Saclay)
:contact: abderrahmane.nezrouk@nokia.com
:maintainer: Abderrahmane Nezrouk (Paris Saclay)
:code based on vebeamSetFR2_16_8_8_1Prsion 0.9  04Dec20 of Juha Matturi
:Helpful library to generate BeamSet for AnalogBeamForming for Ru generation Gen4_HF/RF6.1_HF
"""
import re
import os
from shutil import copyfile, rmtree, make_archive
from datetime import date
from collections import OrderedDict
import logging

logging.basicConfig(level='INFO')

INPUT_RU_GEN = [
    'Gen4_HF',
    'RF6.1_HF'
]

INPUT_GEN4_VARIANTS_IN_ORDER = [
    'AEUB',
    'AEUD',
    'AEWB',
    'AEWD'
]

INPUT_RF61_VARIANTS_IN_ORDER = [
    'AWEUA',
    'AWEUC',
    'AWEUB'
]

basicBeamSetValues = {
    "beamSet_1": 1,
    "beamSet_2": 2,
    "beamSet_4": 3,
    "beamSet_8": 4,
    "beamSet_4_4": 5,
    "beamSet_5_3": 6,
    "beamSet_6_2": 7,
    "beamSet_2_2_2_2": 9,
    "beamSet_3_3_2_square": 10,
    "beamSet_3_3_2_azimuth": 11,
    "beamSet_6": 16,
    "beamSet_2_2": 22,
    "beamSet_2SS": 24,
    "beamSet_4SS": 25,
    "beamSet_3_1": 31,
    "beamSet_3_3": 33,
    "beamSet_4_2": 42,
    "beamSet_5_1": 51,
    "beamSetAbf_1A": 100,
    "beamSetAbf_32A": 101,
    "beamSetAbf_32B": 102,
    "beamSetAbf_32C": 103,
    "beamSetFR2_16_8_8_1P": 104,
    "beamSetFR2_8_8_8_8_1P": 105,
    "beamSetFR2_6_6_6_6_6_2_1P": 106,
    "beamSetFR2_6_6_4_2P": 201,
    "beamSetFR2_6_2_4P": 301,
    "beamSetFR2_4_4_2_3P": 401
}


def get_Json_Infos(Json_file_path):
    pattern = re.compile(r'(?P<whitespace>( |\n|\r|\t)*)'
                         r'"(?P<key>[0-9a-zA-Z_]+)":("?)(?P<value>(\-?[0-9a-zA-Z_\s\.]+))"?,?')
    with open(Json_file_path, 'r') as json_file:
        lines = json_file.readlines()
        attribs = ['major_version', 'minor_version', 'description', 'nominalFrequency_kHz',
                   'rows', "columns", "spacingRow_mm", "spacingColumn_mm"]
        count = 17
        infos = {}
        for line in lines:
            line = line.replace('\n', '').replace('\r', '')
            matched = pattern.match(line)
            if bool(matched):
                if matched.groupdict()['key'] in attribs:
                    infos.update({matched.groupdict()['key']: matched.groupdict()['value']})
            count -= 1
            if count < 0:
                break
        infos['major_version'] = infos['major_version'].zfill(5)
        return infos


def get_basicBeamSetValue(BemSetName):
    for key in basicBeamSetValues.keys():
        if key in BemSetName:
            return key, basicBeamSetValues[key]
    else:
        return 'beamSetAbf_32A', basicBeamSetValues['beamSetAbf_32A']


def writeTargetbdXml(output_dir, bsrName, tarExcl, json_size, xml_size):
    today = date.today()
    file_path = os.path.join(output_dir, 'TargetBD_' + bsrName + '.xml')
    with open(file_path, "w") as target_xml:
        target_xml.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        target_xml.write('<targetBD_BSR softwareReleaseDate="%s" softwareReleaseVersion="00001" '
                         'buildDescriptorId="%s">\n' % (today.strftime("%m/%d/%Y"), bsrName[:-6]))
        target_xml.write('  <buildElement encrypted="" compressed="" path="/" targetPath="/rom/" '
                         'fileLength="0" checksum="" nrOfBlocks="1" hwUnit="FCTBSR" version="_00001.xml" '
                         'name="TargetBD_%s" swFileKeyName=""></buildElement>\n' % bsrName[:-6])
        target_xml.write('  <buildElement encrypted="" compressed="" path="/" targetPath="/rom/config/beamforming/" '
                         'fileLength="%d" checksum="" nrOfBlocks="1" hwUnit="FCTBSR" version="_00001.json" '
                         'name="%s"></buildElement>\n' % (json_size, bsrName[:-6]))
        target_xml.write('  <buildElement encrypted="" compressed="" path="/" targetPath="/rom/config/beamforming/" '
                         'fileLength="%d" checksum="" nrOfBlocks="1" hwUnit="FCTBSR" version="_00001.xml" '
                         'name="%s"></buildElement>\n' % (xml_size, bsrName[:-6]))
        target_xml.write('</targetBD_BSR>\n')


def makeXmlFile(beamSetString, beamIds, output_dir, bsrName, RuVariant, bsCount, bs_infos):
    file_path = os.path.join(output_dir, bsrName + '.xml')
    with open(file_path, "w") as bsr_xml:
        bsr_xml.write('<?xml version="1.0" encoding="ISO-8859-1"?>\n')
        bsr_xml.write('<!-- ********************************************************** -->\n')
        bsr_xml.write('<!-- UNITS                                                      -->\n')
        bsr_xml.write('<!-- carrierFrequency:           %s                       -->\n' %
                      bs_infos['nominalFrequency_kHz']
                      )
        bsr_xml.write('<!-- azimuthSpacings:            %s mm                        -->\n' %
                      bs_infos['spacingColumn_mm']
                      )
        bsr_xml.write('<!-- elevationSpacings:          %s mm                         -->\n' %
                      bs_infos['spacingRow_mm']
                      )
        bsr_xml.write('<!-- columnShifting (upwards):  0 mm                            -->\n')
        bsr_xml.write('<!-- ********************************************************** -->\n')

        bsr_xml.write('<beamSetFile ruType="%s" carrierFrequency="%s" ruNumberOfRows="%s" ruNumberOfColumns="%s" '
                      'ruNumberOfPolarizations="2" azimuthSpacing="%s" elevationSpacing="%s" beamSets="%d">\n' % (
                          RuVariant,
                          bs_infos['nominalFrequency_kHz'],
                          bs_infos['rows'],
                          bs_infos['columns'],
                          bs_infos['spacingColumn_mm'],
                          bs_infos['spacingRow_mm'],
                          bsCount
                      )
                      )
        bsr_xml.write('<beamSet basicBeamSet="%s" basicBeamSetValue="%s" leftEdgeAngle="%s" rightEdgeAngle="%s" '
                      'topEdgeAngle="%s" bottomEdgeAngle="%s">\n' % (
                          bs_infos['basicBeamSet'],
                          bs_infos['beamSetValue'],
                          bs_infos['leftEdgeAngle'],
                          bs_infos['rightEdgeAngle'],
                          bs_infos['topEdgeAngle'],
                          bs_infos['bottomEdgeAngle']
                      )
                      )
        bsr_xml.write('<!---  %s--->\n' % beamSetString)
        bsr_xml.write('  <ssbBeamIndexing ssbsCount="32">\n')
        for k in range(0, 64):
            if bool(beamIds[k]):
                bsr_xml.write('   <ssb> %s </ssb>\n' % hex(beamIds[k]))
            else:
                break  # beamSet is shorter:32, 48 or 56 vs. 64 (max)
        bsr_xml.write('  </ssbBeamIndexing>\n</beamSet>\n</beamSetFile>')
        bsr_xml.write('\n')
    return os.path.getsize(file_path)


def get_all_beamSet(hppFileWithPath):
    str_file = ''
    beamSets = OrderedDict()
    with open(hppFileWithPath, "r") as source_file:
        lines = source_file.readlines()
        matched_items = re.findall(r"/[*](\w+)\s*[*]/\s{(\d{1,3}((,\s+\d{1,3})+)?,\s+\d{1,3})}", ''.join(lines))
        for item in matched_items:
            str_list = item[1].replace(',', '').split()
            beamSets.update({item[0].strip(): [int(e) for e in str_list]})
    return beamSets


def resolveBsrPackageFileName(RU_GEN, ruVariant, beamSet, count):
    ssbs = 0
    orientation = ''
    eleu = 0
    eled = 0
    azil = 0
    azir = 0
    pans = ''
    if 'beamSetAbf_1A' in beamSet:
        ssbs = 1
        eleu = 0
        eled = 0
        azil = 0
        azir = 0
        pans = '1P'
        orientation = 'H1'
    elif 'beamSetAbf_32A' in beamSet:
        ssbs = 32
        eleu = -3
        eled = 33
        azil = 60
        azir = 60
        pans = '1P'
        orientation = 'H16H15H1'
    elif 'beamSetAbf_32B' in beamSet:
        ssbs = 32
        eleu = -18
        eled = 18
        azil = 40
        azir = 40
        pans = '1P'
        orientation = 'H10H11H11'
    elif beamSet == 'beamSetAbf_32C':
        ssbs = 32
        eleu = -18
        eled = 18
        azil = 40
        azir = 40
        pans = '1P'
        orientation = 'H11H10H11'
    else:  # beamSet properties can be derived, search for strings between 2 '_':s
        pars = beamSet.split('_')
        if 'P' in pars[3]:
            ssbs = int(pars[1]) + int(pars[2])
            orientation = 'H' + pars[1] + 'H' + pars[2]
            pans = pars[3]
            azil = pars[4][1:]
            azir = pars[5]
            eleu = pars[6]
            eled = pars[7]
        elif 'P' in pars[4]:
            ssbs = int(pars[1]) + int(pars[2]) + int(pars[3])
            orientation = 'H' + pars[1] + 'H' + pars[2] + 'H' + pars[3]
            pans = pars[4]
            azil = pars[5][1:]
            azir = pars[6]
            eleu = pars[7]
            eled = pars[8]
        elif 'P' in pars[5]:
            ssbs = int(pars[1]) + int(pars[2]) + int(pars[3]) + int(pars[4])
            orientation = 'H' + pars[1] + 'H' + pars[2] + 'H' + pars[3] + 'H' + pars[4]
            pans = pars[5]
            azil = pars[6][1:]
            azir = pars[7]
            eleu = pars[8]
            eled = pars[9]
        elif 'P' in pars[6]:
            ssbs = int(pars[1]) + int(pars[2]) + int(pars[3]) + int(pars[4]) + int(pars[4]) + int(pars[5])
            orientation = 'H' + pars[1] + 'H' + pars[2] + 'H' + pars[3] + 'H' + pars[4] + 'H' + pars[5]
            pans = pars[6]
            azil = pars[7][1:]
            azir = pars[8]
            eleu = pars[9]
            eled = pars[10]
        elif 'P' in pars[7]:
            ssbs = int(pars[1]) + int(pars[2]) + int(pars[3]) + int(pars[4]) + int(pars[4]) + int(pars[5]) + int(
                pars[6])
            orientation = 'H' + pars[1] + 'H' + pars[2] + 'H' + pars[3] + 'H' + pars[4] + 'H' + pars[5] + 'H' + pars[6]
            pans = pars[7]
            azil = pars[8][1:]
            azir = pars[9]
            eleu = pars[10]
            eled = pars[11]
    if int(pans[0]) > 1:
        ssbs = ssbs * int(pans[0])  # 2 or more panels
        if ssbs == 33 or ssbs == 30:  # 3P panels align to 32
            ssbs = 32

    if isinstance(azil, str):
        azil = int(azil)
    if isinstance(azir, str):
        azir = int(azir)
    if isinstance(eleu, str):
        eleu = -int(eleu[1:]) if 'N' in eleu else int(eleu)
    if isinstance(eled, str):
        eled = -int(eled[1:]) if 'N' in eled else int(eled)

    bsrName = 'BSR_{}_32_{}_{}_{}'.format(ruVariant, beamSet, str(1 + count).zfill(5), '00001')

    bemSetInfos = {
        'leftEdgeAngle': str(azil),
        'rightEdgeAngle': str(azir),
        'topEdgeAngle': str(90 + eleu),
        'bottomEdgeAngle': str(90 + eled)
    }
    return bsrName, bemSetInfos


def gen_bsr_sw_package_file(BeamSet, RU_GEN, RuVariant, output_dir):
    '''
    :param BeamSet: 'beamSetFR2_16_8_8_1P_N45_45_N15_5'
    :param RU_GEN:  'RF6.1_HF'
    :param RuVariant:  'AWEUA'
    :param output_dir: '../output_dir'
    :return: bsrname or customBeamSetName
    '''
    logging.debug('Entries Params:\n \tBeamSet:{},\n \tRU_GEN:{},\n \tRuVariant:{},\n \toutput_dir:{},\n'.format(
        BeamSet, RU_GEN, RuVariant, output_dir)
    )
    Count = 0
    if RU_GEN in INPUT_RU_GEN:
        if RU_GEN == INPUT_RU_GEN[0]:
            if RuVariant not in INPUT_GEN4_VARIANTS_IN_ORDER:
                raise AssertionError(
                    "Exception occured: Ru generation {} not supported for {}".format(RU_GEN, RuVariant))
        else:
            if RuVariant not in INPUT_RF61_VARIANTS_IN_ORDER:
                raise AssertionError(
                    "Exception occured: Ru generation {} not supported for {}".format(RU_GEN, RuVariant))
            Count = 3
    else:
        raise AssertionError("Exception occured: Ru generation {}".format(RU_GEN))
    Json_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'Json_{}'.format(RuVariant))
    logging.debug('Json folder {}'.format(Json_folder))
    json_files = [x for x in os.listdir(Json_folder) if x[-5:] == '.json']
    hpp_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'PatternIdTableAbf.hpp')
    beamSets = get_all_beamSet(hpp_file)
    bsrname = ''
    BeamIds = []
    for k in beamSets.keys():
        if BeamSet in k:
            bsrname, bemSetInfos = resolveBsrPackageFileName(RU_GEN, RuVariant, k, Count)
            BeamIds = beamSets[k]
        Count += 1
    json_file = ''
    for file in json_files:
        file_name = os.path.basename(file)
        if bsrname in file_name:
            json_file = os.path.join(Json_folder, file)

    if not bool(json_file):
        raise AssertionError(
            'for {} \n No Json file with beamset {} for {} Ru was found '.format(bsrname, BeamSet, RuVariant))
    try:
        bs_infos = get_Json_Infos(json_file)
        basicBeamSet, beamSetValue = get_basicBeamSetValue(BeamSet)
        bs_infos.update({'basicBeamSet': basicBeamSet,
                         'beamSetValue': beamSetValue})
        bs_infos.update(bemSetInfos)
        bsCount = len(json_files)
        logging.debug('bs_infos {}'.format(bs_infos))
        output_dir = os.path.join(output_dir, bsrname)
        if os.path.exists(output_dir):
            rmtree(output_dir)
        os.mkdir(output_dir)
        dst_file = os.path.join(output_dir, os.path.basename(json_file))
        copyfile(json_file, dst_file)
        json_size = os.path.getsize(dst_file)
        xml_size = makeXmlFile(BeamSet, BeamIds, output_dir, bsrname, RuVariant, bsCount, bs_infos)
        writeTargetbdXml(output_dir, bsrname, 1, json_size, xml_size)
        make_archive(output_dir, 'zip', output_dir)  # zip all files that exist in folder: (output_dir)
    except Exception as e:
        logging.error('Error occurred  : ' + e.message)
        raise AssertionError('Error occurred  : ' + e.message)
    return bsrname
