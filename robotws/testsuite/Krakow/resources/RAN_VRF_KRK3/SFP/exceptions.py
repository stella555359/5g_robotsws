class SfpParametersError(Exception):
    def __init__(self, message):
        super(SfpParametersError, self).__init__(message)
