% plotting straights of different angles from origin. 

A = [0,0]; %start coordinates
L = 50; %in metres, length.
B = [0,L]; %end coordinates
RdSize = 500; %granularity

Angles = linspace(-70, 70, 5);

%Plot initial straight
figure(1)
clf
plot([A(1) B(2)],[A(2) B(1)],'r','linewidth',2)
grid on
hold on

xlim([0 50])
ylim([-50 50])

for a = 1:length(Angles)
    Ang = Angles(a);
    %rotation angle from origin.
    rads = Ang*pi/180; %convert to radians.
    x_array = [A(1) B(2)];
    y_array = [A(2) B(1)];

    %define rotation matrix
    Rot_mat =[cos(rads) -sin(rads); sin(rads) cos(rads)]; %rotation matrix. ROtates point around origin

    New_coords = Rot_mat * [x_array; y_array];

    plot(New_coords(1,:),New_coords(2,:),'k','linewidth',2)
    hold on

    % X_pts = linspace(New_coords(1,1),New_coords(1,2),RdSize);
    % Y_pts = linspace(New_coords(2,1),New_coords(2,2),RdSize);
    
    % plot(X_pts,Y_pts,'k.','MarkerSize',5)
end

%rotate end point of straight
%B_rotated = Rot_mat*[B];