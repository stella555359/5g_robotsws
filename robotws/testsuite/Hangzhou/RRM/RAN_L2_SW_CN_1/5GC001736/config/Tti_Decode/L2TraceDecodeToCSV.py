# -*- coding: utf-8 -*-
import struct
import binascii
import sys
import argparse
import os
import re
import csv
import time
import urllib.request
from L2TracePcapStripper import L2TracePcapStripper

global file_type
global total_lines
l2_trace_udp_port_number = 5678
hexdump_header = '000000 '

# Script 2 for Step 2 BEGIN ------------------------------------------------------------------
formatList = ['x', 'B', 'H', '', 'I', '', '', '', 'Q', '', '', '', '', '', '', '', '']

outFile = {}


class typeClass():

    def __init__(self):
        self._ieList = []
        self._pduDumpSize = 0

    def updateType(self, type_name, type_size):
        self._type_name = type_name
        self._type_size = type_size

    def getTypeName(self):
        return self._type_name

    def getPduDumpSize(self):
        return self._pduDumpSize

    def addIE(self, ieName, iePos):
        tup = [ieName, iePos]
        self._ieList.append(tup)

    def addpduDump(self, pduDumpSize):
        self._pduDumpSize = pduDumpSize

    def resolveSize(self):
        typeSize = int(self._type_size)

        numOfIEs = len(self._ieList)

        if numOfIEs > 0:
            for index in range(0, numOfIEs):

                updIndex = numOfIEs - 1 - index

                tup = self._ieList[updIndex]
                if tup[1] == '':
                    tup[1] = 0

                size = typeSize - int(tup[1])
                if (size == 0):
                    self._ieList[updIndex][1] = self._ieList[updIndex + 1][1]
                    del self._ieList[updIndex + 1]
                else:
                    typeSize = typeSize - size
                    self._ieList[updIndex][1] = size

            if (typeSize != 0):
                print("Error in size ", self.type_name, " ", typeSize)
        if args.debugLevel:
            print("type size is: ", typeSize)

    def getFlatType(self, typeDict):

        mask = 0xFFFFFFFF
        if len(self._ieList) > 0:

            typeStr = ""
            for index in range(0, len(self._ieList)):
                tup = self._ieList[index]
                ieName = tup[0]
                ieSize = str(tup[1])
                if args.debugLevel:
                    print("getFlatType ieName ", ieName, "ieSize ", ieSize)

                p = re.compile("itf_")
                m = p.match(ieName)
                if m:
                    typeStr = typeStr + typeDict[ieName].getFlatType(typeDict)
                else:
                    index = int(ieSize)
                    if (("pduDump" in ieName) and ("padding" not in ieName)):
                        typeStr = typeStr + ieSize + "s"
                    elif (index > 8):
                        typeStr = typeStr + ieSize + "s"
                    elif (formatList[index % 8] == ""):
                        typeStr = typeStr + ieSize + "s"
                    else:
                        typeStr = typeStr + formatList[index]

            return typeStr

        else:
            print("Error in type")

    def getAllIEs(self, typeDict):

        if len(self._ieList) > 0:
            ieList = []
            for index in range(0, len(self._ieList)):
                tup = self._ieList[index]
                ieName = tup[0]

                p = re.compile("itf_")
                m = p.match(ieName)
                if m:
                    ieList = ieList + typeDict[ieName].getAllIEs(typeDict)
                else:
                    ieList.append(ieName)
            return ieList

        else:
            print("Error in type")


def generateEventDiscrimatorReference(luaSharkDir):
    eventListStr = ["Du_Lo_Events", "Du_Hi_Events", "Cu_Hi_Events"]
    p = re.compile(r"^\s+Events_synthesized_events_(.*)\(.*\)")
    domainEventList = []
    index = 0
    while index < len(eventListStr):
        eventStr = eventListStr[index]
        eventFileName = luaSharkDir + os.sep + os.sep.join(eventStr.split("_")) + os.sep + "Events.lua"
        if os.path.isfile(eventFileName):
            fileHandle = open(eventFileName, 'r')
            eventList = []
            for line in fileHandle:
                m = p.match(line)
                if m:
                    eventList.append(m.group(1))
            domainEventList.append(eventList)
        index = index + 1

    return (domainEventList)


def generateTypeFormatAll(luaSharkDir, typeDict):
    for root, dirs, files in os.walk(luaSharkDir):
        for filename in files:
            structureDict = []
            fileSpec = os.path.join(root, filename)

            tmp = fileSpec.split("itf" + os.sep)
            tmp = tmp[1].split(".lua")
            tmp = tmp[0].split(os.sep)
            typeName = ("itf_" + "_".join(tmp))

            if typeName not in typeDict:
                typeStructure = generateTypeFormat(fileSpec)
                typeDict[typeName] = typeStructure
            else:
                print(typeName, " found")


def generateTypeFormat(fileSpec):
    luaSharkDir = ""

    structureStartFound = False
    try:
        fileHandle = open(fileSpec, 'r')
    except IOError:
        print('Cannot open file: ' + fileSpec)
    else:
        p = re.compile("(.*generated_luashark)")
        m = p.match(fileSpec)
        if m:
            luaSharkDir = m.group(1)

        typeStructure = typeClass()

        for line in fileHandle:
            line = line.strip()
            if structureStartFound is False:

                p = re.compile(r".*name=\"(\w*).*size=(\d*)")
                m = p.match(line)
                if m:
                    structureStartFound = True
                    typename = m.group(1)
                    typesize = m.group(2)
                    if args.debugLevel:
                        print("updating size 1 ", typename, " with typesize ", typesize)
                    typeStructure.updateType(typename, typesize)

                p = re.compile(r"\s*fields.StaticUnion\({name=\"(\w+)")
                m = p.match(line)
                if m:
                    structureStartFound = True
                    typename = m.group(1)
                    typesize = 4
                    typeStructure.updateType(typename, typesize)
                    typeStructure.addIE("event", 0)
                    if args.debugLevel:
                        print("updating size 2 ", fileHandle, " with line ", line)
                    readUnion(fileHandle, line)
            else:
                p = re.compile(r".*name=\"(\w+).*position=(\d*)")
                m = p.match(line)
                if m:
                    ieName = m.group(1)
                    iePos = m.group(2)
                    tup = (ieName, iePos)

                    if ("pduDump" in ieName):
                        if args.debugLevel:
                            print(fileSpec, " --> ", line)
                        patt = r".*fields.StaticVariableSizedArray.*size=\d*.*numItems=(\d*).*numPaddingBytes=(\d*)"
                        p = re.compile(patt)
                        m = p.match(line)
                        if m:
                            pduDumpSize = 4 + int(m.group(1)) + int(m.group(2))
                            if args.debugLevel:
                                print(fileSpec, " --> ", ieName, " ", pduDumpSize)

                            typeStructure.addpduDump(pduDumpSize)
                    if args.debugLevel:
                        print("adding iename", ieName, " with iePos ", iePos)
                    typeStructure.addIE(ieName, iePos)
                else:
                    p = re.compile(r"\s*(itf\w+)\((.*\"\,)\s*(\d*)")
                    m = p.match(line)
                    if m:
                        iename = m.group(1)
                        iesize = m.group(3)
                        if args.debugLevel:
                            print("adding iename", iename, " with iesize ", iesize)
                        typeStructure.addIE(iename, iesize)

        typeStructure.resolveSize()

        return typeStructure


def readUnion(fileHandle, line):
    openCount = re.findall(r"\(", line)
    closeCount = re.findall(r"\)", line)
    remainingCount = len(openCount) - len(closeCount)
    while (remainingCount > 0):
        line = fileHandle.readline()
        openCount = re.findall(r"\(", line)
        closeCount = re.findall(r"\)", line)
        remainingCount = len(openCount) - len(closeCount)


def checkTypePresence(domainEventList, typeStr):
    for eventList in domainEventList:
        for event in eventList:
            if event.lower() in typeStr:
                return True
    return False


def generateFlatStruct(domainEventList, typeDict):
    flatTypeDict = {}
    for k, v in typeDict.items():
        if checkTypePresence(domainEventList, k.lower()):
            typeStr = v.getFlatType(typeDict)
            flatTypeDict[k] = "<" + typeStr
    return flatTypeDict


def printFlatStruct(flatTypeDict):
    print("Flat structs")
    for k, v in flatTypeDict.items():
        print(k, " \n    ", v, "\n\n")


def generateXlsFile(traceFile, typeDict, flatTypeDict, domainEventList):
    f = open(traceFile)

    xlsList = []
    lineCount = 0
    lines = f.readlines()
    headerLines = 7
    for index in range(headerLines, len(lines)):
        lineCount = lineCount + 1

        line = lines[index].strip().replace(" ", "")
        eventHex = line[54:]  # 54/2 = 27 Bytes，000000+24Bytes Common content
        if args.debugLevel:
            print("lineCount: ", lineCount, ", eventHex:\n", eventHex, "\n")

        csvStr = convertToCSV(eventHex, typeDict, flatTypeDict, domainEventList, index)
        if (csvStr):
            xlsList.append(csvStr)
    if args.debugLevel:
        print(" Finished processing ", lineCount, " lines of file ", traceFile)
    return xlsList


def getTypeStructFormat(flatTypeDict, typeStr):
    if typeStr in flatTypeDict.keys():
        return flatTypeDict[typeStr]


def getEventType(typeDict, domainEventList, domain, eventDiscriminator):
    internalDomain = int(domain / 2)
    if args.debugLevel:
        print("internalDomain", internalDomain, ", for domain: ", domain)
    if (domainEventList):
        eventList = domainEventList[internalDomain]  # [[LO], [DU], [CU]]
        if (eventList):
            event = eventList[eventDiscriminator]
            if (event):
                for key in typeDict.keys():
                    if event.lower() in key.lower():
                        return key


errorIdx = 999999


def convertEvent(byteArray, typeDict, flatTypeDict, domainEventList, globStartIdx, lineNum):
    csvStr = ""

    try:
        typeStructFormat = ""
        typeStr = ""

        evHeaderBytes = byteArray[0:struct.calcsize('IBB')]

        if args.debugLevel:
            print("evHeaderBytes", evHeaderBytes)

        (eventDiscriminator, domain, typeId) = struct.unpack('IBB', evHeaderBytes)

        typeStr = getEventType(flatTypeDict, domainEventList, domain, eventDiscriminator)

        typeStructFormat = getTypeStructFormat(flatTypeDict, typeStr)
        if args.debugLevel:
            print("typeStructFormat", typeStructFormat, "\n")

        if (typeStr not in outFile):
            arrList = []
            ieNameList = typeDict[typeStr].getAllIEs(typeDict)
            arrList.append(",".join(ieNameList) + "\n")  # Excel's top row
            arrList.append(typeStructFormat + "\n")
            outFile[typeStr] = arrList

        arrList = outFile[typeStr]
        ieList2 = arrList[0]
        snStr = ""

        if args.debugLevel:
            print("typeStr ", typeStr, ", struct size: ", struct.calcsize(typeStructFormat))
        evLastIdx = struct.calcsize('I') + struct.calcsize(typeStructFormat)

        content = byteArray[struct.calcsize('I'): evLastIdx]

        ieList = struct.unpack(typeStructFormat, content)

        if ("pduDump" in ieList2):
            pduDataOffset = 4
            controlBitOffset = 7
            controlBit = int(ieList[-1][4]) >> controlBitOffset
            pduInterpretedData = ""

            if (controlBit == 1):
                pduInterpretedData = int(binascii.b2a_hex(ieList[-1])[9:14], 16)
            else:
                pduInterpretedData = "CONTROL PDU BRO"

            ieList = ieList[:-1] + (pduInterpretedData,)

        csvStr = ",".join(([str(x) for x in ieList]))

        csvStr = csvStr + "," + snStr + "\n"

        arrList.append(csvStr)

        return csvStr, evLastIdx

    except Exception as inst:
        print("ERROR", inst)
        exc_type, exc_obj, exc_tb = sys.exc_info()
        fname = os.path.split(exc_tb.tb_frame.f_code.co_filename)[1]
        print(exc_type, fname, exc_tb.tb_lineno)
        return csvStr, errorIdx


def convertToCSV(eventHex, typeDict, flatTypeDict, domainEventList, lineNum):
    csvStr = ""

    typeStructFormat = ""
    typeStr = ""

    payloadUsedFieldHexCount = 4 * 2

    payloadUsedBytesReversedHex = eventHex[0:payloadUsedFieldHexCount]

    payloadUsedHexCount = int.from_bytes(bytes.fromhex(payloadUsedBytesReversedHex),
                                         byteorder='little') * 2  # 真实PAYLOAD长度
    realHexEnd = payloadUsedFieldHexCount + payloadUsedHexCount
    if args.debugLevel:
        print("payloadUsedHexCount: ", payloadUsedHexCount, "payloadUsedBytesReversedHex ",
              payloadUsedBytesReversedHex, ", real hex end index: ", realHexEnd)
    hexIdx = payloadUsedFieldHexCount
    prevGlob = hexIdx

    while (hexIdx < realHexEnd):
        partBytes = eventHex[hexIdx:]

        byteArray = binascii.unhexlify(partBytes)

        prevHexIdx = hexIdx

        evCsvStr, dataSize = convertEvent(byteArray, typeDict, flatTypeDict, domainEventList, hexIdx, lineNum)

        if (dataSize < errorIdx):
            csvStr = csvStr + evCsvStr
            hexIdx = prevHexIdx + dataSize * 2

        if args.debugLevel:
            print("handled part of line ", lineNum, ", prevHexIdx: ", prevHexIdx,
                  ", hexIdx:", hexIdx, ", hex:", eventHex[prevHexIdx:hexIdx])

    if (hexIdx != realHexEnd):
        print("ERROR didnt end at real hex end: ", realHexEnd, ", hexIdx: ", hexIdx)

    return csvStr


# Script 2 END ------------------------------------------------------------------

class IncorrectFileFormat(Exception):
    def __init__(self):
        self.msg = "File signature not matching correct snapshot or pcap format"


class TraceFileType():
    def __init__(self, file_contents):
        packed_signature = file_contents.read(struct.calcsize(self.format))
        (signature,) = struct.unpack(self.format, packed_signature)
        self.signature_found = signature == self.correct_signature
        file_contents.seek(0)


class PcapFileType(TraceFileType):
    format = ">I"
    correct_signature = 0xd4c3b2a1


class SnapshotFileType(TraceFileType):
    format = "H"
    correct_signature = 0xf00d


class BlockDumper:
    l2_snapshot_block_format = (
        "I"  # uint32_t length{0}
    )

    def __init__(self, trace_file):
        self.trace_file = trace_file

    def dump(self, block_size, block_start_offset):
        self.trace_file.seek(block_start_offset)
        block = self.trace_file.read(block_size)
        (contentLength,) = struct.unpack(
            self.l2_snapshot_block_format, block[0:4])
        contentOffset = struct.calcsize(self.l2_snapshot_block_format)
        content = block[contentOffset:contentLength + contentOffset]
        self._print_block(content)

    def _print_block(self, content):
        print(hexdump_header + ''.join(["%02X " % ord(x) for x in content]).strip())


class SeparateEventsBlockDumper(BlockDumper):
    discriminator_size = struct.calcsize("I")
    trace_payload_used_size_format = (
        "I"  # u32 tracePayload-UsedSize
    )
    stream_component_ind_common_format = (
        "<"  # little-endian and not aligned
        "Q"  # u64 swEventHeader
        "H"  # u16 l2SourceNid
        "H"  # u16 padding
        "I"  # u32 sequenceNumber
        "Q"  # u64 utcTimeStamp
    )
    trace_event_header_format = (
        "B"  # u8 domain
        "B"  # u8 typeId
        "H"  # u16 length
    )

    def _print_block(self, content):
        common_content = self._extract_common_stream_component_ind_content(content)
        used_size = self._extract_used_size(content, len(common_content))
        current_pos = start_pos = len(common_content) + struct.calcsize(self.trace_payload_used_size_format)

        while current_pos < start_pos + used_size:
            trace_event_length = self._extract_trace_length(content, current_pos + self.discriminator_size)
            self._print_common_content(common_content)
            self._print_trace_event(content, current_pos, trace_event_length)
            current_pos += trace_event_length

    def _extract_trace_length(self, content, header_position):
        packed_header = content[header_position:header_position + struct.calcsize(self.trace_event_header_format)]
        (domain, typeid, trace_event_len) = struct.unpack(self.trace_event_header_format, packed_header)
        return trace_event_len + self.discriminator_size

    def _extract_common_stream_component_ind_content(self, content):
        return content[0:struct.calcsize(self.stream_component_ind_common_format)]

    def _extract_used_size(self, content, position):
        length_of_size = struct.calcsize(self.trace_payload_used_size_format)
        packed_data = content[position:position + length_of_size]
        (used_size,) = struct.unpack(self.trace_payload_used_size_format, packed_data)
        return used_size

    def _print_common_content(self, common_content):
        fo.writelines(hexdump_header + ''.join(["%02X " % x for x in common_content]).strip() + ' ')

    def _print_trace_event(self, content, position, trace_event_length):
        packed_data = struct.pack(self.trace_payload_used_size_format, trace_event_length)
        fo.writelines(''.join(["%02X " % x for x in packed_data]))
        end_position = position + trace_event_length
        fo.writelines(''.join(["%02X " % x for x in content[position:end_position]]).strip() + '\n')


class L2TraceStreamPcapDumper(SeparateEventsBlockDumper):
    def strip_headers_and_dump(self):
        for line in L2TracePcapStripper(self.trace_file):
            self._print_block(line)


class L2Snapshot:
    l2_snapshot_header_format_version = 1
    l2_snapshot_header_format = (
        "H"  # uint16_t snapfileIdTag{0xf00d}
        "H"  # uint16_t VersionNumber{0x1}
        "I"  # uint32_t headerLength{sizeof(Header)}
        "I"  # uint32_t blockSize{0}
        "I"  # uint32_t maxBlockCount{0}
        "I"  # uint32_t nextBlock{0}
        "Q"  # uint64_t cumulativeBlockCount{0}
    )
    l2_snapshot_block_size_sanity_limit = 10240

    def __init__(self, trace_file, block_dumper):
        l2_snapshot_header_format_length = struct.calcsize(
            self.l2_snapshot_header_format)
        fo.writelines('# --- L2 trace snapshot ---' + '\n')
        fo.writelines('# Encapsulation: UDP with source port %d' % l2_trace_udp_port_number + '\n')
        fo.writelines('# Header length: %d' % l2_snapshot_header_format_length + '\n')
        l2_snapshot_header = trace_file.read(l2_snapshot_header_format_length)
        (self.snapfileIdTag, self.versionNumber,
            self.headerLength, self.blockSize,
            self.maxBlockCount, self.nextBlock,
            self.cumulativeBlockCount) = struct.unpack(self.l2_snapshot_header_format, l2_snapshot_header)
        self.block_dumper = block_dumper

    def print_header(self):
        fo.writelines('# Tag: 0x%04x version: %d' % (
            self.snapfileIdTag, self.versionNumber) + '\n')
        fo.writelines('# First block: %d' % self._get_first_block_index() + '\n')
        fo.writelines('# Block size: %d' % self._get_block_size() + '\n')
        fo.writelines('# Used block count: %d' % self._get_used_block_count() + '\n')
        fo.writelines('# Max block count: %d' % self._get_max_block_count() + '\n')

    def is_header_valid(self):
        return self._is_snapfile_idtag_valid() and self._is_version_number_valid() and self._is_block_size_valid()

    def _is_snapfile_idtag_valid(self):
        if self.snapfileIdTag != SnapshotFileType.correct_signature:
            print('Error: file identification tag not expected ( should be 0x%04x )'
                  % SnapshotFileType.correct_signature)
            return False
        return True

    def _is_version_number_valid(self):
        if self.versionNumber != self.l2_snapshot_header_format_version:
            print('Error: file format version not expected ( should be %d )'
                  % self.l2_snapshot_header_format_version)
            return False
        return True

    def _is_block_size_valid(self):
        if self._get_block_size() > self.l2_snapshot_block_size_sanity_limit:
            print('Error: block size too big ( should be <= %d )' % self.l2_snapshot_block_size_sanity_limit)
            return False
        return True

    def dump_all_blocks(self, trace_file):
        usedBlockCount = self._get_used_block_count()
        currentBlock = self._get_first_block_index()
        maxBlockCount = self._get_max_block_count()

        granularity = usedBlockCount / 100
        originUsedBlockCount = usedBlockCount
        lastPercentage = 0

        global total_lines
        startFromLastBlock = False
        if total_lines == args.tail:
            startFromLastBlock = True
            print("startFromLastBlock")
            if currentBlock > 0:
                currentBlock -= 1  # 循环覆盖写入，so the last one should be （firstBlock - 1）
            if currentBlock == 0:
                currentBlock = usedBlockCount - 1

        if args.debugLevel:
            print("granularity", granularity, "maxBlockCount", maxBlockCount,
                  "usedBlockCount", usedBlockCount, "FirstBlock", currentBlock)
        ParsedBlockCount = total_lines // 300  # 300 is average trace event among one block
        if ParsedBlockCount >= usedBlockCount:
            ParsedBlockCount = usedBlockCount
        # print("ParsedBlockCount", ParsedBlockCount)
        # print(maxBlockCount, usedBlockCount, granularity, currentBlock)
        while usedBlockCount > 0 and ParsedBlockCount != 0:
            start_offset = self._get_header_length() + currentBlock * self._get_block_size()
            # print(start_offset, self._get_header_length(), currentBlock, self._get_block_size())
            self.block_dumper.dump(self._get_block_size(), start_offset)
            usedBlockCount -= 1
            if (startFromLastBlock is False):
                currentBlock += 1
                if currentBlock >= maxBlockCount:
                    currentBlock = 0
            else:
                currentBlock -= 1
                if currentBlock <= 0:
                    currentBlock = maxBlockCount - 1
            ParsedBlockCount -= 1
            # progessBar
            currentPercentage = int((originUsedBlockCount - usedBlockCount) / granularity)
            if currentPercentage != lastPercentage:
                self._print_progressbar(currentPercentage)
                lastPercentage = currentPercentage
        # print(start_offset, self._get_header_length(), currentBlock, self._get_block_size())

    def _print_progressbar(self, currentHandledPercentage):
        str = '>' * (currentHandledPercentage // 2) + ' ' * ((100 - currentHandledPercentage) // 2)
        sys.stdout.write('\r' + str + '[%s%%]' % (currentHandledPercentage))
        sys.stdout.flush()

    def _get_header_length(self):
        return self.headerLength

    def _get_block_size(self):
        return self.blockSize

    def _get_max_block_count(self):
        return self.maxBlockCount

    def _get_first_block_index(self):
        return self.nextBlock if (self.cumulativeBlockCount > self.maxBlockCount) else 0

    def _get_used_block_count(self):
        return self.maxBlockCount if (self.cumulativeBlockCount > self.maxBlockCount) else self.cumulativeBlockCount


def get_dumper(trace_file, use_original_output_format):
    if use_original_output_format:
        return BlockDumper(trace_file)
    else:
        return SeparateEventsBlockDumper(trace_file)


def decode_snapshot(snapshot_content, use_original_output_format):
    snapshot = L2Snapshot(snapshot_content, get_dumper(snapshot_content, use_original_output_format))
    snapshot.print_header()
    if snapshot.is_header_valid():
        snapshot.dump_all_blocks(snapshot_content)


def strip_pcap_headers_and_dump(pcap_content):
    L2TraceStreamPcapDumper(pcap_content).strip_headers_and_dump()


def decode_file(trace_filename, use_original_output_format):
    try:
        trace_file = open(trace_filename, 'rb')
    except IOError:
        print('Cannot open file: ' + trace_filename)
    else:
        decode_file_contents(trace_file, use_original_output_format)
        trace_file.close()


def decode_file_contents(file_contents, use_original_output_format):
    try:
        global file_type
        file_type = get_file_type_from_signature(file_contents)
    except IncorrectFileFormat as e:
        print(e.msg)
    else:
        if file_type is SnapshotFileType:
            decode_snapshot(file_contents, use_original_output_format)
        else:
            print("L2TracePcapStripper.py for PcapFileType may NOT ready since it still using Python2.7")
            strip_pcap_headers_and_dump(file_contents)


def get_file_type_from_signature(file_contents):
    if PcapFileType(file_contents).signature_found:
        return PcapFileType
    if SnapshotFileType(file_contents).signature_found:
        return SnapshotFileType
    raise IncorrectFileFormat()


def create_arg_parser():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
        description='''Example: {0} 5G19_5.3835.806 L2TraceHi_CU.dat
        You could also open *.bin file with Wireshark "Import From Hex Dump"
        using UDP port {1} as capsulation. Also streamed pcap file can be exploded
        so that trace events are separated into dedicated frames (then needs to be
        imported to Wireshark as hex dump).
        NOTE: 2nd param should be WHOLE build version'''
        .format(sys.argv[0], l2_trace_udp_port_number))
    parser.add_argument("buildVersion", help="The whole build version.(eg. 5G_0.8451.991 or 5G19_5.3835.806)")
    parser.add_argument("l2_trace_filename", help="Snapshot file (.dat) or streamed pcap file")
    parser.add_argument("-o", "--original",
                        help="Retain original format - do not explode events to separate StreamComponentInd events",
                        action="store_true")
    parser.add_argument("-v", "--debugLevel",
                        help="printmore debug information to the terminal for debug purpose",
                        action="store_true",
                        default=False)
    parser.add_argument("--head", help="Parsing N lines from head of file, conflict with --tail options", type=int)
    parser.add_argument("--tail", help="Parsing N lines to tail of file, conflict with --head options", type=int)

    return parser


if __name__ == "__main__":
    args = create_arg_parser().parse_args()
    luaSharkFileName = "luashark-" + args.buildVersion.split('_')[1] + ".zip"
    # once ftp-server changed, you need to adapt below link
    url = "https://artifactory-espoo1.ext.net.nokia.com/artifactory/mnp5g-central-public-local/System_Release/"
    luaSharkURL = url + args.buildVersion.split('_')[1] + "/" + luaSharkFileName
    luaSharkPath = "generated_luashark" + os.sep + "itf" + os.sep + "L2Log" + os.sep
    # print(luaSharkURL)
    # print(luaSharkFileName)
    # print(luaSharkPath)

    if args.head is not None and args.head > 0:
        total_lines = args.head
    elif args.tail is not None and args.tail > 0:
        total_lines = args.tail
    elif args.head is None and args.tail is None:  # printfull trace file
        total_lines = 4294967295  # max u32
    else:
        print("Input Option is incorrect, please refer to --help.")
        sys.exit(1)
    # print(total_lines)

    print("Step 1 start: generating a Wireshark readable file from", args.l2_trace_filename)
    TempFileNameStr = args.l2_trace_filename.split('.dat')[0][-2:] + ".bin"
    # print(TempFileNameStr)
    fo = open(TempFileNameStr, "w")
    decode_file(args.l2_trace_filename, args.original)
    fo.close()
    if file_type is PcapFileType:
        print("\nStep 1 Parsing PcapFileType trace finished.")
    else:
        print("\nStep 1 finished. You can import file", TempFileNameStr, "to Wireshark if you need.")
        if not os.path.isdir(luaSharkPath):
            print("Try to download luashark...")
            try:
                urllib.request.urlretrieve(luaSharkURL, luaSharkFileName)
                cmd = "unzip " + luaSharkFileName + " \"" + luaSharkPath + "*\""
                os.system(cmd)
            except Exception as e:
                print("Error occurred when downloading file, error message:")
                print(e)

        if not os.path.isdir(luaSharkPath):
            # TODO: download from wft webpage to current dir
            print("File", luaSharkPath,
                  "does not exist. You can manually download and decompress it under this folder.")
            print("Parsing terminated!")
            sys.exit(1)
        else:
            print("Step 2 start: converting", TempFileNameStr, "to CSV file ...")
            print("Step 2.1: get domainEventList")
            domainEventList = generateEventDiscrimatorReference(luaSharkPath)
            if args.debugLevel:
                print("DOMAINEVENTLIST:")
                print(domainEventList)

            typeDict = {}
            print("Step 2.2: analyze *.lua files 1 by 1")
            generateTypeFormatAll(luaSharkPath, typeDict)
            if args.debugLevel:
                print("TYPEDICT")
                print(typeDict)

            print("Step 2.3: extract all IEs' strcut for every trace type in specific domain")
            flatTypeDict = generateFlatStruct(domainEventList, typeDict)
            if args.debugLevel:
                printFlatStruct(flatTypeDict)

            xlsList = generateXlsFile(TempFileNameStr, typeDict, flatTypeDict, domainEventList)

            print("Step 2.4: start generating CSV files")
            for k, v in outFile.items():
                fo = open(k + ".csv", "w")
                fo.writelines(v)
                fo.close()

                with open(k + ".csv", mode='r') as csvfile:
                    reader = csv.reader(csvfile, delimiter=",")
                    # omit header
                    header = next(reader, None)
                    # omit some crap in 2nd line
                    secondLineCrap = next(reader, None)
                    sortedlist = sorted(reader,
                                        key=lambda row: (
                                            int(row[3]), int(row[4]), int(row[5]), int(row[6]), int(row[7])))
                    with open(k + "_sorted.csv", 'w', newline='') as writeFile:
                        csvWriter = csv.writer(writeFile, delimiter=",")
                        csvWriter.writerow(header)
                        csvWriter.writerows(sortedlist)
                        print("Sorted trace in", k + "_sorted.csv is generated.")
            print("Converting finished.")
