classdef TestStateMachineUtils < matlab.unittest.TestCase
    methods(Test)
        function testReadEvents(testCase)                                  %check
            % Test read the txt file with all events
            data = StateMachineUtils;
            data = data.readAllEvents('resources/allevents.txt');
            
            % When:
            eventsArray = data.getEventsArray();
            
            % Asserts that:
            exp = load("test/expectedEvents.mat");
            testCase.assertEqual(eventsArray, exp.expectedEvents);

        end

        function testLoadEventsFromAds(testCase)
            % Test read the txt file with all events
            data = StateMachineUtils;
            data = data.loadEventsInAds('resources/tct/ALLEVENT.ADS');
            
            % Asserts that
            exp = load("test/expectedEvents.mat");
            testCase.assertEqual(data.getEventsArray(), exp.expectedEvents);
        end

        function testCreateEventsTable(testCase)                           % check
            % Test if the table of events is created.
            data = StateMachineUtils;
            data = data.readAllEvents('resources/allevents.txt');
            
            % When 
            data = data.createEventsTable();           
            eventsTable = data.getEventsTable();
            
            % Assert equal
            exp = load('test/expectedEventsTable.mat');
            testCase.verifyEqual(eventsTable, exp.eventsTable);
        end
        
        function testLoadTransitionsInPds(testCase)
            utils = StateMachineUtils;
            utils = utils.loadTransitionsInAds('resources/SIMSUP1_MG1.ADS');

            % Asserts that
            exp = load("test/transitions.mat");
            testCase.verifyEqual(utils.getTransitions, exp.transitions);

        end

        function testReadTransitions(testCase)                             % check
            % Test if the transitions matrix is created.
            data = StateMachineUtils;
            data = data.readTransitions('resources/transitions.txt');
            
            % When
            transitions = data.getTransitions();
            
            % Asserts that
            exp = load("test/transitions.mat");
            testCase.verifyEqual(transitions, exp.transitions);
        end

        function testLoadDisabledEvents(testCase)
            data = StateMachineUtils;
            data = data.loadDisabledEventsInPdt('resources/DATA_SIMSUP1_MG1.PDT');
            
            % When
            switchedOffEvents = data.getSwitchedOffEvents();

            % Asserts that
            exp = load('test/switchedOffEvents.mat');
            
            % state 0
            actual = switchedOffEvents{1,1};
            expected = exp.switchedOffEvents{1,1};
            
            testCase.verifyEqual(actual, expected);
            
        end
        
        function testReadSwitchedOffEvents(testCase)                       % check
            data = StateMachineUtils;
            data = data.readSwitchedOffEvents('resources/switchedOffEvents.csv');
            
            % When
            switchedOffEvents = data.getSwitchedOffEvents();

            % Asserts that
            exp = load('test/switchedOffEvents.mat');
            
            % state 0
            actual = switchedOffEvents{1,1};
            expected = int32(exp.switchedOffEvents{1,1});
            
            testCase.verifyEqual(actual, expected);

            % state 1
            actual = switchedOffEvents{2,1};
            expected = int32(exp.switchedOffEvents{2,1});
            
            testCase.verifyEqual(actual, expected);

            % state 2
            actual = switchedOffEvents{3,1};
            expected = int32(exp.switchedOffEvents{3,1});
            
            testCase.verifyEqual(actual, expected);

            % state 3
            actual = switchedOffEvents{4,1};
            expected = int32(exp.switchedOffEvents{4,1});
            
            testCase.verifyEqual(actual, expected);

            % state 4
            actual = switchedOffEvents{5,1};
            expected = int32(exp.switchedOffEvents{5,1});
            
            testCase.verifyEqual(actual, expected);

            % state 5
            actual = switchedOffEvents{6,1};
            expected = int32(exp.switchedOffEvents{6,1});
            
            testCase.verifyEqual(actual, expected);
        end
    end
end