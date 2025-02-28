;; TradeGrid Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-invalid-price (err u101))
(define-constant err-invalid-quantity (err u102))
(define-constant err-order-not-found (err u103))
(define-constant err-commodity-not-found (err u104))

;; Data Maps
(define-map orders
  { order-id: uint }
  {
    seller: principal,
    commodity-id: uint,
    quantity: uint,
    price: uint,
    status: (string-ascii 10)
  }
)

(define-map commodities 
  { commodity-id: uint }
  {
    name: (string-ascii 64),
    symbol: (string-ascii 10),
    owner: principal
  }
)

;; Order Counter
(define-data-var next-order-id uint u1)

;; Public Functions
(define-public (create-order (commodity-id uint) (quantity uint) (price uint))
  (begin
    (asserts! (> quantity u0) (err err-invalid-quantity))
    (asserts! (> price u0) (err err-invalid-price))
    (asserts! (is-some (map-get? commodities {commodity-id: commodity-id})) 
             (err err-commodity-not-found))
    (let ((order-id (var-get next-order-id)))
      (map-set orders
        { order-id: order-id }
        {
          seller: tx-sender,
          commodity-id: commodity-id,
          quantity: quantity,
          price: price,
          status: "active"
        }
      )
      (var-set next-order-id (+ order-id u1))
      (print {event: "order-created", order-id: order-id, seller: tx-sender})
      (ok order-id)
    )
  )
)

(define-public (cancel-order (order-id uint))
  (let ((order (unwrap! (map-get? orders {order-id: order-id}) (err u404))))
    (asserts! (is-eq tx-sender (get seller order)) (err u403))
    (asserts! (is-eq (get status order) "active") (err u401))
    (map-set orders
      { order-id: order-id }
      (merge order { status: "cancelled" })
    )
    (print {event: "order-cancelled", order-id: order-id})
    (ok true)
  )
)

(define-public (execute-trade (order-id uint))
  (let (
    (order (unwrap! (map-get? orders {order-id: order-id}) (err u404)))
    (escrow-id (unwrap! (contract-call? .escrow create-escrow (get price order)) (err u500)))
  )
    (asserts! (is-eq (get status order) "active") (err u401))
    (map-set orders
      { order-id: order-id }
      (merge order { status: "executing" })
    )
    (print {event: "trade-executing", order-id: order-id, escrow-id: escrow-id})
    (ok escrow-id)
  )
)
