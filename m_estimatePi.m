classdef m_estimatePi < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        EstimatePiValueUIFigure  matlab.ui.Figure
        LeftPanel                matlab.ui.container.Panel
        RandomPointsGraph        matlab.ui.control.UIAxes
        RightPanel               matlab.ui.container.Panel
        PiValueGraph             matlab.ui.control.UIAxes
        Main                     matlab.ui.container.Panel
        Calculate                matlab.ui.control.Button
        EditFieldLabel           matlab.ui.control.Label
        RandomPointsNumber       matlab.ui.control.NumericEditField
        Header                   matlab.ui.container.Panel
        Title                    matlab.ui.control.Label
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startup(app)
            % Initialize
            app.PiValueGraph.cla;
            app.RandomPointsGraph.cla;
            app.EditFieldLabel.Text = "Number of random points:";
            app.PiValueGraph.YLim = [0, 4];
            
            % Plot square
            StartX = -1;
            EndX = 1;
            StartY = -1;
            EndY = 1;
            X = [StartX, EndX, EndX, StartX, StartX];
            Y = [StartY, StartY, EndY, EndY, StartY];
            plot(app.RandomPointsGraph, X, Y, 'r');
            
            % Plot circle
            hold(app.RandomPointsGraph, "on");
            Radius = 1;
            Angle = 0:0.01:2*pi;
            X = Radius*cos(Angle);
            Y = Radius*sin(Angle);
            plot(app.RandomPointsGraph, X, Y, 'b');
            hold(app.RandomPointsGraph, "off");
            
            % Plot pi value line
            yline(app.PiValueGraph, pi, 'b--', 'Pi');
        end

        % Button pushed function: Calculate
        function calculate(app, ~)
            % Initialize
            startup(app);
            set(app.Calculate, 'Enable', 'off');
            set(app.Calculate, 'Text', 'Calculating...');
            
            % Variables
            SquarePoints = app.RandomPointsNumber.Value;
            CirclePoints = 0;
            Radius = 1;
            CenterPoint = [0, 0];
            Range = [-1, 1];
            PiValues = zeros(SquarePoints, 1);
            
            app.PiValueGraph.XLim = [1, SquarePoints];
            hold(app.PiValueGraph, "on");
            plot(app.PiValueGraph, 1:app.RandomPointsNumber.Value, pi);
            hold(app.PiValueGraph, "off");
            
            for Iteration=1:SquarePoints
                RandomPoint = [
                                (Range(2)-Range(1)).*rand+Range(1)
                                (Range(2)-Range(1)).*rand+Range(1)
                              ];
                Distance = sqrt((RandomPoint(1)-CenterPoint(1))^2+(RandomPoint(2)-CenterPoint(2))^2);
                
                % Random points graph update
                hold(app.RandomPointsGraph, "on");
                if Distance <= Radius
                    plot(app.RandomPointsGraph, RandomPoint(1), RandomPoint(2), 'b.');
                    CirclePoints = CirclePoints + 1;
                else
                    plot(app.RandomPointsGraph, RandomPoint(1), RandomPoint(2), 'r.');
                end
                hold(app.RandomPointsGraph, "off");
                
                % Pi value graph update
                SquareArea = 4;
                PiValue = SquareArea * CirclePoints / Iteration;
                PiValues(Iteration, 1) = PiValue;
                % Percentage error calculate
                PiError = (abs(pi - PiValue)/pi)*100;
                hold(app.PiValueGraph, "on");
                plot(app.PiValueGraph, Iteration, PiValue, 'r.');
                PiValueGraphTitle = sprintf('Pi value in the %d iteration: %f (error: %f%%)', Iteration, PiValue, PiError);
                app.PiValueGraph.Title.String = PiValueGraphTitle;
                hold(app.PiValueGraph, "off");
                drawnow;
            end
            
            % Connect all points in pi value graph
            hold(app.PiValueGraph, "on");
            plot(app.PiValueGraph, 1:size(PiValues), PiValues, 'r-');
            hold(app.PiValueGraph, "off");
                
            % Finalize
            set(app.Calculate, 'Text', 'Calculate');
            set(app.Calculate, 'Enable', 'on');
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create EstimatePiValueUIFigure and hide until all components are created
            app.EstimatePiValueUIFigure = uifigure('Visible', 'off');
            app.EstimatePiValueUIFigure.Position = [100 100 800 600];
            app.EstimatePiValueUIFigure.Name = 'Estimate Pi Value';
            app.EstimatePiValueUIFigure.Resize = 'off';

            % Create LeftPanel
            app.LeftPanel = uipanel(app.EstimatePiValueUIFigure);
            app.LeftPanel.BorderType = 'none';
            app.LeftPanel.Position = [1 100 400 400];

            % Create RandomPointsGraph
            app.RandomPointsGraph = uiaxes(app.LeftPanel);
            title(app.RandomPointsGraph, 'Random Points')
            xlabel(app.RandomPointsGraph, 'X')
            ylabel(app.RandomPointsGraph, 'Y')
            app.RandomPointsGraph.Position = [1 2 400 400];

            % Create RightPanel
            app.RightPanel = uipanel(app.EstimatePiValueUIFigure);
            app.RightPanel.BorderType = 'none';
            app.RightPanel.Position = [401 100 400 400];

            % Create PiValueGraph
            app.PiValueGraph = uiaxes(app.RightPanel);
            title(app.PiValueGraph, 'Pi value in each iteration')
            xlabel(app.PiValueGraph, 'Iteration')
            ylabel(app.PiValueGraph, 'Pi value')
            app.PiValueGraph.Position = [1 2 400 400];

            % Create Main
            app.Main = uipanel(app.EstimatePiValueUIFigure);
            app.Main.BorderType = 'none';
            app.Main.Position = [1 1 800 100];

            % Create Calculate
            app.Calculate = uibutton(app.Main, 'push');
            app.Calculate.ButtonPushedFcn = createCallbackFcn(app, @calculate, true);
            app.Calculate.FontWeight = 'bold';
            app.Calculate.Tooltip = {'Press to start simulation'};
            app.Calculate.Position = [355 18 122 30];
            app.Calculate.Text = 'Calculate';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.Main);
            app.EditFieldLabel.HorizontalAlignment = 'center';
            app.EditFieldLabel.FontWeight = 'bold';
            app.EditFieldLabel.Position = [272 62 171 22];
            app.EditFieldLabel.Text = 'EditFieldLabel';

            % Create RandomPointsNumber
            app.RandomPointsNumber = uieditfield(app.Main, 'numeric');
            app.RandomPointsNumber.Limits = [1 10000];
            app.RandomPointsNumber.RoundFractionalValues = 'on';
            app.RandomPointsNumber.ValueDisplayFormat = '%.0f';
            app.RandomPointsNumber.HorizontalAlignment = 'center';
            app.RandomPointsNumber.Position = [450 62 107 22];
            app.RandomPointsNumber.Value = 1000;

            % Create Header
            app.Header = uipanel(app.EstimatePiValueUIFigure);
            app.Header.BorderType = 'none';
            app.Header.Position = [1 500 800 100];

            % Create Title
            app.Title = uilabel(app.Header);
            app.Title.HorizontalAlignment = 'center';
            app.Title.FontSize = 24;
            app.Title.Position = [301 40 207 30];
            app.Title.Text = 'Estimate Pi Value';

            % Show the figure after all components are created
            app.EstimatePiValueUIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = m_estimatePi

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.EstimatePiValueUIFigure)

            % Execute the startup function
            runStartupFcn(app, @startup)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.EstimatePiValueUIFigure)
        end
    end
end