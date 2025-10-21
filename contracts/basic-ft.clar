;; basic-ft.clar
;; SIP-010 compliant fungible token
;; Error codes
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT_BALANCE (err u101))
(define-constant ERR_ZERO_AMOUNT (err u102))
(define-constant ERR_INVALID_RECIPIENT (err u103))
(define-constant ERR_INVALID_OWNER (err u104))

;; Token constants
(define-constant TOKEN-NAME "Basic Token")
(define-constant TOKEN-SYMBOL "BFT")
(define-constant TOKEN-DECIMALS u6)

;; Contract state
(define-data-var contract-owner principal tx-sender)
(define-map token-balances principal uint)
(define-data-var total-supply uint u0)

;; SIP-010: Transfer token to a specified principal
(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
  (let ((checked-amount amount)
        (checked-recipient recipient))
    (begin
      (asserts! (is-eq tx-sender sender) (err ERR_UNAUTHORIZED))
      (asserts! (not (is-eq sender checked-recipient)) (err ERR_INVALID_RECIPIENT))
      (match (map-get? token-balances sender)
        sender-balance 
          (begin
            (asserts! (> checked-amount u0) (err ERR_ZERO_AMOUNT))
            (asserts! (>= sender-balance checked-amount) (err ERR_INSUFFICIENT_BALANCE))
            (let ((recipient-balance (default-to u0 (map-get? token-balances checked-recipient))))
              (begin
                (map-set token-balances sender (- sender-balance checked-amount))
                (map-set token-balances checked-recipient (+ recipient-balance checked-amount))
                (print memo)
                (ok true))))
        (err ERR_INSUFFICIENT_BALANCE)))))

;; SIP-010: Read-only functions
(define-read-only (get-name) (ok TOKEN-NAME))
(define-read-only (get-symbol) (ok TOKEN-SYMBOL))
(define-read-only (get-decimals) (ok TOKEN-DECIMALS))
(define-read-only (get-balance (who principal)) 
  (ok (get-token-balance who)))
(define-read-only (get-total-supply) (ok (var-get total-supply)))
(define-read-only (get-token-uri) (ok none))

;; Utility functions
(define-private (get-token-balance (who principal))
  (default-to u0 (map-get? token-balances who)))

;; Administrative functions
(define-public (mint (amount uint) (recipient principal))
  (let ((checked-amount amount)
        (checked-recipient recipient))
    (begin
      (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
      (asserts! (> checked-amount u0) (err ERR_ZERO_AMOUNT))
      (asserts! (not (is-eq checked-recipient tx-sender)) (err ERR_INVALID_RECIPIENT))
      (let ((recipient-balance (get-token-balance checked-recipient))
            (current-supply (var-get total-supply)))
        (begin
          (map-set token-balances checked-recipient (+ recipient-balance checked-amount))
          (var-set total-supply (+ current-supply checked-amount))
          (ok true))))))

(define-public (burn (amount uint))
  (let ((checked-amount amount))
    (begin
      (asserts! (> checked-amount u0) (err ERR_ZERO_AMOUNT))
      (match (map-get? token-balances tx-sender)
        balance
          (begin
            (asserts! (>= balance checked-amount) (err ERR_INSUFFICIENT_BALANCE))
            (let ((current-supply (var-get total-supply)))
              (begin
                (map-set token-balances tx-sender (- balance checked-amount))
                (var-set total-supply (- current-supply checked-amount))
                (ok true))))
        (err ERR_INSUFFICIENT_BALANCE)))))

(define-public (set-contract-owner (new-owner principal))
  (let ((checked-owner new-owner))
    (begin
      (asserts! (is-eq tx-sender (var-get contract-owner)) (err ERR_UNAUTHORIZED))
      (asserts! (not (is-eq checked-owner tx-sender)) (err ERR_INVALID_OWNER))
      (var-set contract-owner checked-owner)
      (ok true))))
