Describe 'swtr_log_msg function'
   Include 'lib/linux/bash/swtr_is_vartype.sh'
   Include 'lib/linux/bash/swtr_log_msg.sh'
   It 'Parameter Check no parameters'
     When call swtr_log_msg
       The status should be failure
       The stderr should equal '[ERROR] swtr_log_msg in lib/linux/bash/swtr_log_msg.sh at line 153 requires 3 or more parameter(s), 0 provided.'
   End
   It 'Parameter Check one parameters'
     When call swtr_log_msg x
       The status should be failure
       The stderr should equal '[ERROR] swtr_log_msg in lib/linux/bash/swtr_log_msg.sh at line 153 requires 3 or more parameter(s), 1 provided.'
   End
   It 'Parameter Check two parameters'
     When call swtr_log_msg x y
       The status should be failure
       The stderr should equal '[ERROR] swtr_log_msg in lib/linux/bash/swtr_log_msg.sh at line 153 requires 3 or more parameter(s), 2 provided.'
   End
   It 'Parameter Check three parameters'
     declare -a loginfo;
     When call swtr_log_msg INFO text "msg text"
       The status should be success
       The stdout should equal '[INFO] msg text'
   End
   It 'Multiple messages in index array'
	declare -a loginfo
	swtr_log_msg "INFO" text loginfo "Test message"
	swtr_log_msg "INFO" text loginfo "Test message"
	swtr_log_msg "INFO" text loginfo "Test message"
	swtr_log_msg "INFO" text loginfo "Test message"
	The variable ${#loginfo[@]} should equal 4;
   End
   Parameters
      "#1" INFO "Test Message"
      "#2" WARNING "Test Message"
      "#3" ERROR "Test Message"
      "#4" DEBUG "Test Message"
   End
   Example "Log $2 text message to console"
     When call swtr_log_msg "$2" text "Test message $1";
     The status should be success
     The stdout should equal "[$2] Test message $1"
   End
   Example "Log $2 json message to console"
     When call swtr_log_msg "$2" json "Test message $1";
     The status should be success
     The stdout should equal "{\"LOGLEVEL\":\"$2\",\"msg\":\"Test message $1\"}"
   End
   Example "Log $2 text message to indexed array"
     declare -a loginfo;
     When call swtr_log_msg "$2" text loginfo "Test message $1";
       The status should be success
       The variable ${#loginfo[@]} should equal 1;
     End
End
