function suite = testSuiteFromStatic(name)
% add on to xUnit to permit test cases to be collected from amongst the
% Static methods of a specified class.

    suite = TestSuite(name);

    mco = meta.class.fromName(name); % e.g., ?CCircularBuffer
    staticMethods = mco.MethodList([mco.MethodList.Static]);
    staticMethodNames = {staticMethods.Name};
    isTest = xunit.utils.isTestString(staticMethodNames) & strcmpi('public', {staticMethods.Access});
    testMethodNames = fliplr({staticMethods(isTest).Name});

    for k = 1:numel(testMethodNames)
        fcn = [mco.Name '.' testMethodNames{k}];
        suite.add(FunctionHandleTestCase(str2func(fcn), [], []));
    end
end