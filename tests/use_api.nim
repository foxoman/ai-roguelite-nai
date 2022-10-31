import std/[asyncdispatch, httpclient, strutils, os, tables, json, strformat, net]
import pkg/uuid4



const token = "eyJhbGciOiJSUzI1NiIsImtpZCI6ImRjMzdkNTkzNjVjNjIyOGI4Y2NkYWNhNTM2MGFjMjRkMDQxNWMxZWEiLCJ0eXAiOiJKV1QifQ.eyJwcm92aWRlcl9pZCI6ImFub255bW91cyIsImlzcyI6Imh0dHBzOi8vc2VjdXJldG9rZW4uZ29vZ2xlLmNvbS9wYWludC1wcm9kIiwiYXVkIjoicGFpbnQtcHJvZCIsImF1dGhfdGltZSI6MTY2NzIyNTA1MCwidXNlcl9pZCI6Im1zNU9QMnVBSlBNQ3U0d3FNQ1o3Vnh6bDgyWjIiLCJzdWIiOiJtczVPUDJ1QUpQTUN1NHdxTUNaN1Z4emw4MloyIiwiaWF0IjoxNjY3MjI1MDUwLCJleHAiOjE2NjcyMjg2NTAsImZpcmViYXNlIjp7ImlkZW50aXRpZXMiOnt9LCJzaWduX2luX3Byb3ZpZGVyIjoiYW5vbnltb3VzIn19.mJ06t8o8jTCr_NafbO0J3JyYpDcpI5bEveNNQ5gQ4kCa-RK_h4h9ArBNvJWxVFsBh5QHFF2QElM8L21x6iY_S3h_XkmXV3Brk4T6jwwgp8esuPqkQoeYKnmsIdxNQqZ9srBDO3P7-lYrs6pbt5IwX7plxy3eIpN5B6z3gyQQfDlHCzrGAWrW3z-A_ksR8aLL0VBwgLN-YeBfCUYLu213CJGXXsTO9ys_mgB4tFu-WaqSYONz8YhSF_soAqo7Mg0hiXX6Wgk4_WqHPt_Q9s3wbmIa5XumrVsR_OGjESPi4sPjrR7dRoQ60WSBde4Eq_S8f5yXs7BzevlL_HB5VglsHQ"

let cont = newContext(verifyMode = CVerifyNone)

let baseUrl = "https://paint.api.wombo.ai"

proc getTaskId: string = 
  let url = fmt"{baseUrl}/api/tasks/"

  # return id field from json response from the post request
  let c = newHttpClient(sslContext = cont)
  c.headers = newHttpHeaders({ "Authorization": "Bearer " & token })
  let response = c.post(url, "")
  let json = parseJson(response.body)
  return json["id"].getStr()

proc doWombo(taskId: string) = 
  let url = fmt"{baseUrl}/api/tasks/{taskId}"

  let c = newHttpClient(sslContext = cont)
  
  let headers = newHttpHeaders()
  headers["Authorization"] = fmt"Bearer {token}"
  headers["Content-Type"] = "application/json"
  c.headers = headers

  
  let data = %*{"input_spec": {"prompt": "big dog", "style": 45, "display_freq": 10}}

  let resp = c.put(url, body = $data)

  echo resp.body

proc checkCompletion(taskId: string): string = 
  let url = fmt"{baseUrl}/api/tasks/{taskId}"

  let c = newHttpClient(sslContext = cont)
  c.headers = newHttpHeaders({ "Authorization": "Bearer " & token })
  let response = c.get(url)
  let data = parseJson(response.body)["photo_url_list"]
  if data.len > 0:
    let last = data[^1].getStr()
    if "/final.jpg" in last:
      return last


let id = getTaskId()
echo id
doWombo(id)

var tries = 0
var url = ""

while tries < 20 and url == "":
  url = checkCompletion(id)
  sleep(1000)
  inc tries

let c = newHttpClient(sslContext = cont)
c.downloadFile(url, "image.png")
c.close()