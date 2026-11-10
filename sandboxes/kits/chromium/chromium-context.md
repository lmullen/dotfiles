## Chromium

This sandbox has Chromium at `/usr/bin/chromium`, for headless use. For a
screenshot: `chromium --headless --no-sandbox --screenshot=out.png
--window-size=1280,800 http://localhost:PORT/`. For DevTools-protocol
scripting, start it with `--headless --no-sandbox
--remote-debugging-port=9222`. There is no display; always pass `--headless`.
