Feature: REST API with CRUD operations on payments
  In order to provide GUI for payments management 
  As a frontent developer
  I need to be able to retrive, update and delete payments

  Scenario: Create new payment
    When I send "POST" request to "/v1/payments" with body:
    """
    {
        "type": "Payment",
        "version": 0,
        "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
        "attributes": {
            "amount": "100.21",
            "beneficiary_party": {
                "account_name": "W Owens",
                "account_number": "31926819",
                "account_number_code": "BBAN",
                "account_type": 0,
                "address": "1 The Beneficiary Localtown SE2",
                "bank_id": "403000",
                "bank_id_code": "GBDSC",
                "name": "Wilfred Jeremiah Owens"
            },
            "charges_information": {
                "bearer_code": "SHAR",
                "sender_charges": [
                    {
                        "amount": "5.00",
                        "currency": "GBP"
                    },
                    {
                        "amount": "10.00",
                        "currency": "USD"
                    }
                ],
                "receiver_charges_amount": "1.00",
                "receiver_charges_currency": "USD"
            },
            "currency": "GBP",
            "debtor_party": {
                "account_name": "EJ Brown Black",
                "account_number": "GB29XABC10161234567801",
                "account_number_code": "IBAN",
                "address": "10 Debtor Crescent Sourcetown NE1",
                "bank_id": "203301",
                "bank_id_code": "GBDSC",
                "name": "Emelia Jane Brown"
            },
            "end_to_end_reference": "Wil piano Jan",
            "fx": {
                "contract_reference": "FX123",
                "exchange_rate": "2.00000",
                "original_amount": "200.42",
                "original_currency": "USD"
            },
            "numeric_reference": "1002001",
            "payment_id": "123456789012345678",
            "payment_purpose": "Paying for goods/services",
            "payment_scheme": "FPS",
            "payment_type": "Credit",
            "processing_date": "2017-01-18",
            "reference": "Payment for Em's piano lessons",
            "scheme_payment_sub_type": "InternetBanking",
            "scheme_payment_type": "ImmediatePayment",
            "sponsor_party": {
                "account_number": "56781234",
                "bank_id": "123123",
                "bank_id_code": "GBDSC"
            }
        }
    }
    """
    Then the response code should be 201
    And the response header "Location" should match "/v1/payments/[a-f0-9]{8}(-[a-f0-9]{4}){3}-[a-f0-9]{12}"
    And the database should have 1 record


  Scenario: Get single payment
    Given the database contains payments:
    | 4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43 |
    When I send "GET" request to "/v1/payments/4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43"
    Then the response code should be 200
    And the response body should match json:
    """
    {
        "type": "Payment",
        "id": "4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43",
        "version": 0,
        "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
        "attributes": {
            "amount": "100.21",
            "beneficiary_party": {
                "account_name": "W Owens",
                "account_number": "31926819",
                "account_number_code": "BBAN",
                "account_type": 0,
                "address": "1 The Beneficiary Localtown SE2",
                "bank_id": "403000",
                "bank_id_code": "GBDSC",
                "name": "Wilfred Jeremiah Owens"
            },
            "charges_information": {
                "bearer_code": "SHAR",
                "sender_charges": [
                    {
                        "amount": "5.00",
                        "currency": "GBP"
                    },
                    {
                        "amount": "10.00",
                        "currency": "USD"
                    }
                ],
                "receiver_charges_amount": "1.00",
                "receiver_charges_currency": "USD"
            },
            "currency": "GBP",
            "debtor_party": {
                "account_name": "EJ Brown Black",
                "account_number": "GB29XABC10161234567801",
                "account_number_code": "IBAN",
                "account_type": 0,
                "address": "10 Debtor Crescent Sourcetown NE1",
                "bank_id": "203301",
                "bank_id_code": "GBDSC",
                "name": "Emelia Jane Brown"
            },
            "end_to_end_reference": "Wil piano Jan",
            "fx": {
                "contract_reference": "FX123",
                "exchange_rate": "2.00000",
                "original_amount": "200.42",
                "original_currency": "USD"
            },
            "numeric_reference": "1002001",
            "payment_id": "123456789012345678",
            "payment_purpose": "Paying for goods/services",
            "payment_scheme": "FPS",
            "payment_type": "Credit",
            "processing_date": "2017-01-18",
            "reference": "Payment for Em's piano lessons",
            "scheme_payment_sub_type": "InternetBanking",
            "scheme_payment_type": "ImmediatePayment",
            "sponsor_party": {
                "account_number": "56781234",
                "bank_id": "123123",
                "bank_id_code": "GBDSC"
            }
        }
    }
    """

  Scenario: Delete payment
    Given the database contains payments:
    | 4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43 |
    When I send "DELETE" request to "/v1/payments/4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43"
    Then the response code should be 204
    And the database should have 0 records

  Scenario: Delete payment which does not exist
    When I send "DELETE" request to "/v1/payments/4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43"
    Then the response code should be 204

  Scenario: Payment not found
    Given the database contains payments:
    | 4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43 |
    When I send "GET" request to "/v1/payments/11111111-2222-3333-4444-555555555555"
    Then the response code should be 404

  Scenario: List payments
    Given the database contains payments:
      | 216d4da9-e59a-4cc6-8df3-3da6e7580b77 |
      | 4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43 |
    When I send "GET" request to "/v1/payments"
    Then the response code should be 200
    And the response body should match json:
    """
    [
      {
          "type": "Payment",
          "id": "216d4da9-e59a-4cc6-8df3-3da6e7580b77",
          "version": 0,
          "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
          "attributes": {
              "amount": "100.21",
              "beneficiary_party": {
                  "account_name": "W Owens",
                  "account_number": "31926819",
                  "account_number_code": "BBAN",
                  "account_type": 0,
                  "address": "1 The Beneficiary Localtown SE2",
                  "bank_id": "403000",
                  "bank_id_code": "GBDSC",
                  "name": "Wilfred Jeremiah Owens"
              },
              "charges_information": {
                  "bearer_code": "SHAR",
                  "sender_charges": [
                      {
                          "amount": "5.00",
                          "currency": "GBP"
                      },
                      {
                          "amount": "10.00",
                          "currency": "USD"
                      }
                  ],
                  "receiver_charges_amount": "1.00",
                  "receiver_charges_currency": "USD"
              },
              "currency": "GBP",
              "debtor_party": {
                  "account_name": "EJ Brown Black",
                  "account_number": "GB29XABC10161234567801",
                  "account_number_code": "IBAN",
                  "account_type": 0,
                  "address": "10 Debtor Crescent Sourcetown NE1",
                  "bank_id": "203301",
                  "bank_id_code": "GBDSC",
                  "name": "Emelia Jane Brown"
              },
              "end_to_end_reference": "Wil piano Jan",
              "fx": {
                  "contract_reference": "FX123",
                  "exchange_rate": "2.00000",
                  "original_amount": "200.42",
                  "original_currency": "USD"
              },
              "numeric_reference": "1002001",
              "payment_id": "123456789012345678",
              "payment_purpose": "Paying for goods/services",
              "payment_scheme": "FPS",
              "payment_type": "Credit",
              "processing_date": "2017-01-18",
              "reference": "Payment for Em's piano lessons",
              "scheme_payment_sub_type": "InternetBanking",
              "scheme_payment_type": "ImmediatePayment",
              "sponsor_party": {
                  "account_number": "56781234",
                  "bank_id": "123123",
                  "bank_id_code": "GBDSC"
              }
          }
      },
      {
          "type": "Payment",
          "id": "4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43",
          "version": 0,
          "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
          "attributes": {
              "amount": "100.21",
              "beneficiary_party": {
                  "account_name": "W Owens",
                  "account_number": "31926819",
                  "account_number_code": "BBAN",
                  "account_type": 0,
                  "address": "1 The Beneficiary Localtown SE2",
                  "bank_id": "403000",
                  "bank_id_code": "GBDSC",
                  "name": "Wilfred Jeremiah Owens"
              },
              "charges_information": {
                  "bearer_code": "SHAR",
                  "sender_charges": [
                      {
                          "amount": "5.00",
                          "currency": "GBP"
                      },
                      {
                          "amount": "10.00",
                          "currency": "USD"
                      }
                  ],
                  "receiver_charges_amount": "1.00",
                  "receiver_charges_currency": "USD"
              },
              "currency": "GBP",
              "debtor_party": {
                  "account_name": "EJ Brown Black",
                  "account_number": "GB29XABC10161234567801",
                  "account_number_code": "IBAN",
                  "account_type": 0,
                  "address": "10 Debtor Crescent Sourcetown NE1",
                  "bank_id": "203301",
                  "bank_id_code": "GBDSC",
                  "name": "Emelia Jane Brown"
              },
              "end_to_end_reference": "Wil piano Jan",
              "fx": {
                  "contract_reference": "FX123",
                  "exchange_rate": "2.00000",
                  "original_amount": "200.42",
                  "original_currency": "USD"
              },
              "numeric_reference": "1002001",
              "payment_id": "123456789012345678",
              "payment_purpose": "Paying for goods/services",
              "payment_scheme": "FPS",
              "payment_type": "Credit",
              "processing_date": "2017-01-18",
              "reference": "Payment for Em's piano lessons",
              "scheme_payment_sub_type": "InternetBanking",
              "scheme_payment_type": "ImmediatePayment",
              "sponsor_party": {
                  "account_number": "56781234",
                  "bank_id": "123123",
                  "bank_id_code": "GBDSC"
              }
          }
      }
    ]
    """

  Scenario: Update payments amount from "100.21" to "999.99"
    Given the database contains payments:
    | 4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43 |
    When I send "PUT" request to "/v1/payments/4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43" with body:
    """
    {
        "type": "Payment",
        "version": 0,
        "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
        "attributes": {
            "amount": "999.99",
            "beneficiary_party": {
                "account_name": "W Owens",
                "account_number": "31926819",
                "account_number_code": "BBAN",
                "account_type": 0,
                "address": "1 The Beneficiary Localtown SE2",
                "bank_id": "403000",
                "bank_id_code": "GBDSC",
                "name": "Wilfred Jeremiah Owens"
            },
            "charges_information": {
                "bearer_code": "SHAR",
                "sender_charges": [
                    {
                        "amount": "5.00",
                        "currency": "GBP"
                    },
                    {
                        "amount": "10.00",
                        "currency": "USD"
                    }
                ],
                "receiver_charges_amount": "1.00",
                "receiver_charges_currency": "USD"
            },
            "currency": "GBP",
            "debtor_party": {
                "account_name": "EJ Brown Black",
                "account_number": "GB29XABC10161234567801",
                "account_number_code": "IBAN",
                "account_type": 0,
                "address": "10 Debtor Crescent Sourcetown NE1",
                "bank_id": "203301",
                "bank_id_code": "GBDSC",
                "name": "Emelia Jane Brown"
            },
            "end_to_end_reference": "Wil piano Jan",
            "fx": {
                "contract_reference": "FX123",
                "exchange_rate": "2.00000",
                "original_amount": "200.42",
                "original_currency": "USD"
            },
            "numeric_reference": "1002001",
            "payment_id": "123456789012345678",
            "payment_purpose": "Paying for goods/services",
            "payment_scheme": "FPS",
            "payment_type": "Credit",
            "processing_date": "2017-01-18",
            "reference": "Payment for Em's piano lessons",
            "scheme_payment_sub_type": "InternetBanking",
            "scheme_payment_type": "ImmediatePayment",
            "sponsor_party": {
                "account_number": "56781234",
                "bank_id": "123123",
                "bank_id_code": "GBDSC"
            }
        }
    }
    """
    Then the response code should be 200
    And the response body should match json:
    """
    {
        "id": "4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43",
        "type": "Payment",
        "version": 0,
        "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
        "attributes": {
            "amount": "999.99",
            "beneficiary_party": {
                "account_name": "W Owens",
                "account_number": "31926819",
                "account_number_code": "BBAN",
                "account_type": 0,
                "address": "1 The Beneficiary Localtown SE2",
                "bank_id": "403000",
                "bank_id_code": "GBDSC",
                "name": "Wilfred Jeremiah Owens"
            },
            "charges_information": {
                "bearer_code": "SHAR",
                "sender_charges": [
                    {
                        "amount": "5.00",
                        "currency": "GBP"
                    },
                    {
                        "amount": "10.00",
                        "currency": "USD"
                    }
                ],
                "receiver_charges_amount": "1.00",
                "receiver_charges_currency": "USD"
            },
            "currency": "GBP",
            "debtor_party": {
                "account_name": "EJ Brown Black",
                "account_number": "GB29XABC10161234567801",
                "account_number_code": "IBAN",
                "account_type": 0,
                "address": "10 Debtor Crescent Sourcetown NE1",
                "bank_id": "203301",
                "bank_id_code": "GBDSC",
                "name": "Emelia Jane Brown"
            },
            "end_to_end_reference": "Wil piano Jan",
            "fx": {
                "contract_reference": "FX123",
                "exchange_rate": "2.00000",
                "original_amount": "200.42",
                "original_currency": "USD"
            },
            "numeric_reference": "1002001",
            "payment_id": "123456789012345678",
            "payment_purpose": "Paying for goods/services",
            "payment_scheme": "FPS",
            "payment_type": "Credit",
            "processing_date": "2017-01-18",
            "reference": "Payment for Em's piano lessons",
            "scheme_payment_sub_type": "InternetBanking",
            "scheme_payment_type": "ImmediatePayment",
            "sponsor_party": {
                "account_number": "56781234",
                "bank_id": "123123",
                "bank_id_code": "GBDSC"
            }
        }
    }
    """
    And the database should have record with id "4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43" and value "999.99" under path "attributes.amount"

  Scenario: Insert payment with external ID
    When I send "PUT" request to "/v1/payments/4ee3a8d8-ca7b-4290-a52c-dd5b6165ec43" with body:
    """
    {
        "type": "Payment",
        "version": 0,
        "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
        "attributes": {
            "amount": "100.21",
            "beneficiary_party": {
                "account_name": "W Owens",
                "account_number": "31926819",
                "account_number_code": "BBAN",
                "account_type": 0,
                "address": "1 The Beneficiary Localtown SE2",
                "bank_id": "403000",
                "bank_id_code": "GBDSC",
                "name": "Wilfred Jeremiah Owens"
            },
            "charges_information": {
                "bearer_code": "SHAR",
                "sender_charges": [
                    {
                        "amount": "5.00",
                        "currency": "GBP"
                    },
                    {
                        "amount": "10.00",
                        "currency": "USD"
                    }
                ],
                "receiver_charges_amount": "1.00",
                "receiver_charges_currency": "USD"
            },
            "currency": "GBP",
            "debtor_party": {
                "account_name": "EJ Brown Black",
                "account_number": "GB29XABC10161234567801",
                "account_number_code": "IBAN",
                "account_type": 0,
                "address": "10 Debtor Crescent Sourcetown NE1",
                "bank_id": "203301",
                "bank_id_code": "GBDSC",
                "name": "Emelia Jane Brown"
            },
            "end_to_end_reference": "Wil piano Jan",
            "fx": {
                "contract_reference": "FX123",
                "exchange_rate": "2.00000",
                "original_amount": "200.42",
                "original_currency": "USD"
            },
            "numeric_reference": "1002001",
            "payment_id": "123456789012345678",
            "payment_purpose": "Paying for goods/services",
            "payment_scheme": "FPS",
            "payment_type": "Credit",
            "processing_date": "2017-01-18",
            "reference": "Payment for Em's piano lessons",
            "scheme_payment_sub_type": "InternetBanking",
            "scheme_payment_type": "ImmediatePayment",
            "sponsor_party": {
                "account_number": "56781234",
                "bank_id": "123123",
                "bank_id_code": "GBDSC"
            }
        }
    }
    """
    Then the response code should be 200
    And the database should have 1 record

  Scenario: Payment with external ID which is not valid UUID
    When I send "PUT" request to "/v1/payments/4ee3a8d8-XXXX-YYYY-ZZZZ-dd5b6165ec43" with body:
    """
    {
        "type": "Payment",
        "version": 0,
        "organisation_id": "743d5b63-8e6f-432e-a8fa-c5d8d2ee5fcb",
        "attributes": {
            "amount": "100.21",
            "beneficiary_party": {
                "account_name": "W Owens",
                "account_number": "31926819",
                "account_number_code": "BBAN",
                "account_type": 0,
                "address": "1 The Beneficiary Localtown SE2",
                "bank_id": "403000",
                "bank_id_code": "GBDSC",
                "name": "Wilfred Jeremiah Owens"
            },
            "charges_information": {
                "bearer_code": "SHAR",
                "sender_charges": [
                    {
                        "amount": "5.00",
                        "currency": "GBP"
                    },
                    {
                        "amount": "10.00",
                        "currency": "USD"
                    }
                ],
                "receiver_charges_amount": "1.00",
                "receiver_charges_currency": "USD"
            },
            "currency": "GBP",
            "debtor_party": {
                "account_name": "EJ Brown Black",
                "account_number": "GB29XABC10161234567801",
                "account_number_code": "IBAN",
                "account_type": 0,
                "address": "10 Debtor Crescent Sourcetown NE1",
                "bank_id": "203301",
                "bank_id_code": "GBDSC",
                "name": "Emelia Jane Brown"
            },
            "end_to_end_reference": "Wil piano Jan",
            "fx": {
                "contract_reference": "FX123",
                "exchange_rate": "2.00000",
                "original_amount": "200.42",
                "original_currency": "USD"
            },
            "numeric_reference": "1002001",
            "payment_id": "123456789012345678",
            "payment_purpose": "Paying for goods/services",
            "payment_scheme": "FPS",
            "payment_type": "Credit",
            "processing_date": "2017-01-18",
            "reference": "Payment for Em's piano lessons",
            "scheme_payment_sub_type": "InternetBanking",
            "scheme_payment_type": "ImmediatePayment",
            "sponsor_party": {
                "account_number": "56781234",
                "bank_id": "123123",
                "bank_id_code": "GBDSC"
            }
        }
    }
    """
    Then the response code should be 400
    And the response body should match json:
    """
    {
        "error": "invalid id format, uuid required"
    }
    """