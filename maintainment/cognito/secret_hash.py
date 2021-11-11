import sys
import hmac, hashlib, base64

# args
# username, app_client_id, client_secret
username = sys.argv[1]
app_client_id = sys.argv[2]
key = sys.argv[3]
#username + app_client_id
message = bytes(sys.argv[1]+sys.argv[2],'utf-8')
#client secret
key = bytes(sys.argv[3],'utf-8')
secret_hash = base64.b64encode(hmac.new(key, message, digestmod=hashlib.sha256).digest()).decode()

# username+app_client_id
print(secret_hash)