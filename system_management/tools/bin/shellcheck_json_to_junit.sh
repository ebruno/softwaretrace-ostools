# Sample Junit format
#
#<?xml version="1.0" encoding="UTF-8" ?>
#   <testsuites id="20140612_170519" name="New_configuration (14/06/12 17:05:19)" tests="225" failures="1262" time="0.001">
#      <testsuite id="codereview.cobol.analysisProvider" name="COBOL Code Review" tests="45" failures="17" time="0.001">
#         <testcase id="codereview.cobol.rules.ProgramIdRule" name="Use a program name that matches the source file name" time="0.001">
#            <failure message="PROGRAM.cbl:2 Use a program name that matches the source file name" type="WARNING">
#WARNING: Use a program name that matches the source file name
#Category: COBOL Code Review – Naming Conventions
#File: /project/PROGRAM.cbl
#Line: 2
#      </failure>
#    </testcase>
#  </testsuite>
#</testsuites>
# Checkstype Sample XML output:
#<?xml version='1.0' encoding='UTF-8'?>
#<checkstyle version='4.3'>
#<file name='swtr&#95;is&#95;vartype.sh' >
#<error line='11' column='14' severity='warning' message='xxxx appears unused. Verify use &#40;or export if used externally&#41;.' source='ShellCheck.SC2034' />
#<error line='13' column='2' severity='info' message='read without &#45;r will mangle backslashes.' source='ShellCheck.SC2162' />
#</file>
#</checkstyle>
