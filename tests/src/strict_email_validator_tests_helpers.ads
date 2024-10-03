with GNATCOLL.JSON; use GNATCOLL.JSON;

package Strict_Email_Validator_Tests_Helpers is

   function Read_Test_Suite_From_File (File_Name : String) return JSON_Value;

   function Read_Test_Suite_From_File (File_Name : String) return JSON_Array;

end Strict_Email_Validator_Tests_Helpers;
