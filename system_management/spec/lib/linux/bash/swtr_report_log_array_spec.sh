Describe 'swtr_report_log_array function'
    Include 'lib/linux/bash/swtr_report_log_array.sh'
   It 'Parameter Check no parameters'
     When call swtr_report_log_array
       The status should be failure
       The stderr should equal '[ERROR] swtr_report_log_array in lib/linux/bash/swtr_report_log_array.sh at line 153 requires 1 or more parameter(s), 0 provided.'
   End
   It 'Parameter Check one parameters'
     When call swtr_report_log_array x
       The status should be success
   End
   It 'Parameter Check two parameters order invalid.'
     declare -a x;
     When call swtr_report_log_array x y
     The status should be failure
     The stderr should equal '[ERROR] swtr_report_log_array in lib/linux/bash/swtr_report_log_array.sh at line 153 requested order is "y", allowed values are [ ascending, descending].'
   End
   It 'Parameter Check two parameters order ascending.'
     declare -a x;
     When call swtr_report_log_array x ascending
     The status should be success
   End
   It 'Parameter Check two parameters order descending.'
     declare -a x;
     When call swtr_report_log_array x descending
     The status should be success
   End
   It 'Parameter Array with two values order 1 param ascending.'
     declare -a x=("line1" "line2");
     When call swtr_report_log_array x
     The status should be success
     The line 1 should equal "line1"
     The line 2 should equal "line2"
   End
   It 'Parameter Array with two values order 2 params ascending.'
     declare -a x=("line1" "line2");
     When call swtr_report_log_array x ascending
     The status should be success
     The line 1 should equal "line1"
     The line 2 should equal "line2"
   End
   It 'Parameter Array with two values order 2 params descending.'
     declare -a x=("line1" "line2");
     When call swtr_report_log_array x descending
     The status should be success
     The line 1 should equal "line2"
     The line 2 should equal "line1"
   End
End
