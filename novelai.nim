import std/[json, asyncdispatch, httpclient, strutils, random, base64, strformat]

let payload = %*{
  "input": "",
  "model": "nai-diffusion",
  "parameters": {
    "width": 512,
    "height": 512,
    "scale": 11,
    "sampler": "k_euler_ancestral",
    "steps": 28,
    "seed": nil,
    "n_samples": 1,
    "strength": 0.7,
    "noise": 0,
    "ucPreset": 0,
    "uc": "nsfw, lowres, bad anatomy, bad hands, text, error, missing fingers, extra digit, fewer digits, cropped, worst quality, low quality, normal quality, jpeg artifacts, signature, watermark, username, blurry"
  }
}

let headers = {
  "authorization": "Bearer " & readFile("nai_token"),
  "content-type": "application/json",
}.newHttpHeaders

randomize()

proc genImage*(prompt: string): Future[(bool, string, string)] {.async.} = 
  const url = "https://api.novelai.net/ai/generate-image"
  let c = newAsyncHttpClient()
  c.headers = headers
  var
    resp: AsyncResponse 
    cont: string
  
  var payload = payload
  payload["input"] = %prompt
  payload["parameters"]["steps"] = %20
  let seed = rand(0'i32..high(int32)-1)
  payload["parameters"]["seed"] = %seed
  try:
    resp = await c.post(url, $payload)
    cont = await resp.body
    if resp.code != Http201:
      return (false, "couldn't generate!", "")
  finally:
    c.close()


  for line in cont.splitLines():
    if line.startsWith("data:"):
      let imgBin = base64.decode(line[5..^1])
      return (true, imgBin, &"Prompt: `{prompt}`\nSeed: `{seed}`")