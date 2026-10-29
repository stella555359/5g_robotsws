# -*- coding:utf-8 -*-


import os
import sys
import re
import struct
from time import gmtime, strftime

from pmcounter_meta_rise import PmCounterMetaRise, merge_ltesbts_counter_from_xml
from pmuri import Uri
from pmservice_pb2 import PMReport

global LackMeasurementID
LackMeasurementID = []


def ParseUri(uri):
    return str(Uri(uri))


def ConvertToXml(pmreport):
    global LackMeasurementID
    print(
        '  <PMSetup startTime="' +
        strftime("%Y-%m-%dT%H:%M:%S.000", gmtime(pmreport.timestamp)) +
        'Z" period="' +
        str(pmreport.period) +
        '" tz="' + pmreport.tz +
        '" version="' +
        pmreport.schema_version +
        '" flags="0x' +
        format(pmreport.flags, '02x') + '">')
    for obj in pmreport.objects:
        print('    <PMMOResult>')
        print('      <MO>' + ParseUri(obj.uri) + '</MO>')
        for measurement in obj.measurements:
            try:
                print('      <NE-WBTS_1.0 measurementType="' + meta.get_measurement_name(
                    str(measurement.measurement_id)) + '">')
            except Exception as e:
                if repr(e).startswith('KeyError'):  # KeyError('40001',)
                    LackMeasurementID.append('M' + str(measurement.measurement_id))
                    continue
            meas_id = 'M' + str(measurement.measurement_id)
            for counter_id, counter_val in zip(measurement.counter_subid,
                                               measurement.counter_value):
                print(
                    '        <' + meas_id + 'C' + str(counter_id) + '>' + str(counter_val)
                    + '</' + meas_id + 'C' + str(
                        counter_id) + '>')
            print('      </NE-WBTS_1.0>')
        print('    </PMMOResult>')
    print('  </PMSetup>')


def ReadInput():
    if sys.version < "3":
        header = sys.stdin.read(12)
    else:
        header = sys.stdin.buffer.read(12)
    # '\xff\x03\x00\x00\x00\x00\x00\x00\x00\x00VV'
    # print(repr(header))
    if len(header) == 0:
        return False
    elif len(header) < 12:
        sys.stderr.write('header truncated, bailing out')
        return False
    else:
        magic, versionMajor, versionMinor, messageId, messageLength = struct.unpack('!BBBxxxHI',
                                                                                    header)
        # 255    3              0             0          22102
        if magic == 0xFF:
            if versionMajor == 3 and versionMinor <= 2:
                if sys.version < "3":
                    message = sys.stdin.read(messageLength)
                else:
                    message = sys.stdin.buffer.read(messageLength)
                report = PMReport()
                report.ParseFromString(message)
                ConvertToXml(report)
                return True
            else:
                sys.stderr.write("unsupported format")
        else:
            sys.stderr.write("unknown format")
    return False


def StartXml():
    print('<?xml version="1.0"?>')
    print('<OMeS>')


def EndXml():
    print('</OMeS>')


if __name__ == "__main__":
    meta = merge_ltesbts_counter_from_xml()

    StartXml()
    while ReadInput():
        pass
    EndXml()

    if len(LackMeasurementID) != 0:
        with open("/tmp/rtpm_not_analyzed_measurementID.txt", 'w') as f:
            for i in list(set(LackMeasurementID)):
                f.write(i)
                f.write('\n')
        f.close()
