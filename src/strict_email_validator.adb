with Ada.Strings.Maps;
with Ada.Characters.Latin_1;
with Ada.Characters.Handling; use Ada.Characters.Handling;
with Ada.Strings;             use Ada.Strings;
with Ada.Strings.Fixed;       use Ada.Strings.Fixed;

package body Strict_Email_Validator is
   -------------------------------------------
   -- Success Validation Result Constructor --
   -------------------------------------------
   function New_Syntax_Validation_Success
     (Normalized_Value : String) return Syntax_Validation_Success
   is
   begin
      return
        ((Normalized_Value =>
            Email_Address_String.To_Bounded_String (Normalized_Value)));
   end New_Syntax_Validation_Success;

   ------------------------------------------
   -- Failed Validation Result Constructor --
   ------------------------------------------
   function New_Syntax_Validation_Fail
     (Error_Kind : Syntax_Error) return Syntax_Validation_Fail
   is
   begin
      return (Error_Kind => Error_Kind);
   end New_Syntax_Validation_Fail;

   -------------------------------------------------
   -- Successful Syntax Validation Result Getters --
   -------------------------------------------------

   function Normalized_Email_Address
     (Success_Result : Syntax_Validation_Success) return String
   is
   begin
      return Email_Address_String.To_String (Success_Result.Normalized_Value);
   end Normalized_Email_Address;

   -------------------
   -- Normalization --
   -------------------
   function Normalize (Email_Address : String) return String is
      use Ada.Strings.Maps;

      Printable_Whitespace_Characters_Sequence : constant String :=
        [Ada.Characters.Latin_1.Space,
        Ada.Characters.Latin_1.HT,
        Ada.Characters.Latin_1.CR,
        Ada.Characters.Latin_1.LF];

      Whitespace_Set : constant Character_Set :=
        To_Set (Printable_Whitespace_Characters_Sequence);
   begin
      return
        To_Lower
          (Trim
             (Source => Email_Address,
              Left   => Whitespace_Set,
              Right  => Whitespace_Set));
   end Normalize;

   -----------------------
   -- Syntax Validation --
   -----------------------
   function Validate_Syntax
     (Email_Address : String) return Syntax_Validation_Result'Class
   is
      Normalized_Value : constant String := Normalize (Email_Address);

      At_Sign_Idx : constant Natural :=
        Index (Normalized_Value, "@", Going => Backward);
   begin
      Step_01_Check_Presence_Of_At_Sign_Local_Part_And_Domain :
      begin
         if At_Sign_Idx = 0 then
            return New_Syntax_Validation_Fail (Error_Kind => Missing_At_Sign);
         end if;

         if At_Sign_Idx = Normalized_Value'First then
            return
              New_Syntax_Validation_Fail (Error_Kind => Missing_Local_Part);
         end if;

         if At_Sign_Idx = Normalized_Value'Last then
            return New_Syntax_Validation_Fail (Error_Kind => Missing_Domain);
         end if;
      end Step_01_Check_Presence_Of_At_Sign_Local_Part_And_Domain;

      Step_02_Check_Lengths :
      declare
         At_Sign_Idx_In_Octets : constant Natural :=
           Index (Normalized_Value, "@", Going => Backward);

         Local_Part_Length_In_Octets : constant Natural :=
           At_Sign_Idx_In_Octets - 1;

         Domain_Length_In_Octets : constant Natural :=
           Normalized_Value'Last - At_Sign_Idx_In_Octets;
      begin
         if Local_Part_Length_In_Octets > Max_Recipient_Name_Length_In_Octets
         then
            return
              New_Syntax_Validation_Fail (Error_Kind => Local_Part_Too_Long);
         end if;

         if Domain_Length_In_Octets > Max_Domain_Length_In_Octets then
            return New_Syntax_Validation_Fail (Error_Kind => Domain_Too_Long);
         end if;
      end Step_02_Check_Lengths;

      Step_03_Check_For_Two_Periods_In_A_Row :
      begin
         for I in Normalized_Value'First + 1 .. Normalized_Value'Last loop
            if Normalized_Value (I) = '.'
              and then Normalized_Value (I - 1) = '.'
            then
               return
                 New_Syntax_Validation_Fail
                   (Error_Kind => Consecutive_Periods);
            end if;
         end loop;
      end Step_03_Check_For_Two_Periods_In_A_Row;

      Check_Local_Part :
      declare
         Local_Part : constant String :=
           Normalized_Value (Normalized_Value'First .. At_Sign_Idx - 1);
      begin
         Step_04_Check_For_Period_At_The_Start_Of_The_Local_Part :
         begin
            if Local_Part (Local_Part'First) = '.' then
               return
                 New_Syntax_Validation_Fail
                   (Error_Kind => Local_Part_Starts_With_Period);
            end if;
         end Step_04_Check_For_Period_At_The_Start_Of_The_Local_Part;

         Step_05_Check_For_Period_At_The_End_Of_The_Local_Part :
         begin
            if Local_Part (Local_Part'Last) = '.' then
               return
                 New_Syntax_Validation_Fail
                   (Error_Kind => Local_Part_Ends_With_Period);
            end if;
         end Step_05_Check_For_Period_At_The_End_Of_The_Local_Part;

         Step_06_Check_For_Invalid_Characters_In_Local_Part :
         begin
            for C of Local_Part loop
               if not Is_Alphanumeric (C) and then C not in '.' | '-' | '_'
               then
                  return
                    New_Syntax_Validation_Fail
                      (Error_Kind => Invalid_Character_In_Local_Part);
               end if;
            end loop;
         end Step_06_Check_For_Invalid_Characters_In_Local_Part;

      end Check_Local_Part;

      Check_Domain :
      declare
         Domain : constant String :=
           Normalized_Value (At_Sign_Idx + 1 .. Normalized_Value'Last);

         Last_Period_Idx : constant Natural :=
           Index (Domain, ".", Going => Backward);
      begin
         Step_07_Check_For_Period_At_The_End_Of_The_Domain :
         begin
            if Domain (Domain'Last) = '.' then
               return
                 New_Syntax_Validation_Fail
                   (Error_Kind => Domain_Ends_With_Period);
            end if;
         end Step_07_Check_For_Period_At_The_End_Of_The_Domain;

         Step_08_Check_For_Period_Presence_In_Domain :
         begin
            if Last_Period_Idx = 0 then
               return
                 New_Syntax_Validation_Fail
                   (Error_Kind => Missing_Period_In_Domain);
            end if;
         end Step_08_Check_For_Period_Presence_In_Domain;

         Check_Base_Domain :
         declare
            Base_Domain : constant String :=
              Domain (Domain'First .. Last_Period_Idx - 1);
         begin
            Step_09_Check_The_First_Symbol_Of_The_Base_Domain :
            declare
               Base_Domain_First_Symbol : constant Character :=
                 Base_Domain (Base_Domain'First);
            begin
               if not Is_Alphanumeric (Base_Domain_First_Symbol) then
                  return
                    New_Syntax_Validation_Fail
                      (Error_Kind => Domain_Starts_With_Non_Alphanumeric);
               end if;
            end Step_09_Check_The_First_Symbol_Of_The_Base_Domain;

            Step_10_Check_For_Invalid_Characters_In_Base_Domain :
            begin
               for C of Base_Domain loop
                  if not Is_Alphanumeric (C) and then C not in '.' | '-' then
                     return
                       New_Syntax_Validation_Fail
                         (Error_Kind => Invalid_Character_In_Domain);
                  end if;
               end loop;
            end Step_10_Check_For_Invalid_Characters_In_Base_Domain;

            Step_11_Check_For_Two_Letters_Two_Hyphens_At_Domain_Start :
            begin
               if Base_Domain'Length > 3 then
                  declare
                     Base_Domain_1st_Symbol : constant Character :=
                       Base_Domain (Base_Domain'First);

                     Base_Domain_2nd_Symbol : constant Character :=
                       Base_Domain (Base_Domain'First + 1);

                     Base_Domain_3rd_Symbol : constant Character :=
                       Base_Domain (Base_Domain'First + 2);

                     Base_Domain_4th_Symbol : constant Character :=
                       Base_Domain (Base_Domain'First + 3);
                  begin
                     if Is_Letter (Base_Domain_1st_Symbol)
                       and then Is_Letter (Base_Domain_2nd_Symbol)
                       and then Base_Domain_3rd_Symbol = '-'
                       and then Base_Domain_4th_Symbol = '-'
                     then
                        return
                          New_Syntax_Validation_Fail
                            (Error_Kind =>
                               Domain_Starts_With_Two_Letters_Two_Hyphens);
                     end if;
                  end;
               end if;
            end Step_11_Check_For_Two_Letters_Two_Hyphens_At_Domain_Start;

            Step_12_Check_For_Periods_And_Hyphens_Next_To_Each_Other :
            begin
               if Base_Domain (Base_Domain'Last) = '-' then
                  return
                    New_Syntax_Validation_Fail
                      (Error_Kind => Adjacent_Periods_And_Hyphens_In_Domain);
               end if;

               if Base_Domain'Length > 1 then
                  for I in Base_Domain'First + 1 .. Base_Domain'Last - 1 loop
                     declare
                        C : constant Character := Base_Domain (I);

                        Prev_C : constant Character := Base_Domain (I - 1);
                     begin
                        if (C = '.' and then Prev_C = '-')
                          or else (C = '-' and then Prev_C = '.')
                        then
                           return
                             New_Syntax_Validation_Fail
                               (Error_Kind =>
                                  Adjacent_Periods_And_Hyphens_In_Domain);
                        end if;
                     end;
                  end loop;
               end if;
            end Step_12_Check_For_Periods_And_Hyphens_Next_To_Each_Other;

         end Check_Base_Domain;

         Check_TLD :
         declare
            TLD : constant String :=
              Domain (Last_Period_Idx + 1 .. Domain'Last);

            Is_All_Symbols_In_TLD_Are_Letters : constant Boolean :=
              (for all C of TLD => Is_Letter (C));
         begin
            if not (TLD'Length > 1 and then Is_All_Symbols_In_TLD_Are_Letters)
            then
               return New_Syntax_Validation_Fail (Error_Kind => Invalid_TLD);
            end if;
         end Check_TLD;

      end Check_Domain;

      return
        New_Syntax_Validation_Success (Normalized_Value => Normalized_Value);

   end Validate_Syntax;

end Strict_Email_Validator;
