# -*- coding: utf-8 -*-
import json
import logging
import os
import re
import shlex
import subprocess
import time

from functools import partial

from robot.utils import timestr_to_secs
from process_manager import ProcessManager


logger = logging.getLogger(__name__)


def _absnorm(path):
    """Returns normalized, absolute path"""
    path = os.path.normpath(os.path.expanduser(path.replace("/", os.sep)))
    return os.path.abspath(path)


class CaptureFilterError(Exception):
    """Raises when provided capture filter is invalid"""

    def __init__(self, filter, msg):
        self.filter = filter
        self.msg = msg

        # crop message to most significant part
        match = re.match(
            r".*^That string isn't a valid capture filter \((.+)\)\.$",
            self.msg,
            flags=re.MULTILINE | re.DOTALL,
        )
        if match:
            self.msg = match.group(1)

    def __str__(self):
        return '"%s" is not a valid capture filter (%s).' % (self.filter, self.msg)


def decode(file, outformat="text", dispfilter=""):
    """Returns pcap file content in human readable format.

    Can apply optional display filter before decoding data. Only packets
    matching filter condition will be returned.

    :param str file: path to file to convert
    :param str outformat: format of the output, one of: pdml|json|text
    :param str dispfilter: filter to apply before returning decoded data.
    :return: plain text representation of the file (in requested format)
    :rtype: str
    """
    if outformat not in ["pdml", "json", "text"]:
        raise ValueError(
            'Invalid output format"{}". It must be one of: '
            '"pdml", "json", "text"'.format(outformat)
        )
    format_flags = "-T text -V" if outformat == "text" else "-T %s" % outformat
    cmd = 'tshark -r "{infile}" {filter} {format}'.format(
        infile=file, filter=dispfilter and '-Y "%s"' % dispfilter, format=format_flags,
    )
    logger.info('Decoding file "%s" into %s format.' % (file, outformat))
    logger.debug("Tshark command: %s" % cmd)
    try:
        output = subprocess.check_output(shlex.split(cmd), stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as err:
        logger.error(err.output.decode("utf-8"))
        raise
    return output.decode("utf-8")


class LiveCapture(object):
    """Class handling packets capturing"""

    def __init__(self):
        self.pm = ProcessManager()

    def start(self, interfaces, outfile, capture_filter="", name="tshark"):
        """Starts packet capturing

        :param list interfaces: list of interfaces to capture from
        :param str outfile: target file where captured packets will be saved
        :param str capture_filter: default capture filter expression
        :param str name: tshark's session name; used to distinguish between
            multiple instances of tshark (has to be unique). Use this parameter
            if you wish to run multiple capturing sessions at once.
        """
        cmd = 'tshark -F pcapng {filter} -i {iface} -w "{outfile}" -q'.format(
            filter=capture_filter and '-f "%s"' % capture_filter,
            iface=" -i ".join(interfaces),
            outfile=outfile,
        )
        logger.debug("Tshark command: %s" % cmd)

        self.pm.start_process(name, shlex.split(cmd), stdout=subprocess.PIPE, stderr=subprocess.STDOUT)

        # wait for tshark to parse list of network interfaces
        p = self.pm._processes[name]
        while True:
            output = p._process.stdout.readline()
            if "Capturing on" in output.decode("utf-8"):
                break

        time.sleep(1)  # let tshark process rest of the arguments
        if not self.pm.is_process_running(name):
            err_msg = self.pm.get_output(name)[0].decode("utf-8")
            self.pm.release_alias(name)
            raise RuntimeError(err_msg)
        logger.debug("Started capturing. PID: %d" % self.pm.get_pid(name))

    def stop(self, name="tshark"):
        """Stops packet capturing

        :param str name: (optional) name of tshark session that will be stopped
        """
        terminated = False
        if self.pm.is_process_running(name):
            pid = self.pm.get_pid(name)
            logger.debug("Stopping PID: %d" % pid)
            terminated = self.pm.terminate(name, timeout=3.0)

        if terminated:
            rc = self.pm.get_return_code(name)
            output = self.pm.get_output(name)[0]
            logger.debug("PID %d stopped. RC: %d" % (pid, rc))
            if output:
                logger.debug(output.splitlines()[-1])
            self.pm.release_alias(name)
        else:
            logger.warn("Unable to stop session `%s`" % name)


class PacketsAnalyzer(object):
    """Functions for messing around with pcaps"""

    @staticmethod
    def count_packets(file_, filter_=""):
        """Return number of packets in pcap file.

        If filer is given, only packets matching the filter are being counted.

        :param str file_: path to PCAP file
        :param str filter_: wireshark's display filter (flag -Y)
        :return: packet's count
        :rtype: int
        """

        data = decode(file_, outformat="json", dispfilter=filter_)
        return len(json.loads(data))

    def check_packets_sequence(self, file_, *conditions_sequence):
        """Checks if given packets sequence can be found in pcap file.

        Packets sequence is passed as list of conditions (display filters).
        Method looks for first occurrence of matching packet that is after
        last one.

        :param str file_: path to PCAP file
        :param list[str] conditions_sequence: list of display filters (-Y flag)
        :return: True if sequence can be found, otherwise false
        :rtype: bool
        """
        packet_series = map(partial(decode, file_, "json"), conditions_sequence)

        sequence_results = []
        for filter_results, condition in zip(packet_series, conditions_sequence):
            frame_times = self._get_frame_times(json.loads(filter_results))
            logger.debug(
                "Condition {0}. Found packets at: {1}" "".format(condition, frame_times)
            )
            logger.debug("Check if there is frame suitable as next in sequence")
            next_frame_in_sequence = self._look_for_next_frame_in_sequence(
                frame_times, sequence_results
            )
            sequence_results.append((condition, next_frame_in_sequence))
        return self._sequence_verdict(sequence_results)

    def _look_for_next_frame_in_sequence(self, frame_times, sequence_results):
        """Iterates over list of frame times, checking if there is any frame
        suitable as next in sequence.

        :param list[float] frame_times: list of frame epoch times
        :param list[tuple] sequence_results: list of results used for
            verification of sequence, contains tuples with condition
            and corresponding frame epoch time in sequence
        :return: frame number if there is valid frame, otherwise -1
            (means no frame can be set as next in sequence)
        :rtype: int
        """
        for frame_time in frame_times:
            if len(sequence_results) == 0:
                logger.debug(
                    "Sequence results list is empty."
                    " Add frame at: {0}".format(frame_time)
                )
                return frame_time
            else:
                last_frame_time_in_sequence = sequence_results[-1][1]
                if frame_time > last_frame_time_in_sequence:
                    logger.debug(
                        "Frame at {0} is later than last frame in sequence result"
                        "at {1}. Add frame at: {0}"
                        "".format(frame_time, last_frame_time_in_sequence)
                    )
                    return frame_time
        logger.debug("No suitable frame has been found")
        return -1

    def _get_frame_times(self, filter_results):
        """Reads JSON data (matching packets) for each sequence condition

        Returns frame epoch times of filtered packets.

        :param generator filter_results: list of JSON data (matching packets)
            collected from reading PCAP file with condition (display filter)
            from sequence conditions
        :return: list of frame epoch times
        :rtype: list[float]
        """
        frame_times = [
            float(result["_source"]["layers"]["frame"]["frame.time_epoch"])
            for result in filter_results
        ]
        return frame_times

    def _sequence_verdict(self, sequence_results):
        """Checks if collected sequence is correct.

        Frame epoch times have to be arranged in ascending order for sequence to be
        correct.

        :param list[tuple] sequence_results: list of results used for
            verification of sequence, contains tuples with condition
            and corresponding frame epoch time in sequence
        :return: True is sequence is correct, otherwise False
        :rtype: bool
        """
        logger.debug("Raw sequence results: {}".format(sequence_results))
        frame_times = [frame_time for condition, frame_time in sequence_results]
        logger.debug("Extracted frame epoch times: {}".format(frame_times))
        matches = [
            frame_times[i] < frame_times[i + 1]
            for i in range(len(frame_times) - 1)
        ]
        logger.debug("Sequence matches: {}".format(matches))
        verdict = all(matches)
        logger.debug("Sequence verdict: {}".format(verdict))
        return verdict


class tshark(object):  # noqa N801
    """Robot Framework test library for packet capture and offline analysis"""

    ROBOT_LIBRARY_SCOPE = "TEST SUITE"
    ROBOT_LIBRARY_DOC_FORMAT = "REST"

    def __init__(self):
        self.capture = LiveCapture()
        self._packets_analyzer = PacketsAnalyzer()
        self.sessions = []
        self.capture_files = []

    def __del__(self):
        for i in range(len(self.sessions)):
            self.stop_packets_capturing()

    def start_packets_capturing(
        self, interfaces, outfile, capture_filter=None, session_name=None
    ):
        """Starts capturing packets in the background.

        What and where to capture is set with ``interface``, ``outfile``,
        and ``capture_filter`` exactly like in keyword ``Capture Packets``.

        It is possible to run multiple capture sessions at the same time.
        Session can be referred in other keywords by its ``session_name``.
        By default, each invocation of *this* keyword starts a new session,
        with name equal to ``output_file``. A custom ``session_name`` can be
        provided as an alias for started session, which can be then used to
        stop capturing session with ``Stop Packets Capturing`` keyword.

        Returns started session name.

        Examples:

        ======================  ====  ==========  ==============  =====
        Start Packet Capturing  any   all.pcap
        Start Packet Capturing  eth1  fsm.pcap    dst port 51000
        Start Packet Capturing  eth3  egate.pcap  sctp            egate
        ======================  ====  ==========  ==============  =====

        =>

        ::

            all.pcap
            syslog
            egate

        """

        # sanitize inputs
        try:
            ifaces = list(interfaces.split(","))
        except AttributeError:
            ifaces = [s for s in interfaces]

        name = session_name or outfile
        if name in self.sessions:
            raise ValueError(
                "{} already in use; session_name has to be unique.".format(name)
            )

        if capture_filter:
            try:
                # use tshark itself to check capture filter syntax
                subprocess.check_output(
                    ["tshark", "-a", "duration:1", "-f", capture_filter],
                    stderr=subprocess.STDOUT,
                )
            except subprocess.CalledProcessError as err:
                raise CaptureFilterError(capture_filter, err.output.decode("utf-8"))

        path = _absnorm(outfile)
        parent = os.path.dirname(path)
        if not os.path.exists(parent):
            logger.debug("Parent folder does not exist, creating %r" % parent)
            os.makedirs(parent)

        # do the actual thing
        logger.info(
            "Start packets capturing session `{}`"
            " on interfaces: {}".format(name, ifaces)
        )
        self.capture.start(
            interfaces=ifaces,
            outfile=path,
            capture_filter=capture_filter or "",
            name=name,
        )

        self.sessions.append(name)
        return name

    def stop_packets_capturing(self, session_name=None):
        """Stops packets capturing session.

        If ``session_name`` was not provided, keyword will stop the latest
        started session. See ``Start Packets Capturing`` for details about how
        ``session_name`` is being set.

        Examples:

        =======================  =========  =========  =======================
        # using session names
        Start Packets Capturing  eth1       eth1.pcap  session_name=first
        Start Packets Capturing  eth2       eth2.pcap  session_name=second
        Start Packets Capturing  eth3       eth3.pcap  session_name=third
        Stop Packets Capturing   first                 # stops first session
        Stop Packets Capturing   third                 # stops third session
        Stop Packets Capturing   second                # stops second session
        # no session names
        Start Packets Capturing  eth1       eth1.pcap  # first session
        Start Packets Capturing  eth2       eth2.pcap  # second session
        Start Packets Capturing  eth3       eth3.pcap  # third session
        Stop Packets Capturing                         # stops third session
        Stop Packets Capturing   eth1.pcap             # stops first session
        Stop Packets Capturing                         # stops second session
        =======================  =========  =========  =======================

        """
        if session_name:
            self.sessions.remove(session_name)
        else:
            session_name = self.sessions.pop()
        logger.info("Stop packets capturing session `{}`".format(session_name))
        self.capture.stop(name=session_name)

    def capture_packets(self, duration, interfaces, outfile, capture_filter=None):
        """Captures packets for given time.

        ``duration`` may be either a number or a time string. Time strings are
        in a format such as ``1d 2h 3m 4s 5ms``, and they are fully explained
        in Robot Framework's `User Guide`_.

        Capture ``interfaces`` can be provided either as name, comma separated
        list of names, or a list object. Following notations are equivalent:

        ===============  ===========  =============  ====================
        ${interfaces}=   Create List  eth3           eth4
        Capture Packets  2m 30s       ${interfaces}  some.pcap
        Capture Packets  2m 30s       eth3,eth4      ${EXECDIR}/some.pcap
        ===============  ===========  =============  ====================

        Captured packets will be stored under ``outfile``, in *pcapng* format.
        Number of packets saved can by limited using ``capture_filter``.
        For a syntax reference, see the manual page of `pcap-filter(7)`_.
        Default is no filter.

        Examples:

        ===============  =========  =========  =========  ===================
        capture packets  5          any        file.pcap
        capture packets  5 seconds  eth0,eth1  ping.pcap  capture_filter=icmp
        capture packets  5s         ${ifaces}  echo.pcap  icmp[icmptype] == 8
        ===============  =========  =========  =========  ===================

        Please see ``Start Packet Capturing`` if you wish to run other keywords
        while packets are being captured.

        .. _`User Guide`: https://robotframework.org/robotframework/latest/RobotFrameworkUserGuide.html#time-format
        .. _`pcap-filter(7)`: https://linux.die.net/man/7/pcap-filter
        """
        seconds = timestr_to_secs(duration)

        self.start_packets_capturing(interfaces, outfile, capture_filter)
        time.sleep(seconds)
        self.stop_packets_capturing()

    @staticmethod
    def convert_pcap_file(infile, outfile=None, format="json", filter=None):
        """Converts ``infile`` into ``format`` and saves it under ``outfile``.

        Returns absolute path to resulting file.

        ``outfile`` may be omitted. If so, resulting file will be stored in
        same directory as ``infile``, with the same name, and extension changed
        to match the chosen format of file conversion.

        ``format`` may be one of: ``pdml``, ``json`` or ``text``.

        An optional *display* ``filter`` can be provided to filter out packets.
        Only packets matching filter condition will be saved into ``outfile``.
        See `wireshark wiki`_ for a syntax reference.

        Examples:

        =================  ==========  ===========  ====  ==================
        Convert Pcap File  input.pcap  output.txt   text
        Convert Pcap File  input.pcap  output.json  json  iphy.cell_id == 11
        Convert Pcap File  file.pcap
        Convert Pcap File  file.pcap   format=pdml
        =================  ==========  ===========  ====  ==================

        =>

        ::

            output.txt
            output.json
            file.json
            file.pdml

        .. _`wireshark wiki`: https://wiki.wireshark.org/DisplayFilters
        """
        content = decode(_absnorm(infile), format, filter or "")

        if outfile:
            path = _absnorm(outfile)
            parent = os.path.dirname(path)
            if not os.path.exists(parent):
                os.makedirs(parent)
        else:
            path = _absnorm(infile)
            basename_no_extension = os.path.splitext(os.path.basename(path))[0]
            path = os.path.join(
                os.path.dirname(path), "%s.%s" % (basename_no_extension, format),
            )
        with open(path, "w") as fp:
            fp.write(content)
        return path

    def check_if_packets_are_in_given_sequence(self, file, *filters):
        """Checks if packets sequence occurred during capture in PCAP ``file``.

        Returns ``True``, if it is possible to find packets in ``file`` that
        are ordered in a sequence described by list of display ``filters``.

        See `wireshark wiki`_ for complete *display filter* syntax reference.

        Packets do not have to occur directly one after another.
        Only their order relative to each other is taken into consideration
        (all packets betwixt not matching given filters are being ignored)
        and only one packet from given group has to match the sequence.

        Example:

        ==============  ======================================  ==============  =======  ========
        ${ECHO}         Set Variable                            icmp.type == 8
        ${REPLY}        Set Variable                            icmp.type == 0
        ${result}       check if packets are in given sequence  ping.pcap       ${ECHO}  ${REPLY}
        Should Be True  ${result}
        ==============  ======================================  ==============  =======  ========

        Returns ``False`` if no packets matching the sequence where found.

        .. _`wireshark wiki`: https://wiki.wireshark.org/DisplayFilters
        """
        if len(filters) < 2:
            raise RuntimeError("At least two display filters are required.")

        path = _absnorm(file)
        logger.info("Check if packets sequence can be found in {}".format(path))
        return self._packets_analyzer.check_packets_sequence(path, *filters)

    def count_packets(self, file, filter=None):
        """Counts packets in given PCAP ``file`` and returns their number.

        An optional display ``filter`` can be given to count only those packets
        that match filter criteria.

        Examples:

        ==================  =============  =========  =====================
        ${packets count}=   Count Packets  ping.pcap
        ${echo requests}=   Count Packets  ping.pcap  icmp.type == 8
        ${echo responses}=  Count Packets  ping.pcap  filter=icmp.type == 0
        ==================  =============  =========  =====================

        """
        path = _absnorm(file)
        logger.info("Count packets in {}".format(path))
        result = self._packets_analyzer.count_packets(path, filter or "")
        logger.debug("Packets count: {}".format(result))
        return result
