#!/usr/bin/env python3
import sys
import json
from pprint import pprint
###################################################### Program environment ################################################################

# Flag for lexical scoping 
## True  -> Lexical
## False -> Dyanmic 
lexicalScopeFlag = True

solid_quotes = [
    "People tell you the world looks a certain way. Parents tell you how to think. Schools tell you how to think. TV. Religion. And then at a certain point, if you’re lucky, you realize you can make up your own mind. Nobody sets the rules but you. You can design your own life.”— Carrie Ann Moss",
    "Some women choose to follow men, and some choose to follow their dreams. If you’re wondering which way to go, remember that your career will never wake up and tell you that it doesn’t love you anymore.” — Lady Gaga",
    "Life is what happens to us while we are making other plans.”― Allen Saunders",
    "Life isn’t about finding yourself. Life is about creating yourself.”― George Bernard Shaw",
    "You are the sum total of everything you’ve ever seen, heard, eaten, smelled, been told, forgot ― it’s all there. Everything influences each of us, and because of that I try to make sure that my experiences are positive.” ― Maya Angelou",
    "Doubt kills more dreams than failure ever will.” – Suzy Kassem",
    "Keep your face always toward the sunshine, and shadows will fall behind you.” – Walt Whitman",
    "Whether you think you can or think you can’t, you’re right.” – Henry Ford",
    "Your talent determines what you can do. Your motivation determines how much you’re willing to do. Your attitude determines how well you do it.” —Lou Holtz",
    "The happiness of your life depends on the quality of your thoughts.” – Marcus Aurelius"
]

# Node class for connecting environments
class Node: 
    def __init__(self, data=None, next=None):
        self.data = data
        self.next = next

# Enviroment used as a linked list of bindings
init_env = Node(("x", 10), 
    Node(("v", 5),
    Node(("i", 1),
    Node(("add",          lambda x, y: x + y),
    Node(("sub",          lambda x, y: x - y),
    Node(("equals?",      lambda x, y: True if x == y else False),
    Node(("true",         True),
    Node(("false",        False),
    Node(("mul",          lambda x, y: x * y),
    Node(("zero?",        lambda n: True if n == 0 else False),
    Node(("print", print),
    Node(("printNL",      lambda s: print(s, end="")),
    Node(("prettyprint",  lambda s: pprint(s)),
    Node(("endl",         lambda: print("")),
    Node(("inspo",        lambda n: solid_quotes[n] if 0 <= n < len(solid_quotes) else solid_quotes[0]),
    Node(("strlen",       lambda s: len(s)),
    Node(("reverse",      lambda s: s[::-1]),
    Node(("positive?",    lambda n: True if n > 0 else False),
    Node(("negative?",    lambda n: True if n < 0 else False),
    Node(("nonPositive?", lambda n: True if n <= 0 else False),
    Node(("nonNegative?", lambda n: True if n >= 0 else False),
    Node(("RED",          lambda str: f"\033[31m{str}\033[0m"),
    Node(("GREEN",        lambda str: f"\033[32m{str}\033[0m"),
    Node(("YELLOW",       lambda str: f"\033[33m{str}\033[0m"),
    Node(("BLUE",         lambda str: f"\033[34m{str}\033[0m"),
    Node(("PURPLE",       lambda str: f"\033[35m{str}\033[0m"),
    Node(("WHITE",        lambda str: f"\033[0m{str}\033[0m"),
    Node(("SET_RED",      lambda: print("\033[31m", end="")),
    Node(("SET_GREEN",    lambda: print("\033[32m", end="")),
    Node(("SET_YELLOW",   lambda: print("\033[33m", end="")),
    Node(("SET_BLUE",     lambda: print("\033[34m", end="")),
    Node(("SET_PURPLE",   lambda: print("\033[35m", end="")),
    Node(("SET_WHITE",    lambda: print("\033[0m", end="")),
    Node(("CUSTOM_COLOR", lambda n: print(f"\033[38;5;{n}m", end="")),
    None)))))))))))))))))))))))))))))))))
)

def createPredicate(string):
    def predicate(expression):
        if isinstance(expression, list):
            return expression[0] == string
        else:
            return expression.get(string) is not None
    return predicate

isUserDefined =           createPredicate("UserDefined")
isLet =                   createPredicate("Let")
isCond =                  createPredicate("Cond")
isBlock =                 createPredicate("Block")
isLambda =                createPredicate("Lambda")
isAssignment =            createPredicate("Assignment")

##################################################### End Program Environment #############################################################

def main():
    variable = json.loads(input())
    result = parseInput(variable, init_env)
    print(result)
    exit(0)

# Function parses input and computes the result (eval) 
def parseInput(expression, environment):
    # Debug
    # pprint(expression)

    # Integer 
    if isinstance(expression, int):
        maxSigned = (1 << 63) - 1
        minSigned = maxSigned * -1
        try: 
            convertedVal = int(expression)
        except ValueError:
            print("ERROR: Input string is not a valid integer.", file=sys.stderr)
            sys.exit(1)

        if maxSigned < convertedVal or minSigned > convertedVal:
            print("ERROR: Input is not within the range representable by a signed 64-bit integer.", file=sys.stderr)
            sys.exit(1)
        return convertedVal
    
    # String 
    if isinstance(expression, str):
        return expression
    
    # Function
    if callable(expression):
        return expression
    # Block 
    if isBlock(expression):
        return blockEval(expression['Block'], environment)
    # Lambda
    if isLambda(expression):
        newExpression = expression['Lambda']
        param = newExpression[0]
        body = newExpression[1]
        return ['UserDefined', param, body, environment]
    # Assignment
    if isAssignment(expression):
        assignment = expression['Assignment']
        return applyAssignment(assignment, environment)
    if isLet(expression):
        return applyLet(expression["Let"], environment)
    # Cond
    if isCond(expression):
        conditionals = expression['Cond']
        return condEval(conditionals, environment)
    
    # Identifier 
    try:
        statement = expression['Identifier']
        return lookup_env(statement, environment)
    except:
       None

    # App
    if applicationCheck(expression):
        application = expression['Application']
        return funcExpandAndApply(application[0], application[1:], environment)
    
# Using apply function using operands
def funcExpandAndApply(func, arguments, environment):
    operator = parseInput(func, environment)
    parsedOperators = []
    for arg in arguments:
        parsedValue = parseInput(arg, environment)
        parsedOperators.append(parsedValue)

    try:
        if callable(operator):
            return operator(*parsedOperators)
        elif isUserDefined:
            # pprint(func) # debugging
            if lexicalScopeFlag is True:
                environment = operator[3] # environment
            
            # Add to list 
            newBinding = None
            for key, data in reversed(list(zip(stripParams(operator), parsedOperators))):
                newBinding = Node((key, data), newBinding)
           
            newEnv = reallocEnv(newBinding, environment)
            return parseInput(operator[2], newEnv) # body 
        
        else: 
            print(f"ERROR: Un-appliable function: {operator}", file=sys.stderr)
            sys.exit(1)
    # Exception case 
    except Exception as e: 
        print(f"ERROR: Failed with exception: {e} for {parsedOperators}", file=sys.stderr)
        exit(1)

# Responsible for replacing existing value 
def reassign(key, newValue, environment):
    if environment is None:
        print(f"ERROR: Unbound Identifier: {key}")
        exit(1)
    if environment.data[0] == key:
        environment.data = (key, newValue)  
        return newValue
    else:
        return reassign(key, newValue, environment.next)
    
# Responsible for applying the assignment to existing variable
def applyAssignment(exp, env):
    key = exp[0]["Identifier"] 
    rightHandSide = exp[1]               
    data = parseInput(rightHandSide, env)          
    reassign(key, data, env)    
    return data   

# Applying 'let' and creating new environment with data  
def applyLet(expression, env):
    key = expression[0]["Identifier"] 
    rightHandSide = expression[1]
    body = expression[2]
    data = parseInput(rightHandSide, env)
    return parseInput(body, reallocEnv(Node((key, data)), env))

# Parses parameters 
def stripParams(func):
    params = []
    for identifier in func[1]['Parameters']:
        params.append(identifier['Identifier'])
    return params

# Evaluates conditions
def condEval(expression, env):
    if len(expression) == 0:
        return False;
    # Parse conditionals in expression
    for condition in expression:
        params = condition['Clause']
        boolean = params[0]
        statement = params[1]
        truth = parseInput(boolean, env)
        if isTrue(truth):
            return parseInput(statement, env)
    return False

# Evaluates blocks
def blockEval(expression, env):
    if len(expression) == 1:
        return parseInput(expression[0], env)
    if not expression:
        return False
    else:
        parseInput(expression[0], env)
        return blockEval(expression[1:], env)

# link environment with new bindings
def reallocEnv(newBinding, env):
    if newBinding is None:
       return env
    bindings = newBinding.data
    return reallocEnv(newBinding.next, newBind(bindings[0], bindings[1], env))

# Evaluates if true or false
def isTrue(value):
    true_value = lookup_env("true", init_env)
    false_value = lookup_env("false", init_env)
    if value == true_value:
        return True
    if value == false_value:
        return False
    print(f"ERROR: Not a boolean {value}", file=sys.stderr)
    exit(1)

# App
def applicationCheck(expression):
   if type(expression) is dict and "Application" in expression:
       return True
   return False

# Lookup -- Node
def lookup_env(key, env):
    if env is None:
        return key
    if env.data[0] == key:
        return env.data[1]
    else:
        return lookup_env(key, env.next)

# New binding 
def newBind(key, data, env):
    return Node((key, data), env)

# main function call 
main()