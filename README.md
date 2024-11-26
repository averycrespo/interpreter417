# CSC417-INTERP
Python Version 3.12 https://www.python.org/downloads/release/python-3120rc1/ (macOS)

## Running:
manual input example: ./parse <<< 1 | sh run.sh 

manual input example: ./parse <<< "{
  let base = 10;
  let multiplier = lambda(x) {mul(base, x)};
  multiplier(3)
}" | sh run.sh 



input file: ./parse < cp6ex2.417 | sh run.sh

input file: ./parse < demoTest.417 | sh run.sh


## Testing (Windows and MacOS):
### Completed within WSL (Ubuntu)
command: dos2unix test.sh
command: bash test.sh
command: chmod +x run.sh parse test.sh

### MacOS
Previous commands mentioned within WSL were not used and testing worked fine.
Testing command: sh test.sh
 
