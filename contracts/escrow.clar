;; Escrow Contract

(define-constant err-invalid-amount (err u201))
(define-constant err-unauthorized (err u202))

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
  (begin
    (asserts! (> amount u0) err-invalid-amount)
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
      (print {event: "escrow-created", escrow-id: escrow-id})
      (ok escrow-id)
    )
  )
)

(define-public (complete-escrow (escrow-id uint))
  (let ((escrow (unwrap! (map-get? escrows {escrow-id: escrow-id}) (err u404))))
    (asserts! (is-eq tx-sender (get buyer escrow)) err-unauthorized)
    (asserts! (is-eq (get status escrow) "pending") (err u401))
    (map-set escrows
      { escrow-id: escrow-id }
      (merge escrow { status: "completed" })
    )
    (print {event: "escrow-completed", escrow-id: escrow-id})
    (ok true)
  )
)
