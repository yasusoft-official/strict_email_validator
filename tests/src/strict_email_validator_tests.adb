with Strict_Email_Validator.Validation_Tests;
with Strict_Email_Validator.Normalization_Tests;
with Trendy_Test.Reports;

procedure Strict_Email_Validator_Tests is
begin
   Trendy_Test.Register (Strict_Email_Validator.Validation_Tests.All_Tests);
   Trendy_Test.Register (Strict_Email_Validator.Normalization_Tests.All_Tests);
   Trendy_Test.Reports.Print_Basic_Report (Trendy_Test.Run);
end Strict_Email_Validator_Tests;
