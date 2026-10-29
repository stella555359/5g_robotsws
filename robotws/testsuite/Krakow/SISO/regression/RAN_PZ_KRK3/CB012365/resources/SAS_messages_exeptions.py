class MessageNotFoundException(Exception):
    def __init__(self, message):
        super().__init__(message)


class TooManyMessagesFoundException(Exception):
    def __init__(self, message):
        super().__init__(message)


class TooFewMessagesFoundException(Exception):
    def __init__(self, message):
        super().__init__(message)


class WrongParameterValueException(Exception):
    def __init__(self, message):
        super().__init__(message)
