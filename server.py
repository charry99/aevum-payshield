"""PayShield on Aevum — zero-dependency static server (same pattern as PayShield's server.py).
Serves frontend/ on http://localhost:8000. No secrets, no wallet keys, no backend state.
"""
import http.server
import functools
import os

PORT = int(os.environ.get("PORT", "8000"))
FRONTEND_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "frontend")

Handler = functools.partial(http.server.SimpleHTTPRequestHandler, directory=FRONTEND_DIR)

if __name__ == "__main__":
    with http.server.ThreadingHTTPServer(("127.0.0.1", PORT), Handler) as httpd:
        print(f"PayShield on Aevum — http://localhost:{PORT} (serving {FRONTEND_DIR})")
        httpd.serve_forever()
