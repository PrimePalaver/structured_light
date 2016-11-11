function image_creation()

    function res = is_even(num)
        if (mod(num, 2) == 0)
            res = 1;
            return;
        end
         res = 0;
    end

    function checkerboard(boardSize, checkerSize)
        board = zeros(boardSize);
        for i=1:boardSize
            for j=1:boardSize
                x = i-1;
                y = j-1;
                if (is_even(floor(x/checkerSize)))
                    if (is_even(floor(y/10)))
                        board(i, j) = 1;
                    end
                else
                    if (~(is_even(floor(y/10))))
                        board(i, j) = 1;
                    end
                end
            end
        end
        imshow(board);
    end

    function linearGradient(board_size, division_size)
        max_val = 80;
        min_val = 10;
        
%         board1 = zeros(board_size);
%         for i=1:board_size
%             board1(i,:) = floor(i/division_size);
%         end
%         board1 = uint8(max_val * mat2gray(board1) + min_val);
%         board1
% %         imshow(board1);
%         imwrite(board1, 'gradient_vertical.png')
        
%         figure
        
        board2 = zeros(board_size);
        for i=1:board_size
            board2(:,i) = floor(i/division_size);
        end
        board2 = uint8((max_val * mat2gray(board2) + min_val));
%         imshow(board2);
        imwrite(board2, 'patterns/gradient_horizontal_500_10.png')
    end

%     checkerboard(1000, 10)
    linearGradient(500, 10)

end