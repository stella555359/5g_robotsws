*** Settings ***
Documentation
...  author:  Patryk Tatarek
...  contact: patryk.tatarek@nokia.com

Resource    ../Resources/CB008154_Keywords.robot

*** Keywords ***
[1]CB008154 old CBRS rootCA removal WebEM
    Old CBRS rootCA removal WebEM

[1]CB008154 old CBRS rootCA retention WebEM
    Old CBRS rootCA retention WebEM

[1]CB008154 autoCBRSCertDelete privileges check WebEM
    Check autoCBRSCertDelete privileges on WebEM

[1]CB008154 autoCertDelete privileges check WebEM
    Check autoCertDelete privilegeson on WebEM

[1]CB008154 Manual BTS Local User Account Credentials Update Via WebEM
    Change username and password for local user    BTSSecurity
    Change username and password for local user    BTSApplication
    Change username and password for local user    BTSRead

[1]CB008154 Manual Local Password Changeability
    Manual Local Password Changeability

[1]CB008154 Manual Local Password Changeability Unsuccessful Entry
    Manual Local Password Changeability Unsuccessful Entry
    Manual Local Password Changeability

[1]CB008154 Manual Temporary Log Event Storage
    Manual Temporary Log Event Storage
