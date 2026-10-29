# Definition of constant variables used during operations on Insta Certifier Server

# **** Login parameters ****

primaryDpUrl = "https://10.42.132.97"
secondaryDpUrl = "https://10.42.132.98"
dpUrlUsername = "dpadmin"
dpUrlPassword = "Nokia123DP!!"

primaryDpSSH = "10.42.132.97"
secondaryDpSSH = "10.42.132.98"
dpOMSUsername = "_nokadmin"
dpOMSPassword = "Nokia123DP"
dpSSHUsername = "vplatadmin"
dpSSHPassword = "_vplatAdmin123"

# Login locators

dpBtnAdvanced = "id:details-button"
dpBtnProceed = "id:proceed-link"
dpTxtLogin = '//*[@id="username"]'
dpTxtPass = '//*[@id="password"]'
dpBtnLogin = '//*[@id="login"]'
dpBtnOK = "id:recentActivityPopupOK"
dpBtnLogout = "xpath:/html/body/app-root/app-loginlayout/kendo-dialog/div[2]/kendo-dialog-actions/button[2]"

# Import SAS cert locatiors
primaryDpCbrsUrl = "https://10.42.132.97/dp/cbrssettings"
secondaryDpCbrsUrl = "https://10.42.132.98/dp/cbrssettings"
dpSASip = "id:primarySasUrl"
dpSASImport = "id:primarySasCert"
dpBtnUpdate = "id:update"

dpTabCBSD = "xpath:/html/body/app-root/app-dashboardlayout/div[1]/app-cbrssettings" \
            "/div/div/div/form/fieldset/kendo-tabstrip/ul/li[3]/span"
dpImportCBSD1 = "id:cbsdCertOne"
dpImportCBSD2 = "id:cbsdCertTwo"
dpImportCBSD3 = "id:cbsdCertThree"

primaryDpCertificateUrl = "https://10.42.132.97/dp/certificate"
secondaryDpCertificateUrl = "https://10.42.132.98/dp/certificate"
dpCoreImport = "id:uploadCore"
dpAccessImport = "id:uploadAccess"
dpCertificate = "id:certificate"
dpTrustChain = "id:intermediateTrustChain"
dpBtnImport = "id:import"

# Switchover
primaryDpSettingsUrl = "https://10.42.132.97/dp/systemsettings"
secondaryDpSettingsUrl = "https://10.42.132.98/dp/systemsettings"
dpTabSwMain = "id:k-tabstrip-tab-2"
dpSwitchoverList = "id:cbsdSwitchoverMode"
dpRedundantListVal = "Switch to Redundant DP"
dpPrimaryListVal = "Fallback to Primary DP"
dpDisabledListVal = "Disabled"
