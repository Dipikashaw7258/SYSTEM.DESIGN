# CampusConnect Network Security & Cryptographic Protocol Specification

**Author GitHub:** [dipikashaw](https://github.com/dipikashaw)

---

## Task 3: Security-Principle Mapping & Protocol Classification

### Security Principles Addressed
* **RSA:** Directly addresses **Confidentiality** (by encrypting sensitive data using public key $e$), **Authentication** (via digital signatures signed with private key $d$), and **Non-Repudiation** (since only the private key owner can generate a valid signature).
* **Diffie-Hellman:** Addresses **Confidentiality** by establishing a shared symmetric secret key over an unsecure channel to encrypt subsequent traffic.

### Key Exchange vs. Encryption Classification
Diffie-Hellman is strictly classified as a key exchange protocol because it provides no mechanism to directly encrypt arbitrary plaintext messages; it enables two untrusted endpoints to independently derive a matching symmetric session key over an insecure medium. Conversely, RSA is a full asymmetric cryptographic system capable of both key derivation and direct data encryption/decryption, as it mathematically maps a plaintext value $m$ directly to a ciphertext $c$ via modulo exponentiation using its public-private key pair.

---

## Task 4: CampusConnect Security Threat Model & Defense Architecture

### (a) Firewall Placement & Traffic Filtering
* **Placement & Type:** Deploy a **hardware/perimeter firewall** at the edge of the network before the router/load balancer to filter external internet traffic, paired with a **software firewall** (e.g., `ufw` or `iptables`) directly on the web application server host for defense-in-depth.
* **Specific Filtering Rule:** Enforce an inbound rule allowing traffic strictly on TCP port 443 (HTTPS) while dropping/blocking all incoming traffic on TCP port 80 (HTTP) or SSH TCP port 22 except from explicit administrator IP subnets.

### (b) Intrusion Detection Strategy (HIDS vs. NIDS)
* **CampusConnect Decision:** CampusConnect must deploy **both** a Host-based IDS (HIDS) and a Network-based IDS (NIDS).
* **Justification:** 
  * **NIDS:** Positioned at network bottlenecks to monitor packet flows across subnets; it can detect port scans, DDoS floods, and known network signatures, but cannot inspect encrypted payload contents (TLS/HTTPS).
  * **HIDS:** Installed directly on application host OS nodes; it can inspect local system logs, file integrity changes, and privilege escalations, but cannot inspect or analyze network traffic directed at other host targets across the campus network.

### (c) Transport Security & Vulnerability Mitigation
* **Protocol Recommendation:** CampusConnect’s login page must operate exclusively over **HTTPS (HTTP over TLS/SSL)**.
* **Vulnerability Prevented:** HTTPS prevents **credential sniffing** (e.g., plaintext packet capture via Wireshark on public Wi-Fi) and **session hijacking** (mitm cookie theft) by encrypting traffic between client browsers and server endpoints.

### (d) Authentication & Least Privilege Architecture
* **Multi-Factor Authentication (MFA):** Requires two distinct factors:
  1. *Knowledge Factor:* Master account password or passphrase.
  2. *Possession Factor:* Time-based One-Time Password (TOTP) generated via an authenticator app (or hardware security key).
* **Role-Based Access Control (RBAC):**
  * **Student Role:** Read-only access to enrolled course materials; write access restricted to submitting personal assignments and viewing personal grades.
  * **Instructor Role:** Read/write access to assign grades, upload course syllabi, and manage enrolled rosters for their designated sections.
  * **Admin Role:** System configuration, user account creation, and security log viewing permissions; blocked from modifying individual academic grades directly without audit logging.

### (e) Attack Analysis & Classification
* **Scenario:** An attacker positions a passive packet sniffer on an unencrypted campus Wi-Fi access point to monitor traffic destined for the `http://campusconnect.edu/login` endpoint, capturing student credentials submitted via plaintext POST forms.
* **Classification:** **Passive Attack**.
* **Justification:** The attack involves monitoring and intercepting sensitive data in transit without altering packet contents, disrupting network operations, or modifying system state.