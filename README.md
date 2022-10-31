# ai-roguelite-nai

This is a small utility that allows you to use NovelAI's image generation or locally (or remote) running Automatic's Stable Diffusion WebUI in AI Roguelite.


To run it:
1. download the latest archive for your platform, unzip in a folder.
2. Rename `config.toml.sample` to `config.toml` and edit it to your liking.
3. Open `C:\Windows\System32\drivers\etc\hosts` as admin (or `/etc/hosts` on Linux) and add the following line:

`127.0.0.1 paint.api.wombo.ai`

This is needed to make the game do requests to the local service instead of actually contacting Wombo.