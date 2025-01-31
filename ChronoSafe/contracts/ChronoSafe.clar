;; Advanced Time-Locked Vault Contract
;; Enhanced vault with multiple beneficiaries and withdrawal strategies

;; Constants
(define-constant err-no-vault (err u200))
(define-constant err-unauthorized-access (err u201))
(define-constant err-invalid-params (err u202))
(define-constant err-locked (err u203))
(define-constant err-already-exists (err u204))

;; Data Types
(define-map vaults
  { vault-id: uint }
  { owner: principal,
    balance: uint,
    unlock-height: uint,
    withdrawal-limit: uint,
    emergency-contact: (optional principal) })

(define-map beneficiaries
  { vault-id: uint, beneficiary: principal }
  { share-percentage: uint,
    can-emergency-withdraw: bool })

(define-map withdrawal-history
  { vault-id: uint, user: principal }
  { last-withdrawal: uint,
    total-withdrawn: uint })

(define-data-var vault-count uint u0)
(define-data-var emergency-delay uint u144) ;; ~24 hours in blocks

;; Create new vault
(define-public (create-vault 
    (amount uint)
    (unlock-blocks uint)
    (withdrawal-limit uint)
    (emergency-contact (optional principal)))
  (let ((vault-id (var-get vault-count)))
    (begin
      (asserts! (> amount u0) err-invalid-params)
      (asserts! (> unlock-blocks u0) err-invalid-params)
      (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
      (map-set vaults
        { vault-id: vault-id }
        { owner: tx-sender,
          balance: amount,
          unlock-height: (+ block-height unlock-blocks),
          withdrawal-limit: withdrawal-limit,
          emergency-contact: emergency-contact })
      (var-set vault-count (+ vault-id u1))
      (ok vault-id))))

;; Add beneficiary to vault
(define-public (add-beneficiary
    (vault-id uint)
    (beneficiary principal)
    (share-percentage uint)
    (can-emergency-withdraw bool))
  (let ((vault (unwrap! (map-get? vaults { vault-id: vault-id }) err-no-vault)))
    (begin
      (asserts! (is-eq (get owner vault) tx-sender) err-unauthorized-access)
      (asserts! (<= share-percentage u100) err-invalid-params)
      (map-set beneficiaries
        { vault-id: vault-id, beneficiary: beneficiary }
        { share-percentage: share-percentage,
          can-emergency-withdraw: can-emergency-withdraw })
      (ok true))))

;; Regular withdrawal
(define-public (withdraw-from-vault 
    (vault-id uint)
    (amount uint))
  (let ((vault (unwrap! (map-get? vaults { vault-id: vault-id }) err-no-vault))
        (history (default-to 
          { last-withdrawal: u0, total-withdrawn: u0 }
          (map-get? withdrawal-history { vault-id: vault-id, user: tx-sender }))))
    (begin
      (asserts! (>= block-height (get unlock-height vault)) err-locked)
      (asserts! (<= amount (get withdrawal-limit vault)) err-invalid-params)
      (asserts! (<= amount (get balance vault)) err-invalid-params)
      (try! (as-contract (stx-transfer? amount tx-sender tx-sender)))
      (map-set vaults
        { vault-id: vault-id }
        (merge vault { balance: (- (get balance vault) amount) }))
      (map-set withdrawal-history
        { vault-id: vault-id, user: tx-sender }
        { last-withdrawal: block-height,
          total-withdrawn: (+ (get total-withdrawn history) amount) })
      (ok amount))))

