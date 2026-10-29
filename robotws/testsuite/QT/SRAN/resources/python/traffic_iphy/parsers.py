import re
import logging
from pprint import pformat
logger = logging.getLogger(__name__)


class BearerStatsError(RuntimeError):
    pass


class BearerStats(object):
    HEADER = re.compile(
        r'^'
        r'UE\s(?P<ue_no>\d+)'  # ue number
        r',\s'
        r'bearer\s(?P<bearer_no>\d+)'  # bearer number
        r':\s'
        r'(?P<direction>(UL|DL))'  # direction
        r'\s'
        r'(?P<description>.+)'  # desc
        r'$')

    ITEM = re.compile(
            r'^'
            r'(?P<p_name>[\w\s]+)'  # paramter name
            r'(\s+|.+\s\s+)'  # mid paramter additional info
            r'(?P<p_value>\d+)'  # parameter value
            # r'\s*'
            r'.*'
            )

    ESCAPE_CHARS = re.compile('|'.join([
            r'\x1b\[\d{1,3}[lhinc]',
            r'\x1b\[\d{1,3};\d{1,3}[lhy]',
            r'\x1b\[\d+[ABCDmgKJPLMincq]',
            r'\x1b\[\d+;\d+[HfmrR]',
            r'\x1b\[[HfmKJic]',
            r'\x1b[DME78=>NOHgZc<ABCDIFGKJ\^_WXV\]]',
            r'\x1b[()][AB012]',
            r'\x1b#\d',
            r'\x1bY\d+',
            r'\x1b\/Z',
        ]))

    SIGNS_BLACKLIST = ['\x1b[K', ]  # to avoid problems with error during parsing i.e. total packets sent

    def __init__(self, out):
        # logger.info('Creating Stats from \n {}'.format(pformat(out))) # Debug
        self.stats = self._parse(out)

    def __preclean_line_out_of_escape_chars(self, line):
        line = self.ESCAPE_CHARS.sub('', line)
        return line

    def _parse(self, blob):
        stats = {}
        for line in blob.split('\n'):
            line = self.__preclean_line_out_of_escape_chars(line)
            match = self.ITEM.search(line)
            if match:
                value = match.group('p_value')
                try:
                    value = int(value)
                except Exception as e:
                    logger.info('Something went wrong: {}'.format(e))
                    pass
                stats[match.group('p_name').strip().lower().replace(' ', '_')] = value
        return stats

    @property
    def loss_rate(self):
        sent = self.stats['total_packets_sent']
        if sent == 0:
            raise BearerStatsError('No sent packets available in {}'.format(pformat(self.stats)))

        received = self.stats['total_packets_received']
        logger.info('Total packets sent: {}'.format(sent))
        logger.info('Total packets received: {}'.format(received))
        return round(float((sent - received) * 100 / sent), 2)

    @property
    def average_data_rate(self):
        logger.info('Current average data rate: {}'.format(self.stats['average_data_rate']))
        return self.stats['average_data_rate']

    def __repr__(self):
        return pformat(self.stats)
