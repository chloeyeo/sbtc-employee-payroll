;; Define the employees' data variables
(define-map skill-levels { employee: principal } { level: uint })
(define-map skill-levels { skill-level: uint } { payment-amount: uint })
(define-map skill-tests { test-id: uint } { payment-amount: uint })

(define-data-var skill-levels { level-1: uint, level-2: uint, level-3: uint, level-4: uint })

;; Employees' skills get mapped into amount of sBTC they get paid back into their wallet
(define-public (pay (employee principal) (skill-level uint))
  (require (is-valid-principal employee))
  (require (<= skill-level 4)) ;; Assuming skill level ranges from 1 to 4

  (let ((payment-amount (match skill-level
                          1 (var-get skill-levels level-1)
                          2 (var-get skill-levels level-2)
                          3 (var-get skill-levels level-3)
                          4 (var-get skill-levels level-4)
                          )))
    (require (> payment-amount 0)) ;; Ensure payment amount is greater than 0

    ;; Transfer the payment amount to the employee's wallet
    (try! (contract-call? .asset transfer payment-amount employee (as-contract employee) none))
    (ok true)
  )
)

(define-public (take-test (employee principal) (test-id uint))
  (require (is-valid-principal employee))
  (require (map-contains? skill-tests { test-id: test-id })) ;; Check if the test exists

  (let ((payment-amount (map-get? skill-tests { test-id: test-id })))
    (require (> payment-amount 0)) ;; Ensure payment amount is greater than 0

    ;; Transfer the payment amount from the employee's wallet to the firm's wallet
    (try! (contract-call? .asset transfer payment-amount employee (as-contract firm-wallet) none))

    ;; Simulate a 50% chance of passing the test
    (let ((pass (<= (random-u8) 127))) ;; Assuming random-u8 generates a random number between 0 and 255
      (if pass
        (let ((nft-badge (create-nft-badge employee test-id))) ;; Create an NFT badge for the employee
          (try! (contract-call? .asset transfer-nft nft-badge employee (as-contract employee) none)) ;; Transfer the NFT badge to the employee's wallet
          (ok nft-badge))
        (ok false)
      )
    )
  )
)

