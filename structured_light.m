function structured_light()
    % For x angles, facing the wall is pi/2
    % For y angles, flat is 0
    angle_rig_camera_x = 80 *(pi/180);
    angle_rig_camera_y = 15 *(pi/180);
    angle_rig_projector_x = 105 *(pi/180);
    angle_rig_projector_y = 0 *(pi/180);
    position_camera_projector_x = -.3;
    position_camera_projector_y = 0;
    position_camera_projector_z = 0;

    % Wall scan parameters
    % angle_rig_camera_x = 50 *(pi/180);
    % angle_rig_camera_y = 0 *(pi/180);
    % angle_rig_projector_x = 90 *(pi/180);
    % position_camera_projector_z = .3;

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
    res_projector_x = 500;
    res_projector_y = 500;
    mid_projector_x = floor(res_projector_x/2);
    mid_projector_y = floor(res_projector_y/2);
    focal_length_projector_x = (res_projector_x/2)/(tan(fov_projector_x/2));
    focal_length_projector_y = (res_projector_y/2)/(tan(fov_projector_y/2));

    photo = rgb2gray(imread('photos/box1.png'));
    pattern = imread('patterns/gradient_horizontal_500_10.png');
    
    function point = get_intersection(ang_proj_x, ang_cam_x, ang_cam_y, ...
                                      verbose)
        % Input: (pixel x angle relative to projector, pixel x angle
        % relative to the camera, pixel y angle relative to the camera,
        % optional verbose boolean)
        % Output: pixel 3D location relative to the projector (x, y, z)
        
        % Default value of optional parameter 'verbose' is 0
        if ~exist('verbose', 'var')
            verbose = 0;
        end
        
        % Change angles to be relative to the coordinate system
        ang_proj_x = ang_proj_x + angle_rig_projector_x;
        ang_cam_x = ang_cam_x + angle_rig_camera_x;
        ang_cam_y = ang_cam_y + angle_rig_camera_y;
        
        % Define the projector's view plane
        P1 = [0, 0, 0];
        P2 = [cos(ang_proj_x), sin(ang_proj_x), 1];
        P3 = [cos(ang_proj_x), sin(ang_proj_x), 0];
        normal = cross(P1-P2, P1-P3);
        x = sym('x');
        y = sym('y');
        z = sym('z');
        P = [x,y,z];
        planefunction = dot(normal, P-P1);
        
        % Define the camera's view line
        P4 = [position_camera_projector_x, ...
              position_camera_projector_y, ...
              position_camera_projector_z];
        P5 = [cos(ang_cam_x)*cos(ang_cam_y)+position_camera_projector_x, ...
              sin(ang_cam_x)*cos(ang_cam_y)+position_camera_projector_y, ...
              sin(ang_cam_y)+position_camera_projector_z];
        t = sym('t');
        line = P4 + t*(P5-P4);
        % Find the intersection point if any exists
        newfunction = subs(planefunction, P, line);
        t0 = solve(newfunction);
        point_frac = subs(line, t, t0);
        point = [double(point_frac(1)), double(point_frac(2)), double(point_frac(3))];
        fprintf('ang_proj_x: %f\nang_cam_x: %f\nang_cam_y: %f\n', ang_proj_x, ang_cam_x, ang_cam_y)
        fprintf('Intersection point: (%f, %f, %f) \n', point(1), point(2), ...
                point(3))
        
        if (verbose)
            figure(fig_int)
            hold on
            % Plot the projector
            plot3(P1(1), P1(2), P1(3), 'rX', 'linewidth', 3)
            % Plot the camera
            plot3(P4(1), P4(2), P4(3), 'bX', 'linewidth', 3)
            % Plot projector plane
            plane = patch([P1(1), P2(1), P3(1)], ...
                  [P1(2), P2(2), P3(2)], ...
                  [P1(3), P2(3), P3(3)], ...
                  'red');
            set(plane, 'facealpha', .2)
            % Plot camera line
            plot3([P4(1), P5(1)], ...
                  [P4(2), P5(2)], ...
                  [P4(3), P5(3)], ...
                  '-')
            % Plot intersection point
            plot3(point(1), point(2), point(3), 'kx', 'linewidth', 2);
            title('Intersection of Camera Lines and Projector Planes')
            legend('Projector', 'Camera', 'Projector Pixel Plane', ...
                'Camera Pixel Line', 'Intersection Point')
            xlabel('x')
            ylabel('y')
            zlabel('z')
            axis equal
        end
    end
    
    function newVal = map(val, fromLow, fromHigh, toLow, toHigh)
        % Input: (value to map, from low range, from high range, to low
        % range, to high range)
        % Output: mapped value
        
        frac = (val-fromLow)/(fromHigh-fromLow);
        newVal = frac*(toHigh-toLow)+toLow;
    end
    
    function [angle_x_cam, angle_y_cam] = get_pixel_camera_angle(x, y)
        % Input: (pixel's x pixel position on image, pixel's y
        % pixel position on image)
        % Output: (pixel's x angle relative to camera, pixel's y
        % angle relative to camera)
        
        % Flip y axis to make bottom of image 0
        y = res_camera_y - y;
        angle_x_cam = atan((mid_camera_x-x)/focal_length_camera_x);
        angle_y_cam = atan((y-mid_camera_y)/focal_length_camera_y);
    end

    function angle_x_proj = get_pixel_projector_angle(pixel_value, verbose)
        % Input: (pixel's 0-255 gray value in pattern, optional
        % verbose boolean)
        % Output: (pixel's x angle relative to projector)
        
        % Default value of optional parameter 'verbose' is 0
        if ~exist('verbose', 'var')
            verbose = 0;
        end
        
        found_x = 0;
        % Map the given 0-255 gray value to the actual gray value range
        % of the photo
        new_pixel_value = round(map(double(pixel_value), 7, 120, 10, 90));
        
        [~, x_size] = size(pattern);
        for i=1:x_size
            if (abs(new_pixel_value-double(pattern(250, i))) <= 1)
                x = i;
                found_x = 1;
                break
            end
            if (found_x == 0)
                x = 0;
            end
        end
        
        angle_x_proj = atan((mid_projector_x-x)/focal_length_projector_x);
        fprintf('gray value: %d\n', new_pixel_value);
        
        if (verbose)
            fprintf('Pixel''s x location: %d \n', x)
            fprintf('Pixel''s x angle from projector: %f \n', angle_x_proj)
            patt = figure;
            imshow(pattern)
            figure(patt)
            title({'Pattern Projected by Projector and Horizontal' ...
                ' Position of Isolated Pixel'})
            hold on
            plot([x, x], [0, 500], '-r', 'linewidth', 2)
        end
    end

    function pos = get_3d_pos(pixel_x, pixel_y)
        % Input: (photo x pixel, photo y pixel)
        % Output: 3D position (x, y, z)
        
        curr_pixel_value = photo(pixel_y, pixel_x);
        curr_proj_x_angle = get_pixel_projector_angle(curr_pixel_value);
        [curr_cam_x_angle, curr_cam_y_angle] = get_pixel_camera_angle(pixel_x, pixel_y);
        pos = get_intersection(curr_proj_x_angle, curr_cam_x_angle, curr_cam_y_angle, 1);
    end

    function run()
        clf
        
        % Points on photo to find 3D position of
        all_pix_num = [1800, 1400;
                       1800, 1600;
                       1800, 1800;
                       1800, 2000;
                       2000, 1400;
                       2000, 1600;
                       2000, 1800;
                       2000, 2000;
                       2200, 1400;
                       2200, 1600
                       2200, 1800;
                       2200, 2000;
                       2400, 1400;
                       2400, 1600;
                       2400, 1800;
                       2400, 2000];

        size_all_pix_num = size(all_pix_num);

        all_pixel_pos = zeros(size_all_pix_num(1), 3);
        for i=1:size_all_pix_num(1)
            all_pixel_pos(i, 1:3) = get_3d_pos(all_pix_num(i, 1), all_pix_num(i, 2));
        end
        size_all_pixel_pos = size(all_pixel_pos);
        figure(fig_3d)
        subplot(2, 1, 1)
        hold on
        for i=1:size_all_pixel_pos(1)
            plot3(all_pixel_pos(i, 1), all_pixel_pos(i, 2), ...
                all_pixel_pos(i, 3), '*', 'linewidth', 2)
        end

        title('3D Point Cloud')
        xlabel('x')
        ylabel('y')
        zlabel('z')
        axis equal
        
        subplot(2, 1, 2)
        imshow(photo);    
        hold on
        for i=1:size_all_pix_num(1)
            plot(all_pix_num(i, 1), all_pix_num(i, 2), '*', 'linewidth', 2)
        end
        title('Camera''s Point of View')
    end

    fig_int = figure;
    fig_3d = figure;
    run()
    
end