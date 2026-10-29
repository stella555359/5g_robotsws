from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.readers import LogReader
from testsuite.Wroclaw.RRM.VRF_WRO2_T023.resources.log_analyzer.matchers import MessageMatcher


class MessageFinder(object):

    def __init__(self, log_reader):
        """Class that the actual searching for messages."""

        if not isinstance(log_reader, LogReader):
            em = ': log_reader must be of LogReader type'
            raise ValueError(self.__class__.__name__ + em)

        self.log_reader = log_reader
        self.message_generator = self.log_reader.generator()

    @staticmethod
    def _check_mesg(message, matchers, forget_matcher_on_hit):
        for position, matcher in enumerate(matchers):
            if matcher(message):
                if forget_matcher_on_hit:
                    del (matchers[position])
                return message, matcher, matchers

    def _find(self, matchers, forget_matcher_on_hit=False):
        matchers = list(matchers)  # make copy to work on
        for message in self.message_generator:
            result = self._check_mesg(message, matchers, forget_matcher_on_hit)
            if result:
                message, matcher, matchers = result
                yield (message, matcher)
            if not matchers:
                break

    @staticmethod
    def _make_dict(list_of_msg_matcher_tuples):
        d = {matcher.tag: [] for _, matcher in list_of_msg_matcher_tuples}
        [d[matcher.tag].append(msg) for msg, matcher in list_of_msg_matcher_tuples]
        return d

    def find_next(self, matchers, forget_matcher_on_hit=False):
        """Find the next message matched by any of the provided matchers."""

        is_matchers_list = isinstance(matchers, list)
        if not is_matchers_list:
            matchers = [matchers]

        output = next(self._find(matchers, forget_matcher_on_hit), None)

        if not is_matchers_list and output is not None:
            output = output[0]  # result is a (message, matcher) so it becomes only message here

        return output

    def find_next_anew(self, matchers, forget_matcher_on_hit=False):
        """
        Reset generator and search for first message matching.
        Convenient when you want to find multiple different types of messages with a single generator.
        """

        self.reset_generator()
        return self.find_next(matchers, forget_matcher_on_hit)

    def find_all(self, matchers, forget_matcher_on_hit=False, output='dict'):
        """
        Find all matching messages from the current generator position to the end of file.
        If forget_matcher_on_hit=True, then each matcher will be forgotten after a single match is found for it.
        Generator is reset before this method returns.
        If only one matcher is passed, the results will always be a list of matched messages (or empty).
        In such case, the order of messages is preserved.
        For multiple matchers you can choose the output format. If 'dict' is chosen,
        the order of messages can no longer be preserved among all the matchers. However, the order will be preserved
        within each individual matcher and can be accessed using the specific matcher's 'tag' attribute as dict key.

            raw_list: [msg1, msg2, ...] or []
            tag_list: [(msg, matcher_A), (msg, matcher_B), ...] or []
            dict: {'matcher_A': [msg1, msg2, ...], 'matcher_B': [msg1, msg2, ...], ...} or {}
        """

        options = {
            'dict': self._make_dict,
            'tag_list': lambda result: result,
            'raw_list': lambda result: [tup[0] for tup in result],
        }

        find_multiple_msg = isinstance(matchers, list)
        if not find_multiple_msg:
            matchers = [matchers]  # _find needs matchers as list

        modify = options[output] if find_multiple_msg else options['raw_list']
        result = modify(list(self._find(matchers, forget_matcher_on_hit)))

        self.reset_generator()
        return result

    def find_all_anew(self, matchers, forget_matcher_on_hit=False, output='dict'):
        """Reset generator and call find_all."""
        self.reset_generator()
        return self.find_all(matchers, forget_matcher_on_hit, output)

    def find_exactly(self, x, matcher, assert_msg=None):
        """
        Find all messages matching a single matcher and check whether their number is exactly X. Raises AssertionError.
        """
        if assert_msg:
            assert_msg = assert_msg + ' Expected {expected_num} messages, but found {found_num}'
        else:
            assert_msg = ' Expected {expected_num} messages, but found {found_num}'

        if not isinstance(matcher, MessageMatcher):
            em = 'find_exactly expects exactly one matcher'
            raise ValueError(self.__class__.__name__ + em)

        y = self.find_all_anew(matcher)
        em = self.__class__.__name__ + ': ' + assert_msg
        assert len(y) == x, em.format(expected_num=x, found_num=len(y))
        return y

    def find_one(self, matcher):
        """
        Check if there is EXACTLY ONE message, that matches a given matcher.
        The generator is reset before the method returns. Raises AssertionError if more or less than one message found.
        """
        return self.find_exactly(1, matcher)[0]

    def reset_generator(self):
        self.message_generator = self.log_reader.reset_generator()
