#!/usr/bin/env python3
import sys
import json
import time
import random
import webbrowser
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


# Enviroment used as a linked list of bindings
init_env = {
    "x": 10, 
    "v": 5,
    "i": 1,
    "add": lambda x, y: x + y,
    "sub": lambda x, y: x - y,
    "=": lambda x, y: True if x == y else False,
    "true": True,
    "false": False,
    "mul": lambda x, y: x * y,
    "zero?": lambda n: True if n == 0 else False,
    "print": lambda s: print(s),
    "spaces":  " ",
    "banner":  "--------------------------------------",
    "time": lambda: time.ctime(),
    "random": lambda: solid_quotes[random.randint(0, len(solid_quotes) - 1)],
    "randomQuote": lambda n: solid_quotes[n] if 0 <= n < len(solid_quotes) else solid_quotes[0],
    "strlen": lambda s: len(s),
    "positive?": lambda n: True if n > 0 else False,
    "negative?": lambda n: True if n < 0 else False,
    "nonPositive?": lambda n: True if n <= 0 else False,
    "nonNegative?": lambda n: True if n >= 0 else False,
}

##################################################### End Program Environment #############################################################


# Main function
def main():
    variable = json.loads(input())
    result = parseInput(variable, init_env)
    if result is not None:
        print(result)
        exit(0)
    
    exit(0)

# Function parses input and computes the result (eval)
def parseInput(expression, environment = None):
    try:
        if isinstance(expression, int):
            return(integerCheck(expression))
    except ValueError as e:
        print("ERROR: Input is not a valid integer.", file=sys.stderr)
        sys.exit(1)

    if isinstance(expression, str):
        return(expression)

    innerParam = next( iter(expression) )

    if innerParam == "Lambda":
        return applyLambda(expression, environment)

    # For sure works.
    elif innerParam == "Cond":
        return condEval(expression["Cond"], environment)

    elif innerParam == "Identifier":
        return identifierCheck(expression["Identifier"], environment)

    elif innerParam == "Let":
        # print("let function called")
        return applyLet(expression[innerParam], environment)
    
    elif innerParam == "Block":
        for i in range(len(expression["Block"])):
            parseInput(expression["Block"][i], environment)
            if i == len(expression["Block"]) - 1:
                return parseInput(expression["Block"][i], environment)
    
    elif innerParam == "Application":
        result = expression['Application']
        if len(result) == 0:
            return None

        if "Lambda" in result[0]:
            lambdaFunction = lambdaCheck(result[0])
            args = []
            for arg in result[1:]:
                parsedArguement = parseInput(arg, environment)
                args.append(parsedArguement)

            if len(args) >= len(lambdaFunction['params']):
                return lambdaEval(lambdaFunction, args, environment)
            else: 
                print("ERROR: Invalid arguments for Lambda application.", file=sys.stderr)
                sys.exit(1)

        # Most difficult portion
        elif "Identifier" in result[0]:
            functionIdentifier = result[0]['Identifier']
            if functionIdentifier in environment:

                function = environment[functionIdentifier]
                if isinstance(function, dict) and "params" in function and "body" in function:
                    # Re-worked 
                    parsedArgs = [parseInput(arg, environment) for arg in result[1:]]
                    return lambdaEval(function, parsedArgs, environment)
                else:
                    return applicationCheck(result, environment)
                
        elif "Block" in result[0]:
            innerBlock = result[0]['Block']

            for expr in innerBlock[:-1]:
                parseInput(expr, environment)
            
            prevExpression = innerBlock[-1]
            if isinstance(prevExpression, dict) and "Identifier" in prevExpression:
                blockEvaluated = prevExpression["Identifier"]

            else:
                print("ERROR: Invalid function identifier.", file=sys.stderr)
                sys.exit(1)

            if blockEvaluated in environment:
                function = environment[blockEvaluated]
                if callable(function):
                    args = []
                    for arg in result[1:]:
                        parsedArguement = parseInput(arg, environment)
                        args.append(parsedArguement)
                    return function(*args)
                
                else:
                    print(f"ERROR: Uncallable function {blockEvaluated}.", file=sys.stderr)
                    sys.exit(1)
            else:
                print("ERROR: Invalid function identifier.", file=sys.stderr)
                sys.exit(1)
        else:
            return applicationCheck(result, environment)
    return None
# End function

# Integer check 
def integerCheck(expression):
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

# Strings/Identifiers
def identifierCheck(expression, environment):
    if isinstance(expression, int):
        return expression
    
    
    elif expression in environment:

        if expression == "time":
            timeString = time.strftime("%Y-%m-%d %H:%M:%S")
            print(timeString)
            exit(0)
        return environment[expression]
    
    elif isinstance(expression, str):
        return expression

    else:
        print(f"ERROR: Unknown identifier given '{expression}'.", file=sys.stderr)
        sys.exit(1)

# Application 
def applicationCheck(expression, environment):
    arguments = []
    binding = expression[0]['Identifier']
    if binding in environment:
        # print('binding', binding)
        function = environment[binding]

    else:
        print(f"ERROR: Unappliable function {binding}.",  file=sys.stderr)
        sys.exit(1)

    for arg in expression[1:]:
        if isinstance(arg, dict):
            parsedArg = parseInput(arg, environment)
            arguments.append(parsedArg)

        else:
            arguments.append(arg)
    try:
        return function(*arguments)
    except TypeError as e:
        print(f"ERROR: Invalid arguments for function '{binding}': {arguments}", file=sys.stderr)
        print(f"Details: {e}", file=sys.stderr)
        sys.exit(1)

# Lambda
def lambdaCheck(expression):
    params = []
    for p in expression['Lambda'][0]['Parameters']:
        params.append(p['Identifier'])
    body = expression['Lambda'][1]['Block']
    return {'params': params, 
            'body': body }

# Evaluates conditions
def condEval(expression, env):
    if len(expression) == 0:
        return False
    # Parse conditionals in expression
    for condition in expression:
        params = condition['Clause']
        boolean = params[0]
        statement = params[1]
        truth = parseInput(boolean, env)
        if isTrue(truth):
            return parseInput(statement, env)
    return False

# Evaluates if true or false
def isTrue(value):
   if value == init_env['true']:
        return True
   if value == init_env['false']:
        return False
   print(f"ERROR: Not a boolean {value}", file=sys.stderr)
   exit(1)


# Evaluates blocks
def blockEval(expression, env):
    if len(expression) == 1:
        return parseInput(expression[0], env)
    if not expression:
        return False
    else:
        parseInput(expression[0], env)
        return blockEval(expression[1:], env)


# Let function (new)
def applyLet(expression, environment):
    # Tuple <----- REQUIRED
    variable, variableExpression = expression
    identifier = variable['Identifier']
    value = parseInput(variableExpression, environment)

    if isinstance(value, dict) and 'Lambda' in value:
        value = applyLambda(value, environment)

    if lexicalScopeFlag is True and identifier in environment:
        return value

    environment[identifier] = value
    return value


# Applies lambda 
def applyLambda(expression, environment): 
    params = expression['Lambda'][0]['Parameters']
    block = expression['Lambda'][1]['Block']

    # Lambda function
    def function(*arguments):
        newEnvironment = environment.copy()  

        for i in range(len(params)):
            param = params[i]
            arg = arguments[i]
            newEnvironment[param['Identifier']] = parseInput(arg, environment)

        result = None

        for expr in block:
            result = parseInput(expr, newEnvironment)
        return result
    return function

# Evaluates Lambda 
def lambdaEval(function, arguments, newBindings = None):
    if len(arguments) != len(function['params']):
        print("ERROR: Invalid arguements when evaluating lambda function.", file=sys.stderr)
        sys.exit(1)

    newBindings = newBindings or init_env.copy()

    for i in range(len(function['params'])):
        param = function['params'][i]
        arg = arguments[i]
        newBindings[param] = arg

    if len(function['params']) > 1:
        key = function['params'][0]
        newBindings[key] = function

    result = None
    for expr in function['body']:
        result = parseInput(expr, newBindings)
    return result

# Run Main
main()

