function image_to_3D()
    angle_rig_camera_x = -15 *(pi/180);
    angle_rig_camera_y = 0 *(pi/180);
    angle_rig_projector_x = 0 *(pi/180);
    angle_rig_projector_y = 0 *(pi/180);
    distance_camera_projector_x = 15;
    distance_camera_projector_y = 0;
    distance_camera_projector_z = 14.75;

%     fov_camera_x = 42 *(pi/180);
    fov_camera_x = 64 *(pi/180);
    fov_camera_y = 40 *(pi/180);
    res_camera_x = 3900;
    res_camera_y = 2613;
    mid_camera_x = floor(res_camera_x/2);
    mid_camera_y = floor(res_camera_y/2);
    focal_length_camera_x = (res_camera_x/2)/(tan(fov_camera_x/2));
    focal_length_camera_y = (res_camera_y/2)/(tan(fov_camera_y/2));
    
    fov_projector_x = 34 *(pi/180);
    fov_projector_y = 18 *(pi/180);
    res_projector_x = 1000;
    res_projector_y = 1000;
    mid_projector_x = floor(res_projector_x/2);
    mid_projector_y = floor(res_projector_y/2);
    focal_length_projector_x = (res_projector_x/2)/(tan(fov_projector_x/2));
    focal_length_projector_y = (res_projector_y/2)/(tan(fov_projector_y/2));
    
    img = rgb2gray(imread('photos/gradient_horizontal_500_10.png'));
    imshow(img);
    
    function ans = get_intersection()
        % Get the coordinates of points P1, P2 and P3 that represent the plane
        P1 = [10 10 10];
        P2 = [10 20 10];
        P3 = [20 10 10];
        
        % Define normal of the plane
        normal = cross(P1-P2, P1-P3);
        
        syms x y z
        P = [x,y,z];
        % Find an equation for the plane through the points P1, P2 and P3
        planefunction = dot(normal, P-P1);
        % Represent the line
        P4 = [5 5 5];
        P5 = [3 1.5 1.5];
        % Parametrise the line
        syms t
        line = P4 + t*(P5-P4);
        % Find the intersection point if any exists
        newfunction = subs(planefunction, P, line);
        t0 = solve(newfunction);
        point = subs(line, t, t0);
        ans = subs(planefunction, P, point);
    end
    
    function res = map(val, fromLow, fromHigh, toLow, toHigh)
        frac = (val-fromLow)/(fromHigh-fromLow);
        res = frac*(toHigh-toLow)+toLow;
    end
    
    function [x_angle, y_angle] = pixel_camera_angle(x, y)
        x_angle = atan((mid_camera_x-x)/focal_length_camera_x);
        y_angle = atan((y-mid_camera_y)/focal_length_camera_y);
    end

    function x_angle = pixel_projector_angle(pixel_value)
        pixel_value
        pixel_value = map(pixel_value, 7, 120, 10, 80)
        x_size = size(img);
        x_size = x_size(2);
        for i=1:x_size
            if (abs(img(1400, i)-pixel_value) < 2)
                x = i
                img(1400, i)
                break
            end
        end
        x_angle = atan((mid_projector_x-x)/focal_length_projector_x);
%        x_angle = atan((mid_projector_x-x)/focal_length_projector_x);
%        y_angle = atan((y-mid_projector_y)/focal_length_projector_y);
    end

%     function [pos_x, pos_y, pos_z] = find_pixel_pos(camera_x, camera_y)
%         [angle_camera_x, angle_camera_y] = pixel_camera_angle(camera_x, camera_y);
%         angle_projector_x = pixel_projector_angle(img(camera_x, camera_y));
%         
%         A = (pi/2) + angle_rig_camera_x + angle_camera_x;
%         B = (pi/2) - angle_rig_projector_x - angle_projector_x;
%         C = (pi) - A - B;
%         pos_x = (distance_camera_projector_x * sin(A) * cos(B)) / sin(C);
%         pos_y = (distance_camera_projector_x * sin(A) * sin(B)) / sin(C);
%         
%         D = (pi/2) + angle_rig_camera_y + angle_camera_y;
%         E = (pi/2) - angle_rig_projector_y - angle_projector_y;
%         F = (pi) - D - E;
%         pos_z = (distance_camera_projector_z * sin(D) * cos(E)) / sin(F);
%     end

    function [pos_x, pos_y, pos_z] = find_pixel_pos(camera_x, camera_y)
        [angle_camera_x, angle_camera_y] = pixel_camera_angle(camera_x, camera_y);
        angle_projector_x = pixel_projector_angle(img(camera_x, camera_y));
        
        
    end

    function stuff()
        % Pick pixels on the image to find the 3D position of
        projector_pixels = zeros(25, 2);
        projector_pixels(1:5, 2) = 200;
        projector_pixels(6:10, 2) = 100;
        projector_pixels(11:15, 2) = 0;
        projector_pixels(16:20, 2) = -100;
        projector_pixels(21:25, 2) = -200;
        projector_pixels(1:5:25, 1) = -200;
        projector_pixels(2:5:25, 1) = -100;
        projector_pixels(3:5:25, 1) = 0;
        projector_pixels(4:5:25, 1) = 100;
        projector_pixels(5:5:25, 1) = 200;
        projector_pixels;

        hold on
        for i=1:2
            coord = round(ginput(1));
            [x, y, z] = find_pixel_pos(coord(1), coord(2), projector_pixels(i, 1), projector_pixels(i, 2));
            position(i, 1) = x;
            position(i, 2) = y;
            position(i, 3) = z;
        end

        figure
        hold on
        for i=1:2
            x = position(i, 1);
            y = position(i, 2);
            z = position(i, 3);
            scatter3(x, y, z)
        end
        xlabel('x')
        ylabel('y')
        zlabel('z')
        xlim([-1, 1])
        ylim([-1, 1])
    end

    find_pixel_pos(1400, 2600);
    % 119

%     for i=1:100
%         coord = round(ginput(1))
%         img(coord(2), coord(1))
%     end
end