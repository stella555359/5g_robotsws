# -*- coding: utf-8 -*-
import struct
import binascii
import sys
import argparse
from L2TracePcapStripper import L2TracePcapStripper

l2_trace_udp_port_number = 5678
hexdump_header = '000000 '


class IncorrectFileFormat(Exception):
    def __init__(self):
        self.msg = "File signature not matching correct snapshot or pcap format"


class TraceFileType():
    def __init__(self, file_contents):
        packed_signature = file_contents.read(struct.calcsize(self.format))
        (signature, ) = struct.unpack(self.format, packed_signature)
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
        "I"  # uint32_t length{0};
    )

    def __init__(self, trace_file):
        self.trace_file = trace_file

    def dump(self, block_size, block_start_offset):
        self.trace_file.seek(block_start_offset)
        block = self.trace_file.read(block_size)
        (contentLength, ) = struct.unpack(
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
        (used_size, ) = struct.unpack(self.trace_payload_used_size_format, packed_data)
        return used_size

    def _print_common_content(self, common_content):
        sys.stdout.write(hexdump_header + ''.join(["%02X " % ord(x) for x in common_content]).strip() + ' ')

    def _print_trace_event(self, content, position, trace_event_length):
        packed_data = struct.pack(self.trace_payload_used_size_format, trace_event_length)
        sys.stdout.write(''.join(["%02X " % ord(x) for x in packed_data]))
        end_position = position + trace_event_length
        print(''.join(["%02X " % ord(x) for x in content[position:end_position]]).strip())


class L2TraceStreamPcapDumper(SeparateEventsBlockDumper):
    def strip_headers_and_dump(self):
        for line in L2TracePcapStripper(self.trace_file):
            self._print_block(line)


class L2Snapshot:
    l2_snapshot_header_format_version = 1
    l2_snapshot_header_format = (
        "H"  # uint16_t snapfileIdTag{0xf00d};
        "H"  # uint16_t VersionNumber{0x1};
        "I"  # uint32_t headerLength{sizeof(Header)};
        "I"  # uint32_t blockSize{0};
        "I"  # uint32_t maxBlockCount{0};
        "I"  # uint32_t nextBlock{0};
        "Q"  # uint64_t cumulativeBlockCount{0};
    )
    l2_snapshot_block_size_sanity_limit = 10240

    def __init__(self, trace_file, block_dumper):
        l2_snapshot_header_format_length = struct.calcsize(
            self.l2_snapshot_header_format)
        print('# --- L2 trace snapshot ---')
        print('# Encapsulation: UDP with source port %d' % l2_trace_udp_port_number)
        print('# Header length: %d' % l2_snapshot_header_format_length)
        l2_snapshot_header = trace_file.read(l2_snapshot_header_format_length)
        (self.snapfileIdTag, self.versionNumber, self.headerLength, self.blockSize, self.maxBlockCount, self.nextBlock,
         self.cumulativeBlockCount) = struct.unpack(self.l2_snapshot_header_format, l2_snapshot_header)
        self.block_dumper = block_dumper

    def print_header(self):
        print('# Tag: 0x%04x version: %d' % (
            self.snapfileIdTag, self.versionNumber))
        print('# First block: %d' % self._get_first_block_index())
        print('# Block size: %d' % self._get_block_size())
        print('# Used block count: %d' % self._get_used_block_count())
        print('# Max block count: %d' % self._get_max_block_count())

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
        while usedBlockCount > 0:
            start_offset = self._get_header_length() + currentBlock * self._get_block_size()
            self.block_dumper.dump(self._get_block_size(), start_offset)
            usedBlockCount -= 1
            currentBlock += 1
            if currentBlock >= self._get_max_block_count():
                currentBlock = 0

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
        file_type = get_file_type_from_signature(file_contents)
    except IncorrectFileFormat as e:
        print(e.msg)
    else:
        if file_type is SnapshotFileType:
            decode_snapshot(file_contents, use_original_output_format)
        else:
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
        description='''Example: {0} L2TraceHi_CU.dat > L2TraceHi_CU_hexdump.txt
        Then open L2TraceHi_CU_hexdump.txt file with Wireshark "Import From Hex Dump"
        using UDP port {1} as capsulation. Also streamed pcap file can be exploded
        so that trace events are separated into dedicated frames (then needs to be
        imported to Wireshark as hex dump).
        NOTE: luashark package need to be given to Wireshark to show field names'''
        .format(sys.argv[0], l2_trace_udp_port_number))
    parser.add_argument("l2_trace_filename", help="Snapshot file (.dat) or streamed pcap file")
    parser.add_argument("-o", "--original",
                        help="Retain original format - do not explode events to separate StreamComponentInd events",
                        action="store_true")
    return parser


if __name__ == "__main__":
    args = create_arg_parser().parse_args()
    decode_file(args.l2_trace_filename, args.original)
