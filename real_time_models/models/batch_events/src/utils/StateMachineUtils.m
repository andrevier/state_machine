% Utility class to load the data from the resources. Then, generates:
% - list of States class objects;
% - transitions array: A matrix containing information about all transitions in
%  with the events;
% - events array: An array with all the events number.
classdef StateMachineUtils

    properties
        eventsArray double
        transitions double
        statesArray cell
        switchedOffEvents cell
        numberOfEvents double
        numberOfStates double
    end

    methods
       
        function obj = readAllEvents(obj, allEventsPath)                   % check
            % Read the file containing all possible events and return an 
            % array nx1 of the number of events in the order of
            % reading.           

            size = StateMachineUtils.calcNumberOfLines(allEventsPath);
            obj.eventsArray = zeros(size,1);
            
            fid = fopen(allEventsPath);
            tline = fgets(fid);
            i = 1;
            while ischar(tline)
                obj.eventsArray(i,1) = str2double(tline);
                i = i + 1;
                tline = fgets(fid);
            end

            fclose(fid);
        end
        
        function obj = loadEventsInAds(obj, path)
            % Load control data from TCT auto-generated files (.ADS).
            % Read the file ALLEVENTS.ADS containing all the possible events and
            % outputs a column array with all the events, one per line.
            % This is a autogenerated file.
            fid = fopen(path);
            lines = textscan(fid, "%s", "Delimiter","\n");

            % Data of the events always begins at line 28.
            beginingOfdata = 28;
            allEvents = zeros(numel(lines{1}) - beginingOfdata,1);
            j = 1;
            for i = 28:numel(lines{1})
                % take off trailing spaces and substitute the blank string by empty
                % spaces.
                line = char(strrep(strtrim(lines{1}{i})," ", ""));
                event = str2double(line(2:end-1));

                if isnan(event)
                    break
                end
                allEvents(j) = event;
                j = j + 1;
            end
            fclose(fid);
            obj.eventsArray = allEvents;
        end

        function eventsArray = get.eventsArray(obj)
            eventsArray = obj.eventsArray;
        end
        
        function numberOfEvents = get.numberOfEvents(obj)
            numberOfEvents = size(obj.eventsArray, 1);
        end

        function obj = readTransitions(obj, path)
            % Read the file resources/transitions.txt and save the content in the nx3
            % array. The columns represent:
            % current state | input event | final state
            obj.transitions = readmatrix(path);
           
        end

        function obj = loadTransitionsInAds(obj, path) 
            % Load possible transitions of states due to events  from TCT 
            % auto-generated files (.PDS).
            % This auto-generated files contains a sequence of arrays in the format
            % <initial state> event  <final state>
            % Where:
            % <initial state> is the number of the initial state.
            % <final state> is the number of the final state.
            % event is the number of the final event.
            % Then, this method identify the squence in the file of the path and 
            % outputs a matrix of transitions nx3, where n is the number of 
            % transitions identified in the file.
        
            % Open the file of the path.
            fid = fopen(path);
            lines = textscan(fid, "%s", "Delimiter","\n");
        
            % Fixed line where all the sequences start.
            beginningOfData = 28;
        
            numberOfElements = numel(lines{1});
            
            obj.transitions = zeros(numberOfElements - beginningOfData, 3);
            j = 1;
            for i = beginningOfData:numberOfElements
                line = strtrim(lines{1}{i});
                if (line == "")
                    break;
                end
                line = split(line);
        
                obj.transitions(j, 1) = str2double(line{1});
                obj.transitions(j, 2) = str2double(line{2});
                obj.transitions(j, 3) = str2double(line{3});
                
                j = j + 1;
            end
            fclose(fid);        
        end 

        function transitions = get.transitions(obj)
            transitions = obj.transitions;
        end

        function obj = loadDisabledEventsInPdt(obj, path)
            % Load control data from TCT auto-generated files (.PDT).
            % The file .PDT contains control data displayed as a list of supervisor
            % states where disabling occurs, together with the events that must
            % be disabled there. The output is a nx1 cell array with all the data 
            % in the following format for each line:
            % [<state number>; e1; e2; e3; ...]
            %
            % The first number represents the state and the following numbers (e1, 
            % e2, ...), the events.
        
            % Open the file of the path.
            fid = fopen(path);
            lines = textscan(fid, "%s", "Delimiter","\n");
            
            % Data of the states always begins at line 13.
            beginingOfdata = 13;
            numberOfElements = numel(lines{1});
            
            disabledEvents = {};
            w = 1;
            for i = beginingOfdata:numberOfElements
                thisLine = strtrim(lines{1}{i});
                splittedLine = split(thisLine, "     ");
                if (splittedLine == "")
                    break;
                end
                if (numel(splittedLine) > 1)
                    for j = 1:numel(splittedLine)
                        subLineElement = splittedLine(j, 1);
                        if (subLineElement ~= "")
                            subLineElement = strrep(subLineElement, ":", "");
                            subLineElement = strtrim(subLineElement);
                            subLineElement = split(subLineElement);

                            disabledEvents{w, 1} = str2double(subLineElement);
                            w = w + 1;
                        end
                    end
                else
                    splittedLine = strrep(splittedLine, ":", "");
                    splittedLine = split(splittedLine);

                    disabledEvents{w, 1} = str2double(splittedLine);
                    w = w + 1;
                end
            end

            obj.switchedOffEvents = disabledEvents;
            obj.numberOfStates = size(obj.switchedOffEvents, 1);
        end

        function obj = readSwitchedOffEvents(obj, path)
            % Read the file with all the switched off events in each state 
            % and returns a cell array nx1 with an array in each element. 
            % The first element is the state number and the others, the
            % number of the events. Ex:
            % [<State number>, e1, e2, e3]
            % path: a relative path to a csv file where the state is in the
            % first column and the events are the following columns.
            fid = fopen(path);
            line = fgetl(fid);
            i = 1;
            obj.numberOfStates = StateMachineUtils.calcNumberOfLines(path);
            obj.switchedOffEvents = cell(obj.numberOfStates,1);
            while ischar(line)
                m = textscan(line, '%d', 'Delimiter', ',');
                obj.switchedOffEvents{i,1} = m{1};
                i = i + 1;
                line = fgetl(fid);
            end
            
            fclose(fid);
        end

        function statesArray = get.statesArray(obj)
            % Creates an array of State objects and fills the data from
            % the switchedOffEvents.           
            %obj.statesArray = State.empty(obj.numberOfStates, 0);
            obj.statesArray = cell(obj.numberOfStates, 1);

            % Loop the switchedOffEvents to create an array of states.
            for i = 1:obj.numberOfStates
                stateNumber = obj.switchedOffEvents{i}(1); 
                stateName = "s" + num2str(stateNumber);
                
                % Extract the array of active events in the state.
                matchedEvents = ismember(obj.eventsArray, obj.switchedOffEvents{i}(2:end));
                activeEvents = ~matchedEvents;
                
                obj.statesArray{i} = State(stateNumber, stateName, activeEvents);
            end
            statesArray = obj.statesArray;
        end
    end    

    methods(Static)
        function numberOflines = calcNumberOfLines(path)
            fid = fopen(path);
        
            tline = fgetl(fid);
        
            numberOflines = 0;
        
            while ischar(tline)
                tline = fgetl(fid);
                numberOflines = numberOflines + 1;
            end
            fclose(fid);
        end
    end    
end