#!/bin/bash
# Get the path to the parser if it is on the current $PATH


# On MacOS, "./" is not needed when running "parse <<< (input) | sh run.sh"
## From a file
### Example: parse < cp3ex4.417| sh run.sh
## From command line
### Example: parse <<< add(1,1) | sh run.sh 

# Example running from .417 file:
# Running on Windows
# parse < cp5ex2.417 | sh run.sh 

# Example running from command line: 
# Running on Windows (remove #'s')
# parse <<< "{
#   let base 10;
#   let multiplier lambda(x) {mul(base, x)};
#   multiplier(3)
# }" | sh run.sh
# 30

RED="\003[31m"
GREEN="\033[32m"
WHITE="\033[0m"

parse=$(command -v parse)

all_tests_passed=true
numCases=0

# TC 1 -- test for integer input no operations/functions
output=$(parse <<< 1 | sh run.sh )
expected="1"
if [ "$output" == "$expected" ]; then
    echo "Test 1  | ${GREEN}Passed${RESET}"
else
    echo "Test 1  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 2 -- test for add() function with literal integer values 
output=$(parse <<< "add(1, 2)" | sh run.sh )
expected="3"  
if [ "$output" == "$expected" ]; then
    echo "Test 2  | Passed"
else
    echo "Test 2  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# # TC 3 -- test for add() function with initial environment variables
output=$(parse <<< "add(x,v)" | sh run.sh )
expected="15"  
if [ "$output" == "$expected" ]; then
    echo "Test 3  | Passed"
else
    echo "Test 3  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 4 -- test for sub() function with initial environment variables
output=$(parse <<< "sub(x,v)" | sh run.sh )
expected="5"  
if [ "$output" == "$expected" ]; then
    echo "Test 4  | Passed"
else
    echo "Test 4  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 5 -- test for sub() function given a function parameter and an integer
output=$(parse <<< "sub(add(1,1),2)" | sh run.sh )
expected="0"
if [ "$output" == "$expected" ]; then
    echo "Test 5  | Passed"
else
    echo "Test 5  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi


# TC 6 -- conditional test given two functions as parameters
output=$(parse <<< "=(add(1,1), add(2,0))" | sh run.sh )
expected="True"
if [ "$output" == "$expected" ]; then
    echo "Test 6  | Passed"
else
    echo "Test 6  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 7 -- failing test for function call with no parameters
output=$(parse <<< "sub()" | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 7."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 7  | Passed"
fi

# TC 8 - lambda function given function call as parameter 
output=$(parse <<< "λ(a){ add(a,12) }(add(1,5))" | sh run.sh )
expected="18"
if [ "$output" == "$expected" ]; then
    echo "Test 8  | Passed"
else
    echo "Test 8  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
   ((numCases++))
fi

# TODO: adjust whenever = is removed for eqls due to assignment checkpoint 
# TC 9  -- conditional check for is zero with untouched branch when true 
output=$(parse <<< "λ(n) {
 cond 
  (=(n, 0) => 1) 
  (true => mul(n, sub(n, 1)))
}
(0)" | sh run.sh )
expected="1"
if [ "$output" == "$expected" ]; then
    echo "Test 9  | Passed"
else
    echo "Test 9  | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi


# TC 10 -- conditional if not zero then return lambda function for multiplying param by param - 1
output=$(parse <<< "λ(n) {
 cond 
  (zero?(n) => 1) 
  (true => mul(n, sub(n, 1)))
}
(10)" | sh run.sh )
expected="90"
if [ "$output" == "$expected" ]; then
    echo "Test 10 | Passed"
else
    echo "Test 10 | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi


# TC 11 -- Multiplier function
output=$(parse <<< "{
  let base 10;
  let base10 lambda(x) {mul(base, x)};
  base10(3)
}" | sh run.sh ) 
expected="30"
if [ "$output" == "$expected" ]; then
    echo "Test 11 | Passed"
else
    echo "Test 11 | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 12 -- Multipler function
output=$(parse <<< "{
  let double 2;
  let youknowihadtodoubleit lambda(n) {mul(double, n)};
  youknowihadtodoubleit(100)
}" | sh run.sh ) 
expected="200"
if [ "$output" == "$expected" ]; then
    echo "Test 12 | Passed"
else
    echo "Test 12 | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 13 -- Integer out of bounds 
output=$(parse <<< "9223372036854775808" 2>/dev/null | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 13."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 13 | Passed"
fi

# TC 14 -- Integer max bounds
output=$(parse <<< "-9223372036854775807" | sh run.sh )
expected="-9223372036854775807"
if [ "$output" == "$expected" ]; then
    echo "Test 14 | Passed"
else
    echo "Test 14 | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 15 -- Integer max bounds
output=$(parse <<< "-9223372036854775808" 2>/dev/null | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 15."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 15 | Passed"
fi

# TC 16 -- Integer out of bounds 
output=$(parse <<< "9223372036854775807" | sh run.sh )
expected="9223372036854775807"
if [ "$output" == "$expected" ]; then
    echo "Test 16 | Passed"
else
    echo "Test 16 | Failed"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# Exit with appropriate status after all tests
if [ "$all_tests_passed" = true ]; then
    echo "**********************"
    echo "*  All tests passed  *"
    echo "**********************"
    exit 0
else
    echo "       FAILURE"
    echo "----------------------"
    echo "Failing number of cases: $numCases"
    exit 1
fi