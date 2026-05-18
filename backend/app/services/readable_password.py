import secrets
import string

# Readable 8-char passwords (no 0/O, 1/l/I confusion).
_ALPHABET = "23456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghjkmnpqrstuvwxyz"


def generate_readable_password(length: int = 8) -> str:
    return "".join(secrets.choice(_ALPHABET) for _ in range(length))
