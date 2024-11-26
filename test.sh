#!/bin/bash
# Get the path to the parser if it is on the current $PATH

# On MacOS, "./" is needed when running "parse <<< (input) | sh run.sh"
## From a file
### Example: ./parse < cp3ex4.417| sh run.sh
## From command line
### Example: parse <<< add(1,1) | sh run.sh 


RED="\033[31m"
GREEN="\033[32m"
WHITE="\033[0m"
YELLOW="\033[33m"

parse=$(command -v parse)

all_tests_passed=true
numCases=0

# TC 1 -- test for integer input no operations/functions
output=$(./parse <<< 1 | sh run.sh )
expected="1"
if [ "$output" == "$expected" ]; then
    echo "Test 1  | ${GREEN}Passed${WHITE}"
else
    echo "Test 1  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 2 -- test for add() function with literal integer values 
output=$(./parse <<< "add(1, 2)" | sh run.sh )
expected="3"  
if [ "$output" == "$expected" ]; then
    echo "Test 2  | ${GREEN}Passed${WHITE}"
else
    echo "Test 2  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# # TC 3 -- test for add() function with initial environment variables
output=$(./parse <<< "add(x,v)" | sh run.sh )
expected="15"  
if [ "$output" == "$expected" ]; then
    echo "Test 3  | ${GREEN}Passed${WHITE}"
else
    echo "Test 3  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 4 -- test for sub() function with initial environment variables
output=$(./parse <<< "sub(x,v)" | sh run.sh )
expected="5"  
if [ "$output" == "$expected" ]; then
    echo "Test 4  | ${GREEN}Passed${WHITE}"
else
    echo "Test 4  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 5 -- test for sub() function given a function parameter and an integer
output=$(./parse <<< "sub(add(1,1),2)" | sh run.sh )
expected="0"
if [ "$output" == "$expected" ]; then
    echo "Test 5  | ${GREEN}Passed${WHITE}"
else
    echo "Test 5  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi


# TC 6 -- conditional test given two functions as parameters
output=$(./parse <<< "equals?(add(1,1), add(2,0))" | sh run.sh )
expected="True"
if [ "$output" == "$expected" ]; then
    echo "Test 6  | ${GREEN}Passed${WHITE}"
else
    echo "Test 6  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 7 -- failing test for function call with no parameters
output=$(./parse <<< "sub()" | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 7."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 7  | ${GREEN}Passed${WHITE}"
fi

# TC 8 - lambda function given function call as parameter 
output=$(./parse <<< "λ(a){ add(a,12) }(add(1,5))" | sh run.sh )
expected="18"
if [ "$output" == "$expected" ]; then
    echo "Test 8  | ${GREEN}Passed${WHITE}"
else
    echo "Test 8  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
   ((numCases++))
fi

# TC 9  -- conditional check for is zero with untouched branch when true 
output=$(./parse <<< "λ(n) {
 cond 
  (equals?(n, 0) => 1) 
  (true => mul(n, sub(n, 1)))
}
(0)" | sh run.sh )
expected="1"
if [ "$output" == "$expected" ]; then
    echo "Test 9  | ${GREEN}Passed${WHITE}"
else
    echo "Test 9  | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi


# TC 10 -- conditional if not zero then return lambda function for multiplying param by param - 1
output=$(./parse <<< "λ(n) {
 cond 
  (zero?(n) => 1) 
  (true => mul(n, sub(n, 1)))
}
(10)" | sh run.sh )
expected="90"
if [ "$output" == "$expected" ]; then
    echo "Test 10 | ${GREEN}Passed${WHITE}"
else
    echo "Test 10 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi


# TC 11 -- factorial for value of 7 (updated syntax)
output=$(./parse < cp6ex3.417 | sh run.sh ) 
expected="5040"
if [ "$output" == "$expected" ]; then
    echo "Test 11 | ${GREEN}Passed${WHITE}"
else
    echo "Test 11 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 12 -- Multipler function
output=$(./parse <<< "{
  let double = 2;
  let doubleIt = λ(n) { mul(n, double) };
  doubleIt(8)
}" | sh run.sh )
expected="16"
if [ "$output" == "$expected" ]; then
    echo "Test 12 | ${GREEN}Passed${WHITE}"
else
    echo "Test 12 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 13 -- Integer out of bounds 
output=$(./parse <<< "9223372036854775808" 2>/dev/null | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 13."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 13 | ${GREEN}Passed${WHITE}"
fi

# TC 14 -- Integer max bounds
output=$(./parse <<< "-9223372036854775807" | sh run.sh )
expected="-9223372036854775807"
if [ "$output" == "$expected" ]; then
    echo "Test 14 | ${GREEN}Passed${WHITE}"
else
    echo "Test 14 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 15 -- Integer max bounds
output=$(./parse <<< "-9223372036854775808" 2>/dev/null | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 15."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 15 | ${GREEN}Passed${WHITE}"
fi

# TC 16 -- Integer out of bounds 
output=$(./parse <<< "9223372036854775807" | sh run.sh )
expected="9223372036854775807"
if [ "$output" == "$expected" ]; then
    echo "Test 16 | ${GREEN}Passed${WHITE}"
else
    echo "Test 16 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 17 -- String length
output=$(./parse <<< "strlen("aba")" | sh run.sh )
expected="3"
if [ "$output" == "$expected" ]; then
    echo "Test 17 | ${GREEN}Passed${WHITE}"
else
    echo "Test 17 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 18 -- positive? condition check
output=$(./parse <<< "positive?(5)" | sh run.sh )
expected="True"
if [ "$output" == "$expected" ]; then
    echo "Test 18 | ${GREEN}Passed${WHITE}"
else
    echo "Test 18 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 19 -- positive? condition check
output=$(./parse <<< "positive?(-5)" | sh run.sh )
expected="False"
if [ "$output" == "$expected" ]; then
    echo "Test 19 | ${GREEN}Passed${WHITE}"
else
    echo "Test 19 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 20 -- negative? condition check
output=$(./parse <<< "negative?(-5)" | sh run.sh )
expected="True"
if [ "$output" == "$expected" ]; then
    echo "Test 20 | ${GREEN}Passed${WHITE}"
else
    echo "Test 20 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 21 -- negative? condition check
output=$(./parse <<< "negative?(5)" | sh run.sh )
expected="False"
if [ "$output" == "$expected" ]; then
    echo "Test 21 | ${GREEN}Passed${WHITE}"
else
    echo "Test 21 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 22 -- Invalid function call resulting in 
output=$(./parse <<< "{
  let amt = 1;
  let incr = lambda(n) {add(amt,n)};
  let amt = 100;
  notExistingFunction(5)
}" | sh run.sh > /dev/null 2>&1)
code=$?
if [[ $code -ne 1 ]]; then
    echo "Interpreter returned exit code $code when it should have been 1 for Test 22."
    all_tests_passed=false
    ((numCases++))
else
    echo "Test 22 | ${GREEN}Passed${WHITE}"
fi

# TC 23 -- nonNegative? condition check
output=$(./parse <<< "nonNegative?(-5)" | sh run.sh )
expected="False"
if [ "$output" == "$expected" ]; then
    echo "Test 23 | ${GREEN}Passed${WHITE}"
else
    echo "Test 23 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 24 -- negative? condition check
output=$(./parse <<< "nonPositive?(5)" | sh run.sh )
expected="False"
if [ "$output" == "$expected" ]; then
    echo "Test 24 | ${GREEN}Passed${WHITE}"
else
    echo "Test 24 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 25 -- cp6ex1.417
output=$(./parse <<< "{
  let incr = λ(n) { add(n, x) };
  let x = 3;
  incr(1)
}" | sh run.sh )
expected="11"
if [ "$output" == "$expected" ]; then
    echo "Test 25 | ${GREEN}Passed${WHITE}"
else
    echo "Test 25 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 26 -- cp6ex2.417
output=$(./parse <<< "{
  let incr = λ(n) { add(n, x) };
  x = 3;
  incr(1)
}" | sh run.sh )
expected="4"
if [ "$output" == "$expected" ]; then
    echo "Test 26 | ${GREEN}Passed${WHITE}"
else
    echo "Test 26 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 27 -- cp6ex3.417
output=$(./parse <<< "{
 let fact = 123;     // Dummy value
 fact = λ(n)
        {
	 cond 
	   (zero?(n) => 1) 
	   (true => mul(n, fact(sub(n, 1))))
	};
  fact(7)	
}" | sh run.sh )
expected="5040"
if [ "$output" == "$expected" ]; then
    echo "Test 27 | ${GREEN}Passed${WHITE}"
else
    echo "Test 27 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# TC 27 -- cp6ex3.417
output=$(./parse <<< "{
 let fact = 123;     // Dummy value
 fact = λ(n)
        {
	 cond 
	   (zero?(n) => 1) 
	   (true => mul(n, fact(sub(n, 1))))
	};
  fact(7)	
}" | sh run.sh )
expected="5040"
if [ "$output" == "$expected" ]; then
    echo "Test 27 | ${GREEN}Passed${WHITE}"
else
    echo "Test 27 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi

# Under dynamic scope, the result here should be 105. (Using lexical scope results in 6)
# There is a new binding for 'amt' introduced after the definition
# of 'incr'.  When 'incr' runs and looks up 'amt', it finds the most
# recent binding, not the one that was extant when 'incr' was defined.
# TC - 28 cp5-ex1
output=$(./parse <<< "{
  let amt = 1;
  let incr =  lambda(n) {add(amt,n)};
  let amt = 100;
  incr(5)
}" | sh run.sh )
expected="6"
if [ "$output" == "$expected" ]; then
    echo "Test 28 | ${GREEN}Passed${WHITE}"
else
    echo "Test 28 | ${RED}Failed${WHITE}"
    echo "Expected Value: $expected"
    echo "Returned Value: $output"
    all_tests_passed=false
    ((numCases++))
fi



# Exit with appropriate status after all tests
if [ "$all_tests_passed" = true ]; then
    echo "*****************"
    echo "${GREEN}ALL TESTS PASS${WHITE}    "
    exit 0
else
    echo "       ${RED}FAILURE${WHITE}"
    echo "----------------------"
    echo "Failing number of cases: $numCases"
    exit 1
fi