# python2
try:
    from itertools import izip_longest as zip_longest
except ImportError:
    pass
# python3
try:
    from itertools import zip_longest
except ImportError:
    pass
from collections import OrderedDict
import re
import sys
import os


def interpolate_step(
        x_start,
        y_start,
        x_end,
        y_end):
    """
    Interpolate attenuation values from start to end point.

    Example:

    interpolate_step(
        x_start=5,
        y_start=30,
        x_end=7,
        y_end=50)
    returns: [30, 40, 50]

    :param int x_start:
    :param int y_start:
    :param int x_end:
    :param int y_end:
    :return: List of attenuation values
    """
    return [
        int(y_start + i * (y_end - y_start) / (x_end - x_start))
        for i in range((x_end - x_start) + 1)]


def extract_section(att_file, section):
    assert os.path.exists(att_file), "Attenuator file {} not found!".format(att_file)

    with open(att_file, 'rb') as f:
        data = f.read().decode('utf-8')

        try:
            section_data = re.search(
                r"(?si)\b%s\b.*?\n(.*?)(?:\n\s*SECTION|$)" % section,
                data).group(1)
            return section_data
        except AttributeError:
            raise AssertionError("Section not found in attenuator file!")


def read_att_section(att_file, section):
    """
    Read attenuator profile section from file.

    Example:

    file.dat:

    SECTION test
        CH1 = (1,10) (10,31) (20,31) (30,55)
        CH2 = (1,55) (25,10)

    read_att_section("file.dat", "test") returns:
    [
    ['CH1:10', 'CH2:55'],
    ['CH1:12', 'CH2:53'],
    ['CH1:14', 'CH2:51'],
    ['CH1:17', 'CH2:49'],
    ['CH1:19', 'CH2:47'],
    ['CH1:21', 'CH2:45'],
    ['CH1:24', 'CH2:43'],
    ['CH1:26', 'CH2:41'],
    ['CH1:28', 'CH2:40'],
    ['CH1:31', 'CH2:38'],
    ['CH1:31', 'CH2:36'],
    ['CH1:31', 'CH2:34'],
    ['CH1:31', 'CH2:32'],
    ['CH1:31', 'CH2:30'],
    ['CH1:31', 'CH2:28'],
    ['CH1:31', 'CH2:26'],
    ['CH1:31', 'CH2:25'],
    ['CH1:31', 'CH2:23'],
    ['CH1:31', 'CH2:21'],
    ['CH1:31', 'CH2:19'],
    ['CH1:33', 'CH2:17'],
    ['CH1:35', 'CH2:15'],
    ['CH1:38', 'CH2:13'],
    ['CH1:40', 'CH2:11'],
    ['CH1:43', 'CH2:10'],
    ['CH1:45'],
    ['CH1:47'],
    ['CH1:50'],
    ['CH1:52'],
    ['CH1:55']
    ]

    :param str att_file: File with attenuator profiles.
    :param str section: Section name.
    :return: List of commands with channel name and attenuation value.
    """
    with open(att_file, 'rb') as f:
        data = f.read().decode('utf-8')

    section_data = re.search(
        r"(?si)\b%s\b.*?\n(.*?)(?:\n\s*SECTION|$)" % section,
        data).group(1)

    channel_data = OrderedDict(
        re.findall(
            r"(?m)^\s*(\w+)\s*="
            r"(.*)",
            section_data))

    for channel_name, step_string in channel_data.items():
        step_list = [
            [int(value or 1) for value in x_y]
            for x_y in re.findall(
                r"\s*\((?:(.*?),)?(.*?)\)",
                step_string)]
        resolved_step_list = []
        for i in range(len(step_list) - 1):
            resolved_step_list.append(
                interpolate_step(*(step_list[i] + step_list[i+1])))
        combined_step_list = sum(
            [
                steps[1:] if i else steps
                for i, steps in enumerate(resolved_step_list)],
            [])
        command_list = [
            "%s:%d" % (channel_name, attenuation)
            for attenuation in combined_step_list]
        channel_data[channel_name] = command_list

    zipped_command_list = [
        [command for command in commands if command]
        for commands
        in zip_longest(*channel_data.values())]

    return zipped_command_list


if __name__ == "__main__":
    print(read_att_section(*sys.argv[1:3]))
