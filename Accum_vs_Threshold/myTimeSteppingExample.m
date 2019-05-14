%Initial State. Starting Position, Heading Angle, TimeStep. 
startpos_x = 0;
startpos_y = 0;
heading_angle = 5; %degrees
heading_angle = heading_angle * pi / 180
samples_per_second = 5; %per second
timestep = 1 / samples_per_second ;
speed = 10; %ms.

simulationtime = 30; %seconds
total_number_samples = simulationtime*samples_per_second;

X = zeros(total_number_samples, 1);
Y = zeros(total_number_samples, 1);

% Update Loop
for i = 1:total_number_samples
    if i > 1 
        X(i) = X(i-1) + ...
            cos(heading_angle) * speed * timestep;
        Y(i) = Y(i-1) + ...
            sin(heading_angle) * speed * timestep;
    end 
end
 

%End State plotting
plot(X,Y,'ro') %position
hold on

axis equal
%axis([-1 100 -100 100]);