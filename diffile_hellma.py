import math

def is_primitive_root(g, p):
    if not (1 < g < p):
        return False
    required_set = {pow(g, powers, p) for powers in range(1, p)}
    return len(required_set) == p - 1

def run_diffie_hellman(p, alpha, a, b):
    print(f"\n--- Running Diffie-Hellman for p={p}, alpha={alpha}, a={a}, b={b} ---")
    
    # Validation Constraints
    if not (1 < a < p - 1) or not (1 < b < p - 1):
        raise ValueError("Private keys a and b must satisfy 1 < key < p - 1.")
    if not is_primitive_root(alpha, p):
        raise ValueError(f"alpha ({alpha}) is not a primitive root modulo p ({p}).")
    
    # Compute public keys
    A = pow(alpha, a, p)  # Alice's public key
    B = pow(alpha, b, p)  # Bob's public key
    
    # Compute shared secret independently
    k_alice = pow(B, a, p)
    k_bob = pow(A, b, p)
    
    print(f"Alice Public Key (A): {A}")
    print(f"Bob Public Key (B): {B}")
    print(f"Shared Secret (Alice K): {k_alice}")
    print(f"Shared Secret (Bob K):   {k_bob}")
    
    match = (k_alice == k_bob)
    print(f"Do shared secrets match? {match}")
    assert match, "Key exchange failed!"

if __name__ == "__main__":
    # Test Case 1: Worked Example
    run_diffie_hellman(p=29, alpha=2, a=5, b=12)
    
    # Test Case 2: Additional Custom Test Case
    run_diffie_hellman(p=23, alpha=5, a=6, b=15)