# -*- coding: utf-8 -*-
import io
import unittest
import sys
import struct
import L2TraceFastRingDecoder as decoder


class TestL2TraceFastRingDecoder(unittest.TestCase):

    def setUp(self):
        self.old_stdout = sys.stdout
        sys.stdout = io.BytesIO()
        self.snapshot_gen = SnapshotGenerator()
        self.expected_pcap_output = \
            self._decode_trace_block([0xbc9a7856], "I", False) + "\n" + \
            self._decode_trace_block([0x3412], "H", False) + "\n" + \
            self._decode_trace_block([0xbe57], "H", False)

    def tearDown(self):
        sys.stdout = self.old_stdout

    def test_can_decode_in_original_format(self):
        decoder.decode_file_contents(self.snapshot_gen.generate(), True)
        output = sys.stdout.getvalue().strip()
        self.assertEquals(output, self.snapshot_gen.expected_snapshot_header +
                          self._decode_trace_block([0x3412, 0xbe57], "H", True) + "\n" +
                          self._decode_trace_block([0xbc9a7856], "I", True))

    def test_can_decode_into_separate_blocks(self):
        decoder.decode_file_contents(self.snapshot_gen.generate(), False)
        output = sys.stdout.getvalue().strip()
        self.assertEquals(output, self.snapshot_gen.expected_snapshot_header +
                          self._decode_trace_block([0x3412], "H", False) + "\n" +
                          self._decode_trace_block([0xbe57], "H", False) + "\n" +
                          self._decode_trace_block([0xbc9a7856], "I", False))

    def test_FileNotFound(self):
        traceFileName = 'fileThatDoesNotExist.dat'
        decoder.decode_file(traceFileName, True)
        output = sys.stdout.getvalue().strip()
        self.assertEquals(output, 'Cannot open file: fileThatDoesNotExist.dat')

    def test_given_pcap_with_ipv4_can_strip_headers_and_explode_to_separate_blocks(self):
        decoder.decode_file_contents(PcapGeneratorIPv4().generate_pcap_file(), False)
        self.assertEquals(sys.stdout.getvalue().strip(), self.expected_pcap_output)

        sys.stdout = io.BytesIO()

        decoder.strip_pcap_headers_and_dump(PcapGeneratorIPv4NoOptions().generate_pcap_file())
        self.assertEquals(sys.stdout.getvalue().strip(), self.expected_pcap_output)

    def test_given_pcap_with_ipv6_can_strip_headers_and_explode_to_separate_blocks(self):
        decoder.decode_file_contents(PcapGeneratorIPv6().generate_pcap_file(), False)
        output = sys.stdout.getvalue().strip()
        self.assertEquals(output, self.expected_pcap_output)

    def test_incorrect_format_gives_error(self):
        decoder.decode_file_contents(PcapGeneratorIncorrectPcapSignature().generate_pcap_file(), False)
        output = sys.stdout.getvalue().strip()
        self.assertEquals(output, decoder.IncorrectFileFormat().msg)

    def _decode_trace_block(self, trace_item_dynamic_content_list, dynamic_content_format, using_original_format):
        traces = ''.join(self.snapshot_gen.generate_trace_items(
            trace_item_dynamic_content_list, dynamic_content_format))
        content = self.snapshot_gen.generate_snapshot_block(traces, using_original_format)
        return '000000 ' + ''.join(["%02X " % ord(x) for x in content]).strip()


class SnapshotGenerator():
    block_size = 52
    snapfile_id_tag = 0xf00d
    version_number = 0x1
    header_length = 32
    max_block_count = 2
    nextBlock = 1
    cumulative_block_count = 3
    expected_snapshot_header = '''# --- L2 trace snapshot ---
# Encapsulation: UDP with source port {0}
# Header length: {1}
# Tag: {2} version: 1
# First block: {3}
# Block size: {4}
# Used block count: {5}
# Max block count: {5}
'''.format(decoder.l2_trace_udp_port_number, header_length, hex(snapfile_id_tag), 1, block_size, max_block_count)

    def generate(self):
        snapshotHeader = struct.pack("HHIIIIQ",
                                     self.snapfile_id_tag,
                                     self.version_number,
                                     self.header_length,
                                     self.block_size,
                                     self.max_block_count,
                                     self.nextBlock,
                                     self.cumulative_block_count)

        block_1_content = self.generate_snapshot_block(''.join(self.generate_trace_items([0xbc9a7856], "I")))
        block_2_content = self.generate_snapshot_block(''.join(self.generate_trace_items([0x3412, 0xbe57], "H")))

        block_1_size = struct.pack("I", len(block_1_content))
        block_2_size = struct.pack("I", len(block_2_content))

        return io.BytesIO(snapshotHeader + block_1_size + block_1_content + block_2_size + block_2_content)

    def generate_snapshot_block(self, trace_items, pad_until_block_size=True):
        trace_items_used_size = struct.pack("I", len(trace_items))
        common_event_content = struct.pack("=QHHIQ",
                                           0x1234abcd5678dcba,  # swEventHeader
                                           0x1170,  # l2SourceNid
                                           0,  # padding
                                           0x1012,  # seqNum
                                           0x070c1e3b000611aa)  # timestamp
        content = common_event_content + trace_items_used_size + trace_items
        while len(content) < self.block_size - 4 and pad_until_block_size:
            content += struct.pack("B", 0)
        return content

    def generate_trace_items(self, trace_item_dynamic_content_list, dynamic_content_format):
        trace_item_format = ("="
                             "I"  # discriminator
                             "B"  # domain
                             "B"  # typeid
                             "H")  # trace length
        for dynamic_content in trace_item_dynamic_content_list:
            # don't count discriminator to length
            trace_item_length = struct.calcsize("=BBH" + dynamic_content_format)
            yield struct.pack(trace_item_format + dynamic_content_format, 1, 4, 3, trace_item_length, dynamic_content)


class PcapGeneratorIPv4(SnapshotGenerator):
    _ether_type = 0x0800
    _pcap_signature = 0xd4c3b2a1

    def generate_pcap_file(self):
        global_pcap_header = struct.pack(">IHHiIII", self._pcap_signature, 2, 3, 4, 5, 6, 7)

        trace_1_content = self.generate_snapshot_block(''.join(self.generate_trace_items([0xbc9a7856], "I")))
        frame_1_content = self._frame_header(trace_1_content) + trace_1_content

        trace_2_content = self.generate_snapshot_block(''.join(self.generate_trace_items([0x3412, 0xbe57], "H")))
        frame_2_content = self._frame_header(trace_2_content) + trace_2_content

        return io.BytesIO(global_pcap_header + frame_1_content + frame_2_content)

    def _frame_header(self, trace_content):
        header_content = self._ethernet_header() + self._ip_header() + self._udp_header()
        packet_pcap_header = struct.pack("IIII", 8, 9, len(header_content) + len(trace_content), 11)
        return packet_pcap_header + header_content

    def _ethernet_header(self):
        dest = struct.pack("BBBBBB", 6, 6, 6, 6, 6, 6)
        source = struct.pack("BBBBBB", 7, 7, 7, 7, 7, 7)
        ether_type = struct.pack("!H", self._ether_type)
        return dest + source + ether_type

    def _ip_header(self):
        header_len = 6
        return struct.pack(">BBBBIIIII", header_len, 10, 10, 10, 0xffff, 0xffff, 0xffff, 0xffff, 0xffff)

    def _udp_header(self):
        return struct.pack("II", 8, 8)


class PcapGeneratorIPv4NoOptions(PcapGeneratorIPv4):
    minimum_header_length = 5  # No options

    def _ip_header(self):
        return struct.pack(">BBBBIIII", self.minimum_header_length, 10, 10, 10, 0xffff, 0xffff, 0xffff, 0xffff)


class PcapGeneratorIncorrectPcapSignature(PcapGeneratorIPv4):
    _ether_type = 0x0800
    _pcap_signature = 0xffc3b2a1


class PcapGeneratorIPv6(PcapGeneratorIPv4):
    _ether_type = 0x86dd

    def _ip_header(self):
        return struct.pack("QQQQQ", 0xffff, 0xffff, 0xffff, 0xffff, 0xffff)


if __name__ == '__main__':
    unittest.main(module=__name__, buffer=True, exit=False)
