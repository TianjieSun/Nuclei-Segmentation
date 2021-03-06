function  out_image  = nuclei_segmentation( in_image, is_large, OUT_LIAER_TH_LOW, OUT_LIAER_TH_HIGH)

%% Preprocessing
I = in_image;
I_1 = imhmin(I,40);

I_2 = imhmin(I,100);
I_subs =  I_2 - I_1;

I_ce = I - I_subs;
% imshow(I_ce);

se = strel('disk',3);
I_open = imopen(I,se);
H = imhmin(I_open,30);
Cnp = I_ce+H;

Cnp = imadjust(Cnp);
% figure, imshow(Cnp_ce);
Cnp_inverse = 255 - Cnp;
M_d = imdilate(Cnp_inverse,se);

% figure, imshow(M_d);

level = graythresh(M_d);
BW_1 = im2bw(M_d,level);

cc = bwconncomp(BW_1,4);
array = getfield(cc, 'PixelIdxList');
length = getfield(cc, 'NumObjects');
sizes = zeros(1,length);
for i = 1:length
    size_of_ele = size(array{1,i});
    
    sizes(i) = size_of_ele(1);
end

% if size(sizes) <= 20
%     OUT_LIAER_TH_LOW = 0.2;
%     
% else
%     OUT_LIAER_TH_LOW = 0.2;
%     OUT_LIAER_TH_HIGH = 0.01;
% end
sizes = sort(sizes);
% OUT_LIAER_TH_LOW = 0.1;
% % OUT_LIAER_TH_HIGH = 0.;
low_th = sizes(ceil(length*OUT_LIAER_TH_LOW));
high_th = sizes(ceil(length*(1-OUT_LIAER_TH_HIGH)));

if length >= is_large
    small_removed = bwareaopen(BW_1, low_th);
    large_kept = bwareaopen(small_removed, high_th);
    cleaned = small_removed - large_kept;
else
    small_removed = bwareaopen(BW_1, low_th);
    cleaned = small_removed;
end
% figure, imshow(large_kept);

% cleaned = small_removed - large_kept;
% % BW_1 = imbinarize(M_d,'adaptive');
% % figure, imshow(BW_1);
% 
% small_removed = bwareaopen(BW_1, low_th);
% figure, imshow(small_removed);
% 
% large_kept = bwareaopen(small_removed, high_th);
% % figure, imshow(large_kept);
% 
% cleaned = small_removed - large_kept;
% % cleaned = small_removed;
% % cleaned = large_removed;
% % cleaned = cleaned;
% figure, imshow(cleaned);
% out_image = cleaned;

%% Refinement of Nuclei Boundary Area
% 
% M_g = |I_ce - I_dilate|
M_d = imadjust(M_d);
M_g = uint8(abs(double(I_ce)-double(M_d)));
% figure, imshow(M_g);

% Inverse M_g to the result similar to the paper
M_g = 255-M_g;

% Contrast enhancement
% ????????
% M_g = imadjust(M_g);
% figure, imshow(M_g_ce);

% Apply global thresholding
BW_2 = imbinarize(M_g,0.8);
% figure, imshow(BW);

% Figure 3(c)
joined_image = or(cleaned,BW_2);

% cleaned_small_joined_image = bwareaopen(joined_image, low_th);
% large_kept_joined_image = bwareaopen(cleaned_small_joined_image, high_th);
% 
% cleaned_joined_image = cleaned_small_joined_image - large_kept_joined_image;

if length >= is_large
    cleaned_small_joined_image = bwareaopen(joined_image, low_th);
    cleaned_large_kept = bwareaopen(cleaned_small_joined_image, high_th);
    cleaned_joined_image = cleaned_small_joined_image - cleaned_large_kept;
    out_image = cleaned_joined_image;
    
else
    cleaned_small_joined_image = bwareaopen(joined_image, low_th);
    out_image = cleaned_small_joined_image;
end
% figure, imshow(cleaned_joined_image);
% out_image = cleaned_small_joined_image;
% out_image = cleaned_joined_image;

% figure
% subplot(1,2,1); imshow(I);
% subplot(1,2,2); imshow(out_image);
% % WaterShed
% bw = cleaned_joined_image;
% L = watershed(bw);
% bw2 = ~bwareaopen(~bw, 5);
% D = -bwdist(~bw);
% Ld = watershed(D);
% bw2 = bw;
% bw2(Ld == 0) = 0;
% % figure, imshow(bw2)
% mask = imextendedmin(D,2);
% 
% D2 = imimposemin(D,mask);
% Ld2 = watershed(D2);
% bw3 = bw;
% bw3(Ld2 == 0) = 0;
% % figure,imshow(bw3)
% out_image = bw3;
end

