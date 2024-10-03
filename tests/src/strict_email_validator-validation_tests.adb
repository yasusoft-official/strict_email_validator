with Ada.Text_IO;            use Ada.Text_IO;
with Trendy_Test.Assertions; use Trendy_Test.Assertions;
with Strict_Email_Validator_Tests_Helpers;
use Strict_Email_Validator_Tests_Helpers;
with GNATCOLL.JSON; use GNATCOLL.JSON;

package body Strict_Email_Validator.Validation_Tests is
   ---------------------------
   -- Test Email Validation --
   ---------------------------
   procedure Test_Email_Validation (T : in out Trendy_Test.Operation'Class) is
      Test_Suite : constant JSON_Array :=
        Read_Test_Suite_From_File ("test_suites/validation.json");
   begin
      T.Register;

      for Test_Case_Group of Test_Suite loop
         declare
            Is_Expect_Valid : constant Boolean :=
              Test_Case_Group.Get ("expect").Get ("isValid");
         begin
            for Test_Case of JSON_Array'(Test_Case_Group.Get ("cases")) loop
               Check_Email_For_Syntax_Validity :
               declare
                  Test_Email : constant String := Test_Case.Get;

                  Result : constant Syntax_Validation_Result'Class :=
                    Validate_Syntax (Test_Email);

                  Is_Valid : constant Boolean :=
                    Result in Syntax_Validation_Success;
               begin
                  if Is_Expect_Valid /= Is_Valid then
                     Fail (T, Test_Case_Group.Get ("desc"));
                  elsif not Is_Valid then

                     Check_For_Error_Kind :
                     declare
                        Caused_Error_Kind_Label : constant String :=
                          Syntax_Validation_Fail (Result).Error_Kind'Image;

                        Expected_Error_Kind_Label : constant String :=
                          Test_Case_Group.Get ("expect").Get ("ErrorKind");
                     begin
                        if Caused_Error_Kind_Label /= Expected_Error_Kind_Label
                        then
                           Ada.Text_IO.Put_Line
                             ("======================================");
                           Ada.Text_IO.Put_Line (Test_Case_Group.Get ("desc"));
                           Ada.Text_IO.Put_Line (Test_Email);
                           Ada.Text_IO.Put_Line
                             ("Caused: " & Caused_Error_Kind_Label);
                           Ada.Text_IO.Put_Line
                             ("Expected: " & Expected_Error_Kind_Label);
                           Ada.Text_IO.Put_Line
                             ("======================================");
                           Fail
                             (T,
                              Caused_Error_Kind_Label & " /= " &
                              Expected_Error_Kind_Label);
                        end if;
                     end Check_For_Error_Kind;

                  end if;
               end Check_Email_For_Syntax_Validity;
            end loop;
         end;
      end loop;

   end Test_Email_Validation;

   -------------------
   -- Tests Export  --
   -------------------
   function All_Tests return Trendy_Test.Test_Group is
   --!pp off
     [
        Test_Email_Validation'Access
     ];
   --!pp on

end Strict_Email_Validator.Validation_Tests;
