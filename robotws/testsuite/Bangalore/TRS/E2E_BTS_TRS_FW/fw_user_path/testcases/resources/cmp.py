from selenium import webdriver


def accept_certificate(cloud_ip):
    browser = webdriver.Chrome()
    browser.get('http://10.58.143.250:8083/')
    username = browser.find_element_by_id('username')
    password = browser.find_element_by_id("password")
    username.click()
    username.send_keys("testadmin")
    password.click()
    password.send_keys("Admin@123")
    browser.find_element_by_class_name('submit').click()
    browser.implicitly_wait(5)
    link = browser.find_element_by_link_text('Process Requests')
    link.click()
    browser.implicitly_wait(5)
    for i in range(0, 10):
        variable = "objectview.html?index-number=" + str(i)
        print(variable)
        req = browser.find_element_by_xpath('//a[@href="' + variable + '"]')
        req.click()
        span = browser.find_element_by_class_name('uri')
        print(span.text)
        print("span content")
        ar1 = span.text
        print('ar1 : ' + ar1)
        arr = ar1.split()
        print('arr : ')
        print(arr)
#        cloud_ip = unicode(cloud_ip)
        if ':0000:0000:0000:' in cloud_ip:
            cloud_ip = cloud_ip.replace(':0000:0000:0000:', '::')
        print('cloud_ip : ' + cloud_ip)
        senderip = arr[1]
        if ':0000:0000:0000:' in senderip:
            senderip = senderip.replace(':0000:0000:0000:', '::')
        print('senderip : ' + senderip)
        if senderip == cloud_ip:
            accept = browser.find_element_by_name('accept')
            accept.click()
            break
        elif cloud_ip == '10.0.1.2':
            accept = browser.find_element_by_name('accept')
            accept.click()
            break
        else:
            back = browser.find_element_by_class_name('back-button')
            back.click()
    browser.implicitly_wait(5)
    browser.quit()

# accept_certificate("10.53.186.70")
