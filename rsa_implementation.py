import math

def is_prime(n):
    if n < 2:
        return False
    for i in range(2, int(math.isqrt(n)) + 1):
        if n % i == 0:
            return False
    return True

def extended_gcd(a, b):
    if a == 0:
        return b, 0, 1
    gcd, x1, y1 = extended_gcd(b % a, a)
    x = y1 - (b // a) * x1
    y = x1
    return gcd, x, y

def mod_inverse(e, phi):
    gcd, x, _ = extended_gcd(e, phi)
    if gcd != 1:
        raise ValueError("Modular inverse does not exist (e and phi are not coprime).")
    # Ensure d is the unique value in range 0 <= d < phi
    return x % phi

def run_rsa(p, q, e, m):
    print(f"\n--- Running RSA for p={p}, q={q}, e={e}, m={m} ---")
    
    # Validation Constraints
    if not is_prime(p) or not is_prime(q):
        raise ValueError("Inputs p and q must both be prime numbers.")
    if p == q:
        raise ValueError("Inputs p and q must be distinct primes.")
    
    n = p * q
    phi = (p - 1) * (q - 1)
    
    if not (0 <= m < n):
        raise ValueError(f"Plaintext message m ({m}) must satisfy 0 <= m < n ({n}).")
    if not (1 < e < phi) or math.gcd(e, phi) != 1:
        raise ValueError(f"Public exponent e ({e}) must satisfy 1 < e < phi and be coprime to phi.")
    
    # Compute unique private exponent d (0 <= d < phi)
    d = mod_inverse(e, phi)
    
    # Encrypt: c = m^e mod n
    c = pow(m, e, n)
    
    # Decrypt: recovered_m = c^d mod n
    recovered_m = pow(c, d, n)
    
    # Print intermediate values
    print(f"Modulus (n): {n}")
    print(f"Euler's Totient (phi): {phi}")
    print(f"Public Exponent (e): {e}")
    print(f"Private Exponent (d): {d}")
    print(f"Ciphertext (c): {c}")
    print(f"Recovered Message (m): {recovered_m}")
    
    assert recovered_m == m, "Decryption failed!"
    print("Result: SUCCESS (Decrypted message matches original plaintext)")

if __name__ == "__main__":
    # Test Case 1: Worked Example
    run_rsa(p=3, q=11, e=3, m=4)
    
    # Test Case 2: Additional Custom Test Case
    run_rsa(p=13, q=17, e=5, m=35)