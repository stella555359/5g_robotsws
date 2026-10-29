import os
import re
from robot.api import logger


class ParserError(Exception):
    """Base exception."""
    pass


class NoFilesToVerifies(ParserError):
    """Throws when directory with file to verify is empty."""
    pass


class FrameError(ParserError):
    """Throws when frame could not be parsed."""
    pass


class RatioUnderExpectedError(ParserError):
    """Throws when ratio does not have expected value."""
    pass


class Slot:
    """Single slot in frame."""

    def __init__(self, value):
        self.value = value

    def __str__(self):
        return self.value

    def __repr__(self):
        return 'Slot({})'.format(self.value)


class Frame:
    """Single frame in syslog line."""

    def __init__(self, text):
        self.text = text

    def slots(self):
        """
        Gets all slots.

        :return: list of slots
        """

        raw_slots = self.text.split('|')
        return [Slot(raw_slot) for raw_slot in raw_slots]

    def slot(self, n):
        """
        Gets single slot by id.

        :param n: ID of slot
        :return: slot
        """

        return self.slots()[n]

    def __str__(self):
        return ' | '.join([str(slot) for slot in self.slots()])

    def __repr__(self):
        return 'Frame<{}>'.format(self.slots())


class Line:
    """Line of syslog."""

    def __init__(self, text):
        self.text = text

    def is_dynamic_pdcch_logger_line(self, bwp_idx):
        """
        Checks if line contains "DynamicPdcchLogger.cpp" and "BwpIdx=<id>" frases.
        :param bwp_idx: index of bwp profile
        :return: True if line contains indicated frases, otherwise False
        """

        if 'DynamicPdcchLogger.cpp' in self.text:
            return bool(re.findall(r'BwpIdx={}'.format(bwp_idx), self.text))

        return False

    def frames(self):
        """
        Gets all frames.

        :return: list of frames
        """

        frames_text = re.findall(r'\|.*\|\|', self.text)

        if len(frames_text) == 0:
            raise FrameError('Regex r"\\|.*\\|\\|" not found any frames in text: {}'.format(self.text))

        raw_frames = frames_text[0].lstrip('|').rstrip('||').split('||')
        return [Frame(raw_frame) for raw_frame in raw_frames]

    def frame(self, n):
        """
        Gets single frame by id.

        :param n: ID of frame
        :return: frame
        """

        return self.frames()[n]


class FrameRatioCounter:
    """Frame counter."""

    def __init__(self, name):
        self.name = name

        self.frames_before_change = 0
        self.frames_after_change = 0
        self.unreadable_frames = 0

    def increment_frames_before_change(self):
        """
        Increments number of frames before cee split enable.

        :return: None
        """

        self.frames_before_change += 1

    def increment_frames_after_change(self):
        """
        Increments number of frames after cee split enable.

        :return: None
        """

        self.frames_after_change += 1

    def increment_unreadable_frames(self):
        """
        Increments number of frames which could not be classified to frames after or before cee split enable.

        :return: None
        """

        self.unreadable_frames += 1

    def ratio(self, in_percentage=True):
        """
        Calculates ratio of frames after cee split enable to other.

        :param in_percentage: result will be multiplied by 100%
        :return: ratio
        """

        result = self.frames_after_change / (self.frames_after_change +
                                             self.frames_before_change +
                                             self.unreadable_frames)
        if in_percentage:
            result *= 100
        return result


def verify_if_cce_split_was_enabled_for_bwp(syslogs_dir, bwp_idx, change_ratio=60):
    """
        Verify if cce split was enabled for bwp profile.

        :param syslogs_dir: directory with syslogs to verify; all given files in directory will be sorted by name
        :param bwp_idx: BWP profile index
        :param change_ratio: expected ratio of frames change for slot 2 and slot 12 as int
        :return: None
        """
    cce_split_verifier = CceSplitVerifier()

    for fp, fh in cce_split_verifier.sorted_files(syslogs_dir):

        logger.info('Processing file: {}'.format(fp))

        for raw_line in fh:

            line = Line(raw_line)

            if line.is_dynamic_pdcch_logger_line(bwp_idx):
                cce_split_verifier.process_line(line)

    cce_split_verifier.verify_frames_ration(int(change_ratio))


class CceSplitVerifier:
    """Robot library to cce split was enable."""

    SLOT_VALUE_CCE_SPLIT_OFF = ['2DU_', '2UD_']
    SLOT_VALUE_CCE_SPLIT_ON = ['1S__', '2SU_']

    def __init__(self):

        self.frames_counters = [
            FrameRatioCounter(2),
            FrameRatioCounter(12)
        ]

        self.unreadable_values = set()

    def process_line(self, line):
        """
        Processes single line of frames. Dumps line to frames and checks slots values.

        :param line: line of syslog file
        :return: None
        """

        try:
            frames = line.frames()
        except FrameError:
            logger.warn('There is no any frames in line: {}'.format(line))
        else:
            for frame in frames:
                for counter in self.frames_counters:
                    self._process_frame_slot(frame, counter.name, counter)

    def _process_frame_slot(self, frame, slot_id, counter):
        """
        Processes single frame. Grabs and checks value of given slots.

        :param frame: frame to check
        :param slot_id: ID of slot
        :param counter: counter to update
        :return: updated counter
        """

        slot = frame.slot(slot_id)

        if slot.value in self.SLOT_VALUE_CCE_SPLIT_OFF:
            counter.increment_frames_before_change()
        elif slot.value in self.SLOT_VALUE_CCE_SPLIT_ON:
            counter.increment_frames_after_change()
        else:
            self.unreadable_values.add(slot.value)
            counter.increment_unreadable_frames()

        return counter

    @staticmethod
    def sorted_files(directory):
        """
        Returns file handlers for sorted files in given directory.

        :param directory: Directory path
        :return: generator of tuples with file path and file handler
        """

        files = sorted(os.listdir(directory))

        if len(files) == 0:
            raise NoFilesToVerifies('There are no files to verifies in {}'.format(directory))

        for file in files:
            file_path = os.path.join(directory, file)

            with open(file_path) as file_handler:
                yield file_path, file_handler

    def verify_frames_ration(self, expected_ratio):
        """
        Verifies ratio of frames before change and after change slots value.

        :param expected_ratio: expected ration, if ratio is lower it raises error
        :return: None
        """
        slots_cce_off = " ".join(CceSplitVerifier.SLOT_VALUE_CCE_SPLIT_OFF)
        slots_cce_on = " ".join(CceSplitVerifier.SLOT_VALUE_CCE_SPLIT_ON)
        slots_cce_off_on = "{} {}".format(slots_cce_off, slots_cce_on)
        for counter in self.frames_counters:
            msg = 'Frames with "{}" in slot {}: {}\n' \
                  'Frames with "{}" in slot {}: {}\n' \
                  'Frames with value different  from "{}" in slot {}: {}\n' \
                  'Different values found: {}'
            logger.info(
                msg.format(
                    slots_cce_off, counter.name, counter.frames_before_change,
                    slots_cce_on, counter.name, counter.frames_after_change,
                    slots_cce_off_on, counter.name, counter.unreadable_frames,
                    self.unreadable_values
                )
            )

            ratio = counter.ratio()
            logger.info('<strong>Frames change ration in slot {}: {}%</strong>'.format(counter.name, ratio), html=True)

            if ratio < expected_ratio:
                msg = 'Ratio ({}) after cce split enabling is under expected level ({}) in slot {}'
                raise RatioUnderExpectedError(msg.format(ratio, expected_ratio, counter.name))
