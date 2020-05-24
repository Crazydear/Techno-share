import requests
import random
import time
from concurrent.futures import ThreadPoolExecutor

url = 'http://z2zjie.cn/2018.php'   # 换成钓鱼网址

proxies = {
    'http': "http://125.123.159.254:3000",
    'https': 'https://221.1.200.242:38652',
}

def ranstr(num):
    # 猜猜变量名为啥叫 H
    H = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'
    salt = ''
    for i in range(num):
        salt += random.choice(H)
    return salt + "某某"   # 去查whois，看看谁的域名

def pog(i):
    print(i,end='')
    # 分析网页，找到表单
    data = {"user": random.randint(1, 9999)*100000+71440, "pass": ranstr(random.randint(5,11)), "submit": None}
    print(data)
    aa = requests.post(url,data=data,proxies=proxies)
    time.sleep(2)

i = [item for item in range(1000)]
with ThreadPoolExecutor(16) as p:
    for name in i:
        p.submit(pog, name)
