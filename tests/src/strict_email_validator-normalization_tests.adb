with Trendy_Test.Assertions; use Trendy_Test.Assertions;
with Strict_Email_Validator_Tests_Helpers;
use Strict_Email_Validator_Tests_Helpers;
with GNATCOLL.JSON; use GNATCOLL.JSON;

package body Strict_Email_Validator.Normalization_Tests is
   ------------------------------
   -- Test Email Normalization --
   ------------------------------
   procedure Test_Email_Normalization (T : in out Trendy_Test.Operation'Class)
   is
      Test_Suite : constant JSON_Array :=
        Read_Test_Suite_From_File ("test_suites/normalization.json");
   begin
      T.Register;

      for Test_Case_Group of Test_Suite loop
         declare
            Expected_Normalized_Email : constant String :=
              Test_Case_Group.Get ("expect");

         begin
            for Test_Case of JSON_Array'(Test_Case_Group.Get ("cases")) loop
               Check_Normalized_Email :
               declare
                  Test_Email : constant String := Test_Case.Get;

                  Result : constant Syntax_Validation_Success :=
                    Syntax_Validation_Success (Validate_Syntax (Test_Email));

                  Actual_Normalized_Email_String : constant String :=
                    Result.Normalized_Email_Address;

               begin
                  if not
                    (Expected_Normalized_Email =
                     Actual_Normalized_Email_String)
                  then
                     Fail
                       (T,
                        Expected_Normalized_Email & " /= " &
                        Actual_Normalized_Email_String);
                  end if;

               end Check_Normalized_Email;

            end loop;
         end;
      end loop;

   end Test_Email_Normalization;

   -------------------
   -- Tests Export  --
   -------------------
   function All_Tests return Trendy_Test.Test_Group is
   --!pp off
     [
        Test_Email_Normalization'Access
     ];
   --!pp on

end Strict_Email_Validator.Normalization_Tests;
