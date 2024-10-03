with Ada.Directories;
with Ada.Direct_IO;

package body Strict_Email_Validator_Tests_Helpers is

   function Read_Test_Suite_From_File (File_Name : String) return JSON_Value is
      File_Size : constant Natural :=
        Natural (Ada.Directories.Size (File_Name));

      subtype File_String is String (1 .. File_Size);
      package File_String_IO is new Ada.Direct_IO (File_String);

      File     : File_String_IO.File_Type;
      Contents : File_String;
   begin
      File_String_IO.Open
        (File, Mode => File_String_IO.In_File, Name => File_Name);
      File_String_IO.Read (File, Item => Contents);
      File_String_IO.Close (File);

      return Val : constant JSON_Value := Read (Contents);
   end Read_Test_Suite_From_File;

   function Read_Test_Suite_From_File (File_Name : String) return JSON_Array is
      Val : constant JSON_Value := Read_Test_Suite_From_File (File_Name);
      Val_As_Array : constant JSON_Array := Val.Get;
   begin
      return Val_As_Array;
   end Read_Test_Suite_From_File;

end Strict_Email_Validator_Tests_Helpers;
