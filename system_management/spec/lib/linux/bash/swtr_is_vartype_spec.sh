Describe 'swtr_is_vartype function'
   Include 'lib/linux/bash/swtr_is_vartype.sh'
   It 'Tests if a shell variable is integer variable type.'
      declare -i testvar=1;
      When call swtr_is_vartype '-i' testvar
	The status should be success
   End
   It 'Tests if a shell variable is string variable type.'
      declare testvar="";
      When call swtr_is_vartype '--' testvar
	The status should be success
   End
   It 'Tests if a shell variable is index variable type.'
      declare -a testvar;
      When call swtr_is_vartype '-a' testvar
	The status should be success
   End
   It 'Tests if a shell variable is associated variable type.'
      unset testvar;
      declare -A testvar;
      When call swtr_is_vartype '-A' testvar
	The status should be success
   End
   It 'Tests if a shell variable is not a string variable type.'
      unset testvar;
      declare -A testvar;
      When call swtr_is_vartype '--' testvar
	The status should be failure
   End
End
