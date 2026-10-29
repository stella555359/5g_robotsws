class UnexpectedPartitionActive(Exception):
    pass


class WrongSWActive(Exception):
    pass


class ParsingIssue(Exception):
    pass


class FilePathIssue(Exception):
    pass


class BTSSwIssue(Exception):
    pass


class AlarmWasNotSent(Exception):
    pass


class SocketError(Exception):
    pass


class FaultGenerationFailure(Exception):
    pass


class PartitionWasNotChanged(Exception):
    pass
