;; Decentralized Content Marketplace
;; A marketplace where creators can tokenize and sell digital content with automated royalty distributions

(define-data-var contract-owner principal tx-sender)
(define-map contents
  { content-id: uint }
  {
    creator: principal,
    title: (string-utf8 100),
    content-uri: (string-utf8 256),
    price: uint,
    royalty-percentage: uint,
    is-subscription: bool,
    subscription-duration: uint, ;; in blocks
    is-active: bool,
    created-at: uint
  }
)

;; Map for collaborators and their royalty percentages
(define-map content-collaborators
  { content-id: uint, collaborator: principal }
  { royalty-percentage: uint }
)

;; Map to keep track of content purchases and subscriptions
(define-map purchases
  { buyer: principal, content-id: uint }
  {
    purchase-id: uint,
    purchase-price: uint,
    expires-at: uint, ;; 0 for one-time purchase, block height for subscriptions
    purchased-at: uint
  }
)