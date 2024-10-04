with Ada.Strings.Bounded;

package Strict_Email_Validator is
   ------------------------
   -- Syntax Error Kinds --
   ------------------------
   type Syntax_Error is
     (Missing_At_Sign,
      Missing_Local_Part,
      Missing_Domain,
      Consecutive_Periods,
      Local_Part_Too_Long,
      Domain_Too_Long,
      Local_Part_Starts_With_Period,
      Local_Part_Ends_With_Period,
      Invalid_Character_In_Local_Part,
      Domain_Ends_With_Period,
      Missing_Period_In_Domain,
      Domain_Starts_With_Non_Alphanumeric,
      Invalid_Character_In_Domain,
      Domain_Starts_With_Two_Letters_Two_Hyphens,
      Adjacent_Periods_And_Hyphens_In_Domain,
      Invalid_TLD);

   -------------------------------
   -- Syntax Validation Results --
   -------------------------------

   type Syntax_Validation_Result is abstract tagged private;

   type Syntax_Validation_Success is new Syntax_Validation_Result with private;

   type Syntax_Validation_Fail is new Syntax_Validation_Result with private;

   -------------------------------------------------
   -- Successful Syntax Validation Result Getters --
   -------------------------------------------------

   function Normalized_Email_Address
     (Success_Result : Syntax_Validation_Success) return String;

   ---------------------------------------------
   -- Failed Syntax Validation Result Getters --
   ---------------------------------------------

   function Error_Kind
     (Failed_Result : Syntax_Validation_Fail) return Syntax_Error;

   -----------------------
   -- Syntax Validation --
   -----------------------
   function Validate_Syntax
     (Email_Address : String) return Syntax_Validation_Result'Class;

private

   ---------------
   -- Constants --
   ---------------

   Max_Recipient_Name_Length_In_Octets : constant Integer := 48;

   Max_Domain_Length_In_Octets : constant Integer := 79;

   Max_Email_Address_Length_In_Octets : constant Integer :=
     Max_Recipient_Name_Length_In_Octets + Max_Domain_Length_In_Octets + 1;

   -------------------------------
   -- Email Address Strings Type --
   -------------------------------
   package Email_Address_String is new Ada.Strings.Bounded
     .Generic_Bounded_Length
     (Max =>
        Max_Recipient_Name_Length_In_Octets + Max_Domain_Length_In_Octets + 1);

   -------------------------------
   -- Syntax Validation Results --
   -------------------------------
   type Syntax_Validation_Result is abstract tagged null record;

   type Syntax_Validation_Success is new Syntax_Validation_Result with record
      Normalized_Value : Email_Address_String.Bounded_String;
   end record;

   type Syntax_Validation_Fail is new Syntax_Validation_Result with record
      Error_Kind : Syntax_Error;
   end record;

end Strict_Email_Validator;
