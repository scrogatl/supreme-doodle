import requests
import os
import time
from datetime import datetime
import sys


def loadgen():
    front_end = os.environ.get('FRONTEND_HOST', "localhost")
    print("FRONTEND_HOST: " + front_end)
    
    while (True):
        timeString = datetime.now().strftime("%H:%M:%S.%f")[:-3]
        try:
            res = requests.get('http://' + front_end + ':5000', timeout=.5)
            if res.status_code >= 300: 
                print(timeString + " - Status: " + str(res.status_code) + " - " + res.text)
            else: 
                print(timeString + " - Status: " + str(res.status_code) + " - " + res.text)
        except Exception as e:
            print(timeString + " - Status: " + repr(e))
        time.sleep(1)



if __name__ == '__main__':
    sys.exit(loadgen())  


