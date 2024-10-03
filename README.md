# Ada Strict Email Validator

The package provides functionality for validating email addresses syntax
based on the strict set of rules:

- Only alphanumeric characters, ., -, and \_ are permitted.
- The maximum length of the local part is 48 octets.
- The maximum length of the domain is 79 octets.
- A top-level domain (TLD) is mandatory and must consist of 2+
  alphabetic characters.
