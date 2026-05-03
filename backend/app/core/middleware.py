import time
from jose import jwt
from fastapi import Request
from starlette.middleware.base import BaseHTTPMiddleware

# ANSI color codes for PyCharm console
COLORS = {
	"GET": "\033[92m", # Green
	"POST": "\033[94m", # Blue
	"PATCH": "\033[93m", # Yellow
	"PUT": "\033[93m", # Yellow
	"DELETE": "\033[91m", # Red
	"RESET": "\033[0m", # Reset color
	"INFO": "\033[90m" # Gray for secondary text
}

class ColoredLoggingMiddleware(BaseHTTPMiddleware):
	async def dispatch(self, request: Request, call_next):
		start_time = time.time()

		# 1. Attempt to extract the user from the token
		user_info = "Anonymous"
		auth_header = request.headers.get("Authorization")

		if auth_header and auth_header.startswith("Bearer "):
			token = auth_header.split(" ")[1]
			try:
				# Use get_unverified_claims to read token payload without signature validation
				payload = jwt.get_unverified_claims(token)

				# Extract 'sub' (currently holds user ID based on login endpoint logic)
				subject = payload.get("sub", "?")
				user_info = f"User: {subject}"
			except Exception:
				user_info = "Invalid Token"

		# 2. Pass the request further to the application
		response = await call_next(request)

		# 3. Format logs after receiving the response
		process_time = (time.time() - start_time) * 1000
		method = request.method
		url = request.url.path
		status_code = response.status_code

		# Pick the color for the method
		color = COLORS.get(method, COLORS["RESET"])
		reset = COLORS["RESET"]
		info_color = COLORS["INFO"]

		# Format user block
		user_block = f"[{user_info}]"

		# Form a beautiful log string with perfectly aligned columns
		# {user_block:<12} - smaller fixed width for the user block
		# {method:<7} - fixed width for HTTP methods
		# {url:<35} - fixed width for the URL so Status aligns perfectly
		# {process_time:>7.2f} - right-aligns the milliseconds so decimal points match
		log_message = (
			f"{info_color}INFO:{reset}  "
			f"{info_color}{user_block:<12}{reset} - "
			f"{color}{method:<7}{reset} {url:<35} "
			f"- Status: {status_code} - {process_time:>7.2f}ms"
		)

		print(log_message)

		return response
