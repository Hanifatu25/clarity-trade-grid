;; Escrow Contract

(define-map escrows
  { escrow-id: uint }
  {
    seller: principal,
    buyer: principal,
    amount: uint,
    status: (string-ascii 10)
  }
)

(define-data-var next-escrow-id uint u1)

(define-public (create-escrow (amount uint))
  (let ((escrow-id (var-get next-escrow-id)))
    (map-set escrows
      { escrow-id: escrow-id }
      {
        seller: contract-caller,
        buyer: tx-sender,
        amount: amount,
        status: "pending"
      }
    )
    (var-set next-escrow-id (+ escrow-id u1))
    (ok escrow-id)
  )
)
