class DifferentNumberOfValidationErrorsException(Exception):
    def __init__(self, message):
        super().__init__(message)


class ScfRamlErrorsDoNotMatchException(Exception):
    def __init__(self, message):
        super().__init__(message)
