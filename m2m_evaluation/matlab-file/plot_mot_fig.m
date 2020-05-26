fig_dir = 'F:\CAPG\mm_lzj\code\network\plot_fig\fig3\';
list_fig = dir(fig_dir);
list_fig = list_fig(~ismember({list_fig.name}, {'.', '..'}));
pic = [];
gap_color = 220;
gap = 5;
for i = 1 : length(list_fig)
    fig_path = [fig_dir, list_fig(i).name];
    img_data = imread(fig_path);
    img_data = img_data(100:550,250:600, :);
    img_data(:, 351-gap:351, :) = gap_color;
    if i <= 4
        img_data(:, 351-gap-2:351, :) = gap_color;
    end
    pic=cat(2, pic, img_data);
    % subplot(1, 3, i);
    % imshow(img_data);
end
%% 
fig_dir = 'F:\CAPG\mm_lzj\code\network\plot_fig\fig4\';
list_fig = dir(fig_dir);
list_fig = list_fig(~ismember({list_fig.name}, {'.', '..'}));
pic1 = [];
for i = 1 : length(list_fig)
    fig_path = [fig_dir, list_fig(i).name];
    img_data = imread(fig_path);
    img_data = img_data(100:550,250:600, :);
    img_data(:, 351-gap:351, :) = gap_color;
    if i <= 4
        img_data(:, 351-gap-2:351, :) = gap_color;
    end
    pic1=cat(2, pic1, img_data);
    % subplot(1, 3, i);
    % imshow(img_data);
end
%% 
fig_dir = 'F:\CAPG\mm_lzj\code\network\plot_fig\fig5\';
list_fig = dir(fig_dir);
list_fig = list_fig(~ismember({list_fig.name}, {'.', '..'}));
pic2 = [];
for i = 1 : length(list_fig)
    fig_path = [fig_dir, list_fig(i).name];
    img_data = imread(fig_path);
    img_data = img_data(100:550,250:600, :);
    img_data(:, 351-gap:351, :) = gap_color;
    if i <= 4
        img_data(:, 351-gap-2:351, :) = gap_color;
    end
    pic2=cat(2, pic2, img_data);
    % subplot(1, 3, i);
    % imshow(img_data);
end

%% 
set(0,'defaultfigurecolor','default');
bs = 0.2;
figure;
subplot('Position',[0.1 0+bs 0.8 0.2]);
imshow(pic);
ylabel('序列3', 'Rotation', 0, 'Fontsize', 16);
subplot('Position',[0.1 0.21+bs 0.8 0.2]);
imshow(pic1);
ylabel('序列2', 'Rotation', 0, 'Fontsize', 16);
subplot('Position',[0.1 0.42+bs 0.8 0.2]);
imshow(pic2);
ylabel('序列1', 'Rotation', 0, 'Fontsize', 16);
subplot('Position',[0.1 0.62+bs 0.8 0.02]);
axis off;
title('前5帧为输入动作序列  |  后5帧为预测动作序列', 'Fontsize', 20);
