# Ada Strict Email Validator

The package provides functionality for validating email addresses syntax
based on the strict set of rules:

- Only Latin alphanumeric characters, periods, hyphens, and underscores
  are permitted.
- Punycode is not permitted.
- The maximum length of the local part is 48 octets.
- The maximum length of the domain part is 79 octets.
- A top-level domain (TLD) is mandatory and must consist of 2+
  alphabetic characters.

## Requirements

- Ada2012 compatible compiler.

## Dependencies

#### Package Itself

None. It only uses the Ada standard library.

#### Test Suite

- GNAT v14+
- GNATCOLL 24+
- trendy-test

## Example Usage

```ada
with Ada.Text_IO;            use Ada.Text_IO;
with Strict_Email_Validator; use Strict_Email_Validator;

procedure Example is
   Email : constant String := "example.user@domain.com";

   Result : constant Syntax_Validation_Result'Class := Validate_Syntax (Email);
begin
   if (Result in Syntax_Validation_Success) then

      Put_Line ("Email is valid.");

      declare
         Success_Result : constant Syntax_Validation_Success :=
           Syntax_Validation_Success (Result);

         Normalized_Email : constant String :=
           Success_Result.Normalized_Email_Address;
      begin
         Put_Line ("Normalized Email: " & Normalized_Email);
      end;
   else
      Put_Line ("Email is invalid.");

      declare
         Failed_Result : constant Syntax_Validation_Fail :=
           Syntax_Validation_Fail (Result);

         Error_Kind : constant Syntax_Error := Failed_Result.Error_Kind;
      begin
         Put_Line ("Error: " & Error_Kind'Image);
      end;
   end if;
end Example;
```
