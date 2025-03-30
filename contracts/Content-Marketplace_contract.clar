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

;; Map for reviews and ratings
(define-map reviews
  { reviewer: principal, content-id: uint }
  {
    rating: uint,            ;; 1-5 star rating
    review-text: (string-utf8 500),
    review-date: uint
  }
)

;; Counter for content IDs
(define-data-var next-content-id uint u1)
(define-data-var next-purchase-id uint u1)

;; Error codes
(define-constant ERR-NOT-AUTHORIZED u1)
(define-constant ERR-CONTENT-NOT-FOUND u2)
(define-constant ERR-PRICE-NOT-MET u3)
(define-constant ERR-ALREADY-PURCHASED u4)
(define-constant ERR-INVALID-RATING u5)
(define-constant ERR-CONTENT-NOT-ACTIVE u6)
(define-constant ERR-ALREADY-REVIEWED u7)
(define-constant ERR-NOT-PURCHASED u8)
(define-constant ERR-INVALID-ROYALTY-PERCENTAGE u9)
(define-constant ERR-TOTAL-ROYALTY-EXCEEDS-100 u10)

;; Read-only functions
(define-read-only (get-content (content-id uint))
  (map-get? contents { content-id: content-id })
)

(define-read-only (get-content-collaborator (content-id uint) (collaborator principal))
  (map-get? content-collaborators { content-id: content-id, collaborator: collaborator })
)

(define-read-only (get-purchase (buyer principal) (content-id uint))
  (map-get? purchases { buyer: buyer, content-id: content-id })
)

(define-read-only (get-review (reviewer principal) (content-id uint))
  (map-get? reviews { reviewer: reviewer, content-id: content-id })
)

(define-read-only (has-active-subscription (buyer principal) (content-id uint))
  (match (get-purchase buyer content-id)
    purchase (> (get expires-at purchase) block-height)
    false
  )
)

(define-read-only (has-purchased (buyer principal) (content-id uint))
  (is-some (get-purchase buyer content-id))
)

(define-read-only (calculate-average-rating (content-id uint))
  ;; This is a simplified implementation - in practice you'd iterate through all reviews
  ;; You might want to store cumulative rating and count separately for efficiency
  u0
)

;; Public functions
(define-public (register-content 
  (title (string-utf8 100))
  (content-uri (string-utf8 256))
  (price uint)
  (royalty-percentage uint)
  (is-subscription bool)
  (subscription-duration uint)
)
  (let 
    (
      (content-id (var-get next-content-id))
    )
    
    ;; Validate royalty percentage is between 0-100
    (asserts! (<= royalty-percentage u100) (err ERR-INVALID-ROYALTY-PERCENTAGE))
    
    ;; Register the content
    (map-set contents
      { content-id: content-id }
      {
        creator: tx-sender,
        title: title,
        content-uri: content-uri,
        price: price,
        royalty-percentage: royalty-percentage,
        is-subscription: is-subscription,
        subscription-duration: subscription-duration,
        is-active: true,
        created-at: block-height
      }
    )
    
    ;; Increment the content ID counter
    (var-set next-content-id (+ content-id u1))
    
    (ok content-id)
  )
)

(define-public (add-collaborator (content-id uint) (collaborator principal) (royalty-percentage uint))
  (let
    (
      (content (unwrap! (get-content content-id) (err ERR-CONTENT-NOT-FOUND)))
      (total-royalty (default-to u0 (get-collaborators-total-royalty content-id)))
    )
    
    ;; Check that the caller is the content creator
    (asserts! (is-eq tx-sender (get creator content)) (err ERR-NOT-AUTHORIZED))
    
    ;; Validate royalty percentage
    (asserts! (<= royalty-percentage u100) (err ERR-INVALID-ROYALTY-PERCENTAGE))
    
    ;; Make sure total royalty doesn't exceed 100%
    (asserts! (<= (+ total-royalty royalty-percentage) u100) (err ERR-TOTAL-ROYALTY-EXCEEDS-100))
    
    ;; Add collaborator
    (map-set content-collaborators
      { content-id: content-id, collaborator: collaborator }
      { royalty-percentage: royalty-percentage }
    )
    
    (ok true)
  )
)

(define-read-only (get-collaborators-total-royalty (content-id uint))
  ;; In practice, you'd need to enumerate all collaborators and sum their percentages
  ;; This is a simplified placeholder
  u0
)

(define-public (purchase-content (content-id uint))
  (let
    (
      (content (unwrap! (get-content content-id) (err ERR-CONTENT-NOT-FOUND)))
      (buyer tx-sender)
      (price (get price content))
      (creator (get creator content))
      (purchase-id (var-get next-purchase-id))
      (expires-at (if (get is-subscription content)
                     (+ block-height (get subscription-duration content))
                     u0))
    )
    
    ;; Check that content is active
    (asserts! (get is-active content) (err ERR-CONTENT-NOT-ACTIVE))
    
    ;; Check if already purchased (for non-subscription)
    (when (and (not (get is-subscription content))
             (has-purchased buyer content-id))
      (err ERR-ALREADY-PURCHASED))
    
    ;; Process the payment
    (try! (stx-transfer? price buyer creator))
    
    ;; Record the purchase
    (map-set purchases
      { buyer: buyer, content-id: content-id }
      {
        purchase-id: purchase-id,
        purchase-price: price,
        expires-at: expires-at,
        purchased-at: block-height
      }
    )