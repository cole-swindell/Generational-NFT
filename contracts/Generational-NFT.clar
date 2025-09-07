;; Generational NFT Contract
;; NFTs that can reproduce and create children with inherited properties

;; Define the NFT
(define-non-fungible-token generational-nft uint)

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-not-authorized (err u102))
(define-constant err-already-exists (err u103))
(define-constant err-invalid-generation (err u104))

;; Data Variables
(define-data-var last-token-id uint u0)
(define-data-var breeding-cost uint u1000000) ;; 1 STX in microSTX

;; Data Maps
(define-map token-metadata uint {
  name: (string-ascii 50),
  generation: uint,
  parent1: (optional uint),
  parent2: (optional uint),
  birth-block: uint,
  color: (string-ascii 20),
  size: uint,
  rarity: uint
})

(define-map token-breeding-count uint uint)

;; Helper function to get maximum of two numbers
(define-private (max-uint (a uint) (b uint))
  (if (> a b) a b))

;; Helper function to get minimum of two numbers
(define-private (min-uint (a uint) (b uint))
  (if (< a b) a b))

;; Get next token ID
(define-private (get-next-token-id)
  (ok (+ (var-get last-token-id) u1)))

;; Mint genesis NFT (generation 0)
(define-public (mint-genesis (recipient principal) (name (string-ascii 50)) (color (string-ascii 20)) (size uint))
  (let ((token-id (unwrap! (get-next-token-id) (err u500))))
    (try! (nft-mint? generational-nft token-id recipient))
    (map-set token-metadata token-id {
      name: name,
      generation: u0,
      parent1: none,
      parent2: none,
      birth-block: block-height,
      color: color,
      size: size,
      rarity: u1
    })
    (map-set token-breeding-count token-id u0)
    (var-set last-token-id token-id)
    (ok token-id)))

;; Breed two NFTs to create a child
(define-public (breed (parent1-id uint) (parent2-id uint) (child-name (string-ascii 50)))
  (let (
    (parent1-data (unwrap! (map-get? token-metadata parent1-id) err-not-found))
    (parent2-data (unwrap! (map-get? token-metadata parent2-id) err-not-found))
    (parent1-owner (unwrap! (nft-get-owner? generational-nft parent1-id) err-not-found))
    (parent2-owner (unwrap! (nft-get-owner? generational-nft parent2-id) err-not-found))
    (child-token-id (unwrap! (get-next-token-id) (err u500)))
    (breeding-fee (var-get breeding-cost))
  )
    ;; Check authorization - caller must own at least one parent
    (asserts! (or (is-eq tx-sender parent1-owner) (is-eq tx-sender parent2-owner)) err-not-authorized)

    ;; Pay breeding cost
    (try! (stx-transfer? breeding-fee tx-sender contract-owner))

    ;; Create child NFT with inherited properties
    (try! (nft-mint? generational-nft child-token-id tx-sender))

    ;; Calculate inherited properties
    (let (
      (new-generation (+ (max-uint (get generation parent1-data) (get generation parent2-data)) u1))
      (inherited-color (if (is-eq (get color parent1-data) (get color parent2-data)) 
                          (get color parent1-data) 
                          "mixed"))
      (inherited-size (/ (+ (get size parent1-data) (get size parent2-data)) u2))
      (inherited-rarity (min-uint (get rarity parent1-data) (get rarity parent2-data)))
    )

      ;; Set child metadata
      (map-set token-metadata child-token-id {
        name: child-name,
        generation: new-generation,
        parent1: (some parent1-id),
        parent2: (some parent2-id),
        birth-block: block-height,
        color: inherited-color,
        size: inherited-size,
        rarity: inherited-rarity
      })

      ;; Initialize breeding count for child
      (map-set token-breeding-count child-token-id u0)

      ;; Update parent breeding counts
      (map-set token-breeding-count parent1-id 
        (+ (default-to u0 (map-get? token-breeding-count parent1-id)) u1))
      (map-set token-breeding-count parent2-id 
        (+ (default-to u0 (map-get? token-breeding-count parent2-id)) u1))

      ;; Update last token ID
      (var-set last-token-id child-token-id)
      (ok child-token-id))))

;; Transfer NFT
(define-public (transfer (token-id uint) (sender principal) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender sender) err-not-authorized)
    (nft-transfer? generational-nft token-id sender recipient)))

;; Get NFT metadata
(define-read-only (get-metadata (token-id uint))
  (map-get? token-metadata token-id))

;; Get NFT owner
(define-read-only (get-owner (token-id uint))
  (ok (nft-get-owner? generational-nft token-id)))

;; Get token URI (placeholder)
(define-read-only (get-token-uri (token-id uint))
  (ok none))

;; Get breeding count for a token
(define-read-only (get-breeding-count (token-id uint))
  (default-to u0 (map-get? token-breeding-count token-id)))

;; Get family tree (parents and children)
(define-read-only (get-family-tree (token-id uint))
  (let ((metadata (unwrap! (map-get? token-metadata token-id) err-not-found)))
    (ok {
      token-id: token-id,
      generation: (get generation metadata),
      parent1: (get parent1 metadata),
      parent2: (get parent2 metadata)
    })))

;; Get last token ID
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id)))

;; Admin function to update breeding cost
(define-public (set-breeding-cost (new-cost uint))
  (begin
    (asserts! (is-eq tx-sender contract-owner) err-owner-only)
    (var-set breeding-cost new-cost)
    (ok true)))

;; Get current breeding cost
(define-read-only (get-breeding-cost)
  (ok (var-get breeding-cost)))