# Advanced Time-Locked Vault Smart Contract (ChronoSafe)

A sophisticated smart contract implementation for creating and managing time-locked vaults with multiple beneficiaries and flexible withdrawal strategies on the Stacks blockchain.

## Overview

This smart contract provides a secure way to create time-locked vaults for STX tokens with advanced features including:
- Multiple beneficiary support with customizable share percentages
- Configurable withdrawal limits
- Emergency contact designation
- Emergency withdrawal mechanisms
- Comprehensive withdrawal history tracking

## Key Features

### Vault Management
- Create vaults with customizable lock periods and withdrawal limits
- Deposit STX tokens securely
- Designate emergency contacts
- Track vault ownership and balances

### Beneficiary System
- Add multiple beneficiaries to a single vault
- Configure share percentages for each beneficiary
- Set emergency withdrawal permissions per beneficiary
- Flexible withdrawal mechanisms

### Security Features
- Time-based locking mechanism
- Emergency withdrawal delay (24-hour default)
- Authorization checks for all operations
- Withdrawal limits to prevent fund drainage

## Contract Components

### Data Structures

#### Vaults Map
```clarity
(define-map vaults
  { vault-id: uint }
  { owner: principal,
    balance: uint,
    unlock-height: uint,
    withdrawal-limit: uint,
    emergency-contact: (optional principal) })
```

#### Beneficiaries Map
```clarity
(define-map beneficiaries
  { vault-id: uint, beneficiary: principal }
  { share-percentage: uint,
    can-emergency-withdraw: bool })
```

#### Withdrawal History
```clarity
(define-map withdrawal-history
  { vault-id: uint, user: principal }
  { last-withdrawal: uint,
    total-withdrawn: uint })
```

### Core Functions

#### create-vault
Creates a new vault with specified parameters:
- Initial deposit amount
- Lock period in blocks
- Withdrawal limit
- Optional emergency contact

#### add-beneficiary
Adds a beneficiary to an existing vault with:
- Share percentage
- Emergency withdrawal permissions

#### withdraw-from-vault
Enables regular withdrawals with:
- Amount validation
- Balance checks
- Withdrawal limit enforcement
- History tracking

#### emergency-withdraw-partial
Provides emergency withdrawal functionality:
- Share-based withdrawal calculation
- Emergency contact verification
- Time delay enforcement

## Error Codes

| Code | Description |
|------|-------------|
| u200 | Vault not found |
| u201 | Unauthorized access |
| u202 | Invalid parameters |
| u203 | Vault is locked |
| u204 | Resource already exists |

## Usage Examples

### Creating a Vault
```clarity
(contract-call? .vault create-vault
  u1000000 ;; amount
  u144     ;; unlock after 24 hours (144 blocks)
  u100000  ;; withdrawal limit
  none)    ;; no emergency contact
```

### Adding a Beneficiary
```clarity
(contract-call? .vault add-beneficiary
  u1        ;; vault-id
  tx-sender ;; beneficiary
  u50       ;; 50% share
  true)     ;; can emergency withdraw
```

## Security Considerations

1. **Time Locks**: All withdrawals are subject to the unlock height specified during vault creation.
2. **Emergency Delays**: Emergency withdrawals require a 24-hour waiting period after the unlock height.
3. **Access Control**: Only vault owners can add beneficiaries and modify vault settings.
4. **Withdrawal Limits**: Prevents excessive withdrawals through configurable limits.

## Development and Testing

This contract includes comprehensive error handling and input validation. It's recommended to thoroughly test all functions in a development environment before deploying to mainnet.

## License

This smart contract is released under the MIT License. See the LICENSE file for details.
