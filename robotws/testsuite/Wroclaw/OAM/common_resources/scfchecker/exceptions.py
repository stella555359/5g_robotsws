

class OwnExceptions(Exception):
    """Base class for custom exceptions in this module."""
    pass


class PathNotFound(OwnExceptions):
    pass


class CannotCreateTable(OwnExceptions):
    pass


class ParameterFileError(OwnExceptions):
    """Error reading or parsing parameter file."""
    pass


class InvalidParameterFormat(ParameterFileError):
    """Parameter line has invalid format."""
    pass
