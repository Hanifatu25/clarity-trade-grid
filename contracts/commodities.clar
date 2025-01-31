;; Commodities Token Contract

(define-fungible-token commodity-token)

(define-constant contract-owner tx-sender)

(define-public (mint (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender contract-owner) (err u403))
    (ft-mint? commodity-token amount recipient)
  )
)

(define-public (transfer (amount uint) (recipient principal))
  (ft-transfer? commodity-token amount tx-sender recipient)
)
