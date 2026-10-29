# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Ju Fei
:contact: fei.ju@nokia-sbell.com
"""
import os
import re
import logging
from lxml import etree
import lzma
import gzip

try:
    from common import IpaMmlItem
except Exception:
    from .common import IpaMmlItem


class c_counter_manager(object):

    def __init__(self, **kwargs):
        self.logger = kwargs.get('logger', logging.getLogger(__file__))

    def parse_pm_file(self, xzfile='', cared_counters=[]):
        self.logger.info('Parse PM Counter file: ' + xzfile)
        result = []
        ext = os.path.splitext(xzfile)[-1]
        btsid = re.findall(r'BTS-[\d]+', xzfile)[0]
        if ext == '.xz':
            tree = etree.fromstring(lzma.LZMAFile(xzfile).read())
        elif ext == '.gz':
            tree = etree.fromstring(gzip.open(xzfile, 'rb').read())
        elif (ext == '.xml' or ext == '.raw'):
            tree = etree.fromstring(open(xzfile, 'rb').read())
        else:
            raise Exception('Unknown PM Counter file format [%s].' % (xzfile))

        if cared_counters:
            self.counter_list = cared_counters
        else:
            self.counter_list = list(set(re.findall(r'M[0-9A-Z]{4,10}',
                                     etree.tostring(tree, pretty_print=True).decode())))
        for pmsetup in tree.xpath('//PMSetup'):
            for counter in self.counter_list:
                for node in pmsetup.xpath('.//%s' % (counter)):
                    aresult = IpaMmlItem()
                    aresult.starttime = pmsetup.attrib['startTime']
                    aresult.counter = counter
                    aresult.value = float(node.text)
                    parent_node = node.xpath('..')[0]
                    aresult.cellinfo = ''
                    if parent_node.xpath('..//%s' % ('localMoid')):
                        if (len(parent_node.xpath('..//%s' % ('localMoid'))[0].
                                text.split(r'/')[:2]) > 1):
                            aresult.cellinfo = '/'.join(
                                parent_node.xpath('..//%s' % ('localMoid'))[0].
                                text.split(r'/')[:2])
                        else:
                            aresult.cellinfo = (parent_node.xpath(
                                '..//%s' % ('localMoid'))[0].
                                text.split(r'/')[:2][0])
                    if parent_node.xpath('..//%s' % ('DN')):
                        aresult.cellinfo = parent_node.xpath(
                            '..//%s' % ('DN'))[0].text
                    if ('LNCEL' not in aresult.cellinfo.upper()) and (
                            'NRCELL' not in aresult.cellinfo.upper()) and (
                            'NRBTS' not in aresult.cellinfo.upper()):
                        aresult.cellinfo = 'LNBTS'
                    aresult.btsid = btsid
                    result.append(aresult)
        return result
