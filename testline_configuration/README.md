# testline_configuration

Project containing configurations of test lines used in automatic test executions

## Checks
The checks performed in CI/CD pipelines can be roughly divided into two categories:
- validation of TL configuration and `__init__.py` files syntax
- validation of committed files (size, extension, etc.)

## Validation of configuration and syntax
### UTE config validation
Check `__init.__.py` files defining UTE test line model (i.e., using `UTE_CONFIG` objects).

### Common config validation
Check `__init.__.py` files defining TAF test line models.

In this step, also correctness of topology will be verified if appropriate rules are defined.
Please check out [README.md](./topology_validation_rules/README.md) in `topology_validation_rules` directory 
to learn more.

### Black
Use Black (a Python library) to check if `__init__.py` code follows the PEP8 format, which is the official 
Python style guide.

> **Note:** As of now, this step *does not* fix configuration files automatically. 
It just provides information about formatting issues in a form of suggested patch.

## Validation of committed files
- no empty files allowed
- no binary files allowed
- no RobotFramework output files allowed (`output.xml`, `log.html`, `report.html`)
- only allowed files with extensions: `.yaml`, `.yml`, `.sce`, `.sid`, `.env`, `.xml`
- file names / directory names should only contain letters, digits, dots, underscores, or dashes
- test line directories must match allowed patterns:
  - TEST_LINE_PATTERN:`([0-9]+)_([0-9]+)_([a-zA-Z0-9_]+)`
  - LEGACY_QT_TEST_LINE_PATTERN: `QT_(WRO|HZ|HGZ|TSR)_(TL|CLASS)\d+_\w+`
  - NEW_QT_TEST_LINE_PATTERN: `QT_(\w+)_[A-Z]+_?(\d+)(C|E)?`
  
### Limit on test line modifications
MRs modifying more than 5 test line configurations should be checked and merged by a repository Code Guard.
