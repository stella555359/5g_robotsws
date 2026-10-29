# Definition of constant variables used during operations on Insta Certifier Server

# **** Login parameters ****

instaUrl = "http://10.42.196.196:8083"
instaUsername = "admin"
instaPassword = "admin"

# Login locators
instaTxtLogin = "id:username"
instaTxtPass = "id:password"
instaBtnLogin = "Proceed"  # value
instaText1 = "Operator Login"

# **** Generate certificates parameters ****

instaCommonCertificates = ["CBRS_TEST_TA1", "CBRS_TEST_TA2", "CBRS_TEST_CA1.1", "CBRS_TEST_CA1.2", "CBRS_TEST_CA2.1",
                           "CBRS_TEST_CA2.2", "CBRS_TEST_TA_EXPIRE", "NCDP_CA", "NCDP_TA"]
instaCommonCertificates2 = ["CBRS_CA1", "CBRS_TA1", "CBRS_TEST_TA1", "CBRS_TEST_TA2", "CBRS_TEST_CA1.1",
                            "NCDP_CA", "NCDP_TA"]
instaIssuer = {
    "+ CBRS_TEST_CA1.1": "23",
    "CBRS_TEST_CA1.1": "23",
    "CA1.1": "23",
    "+ CBRS_TEST_CA2.1": "32",
    "CBRS_TEST_CA2.1": "32",
    "CA2.1": "32",
    "+ CBRS_CA1": "14",
    "CBRS_CA1": "14",
    "CA1": "14",
    "NCDP_CA": "9631"
}
instaValidity = {
    "1month": "30",
    "2months": "60",
    "3months": "90",
    "6months": "180",
    "1year": "365",
    "2years": "730",
    "3years": "1095",
    "5years": "1825",
    "10years": "3650",
    "15years": "5478",
    "20years": "7304"
}
instaSignature = {
    "1": "rsa-pkcs1-sha1",
    "224": "rsa-pkcs1-sha224",
    "256": "rsa-pkcs1-sha256",
    "384": "rsa-pkcs1-sha384",
    "512": "rsa-pkcs1-sha512"
}

# Import CSR locators
instaTxtCSR = "name:pem"
instaBtnProceed = "name:proceed"
instaBtnInstert = "name:insert-request-proceed"

# Certificate request setup locators
instaListIssuer = "id:ca-selection:gs"
instaListValidity = "id:validity-length"
instaBtnSet = "name:set-validity-period"
instaListSignature = "id:signature-algorithm"
instaBtnAccept = "name:accept"

# Search certificates
instaCheckCA = "id:use-ca"
instaBtnSearch = "id:proceed"
instaBtnDownload1 = "xpath:/html/body/div[3]/form/div[1]/fieldset[1]/div[8]/a[2]"
instaBtnDownload2 = "xpath:/html/body/div[3]/form/div[1]/fieldset[1]/div[7]/a[2]"
instaTxtSearch = "xpath://*[@id=\"search_form\"]/div[1]/fieldset[2]/div[1]/input"
instaGoToCert = "xpath:/html/body/div[3]/form/div[1]/fieldset[2]/div[1]/div/input[1]"
